Unit Guake.Logging;

Interface

 Uses
  System.SysUtils, System.SyncObjs;

 Type
  TGuakeLog = Class
   Private
    fFileName : String;
    fLock     : TCriticalSection;
   Public
    Constructor Create         (Const FileName : String);
    Destructor  Destroy; Override;
    Function    TryLogException(e : Exception; Const Context : String) : Boolean;
  End;

Implementation

 Uses
  Winapi.Windows, System.IOUtils, VersionU;

 Constructor TGuakeLog.Create(Const FileName : String);
  Begin
   Inherited Create;
   fFileName := ExpandFileName(FileName);
   fLock     := TCriticalSection.Create;
  End;

 Destructor TGuakeLog.Destroy;
  Begin
   fLock.Free;
   Inherited;
  End;

 Function TGuakeLog.TryLogException(e : Exception; Const Context : String) : Boolean;
  Var
   RecordText : String;
   Stack      : String;
   Version    : String;
   Info       : TWin32FileAttributeData;
  Begin
   Result := False;
   If e = Nil Then
    Exit;
   Try
    Stack := e.StackTrace;
    If Stack = '' Then
     Stack     := '(stack unavailable)';
    Version    := ExeVersionInfo.FileVersion;
    RecordText := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) +
    Format(' [pid=%d thread=%d version=%s] %s: %s: %s',
    [GetCurrentProcessId, GetCurrentThreadId, Version, Context, e.ClassName, e.Message]) +
    sLineBreak + Stack + sLineBreak + sLineBreak;
    fLock.Acquire;
    Try
     If Not ForceDirectories(ExtractFileDir(fFileName)) Then
      Raise EInOutError.Create('Cannot create log directory');
     If GetFileAttributesEx(PChar(fFileName), GetFileExInfoStandard, @Info) And ((Info.nFileSizeHigh > 0) Or (Info.nFileSizeLow >= 4 * 1024 * 1024)) Then
      Begin
       If TFile.Exists(fFileName + '.old') Then
        TFile.Delete(fFileName + '.old');
       TFile.Move(fFileName, fFileName + '.old');
      End;
     TFile.AppendAllText(fFileName, RecordText, TEncoding.UTF8);
     Result := True;
    Finally
     fLock.Release;
    End;
   Except
    OutputDebugString(PChar('Guake: unable to log exception: ' + e.ClassName + ': ' + e.Message));
   End;
  End;

End.
