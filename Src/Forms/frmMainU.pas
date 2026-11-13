{$StackFrames On}
Unit frmMainU;

Interface

 Uses
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages,
  Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus,
  Guake.Settings, Guake.Localization, Guake.Logging;

 Type
  TGuakeWindowCommand = (gwNewTab, gwCloseTab, gwSplitHorizontal, gwSplitVertical, gwCopy, gwPaste, gwSearch);

  TGuakeCommandEvent = Procedure(Sender : TObject; Command : TGuakeWindowCommand) Of Object;

  TfrmMain = Class(TForm)
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
    Procedure FormShow        (Sender : TObject);
    Procedure PreferencesClick(Sender : TObject);
    Procedure AboutClick      (Sender : TObject);
    Procedure QuitClick       (Sender : TObject);
    Procedure CommandClick    (Sender : TObject);
    Procedure TrayDblClick    (Sender : TObject);
    Procedure FormDeactivate  (Sender : TObject);
    Procedure FormClose       (Sender : TObject; Var Action : TCloseAction);
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
    Procedure Bind         (Settings : TGuakeSettings; Localizer : TGuakeLocalization = Nil; Log : TGuakeLog = Nil);
    Procedure ApplySettings;
    Procedure ToggleVisibility;
    Procedure SetFullScreen(Value : Boolean);
    Property OnCommand : TGuakeCommandEvent Read fOnCommand Write SetOnCommand;
  End;

Implementation

 Uses
  frmPreferencesU, frmAboutU;
{$R *.dfm}

 Procedure TfrmMain.FormShow(Sender : TObject);
  Begin
   trayIcon.Icon.Assign(Application.Icon);
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
   trayIcon.Visible := Visible And fSettings.General.UseTrayicon;
  End;

 Procedure TfrmMain.SettingsChanged(Sender : TObject);
  Begin
   ApplySettings;
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
   trayIcon.Visible := False;
   Application.Terminate;
  End;

 Procedure TfrmMain.CommandClick(Sender : TObject);
  Begin
   If Assigned(fOnCommand) Then
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

End.
