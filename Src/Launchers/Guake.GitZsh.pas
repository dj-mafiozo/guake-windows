{$StackFrames On}
/// <summary>Prepares the Git for Windows SDK environment and forwards Zsh arguments and exit status.</summary>
Unit Guake.GitZsh;

Interface
/// <summary>Runs mintty unless --nomintty was requested; --git-sdk-root selects the SDK installation.</summary>

 Function RunGitZsh : Integer;

Implementation

 Uses
  Winapi.Windows, System.SysUtils, System.IOUtils, Winapi.ShellAPI, Guake.Shells;

 Function ConsoleControl(Event : DWORD) : BOOL; Stdcall;
  Begin
   // The child shares the console and receives Ctrl+C itself. Keep its launcher alive to wait for it.
   Result := Event In [CTRL_C_EVENT, CTRL_BREAK_EVENT];
  End;

/// <summary>Uses Windows argument parsing so quoted shell scripts survive an extra launcher process.</summary>

 Function WindowsArguments : TArray<String>;
  Type
   TArguments = Array[0..65535] Of PWideChar;
   PArguments = ^TArguments;
  Var
   Values : PPWideChar;
   Count  : Integer;
   i      : Integer;
  Begin
   Values := CommandLineToArgvW(GetCommandLineW, Count);
   If Values = Nil Then
    RaiseLastOSError;
   Try
    SetLength(Result, Count);
    For i      := 0 To Count - 1 Do
     Result[i] := PArguments(Values)^[i];
   Finally
    LocalFree(HLOCAL(Values));
   End;
  End;

 Function RunGitZsh : Integer;
  Var
   Root             : String;
   Args             : String;
   Exe              : String;
   Command          : String;
   NoMintty         : Boolean;
   ForwardArguments : Boolean;
   Values           : TArray<String>;
   i                : Integer;
   Startup          : TStartupInfo;
   Process          : TProcessInformation;
   Code             : DWORD;
  Begin
   Values           := WindowsArguments;
   ForwardArguments := False;
   Root             := GetEnvironmentVariable('GIT_SDK_ROOT');
   NoMintty         := False;
   Args             := '';
   i                := 1;
   While i < Length(Values) Do
    Begin
     If Not ForwardArguments And (Values[i] = '--nomintty') Then
      NoMintty := True
     Else If Not ForwardArguments And (Values[i] = '--git-sdk-root') Then
      Begin
       Inc(i);
       If i >= Length(Values) Then
        Raise EArgumentException.Create('Missing --git-sdk-root directory');
       Root := Values[i];
      End
     Else
      Begin
       ForwardArguments := True;
       Args             := Args + ' ' + QuoteProcessArgument(Values[i]);
      End;
     Inc(i);
    End;
   If Root = '' Then
    Begin
     Root := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
     If Not TFile.Exists(TPath.Combine(Root, 'usr\bin\zsh.exe')) Then
      Root := 'C:\git-sdk-64';
    End;
   Root := ExpandFileName(Root);
   If Not TFile.Exists(TPath.Combine(Root, 'usr\bin\zsh.exe')) Then
    Raise EFileNotFoundException.Create('Git SDK Zsh not found: ' + Root);
   Win32Check(SetEnvironmentVariable('GIT_SDK_ROOT', PChar(Root)));
   Win32Check(SetEnvironmentVariable('MSYSTEM', 'MINGW64'));
   Win32Check(SetEnvironmentVariable('MSYS2_PATH_TYPE', 'inherit'));
   Win32Check(SetEnvironmentVariable('CHERE_INVOKING', '1'));
   Win32Check(SetEnvironmentVariable('TERM', 'xterm-256color'));
   Win32Check(SetEnvironmentVariable('COLORTERM', 'truecolor'));
   Win32Check(SetEnvironmentVariable('PATH', PChar(TPath.Combine(Root, 'mingw64\bin') + ';' +
   TPath.Combine(Root, 'usr\bin') + ';' + TPath.Combine(Root, 'cmd') + ';' + GetEnvironmentVariable('PATH'))));
   If GetEnvironmentVariable('HOME') = '' Then
    Win32Check(SetEnvironmentVariable('HOME', PChar(GetEnvironmentVariable('USERPROFILE'))));
   If Args = '' Then
    Args := ' --login -i';
   Exe   := TPath.Combine(Root, 'usr\bin\zsh.exe');
   If NoMintty Then
    Command := QuoteProcessArgument(Exe) + Args
   Else
    Begin
     Command := QuoteProcessArgument(TPath.Combine(Root, 'usr\bin\mintty.exe')) + ' -o Term=xterm-256color ' + QuoteProcessArgument(Exe) + Args;
    End;
   UniqueString(Command);
   FillChar(Startup, SizeOf(Startup), 0);
   Startup.cb := SizeOf(Startup);
   FillChar(Process, SizeOf(Process), 0);
   Win32Check(SetConsoleCtrlHandler(@ConsoleControl, True));
   Try
    // In --nomintty mode no console is allocated: stdin/stdout remain the caller's console or ConPTY.
    Win32Check(CreateProcess(Nil, PChar(Command), Nil, Nil, True, 0, Nil, Nil, Startup, Process));
    Try
     If Not NoMintty Then
      FreeConsole;
     Win32Check(WaitForSingleObject(Process.hProcess, INFINITE) = WAIT_OBJECT_0);
     Win32Check(GetExitCodeProcess(Process.hProcess, Code));
     Result := Integer(Code);
    Finally
     CloseHandle(Process.hThread);
     CloseHandle(Process.hProcess);
    End;
   Finally
    SetConsoleCtrlHandler(@ConsoleControl, False);
   End;
  End;

End.
