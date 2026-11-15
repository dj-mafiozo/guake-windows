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
  End;

Implementation

 Uses
  Winapi.Windows, System.SysUtils, System.IOUtils, System.JSON,
  Guake.IPC, Guake.CommandLine, Guake.ConPTY, Guake.Shells;

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

Initialization
 TDUnitX.RegisterTestFixture(TGuakeIPCTests);

End.
