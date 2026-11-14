{$StackFrames On}
/// <summary>Owns a Windows pseudoconsole, a kill-on-close process job and independent input/output pumps.</summary>
Unit Guake.ConPTY;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, System.SyncObjs;

 Type
  TConPtySession = Class;

  TConPtyPump = Class(TThread)
   Private
    fSession : TConPtySession;
    fReading : Boolean;
   Protected
    Procedure Execute; Override;
   Public
    /// <summary>Initializes this service and acquires the resources whose lifetime it owns.</summary>
    Constructor Create(Session : TConPtySession; Reading : Boolean);
  End;

  TConPtySession = Class
   Private
    fPty       : THandle;
    fProcess   : THandle;
    fJob       : THandle;
    fInput     : THandle;
    fOutput    : THandle;
    fProcessId : Cardinal;
    fReader    : TConPtyPump;
    fWriter    : TConPtyPump;
    fLock      : TCriticalSection;
    fWake      : TEvent;
    fReceived  : TMemoryStream;
    fPending   : TMemoryStream;
    fStopping  : Boolean;
    fError     : String;
    Procedure Fail(Const Message : String);
    Procedure ReadLoop;
    Procedure WriteLoop;
    Function  GetError : String;
   Public
    /// <summary>Initializes this service and acquires the resources whose lifetime it owns.</summary>
    Constructor    Create(Const Executable, Arguments, Directory : String; Columns, Rows : Integer; Environment : TStrings = Nil);
    /// <summary>Releases owned resources; borrowed settings and view references are not freed.</summary>
    Destructor     Destroy; Override;
    /// <summary>Checks that the required pseudoconsole entry points exist in kernel32.</summary>
    Class Function Supported : Boolean; Static;
    /// <summary>Atomically drains queued pseudoconsole output without blocking on pipe input.</summary>
    Function       ReadAvailable : TBytes;
    /// <summary>Queues bytes for the dedicated input writer; enforces the session input queue limit.</summary>
    Procedure      Send(Const Bytes : TBytes);
    /// <summary>Encodes Unicode input as UTF-8 and queues it for the pseudoconsole writer.</summary>
    Procedure SendText(Const Text : String);
    Procedure Resize  (Columns, Rows : Integer);
    /// <summary>Ends the process job, drains final console output and closes all session handles; safe to repeat.</summary>
    Procedure      Stop;
    /// <summary>After process exit, closes the pseudoconsole and waits for the reader to queue all final output.</summary>
    Procedure CompleteOutput;
    /// <summary>Checks the child process handle without waiting for it to exit.</summary>
    Function       Running : Boolean;
    /// <summary>Returns the Windows process exit status, including STILL_ACTIVE for a live child.</summary>
    Function       ExitCode : Cardinal;
    Property ProcessId : Cardinal Read fProcessId;
    Property ErrorText : String Read GetError;
  End;

Implementation

 Uses
  System.Generics.Collections, System.Math, Guake.Shells;

 Type
  TCreatePseudoConsole = Function(Size : TCoord; Input, Output : THandle; Flags : DWORD; Out Pty : THandle) : HRESULT;

  Stdcall;

  TResizePseudoConsole = Function(Pty : THandle; Size : TCoord) : HRESULT;

  Stdcall;

  TClosePseudoConsole = Procedure(Pty : THandle);

  Stdcall;

  TExtendedStartup = Record
   Info       : TStartupInfo;
   Attributes : Pointer;
  End;

 Const
  PseudoConsoleAttribute             = $00020016;
  JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = $00002000;
  EXTENDED_STARTUPINFO_PRESENT       = $00080000;
  MaxBufferedOutput                  = 16 * 1024 * 1024;
  MaxBufferedInput                   = 4 * 1024 * 1024;

 Function StartProcess(ApplicationName, CommandLine : PChar; ProcessAttributes, ThreadAttributes : Pointer; InheritHandles : BOOL; Flags : DWORD; Environment : Pointer; Directory : PChar; Startup, ProcessInfo : Pointer) : BOOL; Stdcall; External 'kernel32.dll' name 'CreateProcessW';

 Function InitAttributes(List : Pointer; Count, Flags : DWORD; Var Size : NativeUInt) : BOOL; Stdcall; External 'kernel32.dll' name 'InitializeProcThreadAttributeList';

 Function UpdateAttributes(List : Pointer; Flags : DWORD; Attribute : NativeUInt; Value : Pointer; Size : NativeUInt; Previous, Returned : Pointer) : BOOL; Stdcall; External 'kernel32.dll' name 'UpdateProcThreadAttribute';

 Procedure DeleteAttributes(List : Pointer); Stdcall; External 'kernel32.dll' name 'DeleteProcThreadAttributeList';

 Function CreateJob(Attributes : Pointer; name : PChar) : THandle; Stdcall; External 'kernel32.dll' name 'CreateJobObjectW';

 Function CreateApi : TCreatePseudoConsole;
  Begin
   Result := GetProcAddress(GetModuleHandle('kernel32.dll'), 'CreatePseudoConsole');
  End;

 Function ResizeApi : TResizePseudoConsole;
  Begin
   Result := GetProcAddress(GetModuleHandle('kernel32.dll'), 'ResizePseudoConsole');
  End;

 Function CloseApi : TClosePseudoConsole;
  Begin
   Result := GetProcAddress(GetModuleHandle('kernel32.dll'), 'ClosePseudoConsole');
  End;

 Procedure CloseOwned(Var Handle : THandle);
  Begin
   If (Handle <> 0) And (Handle <> INVALID_HANDLE_VALUE) Then
    CloseHandle(Handle);
   Handle := 0;
  End;

 Function EnvironmentBlock(Overrides : TStrings) : String;
  Var
   Source : PChar;
   Cursor : PChar;
   Items  : TStringList;
   i      : Integer;
   name   : String;
   Value  : String;
   Entry  : String;
  Begin
   Items := TStringList.Create;
   Try
    Items.CaseSensitive := False;
    Source              := GetEnvironmentStrings;
    If Source = Nil Then
     RaiseLastOSError;
    Try
     Cursor := Source;
     While Cursor^ <> #0 Do
      Begin
       Entry := Cursor;
       Items.Add(Entry);
       Inc(Cursor, Length(Entry) + 1);
      End;
    Finally
     FreeEnvironmentStrings(Source);
    End;
    If Overrides <> Nil Then
     For i := 0 To Overrides.Count - 1 Do
      Begin
       name  := Overrides.Names[i];
       Value := Overrides.ValueFromIndex[i];
       If (name = '') Or (Pos(#0, Value) > 0) Then
        Raise EArgumentException.Create('Invalid session environment');
       Items.Values[name] := Value;
      End;
    Items.Values['TERM']         := 'xterm-256color';
    Items.Values['TERM_PROGRAM'] := 'guake';
    Items.Sort;
    Result  := '';
    For i   := 0 To Items.Count - 1 Do
     Result := Result + Items[i] + #0;
    Result  := Result + #0;
   Finally
    Items.Free;
   End;
  End;

 Constructor TConPtyPump.Create(Session : TConPtySession; Reading : Boolean);
  Begin
   Inherited Create(True);
   FreeOnTerminate := False;
   fSession        := Session;
   fReading        := Reading;
  End;

 Procedure TConPtyPump.Execute;
  Begin
   Try
    If fReading Then
     fSession.ReadLoop
    Else
     fSession.WriteLoop;
   Except
    On E : Exception Do
     fSession.Fail(E.ClassName + ': ' + E.Message);
   End;
  End;

  Class Function TConPtySession.Supported : Boolean;

Begin
 Result := (GetProcAddress(GetModuleHandle('kernel32.dll'), 'CreatePseudoConsole') <> Nil) And (GetProcAddress(GetModuleHandle('kernel32.dll'), 'ResizePseudoConsole') <> Nil) And (GetProcAddress(GetModuleHandle('kernel32.dll'), 'ClosePseudoConsole') <> Nil);
End;

 Constructor TConPtySession.Create(Const Executable, Arguments, Directory : String; Columns, Rows : Integer; Environment : TStrings);
  Var
   InputRead        : THandle;
   OutputWrite      : THandle;
   Size             : TCoord;
   Start            : TExtendedStartup;
   Process          : TProcessInformation;
   AttrSize         : NativeUInt;
   Attr             : Pointer;
   Limits           : TJobObjectExtendedLimitInformation;
   Command          : String;
   Block            : String;
   CreateFn         : TCreatePseudoConsole;
   HR               : HRESULT;
   DirectoryPointer : PChar;
  Begin
   Inherited Create;
   fLock       := TCriticalSection.Create;
   fWake       := TEvent.Create(Nil, False, False, '');
   fReceived   := TMemoryStream.Create;
   fPending    := TMemoryStream.Create;
   InputRead   := 0;
   OutputWrite := 0;
   Attr        := Nil;
   FillChar(Process, SizeOf(Process), 0);
   If Not Supported Then
    Raise ENotSupportedException.Create('ConPTY requires Windows 10 version 1809 or later');
   If (Columns < 1) Or (Rows < 1) Or (Columns > 32767) Or (Rows > 32767) Then
    Raise EArgumentOutOfRangeException.Create('Invalid terminal size');
   If Not FileExists(Executable) Then
    Raise EFileNotFoundException.Create(Executable);
   If (Directory <> '') And Not DirectoryExists(Directory) Then
    Raise EDirectoryNotFoundException.Create(Directory);
   Try
    If Not CreatePipe(InputRead, fInput, Nil, 0) Then
     RaiseLastOSError;
    If Not CreatePipe(fOutput, OutputWrite, Nil, 0) Then
     RaiseLastOSError;
    Size.X   := Columns;
    Size.Y   := Rows;
    CreateFn := CreateApi();
    HR       := CreateFn(Size, InputRead, OutputWrite, 0, fPty);
    If Failed(HR) Then
     Raise EOSError.CreateFmt('CreatePseudoConsole failed: %.8x', [Cardinal(HR)]);
    CloseOwned(InputRead);
    CloseOwned(OutputWrite);
    // Drain ConPTY before starting the shell. Creation and shutdown can both emit VT output.
    fReader := TConPtyPump.Create(Self, True);
    fReader.Start;
    AttrSize := 0;
    InitAttributes(Attr, 1, 0, AttrSize);
    GetMem(Attr, AttrSize);
    If Not InitAttributes(Attr, 1, 0, AttrSize) Then
     RaiseLastOSError;
    Try
     If Not UpdateAttributes(Attr, 0, PseudoConsoleAttribute, Pointer(fPty), SizeOf(fPty), Nil, Nil) Then
      RaiseLastOSError;
     If (SizeOf(Start.Info) <> 104) Or (NativeUInt(@Start.Attributes) - NativeUInt(@Start) <> 104) Then
      Raise EInvalidOpException.CreateFmt('Invalid STARTUPINFOEX layout: base=%d total=%d offset=%d', [SizeOf(Start.Info), SizeOf(Start), NativeUInt(@Start.Attributes) - NativeUInt(@Start)]);
     FillChar(Start, SizeOf(Start), 0);
     Start.Info.cb := SizeOf(Start);
     // Suppress redirected parent std handles; the console initializes the pseudoconsole handles.
     Start.Info.dwFlags := STARTF_USESTDHANDLES;
     Start.Attributes   := Attr;
     Command            := QuoteProcessArgument(Executable);
     If Arguments <> '' Then
      Command := Command + ' ' + Arguments;
     UniqueString(Command);
     Block := EnvironmentBlock(Environment);
     fJob  := CreateJob(Nil, Nil);
     If fJob = 0 Then
      RaiseLastOSError;
     FillChar(Limits, SizeOf(Limits), 0);
     Limits.BasicLimitInformation.LimitFlags := JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
     If Not SetInformationJobObject(fJob, JobObjectExtendedLimitInformation, @Limits, SizeOf(Limits)) Then
      RaiseLastOSError;
     DirectoryPointer := Nil;
     If Directory <> '' Then
      DirectoryPointer := PChar(Directory);
     If Not StartProcess(PChar(Executable), PChar(Command), Nil, Nil, False,
     EXTENDED_STARTUPINFO_PRESENT Or CREATE_UNICODE_ENVIRONMENT Or CREATE_SUSPENDED,
     PChar(Block), DirectoryPointer, @Start, @Process) Then
      RaiseLastOSError;
     fProcess   := Process.hProcess;
     fProcessId := Process.dwProcessId;
     If Not AssignProcessToJobObject(fJob, fProcess) Then
      RaiseLastOSError;
     If ResumeThread(Process.hThread) = DWORD( -1) Then
      RaiseLastOSError;
    Finally
     DeleteAttributes(Attr);
    End;
    fWriter := TConPtyPump.Create(Self, False);
    fWriter.Start;
   Finally
    If Attr <> Nil Then
     FreeMem(Attr);
    CloseOwned(InputRead);
    CloseOwned(OutputWrite);
    CloseOwned(Process.hThread);
   End;
  End;

 Destructor TConPtySession.Destroy;
  Begin
   Stop;
   fPending.Free;
   fReceived.Free;
   fWake.Free;
   fLock.Free;
   Inherited;
  End;

 Procedure TConPtySession.Fail(Const Message : String);
  Begin
   fLock.Acquire;
   Try
    If Not fStopping And (fError = '') Then
     fError := Message;
   Finally
    fLock.Release;
   End;
  End;

 Function TConPtySession.GetError : String;
  Begin
   fLock.Acquire;
   Try
    Result := fError;
   Finally
    fLock.Release;
   End;
  End;

 Procedure TConPtySession.ReadLoop;
  Var
   Buffer   : Array[0..8191] Of Byte;
   Count    : Cardinal;
   Error    : Cardinal;
   Overflow : Boolean;
  Begin
   While ReadFile(fOutput, Buffer, SizeOf(Buffer), Count, Nil) And (Count > 0) Do
    Begin
     Overflow := False;
     fLock.Acquire;
     Try
      If Not fStopping Then
       Begin
        Overflow := fReceived.Size + Count > MaxBufferedOutput;
        If Not Overflow Then
         Begin
          fReceived.Position := fReceived.Size;
          fReceived.WriteBuffer(Buffer, Count);
         End;
       End;
     Finally
      fLock.Release;
     End;
     If Overflow Then
      Begin
       Fail('Terminal output queue exceeded 16 MiB');
       If fJob <> 0 Then
        TerminateJobObject(fJob, ERROR_BUFFER_OVERFLOW);
       // Keep draining until ConPTY closes; shutdown must never wait on a full output pipe.
      End;
    End;
   Error := GetLastError;
   If (Error <> ERROR_SUCCESS) And (Error <> ERROR_BROKEN_PIPE) And (Error <> ERROR_OPERATION_ABORTED) Then
    Fail(SysErrorMessage(Error));
  End;

 Procedure TConPtySession.WriteLoop;
  Var
   Bytes  : TBytes;
   Count  : Cardinal;
   Offset : Cardinal;
  Begin
   While True Do
    Begin
     fWake.WaitFor(INFINITE);
     fLock.Acquire;
     Try
      If fStopping Then
       Exit;
      SetLength(Bytes, fPending.Size);
      If Length(Bytes) > 0 Then
       Move(fPending.Memory^, Bytes[0], Length(Bytes));
      fPending.Clear;
     Finally
      fLock.Release;
     End;
     Offset := 0;
     While Offset < Cardinal(Length(Bytes)) Do
      Begin
       If Not WriteFile(fInput, Bytes[Offset], Min(Cardinal(4096), Cardinal(Length(Bytes)) - Offset), Count, Nil) Then
        Begin
         Fail(SysErrorMessage(GetLastError));
         Exit;
        End;
       If Count = 0 Then
        Exit;
       Inc(Offset, Count);
      End;
    End;
  End;

 Function TConPtySession.ReadAvailable : TBytes;
  Begin
   fLock.Acquire;
   Try
    SetLength(Result, fReceived.Size);
    If Length(Result) > 0 Then
     Move(fReceived.Memory^, Result[0], Length(Result));
    fReceived.Clear;
   Finally
    fLock.Release;
   End;
  End;

 Procedure TConPtySession.Send(Const Bytes : TBytes);
  Begin
   If Length(Bytes) = 0 Then
    Exit;
   fLock.Acquire;
   Try
    If fStopping Or Not Running Then
     Raise EInvalidOpException.Create('Terminal session has ended');
    If fPending.Size + Length(Bytes) > MaxBufferedInput Then
     Raise EInvalidOpException.Create('Terminal input queue exceeded 4 MiB');
    fPending.Position := fPending.Size;
    fPending.WriteBuffer(Bytes[0], Length(Bytes));
   Finally
    fLock.Release;
   End;
   fWake.SetEvent;
  End;

 Procedure TConPtySession.SendText(Const Text : String);
  Begin
   Send(TEncoding.UTF8.GetBytes(Text));
  End;

 Procedure TConPtySession.Resize(Columns, Rows : Integer);
  Var
   Fn   : TResizePseudoConsole;
   Size : TCoord;
   HR   : HRESULT;
  Begin
   If (Columns < 1) Or (Rows < 1) Or (Columns > 32767) Or (Rows > 32767) Then
    Raise EArgumentOutOfRangeException.Create('Invalid terminal size');
   If fPty = 0 Then
    Exit;
   Fn     := ResizeApi();
   Size.X := Columns;
   Size.Y := Rows;
   HR     := Fn(fPty, Size);
   If Failed(HR) Then
    Raise EOSError.CreateFmt('ResizePseudoConsole failed: %.8x', [Cardinal(HR)]);
  End;

 Procedure TConPtySession.CompleteOutput;
  Var
   Fn : TClosePseudoConsole;
  Begin
   If Running Then
    Raise EInvalidOpException.Create('The terminal process is still running');
   If fPty <> 0 Then
    Begin
     Fn := CloseApi();
     Fn(fPty);
     fPty := 0;
    End;
   If fReader <> Nil Then
    Begin
     fReader.WaitFor;
     FreeAndNil(fReader);
    End;
  End;

 Procedure TConPtySession.Stop;
  Var
   Fn : TClosePseudoConsole;
  Begin
   If fLock <> Nil Then
    Begin
     fLock.Acquire;
     Try
      fStopping := True;
     Finally
      fLock.Release;
     End;
    End;
   If fJob <> 0 Then
    TerminateJobObject(fJob, 0)
   Else If fProcess <> 0 Then
    TerminateProcess(fProcess, 0);
   If fWriter <> Nil Then
    Begin
     fWake.SetEvent;
     CancelSynchronousIo(fWriter.Handle);
    End;
   If fPty <> 0 Then
    Begin
     Fn := CloseApi();
     Fn(fPty);
     fPty := 0;
    End;
   If fWriter <> Nil Then
    Begin
     fWriter.WaitFor;
     FreeAndNil(fWriter);
    End;
   CloseOwned(fInput);
   If fReader <> Nil Then
    Begin
     CancelSynchronousIo(fReader.Handle);
     fReader.WaitFor;
     FreeAndNil(fReader);
    End;
   CloseOwned(fOutput);
   CloseOwned(fProcess);
   CloseOwned(fJob);
  End;

 Function TConPtySession.Running : Boolean;
  Begin
   Result := (fProcess <> 0) And (WaitForSingleObject(fProcess, 0) = WAIT_TIMEOUT);
  End;

 Function TConPtySession.ExitCode : Cardinal;
  Begin
   Result := 0;
   If fProcess <> 0 Then
    If Not GetExitCodeProcess(fProcess, Result) Then
     RaiseLastOSError;
  End;

End.
