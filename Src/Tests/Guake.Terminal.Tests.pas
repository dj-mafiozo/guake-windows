{$StackFrames On}
/// <summary>DUnitX verification of terminal tests.</summary>
Unit Guake.Terminal.Tests;
/// <summary>Exercises the actual ConPTY process lifecycle and independently verifies incremental VT behavior.</summary>

Interface

 Uses
  DUnitX.TestFramework;

 Type

  [TestFixture]
  TTerminalTests = Class
   Public
    [Test] Procedure IncrementalUnicodeAndCSI;
    [Test] Procedure AlternateScreenRestoresPrimary;
    [Test] Procedure ColorsCursorAndDeviceResponses;
    [Test] Procedure ScrollbackAndMargins;
    [Test] Procedure WideAndCombiningCells;
    [Test] Procedure ResizePreservesContent;
    [Test] Procedure CmdEnvironmentDirectoryAndExitCode;
    [Test] Procedure InteractivePowerShell;
    [Test] Procedure InteractiveBash;
    [Test] Procedure InteractiveZsh;
    [Test] Procedure ShutdownWithUndrainedOutput;
    [Test] Procedure FailedStartDoesNotLeakHandles;
    [Test] Procedure ControllerTabsSplitsAndFailure;
    [Test] Procedure WindowsAccelerators;
    [Test] Procedure MainWindowCreatesTerminalAndSplitFrames;
  End;

Implementation

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils,
  frmMainU, Vcl.Controls, Guake.ConPTY, Guake.VT, Guake.Shells, Guake.Sessions, Guake.Settings, Guake.Keybindings;

 Function WaitForText(Session : TConPtySession; Buffer : TTerminalBuffer; Const Value : String; Timeout : Cardinal = 15000) : Boolean;
  Var
   Deadline : UInt64;
   Response : String;
  Begin
   Deadline := GetTickCount64 + Timeout;
   Repeat
    Buffer.Feed(Session.ReadAvailable);
    Response := Buffer.TakeResponses;
    If (Response <> '') And Session.Running Then
     Session.SendText(Response);
    If Pos(Value, Buffer.Text) > 0 Then
     Exit(True);
    Sleep(10);
   Until GetTickCount64 >= Deadline;
   Result := False;
  End;

 Procedure TTerminalTests.IncrementalUnicodeAndCSI;
  Var
   Buffer : TTerminalBuffer;
   Bytes  : TBytes;
   One    : TBytes;
   b      : Byte;
  Begin
   Buffer := TTerminalBuffer.Create(80, 5);
   Try
    Bytes := TEncoding.UTF8.GetBytes('Zażółć 日本語 😀' + #27'[31mR' + #27'[0m');
    SetLength(One, 1);
    For b In Bytes Do
     Begin
      One[0] := b;
      Buffer.Feed(One);
     End;
    Assert.IsTrue(Pos('Zażółć 日本語 😀R', Buffer.Text) > 0, Buffer.Text);
    Assert.AreEqual(1, Buffer.Cell[16, 0].Foreground);
   Finally
    Buffer.Free;
   End;
  End;

 Procedure TTerminalTests.AlternateScreenRestoresPrimary;
  Var
   Buffer : TTerminalBuffer;
  Begin
   Buffer := TTerminalBuffer.Create(20, 4);
   Try
    Buffer.FeedText('primary' + #27'[?1049halternate');
    Assert.IsTrue(Buffer.AlternateScreen);
    Assert.IsTrue(Pos('alternate', Buffer.Text) > 0);
    Buffer.Resize(30, 6);
    Buffer.FeedText(#27'[?1049l');
    Assert.IsFalse(Buffer.AlternateScreen);
    Assert.AreEqual('primary', Buffer.LineText(0));
   Finally
    Buffer.Free;
   End;
  End;

 Procedure TTerminalTests.ColorsCursorAndDeviceResponses;
  Var
   Buffer : TTerminalBuffer;
  Begin
   Buffer := TTerminalBuffer.Create(40, 10);
   Try
    Buffer.FeedText(#27'[3;4H' + #27'[1;38;2;17;34;51;48;5;201mX' + #27'[6n' + #27'[?2004h');
    Assert.AreEqual($01332211, Buffer.Cell[3, 2].Foreground);
    Assert.AreEqual(201, Buffer.Cell[3, 2].Background);
    Assert.IsTrue(Buffer.Cell[3, 2].Bold);
    Assert.AreEqual(#27'[3;5R', Buffer.TakeResponses);
    Assert.IsTrue(Buffer.BracketedPaste);
    Buffer.FeedText(#27']2;Session title' + #27'\');
    Assert.AreEqual('Session title', Buffer.Title);
   Finally
    Buffer.Free;
   End;
  End;

 Procedure TTerminalTests.ScrollbackAndMargins;
  Var
   Buffer : TTerminalBuffer;
  Begin
   Buffer := TTerminalBuffer.Create(10, 3, 2);
   Try
    Buffer.FeedText('one'#13#10'two'#13#10'tre'#13#10'for');
    Assert.AreEqual(4, Buffer.TotalLines);
    Assert.AreEqual('one', Buffer.LineText(0));
    Buffer.FeedText(#27'[2;3r' + #27'[3;1H' + #13#10'five');
    Assert.AreEqual('one', Buffer.LineText(0));
    Assert.AreEqual('two', Buffer.LineText(1));
    Buffer.FeedText(#27'[3J');
    Assert.AreEqual(3, Buffer.TotalLines);
   Finally
    Buffer.Free;
   End;
  End;

 Procedure TTerminalTests.WideAndCombiningCells;
  Var
   Buffer : TTerminalBuffer;
  Begin
   Buffer := TTerminalBuffer.Create(10, 2);
   Try
    Buffer.FeedText('界e' + Char($0301) + 'X');
    Assert.IsTrue(Buffer.Cell[1, 0].Continuation);
    Assert.AreEqual('e' + Char($0301), Buffer.Cell[2, 0].Text);
    Assert.AreEqual(4, Buffer.CursorX);
   Finally
    Buffer.Free;
   End;
  End;

 Procedure TTerminalTests.ResizePreservesContent;
  Var
   Buffer : TTerminalBuffer;
  Begin
   Buffer := TTerminalBuffer.Create(10, 3);
   Try
    Buffer.FeedText('test');
    Buffer.Resize(20, 5);
    Assert.AreEqual('test', Buffer.LineText(0));
    Buffer.FeedText(#27'[2J');
    Assert.AreEqual('', Buffer.Text);
   Finally
    Buffer.Free;
   End;
  End;

 Procedure TTerminalTests.CmdEnvironmentDirectoryAndExitCode;
  Var
   Session  : TConPtySession;
   Profile  : TShellProfile;
   Buffer   : TTerminalBuffer;
   Env      : TStringList;
   Deadline : UInt64;
  Begin
   Assert.IsTrue(TConPtySession.Supported);
   Profile := TShellProfile.Resolve(gsCmd);
   Env     := TStringList.Create;
   Buffer  := TTerminalBuffer.Create(120, 30);
   Try
    Env.Values['GUAKE_CONPTY_TEST'] := 'native-conpty-ok';
    Session                         := TConPtySession.Create(Profile.Executable, '/D /Q /C "echo %GUAKE_CONPTY_TEST% & cd & exit /b 37"', GetCurrentDir, 120, 30, Env);
    Try
     Assert.IsTrue(WaitForText(Session, Buffer, 'native-conpty-ok'), Buffer.Text);
     Deadline := GetTickCount64 + 5000;
     While Session.Running And (GetTickCount64 < Deadline) Do
      Sleep(10);
     Assert.IsFalse(Session.Running);
     Assert.AreEqual(37, Integer(Session.ExitCode));
     Session.CompleteOutput;
     Buffer.Feed(Session.ReadAvailable);
     Assert.IsTrue(Pos(GetCurrentDir, Buffer.Text) > 0, Buffer.Text);
    Finally
     Session.Free;
    End;
   Finally
    Buffer.Free;
    Env.Free;
   End;
  End;

 Procedure TestInteractive(Kind : TGuakeShell; Const Command : String);
  Var
   Profile : TShellProfile;
   Session : TConPtySession;
   Buffer  : TTerminalBuffer;
  Begin
   Profile := TShellProfile.Resolve(Kind);
   Assert.IsTrue(Profile.Available, Profile.Executable);
   Case Kind Of
    gsBash       : Profile.Arguments := '--noprofile --norc -i';
    gsZsh        : Profile.Arguments := '-d -f -i';
    gsPowerShell : Profile.Arguments := '-NoLogo -NoProfile';
   End;
   Buffer := TTerminalBuffer.Create(120, 30, 2000);
   Try
    Session := TConPtySession.Create(Profile.Executable, Profile.Arguments, GetCurrentDir, 120, 30);
    Try
     Session.SendText(Command + #13);
     Assert.IsTrue(WaitForText(Session, Buffer, 'CONPTY-' + 'READY'), Buffer.Text);
     Session.Resize(100, 25);
     Session.SendText('exit' + #13);
    Finally
     Session.Free;
    End;
   Finally
    Buffer.Free;
   End;
  End;

 Procedure TTerminalTests.InteractivePowerShell;
  Begin
   TestInteractive(gsPowerShell, 'Write-Output (''CONPTY-'' + ''READY'')');
  End;

 Procedure TTerminalTests.InteractiveBash;
  Begin
   TestInteractive(gsBash, 'printf "CONPTY-%s\n" READY');
  End;

 Procedure TTerminalTests.InteractiveZsh;
  Begin
   TestInteractive(gsZsh, 'printf "CONPTY-%s\n" READY');
  End;

 Procedure TTerminalTests.ShutdownWithUndrainedOutput;
  Var
   Profile : TShellProfile;
   Session : TConPtySession;
   Started : UInt64;
  Begin
   Profile := TShellProfile.Resolve(gsCmd);
   Session := TConPtySession.Create(Profile.Executable, '/D /Q /C "for /L %i in (1,1,50000) do @echo terminal-output-%i"', GetCurrentDir, 80, 24);
   Sleep(100);
   Started := GetTickCount64;
   Session.Free;
   Assert.IsTrue(GetTickCount64 - Started < 5000, 'ConPTY teardown must drain pending output');
  End;

 Procedure TTerminalTests.FailedStartDoesNotLeakHandles;
  Var
   Before : Cardinal;
   After  : Cardinal;
   i      : Integer;
  Begin
   GetProcessHandleCount(GetCurrentProcess, Before);
   For i                                                                   := 1 To 10 Do
    Assert.WillRaise(Procedure Var Session : TConPtySession; Begin Session := TConPtySession.Create('C:\missing-guake-shell.exe', '', '', 80, 24); Session.Free; End, EFileNotFoundException);
   GetProcessHandleCount(GetCurrentProcess, After);
   Assert.IsTrue(After <= Before + 2, Format('Handles before=%d after=%d', [Before, After]));
  End;

 Procedure TTerminalTests.ControllerTabsSplitsAndFailure;
  Var
   Settings   : TGuakeSettings;
   Controller : TTerminalController;
   FirstId    : String;
  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Settings.General.DefaultShell := 'cmd';
    Controller                    := TTerminalController.Create(Settings);
    Try
     Controller.NewTab;
     FirstId := Controller.ActiveTab.Id;
     Controller.Split(True);
     Assert.AreEqual(2, Integer(Length(Controller.Sessions())));
     Controller.CloseTerminal;
     Assert.AreEqual(1, Integer(Length(Controller.Sessions())));
     Controller.NewTab;
     Assert.AreEqual(2, Controller.Count);
     Controller.MoveTab(0, 1);
     Assert.AreEqual(FirstId, Controller.Tabs[1].Id);
     Try
      Controller.NewTab('', 'C:\missing-guake-shell.exe');
      Assert.Fail('Missing shell was accepted');
     Except
      On E : EFileNotFoundException Do
       Assert.AreEqual(2, Controller.Count);
     End;
     Assert.AreEqual(2, Controller.Count);
     Controller.CloseTab(0);
     Controller.CloseTab(0);
     Assert.AreEqual(0, Controller.Count);
    Finally
     Controller.Free;
    End;
   Finally
    Settings.Free;
   End;
  End;

 Procedure TTerminalTests.WindowsAccelerators;
  Var
   Key       : Word;
   Modifiers : Cardinal;
  Begin
   Assert.IsTrue(ParseAccelerator('<Control><Shift>t', Key, Modifiers));
   Assert.AreEqual(Ord('T'), Integer(Key));
   Assert.AreEqual(Integer(MOD_CONTROL Or MOD_SHIFT), Integer(Modifiers));
   Assert.IsFalse(ParseAccelerator('disabled', Key, Modifiers));
   Assert.IsTrue(MatchAccelerator('<Control>Page_Down', VK_NEXT, [ssCtrl]));
  End;

/// <summary>Loads DFM-backed terminal views and verifies their lifecycle with real CMD sessions.</summary>

 Procedure TTerminalTests.MainWindowCreatesTerminalAndSplitFrames;
  Var
   Settings : TGuakeSettings;
   Main     : TfrmMain;
  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Settings.General.DefaultShell         := 'cmd';
    Settings.General.UseTrayicon          := False;
    Settings.Keybindings.Global.ShowHide  := 'disabled';
    Settings.Keybindings.Global.ShowFocus := 'disabled';
    Main                                  := TfrmMain.Create(Nil);
    Try
     Main.Bind(Settings);
     Main.StartTerminal;
     Assert.AreEqual(1, Main.Controller.Count);
     Assert.AreEqual(1, Main.terminalHost.ControlCount);
     Main.Controller.Split(True);
     Assert.AreEqual(2, Integer(Length(Main.Controller.Sessions())));
     Assert.AreEqual(1, Main.terminalHost.ControlCount);
     Main.Controller.CloseTerminal;
     Assert.AreEqual(1, Integer(Length(Main.Controller.Sessions())));
     Main.StopTerminal;
     Main.StopTerminal;
     Assert.AreEqual(0, Main.terminalHost.ControlCount);
    Finally
     Main.Free;
    End;
   Finally
    Settings.Free;
   End;
  End;

Initialization
 TDUnitX.RegisterTestFixture(TTerminalTests);

End.
