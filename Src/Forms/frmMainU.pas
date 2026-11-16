{$StackFrames On}
/// <summary>Hosts the drop-down terminal window, session layout, tray commands and native global shortcuts.</summary>
Unit frmMainU;

Interface

 Uses
  System.SysUtils, System.Classes, System.Generics.Collections, Winapi.Windows, Winapi.Messages,
  Vcl.Graphics, Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons,
  Guake.QuickOpen, Guake.IPC, Guake.Settings, Guake.Localization, Guake.Logging, Guake.Sessions, fraTerminalU, frmSearchU;

 Type
  TGuakeWindowCommand = (gwNewTab, gwCloseTab, gwSplitHorizontal, gwSplitVertical, gwCopy, gwPaste, gwSearch);

  TGuakeNotificationEvent = Procedure(Sender : TObject; Const Title, Body : String) Of Object;

  TGuakeCommandEvent = Procedure(Sender : TObject; Command : TGuakeWindowCommand) Of Object;

  TfrmMain = Class(TForm)
    miTrayToggle          : TMenuItem;
    notificationTimer     : TTimer;
    miCustomCommands      : TMenuItem;
    sessionTimer          : TTimer;
    animationTimer        : TTimer;
    pollTimer             : TTimer;
    terminalHost          : TPanel;
    tabBar                : TTabControl;
    tabHost               : TPanel;
    trayIcon              : TTrayIcon;
    trayMenu              : TPopupMenu;
    miPreferences         : TMenuItem;
    miAbout               : TMenuItem;
    miSeparator           : TMenuItem;
    miQuit                : TMenuItem;
    terminalMenu          : TPopupMenu;
    miNewTab              : TMenuItem;
    miCloseTab            : TMenuItem;
    miSplitHorizontal     : TMenuItem;
    miSplitVertical       : TMenuItem;
    miCopy                : TMenuItem;
    miPaste               : TMenuItem;
    miSearch              : TMenuItem;
    tabMenu               : TPopupMenu;
    miFullscreen          : TMenuItem;
    miCloseTerminal       : TMenuItem;
    miSaveTerminal        : TMenuItem;
    miResetTerminal       : TMenuItem;
    miTerminalSeparator1  : TMenuItem;
    miTerminalSeparator2  : TMenuItem;
    miTerminalSeparator3  : TMenuItem;
    miTerminalSeparator4  : TMenuItem;
    miTerminalSeparator5  : TMenuItem;
    miTerminalSeparator6  : TMenuItem;
    miOpenLink            : TMenuItem;
    miSearchWeb           : TMenuItem;
    miQuickOpen           : TMenuItem;
    miTerminalPreferences : TMenuItem;
    miTerminalAbout       : TMenuItem;
    miTerminalQuit        : TMenuItem;
    miRenameTab           : TMenuItem;
    miRestoreTabColors    : TMenuItem;
    btnAddTab             : TSpeedButton;
    btnTabList            : TSpeedButton;
    tabListMenu           : TPopupMenu;
    miTrayNewTab          : TMenuItem;
    miSaveTabs            : TMenuItem;
    miRestoreTabs         : TMenuItem;
    miTraySeparator1      : TMenuItem;
    miTraySeparator2      : TMenuItem;
    miNewShellTab         : TMenuItem;
    miNewZsh              : TMenuItem;
    miNewBash             : TMenuItem;
    miNewCmd              : TMenuItem;
    miNewPowerShell       : TMenuItem;
    shellMenu             : TPopupMenu;
    miPopupZsh            : TMenuItem;
    miPopupBash           : TMenuItem;
    miPopupCmd            : TMenuItem;
    miPopupPowerShell     : TMenuItem;
    Procedure DrawTerminalTab    (Control : TCustomTabControl; TabIndex : Integer; Const Rect : TRect; Active : Boolean);
    Procedure TabMouseDown       (Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
    Procedure TabMouseMove       (Sender : TObject; Shift : TShiftState; x, y : Integer);
    Procedure ResetTabColorsClick(Sender : TObject);
    Procedure QuickOpenClick     (Sender : TObject);
    Procedure NotificationExpired(Sender : TObject);
    Procedure CustomCommandClick (Sender : TObject);
    Procedure SaveTabsClick      (Sender : TObject);
    Procedure RestoreTabsClick   (Sender : TObject);
    Procedure SessionSaveTick    (Sender : TObject);
    Procedure LinkActionClick    (Sender : TObject);
    Procedure AnimationTick      (Sender : TObject);
    Procedure ShellTabClick      (Sender : TObject);
    Procedure AddTabClick        (Sender : TObject);
    Procedure TabListClick       (Sender : TObject);
    Procedure TabListPopup       (Sender : TObject);
    Procedure SelectListedTab    (Sender : TObject);
    Procedure TerminalActionClick(Sender : TObject);
    Procedure TerminalMenuPopup  (Sender : TObject);
    Procedure TabMenuPopup       (Sender : TObject);
    Procedure FormCreate         (Sender : TObject);
    Procedure FormShow           (Sender : TObject);
    Procedure PreferencesClick   (Sender : TObject);
    Procedure AboutClick         (Sender : TObject);
    Procedure QuitClick          (Sender : TObject);
    Procedure CommandClick       (Sender : TObject);
    Procedure TrayDblClick       (Sender : TObject);
    Procedure FormDeactivate     (Sender : TObject);
    Procedure FormClose          (Sender : TObject; Var Action : TCloseAction);
    Procedure FormDestroy        (Sender : TObject);
    Procedure PollTerminal       (Sender : TObject);
    Procedure TabChanged         (Sender : TObject);
    Procedure TabDoubleClick     (Sender : TObject);
   Private
    fLastTabActivity : String;
    fPendingTabClose : TQueue<String>;
    fHoverTab        : Integer;
    fLayeredDirty    : Boolean;
    fComposing       : Boolean;
    fChromeSurface   : TBitmap;
    fWindowSurface   : TBitmap;
    fTerminalSurface : TBitmap;
    Procedure VisualChanged   (Sender : TObject);
    Procedure PaintTerminalTab(Canvas : TCanvas; Index : Integer; Const Bounds : TRect; Active : Boolean);
    Procedure PresentLayeredWindow;
    Procedure WMCloseTabButton(Var Message : TMessage); Message WM_APP + 44;
   Private
    fPopupQuickOpen     : TQuickOpenTarget;
    fPopupQuickSession  : String;
    fPopupLink          : String;
    fNotificationQueue  : TQueue<String>;
    fNotificationWindow : HWND;
    fNotificationAdded  : Boolean;
    fOnNotification     : TGuakeNotificationEvent;
    fAutoStartState     : Boolean;
    fInstance           : TGuakeInstance;
    fController         : TTerminalController;
    fViews              : TDictionary<TTerminalSession, TfraTerminal>;
    fRootView           : TControl;
    fSearch             : TfrmSearch;
    fUpdatingTabs       : Boolean;
    fPolling            : Boolean;
    fHotkeyErrors       : String;
    Procedure TerminalCtrlClick(Sender : TObject; x, y : Integer; Var Handled : Boolean);
    Function  QuickOpenTarget  (Frame : TfraTerminal; x, y : Integer; Out Target : TQuickOpenTarget) : Boolean;
    /// <summary>Executes an editor command only for a previously resolved, existing local file.</summary>
    Procedure OpenQuickTarget      (Frame : TfraTerminal; Const Target : TQuickOpenTarget);
    Procedure ExecuteConfiguredHook(Const Value : String);
    Procedure ShowNotification     (Const Text : String);
    Procedure ShowNextNotification;
    Procedure DeleteNotificationIcon;
    Procedure WMNotification       (Var Message : TMessage); Message WM_APP + 43;
    Function  StartupMessage                            : String;
    Procedure LoadCustomCommands;
    Procedure ClearTerminalViews;
    Procedure ControllerChanged    (Sender : TObject);
    Procedure RenderTerminalTree;
    Procedure UpdateTerminalTitles;
    Procedure TerminalActivated    (Sender : TObject);
    Procedure TerminalShortcut     (Sender : TObject; Key : Word; Shift : TShiftState; Var Handled : Boolean);
    Procedure RegisterGlobalHotkeys;
    Procedure WMHotKey             (Var Message : TMessage); Message WM_HOTKEY;
    Procedure WMTerminalAction     (Var Message : TMessage); Message WM_APP + 42;
    Procedure OpenExternalLink     (Const Value : String);
    Procedure SearchMatched        (Sender : TObject);
    Procedure ExitApplication      (AskConfirmation : Boolean);
    Function  ConfirmClose         (Quitting : Boolean) : Boolean;
   Private
    fSettings           : TGuakeSettings;
    fLocalizer          : TGuakeLocalization;
    fLog                : TGuakeLog;
    fOnCommand          : TGuakeCommandEvent;
    fFullScreen         : Boolean;
    fAnimating          : Boolean;
    fAnimationTarget    : Boolean;
    fAnimationProgress  : Double;
    fAnimationTick      : UInt64;
    fAnimationBounds    : TRect;
    fSessionSaveBlocked : Boolean;
    fLastSavedState     : String;
    fSavedBounds        : TRect;
    Procedure ApplyOpacity;
    Function  SessionFileName : String;
    Procedure SettingsChanged(Sender : TObject);
    Procedure SetOnCommand   (Const Value : TGuakeCommandEvent);
   Protected
    Procedure CreateParams(Var Params : TCreateParams); Override;
    Procedure CreateWnd; Override;
    Procedure WndProc     (Var Message : TMessage); Override;
   Public
    /// <summary>Starts the default ConPTY tab, native hotkeys and session polling.</summary>
    /// <summary>Executes an accepted command on the VCL thread.</summary>
    Procedure ExecuteIPCCommand(Const Command : String);
    /// <summary>The DPR owns the single-instance transport; the form borrows it.</summary>
    Property Instance : TGuakeInstance Read fInstance Write fInstance;
    Procedure StartTerminal;
    /// <summary>Detaches views before destroying session-owned processes and buffers.</summary>
    Procedure StopTerminal;
    Procedure ExecuteTerminalAction(Action : TGuakeSetting);
    Function  ActiveTerminalFrame : TfraTerminal;
    Property Controller : TTerminalController Read fController;
    /// <summary>Registration failures for unavailable global shortcuts; terminal startup remains operational.</summary>
    Property HotkeyErrors : String Read fHotkeyErrors;
    Procedure Bind(Settings : TGuakeSettings; Localizer : TGuakeLocalization = Nil; Log : TGuakeLog = Nil);
    Procedure ApplySettings;
    /// <summary>Builds the native UI with opaque controls and premultiplied terminal background alpha.</summary>
    Procedure RenderWindow(Destination : TBitmap);
    /// <summary>Close-button bounds in native tab-bar coordinates.</summary>
    Function  TabCloseRect      (Index : Integer) : TRect;
    Procedure SetTerminalVisible(Value : Boolean);
    Procedure ToggleVisibility;
    Procedure SetFullScreen     (Value : Boolean);
    Property OnNotification : TGuakeNotificationEvent Read fOnNotification Write fOnNotification;
    Property OnCommand      : TGuakeCommandEvent Read fOnCommand Write SetOnCommand;
  End;

Implementation

 Uses
  Guake.Composition, Guake.Colors, Vcl.Themes, Winapi.CommCtrl, Guake.Shells, Guake.WindowsIntegration, Guake.ProjectConfig, Guake.Links, Winapi.ShellAPI, System.NetEncoding, System.IOUtils, System.JSON, frmPreferencesU, frmAboutU, frmRenameU, frmConfirmU, dmDialogsU, fraSplitU, Guake.Keybindings, System.Math, Guake.Resources;

 Type
  TTabControlAccess = Class(TTabControl)
  End;

/// <summary>Data-dependent menu row that keeps tab identity separate from user-visible hints.</summary>

  TTabListItem = Class(TMenuItem)
   Public
    TabId : String;
  End;

/// <summary>A menu entry created from user command data, rather than static form layout.</summary>

  TCustomCommandItem = Class(TMenuItem)
   Public
    CommandText : String;
  End;

{$R *.dfm}

/// <summary>Connects the inherited double-click event without streaming an unpublished DFM property.</summary>

 Procedure TfrmMain.FormCreate(Sender : TObject);
  Begin
   fPendingTabClose                     := TQueue<String>.Create;
   fHoverTab                            := -1;
   TTabControlAccess(tabBar).OnDblClick := TabDoubleClick;
  End;

 Procedure TfrmMain.FormShow(Sender : TObject);
  Begin
   LoadGuakeTrayIcon(trayIcon.Icon);
   If (fController <> Nil) And (fController.Count = 0) Then
    fController.NewTab;
   ApplySettings;
   PresentLayeredWindow;
   If fSettings <> Nil Then
    ExecuteConfiguredHook(fSettings.Hooks.Show);
  End;

 Procedure TfrmMain.Bind(Settings : TGuakeSettings; Localizer : TGuakeLocalization; Log : TGuakeLog);
  Begin
   If Settings = Nil Then
    Raise EArgumentNilException.Create('Settings');
   fSettings       := Settings;
   fAutoStartState := Settings.General.StartAtLogin;
   fLocalizer      := Localizer;
   fLog            := Log;
   If Localizer <> Nil Then
    Begin
     miPreferences.Caption         := Localizer.Text('Preferences');
     miCopy.Caption                := Localizer.Text('Copy');
     miPaste.Caption               := Localizer.Text('Paste');
     miFullscreen.Caption          := Localizer.Text('Toggle Fullscreen');
     miSplitHorizontal.Caption     := Localizer.Text('Split ―');
     miSplitVertical.Caption       := Localizer.Text('Split |');
     miCloseTerminal.Caption       := Localizer.Text('Close terminal');
     miSaveTerminal.Caption        := Localizer.Text('Save content...');
     miResetTerminal.Caption       := Localizer.Text('Reset terminal');
     miOpenLink.Caption            := Localizer.Text('Open link...');
     miSearchWeb.Caption           := Localizer.Text('Search on Web');
     miQuickOpen.Caption           := Localizer.Text('Quick Open...');
     miTerminalPreferences.Caption := Localizer.Text('Preferences');
     miTerminalAbout.Caption       := Localizer.Text('About');
     miTerminalQuit.Caption        := Localizer.Text('Quit');
     miNewTab.Caption              := Localizer.Text('New tab');
     miNewShellTab.Caption         := Localizer.Text('New tab with shell');
     miTrayNewTab.Caption          := Localizer.Text('New tab');
     miRenameTab.Caption           := Localizer.Text('Rename');
     miRestoreTabColors.Caption    := Localizer.Text('Reset custom colors');
     miCloseTab.Caption            := Localizer.Text('Close');
     miSaveTabs.Caption            := Localizer.Text('Save Tabs');
     miRestoreTabs.Caption         := Localizer.Text('Restore Tabs');

     miTrayToggle.Caption     := Localizer.Text('Show');
     miTrayToggle.Caption     := Localizer.Text('Show');
     miCustomCommands.Caption := Localizer.Text('Custom commands');
     miAbout.Caption          := Localizer.Text('About');
     miQuit.Caption           := Localizer.Text('Quit');
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
   If Not fFullScreen And Not fAnimating Then
    SetBounds(x, y, w, h);
   If fSettings.General.WindowOntop Then
    FormStyle := fsStayOnTop
   Else
    FormStyle := fsNormal;
   If fSettings.General.TabOntop Then
    tabHost.Align := alTop
   Else
    tabHost.Align  := alBottom;
   tabHost.Visible := fSettings.General.WindowTabbar And Not(fFullScreen And fSettings.General.FullscreenHideTabbar)
   And Not(fSettings.General.HideTabsIfOneTab And (tabBar.Tabs.Count <= 1));
   If fSettings.General.TabCloseButtons Then
    SendMessage(tabBar.Handle, TCM_SETPADDING, 0, MakeLParam(MulDiv(18, PixelsPerInch, 96), 3))
   Else
    SendMessage(tabBar.Handle, TCM_SETPADDING, 0, MakeLParam(MulDiv(6, PixelsPerInch, 96), 3));
   tabBar.Invalidate;
   ApplyOpacity;
   trayIcon.Visible := (fController <> Nil) And fSettings.General.UseTrayicon;
  End;

/// <summary>Selects per-pixel background composition after settings changes and HWND recreation.</summary>

 Procedure TfrmMain.ApplyOpacity;
  Var
   Style : NativeInt;
  Begin
   If fSettings = Nil Then
    Exit;
   // VCL AlphaBlend uses constant alpha for the WHOLE window and conflicts with UpdateLayeredWindow.
   AlphaBlend := False;
   If HandleAllocated Then
    Begin
     Style := GetWindowLongPtr(Handle, GWL_EXSTYLE);
     If fSettings.Style.Background.Transparency < 100 Then
      Style := Style Or WS_EX_LAYERED
     Else
      Style := Style And Not WS_EX_LAYERED;
     SetWindowLongPtr(Handle, GWL_EXSTYLE, Style);
    End;
   fLayeredDirty := True;
   Invalidate;
  End;

 Procedure TfrmMain.VisualChanged(Sender : TObject);
  Begin
   fLayeredDirty := True;
  End;

 Procedure TfrmMain.WndProc(Var Message : TMessage);
  Begin
   If Not fComposing And ((Message.Msg = WM_PAINT) Or (Message.Msg = WM_SIZE) Or
   (Message.Msg = WM_WINDOWPOSCHANGED) Or (Message.Msg = WM_SHOWWINDOW)) Then
    fLayeredDirty := True;
   Inherited;
  End;

 Procedure TfrmMain.RenderWindow(Destination : TBitmap);
  Var
   Frame        : TfraTerminal;
   Position     : TPoint;
   y            : Integer;
   Left         : Integer;
   Right        : Integer;
   Top          : Integer;
   Bottom       : Integer;
   SourceBase   : PByte;
   TargetBase   : PByte;
   SourceStride : NativeInt;
   TargetStride : NativeInt;
   Source       : PByte;
   Target       : PByte;
   Opacity      : Byte;

   Procedure PaintNative(Control : TWinControl);
    Var
     Origin : TPoint;
     Index  : Integer;
     Saved  : Integer;
    Begin
     Origin := ScreenToClient(Control.Parent.ClientToScreen(Point(Control.Left, Control.Top)));
     If fChromeSurface = Nil Then
      fChromeSurface            := TBitmap.Create;
     fChromeSurface.PixelFormat := pf32bit;
     fChromeSurface.SetSize(Control.Width, Control.Height);
     fChromeSurface.Canvas.Brush.Style := bsSolid;
     fChromeSurface.Canvas.Brush.Color := clBtnFace;
     fChromeSurface.Canvas.FillRect(Rect(0, 0, Control.Width, Control.Height));
     // Give native theme and owner-draw code a local DC, without the parent snapshot's viewport/clip state.
     Saved := SaveDC(fChromeSurface.Canvas.Handle);
     Try
      Control.Perform(WM_PRINTCLIENT, fChromeSurface.Canvas.Handle, PRF_CLIENT Or PRF_ERASEBKGND);
     Finally
      RestoreDC(fChromeSurface.Canvas.Handle, Saved);
      fChromeSurface.Canvas.Refresh;
     End;
     If (Control = tabBar) And tabBar.OwnerDraw Then
      For Index := 0 To tabBar.Tabs.Count - 1 Do
       PaintTerminalTab(fChromeSurface.Canvas, Index, tabBar.TabRect(Index), Index = tabBar.TabIndex);
     BitBlt(Destination.Canvas.Handle, Origin.x, Origin.y, Control.Width, Control.Height,
     fChromeSurface.Canvas.Handle, 0, 0, SRCCOPY);
    End;

  Begin
   If fComposing Or (ClientWidth <= 0) Or (ClientHeight <= 0) Then
    Exit;
   fComposing := True;
   Try
    Destination.PixelFormat := pf32bit;
    Destination.SetSize(ClientWidth, ClientHeight);
    // Keep the premultiplied flag: resetting to afIgnored unpremultiplies every old pixel only to overwrite it.
    Destination.AlphaFormat := afPremultiplied;
    If fViews <> Nil Then
     For Frame In fViews.Values Do
      Frame.CaptureBackgroundOnly  := True;
    Destination.Canvas.Brush.Color := Color;
    Destination.Canvas.FillRect(ClientRect);
    PaintTo(Destination.Canvas.Handle, 0, 0);
    // PaintTo uses WM_PAINT with a DC, which omits native common-control content.
    If tabHost.Visible Then
     Begin
      PaintNative(tabHost);
      PaintNative(tabBar);
     End;
    If fViews <> Nil Then
     For Frame In fViews.Values Do
      If Frame.Visible And Frame.scroll.Visible Then
       PaintNative(Frame.scroll);
    MakeBitmapOpaque(Destination);
    TargetBase   := Destination.ScanLine[0];
    TargetStride := 0;
    If Destination.Height > 1 Then
     TargetStride := NativeInt(Destination.ScanLine[1]) - NativeInt(TargetBase);
    If fTerminalSurface = Nil Then
     fTerminalSurface := TBitmap.Create;
    Opacity           := Max(1, MulDiv(fSettings.Style.Background.Transparency, 255, 100));
    If fViews <> Nil Then
     For Frame In fViews.Values Do
      If Frame.Visible And (Frame.surface.Width > 0) And (Frame.surface.Height > 0) Then
       Begin
        Position := ScreenToClient(Frame.surface.ClientToScreen(Point(0, 0)));
        Frame.RenderAlpha(fTerminalSurface, Opacity);
        SourceBase   := fTerminalSurface.ScanLine[0];
        SourceStride := 0;
        If fTerminalSurface.Height > 1 Then
         SourceStride := NativeInt(fTerminalSurface.ScanLine[1]) - NativeInt(SourceBase);
        Left          := Max(0, Position.x);
        Right         := Min(Destination.Width, Position.x + fTerminalSurface.Width);
        Top           := Max(0, Position.y);
        Bottom        := Min(Destination.Height, Position.y + fTerminalSurface.Height);
        For y         := Top To Bottom - 1 Do
         If Right > Left Then
          Begin
           Source := PByte(NativeInt(SourceBase) + (y - Position.y) * SourceStride);
           Inc(Source, (Left - Position.x) * SizeOf(TRGBQuad));
           Target := PByte(NativeInt(TargetBase) + y * TargetStride);
           Inc(Target, Left * SizeOf(TRGBQuad));
           Move(Source^, Target^, (Right - Left) * SizeOf(TRGBQuad));
          End;
       End;
   Finally
    If fViews <> Nil Then
     For Frame In fViews.Values Do
      Frame.CaptureBackgroundOnly := False;
    fComposing                    := False;
   End;
  End;

 Procedure TfrmMain.PresentLayeredWindow;
  Var
   Position : TPoint;
   Origin   : TPoint;
   Size     : TSize;
   Blend    : TBlendFunction;
  Begin
   If Not Visible Or Not fLayeredDirty Or fComposing Or (fSettings = Nil) Or
   (fSettings.Style.Background.Transparency = 100) Then
    Exit;
   If fWindowSurface = Nil Then
    fWindowSurface := TBitmap.Create;
   RenderWindow(fWindowSurface);
   Position                  := Point(Left, Top);
   Origin                    := Point(0, 0);
   Size.cx                   := ClientWidth;
   Size.cy                   := ClientHeight;
   Blend.BlendOp             := AC_SRC_OVER;
   Blend.BlendFlags          := 0;
   Blend.SourceConstantAlpha := 255;
   Blend.AlphaFormat         := AC_SRC_ALPHA;
   Win32Check(UpdateLayeredWindow(Handle, 0, @Position, @Size, fWindowSurface.Canvas.Handle,
   @Origin, 0, @Blend, ULW_ALPHA));
   fLayeredDirty := False;
  End;

/// <summary>Keeps the terminal owned by the tray-only VCL proxy across HWND recreation.</summary>

 Procedure TfrmMain.CreateParams(Var Params : TCreateParams);
  Begin
   Inherited;
   Params.ExStyle   := (Params.ExStyle Or WS_EX_TOOLWINDOW) And Not WS_EX_APPWINDOW;
   Params.WndParent := Application.Handle;
  End;

 Procedure TfrmMain.CreateWnd;
  Begin
   Inherited;
   ConfigureTrayOnlyWindow(Handle);
   ConfigureTrayOnlyWindow(Application.Handle, True);
   ApplyOpacity;
  End;

 Procedure TfrmMain.SettingsChanged(Sender : TObject);
  Var
   Frame : TfraTerminal;
  Begin
   If fAutoStartState <> fSettings.General.StartAtLogin Then
    Begin
     ConfigureAutoStart(fSettings.General.StartAtLogin, ParamStr(0));
     fAutoStartState := fSettings.General.StartAtLogin;
    End;

   ApplySettings;
   If fViews <> Nil Then
    For Frame In fViews.Values Do
     Frame.ApplySettings;
   If fController <> Nil Then
    RegisterGlobalHotkeys;
   PresentLayeredWindow;
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
   ExitApplication(True);
  End;

/// <summary>Stops all terminals through the normal session-save path and terminates the VCL message loop.</summary>

 Procedure TfrmMain.ExitApplication(AskConfirmation : Boolean);
  Begin
   If AskConfirmation And Not ConfirmClose(True) Then
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
  Begin
   fOnCommand                := Value;
   miNewTab.Enabled          := Assigned(Value);
   miCloseTab.Enabled        := Assigned(Value);
   miSplitHorizontal.Enabled := Assigned(Value);
   miSplitVertical.Enabled   := Assigned(Value);
   miCopy.Enabled            := Assigned(Value);
   miPaste.Enabled           := Assigned(Value);
   miSearch.Enabled          := Assigned(Value);
  End;

/// <summary>Updates context actions from the active session without enabling unimplemented integrations.</summary>

/// <summary>Uses the same action dispatch for shell-specific menu items and keyboard shortcuts.</summary>

 Procedure TfrmMain.ShellTabClick(Sender : TObject);
  Begin
   ExecuteTerminalAction(TGuakeSetting(Ord(gskKeybindingsLocalNewTabZsh) + TMenuItem(Sender).Tag));
  End;

 Procedure TfrmMain.AddTabClick(Sender : TObject);
  Begin
   ExecuteTerminalAction(gskKeybindingsLocalNewTab);
  End;

 Procedure TfrmMain.TabListClick(Sender : TObject);
  Var
   Point : TPoint;
  Begin
   Point.x := 0;
   Point.y := btnTabList.Height;
   Point   := btnTabList.ClientToScreen(Point);
   tabListMenu.Popup(Point.x, Point.y);
  End;

/// <summary>Builds only the data-dependent tab list and selects by stable tab identity.</summary>

 Procedure TfrmMain.TabListPopup(Sender : TObject);
  Var
   Index : Integer;
   Item  : TTabListItem;
  Begin
   tabListMenu.Items.Clear;
   If fController = Nil Then
    Exit;
   For Index := 0 To fController.Count - 1 Do
    Begin
     Item           := TTabListItem.Create(tabListMenu);
     Item.Caption   := StringReplace(fController.Tabs[Index].Title, '&', '&&', [rfReplaceAll]);
     Item.TabId     := fController.Tabs[Index].Id;
     Item.RadioItem := True;
     Item.Checked   := Index = fController.ActiveIndex;
     Item.OnClick   := SelectListedTab;
     tabListMenu.Items.Add(Item);
    End;
  End;

 Procedure TfrmMain.SelectListedTab(Sender : TObject);
  Var
   Index : Integer;
  Begin
   If fController = Nil Then
    Exit;
   For Index := 0 To fController.Count - 1 Do
    If fController.Tabs[Index].Id = TTabListItem(Sender).TabId Then
     Begin
      fController.SelectTab(Index);
      Exit;
     End;
  End;

/// <summary>Opens supported URI schemes through the Windows default application.</summary>

 Procedure TfrmMain.OpenExternalLink(Const Value : String);
  Var
   Link : String;
   Code : NativeInt;
  Begin
   Link := NormalizeTerminalLink(Value);
   If Link = '' Then
    Exit;
   Code := NativeInt(ShellExecute(Handle, 'open', PChar(Link), Nil, Nil, SW_SHOWNORMAL));
   If Code <= 32 Then
    Raise EOSError.CreateFmt('Cannot open link (%d): %s', [Code, Link]);
  End;

 Procedure TfrmMain.LinkActionClick(Sender : TObject);
  Begin
   If Sender = miSearchWeb Then
    ExecuteTerminalAction(gskKeybindingsLocalSearchOnWeb)
   Else
    OpenExternalLink(fPopupLink);
  End;

/// <summary>Builds the original startup message without GTK markup.</summary>

 Function TfrmMain.StartupMessage : String;
  Var
   LabelText : String;
  Begin
   LabelText := fSettings.Keybindings.Global.ShowHide;
   If (LabelText = '') Or SameText(LabelText, 'disabled') Then
    Begin
     Result := 'Guake is now running. Assign an activation shortcut in Preferences.';
     If fLocalizer <> Nil Then
      Result := fLocalizer.Text(Result);
     Exit;
    End;
   LabelText := StringReplace(LabelText, '<Control>', 'Ctrl+', [rfReplaceAll, rfIgnoreCase]);
   LabelText := StringReplace(LabelText, '<Primary>', 'Ctrl+', [rfReplaceAll, rfIgnoreCase]);
   LabelText := StringReplace(LabelText, '<Alt>', 'Alt+', [rfReplaceAll, rfIgnoreCase]);
   LabelText := StringReplace(LabelText, '<Shift>', 'Shift+', [rfReplaceAll, rfIgnoreCase]);
   LabelText := StringReplace(LabelText, '<Super>', 'Win+', [rfReplaceAll, rfIgnoreCase]);
   LabelText := StringReplace(LabelText, 'grave', '`', [rfReplaceAll, rfIgnoreCase]);
   LabelText := StringReplace(LabelText, 'asciitilde', '~', [rfReplaceAll, rfIgnoreCase]);
   Result    := 'Guake is now running,' + #10 + 'press <b>{!s}</b> to use it.';
   If fLocalizer <> Nil Then
    Result := fLocalizer.Text(Result);
   Result  := StringReplace(Result, '<b>', '', [rfReplaceAll]);
   Result  := StringReplace(Result, '</b>', '', [rfReplaceAll]);
   Result  := StringReplace(Result, '{!s}', LabelText, [rfReplaceAll]);
  End;

 Procedure TfrmMain.ExecuteConfiguredHook(Const Value : String);
  Var
   Directory : String;
  Begin
   If Trim(Value) = '' Then
    Exit;
   Directory := '';
   If (fController <> Nil) And (fController.ActiveSession <> Nil) Then
    Directory := fController.ActiveSession.Directory;
   Try
    StartConfiguredCommand(Value, Directory);
   Except
    On E : Exception Do
     If fLog <> Nil Then
      fLog.TryLogException(E, 'Configured hook');
   End;
  End;

 Procedure TfrmMain.DeleteNotificationIcon;
  Var
   Data : TNotifyIconData;
  Begin
   If Not fNotificationAdded Then
    Exit;
   FillChar(Data, SizeOf(Data), 0);
   Data.cbSize := SizeOf(Data);
   Data.Wnd    := fNotificationWindow;
   Data.uID    := $4755;
   Shell_NotifyIcon(NIM_DELETE, @Data);
   fNotificationAdded := False;
  End;

 Procedure TfrmMain.ShowNotification(Const Text : String);
  Var
   Title : String;
   Body  : String;
  Begin
   If Not fSettings.General.UsePopup Then
    Exit;
   Title := 'Guake Terminal';
   Body  := Text;
   If fLocalizer <> Nil Then
    Begin
     Title := fLocalizer.Text(Title);
     Body  := fLocalizer.Text(Body);
    End;
   If Assigned(fOnNotification) Then
    Begin
     fOnNotification(Self, Title, Body);
     Exit;
    End;
   If fNotificationQueue = Nil Then
    fNotificationQueue := TQueue<String>.Create;
   If fNotificationQueue.Count >= 32 Then
    fNotificationQueue.Dequeue;
   fNotificationQueue.Enqueue(Body);
   If Not notificationTimer.Enabled Then
    ShowNextNotification;
  End;

 Procedure TfrmMain.ShowNextNotification;
  Var
   Data  : TNotifyIconData;
   Title : String;
   Body  : String;
  Begin
   If (fNotificationQueue = Nil) Or (fNotificationQueue.Count = 0) Then
    Exit;
   DeleteNotificationIcon;
   LoadGuakeTrayIcon(trayIcon.Icon);
   FillChar(Data, SizeOf(Data), 0);
   Data.cbSize           := SizeOf(Data);
   fNotificationWindow   := Handle;
   Data.Wnd              := fNotificationWindow;
   Data.uID              := $4755;
   Data.uFlags           := NIF_ICON Or NIF_MESSAGE Or NIF_TIP;
   Data.uCallbackMessage := WM_APP + 43;
   Data.hIcon            := trayIcon.Icon.Handle;
   StrPLCopy(Data.szTip, 'Guake', Length(Data.szTip) - 1);
   fNotificationAdded := Shell_NotifyIcon(NIM_ADD, @Data);
   If Not fNotificationAdded Then
    Exit;
   Title := 'Guake Terminal';
   If fLocalizer <> Nil Then
    Title      := fLocalizer.Text(Title);
   Body        := fNotificationQueue.Dequeue;
   Data.uFlags := NIF_INFO;
   StrPLCopy(Data.szInfoTitle, Title, Length(Data.szInfoTitle) - 1);
   StrPLCopy(Data.szInfo, Body, Length(Data.szInfo) - 1);
   Data.dwInfoFlags  := NIIF_USER Or $20;
   Data.hBalloonIcon := trayIcon.Icon.Handle;
   Shell_NotifyIcon(NIM_MODIFY, @Data);
   notificationTimer.Enabled := True;
  End;

 Procedure TfrmMain.NotificationExpired(Sender : TObject);
  Begin
   notificationTimer.Enabled := False;
   DeleteNotificationIcon;
   ShowNextNotification;
  End;

 Procedure TfrmMain.WMNotification(Var Message : TMessage);
  Begin
   If (LoWord(Message.LParam) = NIN_BALLOONUSERCLICK) Or (LoWord(Message.LParam) = WM_LBUTTONUP) Then
    Begin
     SetTerminalVisible(True);
     SetForegroundWindow(Handle);
    End;
  End;

 Procedure TfrmMain.LoadCustomCommands;
  Var
   Commands : TObjectList<TCustomCommand>;

   Procedure AddItems(Parent : TMenuItem; Items : TObjectList<TCustomCommand>);
    Var
     Command : TCustomCommand;
     Item    : TCustomCommandItem;
    Begin
     For Command In Items Do
      Begin
       Item := TCustomCommandItem.Create(miCustomCommands);
       Parent.Add(Item);
       Item.Caption     := StringReplace(Command.Description, '&', '&&', [rfReplaceAll]);
       Item.CommandText := Command.Command;
       If Command.IsMenu Then
        AddItems(Item, Command.Children)
       Else
        Item.OnClick := CustomCommandClick;
      End;
    End;

  Begin
   miCustomCommands.Clear;
   miCustomCommands.Visible := False;
   If fSettings.General.CustomCommandFile = '' Then
    Exit;
   Try
    Commands := ReadCustomCommands(fSettings.General.CustomCommandFile);
    Try
     AddItems(miCustomCommands, Commands);
    Finally
     Commands.Free;
    End;
    miCustomCommands.Visible := miCustomCommands.Count > 0;
   Except
    On E : Exception Do
     Begin
      miCustomCommands.Clear;
      If fLog <> Nil Then
       fLog.TryLogException(E, 'Custom command file');
     End;
   End;
  End;

 Procedure TfrmMain.CustomCommandClick(Sender : TObject);
  Begin
   If (fController = Nil) Or (fController.ActiveSession = Nil) Then
    Exit;
   fController.ActiveSession.SendText(TCustomCommandItem(Sender).CommandText + #13);
  End;

 Function TfrmMain.QuickOpenTarget(Frame : TfraTerminal; x, y : Integer; Out Target : TQuickOpenTarget) : Boolean;
  Var
   Text  : String;
   Index : Integer;
  Begin
   Result := False;
   Target := Default(TQuickOpenTarget);
   If (Frame = Nil) Or (Frame.Session = Nil) Or Not fSettings.General.QuickOpenEnable Then
    Exit;
   Text := Frame.SelectedText;
   If Text <> '' Then
    If FindQuickOpenTarget(Text, -1, Frame.Session.Directory, Frame.Session.Profile.GitSdkRoot, Target) Then
     Exit(True);
   Text := Frame.TextAt(x, y, Index);
   If Index >= 0 Then
    Result := FindQuickOpenTarget(Text, Index, Frame.Session.Directory, Frame.Session.Profile.GitSdkRoot, Target);
  End;

 Procedure TfrmMain.OpenQuickTarget(Frame : TfraTerminal; Const Target : TQuickOpenTarget);
  Var
   Command : String;
   Shell   : TGuakeShell;
  Begin
   If (Frame = Nil) Or (Frame.Session = Nil) Or (Target.FileName = '') Then
    Exit;
   Try
    If fSettings.General.QuickOpenInCurrentTerminal Then
     Shell := Frame.Session.Profile.Kind
    Else
     Shell  := gsCmd;
    Command := QuickOpenCommand(fSettings.General.QuickOpenCommandLine, Target, Shell);
    If fSettings.General.QuickOpenInCurrentTerminal Then
     Frame.Session.SendText(Command + #13)
    Else
     StartConfiguredCommand(Command, Frame.Session.Directory);
   Except
    On E : Exception Do
     Begin
      If fLog <> Nil Then
       fLog.TryLogException(E, 'Quick Open');
      ShowNotification('Could not open the file. Check the editor command in preferences.');
     End;
   End;
  End;

 Procedure TfrmMain.TerminalCtrlClick(Sender : TObject; x, y : Integer; Var Handled : Boolean);
  Var
   Frame  : TfraTerminal;
   Target : TQuickOpenTarget;
   Link   : String;
  Begin
   Frame   := TfraTerminal(Sender);
   Handled := QuickOpenTarget(Frame, x, y, Target);
   If Handled Then
    OpenQuickTarget(Frame, Target)
   Else
    Begin
     Link    := Frame.LinkAt(x, y);
     Handled := Link <> '';
     If Handled Then
      OpenExternalLink(Link);
    End;
  End;

 Procedure TfrmMain.QuickOpenClick(Sender : TObject);
  Var
   Frame : TfraTerminal;
  Begin
   Frame := ActiveTerminalFrame;
   If (Frame <> Nil) And (Frame.Session.Id = fPopupQuickSession) Then
    OpenQuickTarget(Frame, fPopupQuickOpen);
  End;

 Procedure TfrmMain.TerminalMenuPopup(Sender : TObject);
  Var
   Frame : TfraTerminal;
  Begin
   LoadCustomCommands;
   fPopupQuickOpen     := Default(TQuickOpenTarget);
   fPopupQuickSession  := '';
   miQuickOpen.Enabled := False;
   fPopupLink          := '';
   Frame               := ActiveTerminalFrame;
   miSearchWeb.Enabled := (Frame <> Nil) And (Frame.SelectedText <> '');
   miOpenLink.Enabled  := False;
   If Frame <> Nil Then
    fPopupLink := Frame.LinkAt(Frame.surface.ScreenToClient(Mouse.CursorPos).x, Frame.surface.ScreenToClient(Mouse.CursorPos).y);
   If Frame <> Nil Then
    Begin
     miQuickOpen.Enabled := QuickOpenTarget(Frame, Frame.surface.ScreenToClient(Mouse.CursorPos).x,
     Frame.surface.ScreenToClient(Mouse.CursorPos).y, fPopupQuickOpen);
     fPopupQuickSession := Frame.Session.Id;
    End;
   miOpenLink.Enabled      := fPopupLink <> '';
   miCopy.Enabled          := (Frame <> Nil) And (Frame.SelectedText <> '');
   miPaste.Enabled         := (Frame <> Nil) And IsClipboardFormatAvailable(CF_UNICODETEXT);
   miFullscreen.Enabled    := fController <> Nil;
   miFullscreen.Checked    := fFullScreen;
   miCloseTerminal.Enabled := Frame <> Nil;
   miSaveTerminal.Enabled  := Frame <> Nil;
   miResetTerminal.Enabled := Frame <> Nil;
  End;

 Function TfrmMain.TabCloseRect(Index : Integer) : TRect;
  Var
   Width : Integer;
  Begin
   Result      := tabBar.TabRect(Index);
   Width       := MulDiv(18, PixelsPerInch, 96);
   Result.Left := Result.Right - Width - 2;
   InflateRect(Result, 0, -2);
  End;

 Procedure TfrmMain.DrawTerminalTab(Control : TCustomTabControl; TabIndex : Integer; Const Rect : TRect; Active : Boolean);
  Begin
   PaintTerminalTab(tabBar.Canvas, TabIndex, Rect, Active);
  End;

 Procedure TfrmMain.PaintTerminalTab(Canvas : TCanvas; Index : Integer; Const Bounds : TRect; Active : Boolean);
  Var
   Details   : TThemedElementDetails;
   TextRect  : TRect;
   CloseRect : TRect;
   x         : Integer;
   y         : Integer;
   Radius    : Integer;
   Title     : String;
  Begin
   If (Index < 0) Or (Index >= tabBar.Tabs.Count) Then
    Exit;
   Canvas.Brush.Style := bsSolid;
   Canvas.Brush.Color := clBtnFace;
   Canvas.FillRect(Bounds);
   If Active Then
    Details := StyleServices.GetElementDetails(ttbButtonChecked)
   Else If Index = fHoverTab Then
    Details := StyleServices.GetElementDetails(ttbButtonHot)
   Else
    Details := StyleServices.GetElementDetails(ttbButtonNormal);
   StyleServices.DrawElement(Canvas.Handle, Details, Bounds);
   Canvas.Font.Assign(tabBar.Font);
   If (fController <> Nil) And (Index >= 0) And (Index < fController.Count) And
   fController.Tabs[Index].HasActivity Then
    Canvas.Font.Style := [fsBold];
   Canvas.Font.Color  := clWindowText;
   TextRect           := Bounds;
   InflateRect(TextRect, -6, 0);
   If (fSettings <> Nil) And fSettings.General.TabCloseButtons Then
    Begin
     CloseRect        := TabCloseRect(Index);
     TextRect.Right   := CloseRect.Left - 2;
     x                := (CloseRect.Left + CloseRect.Right) Div 2;
     y                := (CloseRect.Top + CloseRect.Bottom) Div 2;
     Radius           := Max(3, MulDiv(3, PixelsPerInch, 96));
     Canvas.Pen.Color := clWindowText;
     Canvas.Pen.Width := Max(1, MulDiv(1, PixelsPerInch, 96));
     Canvas.MoveTo(x - Radius, y - Radius);
     Canvas.LineTo(x + Radius + 1, y + Radius + 1);
     Canvas.MoveTo(x - Radius, y + Radius);
     Canvas.LineTo(x + Radius + 1, y - Radius - 1);
    End;
   Canvas.Refresh;
   Canvas.TextWidth('M');
   SetTextAlign(Canvas.Handle, TA_LEFT Or TA_TOP Or TA_NOUPDATECP);
   SelectObject(Canvas.Handle, Canvas.Font.Handle);
   SetTextColor(Canvas.Handle, ColorToRGB(clWindowText));
   SetBkMode(Canvas.Handle, TRANSPARENT);
   Title              := tabBar.Tabs[Index];
   Canvas.Brush.Style := bsClear;
   Canvas.TextRect(TextRect, TextRect.Left, TextRect.Top + Max(0, (TextRect.Bottom - TextRect.Top - Canvas.TextHeight(Title)) Div 2), Title);
  End;

 Procedure TfrmMain.TabMouseMove(Sender : TObject; Shift : TShiftState; x, y : Integer);
  Var
   Index : Integer;
  Begin
   Index := tabBar.IndexOfTabAt(x, y);
   If Index <> fHoverTab Then
    Begin
     fHoverTab := Index;
     tabBar.Invalidate;
     VisualChanged(Self);
    End;
  End;

 Procedure TfrmMain.TabMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Var
   Index : Integer;
  Begin
   If (fSettings = Nil) Or (fController = Nil) Or Not fSettings.General.TabCloseButtons Or (Button <> mbLeft) Then
    Exit;
   Index := tabBar.IndexOfTabAt(x, y);
   If (Index < 0) Or (Index >= fController.Count) Then
    Exit;
   If PtInRect(TabCloseRect(Index), Point(x, y)) Then
    Begin
     fPendingTabClose.Enqueue(fController.Tabs[Index].Id);
     PostMessage(Handle, WM_APP + 44, 0, 0);
    End;
  End;

 Procedure TfrmMain.WMCloseTabButton(Var Message : TMessage);
  Var
   Id : String;
   i  : Integer;
  Begin
   If (fPendingTabClose = Nil) Or (fPendingTabClose.Count = 0) Then
    Exit;
   Id := fPendingTabClose.Dequeue;
   If fController = Nil Then
    Exit;
   For i := 0 To fController.Count - 1 Do
    If fController.Tabs[i].Id = Id Then
     Begin
      fController.SelectTab(i);
      ExecuteTerminalAction(gskKeybindingsLocalCloseTab);
      Break;
     End;
  End;

 Procedure TfrmMain.ResetTabColorsClick(Sender : TObject);
  Begin
   If fController <> Nil Then
    fController.ResetColors(tcsTab);
  End;

 Procedure TfrmMain.TabMenuPopup(Sender : TObject);
  Var
   Point : TPoint;
   Index : Integer;
  Var
   Session : TTerminalSession;
   List    : TList<TTerminalSession>;
  Begin
   miRestoreTabColors.Enabled := False;
   If (fController <> Nil) And (fController.ActiveTab <> Nil) Then
    Begin
     List := TList<TTerminalSession>.Create;
     Try
      fController.ActiveTab.Root.Collect(List);
      For Session In List Do
       If (Session.CustomForeground >= 0) Or (Session.CustomBackground >= 0) Then
        miRestoreTabColors.Enabled := True;
     Finally
      List.Free;
     End;
    End;

   If fController = Nil Then
    Exit;
   Point := tabBar.ScreenToClient(Mouse.CursorPos);
   Index := tabBar.IndexOfTabAt(Point.x, Point.y);
   If Index >= 0 Then
    fController.SelectTab(Index);
   miRenameTab.Enabled := fController.ActiveTab <> Nil;
  End;

 Procedure TfrmMain.TerminalActionClick(Sender : TObject);
  Var
   Dialogs : TdmDialogs;
  Begin
   If fController = Nil Then
    Exit;
   Case TMenuItem(Sender).Tag Of
    0 :
     ExecuteTerminalAction(gskKeybindingsLocalToggleFullscreen);
    1 :
     ExecuteTerminalAction(gskKeybindingsLocalCloseTerminal);
    2 :
     ExecuteTerminalAction(gskKeybindingsLocalResetTerminal);
    3 :
     ExecuteTerminalAction(gskKeybindingsLocalRenameCurrentTab);
    4 :
     If fController.ActiveSession <> Nil Then
      Begin
       Dialogs := TdmDialogs.Create(Self);
       Try
        Dialogs.SaveTerminal(fController.ActiveSession.Buffer.Text, Handle);
       Finally
        Dialogs.Free;
       End;
      End;
   End;
  End;

/// <summary>Slides without resizing ConPTY, clips to the final window slot, and supports reversing in flight.</summary>

 Procedure TfrmMain.SetTerminalVisible(Value : Boolean);
  Begin
   If fSettings = Nil Then
    Exit;
   If Not fSettings.General.DropDownAnimation Or (fSettings.General.DropDownAnimationDuration = 0) Or fFullScreen Then
    Begin
     animationTimer.Enabled := False;
     If fAnimating Then
      Begin
       BoundsRect := fAnimationBounds;
       SetWindowRgn(Handle, 0, True);
      End;
     fAnimating := False;
     If Value Then
      Show
     Else
      Hide;
     Exit;
    End;
   If Not fAnimating Then
    Begin
     If Visible = Value Then
      Exit;
     ApplySettings;
     fAnimationBounds   := BoundsRect;
     fAnimationProgress := Ord(Visible);
     fAnimating         := True;
    End;
   fAnimationTarget := Value;
   fAnimationTick   := GetTickCount64;
   If Value Then
    Begin
     AnimationTick(Nil);
     Show;
     SetForegroundWindow(Handle);
    End;
   animationTimer.Enabled := True;
  End;

 Procedure TfrmMain.AnimationTick(Sender : TObject);
  Var
   NowTick : UInt64;
   Step    : Double;
   Eased   : Double;
   y       : Integer;
   Delta   : Integer;
   Clip    : TRect;
  Begin
   If Not fAnimating Then
    Exit;
   NowTick        := GetTickCount64;
   Step           := (NowTick - fAnimationTick) / Max(1, fSettings.General.DropDownAnimationDuration);
   fAnimationTick := NowTick;
   If fAnimationTarget Then
    fAnimationProgress := Min(1.0, fAnimationProgress + Step)
   Else
    fAnimationProgress := Max(0.0, fAnimationProgress - Step);
   Eased               := fAnimationProgress * fAnimationProgress * (3 - 2 * fAnimationProgress);
   Delta               := Round((fAnimationBounds.Bottom - fAnimationBounds.Top) * (1 - Eased));
   If fSettings.General.WindowValignment = 1 Then
    y := fAnimationBounds.Top + Delta
   Else
    y   := fAnimationBounds.Top - Delta;
   Top  := y;
   Clip := Rect(0, Max(0, fAnimationBounds.Top - y), Width, Min(Height, fAnimationBounds.Bottom - y));
   SetWindowRgn(Handle, CreateRectRgn(Clip.Left, Clip.Top, Clip.Right, Clip.Bottom), True);
   If (fAnimationTarget And (fAnimationProgress >= 1)) Or (Not fAnimationTarget And (fAnimationProgress <= 0)) Then
    Begin
     animationTimer.Enabled := False;
     If Not fAnimationTarget Then
      Hide;
     BoundsRect := fAnimationBounds;
     SetWindowRgn(Handle, 0, True);
     fAnimating := False;
    End;
  End;

 Procedure TfrmMain.ToggleVisibility;
  Begin
   If fAnimating Then
    SetTerminalVisible(Not fAnimationTarget)
   Else
    SetTerminalVisible(Not Visible);
  End;

 Procedure TfrmMain.TrayDblClick(Sender : TObject);
  Begin
   ToggleVisibility;
  End;

 Procedure TfrmMain.FormDeactivate(Sender : TObject);
  Begin
   If (fSettings <> Nil) And fSettings.General.WindowLosefocus And (Screen.ActiveForm = Self) Then
    SetTerminalVisible(False);
  End;

 Procedure TfrmMain.FormClose(Sender : TObject; Var Action : TCloseAction);
  Begin
   Action := caNone;
   SetTerminalVisible(False);
  End;

 Procedure TfrmMain.SetFullScreen(Value : Boolean);
  Var
   r : TRect;
  Begin
   If fFullScreen = Value Then
    Exit;
   If fAnimating Then
    Begin
     animationTimer.Enabled := False;
     BoundsRect             := fAnimationBounds;
     SetWindowRgn(Handle, 0, True);
     fAnimating := False;
    End;
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
    fSessionSaveBlocked := False;
    If fSettings.General.RestoreTabsStartup And TFile.Exists(SessionFileName) Then
     Begin
      Try
       fController.LoadSession(SessionFileName);
       fLastSavedState := fController.SessionState;
      Except
       On E : Exception Do
        Begin
         fSessionSaveBlocked := True;
         If fLog <> Nil Then
          fLog.TryLogException(E, 'Restore session at startup');
         ShowNotification('Could not restore tabs. The existing session file has been preserved.');
        End;
      End;
     End;
    If fController.Count = 0 Then
     fController.NewTab;
    sessionTimer.Enabled  := Not fSessionSaveBlocked;
    miSaveTabs.Enabled    := True;
    miRestoreTabs.Enabled := TFile.Exists(SessionFileName);
    RegisterGlobalHotkeys;
    pollTimer.Enabled         := True;
    miNewTab.Enabled          := True;
    btnAddTab.Enabled         := True;
    btnTabList.Enabled        := True;
    miTrayNewTab.Enabled      := True;
    miCloseTab.Enabled        := True;
    miSplitHorizontal.Enabled := True;
    miSplitVertical.Enabled   := True;
    miCopy.Enabled            := True;
    miPaste.Enabled           := True;
    miSearch.Enabled          := True;
    ApplySettings;
    If fSettings.General.StartAtLogin Then
     Try
      ConfigureAutoStart(True, ParamStr(0));
     Except
      On E : Exception Do
       Begin
        If fLog <> Nil Then
         fLog.TryLogException(E, 'Windows startup registration');
        ShowNotification('Could not configure Windows startup. See the log for details.');
       End;
     End;
    If Not FindCmdLineSwitch('no-startup-script') Then
     ExecuteConfiguredHook(fSettings.General.StartupScript);
    ShowNotification(StartupMessage);
    If fHotkeyErrors <> '' Then
     ShowNotification('Could not register a global shortcut. Choose another shortcut in Preferences.');
    If fSettings.General.StartFullscreen Then
     SetFullScreen(True);
   Except
    StopTerminal;
    Raise;
   End;
  End;

 Procedure TfrmMain.StopTerminal;
  Begin
   If sessionTimer <> Nil Then
    sessionTimer.Enabled := False;
   If (fController <> Nil) And (fSettings <> Nil) And fSettings.General.SaveTabsWhenChanged And Not fSessionSaveBlocked Then
    Begin
     Try
      fController.SaveSession(SessionFileName);
     Except
      On E : Exception Do
       If fLog <> Nil Then
        fLog.TryLogException(E, 'Save session at shutdown');
     End;
    End;
   If pollTimer <> Nil Then
    pollTimer.Enabled := False;
   If HandleAllocated Then
    Begin
     UnregisterHotKey(Handle, 1);
     UnregisterHotKey(Handle, 2);
    End;
   If btnAddTab <> Nil Then
    btnAddTab.Enabled := False;
   If btnTabList <> Nil Then
    btnTabList.Enabled := False;
   If miTrayNewTab <> Nil Then
    miTrayNewTab.Enabled := False;
   ClearTerminalViews;
   FreeAndNil(fViews);
   FreeAndNil(fController);
  End;

 Procedure TfrmMain.FormDestroy(Sender : TObject);
  Begin
   If notificationTimer <> Nil Then
    notificationTimer.Enabled := False;
   DeleteNotificationIcon;
   FreeAndNil(fNotificationQueue);
   FreeAndNil(fPendingTabClose);
   If animationTimer <> Nil Then
    animationTimer.Enabled := False;
   StopTerminal;
   FreeAndNil(fChromeSurface);
   FreeAndNil(fWindowSurface);
   FreeAndNil(fTerminalSurface);
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
       Frame.OnCtrlClick       := TerminalCtrlClick;
       Frame.OnVisualChanged   := VisualChanged;
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
       Split.Node   := Node;
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
   i           : Integer;
   Title       : String;
   Activity    : String;
   WindowTitle : String;
   Changed     : Boolean;
   ShowTabs    : Boolean;
  Begin
   If fController = Nil Then
    Exit;
   Changed       := False;
   Activity      := '';
   fUpdatingTabs := True;
   Try
    While tabBar.Tabs.Count > fController.Count Do
     Begin
      tabBar.Tabs.Delete(tabBar.Tabs.Count - 1);
      Changed := True;
     End;
    For i := 0 To fController.Count - 1 Do
     Begin
      Title := fController.Tabs[i].Title;
      If Length(Title) > fSettings.General.MaxTabNameLength Then
       Title := Copy(Title, 1, fSettings.General.MaxTabNameLength);
      If i = tabBar.Tabs.Count Then
       Begin
        tabBar.Tabs.Add(Title);
        Changed := True;
       End
      Else If tabBar.Tabs[i] <> Title Then
       Begin
        tabBar.Tabs[i] := Title;
        Changed        := True;
       End;
      Activity := Activity + BoolToStr(fController.Tabs[i].HasActivity);
     End;
    If tabBar.TabIndex <> fController.ActiveIndex Then
     Begin
      tabBar.TabIndex := fController.ActiveIndex;
      Changed         := True;
     End;
    If fSettings.General.SetWindowTitle And (fController.ActiveTab <> Nil) Then
     WindowTitle := fController.ActiveTab.Title
    Else
     WindowTitle := 'Guake!';
    If Caption <> WindowTitle Then
     Caption := WindowTitle;
    ShowTabs := fSettings.General.WindowTabbar And Not(fFullScreen And fSettings.General.FullscreenHideTabbar)
    And Not(fSettings.General.HideTabsIfOneTab And (fController.Count <= 1));
    If tabHost.Visible <> ShowTabs Then
     Begin
      tabHost.Visible := ShowTabs;
      Changed         := True;
     End;
    If Activity <> fLastTabActivity Then
     Begin
      fLastTabActivity := Activity;
      Changed          := True;
     End;
    If Changed Then
     Begin
      tabBar.Invalidate;
      VisualChanged(Self);
     End;
   Finally
    fUpdatingTabs := False;
   End;
  End;

 Function TfrmMain.SessionFileName : String;
  Begin
   Result := ChangeFileExt(fSettings.FileName, '.session.json');
  End;

 Procedure TfrmMain.SaveTabsClick(Sender : TObject);
  Begin
   If fController = Nil Then
    Exit;
   fController.SaveSession(SessionFileName);
   fLastSavedState       := fController.SessionState;
   fSessionSaveBlocked   := False;
   sessionTimer.Enabled  := True;
   miRestoreTabs.Enabled := True;
  End;

 Procedure TfrmMain.RestoreTabsClick(Sender : TObject);
  Begin
   If fController = Nil Then
    Exit;
   Try
    fController.LoadSession(SessionFileName);
    fLastSavedState      := fController.SessionState;
    fSessionSaveBlocked  := False;
    sessionTimer.Enabled := True;
    If fSettings.General.RestoreTabsNotify Then
     ShowNotification('Your tabs has been restored!');
   Except
    On E : Exception Do
     Begin
      If fLog <> Nil Then
       fLog.TryLogException(E, 'Restore session');
      ShowNotification('Could not restore tabs. The existing session file has been preserved.');
     End;
   End;
  End;

 Procedure TfrmMain.SessionSaveTick(Sender : TObject);
  Var
   State : String;
  Begin
   If (fController = Nil) Or fSessionSaveBlocked Or Not fSettings.General.SaveTabsWhenChanged Then
    Exit;
   State := fController.SessionState;
   If State = fLastSavedState Then
    Exit;
   Try
    fController.SaveSession(SessionFileName);
    fLastSavedState       := State;
    miRestoreTabs.Enabled := True;
   Except
    On E : Exception Do
     Begin
      sessionTimer.Enabled := False;
      fSessionSaveBlocked  := True;
      If fLog <> Nil Then
       fLog.TryLogException(E, 'Autosave session');
     End;
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

/// <summary>Dispatches protocol actions without evaluating JSON as executable code.</summary>

 Procedure TfrmMain.ExecuteIPCCommand(Const Command : String);
  Var
   Root   : TJSONValue;
   Obj    : TJSONObject;
   Action : String;

   Function Field(Const Name : String) : String;
    Var
     Value : TJSONValue;
    Begin
     Value := Obj.GetValue(Name);
     If Value = Nil Then
      Result := ''
     Else
      Result := Value.Value;
    End;

  Begin
   If Not ValidIPCCommand(Command) Then
    Raise EArgumentException.Create('Invalid named pipe command');
   Root := TJSONObject.ParseJSONValue(Command);
   Try
    Obj    := TJSONObject(Root);
    Action := Field('action');
    If Action = 'show' Then
     SetTerminalVisible(True)
    Else If Action = 'hide' Then
     SetTerminalVisible(False)
    Else If Action = 'toggle' Then
     ToggleVisibility
    Else If Action = 'new-tab' Then
     Begin
      fController.NewTab(Field('directory'), Field('shell'));
      SetTerminalVisible(True);
     End
    Else If (Action = 'bgcolor') Or (Action = 'fgcolor') Then
     Begin
      If Field('current') = 'true' Then
       fController.SetColor(Action = 'fgcolor', ParseTerminalColor(Field('color')), tcsTerminal)
      Else
       fController.SetColor(Action = 'fgcolor', ParseTerminalColor(Field('color')), tcsTab);
     End
    Else If Action = 'reset-colors' Then
     Begin
      If Field('current') = 'true' Then
       fController.ResetColors(tcsTerminal)
      Else
       fController.ResetColors(tcsAll);
     End
    Else If Action = 'close-tab' Then
     ExecuteTerminalAction(gskKeybindingsLocalCloseTab)
    Else If Action = 'select-tab' Then
     fController.SelectTab(StrToInt(Field('index')))
    Else If Action = 'rename-tab' Then
     Begin
      If fController.ActiveTab <> Nil Then
       fController.ActiveTab.Name := Field('name');
      UpdateTerminalTitles;
     End
    Else If Action = 'split-horizontal' Then
     ExecuteTerminalAction(gskKeybindingsLocalSplitTabHorizontal)
    Else If Action = 'split-vertical' Then
     ExecuteTerminalAction(gskKeybindingsLocalSplitTabVertical)
    Else If Action = 'execute' Then
     Begin
      If fController.ActiveSession <> Nil Then
       fController.ActiveSession.SendText(Field('text') + #13);
     End
    Else If Action = 'preferences' Then
     PreferencesClick(Nil)
    Else If Action = 'about' Then
     AboutClick(Nil)
    Else If Action = 'exit' Then
     ExitApplication(False)
    Else If Action = 'quit' Then
     QuitClick(Nil)
    Else If Action = 'save-session' Then
     SaveTabsClick(Nil)
    Else If Action = 'restore-session' Then
     RestoreTabsClick(Nil)
    Else If Action = 'fullscreen' Then
     SetFullScreen(True)
    Else If Action = 'unfullscreen' Then
     SetFullScreen(False);
   Finally
    Root.Free;
   End;
  End;

 Procedure TfrmMain.PollTerminal(Sender : TObject);
  Var
   i         : Integer;
   Tab       : TTerminalTab;
   Session   : TTerminalSession;
   AllExited : Boolean;
   List      : TList<TTerminalSession>;
   Command   : String;
   Frame     : TfraTerminal;
  Begin
   If (fController = Nil) Or fPolling Then
    Exit;
   fPolling := True;
   Try
    If fInstance <> Nil Then
     For i := 1 To 16 Do
      Begin
       If Not fInstance.TryReceive(Command) Then
        Break;
       Try
        ExecuteIPCCommand(Command);
       Except
        On E : Exception Do
         Begin
          If fLog <> Nil Then
           fLog.TryLogException(E, 'Named pipe command');
          ShowNotification('Could not execute a remote command. See the log for details.');
         End;
       End;
      End;

    If fController.Poll Then
     Begin
      UpdateTerminalTitles;
      // Consume output and update the viewport in the same poll instead of waiting another 100 ms.
      If fViews <> Nil Then
       For Frame In fViews.Values Do
        Frame.RefreshTick(Nil);
     End;
    For Session In fController.Sessions Do
     If Session.TakeBell And fSettings.General.UseAudibleBell Then
      MessageBeep(MB_OK);

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
    PresentLayeredWindow;
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
      SetTerminalVisible(True);
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
   Point  : TPoint;
  Begin
   If fController = Nil Then
    Exit;
   Frame := ActiveTerminalFrame;
   Case Action Of
    gskKeybindingsLocalSearchOnWeb :
     If Frame <> Nil Then
      OpenExternalLink(WebSearchAddress(Frame.SelectedText, fSettings.General.SearchEngine, fSettings.General.CustomSearchEngine));
    gskKeybindingsLocalOpenLinkUnderTerminalCursor :
     If Frame <> Nil Then
      Begin
       Point := Frame.surface.ScreenToClient(Mouse.CursorPos);
       OpenExternalLink(Frame.LinkAt(Point.x, Point.y));
      End;
    gskKeybindingsLocalFocusTerminalUp :
     fController.FocusDirection(0, -1);
    gskKeybindingsLocalFocusTerminalDown :
     fController.FocusDirection(0, 1);
    gskKeybindingsLocalFocusTerminalLeft :
     fController.FocusDirection( -1, 0);
    gskKeybindingsLocalFocusTerminalRight :
     fController.FocusDirection(1, 0);
    gskKeybindingsLocalMoveTerminalSplitUp :
     fController.MoveSplit(0, -1);
    gskKeybindingsLocalMoveTerminalSplitDown :
     fController.MoveSplit(0, 1);
    gskKeybindingsLocalMoveTerminalSplitLeft :
     fController.MoveSplit( -1, 0);
    gskKeybindingsLocalMoveTerminalSplitRight :
     fController.MoveSplit(1, 0);
    gskKeybindingsLocalNewTabZsh :
     fController.NewTab('', 'zsh');
    gskKeybindingsLocalNewTabBash :
     fController.NewTab('', 'bash');
    gskKeybindingsLocalNewTabCmd :
     fController.NewTab('', 'cmd');
    gskKeybindingsLocalNewTabPowerShell :
     fController.NewTab('', 'powershell');
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
   If Action In [gskKeybindingsLocalFocusTerminalUp, gskKeybindingsLocalFocusTerminalDown,
   gskKeybindingsLocalFocusTerminalLeft, gskKeybindingsLocalFocusTerminalRight] Then
    Begin
     Frame := ActiveTerminalFrame;
     If (Frame <> Nil) And Frame.CanFocus Then
      Frame.SetFocus;
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
