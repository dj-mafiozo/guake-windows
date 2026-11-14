{$StackFrames On}
/// <summary>Hosts the drop-down terminal window, session layout, tray commands and native global shortcuts.</summary>
Unit frmMainU;

Interface

 Uses
  System.SysUtils, System.Classes, System.Generics.Collections, Winapi.Windows, Winapi.Messages,
  Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus,
  Guake.Settings, Guake.Localization, Guake.Logging, Guake.Sessions, fraTerminalU, frmSearchU;

 Type
  TGuakeWindowCommand = (gwNewTab, gwCloseTab, gwSplitHorizontal, gwSplitVertical, gwCopy, gwPaste, gwSearch);

  TGuakeCommandEvent = Procedure(Sender : TObject; Command : TGuakeWindowCommand) Of Object;

  TfrmMain = Class(TForm)
    pollTimer         : TTimer;
    terminalHost      : TPanel;
    tabBar            : TTabControl;
    trayIcon          : TTrayIcon;
    trayMenu          : TPopupMenu;
    miPreferences     : TMenuItem;
    miAbout           : TMenuItem;
    miSeparator       : TMenuItem;
    miQuit            : TMenuItem;
    terminalMenu      : TPopupMenu;
    miNewTab          : TMenuItem;
    miCloseTab        : TMenuItem;
    miSplitHorizontal : TMenuItem;
    miSplitVertical   : TMenuItem;
    miCopy            : TMenuItem;
    miPaste           : TMenuItem;
    miSearch          : TMenuItem;
    Procedure FormCreate      (Sender : TObject);
    Procedure FormShow        (Sender : TObject);
    Procedure PreferencesClick(Sender : TObject);
    Procedure AboutClick      (Sender : TObject);
    Procedure QuitClick       (Sender : TObject);
    Procedure CommandClick    (Sender : TObject);
    Procedure TrayDblClick    (Sender : TObject);
    Procedure FormDeactivate  (Sender : TObject);
    Procedure FormClose       (Sender : TObject; Var Action : TCloseAction);
    Procedure FormDestroy     (Sender : TObject);
    Procedure PollTerminal    (Sender : TObject);
    Procedure TabChanged      (Sender : TObject);
    Procedure TabDoubleClick  (Sender : TObject);
   Private
    fController   : TTerminalController;
    fViews        : TDictionary<TTerminalSession, TfraTerminal>;
    fRootView     : TControl;
    fSearch       : TfrmSearch;
    fUpdatingTabs : Boolean;
    fPolling      : Boolean;
    fHotkeyErrors : String;
    Procedure ClearTerminalViews;
    Procedure ControllerChanged(Sender : TObject);
    Procedure RenderTerminalTree;
    Procedure UpdateTerminalTitles;
    Procedure TerminalActivated(Sender : TObject);
    Procedure TerminalShortcut (Sender : TObject; Key : Word; Shift : TShiftState; Var Handled : Boolean);
    Procedure RegisterGlobalHotkeys;
    Procedure WMHotKey         (Var Message : TMessage); Message WM_HOTKEY;
    Procedure WMTerminalAction (Var Message : TMessage); Message WM_APP + 42;
    Procedure SearchMatched    (Sender : TObject);
    Function  ConfirmClose     (Quitting : Boolean) : Boolean;
   Private
    fSettings    : TGuakeSettings;
    fLocalizer   : TGuakeLocalization;
    fLog         : TGuakeLog;
    fOnCommand   : TGuakeCommandEvent;
    fFullScreen  : Boolean;
    fSavedBounds : TRect;
    Procedure SettingsChanged(Sender : TObject);
    Procedure SetOnCommand   (Const Value : TGuakeCommandEvent);
   Public
    /// <summary>Starts the default ConPTY tab, native hotkeys and session polling.</summary>
    Procedure StartTerminal;
    /// <summary>Detaches views before destroying session-owned processes and buffers.</summary>
    Procedure StopTerminal;
    Procedure ExecuteTerminalAction(Action : TGuakeSetting);
    Function  ActiveTerminalFrame : TfraTerminal;
    Property Controller : TTerminalController Read fController;
    /// <summary>Registration failures for unavailable global shortcuts; terminal startup remains operational.</summary>
    Property HotkeyErrors : String Read fHotkeyErrors;
    Procedure Bind         (Settings : TGuakeSettings; Localizer : TGuakeLocalization = Nil; Log : TGuakeLog = Nil);
    Procedure ApplySettings;
    Procedure ToggleVisibility;
    Procedure SetFullScreen(Value : Boolean);
    Property OnCommand : TGuakeCommandEvent Read fOnCommand Write SetOnCommand;
  End;

Implementation

 Uses
  frmPreferencesU, frmAboutU, frmRenameU, frmConfirmU, dmDialogsU, fraSplitU, Guake.Keybindings, System.Math, Guake.Resources;

 Type
  TTabControlAccess = Class(TTabControl)
  End;

{$R *.dfm}

/// <summary>Connects the inherited double-click event without streaming an unpublished DFM property.</summary>

 Procedure TfrmMain.FormCreate(Sender : TObject);
  Begin
   TTabControlAccess(tabBar).OnDblClick := TabDoubleClick;
  End;

 Procedure TfrmMain.FormShow(Sender : TObject);
  Begin
   LoadGuakeTrayIcon(trayIcon.Icon);
   If (fController <> Nil) And (fController.Count = 0) Then
    fController.NewTab;
   ApplySettings;
  End;

 Procedure TfrmMain.Bind(Settings : TGuakeSettings; Localizer : TGuakeLocalization; Log : TGuakeLog);
  Begin
   If Settings = Nil Then
    Raise EArgumentNilException.Create('Settings');
   fSettings  := Settings;
   fLocalizer := Localizer;
   fLog       := Log;
   If Localizer <> Nil Then
    Begin
     miPreferences.Caption := Localizer.Text('Preferences');
     miAbout.Caption       := Localizer.Text('About');
     miQuit.Caption        := Localizer.Text('Quit');
    End;
   ApplySettings;
  End;

 Procedure TfrmMain.ApplySettings;
  Var
   Monitor : TMonitor;
   r       : TRect;
   w       : Integer;
   h       : Integer;
   x       : Integer;
   y       : Integer;
   i       : Integer;
  Begin
   If fSettings = Nil Then
    Exit;
   Monitor := Screen.PrimaryMonitor;
   If fSettings.General.MouseDisplay Then
    Monitor := Screen.MonitorFromPoint(Mouse.CursorPos)
   Else
    Begin
     i := fSettings.General.DisplayN;
     If (i >= 0) And (i < Screen.MonitorCount) Then
      Monitor := Screen.Monitors[i];
    End;
   r := Monitor.WorkareaRect;
   w := MulDiv(r.Right - r.Left, fSettings.General.WindowWidth, 100);
   h := MulDiv(r.Bottom - r.Top, fSettings.General.WindowHeight, 100);
   x := r.Left + (r.Right - r.Left - w) Div 2;
   If fSettings.General.WindowHalignment = 1 Then
    x := r.Left + fSettings.General.WindowHorizontalDisplacement
   Else If fSettings.General.WindowHalignment = 2 Then
    x := r.Right - w - fSettings.General.WindowHorizontalDisplacement;
   If fSettings.General.WindowValignment = 1 Then
    y := r.Bottom - h - fSettings.General.WindowVerticalDisplacement
   Else
    y := r.Top + fSettings.General.WindowVerticalDisplacement;
   If Not fFullScreen Then
    SetBounds(x, y, w, h);
   If fSettings.General.WindowOntop Then
    FormStyle := fsStayOnTop
   Else
    FormStyle := fsNormal;
   If fSettings.General.TabOntop Then
    tabBar.Align := alTop
   Else
    tabBar.Align  := alBottom;
   tabBar.Visible := fSettings.General.WindowTabbar And Not(fFullScreen And fSettings.General.FullscreenHideTabbar)
   And Not(fSettings.General.HideTabsIfOneTab And (tabBar.Tabs.Count <= 1));
   AlphaBlend       := fSettings.Style.Background.Transparency < 100;
   AlphaBlendValue  := MulDiv(fSettings.Style.Background.Transparency, 255, 100);
   trayIcon.Visible := (fController <> Nil) And fSettings.General.UseTrayicon;
  End;

 Procedure TfrmMain.SettingsChanged(Sender : TObject);
  Var
   Frame : TfraTerminal;
  Begin
   ApplySettings;
   If fViews <> Nil Then
    For Frame In fViews.Values Do
     Frame.ApplySettings;
   If fController <> Nil Then
    RegisterGlobalHotkeys;
  End;

 Procedure TfrmMain.PreferencesClick(Sender : TObject);
  Var
   Dialog : TfrmPreferences;
  Begin
   If fSettings = Nil Then
    Exit;
   Dialog := TfrmPreferences.Create(Self);
   Try
    Dialog.Bind(fSettings, fLocalizer, fLog);
    Dialog.OnSettingsChanged := SettingsChanged;
    Dialog.ShowModal;
   Finally
    Dialog.Free;
   End;
  End;

 Procedure TfrmMain.AboutClick(Sender : TObject);
  Var
   Dialog : TfrmAbout;
  Begin
   Dialog := TfrmAbout.Create(Self);
   Try
    Dialog.Localize(fLocalizer);
    Dialog.ShowModal;
   Finally
    Dialog.Free;
   End;
  End;

 Procedure TfrmMain.QuitClick(Sender : TObject);
  Begin
   If Not ConfirmClose(True) Then
    Exit;
   trayIcon.Visible := False;
   StopTerminal;
   Application.Terminate;
  End;

 Procedure TfrmMain.CommandClick(Sender : TObject);
  Const
   Actions : Array[0..6] Of TGuakeSetting = (gskKeybindingsLocalNewTab, gskKeybindingsLocalCloseTab,
   gskKeybindingsLocalSplitTabHorizontal, gskKeybindingsLocalSplitTabVertical,
   gskKeybindingsLocalClipboardCopy, gskKeybindingsLocalClipboardPaste, gskKeybindingsLocalSearchTerminal);
  Begin
   If fController <> Nil Then
    ExecuteTerminalAction(Actions[TMenuItem(Sender).Tag])
   Else If Assigned(fOnCommand) Then
    fOnCommand(Self, TGuakeWindowCommand(TMenuItem(Sender).Tag));
  End;

 Procedure TfrmMain.SetOnCommand(Const Value : TGuakeCommandEvent);
  Var
   i : Integer;
  Begin
   fOnCommand                     := Value;
   For i                          := 0 To terminalMenu.Items.Count - 1 Do
    terminalMenu.Items[i].Enabled := Assigned(Value);
  End;

 Procedure TfrmMain.ToggleVisibility;
  Begin
   If Visible Then
    Hide
   Else
    Begin
     Show;
     ApplySettings;
     SetForegroundWindow(Handle);
    End;
  End;

 Procedure TfrmMain.TrayDblClick(Sender : TObject);
  Begin
   ToggleVisibility;
  End;

 Procedure TfrmMain.FormDeactivate(Sender : TObject);
  Begin
   If (fSettings <> Nil) And fSettings.General.WindowLosefocus And (Screen.ActiveForm = Self) Then
    Hide;
  End;

 Procedure TfrmMain.FormClose(Sender : TObject; Var Action : TCloseAction);
  Begin
   Action := caHide;
  End;

 Procedure TfrmMain.SetFullScreen(Value : Boolean);
  Var
   r : TRect;
  Begin
   If fFullScreen = Value Then
    Exit;
   fFullScreen := Value;
   If Value Then
    Begin
     fSavedBounds := BoundsRect;
     r            := Monitor.BoundsRect;
     BoundsRect   := r;
    End
   Else
    BoundsRect := fSavedBounds;
   ApplySettings;
  End;

 Procedure TfrmMain.ClearTerminalViews;
  Var
   Frame : TfraTerminal;
  Begin
   If fViews <> Nil Then
    Begin
     For Frame In fViews.Values Do
      Frame.Bind(Nil, fSettings);
     fViews.Clear;
    End;
   FreeAndNil(fRootView);
  End;

 Procedure TfrmMain.StartTerminal;
  Begin
   If fController <> Nil Then
    Exit;
   fViews                := TDictionary<TTerminalSession, TfraTerminal>.Create;
   fController           := TTerminalController.Create(fSettings);
   fController.OnChanged := ControllerChanged;
   Try
    fController.NewTab;
    RegisterGlobalHotkeys;
    pollTimer.Enabled         := True;
    miNewTab.Enabled          := True;
    miCloseTab.Enabled        := True;
    miSplitHorizontal.Enabled := True;
    miSplitVertical.Enabled   := True;
    miCopy.Enabled            := True;
    miPaste.Enabled           := True;
    miSearch.Enabled          := True;
    ApplySettings;
    If fSettings.General.StartFullscreen Then
     SetFullScreen(True);
   Except
    StopTerminal;
    Raise;
   End;
  End;

 Procedure TfrmMain.StopTerminal;
  Begin
   If pollTimer <> Nil Then
    pollTimer.Enabled := False;
   If HandleAllocated Then
    Begin
     UnregisterHotKey(Handle, 1);
     UnregisterHotKey(Handle, 2);
    End;
   ClearTerminalViews;
   FreeAndNil(fViews);
   FreeAndNil(fController);
  End;

 Procedure TfrmMain.FormDestroy(Sender : TObject);
  Begin
   StopTerminal;
  End;

 Function TfrmMain.ActiveTerminalFrame : TfraTerminal;
  Begin
   Result := Nil;
   If (fController <> Nil) And (fController.ActiveSession <> Nil) And (fViews <> Nil) Then
    fViews.TryGetValue(fController.ActiveSession, Result);
  End;

 Procedure TfrmMain.RenderTerminalTree;

   Function Build(Node : TTerminalNode; Host : TWinControl) : TControl;
    Var
     Frame : TfraTerminal;
     Split : TfraSplit;
    Begin
     If Node.Kind = tnTerminal Then
      Begin
       Frame                   := TfraTerminal.Create(Host);
       Frame.Parent            := Host;
       Frame.Align             := alClient;
       Frame.PopupMenu         := terminalMenu;
       Frame.surface.PopupMenu := terminalMenu;
       Frame.OnActivate        := TerminalActivated;
       Frame.OnShortcut        := TerminalShortcut;
       Frame.Bind(Node.Session, fSettings);
       fViews.Add(Node.Session, Frame);
       Result := Frame;
      End
     Else
      Begin
       Split        := TfraSplit.Create(Host);
       Split.Parent := Host;
       Split.Align  := alClient;
       Split.Configure(Node.Kind = tnVertical, Node.Ratio);
       Build(Node.First, Split.firstHost);
       Build(Node.Second, Split.secondHost);
       Result := Split;
      End;
    End;
  Var
   Frame : TfraTerminal;

  Begin
   ClearTerminalViews;
   If (fController = Nil) Or (fController.ActiveTab = Nil) Then
    Exit;
   fRootView := Build(fController.ActiveTab.Root, terminalHost);
   Frame     := ActiveTerminalFrame;
   If (Frame <> Nil) And Visible And Frame.CanFocus Then
    Frame.SetFocus;
  End;

 Procedure TfrmMain.UpdateTerminalTitles;
  Var
   i     : Integer;
   Title : String;
  Begin
   If fController = Nil Then
    Exit;
   fUpdatingTabs := True;
   Try
    While tabBar.Tabs.Count > fController.Count Do
     tabBar.Tabs.Delete(tabBar.Tabs.Count - 1);
    For i := 0 To fController.Count - 1 Do
     Begin
      Title := fController.Tabs[i].Title;
      If Length(Title) > fSettings.General.MaxTabNameLength Then
       Title := Copy(Title, 1, fSettings.General.MaxTabNameLength);
      If i = tabBar.Tabs.Count Then
       tabBar.Tabs.Add(Title)
      Else If tabBar.Tabs[i] <> Title Then
       tabBar.Tabs[i] := Title;
     End;
    tabBar.TabIndex := fController.ActiveIndex;
    If fSettings.General.SetWindowTitle And (fController.ActiveTab <> Nil) Then
     Caption := fController.ActiveTab.Title
    Else
     Caption       := 'Guake!';
    tabBar.Visible := fSettings.General.WindowTabbar And Not(fFullScreen And fSettings.General.FullscreenHideTabbar)
    And Not(fSettings.General.HideTabsIfOneTab And (fController.Count <= 1));
   Finally
    fUpdatingTabs := False;
   End;
  End;

 Procedure TfrmMain.ControllerChanged(Sender : TObject);
  Begin
   RenderTerminalTree;
   UpdateTerminalTitles;
  End;

 Procedure TfrmMain.TerminalActivated(Sender : TObject);
  Begin
   If fController <> Nil Then
    fController.FocusSession(TfraTerminal(Sender).Session);
  End;

 Procedure TfrmMain.TabChanged(Sender : TObject);
  Begin
   If fUpdatingTabs Or (fController = Nil) Or (tabBar.TabIndex < 0) Then
    Exit;
   ClearTerminalViews;
   fController.SelectTab(tabBar.TabIndex);
  End;

 Procedure TfrmMain.TabDoubleClick(Sender : TObject);
  Var
   Name : String;
  Begin
   If (fController = Nil) Or (fController.ActiveTab = Nil) Then
    Exit;
   Name := fController.ActiveTab.Title;
   If TfrmRename.Execute(Self, Name, fLocalizer) Then
    Begin
     fController.ActiveTab.Name := Name;
     UpdateTerminalTitles;
    End;
  End;

 Procedure TfrmMain.PollTerminal(Sender : TObject);
  Var
   i         : Integer;
   Tab       : TTerminalTab;
   Session   : TTerminalSession;
   AllExited : Boolean;
   List      : TList<TTerminalSession>;
  Begin
   If (fController = Nil) Or fPolling Then
    Exit;
   fPolling := True;
   Try
    If fController.Poll Then
     UpdateTerminalTitles;
    If Not fSettings.ReadBool('windows', 'keep-exited-tabs', False) Then
     For i := fController.Count - 1 Downto 0 Do
      Begin
       Tab       := fController.Tabs[i];
       AllExited := True;
       List      := TList<TTerminalSession>.Create;
       Try
        Tab.Root.Collect(List);
        For Session In List Do
         AllExited := AllExited And Session.Exited;
       Finally
        List.Free;
       End;
       If AllExited Then
        Begin
         ClearTerminalViews;
         fController.CloseTab(i);
        End;
      End;
    If fController.Count = 0 Then
     Hide;
   Finally
    fPolling := False;
   End;
  End;

/// <summary>Registers each shortcut independently; unavailable shortcuts are reported without stopping sessions.</summary>

 Procedure TfrmMain.RegisterGlobalHotkeys;

   Procedure RegisterShortcut(Id : Integer; Const Shortcut : String);
    Var
     Key       : Word;
     Modifiers : Cardinal;
     Error     : Cardinal;
     Detail    : String;
    Begin
     If Not ParseAccelerator(Shortcut, Key, Modifiers) Then
      Exit;
     If RegisterHotKey(Handle, Id, Modifiers Or $4000, Key) Then
      Exit;
     Error  := GetLastError;
     Detail := Format('%s (%d): %s', [Shortcut, Error, SysErrorMessage(Error)]);
     If fHotkeyErrors <> '' Then
      fHotkeyErrors := fHotkeyErrors + sLineBreak;
     fHotkeyErrors  := fHotkeyErrors + Detail;
     OutputDebugString(PChar('Guake: global shortcut unavailable: ' + Detail));
    End;

  Begin
   UnregisterHotKey(Handle, 1);
   UnregisterHotKey(Handle, 2);
   fHotkeyErrors := '';
   RegisterShortcut(1, fSettings.Keybindings.Global.ShowHide);
   RegisterShortcut(2, fSettings.Keybindings.Global.ShowFocus);
   trayIcon.Hint := 'Guake Terminal';
   If fHotkeyErrors <> '' Then
    trayIcon.Hint := trayIcon.Hint + sLineBreak + fHotkeyErrors;
  End;

 Procedure TfrmMain.WMHotKey(Var Message : TMessage);
  Begin
   If Message.WParam = 1 Then
    ToggleVisibility
   Else If Message.WParam = 2 Then
    Begin
     If Not Visible Then
      Show;
     SetForegroundWindow(Handle);
    End;
  End;

 Procedure TfrmMain.TerminalShortcut(Sender : TObject; Key : Word; Shift : TShiftState; Var Handled : Boolean);
  Var
   Setting    : TGuakeSetting;
   Definition : TGuakeSettingDefinition;
  Begin
   For Setting := Low(TGuakeSetting) To High(TGuakeSetting) Do
    Begin
     Definition := TGuakeSettings.Definition(Setting);
     If (Definition.Section = 'keybindings.local') And MatchAccelerator(fSettings.GetValue(Setting), Key, Shift) Then
      Begin
       Handled := True;
       // Dispatch after KeyDown returns, since actions may destroy the sending terminal frame.
       PostMessage(Handle, WM_APP + 42, Ord(Setting), 0);
       Exit;
      End;
    End;
  End;

 Procedure TfrmMain.WMTerminalAction(Var Message : TMessage);
  Begin
   If Message.WParam <= Ord(High(TGuakeSetting)) Then
    ExecuteTerminalAction(TGuakeSetting(Message.WParam));
  End;

 Procedure TfrmMain.ExecuteTerminalAction(Action : TGuakeSetting);
  Var
   Frame  : TfraTerminal;
   Dialog : TdmDialogs;
   Index  : Integer;
   Name   : String;
  Begin
   If fController = Nil Then
    Exit;
   Frame := ActiveTerminalFrame;
   Case Action Of
    gskKeybindingsLocalNewTab, gskKeybindingsLocalNewTabCwd :
     Begin
      ClearTerminalViews;
      fController.NewTab;
     End;
    gskKeybindingsLocalNewTabHome :
     Begin
      ClearTerminalViews;
      fController.NewTab(GetEnvironmentVariable('USERPROFILE'));
     End;
    gskKeybindingsLocalCloseTab :
     If ConfirmClose(False) Then
      Begin
       ClearTerminalViews;
       fController.CloseTab(fController.ActiveIndex);
      End;
    gskKeybindingsLocalCloseTerminal :
     If ConfirmClose(False) Then
      Begin
       ClearTerminalViews;
       fController.CloseTerminal;
      End;
    gskKeybindingsLocalSplitTabHorizontal, gskKeybindingsLocalSplitTabVertical :
     Begin
      ClearTerminalViews;
      fController.Split(Action = gskKeybindingsLocalSplitTabVertical);
     End;
    gskKeybindingsLocalClipboardCopy :
     If Frame <> Nil Then
      Frame.CopySelection;
    gskKeybindingsLocalClipboardPaste :
     If Frame <> Nil Then
      Frame.Paste;
    gskKeybindingsLocalSelectAll :
     If Frame <> Nil Then
      Frame.SelectAll;
    gskKeybindingsLocalPreviousTab, gskKeybindingsLocalPreviousTabAlt :
     If fController.Count > 0 Then
      Begin
       ClearTerminalViews;
       fController.SelectTab((fController.ActiveIndex + fController.Count - 1) Mod fController.Count);
      End;
    gskKeybindingsLocalNextTab, gskKeybindingsLocalNextTabAlt :
     If fController.Count > 0 Then
      Begin
       ClearTerminalViews;
       fController.SelectTab((fController.ActiveIndex + 1) Mod fController.Count);
      End;
    gskKeybindingsLocalSwitchTab1..gskKeybindingsLocalSwitchTab10 :
     Begin
      Index := Ord(Action) - Ord(gskKeybindingsLocalSwitchTab1);
      If Index < fController.Count Then
       Begin
        ClearTerminalViews;
        fController.SelectTab(Index);
       End;
     End;
    gskKeybindingsLocalSwitchTabLast :
     If fController.Count > 0 Then
      Begin
       ClearTerminalViews;
       fController.SelectTab(fController.Count - 1);
      End;
    gskKeybindingsLocalMoveTabLeft :
     If fController.ActiveIndex > 0 Then
      fController.MoveTab(fController.ActiveIndex, fController.ActiveIndex - 1);
    gskKeybindingsLocalMoveTabRight :
     If fController.ActiveIndex < fController.Count - 1 Then
      fController.MoveTab(fController.ActiveIndex, fController.ActiveIndex + 1);
    gskKeybindingsLocalRenameCurrentTab :
     TabDoubleClick(Nil);
    gskKeybindingsLocalResetTerminal :
     If fController.ActiveSession <> Nil Then
      fController.ActiveSession.Buffer.Reset;
    gskKeybindingsLocalToggleFullscreen :
     SetFullScreen(Not fFullScreen);
    gskKeybindingsLocalToggleHideOnLoseFocus :
     Begin
      fSettings.General.WindowLosefocus := Not fSettings.General.WindowLosefocus;
      fSettings.Save;
     End;
    gskKeybindingsLocalIncreaseHeight, gskKeybindingsLocalDecreaseHeight :
     Begin
      If Action = gskKeybindingsLocalIncreaseHeight Then
       Index := 2
      Else
       Index                         := -2;
      fSettings.General.WindowHeight := EnsureRange(fSettings.General.WindowHeight + Index, 1, 100);
      fSettings.Save;
      ApplySettings;
     End;
    gskKeybindingsLocalIncreaseTransparency, gskKeybindingsLocalDecreaseTransparency :
     Begin
      If Action = gskKeybindingsLocalIncreaseTransparency Then
       Index := -5
      Else
       Index                                  := 5;
      fSettings.Style.Background.Transparency := EnsureRange(fSettings.Style.Background.Transparency + Index, 0, 100);
      fSettings.Save;
      ApplySettings;
     End;
    gskKeybindingsLocalToggleTransparency :
     Begin
      If fSettings.Style.Background.Transparency = 100 Then
       fSettings.Style.Background.Transparency := 90
      Else
       fSettings.Style.Background.Transparency := 100;
      ApplySettings;
     End;
    gskKeybindingsLocalSearchTerminal :
     If fController.ActiveSession <> Nil Then
      Begin
       If fSearch = Nil Then
        fSearch := TfrmSearch.Create(Self);
       fSearch.Localize(fLocalizer);
       fSearch.SetContent(fController.ActiveSession.Buffer.Text);
       fSearch.OnMatch := SearchMatched;
       fSearch.Show;
       fSearch.edtSearch.SetFocus;
      End;
    gskKeybindingsLocalQuit :
     QuitClick(Nil);
   End;
  End;

 Procedure TfrmMain.SearchMatched(Sender : TObject);
  Var
   Frame : TfraTerminal;
  Begin
   Frame := ActiveTerminalFrame;
   If Frame <> Nil Then
    Frame.HighlightText(fSearch.MatchStart, fSearch.MatchLength);
  End;

 Function TfrmMain.ConfirmClose(Quitting : Boolean) : Boolean;
  Var
   Dialog    : TfrmConfirm;
   Processes : TStringList;
   Session   : TTerminalSession;
   TabCount  : Integer;
  Begin
   Result := True;
   If (fController = Nil) Or (fController.Count = 0) Then
    Exit;
   If Quitting Then
    Begin
     If Not fSettings.General.PromptOnQuit And (fSettings.General.PromptOnCloseTab <> 2) Then
      Exit;
     TabCount := fController.Count;
    End
   Else
    Begin
     If fSettings.General.PromptOnCloseTab = 0 Then
      Exit;
     TabCount := -1;
    End;
   Processes := TStringList.Create;
   Try
    If Quitting Then
     Begin
      For Session In fController.Sessions Do
       If Not Session.Exited Then
        Processes.Add(Session.Title);
     End
    Else If (fController.ActiveSession <> Nil) And Not fController.ActiveSession.Exited Then
     Processes.Add(fController.ActiveSession.Title);
    If (Processes.Count = 0) And Not Quitting And (fSettings.General.PromptOnCloseTab = 1) Then
     Exit;
    Dialog := TfrmConfirm.Create(Self);
    Try
     Dialog.ConfigureQuit(Processes, TabCount, 1, fLocalizer);
     Result := Dialog.ShowModal = mrYes;
    Finally
     Dialog.Free;
    End;
   Finally
    Processes.Free;
   End;
  End;

End.
