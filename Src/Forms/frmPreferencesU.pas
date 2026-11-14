{$StackFrames On}

/// <summary>DFM-backed Guake preference editor with immediate transactional persistence and localized captions.</summary>
Unit frmPreferencesU;

// Layout and behavior ported from Guake prefs.glade and prefs.py (GPL-2.0-or-later).

Interface

 Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs,
  Vcl.Samples.Spin, Vcl.Grids, Vcl.AppEvnts, Vcl.Graphics,
  Guake.Settings, Guake.Localization, Guake.Logging;

 Type
  TfrmPreferences = Class(TForm)
    pnlHeader            : TPanel;
    imgHeader            : TImage;
    lblHeaderTitle       : TLabel;
    lblHeaderDescription : TLabel;
    navPages             : TListBox;

    pnlFooter                       : TPanel;
    btnClose                        : TButton;
    pages                           : TPageControl;
    tabGeneral                      : TTabSheet;
    scrollGeneral                   : TScrollBox;
    grpGeneral0                     : TGroupBox;
    ctlRestoreTabsStartup           : TCheckBox;
    ctlRestoreTabsNotify            : TCheckBox;
    ctlSaveTabsWhenChanged          : TCheckBox;
    ctlLoadGuakeYml                 : TCheckBox;
    grpGeneral1                     : TGroupBox;
    ctlUsePopup                     : TCheckBox;
    ctlUseAudibleBell               : TCheckBox;
    ctlStartAtLogin                 : TCheckBox;
    ctlDisplayTabActivity           : TCheckBox;
    lblTabActivityNewTabGrace       : TLabel;
    ctlTabActivityNewTabGrace       : TEdit;
    lblTabActivityFocusLossGrace    : TLabel;
    ctlTabActivityFocusLossGrace    : TEdit;
    lblPromptOnCloseTab             : TLabel;
    ctlPromptOnCloseTab             : TComboBox;
    ctlPromptOnQuit                 : TCheckBox;
    ctlUseTrayicon                  : TCheckBox;
    ctlUseVisibleBell               : TCheckBox;
    ctlWorkspaceSpecificTabSets     : TCheckBox;
    ctlTabCloseButtons              : TCheckBox;
    ctlCopyOnSelect                 : TCheckBox;
    grpGeneral2                     : TGroupBox;
    ctlGtkUseSystemDefaultTheme     : TCheckBox;
    lblGtkThemeName                 : TLabel;
    ctlGtkThemeName                 : TComboBox;
    ctlGtkPreferDarkTheme           : TCheckBox;
    lblCustomCommandFileChooser     : TLabel;
    browseCustomCommandFileChooser  : TButton;
    ctlCustomCommandFileChooser     : TEdit;
    lblSearchEngineSelect           : TLabel;
    ctlSearchEngineSelect           : TComboBox;
    lblCustomSearch                 : TLabel;
    ctlCustomSearch                 : TEdit;
    tabMainWindow                   : TTabSheet;
    scrollMainWindow                : TScrollBox;
    grpMainWindow0                  : TGroupBox;
    ctlWindowRefocus                : TCheckBox;
    ctlWindowLosefocus              : TCheckBox;
    ctlStartFullscreen              : TCheckBox;
    ctlWindowOntop                  : TCheckBox;
    lblTabNameDisplay               : TLabel;
    ctlTabNameDisplay               : TComboBox;
    lblMaxTabNameLength             : TLabel;
    ctlMaxTabNameLength             : TSpinEdit;
    ctlNewTabAfter                  : TCheckBox;
    ctlFullscreenHideTabbar         : TCheckBox;
    ctlHideTabsIfOneTab             : TCheckBox;
    ctlSetWindowTitle               : TCheckBox;
    ctlUseVteTitles                 : TCheckBox;
    ctlWindowTabbar                 : TCheckBox;
    ctlLazyLoseFocus                : TCheckBox;
    grpMainWindow1                  : TGroupBox;
    ctlTopAlign                     : TCheckBox;
    ctlMouseDisplay                 : TCheckBox;
    lblDisplayN                     : TLabel;
    ctlDisplayN                     : TComboBox;
    ctlTabOntop                     : TCheckBox;
    grpMainWindow2                  : TGroupBox;
    lblWindowHeight                 : TLabel;
    valueWindowHeight               : TLabel;
    ctlWindowHeight                 : TTrackBar;
    lblWindowWidth                  : TLabel;
    valueWindowWidth                : TLabel;
    ctlWindowWidth                  : TTrackBar;
    lblWindowVerticalDisplacement   : TLabel;
    ctlWindowVerticalDisplacement   : TSpinEdit;
    lblWindowHorizontalDisplacement : TLabel;
    ctlWindowHorizontalDisplacement : TSpinEdit;
    lblAlignment                    : TLabel;

    ctlAlignLeft                     : TRadioButton;
    ctlAlignCenter                   : TRadioButton;
    ctlAlignRight                    : TRadioButton;
    tabShell                         : TTabSheet;
    scrollShell                      : TScrollBox;
    grpShell0                        : TGroupBox;
    lblDefaultShell                  : TLabel;
    ctlDefaultShell                  : TComboBox;
    ctlUseLoginShell                 : TCheckBox;
    ctlOpenTabCwd                    : TCheckBox;
    lblShellNote                     : TLabel;
    tabScrolling                     : TTabSheet;
    scrollScrolling                  : TScrollBox;
    grpScrolling0                    : TGroupBox;
    ctlUseScrollbar                  : TCheckBox;
    lblHistorySize                   : TLabel;
    ctlHistorySize                   : TSpinEdit;
    ctlInfiniteHistory               : TCheckBox;
    grpScrolling1                    : TGroupBox;
    ctlScrollOutput                  : TCheckBox;
    ctlScrollKeystroke               : TCheckBox;
    tabAppearance                    : TTabSheet;
    scrollAppearance                 : TScrollBox;
    grpAppearance0                   : TGroupBox;
    ctlUseDefaultFont                : TCheckBox;
    lblFontStyle                     : TLabel;
    ctlFontStyle                     : TButton;
    lblCursorShape                   : TLabel;
    ctlCursorShape                   : TComboBox;
    lblCursorBlinkMode               : TLabel;
    ctlCursorBlinkMode               : TComboBox;
    ctlAllowBold                     : TCheckBox;
    ctlBoldIsBright                  : TCheckBox;
    lblBackgroundImageFilechooser    : TLabel;
    browseBackgroundImageFilechooser : TButton;
    clearBackground                  : TButton;
    ctlBackgroundImageFilechooser    : TEdit;
    lblBackgroundImageLayoutMode     : TLabel;
    ctlBackgroundImageLayoutMode     : TComboBox;
    lblCellHeightScale               : TLabel;
    valueCellHeightScale             : TLabel;
    ctlCellHeightScale               : TTrackBar;
    lblCellWidthScale                : TLabel;
    valueCellWidthScale              : TLabel;
    ctlCellWidthScale                : TTrackBar;
    grpAppearance1                   : TGroupBox;
    lblPaletteName                   : TLabel;
    ctlPaletteName                   : TComboBox;
    lblPalette0                      : TLabel;
    colorPalette0                    : TColorBox;
    lblPalette1                      : TLabel;
    colorPalette1                    : TColorBox;
    lblPalette2                      : TLabel;
    colorPalette2                    : TColorBox;
    lblPalette3                      : TLabel;
    colorPalette3                    : TColorBox;
    lblPalette4                      : TLabel;
    colorPalette4                    : TColorBox;
    lblPalette5                      : TLabel;
    colorPalette5                    : TColorBox;
    lblPalette6                      : TLabel;
    colorPalette6                    : TColorBox;
    lblPalette7                      : TLabel;
    colorPalette7                    : TColorBox;
    lblPalette8                      : TLabel;
    colorPalette8                    : TColorBox;
    lblPalette9                      : TLabel;
    colorPalette9                    : TColorBox;
    lblPalette10                     : TLabel;
    colorPalette10                   : TColorBox;
    lblPalette11                     : TLabel;
    colorPalette11                   : TColorBox;
    lblPalette12                     : TLabel;
    colorPalette12                   : TColorBox;
    lblPalette13                     : TLabel;
    colorPalette13                   : TColorBox;
    lblPalette14                     : TLabel;
    colorPalette14                   : TColorBox;
    lblPalette15                     : TLabel;
    colorPalette15                   : TColorBox;
    lblPalette16                     : TLabel;
    colorPalette16                   : TColorBox;
    lblPalette17                     : TLabel;
    colorPalette17                   : TColorBox;
    paletteDemo                      : TPaintBox;
    grpAppearance2                   : TGroupBox;
    lblBackgroundTransparency        : TLabel;
    valueBackgroundTransparency      : TLabel;
    ctlBackgroundTransparency        : TTrackBar;
    tabKeyboard                      : TTabSheet;
    scrollKeyboard                   : TScrollBox;
    lblShortcutHelp                  : TLabel;
    gridShortcuts                    : TStringGrid;
    tabQuickOpen                     : TTabSheet;
    scrollQuickOpen                  : TScrollBox;
    grpQuickOpen0                    : TGroupBox;
    ctlQuickOpenEnable               : TCheckBox;
    lblQuickOpenCommandLine          : TLabel;
    ctlQuickOpenCommandLine          : TEdit;
    ctlQuickOpenInCurrentTerminal    : TCheckBox;
    lblQuickOpenHelp                 : TLabel;
    lblQuickOpenArguments            : TLabel;
    tabHooks                         : TTabSheet;
    scrollHooks                      : TScrollBox;
    grpHooks1                        : TGroupBox;
    lblHookShow                      : TLabel;
    ctlHookShow                      : TEdit;
    lblStartupScript                 : TLabel;
    ctlStartupScript                 : TEdit;
    tabCompatibility                 : TTabSheet;
    scrollCompatibility              : TScrollBox;
    grpCompatibility0                : TGroupBox;
    lblBackspaceBindingCombobox      : TLabel;
    ctlBackspaceBindingCombobox      : TComboBox;
    lblDeleteBindingCombobox         : TLabel;
    ctlDeleteBindingCombobox         : TComboBox;
    lblWordCharsEntry                : TLabel;
    ctlWordCharsEntry                : TEdit;
    btnResetCompatibility            : TButton;
    dlgBackground                    : TOpenDialog;
    dlgCustomCommands                : TOpenDialog;
    dlgFont                          : TFontDialog;
    appEvents                        : TApplicationEvents;
    Procedure NavigationClick        (Sender : TObject);
    Procedure NavigationDrawItem     (Control : TWinControl; Index : Integer; Rect : TRect; State : TOwnerDrawState);
    Procedure PagesChanged           (Sender : TObject);
    Procedure FormCreate             (Sender : TObject);
    Procedure FormDestroy            (Sender : TObject);
    Procedure FormClose              (Sender : TObject; Var Action : TCloseAction);
    Procedure CloseClick             (Sender : TObject);
    Procedure SettingChanged         (Sender : TObject);
    Procedure BrowseClick            (Sender : TObject);
    Procedure ClearBackgroundClick   (Sender : TObject);
    Procedure FontClick              (Sender : TObject);
    Procedure PaletteColorChanged    (Sender : TObject);
    Procedure DemoPaint              (Sender : TObject);
    Procedure ResetCompatibilityClick(Sender : TObject);
    Procedure ShortcutKeyDown        (Sender : TObject; Var Key : Word; Shift : TShiftState);
    Procedure ShortcutDblClick       (Sender : TObject);
    Procedure ApplicationException   (Sender : TObject; e : Exception);
   Private
    fOnError           : TExceptionEvent;
    fSettings          : TGuakeSettings;
    fLocalizer         : TGuakeLocalization;
    fLog               : TGuakeLog;
    fLoading           : Boolean;
    fCapturingShortcut : Boolean;
    fShortcutKeys      : TArray<TGuakeSetting>;
    fOnSettingsChanged : TNotifyEvent;
    Function  Translate   (Const Source : String)                   : String;
    Procedure LoadControls;
    Procedure UpdateSensitivity;
    Procedure Localize;
    Procedure Commit      (Candidate : TGuakeSettings);
    Procedure LoadPalette;
    Procedure FillShortcuts;
    Function  ControlValue(Control : TControl; Key : TGuakeSetting) : String;
   Public
    Procedure Bind         (Settings : TGuakeSettings; Localizer : TGuakeLocalization = Nil; Log : TGuakeLog = Nil);
    Procedure SetPreference(Key : TGuakeSetting; Const Value : String);
    Procedure SetShortcut  (Key : TGuakeSetting; Const Accelerator : String);
    Procedure ResetCompatibility;
    Property OnError           : TExceptionEvent Read fOnError Write fOnError;
    Property Settings          : TGuakeSettings Read fSettings;
    Property OnSettingsChanged : TNotifyEvent Read fOnSettingsChanged Write fOnSettingsChanged;
  End;

Implementation

 Uses
  System.TypInfo, System.Math, System.StrUtils, Vcl.Themes, Guake.Palettes, Guake.Shells, Guake.Keybindings, Guake.Resources;

{$R *.dfm}

 Procedure TfrmPreferences.Localize;
  Var
   varIndex : Integer;
  Begin
   ctlAlignLeft.Caption                    := Translate('Left');
   ctlAlignCenter.Caption                  := Translate('Center');
   ctlAlignRight.Caption                   := Translate('Right');
   Self.Caption                            := Translate('Guake Preferences');
   btnClose.Caption                        := Translate('Close');
   tabGeneral.Caption                      := Translate('General');
   grpGeneral0.Caption                     := Translate('Startup & Tabs (Experiment)');
   ctlRestoreTabsStartup.Caption           := Translate('Restore previous session (tabs)');
   ctlRestoreTabsNotify.Caption            := Translate('Enable notification when restore tabs');
   ctlSaveTabsWhenChanged.Caption          := Translate('Automatically save session when the tabs has been modified');
   ctlLoadGuakeYml.Caption                 := Translate('Load settings from `cwd`/.guake.yml');
   grpGeneral1.Caption                     := Translate('<b>General</b>');
   ctlUsePopup.Caption                     := Translate('Enable popup notifications on startup');
   ctlUseAudibleBell.Caption               := Translate('_Play system alert sound on bell');
   ctlStartAtLogin.Caption                 := Translate('Start Guake at login');
   ctlDisplayTabActivity.Caption           := Translate('Highlight tabs with activity');
   lblTabActivityNewTabGrace.Caption       := Translate('Ignore activity on new tabs for (seconds):');
   lblTabActivityFocusLossGrace.Caption    := Translate('Ignore activity after losing focus for (seconds):');
   lblPromptOnCloseTab.Caption             := Translate('Prompt on close tab:');
   ctlPromptOnQuit.Caption                 := Translate('Always prompt on quit');
   ctlUseTrayicon.Caption                  := Translate('Show tray icon');
   ctlUseVisibleBell.Caption               := Translate('_Flash terminal on bell');
   ctlWorkspaceSpecificTabSets.Caption     := Translate('Use workspace-specific tab sets (requires restart, only work on X11)');
   ctlTabCloseButtons.Caption              := Translate('Show close buttons for tabs');
   ctlCopyOnSelect.Caption                 := Translate('Copy on select');
   ctlGtkUseSystemDefaultTheme.Caption     := Translate('Use system default theme');
   lblGtkThemeName.Caption                 := Translate('GTK Theme:');
   ctlGtkPreferDarkTheme.Caption           := Translate('Prefer dark theme');
   lblCustomCommandFileChooser.Caption     := Translate('Custom command file path:');
   lblSearchEngineSelect.Caption           := Translate('Search Engine:');
   lblCustomSearch.Caption                 := Translate('Custom Search:');
   tabMainWindow.Caption                   := Translate('Main Window');
   grpMainWindow0.Caption                  := Translate('<b>Main Window Options</b>');
   ctlWindowRefocus.Caption                := Translate('Refocus if open');
   ctlWindowLosefocus.Caption              := Translate('Hide on lose focus');
   ctlStartFullscreen.Caption              := Translate('Start fullscreen');
   ctlWindowOntop.Caption                  := Translate('Stay on top');
   lblTabNameDisplay.Caption               := Translate('Display as tab names:');
   lblMaxTabNameLength.Caption             := Translate('Max tab name length:');
   ctlNewTabAfter.Caption                  := Translate('New tabs appear after the current tab');
   ctlFullscreenHideTabbar.Caption         := Translate('Hide tabbar when fullscreen');
   ctlHideTabsIfOneTab.Caption             := Translate('Hide tab bar if there is only one tab');
   ctlSetWindowTitle.Caption               := Translate('Set window title to current tab name');
   ctlUseVteTitles.Caption                 := Translate('Use VTE titles for tab names');
   ctlWindowTabbar.Caption                 := Translate('Show tab bar');
   ctlLazyLoseFocus.Caption                := Translate('Lazy hide on lose focus');
   grpMainWindow1.Caption                  := Translate('<b>Placement</b>');
   ctlTopAlign.Caption                     := Translate('Bottom align window instead of top align');
   ctlMouseDisplay.Caption                 := Translate('Appear on mouse display');
   lblDisplayN.Caption                     := Translate('Appear on display:');
   ctlTabOntop.Caption                     := Translate('Place tabs on top');
   grpMainWindow2.Caption                  := Translate('<b>Geometry</b>');
   lblWindowHeight.Caption                 := Translate('Height:');
   lblWindowWidth.Caption                  := Translate('Width:');
   lblWindowVerticalDisplacement.Caption   := Translate('Vertical displacement in pixels:');
   lblWindowHorizontalDisplacement.Caption := Translate('Horizontal displacement in pixels:');
   lblAlignment.Caption                    := Translate('Horizontal Alignment:');
   tabShell.Caption                        := Translate('Shell');
   lblDefaultShell.Caption                 := Translate('Default interpreter:');
   ctlUseLoginShell.Caption                := Translate('_Run command as a login shell');
   ctlOpenTabCwd.Caption                   := Translate('_Open new tab in current directory');
   lblShellNote.Caption                    := Translate('This might not work on all shells, make sure that your shell supports the --login option');
   tabScrolling.Caption                    := Translate('Scrolling');
   grpScrolling0.Caption                   := Translate('<b>Scrollbar</b>');
   ctlUseScrollbar.Caption                 := Translate('Show scrollbar');
   lblHistorySize.Caption                  := Translate('Scrollback lines:');
   ctlInfiniteHistory.Caption              := Translate('Infinite scrolling');
   grpScrolling1.Caption                   := Translate('<b>Scroll to Bottom</b>');
   ctlScrollOutput.Caption                 := Translate('On output');
   ctlScrollKeystroke.Caption              := Translate('On key stroke');
   tabAppearance.Caption                   := Translate('Appearance');
   grpAppearance0.Caption                  := Translate('<b>General</b>');
   ctlUseDefaultFont.Caption               := Translate('Use the system fixed width font');
   lblFontStyle.Caption                    := Translate('Font:');
   lblCursorShape.Caption                  := Translate('Cursor shape:');
   lblCursorBlinkMode.Caption              := Translate('Cursor blink mode:');
   ctlAllowBold.Caption                    := Translate('Allow bold font');
   ctlBoldIsBright.Caption                 := Translate('Bold text is also bright (VTE >=0.52)');
   lblBackgroundImageFilechooser.Caption   := Translate('Background image:');
   lblBackgroundImageLayoutMode.Caption    := Translate('Background image layout:');
   lblCellHeightScale.Caption              := Translate('Line Height Scale (VTE >= 0.52)');
   lblCellWidthScale.Caption               := Translate('Line Width Scale (VTE >= 0.52)');
   grpAppearance1.Caption                  := Translate('<b>Palette</b>');
   lblPaletteName.Caption                  := Translate('Built-in schemes:');
   lblPalette0.Caption                     := Translate('0');
   lblPalette1.Caption                     := Translate('1');
   lblPalette2.Caption                     := Translate('2');
   lblPalette3.Caption                     := Translate('3');
   lblPalette4.Caption                     := Translate('4');
   lblPalette5.Caption                     := Translate('5');
   lblPalette6.Caption                     := Translate('6');
   lblPalette7.Caption                     := Translate('7');
   lblPalette8.Caption                     := Translate('8');
   lblPalette9.Caption                     := Translate('9');
   lblPalette10.Caption                    := Translate('10');
   lblPalette11.Caption                    := Translate('11');
   lblPalette12.Caption                    := Translate('12');
   lblPalette13.Caption                    := Translate('13');
   lblPalette14.Caption                    := Translate('14');
   lblPalette15.Caption                    := Translate('15');
   lblPalette16.Caption                    := Translate('Foreground');
   lblPalette17.Caption                    := Translate('Background');
   lblBackgroundTransparency.Caption       := Translate('Transparency:');
   tabKeyboard.Caption                     := Translate('Keyboard shortcuts');
   lblShortcutHelp.Caption                 := Translate('To change a shortcut simply click on its name.' + #13#10 + 'To disable a shortcut, press the "Backspace" key.');
   tabQuickOpen.Caption                    := Translate('Quick Open');
   ctlQuickOpenEnable.Caption              := Translate('Enable Quick Open when Ctrl+clicking on a filename in the terminal');
   lblQuickOpenCommandLine.Caption         := Translate('Editor command line:');
   ctlQuickOpenInCurrentTerminal.Caption   := Translate('Quick open in current terminal');
   lblQuickOpenHelp.Caption                := Translate('Quick open is a feature allowing you to open a file directly into your favorite text editor by clicking on its filename when it appears in your terminal.');
   lblQuickOpenArguments.Caption           := Translate('%(file_path)s — ścieżka pliku; %(line_number)s — numer wiersza. Przykład: code -g %(file_path)s:%(line_number)s');
   tabHooks.Caption                        := Translate('Hooks');
   lblHookShow.Caption                     := Translate('On show:');
   lblStartupScript.Caption                := Translate('On start:');
   tabCompatibility.Caption                := Translate('Compatibility');
   lblBackspaceBindingCombobox.Caption     := Translate('_Backspace key generates:');
   lblDeleteBindingCombobox.Caption        := Translate('_Delete key generates:');
   lblWordCharsEntry.Caption               := Translate('_Word characters:');
   btnResetCompatibility.Caption           := Translate('_Reset Compatibility Options to Defaults');
   ctlPromptOnCloseTab.Items[0]            := Translate('Never');
   ctlPromptOnCloseTab.Items[1]            := Translate('With process running');
   ctlPromptOnCloseTab.Items[2]            := Translate('Always');
   ctlSearchEngineSelect.Items[0]          := Translate('Google');
   ctlSearchEngineSelect.Items[1]          := Translate('DuckDuckGo');
   ctlSearchEngineSelect.Items[2]          := Translate('Bing');
   ctlSearchEngineSelect.Items[3]          := Translate('Yandex');
   ctlSearchEngineSelect.Items[4]          := Translate('Neeva');
   ctlSearchEngineSelect.Items[5]          := Translate('Custom');
   ctlTabNameDisplay.Items[0]              := Translate('Full Path');
   ctlTabNameDisplay.Items[1]              := Translate('Abbreviated Path');
   ctlTabNameDisplay.Items[2]              := Translate('Last Segment');
   ctlCursorShape.Items[0]                 := Translate('Block');
   ctlCursorShape.Items[1]                 := Translate('I-Beam');
   ctlCursorShape.Items[2]                 := Translate('Underline');
   ctlCursorBlinkMode.Items[0]             := Translate('Follow GTK+ setting');
   ctlCursorBlinkMode.Items[1]             := Translate('Blink on');
   ctlCursorBlinkMode.Items[2]             := Translate('Blink off');
   ctlBackgroundImageLayoutMode.Items[0]   := Translate('Scale');
   ctlBackgroundImageLayoutMode.Items[1]   := Translate('Tile');
   ctlBackgroundImageLayoutMode.Items[2]   := Translate('Center');
   ctlBackgroundImageLayoutMode.Items[3]   := Translate('Stretch');
   ctlBackspaceBindingCombobox.Items[0]    := Translate('ASCII DEL');
   ctlBackspaceBindingCombobox.Items[1]    := Translate('Escape sequence');
   ctlBackspaceBindingCombobox.Items[2]    := Translate('Control-H');
   ctlDeleteBindingCombobox.Items[0]       := Translate('ASCII DEL');
   ctlDeleteBindingCombobox.Items[1]       := Translate('Escape sequence');
   ctlDeleteBindingCombobox.Items[2]       := Translate('Control-H');
   lblHeaderTitle.Caption                  := Translate('<span size="18000"><b>Guake properties</b></span>');
   lblHeaderDescription.Caption            := Translate('Customize behavior and appearance of Guake!');
   navPages.Items.Clear;
   For varIndex := 0 To pages.PageCount - 1 Do
    navPages.Items.Add(pages.Pages[varIndex].Caption);
   PagesChanged(Nil);
  End;

 Function PlainCaption(Const Value : String) : String;
  Var
   i     : Integer;
   InTag : Boolean;
  Begin
   Result := '';
   InTag  := False;
   For i  := 1 To Length(Value) Do
    If Value[i] = '<' Then
     InTag := True
    Else If Value[i] = '>' Then
     InTag := False
    Else If Not InTag Then
     If Value[i] = '_' Then
      Result := Result + '&'
     Else
      Result := Result + Value[i];
  End;

 Function TfrmPreferences.Translate(Const Source : String) : String;
  Begin
   If fLocalizer <> Nil Then
    Result := fLocalizer.Text(Source)
   Else
    Result := Source;
   Result  := PlainCaption(Result);
  End;

/// <summary>Selects DFM-defined preference pages through the sidebar shown by the original Guake.</summary>

 Procedure TfrmPreferences.NavigationClick(Sender : TObject);
  Begin
   If navPages.ItemIndex >= 0 Then
    pages.ActivePageIndex := navPages.ItemIndex;
  End;

 Procedure TfrmPreferences.PagesChanged(Sender : TObject);
  Begin
   navPages.ItemIndex := pages.ActivePageIndex;
   navPages.Invalidate;
  End;

 Procedure TfrmPreferences.NavigationDrawItem(Control : TWinControl; Index : Integer; Rect : TRect; State : TOwnerDrawState);
  Begin
   If odSelected In State Then
    navPages.Canvas.Brush.Color := clWindow
   Else
    navPages.Canvas.Brush.Color := clBtnFace;
   navPages.Canvas.FillRect(Rect);
   navPages.Canvas.Font.Assign(Font);
   navPages.Canvas.Font.Color := clWindowText;
   DrawText(navPages.Canvas.Handle, PChar(navPages.Items[Index]), -1, Rect, DT_SINGLELINE Or DT_VCENTER Or DT_CENTER Or DT_END_ELLIPSIS);
  End;

 Procedure TfrmPreferences.FormCreate(Sender : TObject);
  Var
   i         : Integer;
   StyleName : String;
  Begin
   LoadGuakeImage(imgHeader, 'GUAKE_GUAKE_48');
   navPages.ItemIndex := 0;
   fLoading           := True;
   For i              := 0 To GuakePaletteCount - 1 Do
    ctlPaletteName.Items.Add(GuakePaletteName(i));
   ctlPaletteName.Items.Add('Custom');
   For StyleName In TStyleManager.StyleNames Do
    ctlGtkThemeName.Items.Add(StyleName);
   ctlDisplayN.Items.Add('Primary');
   For i := 0 To Screen.MonitorCount - 1 Do
    ctlDisplayN.Items.Add(IntToStr(i));
   fLoading := False;
  End;

 Procedure TfrmPreferences.FormDestroy(Sender : TObject);
  Begin
   fSettings  := Nil;
   fLocalizer := Nil;
   fLog       := Nil;
  End;

 Procedure TfrmPreferences.Bind(Settings : TGuakeSettings; Localizer : TGuakeLocalization; Log : TGuakeLog);
  Begin
   If Settings = Nil Then
    Raise EArgumentNilException.Create('Settings');
   fSettings  := Settings;
   fLocalizer := Localizer;
   fLog       := Log;
   Localize;
   LoadControls;
  End;

 Procedure TfrmPreferences.LoadControls;
  Var
   i       : Integer;
   j       : Integer;
   n       : Integer;
   c       : TComponent;
   k       : TGuakeSetting;
   d       : TGuakeSettingDefinition;
   Value   : String;
   Profile : TShellProfile;
   Shell   : TGuakeShell;
  Begin
   If fSettings = Nil Then
    Exit;
   fLoading := True;
   Try
    For i := 0 To ComponentCount - 1 Do
     Begin
      c := Components[i];
      If Not(c Is TControl) Or (c.Tag <= 0) Or (c.Tag > Ord(High(TGuakeSetting)) + 1) Then
       Continue;
      k     := TGuakeSetting(c.Tag - 1);
      d     := TGuakeSettings.Definition(k);
      Value := fSettings.GetValue(k);
      If c Is TRadioButton Then
       TRadioButton(c).Checked := StrToInt(Value) = TRadioButton(c).HelpContext
      Else If c Is TCheckBox Then
       Begin
        If d.Kind = skInteger Then
         TCheckBox(c).Checked := Value <> '0'
        Else
         TCheckBox(c).Checked := SameText(Value, 'true') Or (Value = '1');
       End
      Else If c Is TSpinEdit Then
       TSpinEdit(c).Value := StrToInt(Value)
      Else If c Is TTrackBar Then
       Begin
        If d.Kind = skDouble Then
         n := Round(StrToFloat(Value, TFormatSettings.Invariant) * 100)
        Else
         n := StrToInt(Value);
        If k = gskStyleBackgroundTransparency Then
         n                                                               := 100 - n;
        TTrackBar(c).Position                                            := n;
        TLabel(FindComponent('value' + Copy(c.Name, 4, MaxInt))).Caption :=
        IfThen(d.Kind = skDouble, FormatFloat('0.00', n / 100, TFormatSettings.Invariant), IntToStr(n));
       End
      Else If c Is TComboBox Then
       Begin
        If d.Kind = skInteger Then
         If k = gskGeneralDisplayN Then
          Begin
           j                     := ctlDisplayN.Items.IndexOf(Value);
           ctlDisplayN.ItemIndex := j;
           If j < 0 Then
            ctlDisplayN.Text := Value;
          End
         Else
          TComboBox(c).ItemIndex := StrToInt(Value)
        Else If (k = gskGeneralCompatBackspace) Or (k = gskGeneralCompatDelete) Then
         Begin
          If Value = 'ascii-delete' Then
           j := 0
          Else If Value = 'delete-sequence' Then
           j := 1
          Else If Value = 'ascii-backspace' Then
           j := 2
          Else
           j                     := -1;
          TComboBox(c).ItemIndex := j;
         End
        Else If k = gskGeneralDefaultShell Then
         Begin
          ctlDefaultShell.ItemIndex := -1;
          ctlDefaultShell.Text      := Value;
          If Value = '' Then
           ctlDefaultShell.ItemIndex := 0
          Else
           For Shell := Low(TGuakeShell) To High(TGuakeShell) Do
            Begin
             Profile := TShellProfile.Resolve(Shell);
             If SameText(Profile.Executable, Value) Then
              ctlDefaultShell.ItemIndex := Ord(Shell) + 1;
            End;
         End
        Else
         Begin
          j                      := TComboBox(c).Items.IndexOf(Value);
          TComboBox(c).ItemIndex := j;
          If j < 0 Then
           TComboBox(c).Text := Value;
         End;
       End
      Else If c Is TEdit Then
       TEdit(c).Text := Value
      Else If c = ctlFontStyle Then
       ctlFontStyle.Caption := Value;
     End;
    FillShortcuts;
    LoadPalette;
    UpdateSensitivity;
   Finally
    fLoading := False;
   End;
  End;

 Procedure TfrmPreferences.UpdateSensitivity;
  Begin
   ctlPromptOnQuit.Enabled                 := ctlPromptOnCloseTab.ItemIndex <> 2;
   ctlRestoreTabsNotify.Enabled            := ctlRestoreTabsStartup.Checked;
   ctlTabActivityNewTabGrace.Enabled       := ctlDisplayTabActivity.Checked;
   ctlTabActivityFocusLossGrace.Enabled    := ctlDisplayTabActivity.Checked;
   ctlGtkThemeName.Enabled                 := Not ctlGtkUseSystemDefaultTheme.Checked;
   ctlGtkPreferDarkTheme.Enabled           := Not ctlGtkUseSystemDefaultTheme.Checked;
   ctlCustomSearch.Enabled                 := ctlSearchEngineSelect.ItemIndex = 5;
   ctlLazyLoseFocus.Enabled                := ctlWindowLosefocus.Checked;
   ctlFullscreenHideTabbar.Enabled         := ctlWindowTabbar.Checked;
   ctlHideTabsIfOneTab.Enabled             := ctlWindowTabbar.Checked;
   ctlDisplayN.Enabled                     := Not ctlMouseDisplay.Checked;
   ctlWindowHorizontalDisplacement.Enabled := Not ctlAlignCenter.Checked;
   ctlTabNameDisplay.Enabled               := ctlUseVteTitles.Checked;
   ctlMaxTabNameLength.Enabled             := ctlUseVteTitles.Checked;
   ctlHistorySize.Enabled                  := Not ctlInfiniteHistory.Checked;
   ctlFontStyle.Enabled                    := Not ctlUseDefaultFont.Checked;
   ctlQuickOpenCommandLine.Enabled         := ctlQuickOpenEnable.Checked;
   ctlQuickOpenInCurrentTerminal.Enabled   := ctlQuickOpenEnable.Checked;
  End;

 Function TfrmPreferences.ControlValue(Control : TControl; Key : TGuakeSetting) : String;
  Const
   EraseBindings : Array[0..2] Of String = ('ascii-delete', 'delete-sequence', 'ascii-backspace');
  Var
   Profile : TShellProfile;
   d       : TGuakeSettingDefinition;
   v       : Double;
  Begin
   d := TGuakeSettings.Definition(Key);
   If Control Is TRadioButton Then
    Result := IntToStr(Control.HelpContext)
   Else If Control Is TCheckBox Then
    Begin
     If d.Kind = skInteger Then
      Result := IntToStr(Ord(TCheckBox(Control).Checked))
     Else
      Result := LowerCase(BoolToStr(TCheckBox(Control).Checked, True));
    End
   Else If Control Is TSpinEdit Then
    Result := TSpinEdit(Control).Text
   Else If Control Is TTrackBar Then
    Begin
     v := TTrackBar(Control).Position;
     If d.Kind = skDouble Then
      v := v / 100;
     If Key = gskStyleBackgroundTransparency Then
      v     := 100 - v;
     Result := FloatToStr(v, TFormatSettings.Invariant);
    End
   Else If Control Is TComboBox Then
    Begin
     If Key = gskGeneralDisplayN Then
      If ctlDisplayN.ItemIndex = 0 Then
       Result := '-1'
      Else
       Result := ctlDisplayN.Text
     Else If d.Kind = skInteger Then
      Result := IntToStr(TComboBox(Control).ItemIndex)
     Else If (Key = gskGeneralCompatBackspace) Or (Key = gskGeneralCompatDelete) Then
      Begin
       If (TComboBox(Control).ItemIndex < 0) Or (TComboBox(Control).ItemIndex > 2) Then
        Raise EArgumentException.Create('Select an erase binding');
       Result := EraseBindings[TComboBox(Control).ItemIndex];
      End
     Else If Key = gskGeneralDefaultShell Then
      Begin
       If ctlDefaultShell.ItemIndex = 0 Then
        Result := ''
       Else If ctlDefaultShell.ItemIndex In [1..4] Then
        Begin
         Profile := TShellProfile.Resolve(TGuakeShell(ctlDefaultShell.ItemIndex - 1));
         Result  := Profile.Executable;
        End
       Else
        Result := ctlDefaultShell.Text;
      End
     Else
      Result := TComboBox(Control).Text;
    End
   Else If Control Is TEdit Then
    Result := TEdit(Control).Text
   Else
    Result := fSettings.GetValue(Key);
  End;

 Procedure TfrmPreferences.Commit(Candidate : TGuakeSettings);
  Begin
   Candidate.Save;
   fSettings.Assign(Candidate);
   LoadControls;
   If Assigned(fOnSettingsChanged) Then
    fOnSettingsChanged(Self);
  End;

 Procedure TfrmPreferences.SetPreference(Key : TGuakeSetting; Const Value : String);
  Var
   Candidate : TGuakeSettings;
  Begin
   If fSettings = Nil Then
    Raise EInvalidOpException.Create('Preferences are not bound');
   Candidate := TGuakeSettings.Create(fSettings.FileName);
   Try
    Candidate.Assign(fSettings);
    Candidate.SetValue(Key, Value);
    Commit(Candidate);
   Finally
    Candidate.Free;
   End;
  End;

 Procedure TfrmPreferences.SettingChanged(Sender : TObject);
  Var
   c         : TControl;
   k         : TGuakeSetting;
   Value     : String;
   Candidate : TGuakeSettings;
   i         : Integer;
  Begin
   If fLoading Or (fSettings = Nil) Or Not(Sender Is TControl) Then
    Exit;
   c := TControl(Sender);
   If (c Is TRadioButton) And Not TRadioButton(c).Checked Then
    Exit;
   If (c.Tag < 1) Or (c.Tag > Ord(High(TGuakeSetting)) + 1) Then
    Exit;
   // Editable combo boxes commit a selected item immediately, and typed text on exit.
   If (c Is TComboBox) And (TComboBox(c).Style = csDropDown) And TComboBox(c).Focused And (TComboBox(c).ItemIndex < 0) Then
    Exit;
   k     := TGuakeSetting(c.Tag - 1);
   Value := ControlValue(c, k);
   If fSettings.GetValue(k) = Value Then
    Exit;
   Try
    If k = gskStyleFontPaletteName Then
     Begin
      i := ctlPaletteName.Items.IndexOf(Value);
      If (i < 0) Or (i >= GuakePaletteCount) Then
       Exit;
      Candidate := TGuakeSettings.Create(fSettings.FileName);
      Try
       Candidate.Assign(fSettings);
       Candidate.Style.Font.PaletteName := GuakePaletteName(i);
       Candidate.Style.Font.Palette     := GuakePaletteValue(i);
       Commit(Candidate);
      Finally
       Candidate.Free;
      End;
     End
    Else
     SetPreference(k, Value);
   Except
    LoadControls;
    Raise;
   End;
  End;

 Procedure TfrmPreferences.BrowseClick(Sender : TObject);
  Var
   d : TOpenDialog;
   k : TGuakeSetting;
  Begin
   If fSettings = Nil Then
    Exit;
   k := TGuakeSetting(TControl(Sender).Tag - 1);
   If k = gskGeneralBackgroundImageFile Then
    d := dlgBackground
   Else
    d         := dlgCustomCommands;
   d.FileName := fSettings.GetValue(k);
   If d.Execute(Handle) Then
    SetPreference(k, d.FileName);
  End;

 Procedure TfrmPreferences.ClearBackgroundClick(Sender : TObject);
  Begin
   SetPreference(gskGeneralBackgroundImageFile, '');
  End;

 Procedure TfrmPreferences.FontClick(Sender : TObject);
  Var
   Value : String;
   Name  : String;
   p     : Integer;
   Size  : Integer;
  Begin
   Value             := fSettings.Style.Font.Style;
   p                 := LastDelimiter(' ', Value);
   Name              := Copy(Value, 1, p - 1);
   Size              := StrToIntDef(Copy(Value, p + 1, MaxInt), 10);
   dlgFont.Font.Name := Name;
   dlgFont.Font.Size := Size;
   If dlgFont.Execute(Handle) Then
    SetPreference(gskStyleFontStyle, dlgFont.Font.Name + ' ' + IntToStr(dlgFont.Font.Size));
  End;

 Function ParsePaletteColor(Const Value : String) : TColor;
  Var
   Text : String;
   r    : Integer;
   g    : Integer;
   b    : Integer;
  Begin
   Text := Value;
   If Copy(Text, 1, 1) = '#' Then
    Delete(Text, 1, 1);
   If Length(Text) = 12 Then
    Begin
     r := StrToIntDef('$' + Copy(Text, 1, 4), 0) Div 257;
     g := StrToIntDef('$' + Copy(Text, 5, 4), 0) Div 257;
     b := StrToIntDef('$' + Copy(Text, 9, 4), 0) Div 257;
    End
   Else If Length(Text) = 6 Then
    Begin
     r := StrToIntDef('$' + Copy(Text, 1, 2), 0);
     g := StrToIntDef('$' + Copy(Text, 3, 2), 0);
     b := StrToIntDef('$' + Copy(Text, 5, 2), 0);
    End
   Else
    Begin
     r := 0;
     g := 0;
     b := 0;
    End;
   Result := RGB(r, g, b);
  End;

 Procedure TfrmPreferences.LoadPalette;
  Var
   Colors : TArray<String>;
   i      : Integer;
   Box    : TColorBox;
  Begin
   Colors := fSettings.Style.Font.Palette.Split([':']);
   For i  := 0 To Min(17, High(Colors)) Do
    Begin
     Box          := TColorBox(FindComponent('colorPalette' + IntToStr(i)));
     Box.Selected := ParsePaletteColor(Colors[i]);
    End;
   paletteDemo.Invalidate;
  End;

 Procedure TfrmPreferences.PaletteColorChanged(Sender : TObject);
  Var
   Colors    : TArray<String>;
   Index     : Integer;
   i         : Integer;
   Color     : COLORREF;
   Candidate : TGuakeSettings;
   Value     : String;
  Begin
   If fLoading Or (fSettings = Nil) Then
    Exit;
   Colors := fSettings.Style.Font.Palette.Split([':']);
   If Length(Colors) <> 18 Then
    Colors       := TGuakeSettings.Definition(gskStyleFontPalette).DefaultValue.Split([':']);
   Index         := -TControl(Sender).Tag - 100;
   Color         := ColorToRGB(TColorBox(Sender).Selected);
   Colors[Index] := Format('#%.4x%.4x%.4x', [GetRValue(Color) * 257, GetGValue(Color) * 257, GetBValue(Color) * 257]);
   Value         := '';
   For i         := 0 To High(Colors) Do
    Begin
     If i > 0 Then
      Value := Value + ':';
     Value  := Value + Colors[i];
    End;
   Candidate := TGuakeSettings.Create(fSettings.FileName);
   Try
    Candidate.Assign(fSettings);
    Candidate.Style.Font.Palette     := Value;
    Candidate.Style.Font.PaletteName := 'Custom';
    Commit(Candidate);
   Finally
    Candidate.Free;
   End;
  End;

 Procedure TfrmPreferences.DemoPaint(Sender : TObject);
  Var
   i     : Integer;
   Width : Integer;
   r     : TRect;
   Box   : TColorBox;
  Begin
   paletteDemo.Canvas.Brush.Color := colorPalette17.Selected;
   paletteDemo.Canvas.FillRect(paletteDemo.ClientRect);
   paletteDemo.Canvas.Font.Name  := 'Consolas';
   paletteDemo.Canvas.Font.Color := colorPalette16.Selected;
   paletteDemo.Canvas.TextOut(12, 8, 'Guake > CMD | PowerShell | Bash | Zsh');
   Width := (paletteDemo.Width - 24) Div 16;
   For i := 0 To 15 Do
    Begin
     Box                            := TColorBox(FindComponent('colorPalette' + IntToStr(i)));
     paletteDemo.Canvas.Brush.Color := Box.Selected;
     r                              := Rect(12 + i * Width, 38, 12 + (i + 1) * Width - 3, 64);
     paletteDemo.Canvas.FillRect(r);
    End;
  End;

 Procedure TfrmPreferences.FillShortcuts;
  Var
   k        : TGuakeSetting;
   d        : TGuakeSettingDefinition;
   n        : Integer;
   Selected : Integer;
  Begin
   Selected := gridShortcuts.Row;
   SetLength(fShortcutKeys, 0);
   For k := Low(TGuakeSetting) To High(TGuakeSetting) Do
    Begin
     d := TGuakeSettings.Definition(k);
     If Pos('keybindings.', d.Section) <> 1 Then
      Continue;
     n := Length(fShortcutKeys);
     SetLength(fShortcutKeys, n + 1);
     fShortcutKeys[n] := k;
    End;
   gridShortcuts.RowCount     := Length(fShortcutKeys) + 1;
   gridShortcuts.Cells[0, 0]  := Translate('Action');
   gridShortcuts.Cells[1, 0]  := Translate('Shortcut');
   gridShortcuts.ColWidths[0] := 560;
   gridShortcuts.ColWidths[1] := 300;
   For n                      := 0 To High(fShortcutKeys) Do
    Begin
     d                             := TGuakeSettings.Definition(fShortcutKeys[n]);
     gridShortcuts.Cells[0, n + 1] := Translate(d.Summary);
     gridShortcuts.Cells[1, n + 1] := fSettings.GetValue(fShortcutKeys[n]);
    End;
   gridShortcuts.Row := EnsureRange(Selected, 1, gridShortcuts.RowCount - 1);
  End;

 Function CanonicalShortcut(Const Value : String) : String;
  Var
   s         : String;
   Key       : Word;
   Modifiers : Cardinal;
  Begin
   If ParseAccelerator(Value, Key, Modifiers) Then
    Exit(Format('%d:%d', [Key, Modifiers]));
   s      := LowerCase(Value);
   Result := '';
   If (Pos('<control>', s) > 0) Or (Pos('<primary>', s) > 0) Then
    Result := '<control>';
   If Pos('<alt>', s) > 0 Then
    Result := Result + '<alt>';
   If Pos('<shift>', s) > 0 Then
    Result := Result + '<shift>';
   If Pos('<super>', s) > 0 Then
    Result := Result + '<super>';
   s       := StringReplace(s, '<control>', '', [rfReplaceAll]);
   s       := StringReplace(s, '<primary>', '', [rfReplaceAll]);
   s       := StringReplace(s, '<alt>', '', [rfReplaceAll]);
   s       := StringReplace(s, '<shift>', '', [rfReplaceAll]);
   s       := StringReplace(s, '<super>', '', [rfReplaceAll]);
   Result  := Result + s;
  End;

 Procedure TfrmPreferences.SetShortcut(Key : TGuakeSetting; Const Accelerator : String);
  Var
   Other : TGuakeSetting;
   d     : TGuakeSettingDefinition;
  Begin
   If Pos('keybindings.', TGuakeSettings.Definition(Key).Section) <> 1 Then
    Raise EArgumentException.Create('Not a shortcut setting');
   If (Accelerator <> '') And Not SameText(Accelerator, 'disabled') Then
    For Other := Low(TGuakeSetting) To High(TGuakeSetting) Do
     Begin
      d := TGuakeSettings.Definition(Other);
      If (Other <> Key) And (Pos('keybindings.', d.Section) = 1) And
      (CanonicalShortcut(fSettings.GetValue(Other)) = CanonicalShortcut(Accelerator)) Then
       Raise EArgumentException.CreateFmt('%s: %s', [Translate('Shortcut already in use'), Translate(d.Summary)]);
     End;
   SetPreference(Key, Accelerator);
  End;

 Procedure TfrmPreferences.ShortcutDblClick(Sender : TObject);
  Begin
   fCapturingShortcut                        := True;
   gridShortcuts.Cells[1, gridShortcuts.Row] := Translate('Press a key combination');
  End;

 Procedure TfrmPreferences.ShortcutKeyDown(Sender : TObject; Var Key : Word; Shift : TShiftState);
  Var
   Accelerator : String;
   Name        : String;
  Begin
   If Not fCapturingShortcut Or (gridShortcuts.Row < 1) Then
    Exit;
   If Key = VK_ESCAPE Then
    Begin
     fCapturingShortcut := False;
     FillShortcuts;
     Key := 0;
     Exit;
    End;
   If Key In [VK_SHIFT, VK_CONTROL, VK_MENU, VK_LWIN, VK_RWIN] Then
    Exit;
   If Key = VK_BACK Then
    Accelerator := 'disabled'
   Else
    Begin
     Name := '';
     If (Key >= Ord('A')) And (Key <= Ord('Z')) Then
      Name := LowerCase(Char(Key))
     Else If (Key >= Ord('0')) And (Key <= Ord('9')) Then
      Name := Char(Key)
     Else If (Key >= VK_F1) And (Key <= VK_F24) Then
      Name := 'F' + IntToStr(Key - VK_F1 + 1)
     Else
      Case Key Of
       VK_RETURN :
        Name := 'Return';
       VK_TAB :
        Name := 'Tab';
       VK_SPACE :
        Name := 'space';
       VK_PRIOR :
        Name := 'Page_Up';
       VK_NEXT :
        Name := 'Page_Down';
       VK_HOME :
        Name := 'Home';
       VK_END :
        Name := 'End';
       VK_UP :
        Name := 'Up';
       VK_DOWN :
        Name := 'Down';
       VK_LEFT :
        Name := 'Left';
       VK_RIGHT :
        Name := 'Right';
       VK_INSERT :
        Name := 'Insert';
       VK_DELETE :
        Name := 'Delete';
       VK_OEM_PLUS :
        If ssShift In Shift Then
         Name := 'plus'
        Else
         Name := 'equal';
       VK_OEM_3 :
        If ssShift In Shift Then
         Name := 'asciitilde'
        Else
         Name := 'grave';
       VK_OEM_MINUS :
        Name := 'minus';
       VK_OEM_COMMA :
        Name := 'comma';
       VK_OEM_PERIOD :
        Name := 'period';
      End;
     If Name = '' Then
      Exit;
     Accelerator := '';
     If ssCtrl In Shift Then
      Accelerator := Accelerator + '<Control>';
     If ssAlt In Shift Then
      Accelerator := Accelerator + '<Alt>';
     If ssShift In Shift Then
      Accelerator := Accelerator + '<Shift>';
     If (GetKeyState(VK_LWIN) < 0) Or (GetKeyState(VK_RWIN) < 0) Then
      Accelerator := Accelerator + '<Super>';
     Accelerator  := Accelerator + Name;
    End;
   Key := 0;
   Try
    SetShortcut(fShortcutKeys[gridShortcuts.Row - 1], Accelerator);
   Finally
    fCapturingShortcut := False;
    FillShortcuts;
   End;
  End;

 Procedure TfrmPreferences.ResetCompatibility;
  Var
   Candidate : TGuakeSettings;
  Begin
   Candidate := TGuakeSettings.Create(fSettings.FileName);
   Try
    Candidate.Assign(fSettings);
    Candidate.Reset(gskGeneralCompatBackspace);
    Candidate.Reset(gskGeneralCompatDelete);
    Candidate.Reset(gskGeneralWordChars);
    Commit(Candidate);
   Finally
    Candidate.Free;
   End;
  End;

 Procedure TfrmPreferences.ResetCompatibilityClick(Sender : TObject);
  Begin
   ResetCompatibility;
  End;

 Procedure TfrmPreferences.CloseClick(Sender : TObject);
  Begin
   If fsModal In FormState Then
    ModalResult := mrClose
   Else
    Close;
  End;

 Procedure TfrmPreferences.FormClose(Sender : TObject; Var Action : TCloseAction);
  Begin
   If (ActiveControl Is TEdit) Or (ActiveControl Is TSpinEdit) Or (ActiveControl Is TComboBox) Then
    SettingChanged(ActiveControl);
  End;

 Procedure TfrmPreferences.ApplicationException(Sender : TObject; e : Exception);
  Begin
   If e Is EAbort Then
    Exit;
   If fLog <> Nil Then
    fLog.TryLogException(e, 'Preferences');
   If Assigned(fOnError) Then
    fOnError(Sender, e)
   Else
    Application.ShowException(e);
  End;

End.
