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
    [Test] Procedure ExtendedGraphemesAcrossByteFragments;
    [Test] Procedure ReflowPreservesHistoryStylesAndCursor;
    [Test] Procedure HyperlinksSearchAndDirectionalPanes;
    [Test] Procedure SessionTreeRoundTripAndFailedRestore;
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
    [Test] Procedure DefaultColorsAfterPromptReset;
    [Test] Procedure ZshUsesTerminalCapabilities;
    [Test] Procedure IdleTerminalDoesNotRepaint;
    [Test] Procedure ReferenceMenusAndTabChooser;
    [Test] Procedure BackgroundImageLayoutsAndRemoval;
    [Test] Procedure MainWindowCreatesTerminalAndSplitFrames;
    [Test] Procedure OccupiedGlobalShortcutDoesNotStopTerminal;
    [Test] Procedure FullscreenScrollOpacityAndMouseSelection;
    [Test] Procedure GitZshEnvironmentAndExitStatus;
    [Test] Procedure DropDownAnimationReversesAndKeepsTerminalSize;
  End;

Implementation

 Uses
  Guake.Unicode, Guake.Links, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.IOUtils,
  frmMainU, fraTerminalU, Vcl.Graphics, Vcl.Imaging.pngimage, Vcl.ComCtrls, Vcl.Controls, Guake.ConPTY, Guake.VT, Guake.Shells, Guake.Sessions, Guake.Settings, Guake.Keybindings;

 Type
  TTabControlAccess = Class(TTabControl)
  End;

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
    gsZsh        : Profile.Arguments := '--nomintty -d -f -i';
    gsPowerShell : Profile.Arguments := '-NoLogo -NoProfile -NoExit -Command "Set-PSReadLineOption -HistorySaveStyle SaveNothing"';
   End;
   Buffer := TTerminalBuffer.Create(120, 30, 2000);
   Try
    Session := TConPtySession.Create(Profile.Executable, Profile.Arguments, GetCurrentDir, 120, 30);
    Try
     // Wait until PSReadLine has initialized before sending the command.
     If Kind = gsPowerShell Then
      Assert.IsTrue(WaitForText(Session, Buffer, 'PS ' + GetCurrentDir + '>', 60000), Buffer.Text);
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
   // Initialize lazy exception symbol infrastructure before measuring repeated failed starts.
   Assert.WillRaise(Procedure Var Session : TConPtySession; Begin Session := TConPtySession.Create('C:\missing-guake-shell.exe', '', '', 80, 24); Session.Free; End, EFileNotFoundException);
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
   Assert.IsTrue(ParseAccelerator('`', Key, Modifiers));
   Assert.AreEqual(Integer(VK_OEM_3), Integer(Key));
   Assert.AreEqual(0, Integer(Modifiers));
   Assert.IsTrue(ParseAccelerator('~', Key, Modifiers));
   Assert.AreEqual(Integer(VK_OEM_3), Integer(Key));
   Assert.AreEqual(Integer(MOD_SHIFT), Integer(Modifiers));
   Assert.IsTrue(MatchAccelerator('<Control>grave', VK_OEM_3, [ssCtrl]));
   Assert.IsTrue(MatchAccelerator('<Alt>asciitilde', VK_OEM_3, [ssAlt, ssShift]));
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
     Assert.IsTrue(Assigned(TTabControlAccess(Main.tabBar).OnDblClick));
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

/// <summary>Reserves an actual Windows hotkey, checks partial registration and retries after releasing the conflict.</summary>

 Procedure TTerminalTests.OccupiedGlobalShortcutDoesNotStopTerminal;
  Const
   OccupiedId = $B110;
   ProbeId    = $B111;
   Modifiers  = MOD_CONTROL Or MOD_ALT Or MOD_SHIFT;
  Var
   Settings : TGuakeSettings;
   Main     : TfrmMain;
  Begin
   Assert.IsTrue(RegisterHotKey(0, OccupiedId, Modifiers, VK_F24), 'Cannot reserve the test hotkey');
   Try
    Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
    Try
     Settings.General.DefaultShell         := 'cmd';
     Settings.General.UseTrayicon          := False;
     Settings.Keybindings.Global.ShowHide  := '<Control><Alt><Shift>F24';
     Settings.Keybindings.Global.ShowFocus := '<Control><Alt><Shift>F23';
     Main                                  := TfrmMain.Create(Nil);
     Try
      Main.Bind(Settings);
      Main.StartTerminal;
      Assert.AreEqual(1, Main.Controller.Count);
      Assert.IsTrue(Main.pollTimer.Enabled);
      Assert.IsTrue(Pos('1409', Main.HotkeyErrors) > 0, Main.HotkeyErrors);
      Assert.IsTrue(Pos('F24', Main.trayIcon.Hint) > 0, Main.trayIcon.Hint);
      Assert.IsFalse(RegisterHotKey(0, ProbeId, Modifiers, VK_F23), 'The other shortcut was not registered');
      Main.StopTerminal;
      UnregisterHotKey(0, OccupiedId);
      Main.StartTerminal;
      Assert.AreEqual('', Main.HotkeyErrors);
      Assert.AreEqual('Guake Terminal', Main.trayIcon.Hint);
      Main.StopTerminal;
      Assert.IsTrue(RegisterHotKey(0, ProbeId, Modifiers, VK_F24), 'Shortcut was not released');
     Finally
      UnregisterHotKey(0, ProbeId);
      Main.Free;
     End;
    Finally
     Settings.Free;
    End;
   Finally
    UnregisterHotKey(0, OccupiedId);
   End;
  End;

/// <summary>SGR with no arguments and explicit default colors must end the colored prompt.</summary>

 Procedure TTerminalTests.DefaultColorsAfterPromptReset;
  Var
   Buffer : TTerminalBuffer;
  Begin
   Buffer := TTerminalBuffer.Create(40, 3);
   Try
    Buffer.FeedText(#27'[32mGREEN' + #27'[m% white');
    Assert.AreEqual(2, Buffer.Cell[0, 0].Foreground);
    Assert.AreEqual( -1, Buffer.Cell[5, 0].Foreground);
    Assert.AreEqual( -2, Buffer.Cell[5, 0].Background);
    Buffer.FeedText(#27'[32;41mX' + #27'[39;49mY');
    Assert.AreEqual( -1, Buffer.Cell[13, 0].Foreground);
    Assert.AreEqual( -2, Buffer.Cell[13, 0].Background);
   Finally
    Buffer.Free;
   End;
  End;

/// <summary>Unix shells receive terminal capabilities even when the parent process uses TERM=dumb.</summary>

 Procedure TTerminalTests.ZshUsesTerminalCapabilities;
  Var
   Settings : TGuakeSettings;
   Profile  : TShellProfile;
   Session  : TTerminalSession;
   Deadline : UInt64;
   x        : Integer;
   y        : Integer;
   Fore     : Integer;
   Back     : Integer;
  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Profile           := TShellProfile.Resolve(gsZsh);
    Profile.Arguments := '--nomintty -d -f -c ' + QuoteProcessArgument('printf "%s:%s " "$TERM" "$COLORTERM"; print -n -P ''%F{green}USER%f %% WHITE''');
    Session           := TTerminalSession.Create(Profile, GetCurrentDir, Settings);
    Try
     Deadline := GetTickCount64 + 15000;
     Repeat
      Session.Poll;
      If Session.Exited Then
       Break;
      Sleep(10);
     Until GetTickCount64 >= Deadline;
     Assert.IsTrue(Session.Exited);
     Assert.IsTrue(Pos('xterm-256color:truecolor', Session.Buffer.Text) > 0, Session.Buffer.Text);
     Assert.IsTrue(Pos('% WHITE', Session.Buffer.Text) > 0, Session.Buffer.Text);
     For y  := 0 To Session.Buffer.TotalLines - 1 Do
      For x := 0 To Session.Buffer.Columns - 1 Do
       If (Session.Buffer.Cell[x, y].Text = '%') Or (Session.Buffer.Cell[x, y].Text = 'W') Then
        Begin
         Fore := Session.Buffer.Cell[x, y].Foreground;
         Back := Session.Buffer.Cell[x, y].Background;
         Assert.IsTrue((Fore = -1) Or (Fore = 7) Or (Fore = 15), 'Prompt reset did not restore white text');
         Assert.IsTrue((Back = -2) Or (Back = 0), 'Prompt reset did not restore black background');
        End;

    Finally
     Session.Free;
    End;
   Finally
    Settings.Free;
   End;
  End;

/// <summary>Idle refreshes do not invalidate the view; exports an offscreen terminal and tab-strip preview.</summary>

 Procedure TTerminalTests.IdleTerminalDoesNotRepaint;
  Var
   Settings : TGuakeSettings;
   Main     : TfrmMain;
   Frame    : TfraTerminal;
   Bitmap   : TBitmap;
   Image    : TPngImage;
   Output   : String;
  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Settings.General.DefaultShell         := 'cmd';
    Settings.General.UseTrayicon          := False;
    Settings.General.WindowTabbar         := True;
    Settings.General.HideTabsIfOneTab     := False;
    Settings.Keybindings.Global.ShowHide  := 'disabled';
    Settings.Keybindings.Global.ShowFocus := 'disabled';
    Settings.Style.CursorBlinkMode        := 2;
    Main                                  := TfrmMain.Create(Nil);
    Try
     Main.Bind(Settings);
     Main.StartTerminal;
     Main.SetBounds(0, 0, 1000, 500);
     Main.tabHost.HandleNeeded;
     Main.tabBar.HandleNeeded;
     Frame := Main.ActiveTerminalFrame;
     Frame.HandleNeeded;
     Frame.Session.Buffer.FeedText(#27'[2J' + #27'[H' + #27'[32mUSER' + #27'[m % white on black');
     Frame.RefreshTick(Nil);
     ValidateRect(Frame.Handle, Nil);
     Frame.RefreshTick(Nil);
     Assert.IsFalse(GetUpdateRect(Frame.Handle, Nil, False), 'Idle timer invalidated the terminal');
     Assert.AreEqual(Integer(clBtnFace), Integer(Main.tabHost.Color));
     Bitmap := TBitmap.Create;
     Image  := TPngImage.Create;
     Try
      Bitmap.PixelFormat := pf24bit;
      Bitmap.SetSize(Main.Width, Main.Height);
      Main.PaintTo(Bitmap.Canvas.Handle, 0, 0);
      Assert.IsTrue(Main.tabHost.Visible);
      // Hidden native child windows need an explicit paint in an offscreen preview.
      Main.tabHost.PaintTo(Bitmap.Canvas.Handle, Main.tabHost.Left, Main.tabHost.Top);
      Image.Assign(Bitmap);
      Output := TPath.Combine(ExtractFilePath(ParamStr(0)), 'terminal-preview.png');
      Image.SaveToFile(Output);
     Finally
      Image.Free;
      Bitmap.Free;
     End;
    Finally
     Main.Free;
    End;
   Finally
    Settings.Free;
   End;
  End;

/// <summary>Chooses tabs by stable identity and checks the source terminal and tab context menus.</summary>

 Procedure TTerminalTests.ReferenceMenusAndTabChooser;
  Var
   Settings : TGuakeSettings;
   Main     : TfrmMain;
   Handled  : Boolean;
   Msg      : TMsg;
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
     Assert.IsTrue(Main.tabHost.PopupMenu = Main.tabMenu);
     Assert.IsTrue(Main.tabBar.PopupMenu = Main.tabMenu);
     Assert.IsTrue(Main.btnAddTab.PopupMenu = Main.shellMenu);
     Assert.AreEqual(4, Main.shellMenu.Items.Count);
     Assert.AreEqual(Integer(tsFlatButtons), Integer(Main.tabBar.Style));

     Assert.IsTrue(Main.btnAddTab.Enabled);
     Assert.IsFalse(Main.btnAddTab.Glyph.Empty);
     Assert.IsTrue(Main.btnTabList.Enabled);
     Assert.IsTrue(Main.miTrayNewTab.Enabled);
     Settings.General.DefaultShell := 'powershell';
     Main.miPopupCmd.Click;
     Assert.AreEqual(Integer(gsCmd), Integer(Main.Controller.ActiveSession.Profile.Kind));
     Main.Controller.CloseTab(Main.Controller.ActiveIndex);
     Settings.General.DefaultShell  := 'cmd';
     Main.Controller.ActiveTab.Name := 'one';
     Main.AddTabClick(Nil);
     Main.Controller.ActiveTab.Name := 'two';
     Main.TabListPopup(Nil);
     Assert.AreEqual(2, Main.tabListMenu.Items.Count);
     Assert.IsTrue(Main.tabListMenu.Items[1].Checked);
     Main.tabListMenu.Items[0].Click;
     Assert.AreEqual(0, Main.Controller.ActiveIndex);
     Main.TerminalMenuPopup(Nil);
     Assert.IsTrue(Main.miSaveTerminal.Parent = Main.terminalMenu.Items);
     Assert.AreEqual(5, Main.tabMenu.Items.Count);
     Assert.IsTrue(Main.miResetTerminal.Enabled);
     Assert.AreEqual(4, Main.miNewShellTab.Count);
     Main.miNewCmd.Click;
     Assert.AreEqual(3, Main.Controller.Count);
     Assert.AreEqual(Integer(gsCmd), Integer(Main.Controller.ActiveSession.Profile.Kind));
     Settings.Keybindings.Local.NewTabCmd := '<Control><Alt>F23';
     Handled                              := False;
     Main.ActiveTerminalFrame.OnShortcut(Main.ActiveTerminalFrame, VK_F23, [ssCtrl, ssAlt], Handled);
     Assert.IsTrue(Handled);
     Assert.IsTrue(PeekMessage(Msg, Main.Handle, WM_APP, $BFFF, PM_REMOVE));
     DispatchMessage(Msg);
     Assert.AreEqual(4, Main.Controller.Count);
     Assert.AreEqual(Integer(gsCmd), Integer(Main.Controller.ActiveSession.Profile.Kind));
     Assert.IsFalse(Main.miQuickOpen.Enabled);
     Assert.IsFalse(Main.miSaveTabs.Enabled);
    Finally
     Main.Free;
    End;
   Finally
    Settings.Free;
   End;
  End;

/// <summary>Renders a known two-color image in every layout and verifies removal and failure fallback.</summary>

 Procedure TTerminalTests.BackgroundImageLayoutsAndRemoval;
  Var
   Settings : TGuakeSettings;
   Main     : TfrmMain;
   Frame    : TfraTerminal;
   Source   : TBitmap;
   Target   : TBitmap;
   FileName : String;
   Mode     : Integer;
  Begin
   FileName := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName + '.bmp');
   Source   := TBitmap.Create;
   Target   := TBitmap.Create;
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Source.PixelFormat := pf24bit;
    Source.SetSize(2, 1);
    Source.Canvas.Pixels[0, 0] := clRed;
    Source.Canvas.Pixels[1, 0] := clBlue;
    Source.SaveToFile(FileName);
    Target.PixelFormat := pf24bit;
    Target.SetSize(10, 10);
    Settings.General.BackgroundImageFile := FileName;
    Main                                 := TfrmMain.Create(Nil);
    Try
     Frame        := TfraTerminal.Create(Main.terminalHost);
     Frame.Parent := Main.terminalHost;
     For Mode     := 0 To 3 Do
      Begin
       Settings.General.BackgroundImageLayoutMode := Mode;
       Frame.Bind(Nil, Settings);
       Frame.DrawBackground(Target.Canvas, Rect(0, 0, 10, 10));
       Case Mode Of
        0 :
         Begin
          Assert.AreEqual(Integer(clRed), Integer(Target.Canvas.Pixels[0, 0]));
          Assert.AreEqual(Integer(clRed), Integer(Target.Canvas.Pixels[0, 3]));
         End;
        1 :
         Begin
          Assert.AreEqual(Integer(clRed), Integer(Target.Canvas.Pixels[0, 8]));
          Assert.AreEqual(Integer(clBlue), Integer(Target.Canvas.Pixels[1, 8]));
         End;
        2 :
         Begin
          Assert.AreEqual(Integer(clBlack), Integer(Target.Canvas.Pixels[0, 0]));
          Assert.AreEqual(Integer(clRed), Integer(Target.Canvas.Pixels[4, 4]));
          Assert.AreEqual(Integer(clBlue), Integer(Target.Canvas.Pixels[5, 4]));
         End;
        3 :
         Begin
          Assert.AreEqual(Integer(clRed), Integer(Target.Canvas.Pixels[0, 0]));
          Assert.AreEqual(Integer(clBlue), Integer(Target.Canvas.Pixels[9, 9]));
         End;
       End;
      End;
     Settings.General.BackgroundImageFile := '';
     Frame.ApplySettings;
     Frame.DrawBackground(Target.Canvas, Rect(0, 0, 10, 10));
     Assert.AreEqual(Integer(clBlack), Integer(Target.Canvas.Pixels[4, 4]));
     Settings.General.BackgroundImageFile := FileName + '.missing';
     Frame.ApplySettings;
     Frame.DrawBackground(Target.Canvas, Rect(0, 0, 10, 10));
     Assert.AreEqual(Integer(clBlack), Integer(Target.Canvas.Pixels[4, 4]));
    Finally
     Main.Free;
    End;
   Finally
    Settings.Free;
    Target.Free;
    Source.Free;
    TFile.Delete(FileName);
   End;
  End;

/// <summary>Exercises shrinking below a previous scrollbar page, fullscreen cycles and click versus drag.</summary>

 Procedure TTerminalTests.FullscreenScrollOpacityAndMouseSelection;
  Var
   Settings : TGuakeSettings;
   Main     : TfrmMain;
   Frame    : TfraTerminal;
   i        : Integer;
   Key      : COLORREF;
   Alpha    : Byte;
   Flags    : DWORD;
  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Settings.General.DefaultShell          := 'cmd';
    Settings.General.UseTrayicon           := False;
    Settings.Keybindings.Global.ShowHide   := 'disabled';
    Settings.Keybindings.Global.ShowFocus  := 'disabled';
    Settings.Style.Background.Transparency := 73;
    Main                                   := TfrmMain.Create(Nil);
    Try
     Main.Bind(Settings);
     Main.HandleNeeded;
     Main.StartTerminal;
     Frame := Main.ActiveTerminalFrame;
     Frame.HandleNeeded;
     For i := 1 To 15 Do
      Begin
       Main.SetFullScreen(True);
       Frame.RefreshTick(Nil);
       Main.SetFullScreen(False);
       Main.SetBounds(0, 0, 700, 120);
       Frame.FrameResize(Nil);
       Frame.RefreshTick(Nil);
       Assert.IsTrue(Frame.scroll.PageSize <= Frame.scroll.Max);
       Assert.IsTrue(GetLayeredWindowAttributes(Main.Handle, Key, Alpha, Flags));
       Assert.AreEqual(MulDiv(73, 255, 100), Integer(Alpha));
       Assert.AreEqual(Integer(LWA_ALPHA), Integer(Flags));
      End;
     Settings.General.WindowOntop := Not Settings.General.WindowOntop;
     Main.ApplySettings;
     Assert.IsTrue(GetLayeredWindowAttributes(Main.Handle, Key, Alpha, Flags));
     Assert.AreEqual(MulDiv(73, 255, 100), Integer(Alpha));
     Main.Show;
     Main.SetBounds( -30000, 0, 700, 120);
     Frame.Session.Buffer.FeedText(#27'[2J' + #27'[H' + 'selection');
     Frame.RefreshTick(Nil);
     Frame.SurfaceMouseDown(Nil, mbLeft, [], 5, 5);
     Frame.SurfaceMouseUp(Nil, mbLeft, [], 5, 5);
     Assert.AreEqual('', Frame.SelectedText);
     Frame.SurfaceMouseDown(Nil, mbLeft, [], 5, 5);
     Frame.SurfaceMouseMove(Nil, [ssLeft], 6, 5);
     Assert.AreEqual('', Frame.SelectedText);
     Frame.SurfaceMouseMove(Nil, [ssLeft], 45, 5);
     Frame.SurfaceMouseUp(Nil, mbLeft, [], 45, 5);
     Assert.IsTrue(Length(Frame.SelectedText) > 1, Frame.SelectedText);
    Finally
     Main.Free;
    End;
   Finally
    Settings.Free;
   End;
  End;

/// <summary>Runs the packaged launcher under ConPTY, verifies Git environment and child exit code propagation.</summary>

 Procedure TTerminalTests.GitZshEnvironmentAndExitStatus;
  Var
   Profile  : TShellProfile;
   Session  : TConPtySession;
   Buffer   : TTerminalBuffer;
   Deadline : UInt64;
  Begin
   Profile := TShellProfile.Resolve(gsZsh);
   Assert.IsTrue(SameText(ExtractFileName(Profile.Executable), 'git-zsh.exe'));
   Buffer := TTerminalBuffer.Create(120, 30);
   Try
    Session := TConPtySession.Create(Profile.Executable,
    '--nomintty --git-sdk-root "C:\git-sdk-64" -d -f -c ' + QuoteProcessArgument(
    'printf "SDK=%s TERM=%s HOME=%s\n" "$MSYSTEM" "$TERM" "$HOME"; command -v git; exit 37'), GetCurrentDir, 120, 30);
    Try
     Deadline := GetTickCount64 + 15000;
     Repeat
      Buffer.Feed(Session.ReadAvailable);
      If Not Session.Running Then
       Break;
      Sleep(10);
     Until GetTickCount64 >= Deadline;
     Assert.IsFalse(Session.Running);
     Session.CompleteOutput;
     Buffer.Feed(Session.ReadAvailable);
     Assert.IsTrue(Pos('SDK=MINGW64 TERM=xterm-256color HOME=', Buffer.Text) > 0, Buffer.Text);
     Assert.IsTrue(Pos('/git', Buffer.Text) > 0, Buffer.Text);
     Assert.AreEqual(Cardinal(37), Session.ExitCode);
    Finally
     Session.Free;
    End;
   Finally
    Buffer.Free;
   End;
  End;

/// <summary>Exercises both screen edges, reversing, immediate mode and persistent animation settings.</summary>

 Procedure TTerminalTests.DropDownAnimationReversesAndKeepsTerminalSize;
  Var
   Settings : TGuakeSettings;
   Main     : TfrmMain;
   Edge     : Integer;
   Rows     : Integer;
   Bounds   : TRect;
  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Settings.General.DefaultShell              := 'cmd';
    Settings.General.UseTrayicon               := False;
    Settings.Keybindings.Global.ShowHide       := 'disabled';
    Settings.Keybindings.Global.ShowFocus      := 'disabled';
    Settings.General.DropDownAnimation         := True;
    Settings.General.DropDownAnimationDuration := 40;
    Settings.Save;
    Settings.Reload;
    Assert.IsTrue(Settings.General.DropDownAnimation);
    Assert.AreEqual(40, Settings.General.DropDownAnimationDuration);
    Main := TfrmMain.Create(Nil);
    Try
     Main.Bind(Settings);
     Main.StartTerminal;
     For Edge := 0 To 1 Do
      Begin
       Settings.General.WindowValignment := Edge;
       Main.ApplySettings;
       Bounds := Main.BoundsRect;
       Rows   := Main.ActiveTerminalFrame.Session.Buffer.Rows;
       Main.SetTerminalVisible(True);
       Sleep(15);
       Main.AnimationTick(Nil);
       Assert.AreEqual(Rows, Main.ActiveTerminalFrame.Session.Buffer.Rows);
       Main.ToggleVisibility;
       Sleep(60);
       Main.AnimationTick(Nil);
       Assert.IsFalse(Main.Visible);
       Assert.IsFalse(Main.animationTimer.Enabled);
       Assert.AreEqual(Bounds.Top, Main.Top);
       Main.SetTerminalVisible(True);
       Sleep(60);
       Main.AnimationTick(Nil);
       Assert.IsTrue(Main.Visible);
       Assert.AreEqual(Bounds.Top, Main.Top);
       Main.SetTerminalVisible(False);
       Sleep(60);
       Main.AnimationTick(Nil);
      End;
     Settings.General.DropDownAnimation := False;
     Main.SetTerminalVisible(True);
     Assert.IsTrue(Main.Visible);
     Assert.IsFalse(Main.animationTimer.Enabled);
     Main.SetTerminalVisible(False);
     Assert.IsFalse(Main.Visible);
    Finally
     Main.Free;
    End;
   Finally
    Settings.Free;
   End;
  End;

/// <summary>Verifies URL boundaries, search encoding, OSC 8 across feeds and directional navigation of nested splits.</summary>

 Procedure TTerminalTests.HyperlinksSearchAndDirectionalPanes;
  Var
   Buffer     : TTerminalBuffer;
   Settings   : TGuakeSettings;
   Controller : TTerminalController;
   LeftPane   : TTerminalSession;
   RightPane  : TTerminalSession;
   BottomPane : TTerminalSession;
   URI        : String;
  Begin
   Assert.AreEqual('https://example.org/a', TerminalLinkAt('go https://example.org/a). end', 12));
   Assert.AreEqual('', TerminalLinkAt('go https://example.org/a). end', 26));
   Assert.AreEqual('', NormalizeTerminalLink('javascript:alert(1)'));
   URI := WebSearchAddress('a & b/ż', 5, 'https://example.org/?q=%s');
   Assert.IsTrue(Pos('a+%26+b%2F', URI) > 0, URI);
   Buffer := TTerminalBuffer.Create(80, 5);
   Try
    Buffer.FeedText(#27']8;id=one;https://example.org/' + #27);
    Buffer.FeedText('\' + 'click' + #27'[31m' + 'x' + #27']8;;' + #7 + 'plain');
    Assert.AreEqual('https://example.org/', Buffer.Cell[0, 0].Hyperlink);
    Assert.AreEqual('https://example.org/', Buffer.Cell[5, 0].Hyperlink);
    Assert.AreEqual('', Buffer.Cell[6, 0].Hyperlink);
   Finally
    Buffer.Free;
   End;
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Settings.General.DefaultShell := 'cmd';
    Controller                    := TTerminalController.Create(Settings);
    Try
     Controller.NewTab;
     LeftPane := Controller.ActiveSession;
     Controller.Split(True);
     RightPane := Controller.ActiveSession;
     Controller.Split(False);
     BottomPane := Controller.ActiveSession;
     Assert.IsTrue(Controller.FocusDirection(0, -1));
     Assert.AreSame(RightPane, Controller.ActiveSession);
     Assert.IsTrue(Controller.FocusDirection( -1, 0));
     Assert.AreSame(LeftPane, Controller.ActiveSession);
     Assert.IsFalse(Controller.FocusDirection( -1, 0));
     Controller.FocusSession(BottomPane);
     Assert.IsTrue(Controller.MoveSplit(1, 0));
     Assert.AreEqual(55, Controller.ActiveTab.Root.Ratio);
     Assert.IsTrue(Controller.MoveSplit(0, -1));
     Assert.AreEqual(45, Controller.ActiveTab.Root.Second.Ratio);
    Finally
     Controller.Free;
    End;
   Finally
    Settings.Free;
   End;
  End;

/// <summary>Restores mixed split trees, custom titles, active panes and disk files; malformed input keeps live sessions.</summary>

 Procedure TTerminalTests.SessionTreeRoundTripAndFailedRestore;
  Var
   Settings   : TGuakeSettings;
   Controller : TTerminalController;
   State      : String;
   Path       : String;
   ActiveId   : String;
   Original   : TTerminalSession;
  Begin
   Path     := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName + '.json');
   Settings := TGuakeSettings.Create(Path + '.ini');
   Try
    Settings.General.DefaultShell := 'cmd';
    Controller                    := TTerminalController.Create(Settings);
    Try
     Controller.NewTab;
     Controller.ActiveTab.Name := 'Pierwsza';
     Controller.Split(True);
     Controller.MoveSplit(1, 0);
     Controller.Split(False);
     Controller.MoveSplit(0, -1);
     ActiveId                             := Controller.ActiveSession.Id;
     Controller.ActiveSession.CustomTitle := 'Panel żółty';
     Controller.NewTab;
     Controller.ActiveTab.Name := 'Druga';
     Controller.SelectTab(0);
     Controller.SaveSession(Path);
     State := Controller.SessionState;
     Controller.CloseTab(0);
     Controller.LoadSession(Path);
     Assert.AreEqual(2, Controller.Count);
     Assert.AreEqual(Integer(tnVertical), Integer(Controller.ActiveTab.Root.Kind));
     Assert.AreEqual(55, Controller.ActiveTab.Root.Ratio);
     Assert.AreEqual(Integer(tnHorizontal), Integer(Controller.ActiveTab.Root.Second.Kind));
     Assert.AreEqual(45, Controller.ActiveTab.Root.Second.Ratio);
     Assert.AreEqual(ActiveId, Controller.ActiveSession.Id);
     Assert.AreEqual('Panel żółty', Controller.ActiveSession.CustomTitle);
     Assert.AreEqual(State, Controller.SessionState);
     Original := Controller.ActiveSession;
     Assert.WillRaise(Procedure Begin Controller.RestoreState('{"version":99,"tabs":[]}'); End, EArgumentException);
     Assert.AreSame(Original, Controller.ActiveSession);
     Assert.AreEqual(2, Controller.Count);
    Finally
     Controller.Free;
    End;
   Finally
    Settings.Free;
    If TFile.Exists(Path) Then
     TFile.Delete(Path);
   End;
  End;

/// <summary>Feeds ZWJ families, flags, keycaps, skin tones and combining marks one UTF-8 byte at a time.</summary>

 Procedure TTerminalTests.ExtendedGraphemesAcrossByteFragments;
  Var
   Buffer : TTerminalBuffer;
   Bytes  : TBytes;
   One    : TBytes;
   b      : Byte;
  Begin
   Assert.IsTrue(UnicodeBreakEngineAvailable, 'Windows ICU character break engine is required for this scenario');
   Buffer := TTerminalBuffer.Create(40, 4);
   Try
    Bytes := TEncoding.UTF8.GetBytes('👨‍👩‍👧‍👦🇵🇱1️⃣👍🏽áX');
    SetLength(One, 1);
    For b In Bytes Do
     Begin
      One[0] := b;
      Buffer.Feed(One);
     End;
    Assert.AreEqual('👨‍👩‍👧‍👦', Buffer.Cell[0, 0].Text);
    Assert.AreEqual('🇵🇱', Buffer.Cell[2, 0].Text);
    Assert.AreEqual('1️⃣', Buffer.Cell[4, 0].Text);
    Assert.AreEqual('👍🏽', Buffer.Cell[6, 0].Text);
    Assert.AreEqual('á', Buffer.Cell[8, 0].Text);
    Assert.AreEqual('X', Buffer.Cell[9, 0].Text);
    Assert.IsTrue(Buffer.Cell[1, 0].Continuation);
    Buffer.Resize(6, 4);
    Buffer.Resize(40, 4);
    Assert.AreEqual('👨‍👩‍👧‍👦🇵🇱1️⃣👍🏽áX', Buffer.Text);
   Finally
    Buffer.Free;
   End;
  End;

/// <summary>Resizes repeatedly across wide-character boundaries without losing soft lines, hard newlines, styles or the prompt cursor.</summary>

 Procedure TTerminalTests.ReflowPreservesHistoryStylesAndCursor;
  Var
   Buffer : TTerminalBuffer;
   Before : String;
   i      : Integer;
   x      : Integer;
   y      : Integer;
   Found  : Boolean;
  Begin
   Buffer := TTerminalBuffer.Create(8, 3, 100);
   Try
    Buffer.FeedText('1234567界Z' + #13#10 + #27'[31m' + 'abc 👨‍👩‍👧‍👦 é END' + #27'[0m' + #13#10 + 'tail');
    Before := Buffer.Text;
    Assert.IsTrue(Pos('1234567界Z', Before) > 0, Before);
    For i := 1 To 4 Do
     Begin
      Buffer.Resize(5, 4);
      Assert.AreEqual(Before, Buffer.Text);
      Buffer.Resize(14, 3);
      Assert.AreEqual(Before, Buffer.Text);
     End;
    Found  := False;
    For y  := 0 To Buffer.TotalLines - 1 Do
     For x := 0 To Buffer.Columns - 1 Do
      If Buffer.Cell[x, y].Text = 'a' Then
       If Buffer.Cell[x, y].Foreground = 1 Then
        Found := True;
    Assert.IsTrue(Found, 'SGR attribute lost during reflow');
    Buffer.FeedText('!');
    Assert.AreEqual(Before + '!', Buffer.Text);
    Buffer.FeedText(#27'[?1049h' + 'alternate');
    Buffer.Resize(9, 4);
    Buffer.FeedText(#27'[?1049l');
    Assert.AreEqual(Before + '!', Buffer.Text);
   Finally
    Buffer.Free;
   End;
  End;

Initialization
 TDUnitX.RegisterTestFixture(TTerminalTests);

End.
