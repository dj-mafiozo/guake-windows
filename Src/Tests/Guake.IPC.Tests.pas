{$StackFrames On}
/// <summary>Exercises real user-restricted named pipes, shutdown cancellation and command-line forwarding.</summary>
Unit Guake.IPC.Tests;

Interface

 Uses
  DUnitX.TestFramework;

 Type

  [TestFixture]
  TGuakeIPCTests = Class
   Public
    [Test] Procedure SameUserTransportAndAnonymousDenial;
    [Test] Procedure IdleClientDoesNotBlockShutdown;
    [Test] Procedure CommandLineAndSecondaryProcess;
    [Test] Procedure ExitCommandStopsInstanceAndSavesConfiguredSession;
  End;

Implementation

 Uses
  Winapi.Windows, System.SysUtils, System.IOUtils, System.JSON,
  System.Classes, Guake.Settings, Guake.IPC, Guake.CommandLine, Guake.ConPTY, Guake.Shells;

 Function NativeImpersonateAnonymous(Thread : THandle) : BOOL; Stdcall; External 'advapi32.dll' name 'ImpersonateAnonymousToken';

 Procedure TGuakeIPCTests.SameUserTransportAndAnonymousDenial;
  Var
   Primary   : TGuakeInstance;
   Secondary : TGuakeInstance;
   Scope     : String;
   Command   : String;
   Received  : String;
   Handle    : THandle;
   Error     : DWORD;
   i         : Integer;
  Begin
   Scope   := TPath.GetRandomFileName;
   Primary := TGuakeInstance.Create(Scope);
   Try
    Secondary := TGuakeInstance.Create(Scope);
    Try
     Assert.IsTrue(Primary.IsPrimary);
     Assert.IsFalse(Secondary.IsPrimary);
     Assert.AreEqual(CurrentUserSID, Primary.UserSID);
     Command := '{"action":"execute","text":"echo żółć"}';
     Secondary.SendCommand(Command);
     Assert.IsTrue(Primary.TryReceive(Received));
     Assert.AreEqual(Command, Received);
     Assert.IsFalse(Primary.TryReceive(Received));
     Assert.WillRaise(Procedure Begin Secondary.SendCommand('not JSON'); End, EArgumentException);
     Assert.IsFalse(ValidIPCCommand('{"action":"unknown"}'));
     Win32Check(WaitNamedPipe(PChar(Primary.PipeName), 2000));
     Win32Check(NativeImpersonateAnonymous(GetCurrentThread));
     Try
      Handle := CreateFile(PChar(Primary.PipeName), GENERIC_READ Or GENERIC_WRITE, 0, Nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
      Error  := GetLastError;
      If Handle <> INVALID_HANDLE_VALUE Then
       CloseHandle(Handle);
     Finally
      Win32Check(RevertToSelf);
     End;
     Assert.AreEqual(NativeUInt(INVALID_HANDLE_VALUE), NativeUInt(Handle));
     Assert.AreEqual(DWORD(ERROR_ACCESS_DENIED), Error);
     For i := 1 To 64 Do
      Secondary.SendCommand('{"action":"show"}');
     Assert.WillRaise(TProc(Procedure Begin Secondary.SendCommand('{"action":"show"}'); End), EArgumentException);
     Assert.IsTrue(Primary.TryReceive(Received));
     Secondary.SendCommand('{"action":"hide"}');
    Finally
     Secondary.Free;
    End;
   Finally
    Primary.Free;
   End;
  End;

 Procedure TGuakeIPCTests.IdleClientDoesNotBlockShutdown;
  Var
   Primary : TGuakeInstance;
   Handle  : THandle;
   Started : UInt64;
  Begin
   Primary := TGuakeInstance.Create(TPath.GetRandomFileName);
   Handle  := INVALID_HANDLE_VALUE;
   Try
    Handle := CreateFile(PChar(Primary.PipeName), GENERIC_READ Or GENERIC_WRITE, 0, Nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
    Assert.IsTrue(Handle <> INVALID_HANDLE_VALUE);
    Sleep(30);
    Started := GetTickCount64;
    FreeAndNil(Primary);
    Assert.IsTrue(GetTickCount64 - Started < 2000, 'Pending pipe read delayed shutdown');
   Finally
    If Handle <> INVALID_HANDLE_VALUE Then
     CloseHandle(Handle);
    Primary.Free;
   End;
  End;

 Procedure TGuakeIPCTests.CommandLineAndSecondaryProcess;
  Var
   Options    : TGuakeLaunchOptions;
   JSON       : TJSONValue;
   Scope      : String;
   Received   : String;
   Executable : String;
   Primary    : TGuakeInstance;
   Process    : TConPtySession;
   Deadline   : UInt64;
  Begin
   Options := ParseGuakeArguments(TArray<String>.Create('--new-tab', 'C:\with spaces', '--shell', 'zsh',
   '--execute-command', 'printf "żółć x y"'));
   Assert.AreEqual(2, Integer(Length(Options.Commands)));
   JSON := TJSONObject.ParseJSONValue(Options.Commands[0]);
   Try
    Assert.AreEqual('new-tab', TJSONObject(JSON).GetValue('action').Value);
    Assert.AreEqual('zsh', TJSONObject(JSON).GetValue('shell').Value);
    Assert.AreEqual('C:\with spaces', TJSONObject(JSON).GetValue('directory').Value);
   Finally
    JSON.Free;
   End;
   JSON := TJSONObject.ParseJSONValue(Options.Commands[1]);
   Try
    Assert.AreEqual('printf "żółć x y"', TJSONObject(JSON).GetValue('text').Value);
   Finally
    JSON.Free;
   End;
   Assert.WillRaise(TProc(Procedure Var Dummy : TGuakeLaunchOptions; Begin Dummy := ParseGuakeArguments(TArray<String>.Create('--shell')); End), EArgumentException);
   Executable                                                                    := GetEnvironmentVariable('GUAKE_TEST_EXE');
   Assert.IsTrue(TFile.Exists(Executable), Executable);
   Scope   := TPath.GetRandomFileName;
   Primary := TGuakeInstance.Create(Scope);
   Try
    Process := TConPtySession.Create(Executable, '--instance ' + Scope + ' --execute-command ' +
    QuoteProcessArgument('printf "żółć x y"'), GetCurrentDir, 80, 25);
    Try
     Deadline := GetTickCount64 + 15000;
     Repeat
      Process.ReadAvailable;
      If Not Process.Running Then
       Break;
      Sleep(10);
     Until GetTickCount64 >= Deadline;
     Assert.IsFalse(Process.Running);
     Assert.AreEqual(Cardinal(0), Process.ExitCode);
     Assert.IsTrue(Primary.TryReceive(Received));
     JSON := TJSONObject.ParseJSONValue(Received);
     Try
      Assert.AreEqual('printf "żółć x y"', TJSONObject(JSON).GetValue('text').Value);
     Finally
      JSON.Free;
     End;
    Finally
     Process.Free;
    End;
   Finally
    Primary.Free;
   End;
  End;

 Procedure TGuakeIPCTests.ExitCommandStopsInstanceAndSavesConfiguredSession;
  Var
   Env         : TStringList;
   Settings    : TGuakeSettings;
   Process     : TConPtySession;
   Secondary   : TConPtySession;
   Client      : TGuakeInstance;
   Options     : TGuakeLaunchOptions;
   Directory   : String;
   Scope       : String;
   Executable  : String;
   Ready       : String;
   SessionFile : String;
   Deadline    : UInt64;
   Enabled     : Boolean;
   JSON        : TJSONValue;
  Begin
   Options := ParseGuakeArguments(TArray<String>.Create('--exit'));
   Assert.IsTrue(Options.Hidden And Options.ExitOnly);
   Assert.IsTrue(Pos('"exit"', Options.Commands[0]) > 0);
   Assert.IsTrue(Pos('--exit', GuakeCommandLineHelp) > 0);
   Executable  := GetEnvironmentVariable('GUAKE_TEST_EXE');
   For Enabled := False To True Do
    Begin
     Directory := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
     TDirectory.CreateDirectory(TPath.Combine(Directory, 'Guake'));
     Ready       := TPath.Combine(Directory, 'ready.txt');
     SessionFile := TPath.Combine(Directory, 'Guake\guake.session.json');
     Settings    := TGuakeSettings.Create(TPath.Combine(Directory, 'Guake\guake.ini'));
     Env         := TStringList.Create;
     Process     := Nil;
     Secondary   := Nil;
     Client      := Nil;
     Try
      Settings.General.DefaultShell         := 'cmd';
      Settings.General.UsePopup             := False;
      Settings.General.UseTrayicon          := False;
      Settings.General.StartAtLogin         := False;
      Settings.General.RestoreTabsStartup   := False;
      Settings.General.SaveTabsWhenChanged  := Enabled;
      Settings.General.PromptOnQuit         := True;
      Settings.General.PromptOnCloseTab     := 2;
      Settings.General.StartupScript        := 'echo ready>' + QuoteProcessArgument(Ready);
      Settings.Keybindings.Global.ShowHide  := 'disabled';
      Settings.Keybindings.Global.ShowFocus := 'disabled';
      Settings.Save;
      Env.Values['APPDATA'] := Directory;
      Scope                 := TPath.GetRandomFileName;
      Process               := TConPtySession.Create(Executable, '--instance ' + Scope + ' --exit', GetCurrentDir, 80, 25, Env);
      Deadline              := GetTickCount64 + 10000;
      While Process.Running And (GetTickCount64 < Deadline) Do
       Begin
        Process.ReadAvailable;
        Sleep(10);
       End;
      Assert.IsFalse(Process.Running);
      Assert.AreEqual(Cardinal(0), Process.ExitCode);
      Assert.IsFalse(TFile.Exists(Ready));
      Assert.IsFalse(TFile.Exists(SessionFile));
      FreeAndNil(Process);
      If Not Enabled Then
       TFile.WriteAllText(SessionFile, 'preserved', TEncoding.UTF8);
      Process  := TConPtySession.Create(Executable, '--instance ' + Scope + ' --hidden', GetCurrentDir, 80, 25, Env);
      Deadline := GetTickCount64 + 15000;
      While Not TFile.Exists(Ready) And Process.Running And (GetTickCount64 < Deadline) Do
       Begin
        Process.ReadAvailable;
        Sleep(10);
       End;
      Assert.IsTrue(TFile.Exists(Ready), 'Isolated instance must start');
      Client := TGuakeInstance.Create(Scope);
      Assert.IsFalse(Client.IsPrimary);
      Client.SendCommand('{"action":"new-tab"}');
      Secondary := TConPtySession.Create(Executable, '--instance ' + Scope + ' --exit', GetCurrentDir, 80, 25, Env);
      Deadline  := GetTickCount64 + 15000;
      While Process.Running And (GetTickCount64 < Deadline) Do
       Begin
        Process.ReadAvailable;
        Sleep(10);
       End;
      Assert.IsFalse(Process.Running, '--exit must stop even when close confirmation is enabled');
      Assert.AreEqual(Cardinal(0), Process.ExitCode);
      Deadline := GetTickCount64 + 10000;
      While Secondary.Running And (GetTickCount64 < Deadline) Do
       Begin
        Secondary.ReadAvailable;
        Sleep(10);
       End;
      Assert.IsFalse(Secondary.Running);
      Assert.AreEqual(Cardinal(0), Secondary.ExitCode);
      If Enabled Then
       Begin
        JSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(SessionFile, TEncoding.UTF8));
        Try
         Assert.IsTrue(JSON Is TJSONObject);
         Assert.AreEqual(2, TJSONArray(TJSONObject(JSON).GetValue('tabs')).Count);
        Finally
         JSON.Free;
        End;
       End
      Else
       Assert.AreEqual('preserved', TFile.ReadAllText(SessionFile, TEncoding.UTF8));
     Finally
      Secondary.Free;
      Client.Free;
      Process.Free;
      Env.Free;
      Settings.Free;
     End;
    End;
  End;

Initialization
 TDUnitX.RegisterTestFixture(TGuakeIPCTests);

End.
