{$StackFrames On}
/// <summary>DUnitX verification of terminal tests.</summary>
Unit Guake.Terminal.Tests;
/// <summary>Exercises the actual ConPTY process lifecycle and independently verifies incremental VT behavior.</summary>

Interface

 Uses
  DUnitX.TestFramework, System.Classes;

 Type

  [TestFixture]
  TTerminalTests = Class
   Private
    fNotices : TStringList;
    Procedure CaptureNotification(Sender : TObject; Const Title, Body : String);
   Public
    [Test] Procedure UnchangedSplitPanesReuseComposition;
    [Test] Procedure BatchedAsciiPreservesCellPixels;
    [Test] Procedure TerminalCompositionLatency;
    [Test] Procedure TabColorsScopesAndSessionRestore;
    [Test] Procedure TabColorsRenderAndDeferredClose;
    [Test] Procedure TabActivityHonorsGraceAndSelection;
    [Test] Procedure QuickOpenDiagnosticsAndShellQuoting;
    [Test] Procedure QuickOpenCtrlClickAndContextMenu;
    [Test] Procedure PerPixelAlphaComposition;
    [Test] Procedure TerminalBackgroundAlphaAndWindowControls;
    [Test] Procedure AnimatedGifBackgroundDelaysAndRemoval;
    [Test] Procedure AnimatedGifDisposalAndFiniteLoop;
    [Test] Procedure UnsupportedCSIHasNoAliasedEffects;
    [Test] Procedure OriginRelativeCursorReports;
    [Test] Procedure ProgrammableTabStops;
    [Test] Procedure TabStopsResizeAndReset;
    [Test] Procedure IncrementalUnicodeAndCSI;
    [Test] Procedure ExtendedGraphemesAcrossByteFragments;
    [Test] Procedure ReflowPreservesHistoryStylesAndCursor;
    [Test] Procedure ProjectYamlAndCustomCommandMenu;
    [Test] Procedure StartupRestoreAutosaveAndNotifications;
    [Test] Procedure NativeHooksAutostartAndBell;
    [Test] Procedure TrayOnlyStyleRejectsVclMutation;
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
  System.Diagnostics, Guake.Colors, Guake.CommandLine, Guake.QuickOpen, System.Types, Guake.Composition, Guake.AnimatedBackground, Vcl.Imaging.GIFImg, frmAboutU, Guake.WindowsIntegration, System.Win.Registry, Guake.ProjectConfig, System.JSON, System.Generics.Collections, Guake.Unicode, Guake.Links, Winapi.Windows, Winapi.Messages, System.SysUtils, System.IOUtils,
  frmMainU, fraTerminalU, Vcl.Graphics, Vcl.Imaging.pngimage, Vcl.ComCtrls, Vcl.Controls, Guake.ConPTY, Guake.VT, Guake.Shells, Guake.Sessions, Guake.Settings, Guake.Keybindings, Vcl.Forms;

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

 Function PixelAt(Bitmap : TBitmap; x, y : Integer) : TRGBQuad; Forward;

 Procedure TTerminalTests.UnsupportedCSIHasNoAliasedEffects;
  Var
   Buffer : TTerminalBuffer;
  Begin
   Buffer := TTerminalBuffer.Create(20, 4);
   Try
    Buffer.FeedText('abc'#27'[3;4H');
    Buffer.FeedText(#27'[ A'#27'[?2J'#27'[>2J'#27'[1:2H');
    Assert.AreEqual(3, Buffer.CursorX);
    Assert.AreEqual(2, Buffer.CursorY);
    Assert.AreEqual('abc', Buffer.LineText(0));
    Buffer.FeedText(#27'[?3g'#13#9);
    Assert.AreEqual(8, Buffer.CursorX);
    Buffer.FeedText(#27'[3g'#27'[?5W'#13#9);
    Assert.AreEqual(8, Buffer.CursorX);
   Finally
    Buffer.Free;
   End;
  End;

 Procedure TTerminalTests.OriginRelativeCursorReports;
  Var
   Buffer : TTerminalBuffer;
  Begin
   Buffer := TTerminalBuffer.Create(20, 8);
   Try
    Buffer.FeedText(#27'[3;7r'#27'[?6h'#27'[2;4H'#27'[6n'#27'[?6n');
    Assert.AreEqual(#27'[2;4R'#27'[?2;4R', Buffer.TakeResponses);
    Buffer.FeedText(#27'[?5n');
    Assert.AreEqual('', Buffer.TakeResponses);
    Buffer.FeedText(#27'[?6l'#27'[6n');
    Assert.AreEqual(#27'[1;1R', Buffer.TakeResponses);
   Finally
    Buffer.Free;
   End;
  End;

 Procedure TTerminalTests.ProgrammableTabStops;
  Var
   Buffer : TTerminalBuffer;
  Begin
   Buffer := TTerminalBuffer.Create(24, 3);
   Try
    Buffer.FeedText(#9);
    Assert.AreEqual(8, Buffer.CursorX);
    Buffer.FeedText(#27'[3g'#13#9);
    Assert.AreEqual(23, Buffer.CursorX);
    Buffer.FeedText(#13#27'[5G'#27);
    Buffer.FeedText('H'#13#9);
    Assert.AreEqual(4, Buffer.CursorX);
    Buffer.FeedText(#27'[12G'#27'H'#13#27'[2I');
    Assert.AreEqual(11, Buffer.CursorX);
    Buffer.FeedText(#27'[Z');
    Assert.AreEqual(4, Buffer.CursorX);
    Buffer.FeedText(#27'[g'#13#27'[I');
    Assert.AreEqual(11, Buffer.CursorX);
    Buffer.FeedText(#27'[999Z');
    Assert.AreEqual(0, Buffer.CursorX);
    Assert.AreEqual('', Trim(Buffer.Text));
   Finally
    Buffer.Free;
   End;
  End;

 Procedure TTerminalTests.TabStopsResizeAndReset;
  Var
   Buffer : TTerminalBuffer;
  Begin
   Buffer := TTerminalBuffer.Create(20, 3);
   Try
    Buffer.FeedText(#27'[3g'#27'[6G'#27'H');
    Buffer.Resize(10, 3);
    Buffer.FeedText(#13#9);
    Assert.AreEqual(5, Buffer.CursorX);
    Buffer.Resize(32, 3);
    Buffer.FeedText(#13#27'[2I');
    Assert.AreEqual(24, Buffer.CursorX);
    Buffer.FeedText(#27'c'#9);
    Assert.AreEqual(8, Buffer.CursorX);
    Buffer.FeedText(#27'[2I');
    Assert.AreEqual(24, Buffer.CursorX);
    Buffer.FeedText(#27'[I');
    Assert.AreEqual(31, Buffer.CursorX);
    Buffer.FeedText(#27'[Z');
    Assert.AreEqual(24, Buffer.CursorX);
   Finally
    Buffer.Free;
   End;
  End;

 Procedure TTerminalTests.UnchangedSplitPanesReuseComposition;
  Var
   Settings    : TGuakeSettings;
   Main        : TfrmMain;
   Bitmap      : TBitmap;
   Frames      : TList<TfraTerminal>;
   FirstCount  : UInt64;
   SecondCount : UInt64;
   RowsBefore  : UInt64;

   Procedure Collect(Host : TWinControl);
    Var
     i : Integer;
    Begin
     For i := 0 To Host.ControlCount - 1 Do
      If Host.Controls[i] Is TfraTerminal Then
       Frames.Add(TfraTerminal(Host.Controls[i]))
      Else If Host.Controls[i] Is TWinControl Then
       Collect(TWinControl(Host.Controls[i]));
    End;

  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Frames   := TList<TfraTerminal>.Create;
   Bitmap   := TBitmap.Create;
   Try
    Settings.General.DefaultShell         := 'cmd';
    Settings.General.UseTrayicon          := False;
    Settings.General.UsePopup             := False;
    Settings.General.DropDownAnimation    := False;
    Settings.Keybindings.Global.ShowHide  := 'disabled';
    Settings.Keybindings.Global.ShowFocus := 'disabled';
    Main                                  := TfrmMain.Create(Nil);
    Try
     Main.Bind(Settings);
     Main.StartTerminal;
     Main.Controller.Split(True);
     Main.HandleNeeded;
     Main.SetBounds( -30000, 0, 800, 400);
     Collect(Main.terminalHost);
     Assert.AreEqual(2, Frames.Count);
     Frames[0].Session.Buffer.FeedText(#27'[?25l');
     Frames[1].Session.Buffer.FeedText(#27'[?25l');
     Frames[0].RefreshTick(Nil);
     Frames[1].RefreshTick(Nil);
     Main.RenderWindow(Bitmap);
     FirstCount  := Frames[0].AlphaRenderCount;
     SecondCount := Frames[1].AlphaRenderCount;
     Main.RenderWindow(Bitmap);
     Assert.AreEqual(FirstCount, Frames[0].AlphaRenderCount, 'Idle pane must reuse its pixels');
     Assert.AreEqual(SecondCount, Frames[1].AlphaRenderCount);
     RowsBefore := Frames[0].RasterRowCount;
     Frames[0].Session.Buffer.FeedText('new output');
     Frames[0].RefreshTick(Nil);
     Main.RenderWindow(Bitmap);
     Assert.AreEqual(FirstCount + UInt64(1), Frames[0].AlphaRenderCount);
     Assert.AreEqual(SecondCount, Frames[1].AlphaRenderCount, 'Output in another pane must not rasterize this pane');
     Assert.AreEqual(RowsBefore + UInt64(1), Frames[0].RasterRowCount, 'Typing must rasterize only the changed row');
     Settings.Style.Background.Transparency := 50;
     Main.RenderWindow(Bitmap);
     Assert.AreEqual(SecondCount + UInt64(1), Frames[1].AlphaRenderCount, 'Opacity change invalidates cached alpha');
     Frames[0].Session.Buffer.FeedText(StringOfChar('H', Frames[0].Session.Buffer.Columns * (Frames[0].Session.Buffer.Rows + 4)));
     Frames[0].RefreshTick(Nil);
     Frames[0].Session.Buffer.FeedText(#27'[?1049h' + #27'[?25l' + #27'[H' + #27'[41m ' + #27'[m');
     Frames[0].RefreshTick(Nil);
     Frames[0].RenderAlpha(Bitmap, 255);
     Frames[0].Session.Buffer.FeedText(#27'[H' + #27'[42m ' + #27'[m');
     Frames[0].RefreshTick(Nil);
     Frames[0].RenderAlpha(Bitmap, 255);
     Assert.IsTrue(PixelAt(Bitmap, 5, 5).rgbGreen > PixelAt(Bitmap, 5, 5).rgbRed,
     'Incremental redraw must compare the alternate screen, not primary scrollback');
    Finally
     Main.Free;
    End;
   Finally
    Bitmap.Free;
    Frames.Free;
    Settings.Free;
   End;
  End;

 Procedure TTerminalTests.BatchedAsciiPreservesCellPixels;
  Var
   Settings      : TGuakeSettings;
   Main          : TfrmMain;
   Frame         : TfraTerminal;
   Actual        : TBitmap;
   Reference     : TBitmap;
   Text          : TArray<String>;
   Palette       : TArray<String>;
   CellWidth     : Integer;
   CellHeight    : Integer;
   Row           : Integer;
   Column        : Integer;
   x             : Integer;
   y             : Integer;
   Bounds        : TRect;
   ActualPixel   : PCardinal;
   ExpectedPixel : PCardinal;
  Begin
   Settings  := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Actual    := TBitmap.Create;
   Reference := TBitmap.Create;
   Try
    Settings.General.DefaultShell         := 'cmd';
    Settings.General.UseTrayicon          := False;
    Settings.General.UsePopup             := False;
    Settings.Keybindings.Global.ShowHide  := 'disabled';
    Settings.Keybindings.Global.ShowFocus := 'disabled';
    Main                                  := TfrmMain.Create(Nil);
    Try
     Main.Bind(Settings);
     Main.StartTerminal;
     Main.HandleNeeded;
     Main.SetBounds( -30000, 0, 500, 160);
     Frame := Main.ActiveTerminalFrame;
     Text  := TArray<String>.Create('ASCII Wi01 % [abc] /foo', 'More monospace text 1234567890');
     Frame.Session.Buffer.FeedText(#27'[2J' + #27'[H' + Text[0] + #13#10 + Text[1] + #27'[?25l');
     Frame.RefreshTick(Nil);
     Frame.RenderAlpha(Actual, 255);
     Reference.PixelFormat := pf32bit;
     Reference.SetSize(Actual.Width, Actual.Height);
     Palette                      := Settings.Style.Font.Palette.Split([':']);
     Reference.Canvas.Brush.Color := ParseTerminalColor(Palette[17]);
     Reference.Canvas.FillRect(Rect(0, 0, Reference.Width, Reference.Height));
     Reference.Canvas.Font.Assign(Frame.Font);
     CellWidth  := Reference.Canvas.TextWidth('M');
     CellHeight := Reference.Canvas.TextHeight('Mg');
     SetBkMode(Reference.Canvas.Handle, TRANSPARENT);
     SetTextColor(Reference.Canvas.Handle, ParseTerminalColor(Palette[16]));
     For Row     := 0 To High(Text) Do
      For Column := 1 To Length(Text[Row]) Do
       Begin
        Bounds := Rect(4 + (Column - 1) * CellWidth, 4 + Row * CellHeight,
        4 + Column * CellWidth, 4 + (Row + 1) * CellHeight);
        ExtTextOut(Reference.Canvas.Handle, Bounds.Left, Bounds.Top, ETO_CLIPPED, @Bounds,
        @Text[Row][Column], 1, Nil);
       End;
     For y := 0 To Reference.Height - 1 Do
      Begin
       ActualPixel   := Actual.ScanLine[y];
       ExpectedPixel := Reference.ScanLine[y];
       For x         := 0 To Reference.Width - 1 Do
        Begin
         If (ActualPixel^ And $FFFFFF) <> (ExpectedPixel^ And $FFFFFF) Then
          Assert.Fail(Format('ASCII grid pixel differs at %d,%d', [x, y]));
         Inc(ActualPixel);
         Inc(ExpectedPixel);
        End;
      End;

     Frame.Session.Buffer.FeedText(#27'[1;1H' + #27'[2K');
     Frame.RefreshTick(Nil);
     Frame.RenderAlpha(Actual, 255);
     Reference.Canvas.Brush.Color := ParseTerminalColor(Palette[17]);
     Reference.Canvas.FillRect(Rect(0, 4, Reference.Width, 4 + CellHeight));
     For y := 0 To Reference.Height - 1 Do
      Begin
       ActualPixel   := Actual.ScanLine[y];
       ExpectedPixel := Reference.ScanLine[y];
       For x         := 0 To Reference.Width - 1 Do
        Begin
         If (ActualPixel^ And $FFFFFF) <> (ExpectedPixel^ And $FFFFFF) Then
          Assert.Fail(Format('Incremental erase changed another row or left stale pixels at %d,%d', [x, y]));
         Inc(ActualPixel);
         Inc(ExpectedPixel);
        End;
      End;
     Assert.AreEqual(Reference.Width, Actual.Width);
    Finally
     Main.Free;
    End;
   Finally
    Reference.Free;
    Actual.Free;
    Settings.Free;
   End;
  End;

 Procedure TTerminalTests.TerminalCompositionLatency;
  Var
   Settings : TGuakeSettings;
   Main     : TfrmMain;
   Frame    : TfraTerminal;
   Bitmap   : TBitmap;
   Watch    : TStopwatch;
   i        : Integer;
   Sparse   : Double;
   Dense    : Double;
   Line     : String;
  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Bitmap   := TBitmap.Create;
   Try
    Settings.General.DefaultShell          := 'cmd';
    Settings.General.UseTrayicon           := False;
    Settings.General.UsePopup              := False;
    Settings.General.DropDownAnimation     := False;
    Settings.Keybindings.Global.ShowHide   := 'disabled';
    Settings.Keybindings.Global.ShowFocus  := 'disabled';
    Settings.Style.Background.Transparency := 85;
    Main                                   := TfrmMain.Create(Nil);
    Try
     Main.Bind(Settings);
     Main.StartTerminal;
     Main.HandleNeeded;
     Main.SetBounds( -30000, 0, 1920, 1080);
     Frame := Main.ActiveTerminalFrame;
     Frame.Session.Buffer.FeedText(#27'[2J' + #27'[H' + 'prompt> ');
     Frame.RefreshTick(Nil);
     Main.RenderWindow(Bitmap);
     Watch := TStopwatch.StartNew;
     For i := 1 To 5 Do
      Begin
       Frame.Session.Buffer.FeedText('x');
       Frame.RefreshTick(Nil);
       Main.RenderWindow(Bitmap);
      End;
     Sparse := Watch.Elapsed.TotalMilliseconds / 5;
     Line   := StringOfChar('A', Frame.Session.Buffer.Columns - 1) + #13#10;
     For i  := 1 To Frame.Session.Buffer.Rows - 2 Do
      Frame.Session.Buffer.FeedText(Line);
     Frame.RefreshTick(Nil);
     Main.RenderWindow(Bitmap);
     Watch := TStopwatch.StartNew;
     For i := 1 To 5 Do
      Begin
       Frame.Session.Buffer.FeedText('x');
       Frame.RefreshTick(Nil);
       Main.RenderWindow(Bitmap);
      End;
     Dense := Watch.Elapsed.TotalMilliseconds / 5;
     TFile.WriteAllText(TPath.Combine(ExtractFilePath(ParamStr(0)), 'composition-latency.txt'),
     Format('1920x1080; sparse=%.3f ms; dense=%.3f ms', [Sparse, Dense], TFormatSettings.Invariant));
     Assert.AreEqual(1920, Bitmap.Width);
     Assert.AreEqual(1080, Bitmap.Height);
    Finally
     Main.Free;
    End;
   Finally
    Bitmap.Free;
    Settings.Free;
   End;
  End;

 Procedure TTerminalTests.TabColorsScopesAndSessionRestore;
  Var
   Settings   : TGuakeSettings;
   Controller : TTerminalController;
   Restored   : TTerminalController;
   First      : TTerminalSession;
   State      : String;
   Before     : String;
   Options    : TGuakeLaunchOptions;
  Begin
   Assert.AreEqual(Integer(RGB($AA, $BB, $CC)), ParseTerminalColor('abc'));
   Assert.AreEqual(Integer(RGB(255, 0, 128)), ParseTerminalColor('#ffff00008080'));
   Assert.WillRaise(Procedure Begin ParseTerminalColor('not-a-color'); End, EArgumentException);
   Options := ParseGuakeArguments(TArray<String>.Create('--bgcolor', '123456', '--fgcolor-current', 'abc', '--reset-colors-current'));
   Assert.AreEqual(3, Integer(Length(Options.Commands)));
   Assert.IsTrue(Pos('bgcolor', Options.Commands[0]) > 0);
   Assert.IsTrue(Pos('current', Options.Commands[1]) > 0);
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Settings.General.DefaultShell := 'cmd';
    Controller                    := TTerminalController.Create(Settings);
    Restored                      := TTerminalController.Create(Settings);
    Try
     Controller.NewTab;
     First := Controller.ActiveSession;
     Controller.Split(True);
     Controller.SetColor(True, clRed);
     Assert.AreEqual(Integer(clRed), First.CustomForeground);
     Assert.AreEqual(Integer(clRed), Controller.ActiveSession.CustomForeground);
     Controller.SetColor(False, clBlue, tcsTerminal);
     Assert.AreEqual( -1, First.CustomBackground);
     Assert.AreEqual(Integer(clBlue), Controller.ActiveSession.CustomBackground);
     Controller.NewTab;
     Assert.AreEqual( -1, Controller.ActiveSession.CustomForeground);
     Controller.SelectTab(0);
     State := Controller.SessionState;
     Restored.RestoreState(State);
     Assert.AreEqual(2, Restored.Count);
     Assert.AreEqual(Integer(clBlue), Restored.ActiveSession.CustomBackground);
     Assert.AreEqual(Integer(clRed), Restored.ActiveTab.Root.First.Session.CustomForeground);
     Restored.ResetColors(tcsTerminal);
     Assert.AreEqual( -1, Restored.ActiveSession.CustomForeground);
     Assert.AreEqual(Integer(clRed), Restored.ActiveTab.Root.First.Session.CustomForeground);
     Restored.ResetColors(tcsTab);
     Assert.AreEqual( -1, Restored.ActiveTab.Root.First.Session.CustomForeground);
     Restored.SetColor(True, clGreen, tcsAll);
     Restored.ResetColors;
     Assert.AreEqual( -1, Restored.Tabs[1].Active.Session.CustomForeground);
     Before := Restored.SessionState;
     Assert.WillRaise(Procedure Begin Restored.RestoreState(StringReplace(Before,
     '"custom-foreground":-1', '"custom-foreground":16777216', [rfReplaceAll])); End, EArgumentOutOfRangeException);
     Assert.AreEqual(Before, Restored.SessionState, 'Invalid colors must not replace live sessions');
    Finally
     Restored.Free;
     Controller.Free;
    End;
   Finally
    Settings.Free;
   End;
  End;

 Procedure TTerminalTests.TabColorsRenderAndDeferredClose;
  Var
   Settings : TGuakeSettings;
   Main     : TfrmMain;
   Output   : TBitmap;
   Preview  : TPngImage;
   Pixel    : TRGBQuad;
   Bounds   : TRect;
   FirstId  : String;
   Origin   : TPoint;
   x        : Integer;
   y        : Integer;
   Dark     : Integer;
  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Output   := TBitmap.Create;
   Try
    Settings.General.DefaultShell         := 'cmd';
    Settings.General.UseTrayicon          := False;
    Settings.General.UsePopup             := False;
    Settings.General.DropDownAnimation    := False;
    Settings.General.TabCloseButtons      := True;
    Settings.General.DisplayTabActivity   := True;
    Settings.General.PromptOnCloseTab     := 0;
    Settings.Keybindings.Global.ShowHide  := 'disabled';
    Settings.Keybindings.Global.ShowFocus := 'disabled';
    Main                                  := TfrmMain.Create(Nil);
    Try
     Main.Bind(Settings);
     Main.StartTerminal;
     Main.Show;
     Main.SetBounds( -30000, 0, 1000, 300);
     FirstId := Main.Controller.ActiveTab.Id;
     Main.ExecuteIPCCommand('{"action":"bgcolor","color":"123456"}');
     Main.ActiveTerminalFrame.RenderAlpha(Output, 255);
     Pixel := PixelAt(Output, 1, 1);
     Assert.AreEqual(18, Integer(Pixel.rgbRed));
     Assert.AreEqual(52, Integer(Pixel.rgbGreen));
     Assert.AreEqual(86, Integer(Pixel.rgbBlue));
     Main.TabMenuPopup(Nil);
     Assert.IsTrue(Main.miRestoreTabColors.Enabled);
     Main.miRestoreTabColors.Click;
     Assert.AreEqual( -1, Main.Controller.ActiveSession.CustomBackground);
     Main.Controller.NewTab;
     Main.Controller.SelectTab(0);
     Main.Controller.Tabs[1].HasActivity := True;
     Main.ApplySettings;
     Assert.IsTrue(Main.tabBar.OwnerDraw);
     Main.RenderWindow(Output);
     Bounds := Main.TabCloseRect(1);
     Origin := Main.ScreenToClient(Main.tabBar.ClientToScreen(Point(0, 0)));
     Dark   := 0;
     For y  := (Bounds.Top + Bounds.Bottom) Div 2 - 3 To(Bounds.Top + Bounds.Bottom) Div 2 + 3 Do
      For x := (Bounds.Left + Bounds.Right) Div 2 - 3 To(Bounds.Left + Bounds.Right) Div 2 + 3 Do
       Begin
        Pixel := PixelAt(Output, Origin.x + x, Origin.y + y);
        If (Pixel.rgbRed < 100) And (Pixel.rgbGreen < 100) And (Pixel.rgbBlue < 100) Then
         Inc(Dark);
       End;
     Assert.IsTrue(Dark >= 4, 'The close icon must be present in the layered-window bitmap');
     Assert.IsTrue(Main.tabBar.Tabs[1] <> '', 'Tab caption must not be empty');
     Bounds       := Main.tabBar.TabRect(1);
     Bounds.Right := Main.TabCloseRect(1).Left - 2;
     InflateRect(Bounds, -6, -4);
     Dark   := 0;
     For y  := Bounds.Top To Bounds.Bottom - 1 Do
      For x := Bounds.Left To Bounds.Right - 1 Do
       Begin
        Pixel := PixelAt(Output, Origin.x + x, Origin.y + y);
        If (Pixel.rgbRed < 100) And (Pixel.rgbGreen < 100) And (Pixel.rgbBlue < 100) Then
         Inc(Dark);
       End;
     Assert.IsTrue(Dark >= 3, Format('Caption [%s], text bounds %d,%d..%d,%d, dark %d', [Main.tabBar.Tabs[1], Bounds.Left, Bounds.Top, Bounds.Right, Bounds.Bottom, Dark]));
     Preview := TPngImage.Create;
     Try
      Preview.Assign(Output);
      Preview.SaveToFile(TPath.Combine(ExtractFilePath(ParamStr(0)), 'tabs-preview.png'));
     Finally
      Preview.Free;
     End;
     Bounds := Main.TabCloseRect(1);
     Main.TabMouseDown(Main.tabBar, mbLeft, [], (Bounds.Left + Bounds.Right) Div 2, (Bounds.Top + Bounds.Bottom) Div 2);
     Assert.AreEqual(2, Main.Controller.Count, 'Close is deferred until after the native mouse notification');
     Main.Perform(WM_APP + 44, 0, 0);
     Assert.AreEqual(1, Main.Controller.Count);
     Assert.AreEqual(FirstId, Main.Controller.ActiveTab.Id);
     Settings.General.TabCloseButtons := False;
     Main.ApplySettings;
     Bounds := Main.TabCloseRect(0);
     Main.TabMouseDown(Main.tabBar, mbLeft, [], (Bounds.Left + Bounds.Right) Div 2, (Bounds.Top + Bounds.Bottom) Div 2);
     Main.Perform(WM_APP + 44, 0, 0);
     Assert.AreEqual(1, Main.Controller.Count, 'Disabled close button cannot close a tab');
    Finally
     Main.Free;
    End;
   Finally
    Output.Free;
    Settings.Free;
   End;
  End;

 Procedure TTerminalTests.TabActivityHonorsGraceAndSelection;
  Var
   Settings   : TGuakeSettings;
   Controller : TTerminalController;
   First      : TTerminalTab;
   Deadline   : UInt64;

   Procedure WaitForOutput(Const Marker : String);
    Begin
     Deadline := GetTickCount64 + 5000;
     Repeat
      Controller.Poll;
      If Pos(Marker, First.Root.Session.Buffer.Text) > 0 Then
       Exit;
      Sleep(10);
     Until GetTickCount64 >= Deadline;
     Assert.Fail('Background shell did not produce output');
    End;

  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Settings.General.DefaultShell              := 'cmd';
    Settings.General.DisplayTabActivity        := True;
    Settings.General.TabActivityNewTabGrace    := 60;
    Settings.General.TabActivityFocusLossGrace := 60;
    Controller                                 := TTerminalController.Create(Settings);
    Try
     First := Controller.NewTab;
     Controller.NewTab;
     Assert.IsTrue(First.ActivityIgnoreUntil > GetTickCount64 + 50000);
     First.Root.Session.SendText('echo ACTIVITY_IGNORED' + #13);
     WaitForOutput('ACTIVITY_IGNORED');
     Assert.IsFalse(First.HasActivity);
     First.ActivityIgnoreUntil := 0;
     First.Root.Session.SendText('echo ACTIVITY_MARKED' + #13);
     WaitForOutput('ACTIVITY_MARKED');
     Assert.IsTrue(First.HasActivity);
     Controller.SelectTab(0);
     Assert.IsFalse(First.HasActivity, 'Selecting a tab acknowledges its activity');
     Controller.SelectTab(1);
     Assert.IsTrue(First.ActivityIgnoreUntil > GetTickCount64 + 50000);
     First.HasActivity                   := True;
     Settings.General.DisplayTabActivity := False;
     Controller.Poll;
     Assert.IsFalse(First.HasActivity, 'Disabling activity clears existing highlights');
    Finally
     Controller.Free;
    End;
   Finally
    Settings.Free;
   End;
  End;

 Procedure TTerminalTests.QuickOpenDiagnosticsAndShellQuoting;
  Var
   Directory : String;
   FileName  : String;
   Text      : String;
   Posix     : String;
   Command   : String;
   Target    : TQuickOpenTarget;
  Begin
   Directory := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
   TDirectory.CreateDirectory(Directory);
   FileName := TPath.Combine(Directory, 'zażółć test.py');
   Try
    TFile.WriteAllText(FileName, '# header' + #10 + 'class Tests:' + #10 + '    def test_value(self): pass' + #10, TEncoding.UTF8);
    Text := '  File "' + FileName + '", line 27, in main';
    Assert.IsTrue(FindQuickOpenTarget(Text, 10, Directory, '', Target), 'Python traceback');
    Assert.AreEqual(FileName, Target.FileName);
    Assert.AreEqual(27, Target.LineNumber);
    Text := '"' + FileName + '":17:4: error';
    Assert.IsTrue(FindQuickOpenTarget(Text, 3, Directory, '', Target), 'Quoted GCC diagnostic');
    Assert.AreEqual(17, Target.LineNumber);
    Assert.AreEqual(4, Target.ColumnNumber);
    Text := FileName + ':32:9: error';
    Assert.IsTrue(FindQuickOpenTarget(Text, 3, Directory, '', Target), 'Unquoted GCC path with spaces');
    Assert.AreEqual(32, Target.LineNumber);
    Assert.AreEqual(9, Target.ColumnNumber);
    Assert.AreEqual('https://example.org/a', TerminalLinkAt('https://example.org/a', 0));
    Assert.AreEqual('https://example.org/a', TerminalLinkAt('https://example.org/a', 20));
    Text := FileName + '(31,8): error';
    Assert.IsTrue(FindQuickOpenTarget(Text, 3, Directory, '', Target), 'Delphi/MSVC diagnostic');
    Assert.AreEqual(31, Target.LineNumber);
    Assert.AreEqual(8, Target.ColumnNumber);
    Assert.IsTrue(FindQuickOpenTarget('"zażółć test.py"', -1, Directory, '', Target), 'Relative quoted path');
    Assert.AreEqual(FileName, Target.FileName);
    TFile.Copy(FileName, TPath.Combine(Directory, 'test.py'));
    Assert.IsTrue(FindQuickOpenTarget('test.py::Tests::test_value', 2, Directory, '', Target), 'Pytest function');
    Assert.AreEqual(3, Target.LineNumber);
    Posix := StringReplace(FileName, '\', '/', [rfReplaceAll]);
    Posix := '/' + LowerCase(Posix[1]) + Copy(Posix, 3, MaxInt);
    Assert.IsTrue(FindQuickOpenTarget('"' + Posix + '"', -1, Directory, '', Target), 'Git drive path');
    Assert.AreEqual(FileName, Target.FileName);
    TDirectory.CreateDirectory(TPath.Combine(Directory, 'usr\include'));
    TFile.WriteAllText(TPath.Combine(Directory, 'usr\include\test.h'), 'test');
    Assert.IsTrue(FindQuickOpenTarget('/usr/include/test.h:9', 5, Directory, Directory, Target), 'Git SDK path');
    Assert.AreEqual(9, Target.LineNumber);
    Assert.IsFalse(FindQuickOpenTarget('missing.py:23', 2, Directory, '', Target), 'Missing file');
    Assert.IsFalse(FindQuickOpenTarget('prefix "' + FileName + '":17 suffix', 0, Directory, '', Target), 'Click outside the file');
    Assert.IsFalse(FindQuickOpenTarget(StringOfChar('x', 8193), 0, Directory, '', Target), 'Oversized diagnostic');
    Target.FileName     := 'C:\folder with spaces\O''Brien $x.py';
    Target.LineNumber   := 17;
    Target.ColumnNumber := 4;
    Assert.AreEqual('editor "C:\folder with spaces\O''Brien $x.py":17:4',
    QuickOpenCommand('editor %(file_path)s:%(line_number)s:%(column_number)s', Target, gsCmd));
    Assert.AreEqual('editor "C:\folder with spaces\O''Brien $x.py"',
    QuickOpenCommand('editor "%(file_path)s"', Target, gsCmd));
    Command := QuickOpenCommand('editor %(file_path)s', Target, gsPowerShell);
    Assert.IsTrue(Pos('O''''Brien', Command) > 0, 'PowerShell apostrophe');
    Command := QuickOpenCommand('editor "%(file_path)s"', Target, gsPowerShell);
    Assert.IsTrue(Pos('`$x', Command) > 0, 'PowerShell expansion');
    Command := QuickOpenCommand('editor %(file_path)s', Target, gsBash);
    Assert.IsTrue(Pos('/c/folder with spaces/', Command) > 0, 'POSIX drive mapping');
    Assert.IsTrue(Pos(#39'"'#39'"'#39, Command) > 0, 'POSIX apostrophe');
    Command := QuickOpenCommand('editor "%(file_path)s"', Target, gsZsh);
    Assert.IsTrue(Pos('\$x', Command) > 0, 'Zsh expansion');
   Finally
    TDirectory.Delete(Directory, True);
   End;
  End;

 Procedure TTerminalTests.QuickOpenCtrlClickAndContextMenu;
  Var
   Settings  : TGuakeSettings;
   Main      : TfrmMain;
   Frame     : TfraTerminal;
   Directory : String;
   FileName  : String;
   FlagFile  : String;
   Text      : String;
   Deadline  : UInt64;

   Procedure WaitForEditor;
    Begin
     Deadline := GetTickCount64 + 5000;
     While Not TFile.Exists(FlagFile) And (GetTickCount64 < Deadline) Do
      Begin
       Main.PollTerminal(Nil);
       Sleep(10);
      End;
     Assert.IsTrue(TFile.Exists(FlagFile), 'Editor command was not executed');
     Assert.AreEqual('QUICK_OPEN_17_4', Trim(TFile.ReadAllText(FlagFile)));
    End;

   Procedure PutDiagnostic;
    Begin
     Frame.Session.Buffer.FeedText(#27'[2J' + #27'[H' + Text);
     Frame.RefreshTick(Nil);
    End;

  Begin
   Directory := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
   TDirectory.CreateDirectory(Directory);
   FileName := TPath.Combine(Directory, 'test.pas');
   FlagFile := TPath.Combine(Directory, 'opened.txt');
   Settings := TGuakeSettings.Create(TPath.Combine(Directory, 'settings.ini'));
   Try
    TFile.WriteAllText(FileName, 'test');
    Settings.General.DefaultShell               := 'cmd';
    Settings.General.UseTrayicon                := False;
    Settings.General.UsePopup                   := False;
    Settings.General.DropDownAnimation          := False;
    Settings.Keybindings.Global.ShowHide        := 'disabled';
    Settings.Keybindings.Global.ShowFocus       := 'disabled';
    Settings.General.QuickOpenEnable            := True;
    Settings.General.QuickOpenInCurrentTerminal := True;
    Settings.General.QuickOpenCommandLine       := 'echo QUICK_OPEN_%(line_number)s_%(column_number)s>"' + FlagFile + '"';
    Main                                        := TfrmMain.Create(Nil);
    Try
     Main.Bind(Settings);
     Main.StartTerminal;
     Main.Show;
     Main.SetBounds( -30000, 0, 1200, 300);
     Frame := Main.ActiveTerminalFrame;
     Text  := '"' + FileName + '":17:4';
     PutDiagnostic;
     Frame.SurfaceMouseDown(Nil, mbLeft, [ssCtrl], 6, 5);
     Frame.SurfaceMouseUp(Nil, mbLeft, [ssCtrl], 6, 5);
     Assert.AreEqual('', Frame.SelectedText);
     WaitForEditor;
     TFile.Delete(FlagFile);
     Settings.General.QuickOpenInCurrentTerminal := False;
     PutDiagnostic;
     Assert.IsTrue(Pos(Text, Frame.Session.Buffer.Text) > 0, 'Diagnostic must be available for selection');
     Frame.HighlightText(Pos(Text, Frame.Session.Buffer.Text), Length(Text));
     Assert.AreEqual(Text, Frame.SelectedText, 'Select the entire diagnostic including its column');
     Main.TerminalMenuPopup(Nil);
     Assert.IsTrue(Main.miQuickOpen.Enabled, 'Selected diagnostic enables Quick Open: ' + Frame.SelectedText);
     Main.miQuickOpen.Click;
     WaitForEditor;
     TFile.Delete(FlagFile);
     Settings.General.QuickOpenEnable := False;
     Main.TerminalMenuPopup(Nil);
     Assert.IsFalse(Main.miQuickOpen.Enabled);
     Frame.SurfaceMouseDown(Nil, mbLeft, [ssCtrl], 6, 5);
     Frame.SurfaceMouseUp(Nil, mbLeft, [ssCtrl], 6, 5);
     Assert.IsFalse(TFile.Exists(FlagFile));
    Finally
     Main.Free;
    End;
   Finally
    Settings.Free;
    TDirectory.Delete(Directory, True);
   End;
  End;

 Function PixelAt(Bitmap : TBitmap; x, y : Integer) : TRGBQuad;
  Var
   Pixel : PRGBQuad;
  Begin
   Pixel := Bitmap.ScanLine[y];
   Inc(Pixel, x);
   Result := Pixel^;
  End;

 Procedure TTerminalTests.PerPixelAlphaComposition;
  Var
   Color      : TBitmap;
   Background : TBitmap;
   Mask       : TBitmap;
   Output     : TBitmap;
   Pixel      : TRGBQuad;
  Begin
   Color      := TBitmap.Create;
   Background := TBitmap.Create;
   Mask       := TBitmap.Create;
   Output     := TBitmap.Create;
   Try
    Color.PixelFormat      := pf32bit;
    Background.PixelFormat := pf32bit;
    Mask.PixelFormat       := pf32bit;
    Color.SetSize(3, 1);
    Background.SetSize(3, 1);
    Mask.SetSize(3, 1);
    Background.Canvas.Brush.Color := RGB(40, 80, 120);
    Background.Canvas.FillRect(Rect(0, 0, 3, 1));
    Color.Assign(Background);
    Color.Canvas.Pixels[1, 0] := RGB(200, 100, 60);
    Color.Canvas.Pixels[2, 0] := RGB(120, 90, 90);
    Mask.Canvas.Pixels[0, 0]  := clBlack;
    Mask.Canvas.Pixels[1, 0]  := clWhite;
    Mask.Canvas.Pixels[2, 0]  := RGB(128, 128, 128);
    ComposeTerminalAlpha(Color, Background, Mask, Output, 128);
    Pixel := PixelAt(Output, 0, 0);
    Assert.AreEqual(128, Integer(Pixel.rgbReserved));
    Assert.AreEqual(20, Integer(Pixel.rgbRed));
    Assert.AreEqual(40, Integer(Pixel.rgbGreen));
    Assert.AreEqual(60, Integer(Pixel.rgbBlue));
    Pixel := PixelAt(Output, 1, 0);
    Assert.AreEqual(255, Integer(Pixel.rgbReserved));
    Assert.AreEqual(200, Integer(Pixel.rgbRed));
    Pixel := PixelAt(Output, 2, 0);
    Assert.AreEqual(192, Integer(Pixel.rgbReserved));
    Assert.AreEqual(110, Integer(Pixel.rgbRed));
    ComposeTerminalAlpha(Color, Background, Mask, Output, 0);
    Assert.AreEqual(0, Integer(PixelAt(Output, 0, 0).rgbReserved));
    Assert.AreEqual(255, Integer(PixelAt(Output, 1, 0).rgbReserved));
    ComposeTerminalAlpha(Color, Background, Mask, Output, 255);
    Assert.AreEqual(255, Integer(PixelAt(Output, 0, 0).rgbReserved));
    Assert.AreEqual(40, Integer(PixelAt(Output, 0, 0).rgbRed));
   Finally
    Output.Free;
    Mask.Free;
    Background.Free;
    Color.Free;
   End;
  End;

 Procedure TTerminalTests.TerminalBackgroundAlphaAndWindowControls;
  Var
   Settings     : TGuakeSettings;
   Main         : TfrmMain;
   Frame        : TfraTerminal;
   Output       : TBitmap;
   Preview      : TPngImage;
   Point        : TPoint;
   x            : Integer;
   y            : Integer;
   OpaquePixels : Integer;
  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Output   := TBitmap.Create;
   Try
    Settings.General.DefaultShell          := 'cmd';
    Settings.General.UseTrayicon           := False;
    Settings.General.UsePopup              := False;
    Settings.General.DropDownAnimation     := False;
    Settings.Keybindings.Global.ShowHide   := 'disabled';
    Settings.Keybindings.Global.ShowFocus  := 'disabled';
    Settings.Style.Background.Transparency := 40;
    Main                                   := TfrmMain.Create(Nil);
    Try
     Main.Bind(Settings);
     Main.StartTerminal;
     Main.Show;
     Main.SetBounds( -30000, 0, 700, 200);
     Main.PollTerminal(Nil);
     Frame := Main.ActiveTerminalFrame;
     Frame.Session.Buffer.FeedText(#27'[2J' + #27'[H' + #27'[?25l' + 'M' + #27'[41m '#27'[0m');
     Frame.RefreshTick(Nil);
     Frame.RenderAlpha(Output, 102);
     Assert.AreEqual(102, Integer(PixelAt(Output, 1, 1).rgbReserved), 'Background opacity');
     OpaquePixels := 0;
     For y        := 4 To 18 Do
      For x       := 4 To 10 Do
       If PixelAt(Output, x, y).rgbReserved = 255 Then
        Inc(OpaquePixels);
     Assert.IsTrue(OpaquePixels > 0, 'Foreground glyph must remain opaque');
     Assert.AreEqual(255, Integer(PixelAt(Output, 12, 5).rgbReserved), 'Explicit SGR background');
     Main.RenderWindow(Output);
     Point := Main.ScreenToClient(Frame.surface.ClientToScreen(System.Types.Point(1, 1)));
     Assert.AreEqual(102, Integer(PixelAt(Output, Point.x, Point.y).rgbReserved));
     Point := Main.ScreenToClient(Main.tabHost.ClientToScreen(System.Types.Point(2, 2)));
     Assert.AreEqual(255, Integer(PixelAt(Output, Point.x, Point.y).rgbReserved), 'Tab bar opacity');
     Assert.IsTrue(Main.tabHost.Visible);
     Assert.IsTrue((Point.x >= 0) And (Point.y >= 0) And (Point.x < Output.Width) And (Point.y < Output.Height));
     Assert.IsTrue(Integer(PixelAt(Output, Point.x, Point.y).rgbRed) + PixelAt(Output, Point.x, Point.y).rgbGreen + PixelAt(Output, Point.x, Point.y).rgbBlue > 0, 'Native tab control must be painted, not a black rectangle');
     Preview := TPngImage.Create;
     Try
      Preview.Assign(Output);
      Preview.SaveToFile(TPath.Combine(ExtractFilePath(ParamStr(0)), 'terminal-alpha-preview.png'));
     Finally
      Preview.Free;
     End;
     Main.SetFullScreen(True);
     Main.PollTerminal(Nil);
     Main.SetFullScreen(False);
     Main.PollTerminal(Nil);
     Main.RenderWindow(Output);
     Point := Main.ScreenToClient(Frame.surface.ClientToScreen(System.Types.Point(1, 1)));
     Assert.AreEqual(102, Integer(PixelAt(Output, Point.x, Point.y).rgbReserved), 'Fullscreen must not multiply opacity');
     Settings.Style.Background.Transparency := 100;
     Main.ApplySettings;
     Assert.IsTrue((GetWindowLongPtr(Main.Handle, GWL_EXSTYLE) And WS_EX_LAYERED) = 0);
     Settings.Style.Background.Transparency := 0;
     Main.ApplySettings;
     Main.PollTerminal(Nil);
     Main.RenderWindow(Output);
     Point := Main.ScreenToClient(Frame.surface.ClientToScreen(System.Types.Point(1, 1)));
     Assert.AreEqual(1, Integer(PixelAt(Output, Point.x, Point.y).rgbReserved), 'Transparent background retains mouse hit testing');
    Finally
     Main.Free;
    End;
   Finally
    Output.Free;
    Settings.Free;
   End;
  End;

 Procedure TTerminalTests.AnimatedGifDisposalAndFiniteLoop;
  Var
   Image     : TGIFImage;
   Bitmap    : TBitmap;
   Frame     : TGIFFrame;
   Animation : TAnimatedBackground;
  Begin
   Image  := TGIFImage.Create;
   Bitmap := TBitmap.Create;
   Try
    Bitmap.SetSize(2, 2);
    Bitmap.Canvas.Brush.Color := clRed;
    Bitmap.Canvas.FillRect(Rect(0, 0, 2, 2));
    Frame                                           := Image.Add(Bitmap);
    TGIFGraphicControlExtension.Create(Frame).Delay := 2;
    Bitmap.Canvas.Brush.Color                       := clBlue;
    Bitmap.Canvas.FillRect(Rect(0, 0, 2, 2));
    Frame := Image.Add(Bitmap);
    With TGIFGraphicControlExtension.Create(Frame) Do
     Begin
      Delay    := 2;
      Disposal := dmPrevious;
     End;
    Bitmap.SetSize(1, 1);
    Bitmap.Canvas.Pixels[0, 0]                      := clLime;
    Frame                                           := Image.Add(Bitmap);
    Frame.Left                                      := 1;
    Frame.Top                                       := 1;
    TGIFGraphicControlExtension.Create(Frame).Delay := 2;
    Animation                                       := TAnimatedBackground.Create(Image, clBlack);
    Try
     Assert.AreEqual(Integer(clRed), Integer(Animation.Bitmap.Canvas.Pixels[0, 0]));
     Assert.IsTrue(Animation.Advance(20));
     Assert.AreEqual(Integer(clBlue), Integer(Animation.Bitmap.Canvas.Pixels[0, 0]));
     Assert.IsTrue(Animation.Advance(20));
     Assert.AreEqual(Integer(clRed), Integer(Animation.Bitmap.Canvas.Pixels[0, 0]), 'Previous frame disposal');
     Assert.AreEqual(Integer(clLime), Integer(Animation.Bitmap.Canvas.Pixels[1, 1]), 'Partial frame offset');
     Assert.IsFalse(Animation.Advance(20), 'GIF without loop extension plays once');
     Assert.IsFalse(Animation.Advance(1000));
     Assert.AreEqual(Integer(clLime), Integer(Animation.Bitmap.Canvas.Pixels[1, 1]));
    Finally
     Animation.Free;
    End;
    TGIFAppExtNSLoop.Create(Image.Images[0]).Loops := 1;
    Animation                                      := TAnimatedBackground.Create(Image, clBlack);
    Try
     Assert.IsTrue(Animation.Advance(20));
     Assert.IsTrue(Animation.Advance(20));
     Assert.IsTrue(Animation.Advance(20), 'One repetition includes a second full playback');
     Assert.AreEqual(Integer(clRed), Integer(Animation.Bitmap.Canvas.Pixels[0, 0]));
     Assert.IsTrue(Animation.Advance(20));
     Assert.IsTrue(Animation.Advance(20));
     Assert.IsFalse(Animation.Advance(20));
    Finally
     Animation.Free;
    End;
   Finally
    Bitmap.Free;
    Image.Free;
   End;
  End;

 Procedure TTerminalTests.AnimatedGifBackgroundDelaysAndRemoval;
  Var
   Image    : TGIFImage;
   Bitmap   : TBitmap;
   Output   : TBitmap;
   Frame    : TGIFFrame;
   View     : TfraTerminal;
   Main     : TfrmMain;
   Settings : TGuakeSettings;
   FileName : String;
  Begin
   FileName := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName + '.gif');
   Image    := TGIFImage.Create;
   Bitmap   := TBitmap.Create;
   Output   := TBitmap.Create;
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Bitmap.SetSize(2, 2);
    Bitmap.Canvas.Brush.Color := clRed;
    Bitmap.Canvas.FillRect(Rect(0, 0, 2, 2));
    Frame                                           := Image.Add(Bitmap);
    TGIFGraphicControlExtension.Create(Frame).Delay := 2;
    TGIFAppExtNSLoop.Create(Frame).Loops            := 0;
    Bitmap.Canvas.Brush.Color                       := clBlue;
    Bitmap.Canvas.FillRect(Rect(0, 0, 2, 2));
    Frame                                           := Image.Add(Bitmap);
    TGIFGraphicControlExtension.Create(Frame).Delay := 8;
    Image.SaveToFile(FileName);
    Settings.General.BackgroundImageFile       := FileName;
    Settings.General.BackgroundImageLayoutMode := 3;
    Main                                       := TfrmMain.Create(Nil);
    Try
     View        := TfraTerminal.Create(Main);
     View.Parent := Main;
     View.Bind(Nil, Settings);
     Output.SetSize(10, 10);
     View.DrawBackground(Output.Canvas, Rect(0, 0, 10, 10));
     Assert.AreEqual(Integer(clRed), Integer(Output.Canvas.Pixels[5, 5]));
     Assert.IsFalse(View.AdvanceBackground(19));
     Assert.IsTrue(View.AdvanceBackground(1));
     View.DrawBackground(Output.Canvas, Rect(0, 0, 10, 10));
     Assert.AreEqual(Integer(clBlue), Integer(Output.Canvas.Pixels[5, 5]));
     Assert.IsFalse(View.AdvanceBackground(79));
     Assert.IsTrue(View.AdvanceBackground(1));
     View.DrawBackground(Output.Canvas, Rect(0, 0, 10, 10));
     Assert.AreEqual(Integer(clRed), Integer(Output.Canvas.Pixels[5, 5]));
     Settings.General.BackgroundImageFile := '';
     View.ApplySettings;
     Assert.IsFalse(View.AdvanceBackground(100));
     View.DrawBackground(Output.Canvas, Rect(0, 0, 10, 10));
     Assert.AreEqual(Integer(clBlack), Integer(Output.Canvas.Pixels[5, 5]));
    Finally
     Main.Free;
    End;
   Finally
    Settings.Free;
    Output.Free;
    Bitmap.Free;
    Image.Free;
    TFile.Delete(FileName);
   End;
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
    Settings.General.UsePopup             := False;
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
     Settings.General.UsePopup             := False;
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
    Settings.General.UsePopup             := False;
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
    Settings.General.UsePopup             := False;
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
     Assert.IsTrue(Main.miSaveTabs.Enabled);
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
  Begin
   Settings := TGuakeSettings.Create(TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Try
    Settings.General.DefaultShell          := 'cmd';
    Settings.General.UseTrayicon           := False;
    Settings.General.UsePopup              := False;
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
       Assert.IsTrue((GetWindowLongPtr(Main.Handle, GWL_EXSTYLE) And WS_EX_LAYERED) <> 0);
       Assert.IsFalse(Main.AlphaBlend, 'Constant window alpha would also fade the text');
      End;
     Settings.General.WindowOntop := Not Settings.General.WindowOntop;
     Main.ApplySettings;
     Assert.IsTrue((GetWindowLongPtr(Main.Handle, GWL_EXSTYLE) And WS_EX_LAYERED) <> 0);
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
    Settings.General.UsePopup                  := False;
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
       Main.miTrayToggle.Click;
       Sleep(60);
       Main.AnimationTick(Nil);
       Assert.IsFalse(Main.Visible, 'Terminal still visible after hiding');
       Assert.IsFalse(Main.animationTimer.Enabled);
       Assert.AreEqual(Bounds.Top, Main.Top);
       Main.SetTerminalVisible(True);
       Sleep(60);
       Main.AnimationTick(Nil);
       Assert.IsTrue(Main.Visible, 'Terminal not visible after showing');
       Assert.IsTrue((GetWindowLongPtr(Main.Handle, GWL_EXSTYLE) And WS_EX_TOOLWINDOW) <> 0, 'Main lost TOOLWINDOW');
       Assert.IsTrue((GetWindowLongPtr(Main.Handle, GWL_EXSTYLE) And WS_EX_APPWINDOW) = 0);
       If Vcl.Forms.Application.Handle <> 0 Then
        Begin
         Assert.IsTrue((GetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE) And WS_EX_APPWINDOW) = 0, 'VCL proxy gained APPWINDOW');
         Assert.IsTrue((GetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE) And WS_EX_TOOLWINDOW) <> 0, 'VCL proxy lost TOOLWINDOW');
         // VCL dialog creation attempts to remove TOOLWINDOW from its owner. The proxy guard must reject it.
         SetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE,
         (GetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE) And Not WS_EX_TOOLWINDOW) Or WS_EX_APPWINDOW);
         Assert.IsTrue((GetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE) And WS_EX_TOOLWINDOW) <> 0, 'VCL proxy lost TOOLWINDOW');
         Assert.IsTrue((GetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE) And WS_EX_APPWINDOW) = 0, 'VCL proxy gained APPWINDOW');
        End;
       Assert.AreEqual(Bounds.Top, Main.Top);
       Main.SetTerminalVisible(False);
       Sleep(60);
       Main.AnimationTick(Nil);
      End;
     Settings.General.DropDownAnimation := False;
     Main.SetTerminalVisible(True);
     Assert.IsTrue(Main.Visible, 'Terminal not visible after showing');
     Assert.IsTrue((GetWindowLongPtr(Main.Handle, GWL_EXSTYLE) And WS_EX_TOOLWINDOW) <> 0, 'Main lost TOOLWINDOW');
     Assert.IsTrue((GetWindowLongPtr(Main.Handle, GWL_EXSTYLE) And WS_EX_APPWINDOW) = 0);
     If Vcl.Forms.Application.Handle <> 0 Then
      Begin
       Assert.IsTrue((GetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE) And WS_EX_APPWINDOW) = 0, 'VCL proxy gained APPWINDOW');
       Assert.IsTrue((GetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE) And WS_EX_TOOLWINDOW) <> 0, 'VCL proxy lost TOOLWINDOW');
       // VCL dialog creation attempts to remove TOOLWINDOW from its owner. The proxy guard must reject it.
       SetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE,
       (GetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE) And Not WS_EX_TOOLWINDOW) Or WS_EX_APPWINDOW);
       Assert.IsTrue((GetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE) And WS_EX_TOOLWINDOW) <> 0, 'VCL proxy lost TOOLWINDOW');
       Assert.IsTrue((GetWindowLongPtr(Vcl.Forms.Application.Handle, GWL_EXSTYLE) And WS_EX_APPWINDOW) = 0, 'VCL proxy gained APPWINDOW');
      End;
     Assert.IsFalse(Main.animationTimer.Enabled);
     Main.SetTerminalVisible(False);
     Assert.IsFalse(Main.Visible, 'Terminal still visible after hiding');
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

/// <summary>Exercises project title scalars and UTF-8, then executes a nested JSON menu command only on click.</summary>

 Procedure TTerminalTests.ProjectYamlAndCustomCommandMenu;
  Var
   Directory  : String;
   FileName   : String;
   OutputName : String;
   Settings   : TGuakeSettings;
   Main       : TfrmMain;
   Commands   : TObjectList<TCustomCommand>;
   Deadline   : UInt64;
   JSON       : TJSONArray;
   Items      : TJSONArray;
   Args       : TJSONArray;
   Group      : TJSONObject;
   Command    : TJSONObject;
  Begin
   Assert.AreEqual('Projekt żółty', ProjectTitleFromYaml('title: Projekt żółty # uwaga'));
   Assert.AreEqual('Żółty # 1', ProjectTitleFromYaml('title: "Żółty # 1"'));
   Assert.AreEqual('d' + #39 + 'Artagnan', ProjectTitleFromYaml('title: ' + #39 + 'd' + #39#39 + 'Artagnan' + #39));
   Assert.AreEqual('pierwsza druga', ProjectTitleFromYaml('title: >-' + #10 + '  pierwsza' + #10 + '  druga'));
   Assert.AreEqual('', ProjectTitleFromYaml('title: !run command'));
   Directory := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
   ForceDirectories(Directory);
   Settings := TGuakeSettings.Create(TPath.Combine(Directory, 'guake.ini'));
   Try
    TFile.WriteAllText(TPath.Combine(Directory, '.guake.yml'), 'title: Projekt lokalny', TEncoding.UTF8);
    Assert.AreEqual('Projekt lokalny', ReadProjectTitle(Directory));
    FileName   := TPath.Combine(Directory, 'commands.json');
    OutputName := TPath.Combine(Directory, 'from-menu.txt');
    JSON       := TJSONArray.Create;
    Try
     Group := TJSONObject.Create;
     JSON.AddElement(Group);
     Group.AddPair('type', 'menu');
     Group.AddPair('description', 'Grupa');
     Items := TJSONArray.Create;
     Group.AddPair('items', Items);
     Command := TJSONObject.Create;
     Items.AddElement(Command);
     Command.AddPair('description', 'Zapisz');
     Args := TJSONArray.Create;
     Command.AddPair('cmd', Args);
     Args.AddElement(TJSONString.Create('echo'));
     Args.AddElement(TJSONString.Create('from-menu>' + QuoteProcessArgument(OutputName)));
     TFile.WriteAllText(FileName, JSON.ToJSON, TEncoding.UTF8);
    Finally
     JSON.Free;
    End;
    Commands := ReadCustomCommands(FileName);
    Try
     Assert.AreEqual(1, Commands.Count);
     Assert.IsTrue(Commands[0].IsMenu);
     Assert.AreEqual('Zapisz', Commands[0].Children[0].Description);
    Finally
     Commands.Free;
    End;
    Settings.General.DefaultShell         := 'cmd';
    Settings.General.UseTrayicon          := False;
    Settings.General.UsePopup             := False;
    Settings.General.LoadGuakeYml         := True;
    Settings.General.CustomCommandFile    := FileName;
    Settings.Keybindings.Global.ShowHide  := 'disabled';
    Settings.Keybindings.Global.ShowFocus := 'disabled';
    Main                                  := TfrmMain.Create(Nil);
    Try
     Main.Bind(Settings);
     Main.StartTerminal;
     Main.Controller.NewTab(Directory, 'cmd');
     Assert.AreEqual('Projekt lokalny', Main.Controller.ActiveSession.Title);
     Main.TerminalMenuPopup(Nil);
     Assert.IsTrue(Main.miCustomCommands.Visible);
     Assert.AreEqual(1, Main.miCustomCommands.Count);
     Assert.IsFalse(TFile.Exists(OutputName));
     Main.miCustomCommands.Items[0].Items[0].Click;
     Deadline := GetTickCount64 + 15000;
     Repeat
      Main.PollTerminal(Nil);
      If TFile.Exists(OutputName) Then
       Break;
      Sleep(10);
     Until GetTickCount64 >= Deadline;
     Assert.IsTrue(TFile.Exists(OutputName));
     Assert.AreEqual('from-menu', Trim(TFile.ReadAllText(OutputName)));
    Finally
     Main.Free;
    End;
   Finally
    Settings.Free;
    TDirectory.Delete(Directory, True);
   End;
  End;

 Procedure TTerminalTests.CaptureNotification(Sender : TObject; Const Title, Body : String);
  Begin
   fNotices.Add(Title + ': ' + Body);
  End;

/// <summary>Verifies the application startup path, enabled menus, periodic saves and user-facing notifications without displaying OS popups in tests.</summary>

 Procedure TTerminalTests.StartupRestoreAutosaveAndNotifications;
  Var
   Directory   : String;
   Saved       : String;
   SessionFile : String;
   Settings    : TGuakeSettings;
   Main        : TfrmMain;
  Begin
   Directory := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
   ForceDirectories(Directory);
   Settings := TGuakeSettings.Create(TPath.Combine(Directory, 'guake.ini'));
   fNotices := TStringList.Create;
   Try
    Settings.General.DefaultShell         := 'cmd';
    Settings.General.UseTrayicon          := False;
    Settings.General.UsePopup             := True;
    Settings.General.RestoreTabsStartup   := True;
    Settings.General.SaveTabsWhenChanged  := True;
    Settings.General.RestoreTabsNotify    := True;
    Settings.Keybindings.Global.ShowHide  := '<Control><Alt>F24';
    Settings.Keybindings.Global.ShowFocus := 'disabled';
    Main                                  := TfrmMain.Create(Nil);
    Try
     Main.OnNotification := CaptureNotification;
     Main.Bind(Settings);
     Main.StartTerminal;
     Assert.IsTrue(Pos('F24', fNotices.Text) > 0, fNotices.Text);
     Assert.IsTrue(Main.miSaveTabs.Enabled);
     Assert.IsTrue(Main.sessionTimer.Enabled);
     Main.Controller.NewTab;
     Main.Controller.ActiveTab.Name := 'Zapisana';
     Main.Controller.Split(True);
     Main.SessionSaveTick(Nil);
     Assert.IsTrue(Main.miRestoreTabs.Enabled);
     SessionFile := ChangeFileExt(Settings.FileName, '.session.json');
     Assert.IsTrue(TFile.Exists(SessionFile));
     Saved := Main.Controller.SessionState;
    Finally
     Main.Free;
    End;
    fNotices.Clear;
    Main := TfrmMain.Create(Nil);
    Try
     Main.OnNotification := CaptureNotification;
     Main.Bind(Settings);
     Main.StartTerminal;
     Assert.AreEqual(2, Main.Controller.Count);
     Assert.AreEqual(Saved, Main.Controller.SessionState);
     Assert.IsTrue(Main.miRestoreTabs.Enabled);
     Main.RestoreTabsClick(Nil);
     Assert.IsTrue(Pos('restored', fNotices.Text) > 0, fNotices.Text);
     Settings.General.UsePopup := False;
     fNotices.Clear;
     Main.RestoreTabsClick(Nil);
     Assert.AreEqual(0, fNotices.Count);
    Finally
     Main.Free;
    End;
    Settings.General.UsePopup := True;
    fNotices.Clear;
    TFile.WriteAllText(SessionFile, '{broken', TEncoding.UTF8);
    Main := TfrmMain.Create(Nil);
    Try
     Main.OnNotification := CaptureNotification;
     Main.Bind(Settings);
     Main.StartTerminal;
     Assert.AreEqual(1, Main.Controller.Count);
     Assert.IsTrue(Pos('preserved', fNotices.Text) > 0, fNotices.Text);
     Assert.IsFalse(Main.sessionTimer.Enabled);
    Finally
     Main.Free;
    End;
    Assert.AreEqual('{broken', TFile.ReadAllText(SessionFile, TEncoding.UTF8));
   Finally
    fNotices.Free;
    fNotices := Nil;
    Settings.Free;
    TDirectory.Delete(Directory, True);
   End;
  End;

/// <summary>Exercises a hidden native hook, isolated HKCU startup registration and non-repeating bell consumption.</summary>

 Procedure TTerminalTests.NativeHooksAutostartAndBell;
  Var
   Directory    : String;
   OutputName   : String;
   RegistryPath : String;
   Deadline     : UInt64;
   Registry     : TRegistry;
   Settings     : TGuakeSettings;
   Controller   : TTerminalController;
  Begin
   Directory := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
   ForceDirectories(Directory);
   OutputName   := TPath.Combine(Directory, 'hook.txt');
   RegistryPath := 'SoftwareGuakeGuakeTests' + TPath.GetRandomFileName;
   Registry     := TRegistry.Create(KEY_READ Or KEY_WRITE);
   Settings     := TGuakeSettings.Create(TPath.Combine(Directory, 'guake.ini'));
   Try
    Assert.AreEqual(Cardinal(0), StartConfiguredCommand('', Directory));
    Assert.IsTrue(StartConfiguredCommand('echo hook-data>' + QuoteProcessArgument(OutputName), Directory) > 0);
    Deadline := GetTickCount64 + 5000;
    While Not TFile.Exists(OutputName) And (GetTickCount64 < Deadline) Do
     Sleep(10);
    Assert.AreEqual('hook-data', Trim(TFile.ReadAllText(OutputName)));
    ConfigureAutoStart(True, ParamStr(0), RegistryPath);
    Registry.RootKey := HKEY_CURRENT_USER;
    Assert.IsTrue(Registry.OpenKeyReadOnly(RegistryPath));
    Assert.AreEqual(QuoteProcessArgument(ExpandFileName(ParamStr(0))) + ' --hidden', Registry.ReadString('Guake'));
    Registry.CloseKey;
    ConfigureAutoStart(False, ParamStr(0), RegistryPath);
    Assert.IsTrue(Registry.OpenKeyReadOnly(RegistryPath));
    Assert.IsFalse(Registry.ValueExists('Guake'));
    Registry.CloseKey;
    Settings.General.DefaultShell := 'cmd';
    Controller                    := TTerminalController.Create(Settings);
    Try
     Controller.NewTab;
     Controller.ActiveSession.Buffer.FeedText(#7#7);
     Assert.IsTrue(Controller.ActiveSession.TakeBell);
     Assert.IsFalse(Controller.ActiveSession.TakeBell);
    Finally
     Controller.Free;
    End;
   Finally
    Registry.CloseKey;
    Registry.DeleteKey(RegistryPath);
    Registry.Free;
    Settings.Free;
    TDirectory.Delete(Directory, True);
   End;
  End;

/// <summary>Exercises the same guarded proxy style on a real hidden DFM window, including console test hosts without an Application HWND.</summary>

 Procedure TTerminalTests.TrayOnlyStyleRejectsVclMutation;
  Var
   Window : TfrmAbout;
  Begin
   Window := TfrmAbout.Create(Nil);
   Try
    Window.HandleNeeded;
    ConfigureTrayOnlyWindow(Window.Handle, True);
    Assert.IsTrue((GetWindowLongPtr(Window.Handle, GWL_EXSTYLE) And WS_EX_TOOLWINDOW) <> 0, 'Initial proxy TOOLWINDOW');
    SetWindowLongPtr(Window.Handle, GWL_EXSTYLE,
    (GetWindowLongPtr(Window.Handle, GWL_EXSTYLE) And Not WS_EX_TOOLWINDOW) Or WS_EX_APPWINDOW);
    Assert.IsTrue((GetWindowLongPtr(Window.Handle, GWL_EXSTYLE) And WS_EX_TOOLWINDOW) <> 0, 'Proxy style guard did not reject TOOLWINDOW removal');
    Assert.IsTrue((GetWindowLongPtr(Window.Handle, GWL_EXSTYLE) And WS_EX_APPWINDOW) = 0, 'Proxy style guard allowed APPWINDOW');
   Finally
    Window.Free;
   End;
  End;

Initialization
 TDUnitX.RegisterTestFixture(TTerminalTests);

End.
