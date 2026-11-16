{$StackFrames On}
/// <summary>Provides a per-user, per-session single instance and bounded local named-pipe command transport.</summary>
Unit Guake.IPC;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections;

 Type
  TGuakeInstance = Class
   Private
    fMutex        : THandle;
    fStop         : THandle;
    fReady        : THandle;
    fPrimary      : Boolean;
    fPipeName     : String;
    fUserSID      : String;
    fStartupError : String;
    fDescriptor   : Pointer;
    fThread       : TThread;
    fQueue        : TThreadedQueue<String>;
   Public
    /// <summary>Scope separates isolated tests from the user's real application instance.</summary>
    Constructor Create    (Const Scope : String = '');
    Destructor  Destroy; Override;
    Function    TryReceive(Out Command : String) : Boolean;
    /// <summary>Returns after the primary instance has accepted the command into its bounded UI queue.</summary>
    Procedure SendCommand(Const Command : String);
    Property IsPrimary : Boolean Read fPrimary;
    Property PipeName  : String Read fPipeName;
    Property UserSID   : String Read fUserSID;
  End;

 Function CurrentUserSID : String;
 Function ValidIPCCommand(Const Value : String) : Boolean;

Implementation

 Uses
  System.SyncObjs, System.JSON;

 Const
  MaxCommandBytes     = 65536;
  RejectRemoteClients = $00000008;
  FirstPipeInstance   = $00080000;

 Type
  TPipeWorker = Class(TThread)
   Private
    fOwner : TGuakeInstance;
   Protected
    Procedure Execute; Override;
   Public
    Constructor Create(Owner : TGuakeInstance);
  End;

 Function ConvertSDDL(Text : PWideChar; Revision : DWORD; Out Descriptor : Pointer; Size : PDWORD) : BOOL; Stdcall; External 'advapi32.dll' name 'ConvertStringSecurityDescriptorToSecurityDescriptorW';

 Function TokenSID(Token : THandle) : String;
  Var
   Needed : DWORD;
   Data   : TBytes;
   Text   : PWideChar;
  Begin
   Needed := 0;
   GetTokenInformation(Token, TokenUser, Nil, 0, Needed);
   If Needed = 0 Then
    RaiseLastOSError;
   SetLength(Data, Needed);
   Win32Check(GetTokenInformation(Token, TokenUser, @Data[0], Needed, Needed));
   Text := Nil;
   Win32Check(ConvertSidToStringSidW(PTokenUser(@Data[0]).User.Sid, Text));
   Try
    Result := Text;
   Finally
    LocalFree(HLOCAL(Text));
   End;
  End;

 Function CurrentUserSID : String;
  Var
   Token : THandle;
  Begin
   Win32Check(OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, Token));
   Try
    Result := TokenSID(Token);
   Finally
    CloseHandle(Token);
   End;
  End;

 Function ServerHasUser(Pipe : THandle; Const Sid : String) : Boolean;
  Var
   PID     : ULONG;
   Process : THandle;
   Token   : THandle;
  Begin
   Result := False;
   If Not GetNamedPipeServerProcessId(Pipe, PID) Then
    Exit;
   Process := OpenProcess($1000, False, PID);
   If Process = 0 Then
    Exit;
   Try
    If Not OpenProcessToken(Process, TOKEN_QUERY, Token) Then
     Exit;
    Try
     Result := TokenSID(Token) = Sid;
    Finally
     CloseHandle(Token);
    End;
   Finally
    CloseHandle(Process);
   End;
  End;

 Function ValidIPCCommand(Const Value : String) : Boolean;
  Var
   Root   : TJSONValue;
   Action : TJSONValue;
   name   : String;
  Begin
   Result := False;
   If (Value = '') Or (Length(Value) > MaxCommandBytes) Then
    Exit;
   Root := TJSONObject.ParseJSONValue(Value);
   Try
    If Not(Root Is TJSONObject) Then
     Exit;
    Action := TJSONObject(Root).GetValue('action');
    If Not(Action Is TJSONString) Then
     Exit;
    name   := ',' + Action.Value + ',';
    Result := Pos(name, ',show,hide,toggle,new-tab,close-tab,select-tab,rename-tab,split-horizontal,split-vertical,preferences,about,quit,save-session,restore-session,execute,fullscreen,unfullscreen,bgcolor,fgcolor,reset-colors,') > 0;
   Finally
    Root.Free;
   End;
  End;

 Function FinishIO(Pipe, Stop : THandle; Var Overlapped : TOverlapped; Timeout : DWORD; Out Count : DWORD) : Boolean;
  Var
   Handles    : Array[0..1] Of THandle;
   WaitResult : DWORD;
  Begin
   Handles[0] := Stop;
   Handles[1] := Overlapped.hEvent;
   WaitResult := WaitForMultipleObjects(2, @Handles[0], False, Timeout);
   Result     := WaitResult = WAIT_OBJECT_0 + 1;
   If Result Then
    Result := GetOverlappedResult(Pipe, Overlapped, Count, False)
   Else
    Begin
     CancelIoEx(Pipe, @Overlapped);
     // The OVERLAPPED and event remain alive until the cancellation has completed.
     GetOverlappedResult(Pipe, Overlapped, Count, True);
    End;
  End;

 Function Transfer(Pipe, Stop : THandle; Data : Pointer; Size : DWORD; Writing : Boolean) : Boolean;
  Var
   Overlapped : TOverlapped;
   Done       : DWORD;
   Count      : DWORD;
   Remaining  : DWORD;
   Deadline   : UInt64;
   NowTick    : UInt64;
   Success    : BOOL;
  Begin
   Result   := False;
   Done     := 0;
   Deadline := GetTickCount64 + 5000;
   FillChar(Overlapped, SizeOf(Overlapped), 0);
   Overlapped.hEvent := CreateEvent(Nil, True, False, Nil);
   If Overlapped.hEvent = 0 Then
    Exit;
   Try
    While Done < Size Do
     Begin
      If WaitForSingleObject(Stop, 0) = WAIT_OBJECT_0 Then
       Exit;
      ResetEvent(Overlapped.hEvent);
      Count := 0;
      If Writing Then
       Success := WriteFile(Pipe, (PByte(Data) + Done)^, Size - Done, Count, @Overlapped)
      Else
       Success := ReadFile(Pipe, (PByte(Data) + Done)^, Size - Done, Count, @Overlapped);
      If Not Success Then
       Begin
        If GetLastError <> ERROR_IO_PENDING Then
         Exit;
        NowTick := GetTickCount64;
        If NowTick < Deadline Then
         Remaining := DWORD(Deadline - NowTick)
        Else
         Remaining := 0;
        If Not FinishIO(Pipe, Stop, Overlapped, Remaining, Count) Then
         Exit;
       End;
      If Count = 0 Then
       Exit;
      Inc(Done, Count);
     End;
    Result := True;
   Finally
    CloseHandle(Overlapped.hEvent);
   End;
  End;

 Constructor TPipeWorker.Create(Owner : TGuakeInstance);
  Begin
   Inherited Create(True);
   FreeOnTerminate := False;
   fOwner          := Owner;
  End;

 Procedure TPipeWorker.Execute;
  Var
   Pipe        : THandle;
   Security    : TSecurityAttributes;
   Overlapped  : TOverlapped;
   LengthValue : DWORD;
   Count       : DWORD;
   Bytes       : TBytes;
   Command     : String;
   Ack         : Byte;
   Connected   : Boolean;
  Begin
   Pipe := INVALID_HANDLE_VALUE;
   FillChar(Overlapped, SizeOf(Overlapped), 0);
   Overlapped.hEvent := CreateEvent(Nil, True, False, Nil);
   Try
    Try
     Win32Check(Overlapped.hEvent <> 0);
     FillChar(Security, SizeOf(Security), 0);
     Security.nLength              := SizeOf(Security);
     Security.lpSecurityDescriptor := fOwner.fDescriptor;
     Pipe                          := CreateNamedPipe(PChar(fOwner.fPipeName), PIPE_ACCESS_DUPLEX Or FILE_FLAG_OVERLAPPED Or FirstPipeInstance,
     PIPE_TYPE_BYTE Or PIPE_READMODE_BYTE Or PIPE_WAIT Or RejectRemoteClients, 1, MaxCommandBytes, MaxCommandBytes, 5000, @Security);
     Win32Check(Pipe <> INVALID_HANDLE_VALUE);
    Except
     On E : Exception Do
      Begin
       fOwner.fStartupError := E.ClassName + ': ' + E.Message;
       SetEvent(fOwner.fReady);
       Exit;
      End;
    End;
    SetEvent(fOwner.fReady);
    While WaitForSingleObject(fOwner.fStop, 0) <> WAIT_OBJECT_0 Do
     Begin
      ResetEvent(Overlapped.hEvent);
      Connected := ConnectNamedPipe(Pipe, @Overlapped);
      If Not Connected Then
       Case GetLastError Of
        ERROR_PIPE_CONNECTED : Connected := True;
        ERROR_IO_PENDING     : Connected := FinishIO(Pipe, fOwner.fStop, Overlapped, INFINITE, Count);
       End;
      If Not Connected Then
       Break;
      Try
       LengthValue := 0;
       If Not Transfer(Pipe, fOwner.fStop, @LengthValue, SizeOf(LengthValue), False) Then
        Continue;
       If (LengthValue = 0) Or (LengthValue > MaxCommandBytes) Then
        Continue;
       SetLength(Bytes, LengthValue);
       If Not Transfer(Pipe, fOwner.fStop, @Bytes[0], LengthValue, False) Then
        Continue;
       Ack := 0;
       Try
        Command := TEncoding.UTF8.GetString(Bytes);
        If ValidIPCCommand(Command) And (fOwner.fQueue.PushItem(Command) = wrSignaled) Then
         Ack := 1;
       Except
        On E : Exception Do
         OutputDebugString(PChar(E.ClassName + ': ' + E.Message));
       End;
       // Wait for the reader's receipt before disconnecting; a buffered write alone
       // does not guarantee that DisconnectNamedPipe will preserve unread reply data.
       If Transfer(Pipe, fOwner.fStop, @Ack, SizeOf(Ack), True) Then
        Transfer(Pipe, fOwner.fStop, @Ack, SizeOf(Ack), False);
      Finally
       DisconnectNamedPipe(Pipe);
      End;
     End;
   Finally
    If Pipe <> INVALID_HANDLE_VALUE Then
     CloseHandle(Pipe);
    If Overlapped.hEvent <> 0 Then
     CloseHandle(Overlapped.hEvent);
   End;
  End;

 Constructor TGuakeInstance.Create(Const Scope : String);
  Var
   Security : TSecurityAttributes;
   name     : String;
   Session  : DWORD;
   Error    : DWORD;
   c        : Char;
  Begin
   Inherited Create;
   For c In Scope Do
    If Not CharInSet(c, ['a'..'z', 'A'..'Z', '0'..'9', '-', '_', '.']) Then
     Raise EArgumentException.Create('Invalid IPC scope');
   fUserSID := CurrentUserSID;
   Win32Check(ProcessIdToSessionId(GetCurrentProcessId, Session));
   name := 'Guake.Windows.' + fUserSID + '.' + IntToStr(Session);
   If Scope <> '' Then
    name     := name + '.' + Scope;
   fPipeName := '\\.\pipe\' + name;
   Win32Check(ConvertSDDL(PChar('D:P(A;;GA;;;' + fUserSID + ')'), 1, fDescriptor, Nil));
   FillChar(Security, SizeOf(Security), 0);
   Security.nLength              := SizeOf(Security);
   Security.lpSecurityDescriptor := fDescriptor;
   fMutex                        := CreateMutex(@Security, False, PChar('Local\' + name));
   Error                         := GetLastError;
   Win32Check(fMutex <> 0);
   fPrimary := Error <> ERROR_ALREADY_EXISTS;
   fStop    := CreateEvent(Nil, True, False, Nil);
   Win32Check(fStop <> 0);
   fReady := CreateEvent(Nil, True, False, Nil);
   Win32Check(fReady <> 0);
   fQueue := TThreadedQueue<String>.Create(64, 0, 0);
   If fPrimary Then
    Begin
     fThread := TPipeWorker.Create(Self);
     fThread.Start;
     If WaitForSingleObject(fReady, 5000) <> WAIT_OBJECT_0 Then
      Raise EOSError.Create('Named pipe startup timed out');
     If fStartupError <> '' Then
      Raise EOSError.Create(fStartupError);
    End;
  End;

 Destructor TGuakeInstance.Destroy;
  Begin
   If fStop <> 0 Then
    SetEvent(fStop);
   If fThread <> Nil Then
    Begin
     fThread.WaitFor;
     fThread.Free;
    End;
   fQueue.Free;
   If fReady <> 0 Then
    CloseHandle(fReady);
   If fStop <> 0 Then
    CloseHandle(fStop);
   If fMutex <> 0 Then
    CloseHandle(fMutex);
   If fDescriptor <> Nil Then
    LocalFree(HLOCAL(fDescriptor));
   Inherited;
  End;

 Function TGuakeInstance.TryReceive(Out Command : String) : Boolean;
  Begin
   Result := fQueue.PopItem(Command) = wrSignaled;
  End;

 Procedure TGuakeInstance.SendCommand(Const Command : String);
  Var
   Pipe        : THandle;
   Bytes       : TBytes;
   LengthValue : DWORD;
   Ack         : Byte;
   Deadline    : UInt64;
  Begin
   Bytes := TEncoding.UTF8.GetBytes(Command);
   If (Length(Bytes) = 0) Or (Length(Bytes) > MaxCommandBytes) Or Not ValidIPCCommand(Command) Then
    Raise EArgumentException.Create('Invalid IPC command');
   Deadline := GetTickCount64 + 5000;
   Repeat
    Pipe := CreateFile(PChar(fPipeName), GENERIC_READ Or GENERIC_WRITE, 0, Nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
    If Pipe <> INVALID_HANDLE_VALUE Then
     Break;
    If Not(GetLastError In [ERROR_PIPE_BUSY, ERROR_FILE_NOT_FOUND]) Then
     RaiseLastOSError;
    WaitNamedPipe(PChar(fPipeName), 100);
    Sleep(10);
   Until GetTickCount64 >= Deadline;
   Win32Check(Pipe <> INVALID_HANDLE_VALUE);
   Try
    If Not ServerHasUser(Pipe, fUserSID) Then
     Raise EOSError.Create('Named pipe server belongs to another user');
    LengthValue := Length(Bytes);
    If Not Transfer(Pipe, fStop, @LengthValue, SizeOf(LengthValue), True) Or
    Not Transfer(Pipe, fStop, @Bytes[0], LengthValue, True) Or
    Not Transfer(Pipe, fStop, @Ack, SizeOf(Ack), False) Then
     Raise EOSError.Create('Named pipe transfer failed');
    If Not Transfer(Pipe, fStop, @Ack, SizeOf(Ack), True) Then
     Raise EOSError.Create('Named pipe receipt failed');
    If Ack <> 1 Then
     Raise EArgumentException.Create('Named pipe command was rejected or the queue is full');
   Finally
    CloseHandle(Pipe);
   End;
  End;

End.
