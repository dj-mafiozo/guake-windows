{$StackFrames On}

/// <summary>Typed hierarchical Guake preferences, schema metadata and validated UTF-8 INI persistence.</summary>
Unit Guake.Settings;

// Schema and defaults ported from Guake org.guake.gschema.xml (GPL-2.0-or-later).

Interface

 Uses
  System.SysUtils, System.Classes, System.IniFiles;

 Type
  TGuakeSettingKind = (skString, skInteger, skBoolean, skDouble);
{FLD+}

  TGuakeSetting =
   (
    gskGeneralSchemaVersion,
    gskGeneralDebugMode,
    gskGeneralMouseDisplay,
    gskGeneralDisplayN,
    gskGeneralDefaultShell,
    gskGeneralRestoreTabsStartup,
    gskGeneralRestoreTabsNotify,
    gskGeneralSaveTabsWhenChanged,
    gskGeneralLoadGuakeYml,
    gskGeneralUseLoginShell,
    gskGeneralUseTrayicon,
    gskGeneralWorkspaceSpecificTabSets,
    gskGeneralUsePopup,
    gskGeneralPromptOnQuit,
    gskGeneralPromptOnCloseTab,
    gskGeneralSearchEngine,
    gskGeneralCustomSearchEngine,
    gskGeneralWindowOntop,
    gskGeneralWindowRefocus,
    gskGeneralTabOntop,
    gskGeneralNewTabAfter,
    gskGeneralWindowLosefocus,
    gskGeneralLazyLosefocus,
    gskGeneralWindowTabbar,
    gskGeneralFullscreenHideTabbar,
    gskGeneralHideTabsIfOneTab,
    gskGeneralQuickOpenEnable,
    gskGeneralQuickOpenCommandLine,
    gskGeneralQuickOpenInCurrentTerminal,
    gskGeneralStartupScript,
    gskGeneralStartFullscreen,
    gskGeneralStartAtLogin,
    gskGeneralUseAudibleBell,
    gskGeneralDisplayTabActivity,
    gskGeneralTabActivityNewTabGrace,
    gskGeneralTabActivityFocusLossGrace,
    gskGeneralWindowWidth,
    gskGeneralWindowHeight,
    gskGeneralWindowHorizontalDisplacement,
    gskGeneralWindowVerticalDisplacement,
    gskGeneralWindowHalignment,
    gskGeneralWindowValignment,
    gskGeneralBackgroundImageFile,
    gskGeneralBackgroundImageLayoutMode,
    gskGeneralUseScrollbar,
    gskGeneralHistorySize,
    gskGeneralInfiniteHistory,
    gskGeneralScrollOutput,
    gskGeneralScrollKeystroke,
    gskGeneralUseDefaultFont,
    gskGeneralUseVteTitles,
    gskGeneralSetWindowTitle,
    gskGeneralCompatBackspace,
    gskGeneralCompatDelete,
    gskGeneralWordChars,
    gskGeneralToolbarVisibleInFullscreen,
    gskGeneralFocusIfOpen,
    gskGeneralCustomCommandFile,
    gskGeneralOpenTabCwd,
    gskGeneralMaxTabNameLength,
    gskGeneralDisplayTabNames,
    gskGeneralGtkUseSystemDefaultTheme,
    gskGeneralGtkThemeName,
    gskGeneralGtkPreferDarkTheme,
    gskGeneralTabCloseButtons,
    gskGeneralCopyOnSelect,
    gskStyleCursorBlinkMode,
    gskStyleCursorShape,
    gskStyleFontStyle,
    gskStyleFontPalette,
    gskStyleFontPaletteName,
    gskStyleFontAllowBold,
    gskStyleFontBoldIsBright,
    gskStyleFontCellHeightScale,
    gskStyleFontCellWidthScale,
    gskStyleBackgroundTransparency,
    gskKeybindingsGlobalShowHide,
    gskKeybindingsGlobalShowFocus,
    gskKeybindingsLocalSearchTerminal,
    gskKeybindingsLocalQuit,
    gskKeybindingsLocalNewTab,
    gskKeybindingsLocalNewTabHome,
    gskKeybindingsLocalNewTabCwd,
    gskKeybindingsLocalCloseTab,
    gskKeybindingsLocalSearchOnWeb,
    gskKeybindingsLocalOpenLinkUnderTerminalCursor,
    gskKeybindingsLocalMoveTabLeft,
    gskKeybindingsLocalMoveTabRight,
    gskKeybindingsLocalPreviousTab,
    gskKeybindingsLocalNextTab,
    gskKeybindingsLocalPreviousTabAlt,
    gskKeybindingsLocalNextTabAlt,
    gskKeybindingsLocalSwitchTab1,
    gskKeybindingsLocalSwitchTab2,
    gskKeybindingsLocalSwitchTab3,
    gskKeybindingsLocalSwitchTab4,
    gskKeybindingsLocalSwitchTab5,
    gskKeybindingsLocalSwitchTab6,
    gskKeybindingsLocalSwitchTab7,
    gskKeybindingsLocalSwitchTab8,
    gskKeybindingsLocalSwitchTab9,
    gskKeybindingsLocalSwitchTab10,
    gskKeybindingsLocalRenameCurrentTab,
    gskKeybindingsLocalZoomIn,
    gskKeybindingsLocalZoomInAlt,
    gskKeybindingsLocalZoomOut,
    gskKeybindingsLocalIncreaseHeight,
    gskKeybindingsLocalDecreaseHeight,
    gskKeybindingsLocalIncreaseTransparency,
    gskKeybindingsLocalDecreaseTransparency,
    gskKeybindingsLocalClipboardCopy,
    gskKeybindingsLocalClipboardPaste,
    gskKeybindingsLocalSelectAll,
    gskKeybindingsLocalToggleFullscreen,
    gskKeybindingsLocalToggleHideOnLoseFocus,
    gskKeybindingsLocalResetTerminal,
    gskKeybindingsLocalToggleTransparency,
    gskKeybindingsLocalSwitchTabLast,
    gskKeybindingsLocalSplitTabVertical,
    gskKeybindingsLocalSplitTabHorizontal,
    gskKeybindingsLocalCloseTerminal,
    gskKeybindingsLocalFocusTerminalUp,
    gskKeybindingsLocalFocusTerminalDown,
    gskKeybindingsLocalFocusTerminalRight,
    gskKeybindingsLocalFocusTerminalLeft,
    gskKeybindingsLocalMoveTerminalSplitUp,
    gskKeybindingsLocalMoveTerminalSplitDown,
    gskKeybindingsLocalMoveTerminalSplitLeft,
    gskKeybindingsLocalMoveTerminalSplitRight,
    gskHooksShow
   );
{FLD-}

  TGuakeSettingDefinition = Record
   Section      : String;
   Key          : String;
   DefaultValue : String;
   Summary      : String;
   Description  : String;
   Kind         : TGuakeSettingKind;
   HasRange     : Boolean;
   Minimum      : Double;
   Maximum      : Double;
  End;

  TGuakeGeneralSettings = Record
   SchemaVersion                : String;
   DebugMode                    : Boolean;
   MouseDisplay                 : Boolean;
   DisplayN                     : Integer;
   DefaultShell                 : String;
   RestoreTabsStartup           : Boolean;
   RestoreTabsNotify            : Boolean;
   SaveTabsWhenChanged          : Boolean;
   LoadGuakeYml                 : Boolean;
   UseLoginShell                : Boolean;
   UseTrayicon                  : Boolean;
   WorkspaceSpecificTabSets     : Boolean;
   UsePopup                     : Boolean;
   PromptOnQuit                 : Boolean;
   PromptOnCloseTab             : Integer;
   SearchEngine                 : Integer;
   CustomSearchEngine           : String;
   WindowOntop                  : Boolean;
   WindowRefocus                : Boolean;
   TabOntop                     : Boolean;
   NewTabAfter                  : Boolean;
   WindowLosefocus              : Boolean;
   LazyLosefocus                : Boolean;
   WindowTabbar                 : Boolean;
   FullscreenHideTabbar         : Boolean;
   HideTabsIfOneTab             : Boolean;
   QuickOpenEnable              : Boolean;
   QuickOpenCommandLine         : String;
   QuickOpenInCurrentTerminal   : Boolean;
   StartupScript                : String;
   StartFullscreen              : Boolean;
   StartAtLogin                 : Boolean;
   UseAudibleBell               : Boolean;
   DisplayTabActivity           : Boolean;
   TabActivityNewTabGrace       : Double;
   TabActivityFocusLossGrace    : Double;
   WindowWidth                  : Integer;
   WindowHeight                 : Integer;
   WindowHorizontalDisplacement : Integer;
   WindowVerticalDisplacement   : Integer;
   WindowHalignment             : Integer;
   WindowValignment             : Integer;
   BackgroundImageFile          : String;
   BackgroundImageLayoutMode    : Integer;
   UseScrollbar                 : Boolean;
   HistorySize                  : Integer;
   InfiniteHistory              : Boolean;
   ScrollOutput                 : Boolean;
   ScrollKeystroke              : Boolean;
   UseDefaultFont               : Boolean;
   UseVteTitles                 : Boolean;
   SetWindowTitle               : Boolean;
   CompatBackspace              : String;
   CompatDelete                 : String;
   WordChars                    : String;
   ToolbarVisibleInFullscreen   : Boolean;
   FocusIfOpen                  : Boolean;
   CustomCommandFile            : String;
   OpenTabCwd                   : Boolean;
   MaxTabNameLength             : Integer;
   DisplayTabNames              : Integer;
   GtkUseSystemDefaultTheme     : Boolean;
   GtkThemeName                 : String;
   GtkPreferDarkTheme           : Boolean;
   TabCloseButtons              : Boolean;
   CopyOnSelect                 : Boolean;
  End;

  TGuakeFontSettings = Record
   Style           : String;
   Palette         : String;
   PaletteName     : String;
   AllowBold       : Boolean;
   BoldIsBright    : Boolean;
   CellHeightScale : Double;
   CellWidthScale  : Double;
  End;

  TGuakeBackgroundSettings = Record
   Transparency : Integer;
  End;

  TGuakeStyleSettings = Record
   CursorBlinkMode : Integer;
   CursorShape     : Integer;
   Font            : TGuakeFontSettings;
   Background      : TGuakeBackgroundSettings;
  End;

  TGuakeGlobalKeybindings = Record
   ShowHide  : String;
   ShowFocus : String;
  End;

  TGuakeLocalKeybindings = Record
   SearchTerminal              : String;
   Quit                        : String;
   NewTab                      : String;
   NewTabHome                  : String;
   NewTabCwd                   : String;
   CloseTab                    : String;
   SearchOnWeb                 : String;
   OpenLinkUnderTerminalCursor : String;
   MoveTabLeft                 : String;
   MoveTabRight                : String;
   PreviousTab                 : String;
   NextTab                     : String;
   PreviousTabAlt              : String;
   NextTabAlt                  : String;
   SwitchTab1                  : String;
   SwitchTab2                  : String;
   SwitchTab3                  : String;
   SwitchTab4                  : String;
   SwitchTab5                  : String;
   SwitchTab6                  : String;
   SwitchTab7                  : String;
   SwitchTab8                  : String;
   SwitchTab9                  : String;
   SwitchTab10                 : String;
   RenameCurrentTab            : String;
   ZoomIn                      : String;
   ZoomInAlt                   : String;
   ZoomOut                     : String;
   IncreaseHeight              : String;
   DecreaseHeight              : String;
   IncreaseTransparency        : String;
   DecreaseTransparency        : String;
   ClipboardCopy               : String;
   ClipboardPaste              : String;
   SelectAll                   : String;
   ToggleFullscreen            : String;
   ToggleHideOnLoseFocus       : String;
   ResetTerminal               : String;
   ToggleTransparency          : String;
   SwitchTabLast               : String;
   SplitTabVertical            : String;
   SplitTabHorizontal          : String;
   CloseTerminal               : String;
   FocusTerminalUp             : String;
   FocusTerminalDown           : String;
   FocusTerminalRight          : String;
   FocusTerminalLeft           : String;
   MoveTerminalSplitUp         : String;
   MoveTerminalSplitDown       : String;
   MoveTerminalSplitLeft       : String;
   MoveTerminalSplitRight      : String;
  End;

  TGuakeHookSettings = Record
   Show : String;
  End;

  TGuakeKeybindings = Record
   Global : TGuakeGlobalKeybindings;
   Local  : TGuakeLocalKeybindings;
  End;

  TGuakeSettings = Class
   Private
    fIni      : TMemIniFile;
    fFileName : String;
    Procedure LoadRecords;
    Procedure SetRecordValue (Key : TGuakeSetting; Const Value : String);
    Function  GetStringValue (Index : Integer) : String;
    Function  GetIntegerValue(Index : Integer) : Integer;

    Procedure SetStringValue (Index : Integer; Const Value : String);
    Procedure SetIntegerValue(Index, Value : Integer);
   Public
    General     : TGuakeGeneralSettings;
    Style       : TGuakeStyleSettings;
    Keybindings : TGuakeKeybindings;
    Hooks       : TGuakeHookSettings;
    /// <summary>Initializes this service and acquires the resources whose lifetime it owns.</summary>
    Constructor    Create(Const FileName : String);
    /// <summary>Releases owned resources; borrowed settings and view references are not freed.</summary>
    Destructor     Destroy; Override;
    /// <summary>Returns the user-specific configuration file under APPDATA.</summary>
    Class Function DefaultFileName : String; Static;
    /// <summary>Returns the original schema key, type, default and validation metadata.</summary>
    Class Function Definition(Key : TGuakeSetting) : TGuakeSettingDefinition; Static;
    /// <summary>Resolves an INI section and name to a typed schema identifier.</summary>
    Class Function FindKey(Const Section, Name : String; Out Key : TGuakeSetting) : Boolean; Static;
    /// <summary>Validates textual data against the schema type and preference editor limits.</summary>
    Class Function ValidValue(Key : TGuakeSetting; Const Value : String) : Boolean; Static;
    /// <summary>Discards in-memory edits and reloads records from the UTF-8 settings file.</summary>
    Procedure      Reload;
    /// <summary>Validates records and replaces the settings file through a temporary file in the same directory.</summary>
    Procedure      Save;
    /// <summary>Copies preference records and unknown INI entries without changing the target file path.</summary>
    Procedure Assign(Source : TGuakeSettings);
    Procedure Reset (Key : TGuakeSetting);
    /// <summary>Serializes the current hierarchical record field using invariant numeric formatting.</summary>
    Function       GetValue(Key : TGuakeSetting) : String;
    /// <summary>Validates and updates one hierarchical preference without writing the file implicitly.</summary>
    Procedure SetValue    (Key : TGuakeSetting; Const Value : String);
    Function  ReadString  (Const Section, Key, Default : String)           : String;
    Function  ReadInteger (Const Section, Key : String; Default : Integer) : Integer;
    Function  ReadBool    (Const Section, Key : String; Default : Boolean) : Boolean;
    Procedure WriteString (Const Section, Key, Value : String);
    Procedure WriteInteger(Const Section, Key : String; Value : Integer);
    Procedure WriteBool   (Const Section, Key : String; Value : Boolean);
    Property FileName     : String Read fFileName;
    Property WindowWidth  : Integer Index 36 Read GetIntegerValue Write SetIntegerValue;
    Property WindowHeight : Integer Index 37 Read GetIntegerValue Write SetIntegerValue;
    Property HistorySize  : Integer Index 45 Read GetIntegerValue Write SetIntegerValue;
    Property Shell        : String Index 4 Read GetStringValue Write SetStringValue;
  End;

Implementation

 Uses
  Winapi.Windows, System.IOUtils, System.Math;
{FLD+}

 Const
  Definitions : Array[TGuakeSetting] Of TGuakeSettingDefinition =
   (
    (Section: 'general';            Key: 'schema-version';                  DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'Last used schema version';                                   Description: 'If schema version is not equal to current guake version, the schema file is regenerated and this flag is set to the current guake version.';                                                                                                                                                                                                                          Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'debug-mode';                      DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Enable debug mode';                                          Description: 'When debug mode is enabled, logs are printed in the standard output where Guake as been launched';                                                                                                                                                                                                                                                                    Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'mouse-display';                   DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Appear on the mouse display.';                               Description: 'Appear on the mouse display. This overrides any setting in display_n.';                                                                                                                                                                                                                                                                                               Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'display-n';                       DefaultValue: '0';                                                                                                                                                                                                                                                               Summary: 'Display to appear on.';                                      Description: 'Display to appear on if the  mouse_display option is not set. If this is set to an invalid value (as in the case of removing a screen from a system), the invalid value is automatically updated to the current primary screen.';                                                                                                                                     Kind: skInteger; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'default-shell';                   DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'Path to the default shell.';                                 Description: 'Path to the default shell. Set to empty to use default user shell. If invalid path is set here, guake will fallback to user shell.';                                                                                                                                                                                                                                  Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'restore-tabs-startup';            DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Restore tabs when startup';                                  Description: 'If true, when guake startup, it will restore tabs from previous session';                                                                                                                                                                                                                                                                                             Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'restore-tabs-notify';             DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Notify when restored the tabs';                              Description: 'If true, when guake restored the tabs, it will notify the user that the tabs has been restored';                                                                                                                                                                                                                                                                      Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'save-tabs-when-changed';          DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Automatically save tabs session when changed';               Description: 'If true, when tabs has changed (add / delete ...etc.), it will automatically saved the tabs session';                                                                                                                                                                                                                                                                 Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'load-guake-yml';                  DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Load settings from guake.yml';                               Description: 'If true, when a change in the cwd is detected settings are changed based on the content of the file `cwd`/.guake.yml';                                                                                                                                                                                                                                                Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'use-login-shell';                 DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Login shell';                                                Description: 'If true, the commands in terminal will be executed in a login shell.';                                                                                                                                                                                                                                                                                                Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'use-trayicon';                    DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Sets the tray visibility.';                                  Description: 'When true tray is visible.';                                                                                                                                                                                                                                                                                                                                          Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'workspace-specific-tab-sets';     DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Use workspace specific tab sets';                            Description: 'When true, each workspace gets their own set of tabs.';                                                                                                                                                                                                                                                                                                               Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'use-popup';                       DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Sets the popup notifications visibility.';                   Description: 'When true, popup notifications will be shown when Guake starts.';                                                                                                                                                                                                                                                                                                     Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'prompt-on-quit';                  DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Prompt when quitting.';                                      Description: 'Ask for confirmation when quitting Guake.';                                                                                                                                                                                                                                                                                                                           Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'prompt-on-close-tab';             DefaultValue: '0';                                                                                                                                                                                                                                                               Summary: 'Prompt when closing tabs.';                                  Description: '0: Never 1: If process is running 2: Always.  Also prompts on quit.';                                                                                                                                                                                                                                                                                                 Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 2),
    (Section: 'general';            Key: 'search-engine';                   DefaultValue: '0';                                                                                                                                                                                                                                                               Summary: 'Search engine to use when using web search';                 Description: 'Search engine to use';                                                                                                                                                                                                                                                                                                                                                Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 5),
    (Section: 'general';            Key: 'custom-search-engine';            DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'Search engine to use when using web search';                 Description: 'Custom search engine url to use';                                                                                                                                                                                                                                                                                                                                     Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'window-ontop';                    DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Stay on top.';                                               Description: 'Makes guake window be on top of all other windows in the desktop.';                                                                                                                                                                                                                                                                                                   Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'window-refocus';                  DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Refocus window.';                                            Description: 'Refocus window instead of closing.';                                                                                                                                                                                                                                                                                                                                  Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'tab-ontop';                       DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Tab on top.';                                                Description: 'Makes tab bar on top of the Guake window. Per default, tabs appear below the terminal. Setting this to True will move the tab on top of the terminal. Requires a restart.';                                                                                                                                                                                           Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'new-tab-after';                   DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'New tabs appear after the current tab.';                     Description: 'Makes new tabs appear after the currently selected tab, instead of at the end.';                                                                                                                                                                                                                                                                                      Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'window-losefocus';                DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Determine if guake hides on lose focus.';                    Description: 'If this property is set as true, guake will be hidden when the main window lose the focus (when Alt+Tab be pressed for example).';                                                                                                                                                                                                                                    Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'lazy-losefocus';                  DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Delay hiding on losing focus.';                              Description: 'Momentarily delay hiding Guake when focus is lost and don''t hide if focus is returned quickly, like when switching desktops or turning on certain IMEs.';                                                                                                                                                                                                            Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'window-tabbar';                   DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'The tab bar visibility.';                                    Description: 'When true, the tab bar is visible.';                                                                                                                                                                                                                                                                                                                                  Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'fullscreen-hide-tabbar';          DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Hide tab bar when fullscreen';                               Description: 'When true, the tab bar will hide when is in fullscreen';                                                                                                                                                                                                                                                                                                              Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'hide-tabs-if-one-tab';            DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Hide tab bar if there is only one tab';                      Description: 'When true, the tab bar will hide when there is only one tab';                                                                                                                                                                                                                                                                                                         Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'quick-open-enable';               DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Enable Quick Open feature.';                                 Description: 'If this property is set as true, guake will open a text editor when the user does a Ctrl+Click on a filename printed in the terminal.';                                                                                                                                                                                                                               Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'quick-open-command-line';         DefaultValue: 'gedit %(file_path)s';                                                                                                                                                                                                                                             Summary: 'Command line pattern to start a editor.';                    Description: 'This property gives the command line to execute when doing a Quick Open. You can enter the following python string pattern in it: ''%(file_path)s'' will be replaced with the full pat' + 'h to the captured filename, ''%(line_number)s'' will be replaced by the line number if found (set to the empty string otherwise).';                                        Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'quick-open-in-current-terminal';  DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Quick open the file in the current terminal.';               Description: 'If this property is set as true, guake will use the current terminal to execute the Quick open feature. Use if you want to inherit your terminal environment in your text editor';                                                                                                                                                                                    Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'startup-script';                  DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'Startup script to execute when guake starts';                Description: 'This property allows you to execute a startup bash script each time guake starts. You can configure your initial tab settings within this script. Please see the command line argument of guake (''guake --help'') for complete help.';                                                                                                                               Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'start-fullscreen';                DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Start fullscreen.';                                          Description: 'When true, the program will start in fullscreen mode.';                                                                                                                                                                                                                                                                                                               Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'start-at-login';                  DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Start when GNOME starts';                                    Description: 'When true, the program will start upon GNOME login.';                                                                                                                                                                                                                                                                                                                 Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'use-audible-bell';                DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Audible bell';                                               Description: 'If true, the system alert sound will be played on a bell character.';                                                                                                                                                                                                                                                                                                 Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'display-tab-activity';            DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Highlight tabs with activity';                               Description: 'If true, the title of a background tab is highlighted when its terminal produces output, until the tab is selected.';                                                                                                                                                                                                                                                 Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'tab-activity-new-tab-grace';      DefaultValue: '3.0';                                                                                                                                                                                                                                                             Summary: 'Activity grace period for new tabs';                         Description: 'Number of seconds during which activity is ignored on a newly created tab, to avoid highlighting it because of its initial shell prompt.';                                                                                                                                                                                                                            Kind: skDouble;  HasRange: True;  Minimum: 0; Maximum: 60),
    (Section: 'general';            Key: 'tab-activity-focus-loss-grace';   DefaultValue: '1.0';                                                                                                                                                                                                                                                             Summary: 'Activity grace period after losing focus';                   Description: 'Number of seconds during which activity is ignored on a tab right after it loses focus.';                                                                                                                                                                                                                                                                             Kind: skDouble;  HasRange: True;  Minimum: 0; Maximum: 60),
    (Section: 'general';            Key: 'window-width';                    DefaultValue: '100';                                                                                                                                                                                                                                                             Summary: 'Window width.';                                              Description: 'Percent of the screen that will be used by guake terminal horizontally.';                                                                                                                                                                                                                                                                                             Kind: skInteger; HasRange: True;  Minimum: 1; Maximum: 100),
    (Section: 'general';            Key: 'window-height';                   DefaultValue: '50';                                                                                                                                                                                                                                                              Summary: 'Window height.';                                             Description: 'Percent of the screen that will be used by guake terminal vertically.';                                                                                                                                                                                                                                                                                               Kind: skInteger; HasRange: True;  Minimum: 1; Maximum: 100),
    (Section: 'general';            Key: 'window-horizontal-displacement';  DefaultValue: '0';                                                                                                                                                                                                                                                               Summary: 'Horizontal window displacement.';                            Description: 'Displace the window horizontally by a given amount of pixels.';                                                                                                                                                                                                                                                                                                       Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 10000000),
    (Section: 'general';            Key: 'window-vertical-displacement';    DefaultValue: '0';                                                                                                                                                                                                                                                               Summary: 'Vertical window displacement.';                              Description: 'Displace the window vertically by a given amount of pixels.';                                                                                                                                                                                                                                                                                                         Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 10000000),
    (Section: 'general';            Key: 'window-halignment';               DefaultValue: '0';                                                                                                                                                                                                                                                               Summary: 'Window horizontal alignment.';                               Description: 'Place Guake at: 0: center, 1: left, 2: right';                                                                                                                                                                                                                                                                                                                        Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 2),
    (Section: 'general';            Key: 'window-valignment';               DefaultValue: '0';                                                                                                                                                                                                                                                               Summary: 'Window vertical alignment.';                                 Description: 'Place Guake at: 0: top, 1: bottom';                                                                                                                                                                                                                                                                                                                                   Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 1),
    (Section: 'general';            Key: 'background-image-file';           DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'Background image filename.';                                 Description: 'When setup, the selected background image will show on guake';                                                                                                                                                                                                                                                                                                        Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'background-image-layout-mode';    DefaultValue: '0';                                                                                                                                                                                                                                                               Summary: 'Background image layout mode.';                              Description: 'To select which layout mode want to use for background image.';                                                                                                                                                                                                                                                                                                       Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 3),
    (Section: 'general';            Key: 'use-scrollbar';                   DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Sets the scrollbar visibility.';                             Description: 'When true, scrollbar is visible.';                                                                                                                                                                                                                                                                                                                                    Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'history-size';                    DefaultValue: '1000';                                                                                                                                                                                                                                                            Summary: 'History Size.';                                              Description: 'The number of scrollback lines to save in history.';                                                                                                                                                                                                                                                                                                                  Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 10000000),
    (Section: 'general';            Key: 'infinite-history';                DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Infinite scrolling';                                         Description: 'Scrollback lines in history is infinite';                                                                                                                                                                                                                                                                                                                             Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'scroll-output';                   DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Scroll on output';                                           Description: 'If true, whenever there is new output in the terminal, it will scroll to the bottom.';                                                                                                                                                                                                                                                                                Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'scroll-keystroke';                DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Scroll on keystroke';                                        Description: 'If true and a key is pressed, the terminal is scrolled to the bottom.';                                                                                                                                                                                                                                                                                               Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'use-default-font';                DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Use default font';                                           Description: 'If true, Guake will use the GNOME monospace default font.';                                                                                                                                                                                                                                                                                                           Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'use-vte-titles';                  DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Use terminal titles for tab naming';                         Description: 'Any terminal program can set the terminal''s title via special escape sequences. Some shells (e.g. bash) display user''s prompt there (though you can adjust that to any arbitrary tex' + 't in bashrc or similar) and update it automatically as the prompt changes. So you can have easy automatically updating meaningful tab titles with this option turned on.'; Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'set-window-title';                DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Set window title to current tab name';                       Description: 'If true, Guake will update its window title from the current tab name. It is useful when you work with applications that use windows title, (keepass, automatic time tracker apps)';                                                                                                                                                                                  Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'compat-backspace';                DefaultValue: 'ascii-delete';                                                                                                                                                                                                                                                    Summary: 'Backspace Compatibility';                                    Description: 'Defines the behavior of backspace key.';                                                                                                                                                                                                                                                                                                                              Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'compat-delete';                   DefaultValue: 'delete-sequence';                                                                                                                                                                                                                                                 Summary: 'Delete Compatibility';                                       Description: 'Defines the behavior of delete key.';                                                                                                                                                                                                                                                                                                                                 Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'word-chars';                      DefaultValue: '-A-Za-z0-9,./?%&#:_~';                                                                                                                                                                                                                                            Summary: 'Characters that are considered "part of a word"';            Description: 'When selecting text by word, sequences of these characters are considered single words. Ranges can be given as "A-Z". Literal hyphen (not expressing a range) should be the first character given.';                                                                                                                                                                  Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'toolbar-visible-in-fullscreen';   DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'If the tabs bar must be visible in fullscreen';              Description: 'Set it as false to enjoy guake''s fullscreen.';                                                                                                                                                                                                                                                                                                                       Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'focus-if-open';                   DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Give focus to guake if tab is opened (OBSOLETE).';           Description: 'If the guake window is out of focus but open, enabling this will give it back the focus instead of closing the window.';                                                                                                                                                                                                                                              Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'custom-command-file';             DefaultValue: '~/.config/guake/custom_command.json';                                                                                                                                                                                                                             Summary: 'Path to the default custom command json file.';              Description: 'Path to the default custom command json file. If is blank or the json file is not in a proper format the terminal context menu will be built without custom commands. If the file is' + ' a valid json with recognized structure theterminak context menu will be built with the commands read inside.';                                                              Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'open-tab-cwd';                    DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Open new tab in the current working directory';              Description: 'Open new tab in the current working directory';                                                                                                                                                                                                                                                                                                                       Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'max-tab-name-length';             DefaultValue: '100';                                                                                                                                                                                                                                                             Summary: '#TODO PORT max-tab-name-length';                             Description: '#TODO PORT max-tab-name-length';                                                                                                                                                                                                                                                                                                                                      Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 1000),
    (Section: 'general';            Key: 'display-tab-names';               DefaultValue: '0';                                                                                                                                                                                                                                                               Summary: 'How to display tab names.';                                  Description: 'Controls how the tab names are displayed. 0: Full Path, 1: Abbreviated Path, 2: Only display the last segment of the path';                                                                                                                                                                                                                                           Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 2),
    (Section: 'general';            Key: 'gtk-use-system-default-theme';    DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Use system default theme for GTK';                           Description: 'Prefer the system default theme';                                                                                                                                                                                                                                                                                                                                     Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'gtk-theme-name';                  DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'GTK Theme name';                                             Description: 'Name of the GTK theme to apply on Guake. If set to an empty string, let GTK use the default system theme';                                                                                                                                                                                                                                                            Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'gtk-prefer-dark-theme';           DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Prefer Dark Theme for GTK';                                  Description: 'Prefer the dark theme version of the theme if available';                                                                                                                                                                                                                                                                                                             Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'tab-close-buttons';               DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Show close buttons for tabs';                                Description: 'Show close buttons next to tab titles';                                                                                                                                                                                                                                                                                                                               Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'general';            Key: 'copy-on-select';                  DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Copy selected text if enabled.';                             Description: 'Copy the selected text.';                                                                                                                                                                                                                                                                                                                                             Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'style';              Key: 'cursor-blink-mode';               DefaultValue: '0';                                                                                                                                                                                                                                                               Summary: 'Cursor blink mode of the terminal';                          Description: 'Controls the blink mode of the cursor in the terminals. 0: Follow GTK+ setting, 1: Blink on, 2: Blink off';                                                                                                                                                                                                                                                           Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 2),
    (Section: 'style';              Key: 'cursor-shape';                    DefaultValue: '0';                                                                                                                                                                                                                                                               Summary: 'Cursor shape of the terminal';                               Description: 'Controls the shape of the cursor in the terminals. 0: Block, 1: I-Beam, 2: Underline';                                                                                                                                                                                                                                                                                Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 2),
    (Section: 'style.font';         Key: 'style';                           DefaultValue: 'Monospace 10';                                                                                                                                                                                                                                                    Summary: 'Font style.';                                                Description: 'Font face and size that will be used in terminal.';                                                                                                                                                                                                                                                                                                                   Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'style.font';         Key: 'palette';                         DefaultValue: '000000000000:#cccc00000000:#4e4e9a9a0606:#c4c4a0a00000:#34346565a4a4:#757550507b7b:#060698209a9a:#d3d3d7d7cfcf:#555557575353:#efef29292929:#8a8ae2e23434:#fcfce9e94f4f:#72729f9fcfcf' + ':#adad7f7fa8a8:#3434e2e2e2e2:#eeeeeeeeecec:#ffffffffffff:#000000000000'; Summary: 'Color scheme.';                                              Description: 'Color scheme that will be used in terminal.';                                                                                                                                                                                                                                                                                                                         Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'style.font';         Key: 'palette-name';                    DefaultValue: 'Tango';                                                                                                                                                                                                                                                           Summary: 'Color scheme name.';                                         Description: 'Color scheme name that will be used in terminal.';                                                                                                                                                                                                                                                                                                                    Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'style.font';         Key: 'allow-bold';                      DefaultValue: 'true';                                                                                                                                                                                                                                                            Summary: 'Allow displaying bold font in Guake terminal.';              Description: 'When allow_bold is disabled, any text in Guake terminal intended to print as bold text will be instead rendered as normal text.';                                                                                                                                                                                                                                     Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'style.font';         Key: 'bold-is-bright';                  DefaultValue: 'false';                                                                                                                                                                                                                                                           Summary: 'Use bright colors for bold text';                            Description: 'If true, text from the first 8 colors that is formatted as bold will also be switched to its bright variant (VTE >=0.52).';                                                                                                                                                                                                                                           Kind: skBoolean; HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'style.font';         Key: 'cell-height-scale';               DefaultValue: '1.0';                                                                                                                                                                                                                                                             Summary: 'Set terminal''s cell height scale to `scale` (VTE >= 0.52)'; Description: 'This can be used to increase the line spacing. (The font''s height is not affected.) Valid values go from 1.0 (default) to 2.0 ("double spacing").';                                                                                                                                                                                                                  Kind: skDouble;  HasRange: True;  Minimum: 1; Maximum: 2),
    (Section: 'style.font';         Key: 'cell-width-scale';                DefaultValue: '1.0';                                                                                                                                                                                                                                                             Summary: 'Set terminal''s cell width scale to `scale` (VTE >= 0.52)';  Description: 'This can be used to increase the letter spacing. (The font''s width is not affected.) Valid values go from 1.0 (default) to 2.0 ("double spacing").';                                                                                                                                                                                                                 Kind: skDouble;  HasRange: True;  Minimum: 1; Maximum: 2),
    (Section: 'style.background';   Key: 'transparency';                    DefaultValue: '90';                                                                                                                                                                                                                                                              Summary: 'Background transparency.';                                   Description: 'Alpha that will be applied to the terminal background.';                                                                                                                                                                                                                                                                                                              Kind: skInteger; HasRange: True;  Minimum: 0; Maximum: 100),
    (Section: 'keybindings.global'; Key: 'show-hide';                       DefaultValue: 'F12';                                                                                                                                                                                                                                                             Summary: 'Keybinding to show/hide guake.';                             Description: 'Global keybinding to allow user call guake from each place after it''s opened without clicks.';                                                                                                                                                                                                                                                                       Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.global'; Key: 'show-focus';                      DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'Keybinding to show and focus guake.';                        Description: 'Global keybinding to allow user call guake from each place after it''s opened without clicks.';                                                                                                                                                                                                                                                                       Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'search-terminal';                 DefaultValue: '<Control><Shift>f';                                                                                                                                                                                                                                               Summary: 'Search terminal';                                            Description: 'Show search box to search text inside the terminal';                                                                                                                                                                                                                                                                                                                  Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'quit';                            DefaultValue: '<Control><Shift>q';                                                                                                                                                                                                                                               Summary: 'Quit';                                                       Description: 'Quit Guake.';                                                                                                                                                                                                                                                                                                                                                         Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'new-tab';                         DefaultValue: '<Control><Shift>t';                                                                                                                                                                                                                                               Summary: 'Add a new tab.';                                             Description: 'Calls the function to add a new tab in guake window.';                                                                                                                                                                                                                                                                                                                Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'new-tab-home';                    DefaultValue: '<Control><Shift>h';                                                                                                                                                                                                                                               Summary: 'Add a new tab in home directory.';                           Description: 'Calls the function to add a new home directory tab in guake window.';                                                                                                                                                                                                                                                                                                 Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'new-tab-cwd';                     DefaultValue: '<Super>t';                                                                                                                                                                                                                                                        Summary: 'Add a new tab in current directory.';                        Description: 'Calls the function to add a new tab in guake window, in the same directory as the current tab.';                                                                                                                                                                                                                                                                      Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'close-tab';                       DefaultValue: '<Control><Shift>w';                                                                                                                                                                                                                                               Summary: 'Closes the current tab.';                                    Description: 'Accelerator to active function that closes the current selected tab.';                                                                                                                                                                                                                                                                                                Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'search-on-web';                   DefaultValue: '<Control><Shift>l';                                                                                                                                                                                                                                               Summary: 'Search current selected text on the web';                    Description: 'Accelerator to active function that search on the web the current selected text on the terminal.';                                                                                                                                                                                                                                                                    Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'open-link-under-terminal-cursor'; DefaultValue: '<Control><Shift>o';                                                                                                                                                                                                                                               Summary: 'Open link under terminal cursor';                            Description: 'Accelerator to active function that opens the link (URL) under the current terminal cursor.';                                                                                                                                                                                                                                                                         Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'move-tab-left';                   DefaultValue: '<Control><Shift>Page_Up';                                                                                                                                                                                                                                         Summary: 'Move left current tab';                                      Description: 'Move the current tab to the left';                                                                                                                                                                                                                                                                                                                                    Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'move-tab-right';                  DefaultValue: '<Control><Shift>Page_Down';                                                                                                                                                                                                                                       Summary: 'Move right current tab';                                     Description: 'Move the current tab to the right';                                                                                                                                                                                                                                                                                                                                   Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'previous-tab';                    DefaultValue: '<Control>Page_Up';                                                                                                                                                                                                                                                Summary: 'Previous tab.';                                              Description: 'Shows the previous tab.';                                                                                                                                                                                                                                                                                                                                             Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'next-tab';                        DefaultValue: '<Control>Page_Down';                                                                                                                                                                                                                                              Summary: 'Next tab.';                                                  Description: 'Shows the next tab.';                                                                                                                                                                                                                                                                                                                                                 Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'previous-tab-alt';                DefaultValue: '<Control><Shift>Tab';                                                                                                                                                                                                                                             Summary: 'Previous tab (alternative)';                                 Description: 'Alternate shortcut to show the previous tab.';                                                                                                                                                                                                                                                                                                                        Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'next-tab-alt';                    DefaultValue: '<Control>Tab';                                                                                                                                                                                                                                                    Summary: 'Next tab (alternative)';                                     Description: 'Alternate shortcut to show the next tab.';                                                                                                                                                                                                                                                                                                                            Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'switch-tab1';                     DefaultValue: '<Control>F1';                                                                                                                                                                                                                                                     Summary: 'First tab.';                                                 Description: 'Switch to the first tab.';                                                                                                                                                                                                                                                                                                                                            Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'switch-tab2';                     DefaultValue: '<Control>F2';                                                                                                                                                                                                                                                     Summary: 'Second tab.';                                                Description: 'Switch to the second tab.';                                                                                                                                                                                                                                                                                                                                           Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'switch-tab3';                     DefaultValue: '<Control>F3';                                                                                                                                                                                                                                                     Summary: 'Third tab.';                                                 Description: 'Switch to the third tab.';                                                                                                                                                                                                                                                                                                                                            Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'switch-tab4';                     DefaultValue: '<Control>F4';                                                                                                                                                                                                                                                     Summary: 'Fourth tab.';                                                Description: 'Switch to the fourth tab.';                                                                                                                                                                                                                                                                                                                                           Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'switch-tab5';                     DefaultValue: '<Control>F5';                                                                                                                                                                                                                                                     Summary: 'Fifth tab.';                                                 Description: 'Switch to the fifth tab.';                                                                                                                                                                                                                                                                                                                                            Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'switch-tab6';                     DefaultValue: '<Control>F6';                                                                                                                                                                                                                                                     Summary: 'Sixth tab.';                                                 Description: 'Switch to the sixth tab.';                                                                                                                                                                                                                                                                                                                                            Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'switch-tab7';                     DefaultValue: '<Control>F7';                                                                                                                                                                                                                                                     Summary: 'Seventh tab.';                                               Description: 'Switch to the seventh tab.';                                                                                                                                                                                                                                                                                                                                          Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'switch-tab8';                     DefaultValue: '<Control>F8';                                                                                                                                                                                                                                                     Summary: 'eighth tab.';                                                Description: 'Switch to the eighth tab.';                                                                                                                                                                                                                                                                                                                                           Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'switch-tab9';                     DefaultValue: '<Control>F9';                                                                                                                                                                                                                                                     Summary: 'Ninth tab.';                                                 Description: 'Switch to the ninth tab.';                                                                                                                                                                                                                                                                                                                                            Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'switch-tab10';                    DefaultValue: '<Control>F10';                                                                                                                                                                                                                                                    Summary: 'Tenth tab.';                                                 Description: 'Switch to the tenth tab.';                                                                                                                                                                                                                                                                                                                                            Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'rename-current-tab';              DefaultValue: '<Control><Shift>R';                                                                                                                                                                                                                                               Summary: 'Rename current tab.';                                        Description: 'Shows a dialog to rename the current tab.';                                                                                                                                                                                                                                                                                                                           Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'zoom-in';                         DefaultValue: '<Control>plus';                                                                                                                                                                                                                                                   Summary: 'Zoom in.';                                                   Description: 'Increase the font size of the terminals.';                                                                                                                                                                                                                                                                                                                            Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'zoom-in-alt';                     DefaultValue: '<Control>equal';                                                                                                                                                                                                                                                  Summary: 'Zoom in (alternative)';                                      Description: 'Additional shortcut for zooming in.';                                                                                                                                                                                                                                                                                                                                 Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'zoom-out';                        DefaultValue: '<Control>minus';                                                                                                                                                                                                                                                  Summary: 'Zoom out.';                                                  Description: 'Decrease the font size of the terminals.';                                                                                                                                                                                                                                                                                                                            Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'increase-height';                 DefaultValue: '<Control>Down';                                                                                                                                                                                                                                                   Summary: 'Increase height.';                                           Description: 'Increase the screen height.';                                                                                                                                                                                                                                                                                                                                         Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'decrease-height';                 DefaultValue: '<Control>Up';                                                                                                                                                                                                                                                     Summary: 'Decrease height.';                                           Description: 'Decrease the screen height.';                                                                                                                                                                                                                                                                                                                                         Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'increase-transparency';           DefaultValue: '<Control><Shift>b';                                                                                                                                                                                                                                               Summary: 'Increase transparency.';                                     Description: 'Increase the terminal transparency.';                                                                                                                                                                                                                                                                                                                                 Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'decrease-transparency';           DefaultValue: '<Control><Shift>n';                                                                                                                                                                                                                                               Summary: 'Decrease transparency.';                                     Description: 'Decrease the terminal transparency.';                                                                                                                                                                                                                                                                                                                                 Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'clipboard-copy';                  DefaultValue: '<Control><Shift>c';                                                                                                                                                                                                                                               Summary: 'Copy clipboard.';                                            Description: 'Copy the clipboard content.';                                                                                                                                                                                                                                                                                                                                         Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'clipboard-paste';                 DefaultValue: '<Control><Shift>v';                                                                                                                                                                                                                                               Summary: 'Paste clipboard.';                                           Description: 'Paste the clipboard content.';                                                                                                                                                                                                                                                                                                                                        Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'select-all';                      DefaultValue: '<Control><Shift>a';                                                                                                                                                                                                                                               Summary: 'Select all.';                                                Description: 'Select all contents of the currently active terminal.';                                                                                                                                                                                                                                                                                                               Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'toggle-fullscreen';               DefaultValue: 'F11';                                                                                                                                                                                                                                                             Summary: 'Toggle Fullscreen.';                                         Description: 'Toggle main guake window fullscreen.';                                                                                                                                                                                                                                                                                                                                Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'toggle-hide-on-lose-focus';       DefaultValue: '<Control><Shift>F1';                                                                                                                                                                                                                                              Summary: 'Toggle hide on lose focus.';                                 Description: 'Toggle whether guake will hide when it loses focus.';                                                                                                                                                                                                                                                                                                                 Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'reset-terminal';                  DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'Reset';                                                      Description: 'Reset terminal';                                                                                                                                                                                                                                                                                                                                                      Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'toggle-transparency';             DefaultValue: '<Control><Alt>T';                                                                                                                                                                                                                                                 Summary: 'Toggle transparency.';                                       Description: 'Toggle the terminal transparency from the actual level to 100% and vice versa.';                                                                                                                                                                                                                                                                                      Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'switch-tab-last';                 DefaultValue: '<Control>F12';                                                                                                                                                                                                                                                    Summary: 'Last tab.';                                                  Description: 'Switch to the last tab.';                                                                                                                                                                                                                                                                                                                                             Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'split-tab-vertical';              DefaultValue: '<Super><Shift>comma';                                                                                                                                                                                                                                             Summary: 'Split tab vertical.';                                        Description: 'Split tab vertical.';                                                                                                                                                                                                                                                                                                                                                 Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'split-tab-horizontal';            DefaultValue: '<Super>minus';                                                                                                                                                                                                                                                    Summary: 'Split tab horizontal.';                                      Description: 'Split tab horizontal.';                                                                                                                                                                                                                                                                                                                                               Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'close-terminal';                  DefaultValue: '<Super>x';                                                                                                                                                                                                                                                        Summary: 'Close terminal.';                                            Description: 'Close the currently focused terminal.';                                                                                                                                                                                                                                                                                                                               Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'focus-terminal-up';               DefaultValue: '<Super><Shift>Up';                                                                                                                                                                                                                                                Summary: 'Focus terminal above.';                                      Description: 'Focus terminal above.';                                                                                                                                                                                                                                                                                                                                               Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'focus-terminal-down';             DefaultValue: '<Super><Shift>Down';                                                                                                                                                                                                                                              Summary: 'Focus terminal below.';                                      Description: 'Focus terminal below.';                                                                                                                                                                                                                                                                                                                                               Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'focus-terminal-right';            DefaultValue: '<Super><Shift>Right';                                                                                                                                                                                                                                             Summary: 'Focus terminal on the right.';                               Description: 'Focus terminal on the right.';                                                                                                                                                                                                                                                                                                                                        Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'focus-terminal-left';             DefaultValue: '<Super><Shift>Left';                                                                                                                                                                                                                                              Summary: 'Focus terminal on the left.';                                Description: 'Focus terminal on the left.';                                                                                                                                                                                                                                                                                                                                         Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'move-terminal-split-up';          DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'Move the terminal split handle up.';                         Description: 'Move the terminal split handle up.';                                                                                                                                                                                                                                                                                                                                  Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'move-terminal-split-down';        DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'Move the terminal split handle down.';                       Description: 'Move the terminal split handle down.';                                                                                                                                                                                                                                                                                                                                Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'move-terminal-split-left';        DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'Move the terminal split handle left.';                       Description: 'Move the terminal split handle left.';                                                                                                                                                                                                                                                                                                                                Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'keybindings.local';  Key: 'move-terminal-split-right';       DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'Move the terminal split handle right.';                      Description: 'Move the terminal split handle right.';                                                                                                                                                                                                                                                                                                                               Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0),
    (Section: 'hooks';              Key: 'show';                            DefaultValue: '';                                                                                                                                                                                                                                                                Summary: 'On show.';                                                   Description: 'Run this script on show.';                                                                                                                                                                                                                                                                                                                                            Kind: skString;  HasRange: False; Minimum: 0; Maximum: 0)
   );
{FLD-}

 Constructor TGuakeSettings.Create(Const FileName : String);
  Begin
   Inherited Create;
   If FileName = '' Then
    Raise EArgumentException.Create('Settings file name must not be empty');
   fFileName := ExpandFileName(FileName);
   fIni      := TMemIniFile.Create(fFileName, TEncoding.UTF8);
   LoadRecords;
  End;

 Destructor TGuakeSettings.Destroy;
  Begin
   fIni.Free;
   Inherited;
  End;

  Class Function TGuakeSettings.DefaultFileName : String;

 Var
  Base : String;

Begin
 Base := GetEnvironmentVariable('APPDATA');
 If Base = '' Then
  Raise EInvalidOpException.Create('APPDATA is not defined');
 Result := TPath.Combine(TPath.Combine(Base, 'Guake'), 'guake.ini');
End;

 Procedure TGuakeSettings.Reload;
  Var
   Replacement : TMemIniFile;
  Begin
   Replacement := TMemIniFile.Create(fFileName, TEncoding.UTF8);
   fIni.Free;
   fIni := Replacement;
   LoadRecords;
  End;

 Procedure TGuakeSettings.Save;
  Var
   TempName      : String;
   DirectoryName : String;
   Lines         : TStringList;
   Key           : TGuakeSetting;
   TempIni       : TMemIniFile;
  Begin
   For Key := Low(TGuakeSetting) To High(TGuakeSetting) Do
    If Not ValidValue(Key, GetValue(Key)) Then
     Raise EArgumentOutOfRangeException.CreateFmt('Invalid value for %s.%s', [Definitions[Key].Section, Definitions[Key].Key]);
   For Key := Low(TGuakeSetting) To High(TGuakeSetting) Do
    fIni.WriteString(Definitions[Key].Section, Definitions[Key].Key, GetValue(Key));
   DirectoryName := ExtractFileDir(fFileName);
   If Not ForceDirectories(DirectoryName) Then
    Raise EInOutError.CreateFmt('Cannot create settings directory: %s', [DirectoryName]);
   TempName := TPath.Combine(DirectoryName, TPath.GetRandomFileName);
   Try
    Lines := TStringList.Create;
    Try
     fIni.GetStrings(Lines);
     TempIni := TMemIniFile.Create(TempName, TEncoding.UTF8);
     Try
      TempIni.SetStrings(Lines);
      TempIni.UpdateFile;
     Finally
      TempIni.Free;
     End;
    Finally
     Lines.Free;
    End;
    If Not MoveFileEx(PChar(TempName), PChar(fFileName),
    MOVEFILE_REPLACE_EXISTING Or MOVEFILE_WRITE_THROUGH) Then
     RaiseLastOSError;
   Finally
    If FileExists(TempName) Then
     System.SysUtils.DeleteFile(TempName);
   End;
  End;

 Function TGuakeSettings.ReadString(Const Section, Key, Default : String) : String;
  Var
   Known : TGuakeSetting;
  Begin
   If FindKey(Section, Key, Known) Then
    Result := GetValue(Known)
   Else
    Result := fIni.ReadString(Section, Key, Default);
  End;

 Function TGuakeSettings.ReadInteger(Const Section, Key : String; Default : Integer) : Integer;
  Begin
   If Not TryStrToInt(ReadString(Section, Key, IntToStr(Default)), Result) Then
    Result := Default;
  End;

 Function TGuakeSettings.ReadBool(Const Section, Key : String; Default : Boolean) : Boolean;
  Begin
   If Not TryStrToBool(ReadString(Section, Key, BoolToStr(Default, True)), Result) Then
    Result := Default;
  End;

 Procedure TGuakeSettings.WriteString(Const Section, Key, Value : String);
  Var
   Known : TGuakeSetting;
  Begin
   If (Pos(#13, Value) > 0) Or (Pos(#10, Value) > 0) Then
    Raise EArgumentException.Create('INI values must be single-line');
   fIni.WriteString(Section, Key, Value);
   If FindKey(Section, Key, Known) Then
    If ValidValue(Known, Value) Then
     SetRecordValue(Known, Value)
    Else
     SetRecordValue(Known, Definitions[Known].DefaultValue);
  End;

 Procedure TGuakeSettings.WriteInteger(Const Section, Key : String; Value : Integer);
  Begin
   WriteString(Section, Key, IntToStr(Value));
  End;

 Procedure TGuakeSettings.WriteBool(Const Section, Key : String; Value : Boolean);
  Begin
   WriteString(Section, Key, BoolToStr(Value, True));
  End;

  Class Function TGuakeSettings.Definition(Key : TGuakeSetting) : TGuakeSettingDefinition;

Begin
 Result := Definitions[Key];
End;

  Class Function TGuakeSettings.FindKey(Const Section, Name : String; Out Key : TGuakeSetting) : Boolean;

 Var
  k : TGuakeSetting;

Begin
 For k := Low(TGuakeSetting) To High(TGuakeSetting) Do
  If SameText(Definitions[k].Section, Section) And SameText(Definitions[k].Key, Name) Then
   Begin
    Key := k;
    Exit(True);
   End;
 Result := False;
End;

  Class Function TGuakeSettings.ValidValue(Key : TGuakeSetting; Const Value : String) : Boolean;

 Var
  d : TGuakeSettingDefinition;
  i : Integer;
  v : Double;

Begin
 d := Definitions[Key];
 v := 0;
 Case d.Kind Of
  skString :
   Result := (Pos(#10, Value) = 0) And (Pos(#13, Value) = 0);
  skBoolean :
   Result := SameText(Value, 'true') Or SameText(Value, 'false') Or (Value = '0') Or (Value = '1');
  skInteger :
   Begin
    Result := TryStrToInt(Value, i);
    If Result Then
     v := i;
   End;
  skDouble :
   Begin
    Result := TryStrToFloat(Value, v, TFormatSettings.Invariant);
    Result := Result And Not IsNan(v) And Not IsInfinite(v);
   End;
 Else
   Result := False;
 End;
 If Result And d.HasRange Then
  Result := (v >= d.Minimum) And (v <= d.Maximum);
End;

 Function TGuakeSettings.GetValue(Key : TGuakeSetting) : String;
  Begin
   Case Key Of
    gskGeneralSchemaVersion                        : Result := General.SchemaVersion;
    gskGeneralDebugMode                            : Result := LowerCase(BoolToStr(General.DebugMode, True));
    gskGeneralMouseDisplay                         : Result := LowerCase(BoolToStr(General.MouseDisplay, True));
    gskGeneralDisplayN                             : Result := IntToStr(General.DisplayN);
    gskGeneralDefaultShell                         : Result := General.DefaultShell;
    gskGeneralRestoreTabsStartup                   : Result := LowerCase(BoolToStr(General.RestoreTabsStartup, True));
    gskGeneralRestoreTabsNotify                    : Result := LowerCase(BoolToStr(General.RestoreTabsNotify, True));
    gskGeneralSaveTabsWhenChanged                  : Result := LowerCase(BoolToStr(General.SaveTabsWhenChanged, True));
    gskGeneralLoadGuakeYml                         : Result := LowerCase(BoolToStr(General.LoadGuakeYml, True));
    gskGeneralUseLoginShell                        : Result := LowerCase(BoolToStr(General.UseLoginShell, True));
    gskGeneralUseTrayicon                          : Result := LowerCase(BoolToStr(General.UseTrayicon, True));
    gskGeneralWorkspaceSpecificTabSets             : Result := LowerCase(BoolToStr(General.WorkspaceSpecificTabSets, True));
    gskGeneralUsePopup                             : Result := LowerCase(BoolToStr(General.UsePopup, True));
    gskGeneralPromptOnQuit                         : Result := LowerCase(BoolToStr(General.PromptOnQuit, True));
    gskGeneralPromptOnCloseTab                     : Result := IntToStr(General.PromptOnCloseTab);
    gskGeneralSearchEngine                         : Result := IntToStr(General.SearchEngine);
    gskGeneralCustomSearchEngine                   : Result := General.CustomSearchEngine;
    gskGeneralWindowOntop                          : Result := LowerCase(BoolToStr(General.WindowOntop, True));
    gskGeneralWindowRefocus                        : Result := LowerCase(BoolToStr(General.WindowRefocus, True));
    gskGeneralTabOntop                             : Result := LowerCase(BoolToStr(General.TabOntop, True));
    gskGeneralNewTabAfter                          : Result := LowerCase(BoolToStr(General.NewTabAfter, True));
    gskGeneralWindowLosefocus                      : Result := LowerCase(BoolToStr(General.WindowLosefocus, True));
    gskGeneralLazyLosefocus                        : Result := LowerCase(BoolToStr(General.LazyLosefocus, True));
    gskGeneralWindowTabbar                         : Result := LowerCase(BoolToStr(General.WindowTabbar, True));
    gskGeneralFullscreenHideTabbar                 : Result := LowerCase(BoolToStr(General.FullscreenHideTabbar, True));
    gskGeneralHideTabsIfOneTab                     : Result := LowerCase(BoolToStr(General.HideTabsIfOneTab, True));
    gskGeneralQuickOpenEnable                      : Result := LowerCase(BoolToStr(General.QuickOpenEnable, True));
    gskGeneralQuickOpenCommandLine                 : Result := General.QuickOpenCommandLine;
    gskGeneralQuickOpenInCurrentTerminal           : Result := LowerCase(BoolToStr(General.QuickOpenInCurrentTerminal, True));
    gskGeneralStartupScript                        : Result := General.StartupScript;
    gskGeneralStartFullscreen                      : Result := LowerCase(BoolToStr(General.StartFullscreen, True));
    gskGeneralStartAtLogin                         : Result := LowerCase(BoolToStr(General.StartAtLogin, True));
    gskGeneralUseAudibleBell                       : Result := LowerCase(BoolToStr(General.UseAudibleBell, True));
    gskGeneralDisplayTabActivity                   : Result := LowerCase(BoolToStr(General.DisplayTabActivity, True));
    gskGeneralTabActivityNewTabGrace               : Result := FloatToStr(General.TabActivityNewTabGrace, TFormatSettings.Invariant);
    gskGeneralTabActivityFocusLossGrace            : Result := FloatToStr(General.TabActivityFocusLossGrace, TFormatSettings.Invariant);
    gskGeneralWindowWidth                          : Result := IntToStr(General.WindowWidth);
    gskGeneralWindowHeight                         : Result := IntToStr(General.WindowHeight);
    gskGeneralWindowHorizontalDisplacement         : Result := IntToStr(General.WindowHorizontalDisplacement);
    gskGeneralWindowVerticalDisplacement           : Result := IntToStr(General.WindowVerticalDisplacement);
    gskGeneralWindowHalignment                     : Result := IntToStr(General.WindowHalignment);
    gskGeneralWindowValignment                     : Result := IntToStr(General.WindowValignment);
    gskGeneralBackgroundImageFile                  : Result := General.BackgroundImageFile;
    gskGeneralBackgroundImageLayoutMode            : Result := IntToStr(General.BackgroundImageLayoutMode);
    gskGeneralUseScrollbar                         : Result := LowerCase(BoolToStr(General.UseScrollbar, True));
    gskGeneralHistorySize                          : Result := IntToStr(General.HistorySize);
    gskGeneralInfiniteHistory                      : Result := LowerCase(BoolToStr(General.InfiniteHistory, True));
    gskGeneralScrollOutput                         : Result := LowerCase(BoolToStr(General.ScrollOutput, True));
    gskGeneralScrollKeystroke                      : Result := LowerCase(BoolToStr(General.ScrollKeystroke, True));
    gskGeneralUseDefaultFont                       : Result := LowerCase(BoolToStr(General.UseDefaultFont, True));
    gskGeneralUseVteTitles                         : Result := LowerCase(BoolToStr(General.UseVteTitles, True));
    gskGeneralSetWindowTitle                       : Result := LowerCase(BoolToStr(General.SetWindowTitle, True));
    gskGeneralCompatBackspace                      : Result := General.CompatBackspace;
    gskGeneralCompatDelete                         : Result := General.CompatDelete;
    gskGeneralWordChars                            : Result := General.WordChars;
    gskGeneralToolbarVisibleInFullscreen           : Result := LowerCase(BoolToStr(General.ToolbarVisibleInFullscreen, True));
    gskGeneralFocusIfOpen                          : Result := LowerCase(BoolToStr(General.FocusIfOpen, True));
    gskGeneralCustomCommandFile                    : Result := General.CustomCommandFile;
    gskGeneralOpenTabCwd                           : Result := LowerCase(BoolToStr(General.OpenTabCwd, True));
    gskGeneralMaxTabNameLength                     : Result := IntToStr(General.MaxTabNameLength);
    gskGeneralDisplayTabNames                      : Result := IntToStr(General.DisplayTabNames);
    gskGeneralGtkUseSystemDefaultTheme             : Result := LowerCase(BoolToStr(General.GtkUseSystemDefaultTheme, True));
    gskGeneralGtkThemeName                         : Result := General.GtkThemeName;
    gskGeneralGtkPreferDarkTheme                   : Result := LowerCase(BoolToStr(General.GtkPreferDarkTheme, True));
    gskGeneralTabCloseButtons                      : Result := LowerCase(BoolToStr(General.TabCloseButtons, True));
    gskGeneralCopyOnSelect                         : Result := LowerCase(BoolToStr(General.CopyOnSelect, True));
    gskStyleCursorBlinkMode                        : Result := IntToStr(Style.CursorBlinkMode);
    gskStyleCursorShape                            : Result := IntToStr(Style.CursorShape);
    gskStyleFontStyle                              : Result := Style.Font.Style;
    gskStyleFontPalette                            : Result := Style.Font.Palette;
    gskStyleFontPaletteName                        : Result := Style.Font.PaletteName;
    gskStyleFontAllowBold                          : Result := LowerCase(BoolToStr(Style.Font.AllowBold, True));
    gskStyleFontBoldIsBright                       : Result := LowerCase(BoolToStr(Style.Font.BoldIsBright, True));
    gskStyleFontCellHeightScale                    : Result := FloatToStr(Style.Font.CellHeightScale, TFormatSettings.Invariant);
    gskStyleFontCellWidthScale                     : Result := FloatToStr(Style.Font.CellWidthScale, TFormatSettings.Invariant);
    gskStyleBackgroundTransparency                 : Result := IntToStr(Style.Background.Transparency);
    gskKeybindingsGlobalShowHide                   : Result := Keybindings.Global.ShowHide;
    gskKeybindingsGlobalShowFocus                  : Result := Keybindings.Global.ShowFocus;
    gskKeybindingsLocalSearchTerminal              : Result := Keybindings.Local.SearchTerminal;
    gskKeybindingsLocalQuit                        : Result := Keybindings.Local.Quit;
    gskKeybindingsLocalNewTab                      : Result := Keybindings.Local.NewTab;
    gskKeybindingsLocalNewTabHome                  : Result := Keybindings.Local.NewTabHome;
    gskKeybindingsLocalNewTabCwd                   : Result := Keybindings.Local.NewTabCwd;
    gskKeybindingsLocalCloseTab                    : Result := Keybindings.Local.CloseTab;
    gskKeybindingsLocalSearchOnWeb                 : Result := Keybindings.Local.SearchOnWeb;
    gskKeybindingsLocalOpenLinkUnderTerminalCursor : Result := Keybindings.Local.OpenLinkUnderTerminalCursor;
    gskKeybindingsLocalMoveTabLeft                 : Result := Keybindings.Local.MoveTabLeft;
    gskKeybindingsLocalMoveTabRight                : Result := Keybindings.Local.MoveTabRight;
    gskKeybindingsLocalPreviousTab                 : Result := Keybindings.Local.PreviousTab;
    gskKeybindingsLocalNextTab                     : Result := Keybindings.Local.NextTab;
    gskKeybindingsLocalPreviousTabAlt              : Result := Keybindings.Local.PreviousTabAlt;
    gskKeybindingsLocalNextTabAlt                  : Result := Keybindings.Local.NextTabAlt;
    gskKeybindingsLocalSwitchTab1                  : Result := Keybindings.Local.SwitchTab1;
    gskKeybindingsLocalSwitchTab2                  : Result := Keybindings.Local.SwitchTab2;
    gskKeybindingsLocalSwitchTab3                  : Result := Keybindings.Local.SwitchTab3;
    gskKeybindingsLocalSwitchTab4                  : Result := Keybindings.Local.SwitchTab4;
    gskKeybindingsLocalSwitchTab5                  : Result := Keybindings.Local.SwitchTab5;
    gskKeybindingsLocalSwitchTab6                  : Result := Keybindings.Local.SwitchTab6;
    gskKeybindingsLocalSwitchTab7                  : Result := Keybindings.Local.SwitchTab7;
    gskKeybindingsLocalSwitchTab8                  : Result := Keybindings.Local.SwitchTab8;
    gskKeybindingsLocalSwitchTab9                  : Result := Keybindings.Local.SwitchTab9;
    gskKeybindingsLocalSwitchTab10                 : Result := Keybindings.Local.SwitchTab10;
    gskKeybindingsLocalRenameCurrentTab            : Result := Keybindings.Local.RenameCurrentTab;
    gskKeybindingsLocalZoomIn                      : Result := Keybindings.Local.ZoomIn;
    gskKeybindingsLocalZoomInAlt                   : Result := Keybindings.Local.ZoomInAlt;
    gskKeybindingsLocalZoomOut                     : Result := Keybindings.Local.ZoomOut;
    gskKeybindingsLocalIncreaseHeight              : Result := Keybindings.Local.IncreaseHeight;
    gskKeybindingsLocalDecreaseHeight              : Result := Keybindings.Local.DecreaseHeight;
    gskKeybindingsLocalIncreaseTransparency        : Result := Keybindings.Local.IncreaseTransparency;
    gskKeybindingsLocalDecreaseTransparency        : Result := Keybindings.Local.DecreaseTransparency;
    gskKeybindingsLocalClipboardCopy               : Result := Keybindings.Local.ClipboardCopy;
    gskKeybindingsLocalClipboardPaste              : Result := Keybindings.Local.ClipboardPaste;
    gskKeybindingsLocalSelectAll                   : Result := Keybindings.Local.SelectAll;
    gskKeybindingsLocalToggleFullscreen            : Result := Keybindings.Local.ToggleFullscreen;
    gskKeybindingsLocalToggleHideOnLoseFocus       : Result := Keybindings.Local.ToggleHideOnLoseFocus;
    gskKeybindingsLocalResetTerminal               : Result := Keybindings.Local.ResetTerminal;
    gskKeybindingsLocalToggleTransparency          : Result := Keybindings.Local.ToggleTransparency;
    gskKeybindingsLocalSwitchTabLast               : Result := Keybindings.Local.SwitchTabLast;
    gskKeybindingsLocalSplitTabVertical            : Result := Keybindings.Local.SplitTabVertical;
    gskKeybindingsLocalSplitTabHorizontal          : Result := Keybindings.Local.SplitTabHorizontal;
    gskKeybindingsLocalCloseTerminal               : Result := Keybindings.Local.CloseTerminal;
    gskKeybindingsLocalFocusTerminalUp             : Result := Keybindings.Local.FocusTerminalUp;
    gskKeybindingsLocalFocusTerminalDown           : Result := Keybindings.Local.FocusTerminalDown;
    gskKeybindingsLocalFocusTerminalRight          : Result := Keybindings.Local.FocusTerminalRight;
    gskKeybindingsLocalFocusTerminalLeft           : Result := Keybindings.Local.FocusTerminalLeft;
    gskKeybindingsLocalMoveTerminalSplitUp         : Result := Keybindings.Local.MoveTerminalSplitUp;
    gskKeybindingsLocalMoveTerminalSplitDown       : Result := Keybindings.Local.MoveTerminalSplitDown;
    gskKeybindingsLocalMoveTerminalSplitLeft       : Result := Keybindings.Local.MoveTerminalSplitLeft;
    gskKeybindingsLocalMoveTerminalSplitRight      : Result := Keybindings.Local.MoveTerminalSplitRight;
    gskHooksShow                                   : Result := Hooks.Show;
   Else Result := '';
   End;
  End;

 Procedure TGuakeSettings.SetRecordValue(Key : TGuakeSetting; Const Value : String);
  Begin
   Case Key Of
    gskGeneralSchemaVersion                        : General.SchemaVersion := Value;
    gskGeneralDebugMode                            : General.DebugMode := SameText(Value, 'true') Or (Value = '1');
    gskGeneralMouseDisplay                         : General.MouseDisplay := SameText(Value, 'true') Or (Value = '1');
    gskGeneralDisplayN                             : General.DisplayN := StrToInt(Value);
    gskGeneralDefaultShell                         : General.DefaultShell := Value;
    gskGeneralRestoreTabsStartup                   : General.RestoreTabsStartup := SameText(Value, 'true') Or (Value = '1');
    gskGeneralRestoreTabsNotify                    : General.RestoreTabsNotify := SameText(Value, 'true') Or (Value = '1');
    gskGeneralSaveTabsWhenChanged                  : General.SaveTabsWhenChanged := SameText(Value, 'true') Or (Value = '1');
    gskGeneralLoadGuakeYml                         : General.LoadGuakeYml := SameText(Value, 'true') Or (Value = '1');
    gskGeneralUseLoginShell                        : General.UseLoginShell := SameText(Value, 'true') Or (Value = '1');
    gskGeneralUseTrayicon                          : General.UseTrayicon := SameText(Value, 'true') Or (Value = '1');
    gskGeneralWorkspaceSpecificTabSets             : General.WorkspaceSpecificTabSets := SameText(Value, 'true') Or (Value = '1');
    gskGeneralUsePopup                             : General.UsePopup := SameText(Value, 'true') Or (Value = '1');
    gskGeneralPromptOnQuit                         : General.PromptOnQuit := SameText(Value, 'true') Or (Value = '1');
    gskGeneralPromptOnCloseTab                     : General.PromptOnCloseTab := StrToInt(Value);
    gskGeneralSearchEngine                         : General.SearchEngine := StrToInt(Value);
    gskGeneralCustomSearchEngine                   : General.CustomSearchEngine := Value;
    gskGeneralWindowOntop                          : General.WindowOntop := SameText(Value, 'true') Or (Value = '1');
    gskGeneralWindowRefocus                        : General.WindowRefocus := SameText(Value, 'true') Or (Value = '1');
    gskGeneralTabOntop                             : General.TabOntop := SameText(Value, 'true') Or (Value = '1');
    gskGeneralNewTabAfter                          : General.NewTabAfter := SameText(Value, 'true') Or (Value = '1');
    gskGeneralWindowLosefocus                      : General.WindowLosefocus := SameText(Value, 'true') Or (Value = '1');
    gskGeneralLazyLosefocus                        : General.LazyLosefocus := SameText(Value, 'true') Or (Value = '1');
    gskGeneralWindowTabbar                         : General.WindowTabbar := SameText(Value, 'true') Or (Value = '1');
    gskGeneralFullscreenHideTabbar                 : General.FullscreenHideTabbar := SameText(Value, 'true') Or (Value = '1');
    gskGeneralHideTabsIfOneTab                     : General.HideTabsIfOneTab := SameText(Value, 'true') Or (Value = '1');
    gskGeneralQuickOpenEnable                      : General.QuickOpenEnable := SameText(Value, 'true') Or (Value = '1');
    gskGeneralQuickOpenCommandLine                 : General.QuickOpenCommandLine := Value;
    gskGeneralQuickOpenInCurrentTerminal           : General.QuickOpenInCurrentTerminal := SameText(Value, 'true') Or (Value = '1');
    gskGeneralStartupScript                        : General.StartupScript := Value;
    gskGeneralStartFullscreen                      : General.StartFullscreen := SameText(Value, 'true') Or (Value = '1');
    gskGeneralStartAtLogin                         : General.StartAtLogin := SameText(Value, 'true') Or (Value = '1');
    gskGeneralUseAudibleBell                       : General.UseAudibleBell := SameText(Value, 'true') Or (Value = '1');
    gskGeneralDisplayTabActivity                   : General.DisplayTabActivity := SameText(Value, 'true') Or (Value = '1');
    gskGeneralTabActivityNewTabGrace               : General.TabActivityNewTabGrace := StrToFloat(Value, TFormatSettings.Invariant);
    gskGeneralTabActivityFocusLossGrace            : General.TabActivityFocusLossGrace := StrToFloat(Value, TFormatSettings.Invariant);
    gskGeneralWindowWidth                          : General.WindowWidth := StrToInt(Value);
    gskGeneralWindowHeight                         : General.WindowHeight := StrToInt(Value);
    gskGeneralWindowHorizontalDisplacement         : General.WindowHorizontalDisplacement := StrToInt(Value);
    gskGeneralWindowVerticalDisplacement           : General.WindowVerticalDisplacement := StrToInt(Value);
    gskGeneralWindowHalignment                     : General.WindowHalignment := StrToInt(Value);
    gskGeneralWindowValignment                     : General.WindowValignment := StrToInt(Value);
    gskGeneralBackgroundImageFile                  : General.BackgroundImageFile := Value;
    gskGeneralBackgroundImageLayoutMode            : General.BackgroundImageLayoutMode := StrToInt(Value);
    gskGeneralUseScrollbar                         : General.UseScrollbar := SameText(Value, 'true') Or (Value = '1');
    gskGeneralHistorySize                          : General.HistorySize := StrToInt(Value);
    gskGeneralInfiniteHistory                      : General.InfiniteHistory := SameText(Value, 'true') Or (Value = '1');
    gskGeneralScrollOutput                         : General.ScrollOutput := SameText(Value, 'true') Or (Value = '1');
    gskGeneralScrollKeystroke                      : General.ScrollKeystroke := SameText(Value, 'true') Or (Value = '1');
    gskGeneralUseDefaultFont                       : General.UseDefaultFont := SameText(Value, 'true') Or (Value = '1');
    gskGeneralUseVteTitles                         : General.UseVteTitles := SameText(Value, 'true') Or (Value = '1');
    gskGeneralSetWindowTitle                       : General.SetWindowTitle := SameText(Value, 'true') Or (Value = '1');
    gskGeneralCompatBackspace                      : General.CompatBackspace := Value;
    gskGeneralCompatDelete                         : General.CompatDelete := Value;
    gskGeneralWordChars                            : General.WordChars := Value;
    gskGeneralToolbarVisibleInFullscreen           : General.ToolbarVisibleInFullscreen := SameText(Value, 'true') Or (Value = '1');
    gskGeneralFocusIfOpen                          : General.FocusIfOpen := SameText(Value, 'true') Or (Value = '1');
    gskGeneralCustomCommandFile                    : General.CustomCommandFile := Value;
    gskGeneralOpenTabCwd                           : General.OpenTabCwd := SameText(Value, 'true') Or (Value = '1');
    gskGeneralMaxTabNameLength                     : General.MaxTabNameLength := StrToInt(Value);
    gskGeneralDisplayTabNames                      : General.DisplayTabNames := StrToInt(Value);
    gskGeneralGtkUseSystemDefaultTheme             : General.GtkUseSystemDefaultTheme := SameText(Value, 'true') Or (Value = '1');
    gskGeneralGtkThemeName                         : General.GtkThemeName := Value;
    gskGeneralGtkPreferDarkTheme                   : General.GtkPreferDarkTheme := SameText(Value, 'true') Or (Value = '1');
    gskGeneralTabCloseButtons                      : General.TabCloseButtons := SameText(Value, 'true') Or (Value = '1');
    gskGeneralCopyOnSelect                         : General.CopyOnSelect := SameText(Value, 'true') Or (Value = '1');
    gskStyleCursorBlinkMode                        : Style.CursorBlinkMode := StrToInt(Value);
    gskStyleCursorShape                            : Style.CursorShape := StrToInt(Value);
    gskStyleFontStyle                              : Style.Font.Style := Value;
    gskStyleFontPalette                            : Style.Font.Palette := Value;
    gskStyleFontPaletteName                        : Style.Font.PaletteName := Value;
    gskStyleFontAllowBold                          : Style.Font.AllowBold := SameText(Value, 'true') Or (Value = '1');
    gskStyleFontBoldIsBright                       : Style.Font.BoldIsBright := SameText(Value, 'true') Or (Value = '1');
    gskStyleFontCellHeightScale                    : Style.Font.CellHeightScale := StrToFloat(Value, TFormatSettings.Invariant);
    gskStyleFontCellWidthScale                     : Style.Font.CellWidthScale := StrToFloat(Value, TFormatSettings.Invariant);
    gskStyleBackgroundTransparency                 : Style.Background.Transparency := StrToInt(Value);
    gskKeybindingsGlobalShowHide                   : Keybindings.Global.ShowHide := Value;
    gskKeybindingsGlobalShowFocus                  : Keybindings.Global.ShowFocus := Value;
    gskKeybindingsLocalSearchTerminal              : Keybindings.Local.SearchTerminal := Value;
    gskKeybindingsLocalQuit                        : Keybindings.Local.Quit := Value;
    gskKeybindingsLocalNewTab                      : Keybindings.Local.NewTab := Value;
    gskKeybindingsLocalNewTabHome                  : Keybindings.Local.NewTabHome := Value;
    gskKeybindingsLocalNewTabCwd                   : Keybindings.Local.NewTabCwd := Value;
    gskKeybindingsLocalCloseTab                    : Keybindings.Local.CloseTab := Value;
    gskKeybindingsLocalSearchOnWeb                 : Keybindings.Local.SearchOnWeb := Value;
    gskKeybindingsLocalOpenLinkUnderTerminalCursor : Keybindings.Local.OpenLinkUnderTerminalCursor := Value;
    gskKeybindingsLocalMoveTabLeft                 : Keybindings.Local.MoveTabLeft := Value;
    gskKeybindingsLocalMoveTabRight                : Keybindings.Local.MoveTabRight := Value;
    gskKeybindingsLocalPreviousTab                 : Keybindings.Local.PreviousTab := Value;
    gskKeybindingsLocalNextTab                     : Keybindings.Local.NextTab := Value;
    gskKeybindingsLocalPreviousTabAlt              : Keybindings.Local.PreviousTabAlt := Value;
    gskKeybindingsLocalNextTabAlt                  : Keybindings.Local.NextTabAlt := Value;
    gskKeybindingsLocalSwitchTab1                  : Keybindings.Local.SwitchTab1 := Value;
    gskKeybindingsLocalSwitchTab2                  : Keybindings.Local.SwitchTab2 := Value;
    gskKeybindingsLocalSwitchTab3                  : Keybindings.Local.SwitchTab3 := Value;
    gskKeybindingsLocalSwitchTab4                  : Keybindings.Local.SwitchTab4 := Value;
    gskKeybindingsLocalSwitchTab5                  : Keybindings.Local.SwitchTab5 := Value;
    gskKeybindingsLocalSwitchTab6                  : Keybindings.Local.SwitchTab6 := Value;
    gskKeybindingsLocalSwitchTab7                  : Keybindings.Local.SwitchTab7 := Value;
    gskKeybindingsLocalSwitchTab8                  : Keybindings.Local.SwitchTab8 := Value;
    gskKeybindingsLocalSwitchTab9                  : Keybindings.Local.SwitchTab9 := Value;
    gskKeybindingsLocalSwitchTab10                 : Keybindings.Local.SwitchTab10 := Value;
    gskKeybindingsLocalRenameCurrentTab            : Keybindings.Local.RenameCurrentTab := Value;
    gskKeybindingsLocalZoomIn                      : Keybindings.Local.ZoomIn := Value;
    gskKeybindingsLocalZoomInAlt                   : Keybindings.Local.ZoomInAlt := Value;
    gskKeybindingsLocalZoomOut                     : Keybindings.Local.ZoomOut := Value;
    gskKeybindingsLocalIncreaseHeight              : Keybindings.Local.IncreaseHeight := Value;
    gskKeybindingsLocalDecreaseHeight              : Keybindings.Local.DecreaseHeight := Value;
    gskKeybindingsLocalIncreaseTransparency        : Keybindings.Local.IncreaseTransparency := Value;
    gskKeybindingsLocalDecreaseTransparency        : Keybindings.Local.DecreaseTransparency := Value;
    gskKeybindingsLocalClipboardCopy               : Keybindings.Local.ClipboardCopy := Value;
    gskKeybindingsLocalClipboardPaste              : Keybindings.Local.ClipboardPaste := Value;
    gskKeybindingsLocalSelectAll                   : Keybindings.Local.SelectAll := Value;
    gskKeybindingsLocalToggleFullscreen            : Keybindings.Local.ToggleFullscreen := Value;
    gskKeybindingsLocalToggleHideOnLoseFocus       : Keybindings.Local.ToggleHideOnLoseFocus := Value;
    gskKeybindingsLocalResetTerminal               : Keybindings.Local.ResetTerminal := Value;
    gskKeybindingsLocalToggleTransparency          : Keybindings.Local.ToggleTransparency := Value;
    gskKeybindingsLocalSwitchTabLast               : Keybindings.Local.SwitchTabLast := Value;
    gskKeybindingsLocalSplitTabVertical            : Keybindings.Local.SplitTabVertical := Value;
    gskKeybindingsLocalSplitTabHorizontal          : Keybindings.Local.SplitTabHorizontal := Value;
    gskKeybindingsLocalCloseTerminal               : Keybindings.Local.CloseTerminal := Value;
    gskKeybindingsLocalFocusTerminalUp             : Keybindings.Local.FocusTerminalUp := Value;
    gskKeybindingsLocalFocusTerminalDown           : Keybindings.Local.FocusTerminalDown := Value;
    gskKeybindingsLocalFocusTerminalRight          : Keybindings.Local.FocusTerminalRight := Value;
    gskKeybindingsLocalFocusTerminalLeft           : Keybindings.Local.FocusTerminalLeft := Value;
    gskKeybindingsLocalMoveTerminalSplitUp         : Keybindings.Local.MoveTerminalSplitUp := Value;
    gskKeybindingsLocalMoveTerminalSplitDown       : Keybindings.Local.MoveTerminalSplitDown := Value;
    gskKeybindingsLocalMoveTerminalSplitLeft       : Keybindings.Local.MoveTerminalSplitLeft := Value;
    gskKeybindingsLocalMoveTerminalSplitRight      : Keybindings.Local.MoveTerminalSplitRight := Value;
    gskHooksShow                                   : Hooks.Show := Value;
   End;
  End;

 Procedure TGuakeSettings.LoadRecords;
  Var
   Key   : TGuakeSetting;
   Value : String;
  Begin
   For Key := Low(TGuakeSetting) To High(TGuakeSetting) Do
    Begin
     Value := fIni.ReadString(Definitions[Key].Section, Definitions[Key].Key, Definitions[Key].DefaultValue);
     If Not ValidValue(Key, Value) Then
      Value := Definitions[Key].DefaultValue;
     SetRecordValue(Key, Value);
    End;
  End;

 Procedure TGuakeSettings.SetValue(Key : TGuakeSetting; Const Value : String);
  Begin
   If (Pos(#13, Value) > 0) Or (Pos(#10, Value) > 0) Then
    Raise EArgumentException.Create('INI values must be single-line');
   If Not ValidValue(Key, Value) Then
    Raise EArgumentOutOfRangeException.CreateFmt('Invalid value for %s.%s: %s', [Definitions[Key].Section, Definitions[Key].Key, Value]);
   SetRecordValue(Key, Value);
  End;

 Procedure TGuakeSettings.Reset(Key : TGuakeSetting);
  Begin
   fIni.DeleteKey(Definitions[Key].Section, Definitions[Key].Key);
   SetRecordValue(Key, Definitions[Key].DefaultValue);
  End;

 Procedure TGuakeSettings.Assign(Source : TGuakeSettings);
  Var
   Lines : TStringList;
  Begin
   If Source = Nil Then
    Raise EArgumentNilException.Create('Source');
   If Source = Self Then
    Exit;
   General     := Source.General;
   Style       := Source.Style;
   Keybindings := Source.Keybindings;
   Hooks       := Source.Hooks;
   Lines       := TStringList.Create;
   Try
    Source.fIni.GetStrings(Lines);
    fIni.SetStrings(Lines);
   Finally
    Lines.Free;
   End;
  End;

 Function TGuakeSettings.GetStringValue(Index : Integer) : String;
  Begin
   Result := GetValue(TGuakeSetting(Index));
  End;

 Function TGuakeSettings.GetIntegerValue(Index : Integer) : Integer;
  Begin
   Result := StrToInt(GetValue(TGuakeSetting(Index)));
  End;

 Procedure TGuakeSettings.SetStringValue(Index : Integer; Const Value : String);
  Begin
   SetValue(TGuakeSetting(Index), Value);
  End;

 Procedure TGuakeSettings.SetIntegerValue(Index, Value : Integer);
  Begin
   SetValue(TGuakeSetting(Index), IntToStr(Value));
  End;

End.
