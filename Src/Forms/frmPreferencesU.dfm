object frmPreferences: TfrmPreferences
  Left = 0
  Top = 0
  Caption = 'Preferencje programu Guake'
  ClientHeight = 740
  ClientWidth = 1180
  Constraints.MinHeight = 640
  Constraints.MinWidth = 1100
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object pnlHeader: TPanel
    Align = alTop
    Height = 92
    BevelOuter = bvNone
    TabOrder = 2
    object imgHeader: TImage
      Left = 20
      Top = 22
      Width = 48
      Height = 48
      Proportional = True
      Center = True
    end
    object lblHeaderTitle: TLabel
      Left = 84
      Top = 21
      Caption = 'Właściwości programu Guake'
      Font.Height = -24
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblHeaderDescription: TLabel
      Left = 84
      Top = 54
      Caption = 'Dostosowanie zachowania i wyglądu programu Guake!'
    end
  end
  object navPages: TListBox
    Align = alLeft
    Width = 160
    BorderStyle = bsNone
    ItemHeight = 50
    Style = lbOwnerDrawFixed
    TabOrder = 3
    OnClick = NavigationClick
    OnDrawItem = NavigationDrawItem
    Items.Strings = (
      'Ogólne'
      'Główne okno'
      'Powłoka'
      'Przewijanie'
      'Wygląd'
      'Skróty klawiszowe'
      'Szybkie otwieranie'
      'Zaczepy'
      'Zgodność')
  end
  object pnlFooter: TPanel
    Width = 960
    Align = alBottom
    Height = 48
    BevelOuter = bvNone
    TabOrder = 1
    object btnClose: TButton
      Left = 842
      Top = 10
      Width = 100
      Height = 28
      Anchors = [akTop, akRight]
      Caption = 'Zamknij'
      Cancel = True
      OnClick = CloseClick
    end
  end
  object pages: TPageControl
    Width = 960
    Height = 692
    Align = alClient
    ActivePage = tabGeneral
    OnChange = PagesChanged
    MultiLine = True
    TabOrder = 0
    object tabGeneral: TTabSheet
      TabVisible = False
      ExplicitWidth = 952
      ExplicitHeight = 640
      Caption = 'Ogólne'
      object scrollGeneral: TScrollBox
        Width = 952
        Height = 640
        Align = alClient
        BorderStyle = bsNone
        HorzScrollBar.Visible = False
        VertScrollBar.Tracking = True
        TabOrder = 0
        object grpGeneral0: TGroupBox
          Left = 16
          Top = 12
          Width = 900
          Height = 196
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Uruchamianie i karty (eksperymentalne)'
          object ctlRestoreTabsStartup: TCheckBox
            Left = 16
            Top = 24
            Width = 760
            Height = 36
            Tag = 6
            Hint = 'If true, when guake startup, it will restore tabs from previous session'
            ShowHint = True
            Caption = 'Przywracanie poprzedniej sesji (kart)'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlRestoreTabsNotify: TCheckBox
            Left = 16
            Top = 64
            Width = 760
            Height = 36
            Tag = 7
            Hint = 'If true, when guake restored the tabs, it will notify the user that the tabs has been restored'
            ShowHint = True
            Caption = 'Powiadomienie po przywróceniu kart'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlSaveTabsWhenChanged: TCheckBox
            Left = 16
            Top = 104
            Width = 760
            Height = 36
            Tag = 8
            Hint = 'If true, when tabs has changed (add / delete ...etc.), it will automatically saved the tabs session'
            ShowHint = True
            Caption = 'Automatyczne zapisywanie sesji po modyfikacji kart'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlLoadGuakeYml: TCheckBox
            Left = 16
            Top = 144
            Width = 760
            Height = 36
            Tag = 9
            Hint = 'If true, when a change in the cwd is detected settings are changed based on the content of the file `cwd`/.guake.yml'
            ShowHint = True
            Caption = 'Load settings from `cwd`/.guake.yml'
            WordWrap = True
            OnClick = SettingChanged
          end
        end
        object grpGeneral1: TGroupBox
          Left = 16
          Top = 222
          Width = 900
          Height = 556
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Ogólne'
          object ctlUsePopup: TCheckBox
            Left = 16
            Top = 24
            Width = 760
            Height = 36
            Tag = 13
            Hint = 'When true, popup notifications will be shown when Guake starts.'
            ShowHint = True
            Caption = 'Wyskakujące powiadomienia podczas uruchamiania'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlUseAudibleBell: TCheckBox
            Left = 16
            Top = 64
            Width = 760
            Height = 36
            Tag = 33
            Hint = 'If true, the system alert sound will be played on a bell character.'
            ShowHint = True
            Caption = 'Systemowy &dźwięk alarmu jako dzwonek'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlStartAtLogin: TCheckBox
            Left = 16
            Top = 104
            Width = 760
            Height = 36
            Tag = 32
            Hint = 'When true, the program will start upon GNOME login.'
            ShowHint = True
            Caption = 'Uruchamianie programu Guake podczas logowania'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlDisplayTabActivity: TCheckBox
            Left = 16
            Top = 144
            Width = 760
            Height = 36
            Tag = 34
            Hint = 'If true, the title of a background tab is highlighted when its terminal produces output, until the tab is selected.'
            ShowHint = True
            Caption = 'Highlight tabs with activity'
            WordWrap = True
            OnClick = SettingChanged
          end
          object lblTabActivityNewTabGrace: TLabel
            Left = 16
            Top = 188
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Ignore activity on new tabs for (seconds):'
          end
          object ctlTabActivityNewTabGrace: TEdit
            Left = 450
            Top = 184
            Width = 314
            Height = 25
            Tag = 35
            Hint = 'Number of seconds during which activity is ignored on a newly created tab, to avoid highlighting it because of its initial shell prompt.'
            ShowHint = True
            OnExit = SettingChanged
          end
          object lblTabActivityFocusLossGrace: TLabel
            Left = 16
            Top = 228
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Ignore activity after losing focus for (seconds):'
          end
          object ctlTabActivityFocusLossGrace: TEdit
            Left = 450
            Top = 224
            Width = 314
            Height = 25
            Tag = 36
            Hint = 'Number of seconds during which activity is ignored on a tab right after it loses focus.'
            ShowHint = True
            OnExit = SettingChanged
          end
          object lblPromptOnCloseTab: TLabel
            Left = 16
            Top = 268
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Potwierdzenie podczas zamykania karty:'
          end
          object ctlPromptOnCloseTab: TComboBox
            Left = 450
            Top = 264
            Width = 314
            Height = 25
            Tag = 15
            Hint = '0: Never 1: If process is running 2: Always.  Also prompts on quit.'
            ShowHint = True
            Style = csDropDownList
            OnChange = SettingChanged
            Items.Strings = (
              'Nigdy'
              'Kiedy jest uruchomiony proces'
              'Zawsze')
          end
          object ctlPromptOnQuit: TCheckBox
            Left = 16
            Top = 304
            Width = 760
            Height = 36
            Tag = 14
            Hint = 'Ask for confirmation when quitting Guake.'
            ShowHint = True
            Caption = 'Potwierdzenie podczas kończenia działania'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlUseTrayicon: TCheckBox
            Left = 16
            Top = 344
            Width = 760
            Height = 36
            Tag = 11
            Hint = 'When true tray is visible.'
            ShowHint = True
            Caption = 'Ikona obszaru powiadamiania'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlUseVisibleBell: TCheckBox
            Left = 16
            Top = 384
            Width = 760
            Height = 36
            Caption = '&Miganie terminalem jako dzwonek'
            Enabled = False
            Hint = 'Opcja nie ma klucza w oryginalnym schemacie Guake.'
            ShowHint = True
          end
          object ctlWorkspaceSpecificTabSets: TCheckBox
            Left = 16
            Top = 424
            Width = 760
            Height = 36
            Tag = 12
            Hint = 'When true, each workspace gets their own set of tabs.'
            ShowHint = True
            Caption = 'Używa zestawów kart dla konkretnych obszarów roboczych (wymaga ponownego uruchomienia, działa tylko w systemie X11)'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlTabCloseButtons: TCheckBox
            Left = 16
            Top = 464
            Width = 760
            Height = 36
            Tag = 65
            Hint = 'Show close buttons next to tab titles'
            ShowHint = True
            Caption = 'Przyciski zamknięcia kart'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlCopyOnSelect: TCheckBox
            Left = 16
            Top = 504
            Width = 760
            Height = 36
            Tag = 66
            Hint = 'Copy the selected text.'
            ShowHint = True
            Caption = 'Kopiowanie podczas zaznaczania'
            WordWrap = True
            OnClick = SettingChanged
          end
        end
        object grpGeneral2: TGroupBox
          Left = 16
          Top = 792
          Width = 900
          Height = 276
          Anchors = [akLeft, akTop, akRight]
          Caption = ''
          object ctlGtkUseSystemDefaultTheme: TCheckBox
            Left = 16
            Top = 24
            Width = 760
            Height = 36
            Tag = 62
            Hint = 'Prefer the system default theme'
            ShowHint = True
            Caption = 'Domyślny motyw systemu'
            WordWrap = True
            OnClick = SettingChanged
          end
          object lblGtkThemeName: TLabel
            Left = 16
            Top = 68
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Motyw biblioteki GTK:'
          end
          object ctlGtkThemeName: TComboBox
            Left = 450
            Top = 64
            Width = 314
            Height = 25
            Tag = 63
            Hint = 'Name of the GTK theme to apply on Guake. If set to an empty string, let GTK use the default system theme'
            ShowHint = True
            Style = csDropDown
            OnChange = SettingChanged
            OnExit = SettingChanged
          end
          object ctlGtkPreferDarkTheme: TCheckBox
            Left = 16
            Top = 104
            Width = 760
            Height = 36
            Tag = 64
            Hint = 'Prefer the dark theme version of the theme if available'
            ShowHint = True
            Caption = 'Ciemny motyw'
            WordWrap = True
            OnClick = SettingChanged
          end
          object lblCustomCommandFileChooser: TLabel
            Left = 16
            Top = 148
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Inna ścieżka do pliku polecenia:'
          end
          object browseCustomCommandFileChooser: TButton
            Left = 692
            Top = 144
            Width = 72
            Height = 26
            Tag = 58
            Caption = '…'
            OnClick = BrowseClick
          end
          object ctlCustomCommandFileChooser: TEdit
            Left = 450
            Top = 144
            Width = 234
            Height = 25
            Tag = 58
            Hint = 'Path to the default custom command json file. If is blank or the json file is not in a proper format the terminal context menu will be built without custom commands. If the file is a valid json with recognized structure theterminak context menu will be built with the commands read inside.'
            ShowHint = True
            OnExit = SettingChanged
          end
          object lblSearchEngineSelect: TLabel
            Left = 16
            Top = 188
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Search Engine:'
          end
          object ctlSearchEngineSelect: TComboBox
            Left = 450
            Top = 184
            Width = 314
            Height = 25
            Tag = 16
            Hint = 'Search engine to use'
            ShowHint = True
            Style = csDropDownList
            OnChange = SettingChanged
            Items.Strings = (
              'Google'
              'DuckDuckGo'
              'Bing'
              'Yandex'
              'Neeva'
              'Inne')
          end
          object lblCustomSearch: TLabel
            Left = 16
            Top = 228
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Custom Search:'
          end
          object ctlCustomSearch: TEdit
            Left = 450
            Top = 224
            Width = 314
            Height = 25
            Tag = 17
            Hint = 'Custom search engine url to use'
            ShowHint = True
            OnExit = SettingChanged
          end
        end
      end
    end
    object tabMainWindow: TTabSheet
      TabVisible = False
      ExplicitWidth = 952
      ExplicitHeight = 640
      Caption = 'Główne okno'
      object scrollMainWindow: TScrollBox
        Width = 952
        Height = 640
        Align = alClient
        BorderStyle = bsNone
        HorzScrollBar.Visible = False
        VertScrollBar.Tracking = True
        TabOrder = 0
        object grpMainWindow0: TGroupBox
          Left = 16
          Top = 12
          Width = 900
          Height = 556
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Opcje głównego okna'
          object ctlWindowRefocus: TCheckBox
            Left = 16
            Top = 24
            Width = 760
            Height = 36
            Tag = 19
            Hint = 'Refocus window instead of closing.'
            ShowHint = True
            Caption = 'Ponowna aktywacja, jeśli jest otwarty'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlWindowLosefocus: TCheckBox
            Left = 16
            Top = 64
            Width = 760
            Height = 36
            Tag = 22
            Hint = 'If this property is set as true, guake will be hidden when the main window lose the focus (when Alt+Tab be pressed for example).'
            ShowHint = True
            Caption = 'Ukrycie po utracie aktywności'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlStartFullscreen: TCheckBox
            Left = 16
            Top = 104
            Width = 760
            Height = 36
            Tag = 31
            Hint = 'When true, the program will start in fullscreen mode.'
            ShowHint = True
            Caption = 'Uruchamianie w trybie pełnoekranowym'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlWindowOntop: TCheckBox
            Left = 16
            Top = 144
            Width = 760
            Height = 36
            Tag = 18
            Hint = 'Makes guake window be on top of all other windows in the desktop.'
            ShowHint = True
            Caption = 'Zawsze na wierzchu'
            WordWrap = True
            OnClick = SettingChanged
          end
          object lblTabNameDisplay: TLabel
            Left = 16
            Top = 188
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Nazwy kart:'
          end
          object ctlTabNameDisplay: TComboBox
            Left = 450
            Top = 184
            Width = 314
            Height = 25
            Tag = 61
            Hint = 'Controls how the tab names are displayed. 0: Full Path, 1: Abbreviated Path, 2: Only display the last segment of the path'
            ShowHint = True
            Style = csDropDownList
            OnChange = SettingChanged
            Items.Strings = (
              'Pełna ścieżka'
              'Skrócona ścieżka'
              'Ostatni segment')
          end
          object lblMaxTabNameLength: TLabel
            Left = 16
            Top = 228
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Maksymalna długość nazwy karty:'
          end
          object ctlMaxTabNameLength: TSpinEdit
            Left = 450
            Top = 224
            Width = 180
            Height = 25
            Tag = 60
            Hint = '#TODO PORT max-tab-name-length'
            ShowHint = True
            MinValue = 0
            MaxValue = 1000
            Value = 0
            OnExit = SettingChanged
          end
          object ctlNewTabAfter: TCheckBox
            Left = 16
            Top = 264
            Width = 760
            Height = 36
            Tag = 21
            Hint = 'Makes new tabs appear after the currently selected tab, instead of at the end.'
            ShowHint = True
            Caption = 'Otwieranie nowych kart za bieżącą kartą'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlFullscreenHideTabbar: TCheckBox
            Left = 16
            Top = 304
            Width = 760
            Height = 36
            Tag = 25
            Hint = 'When true, the tab bar will hide when is in fullscreen'
            ShowHint = True
            Caption = 'Ukrywanie paska kart w trybie pełnoekranowym'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlHideTabsIfOneTab: TCheckBox
            Left = 16
            Top = 344
            Width = 760
            Height = 36
            Tag = 26
            Hint = 'When true, the tab bar will hide when there is only one tab'
            ShowHint = True
            Caption = 'Ukrywanie paska kart, kiedy jest tylko jedna karta'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlSetWindowTitle: TCheckBox
            Left = 16
            Top = 384
            Width = 760
            Height = 36
            Tag = 52
            Hint = 'If true, Guake will update its window title from the current tab name. It is useful when you work with applications that use windows title, (keepass, automatic time tracker apps)'
            ShowHint = True
            Caption = 'Ustawianie tytułu okna na nazwę obecnej karty'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlUseVteTitles: TCheckBox
            Left = 16
            Top = 424
            Width = 760
            Height = 36
            Tag = 51
            Hint = 'Any terminal program can set the terminal''s title via special escape sequences. Some shells (e.g. bash) display user''s prompt there (though you can adjust that to any arbitrary text in bashrc or similar) and update it automatically as the prompt changes. So you can have easy automatically updating meaningful tab titles with this option turned on.'
            ShowHint = True
            Caption = 'Tytuły VTE dla nazw kart'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlWindowTabbar: TCheckBox
            Left = 16
            Top = 464
            Width = 760
            Height = 36
            Tag = 24
            Hint = 'When true, the tab bar is visible.'
            ShowHint = True
            Caption = 'Pasek kart'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlLazyLoseFocus: TCheckBox
            Left = 16
            Top = 504
            Width = 760
            Height = 36
            Tag = 23
            Hint = 'Momentarily delay hiding Guake when focus is lost and don''t hide if focus is returned quickly, like when switching desktops or turning on certain IMEs.'
            ShowHint = True
            Caption = 'Lazy hide on lose focus'
            WordWrap = True
            OnClick = SettingChanged
          end
        end
        object grpMainWindow1: TGroupBox
          Left = 16
          Top = 582
          Width = 900
          Height = 196
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Umieszczenie'
          object ctlTopAlign: TCheckBox
            Left = 16
            Top = 24
            Width = 760
            Height = 36
            Tag = 42
            Hint = 'Place Guake at: 0: top, 1: bottom'
            ShowHint = True
            Caption = 'Okno na dole zamiast na górze'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlMouseDisplay: TCheckBox
            Left = 16
            Top = 64
            Width = 760
            Height = 36
            Tag = 3
            Hint = 'Appear on the mouse display. This overrides any setting in display_n.'
            ShowHint = True
            Caption = 'Wyświetlanie na ekranie z kursorem'
            WordWrap = True
            OnClick = SettingChanged
          end
          object lblDisplayN: TLabel
            Left = 16
            Top = 108
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Wyświetlanie na ekranie:'
          end
          object ctlDisplayN: TComboBox
            Left = 450
            Top = 104
            Width = 314
            Height = 25
            Tag = 4
            Hint = 'Display to appear on if the  mouse_display option is not set. If this is set to an invalid value (as in the case of removing a screen from a system), the invalid value is automatically updated to the current primary screen.'
            ShowHint = True
            Style = csDropDownList
            OnChange = SettingChanged
          end
          object ctlTabOntop: TCheckBox
            Left = 16
            Top = 144
            Width = 760
            Height = 36
            Tag = 20
            Hint = 'Makes tab bar on top of the Guake window. Per default, tabs appear below the terminal. Setting this to True will move the tab on top of the terminal. Requires a restart.'
            ShowHint = True
            Caption = 'Karty na górze'
            WordWrap = True
            OnClick = SettingChanged
          end
        end
        object grpMainWindow2: TGroupBox
          Left = 16
          Top = 792
          Width = 900
          Height = 254
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Geometria'
          object lblWindowHeight: TLabel
            Left = 16
            Top = 29
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Wysokość:'
          end
          object valueWindowHeight: TLabel
            Left = 718
            Top = 30
            Width = 60
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = ''
          end
          object ctlWindowHeight: TTrackBar
            Left = 450
            Top = 24
            Width = 260
            Height = 40
            Tag = 38
            Hint = 'Percent of the screen that will be used by guake terminal vertically.'
            ShowHint = True
            Min = 1
            Max = 100
            Frequency = 10
            PageSize = 10
            OnChange = SettingChanged
          end
          object lblWindowWidth: TLabel
            Left = 16
            Top = 77
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Szerokość:'
          end
          object valueWindowWidth: TLabel
            Left = 718
            Top = 78
            Width = 60
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = ''
          end
          object ctlWindowWidth: TTrackBar
            Left = 450
            Top = 72
            Width = 260
            Height = 40
            Tag = 37
            Hint = 'Percent of the screen that will be used by guake terminal horizontally.'
            ShowHint = True
            Min = 1
            Max = 100
            Frequency = 10
            PageSize = 10
            OnChange = SettingChanged
          end
          object lblWindowVerticalDisplacement: TLabel
            Left = 16
            Top = 124
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Vertical displacement in pixels:'
          end
          object ctlWindowVerticalDisplacement: TSpinEdit
            Left = 450
            Top = 120
            Width = 180
            Height = 25
            Tag = 40
            Hint = 'Displace the window vertically by a given amount of pixels.'
            ShowHint = True
            MinValue = 0
            MaxValue = 10000000
            Value = 0
            OnExit = SettingChanged
          end
          object lblWindowHorizontalDisplacement: TLabel
            Left = 16
            Top = 164
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Horizontal displacement in pixels:'
          end
          object ctlWindowHorizontalDisplacement: TSpinEdit
            Left = 450
            Top = 160
            Width = 180
            Height = 25
            Tag = 39
            Hint = 'Displace the window horizontally by a given amount of pixels.'
            ShowHint = True
            MinValue = 0
            MaxValue = 10000000
            Value = 0
            OnExit = SettingChanged
          end
          object lblAlignment: TLabel
            Left = 16
            Top = 204
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Wyrównanie poziome:'
          end
          object ctlAlignLeft: TRadioButton
            Left = 450
            Top = 200
            Width = 100
            Height = 25
            Tag = 41
            HelpContext = 1
            Caption = 'Lewo'
            OnClick = SettingChanged
          end
          object ctlAlignCenter: TRadioButton
            Left = 556
            Top = 200
            Width = 100
            Height = 25
            Tag = 41
            HelpContext = 0
            Caption = '?rodek'
            OnClick = SettingChanged
          end
          object ctlAlignRight: TRadioButton
            Left = 662
            Top = 200
            Width = 100
            Height = 25
            Tag = 41
            HelpContext = 2
            Caption = 'Prawo'
            OnClick = SettingChanged
          end
        end
      end
    end
    object tabShell: TTabSheet
      TabVisible = False
      ExplicitWidth = 952
      ExplicitHeight = 640
      Caption = 'Powłoka'
      object scrollShell: TScrollBox
        Width = 952
        Height = 640
        Align = alClient
        BorderStyle = bsNone
        HorzScrollBar.Visible = False
        VertScrollBar.Tracking = True
        TabOrder = 0
        object grpShell0: TGroupBox
          Left = 16
          Top = 12
          Width = 900
          Height = 156
          Anchors = [akLeft, akTop, akRight]
          Caption = ''
          object lblDefaultShell: TLabel
            Left = 16
            Top = 28
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Domyślna powłoka:'
          end
          object ctlDefaultShell: TComboBox
            Left = 450
            Top = 24
            Width = 314
            Height = 25
            Tag = 5
            Hint = 'Path to the default shell. Set to empty to use default user shell. If invalid path is set here, guake will fallback to user shell.'
            ShowHint = True
            Style = csDropDown
            OnChange = SettingChanged
            OnExit = SettingChanged
            Items.Strings = (
              '<pow?oka u?ytkownika>'
              'CMD'
              'PowerShell'
              'Bash (git-sdk-64)'
              'Zsh (git-sdk-64)')
          end
          object ctlUseLoginShell: TCheckBox
            Left = 16
            Top = 64
            Width = 760
            Height = 36
            Tag = 10
            Hint = 'If true, the commands in terminal will be executed in a login shell.'
            ShowHint = True
            Caption = 'U&ruchamianie polecenia jako powłokę logowania'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlOpenTabCwd: TCheckBox
            Left = 16
            Top = 104
            Width = 760
            Height = 36
            Tag = 59
            Hint = 'Open new tab in the current working directory'
            ShowHint = True
            Caption = '&Otwieranie nowych kart w bieżącym katalogu'
            WordWrap = True
            OnClick = SettingChanged
          end
        end
        object lblShellNote: TLabel
          Left = 20
          Top = 190
          Width = 860
          Height = 32
          AutoSize = False
          WordWrap = True
          Caption = 'To może nie działać we wszystkich powłokach, proszę się upewnić, że używana powłoka obsługuje opcję --login'
        end
      end
    end
    object tabScrolling: TTabSheet
      TabVisible = False
      ExplicitWidth = 952
      ExplicitHeight = 640
      Caption = 'Przewijanie'
      object scrollScrolling: TScrollBox
        Width = 952
        Height = 640
        Align = alClient
        BorderStyle = bsNone
        HorzScrollBar.Visible = False
        VertScrollBar.Tracking = True
        TabOrder = 0
        object grpScrolling0: TGroupBox
          Left = 16
          Top = 12
          Width = 900
          Height = 156
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Pasek przewijania'
          object ctlUseScrollbar: TCheckBox
            Left = 16
            Top = 24
            Width = 760
            Height = 36
            Tag = 45
            Hint = 'When true, scrollbar is visible.'
            ShowHint = True
            Caption = 'Pasek przewijania'
            WordWrap = True
            OnClick = SettingChanged
          end
          object lblHistorySize: TLabel
            Left = 16
            Top = 68
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Przewijanie:'
          end
          object ctlHistorySize: TSpinEdit
            Left = 450
            Top = 64
            Width = 180
            Height = 25
            Tag = 46
            Hint = 'The number of scrollback lines to save in history.'
            ShowHint = True
            MinValue = 0
            MaxValue = 10000000
            Value = 0
            OnExit = SettingChanged
          end
          object ctlInfiniteHistory: TCheckBox
            Left = 16
            Top = 104
            Width = 760
            Height = 36
            Tag = 47
            Hint = 'Scrollback lines in history is infinite'
            ShowHint = True
            Caption = 'Nieograniczone przewijanie'
            WordWrap = True
            OnClick = SettingChanged
          end
        end
        object grpScrolling1: TGroupBox
          Left = 16
          Top = 182
          Width = 900
          Height = 116
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Przewijanie na dół'
          object ctlScrollOutput: TCheckBox
            Left = 16
            Top = 24
            Width = 760
            Height = 36
            Tag = 48
            Hint = 'If true, whenever there is new output in the terminal, it will scroll to the bottom.'
            ShowHint = True
            Caption = 'Po wyjściu'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlScrollKeystroke: TCheckBox
            Left = 16
            Top = 64
            Width = 760
            Height = 36
            Tag = 49
            Hint = 'If true and a key is pressed, the terminal is scrolled to the bottom.'
            ShowHint = True
            Caption = 'Po wciśnięciu klawisza'
            WordWrap = True
            OnClick = SettingChanged
          end
        end
      end
    end
    object tabAppearance: TTabSheet
      TabVisible = False
      ExplicitWidth = 952
      ExplicitHeight = 640
      Caption = 'Wygląd'
      object scrollAppearance: TScrollBox
        Width = 952
        Height = 640
        Align = alClient
        BorderStyle = bsNone
        HorzScrollBar.Visible = False
        VertScrollBar.Tracking = True
        TabOrder = 0
        object grpAppearance0: TGroupBox
          Left = 16
          Top = 12
          Width = 900
          Height = 476
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Ogólne'
          object ctlUseDefaultFont: TCheckBox
            Left = 16
            Top = 24
            Width = 760
            Height = 36
            Tag = 50
            Hint = 'If true, Guake will use the GNOME monospace default font.'
            ShowHint = True
            Caption = 'Systemowa czcionka o stałej szerokości'
            WordWrap = True
            OnClick = SettingChanged
          end
          object lblFontStyle: TLabel
            Left = 16
            Top = 68
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Czcionka:'
          end
          object ctlFontStyle: TButton
            Left = 450
            Top = 64
            Width = 314
            Height = 28
            Tag = 69
            Hint = 'Font face and size that will be used in terminal.'
            ShowHint = True
            Caption = 'Monospace 10'
            OnClick = FontClick
          end
          object lblCursorShape: TLabel
            Left = 16
            Top = 108
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Kształt kursora:'
          end
          object ctlCursorShape: TComboBox
            Left = 450
            Top = 104
            Width = 314
            Height = 25
            Tag = 68
            Hint = 'Controls the shape of the cursor in the terminals. 0: Block, 1: I-Beam, 2: Underline'
            ShowHint = True
            Style = csDropDownList
            OnChange = SettingChanged
            Items.Strings = (
              'Blokowy'
              'Linia pionowa'
              'Podkreślenie')
          end
          object lblCursorBlinkMode: TLabel
            Left = 16
            Top = 148
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Tryb migania kursora:'
          end
          object ctlCursorBlinkMode: TComboBox
            Left = 450
            Top = 144
            Width = 314
            Height = 25
            Tag = 67
            Hint = 'Controls the blink mode of the cursor in the terminals. 0: Follow GTK+ setting, 1: Blink on, 2: Blink off'
            ShowHint = True
            Style = csDropDownList
            OnChange = SettingChanged
            Items.Strings = (
              'Ustawienie biblioteki GTK+'
              'Miganie'
              'Bez migania')
          end
          object ctlAllowBold: TCheckBox
            Left = 16
            Top = 184
            Width = 760
            Height = 36
            Tag = 72
            Hint = 'When allow_bold is disabled, any text in Guake terminal intended to print as bold text will be instead rendered as normal text.'
            ShowHint = True
            Caption = 'Zezwolenie na pogrubioną czcionkę'
            WordWrap = True
            OnClick = SettingChanged
          end
          object ctlBoldIsBright: TCheckBox
            Left = 16
            Top = 224
            Width = 760
            Height = 36
            Tag = 73
            Hint = 'If true, text from the first 8 colors that is formatted as bold will also be switched to its bright variant (VTE >=0.52).'
            ShowHint = True
            Caption = 'Pogrubiony tekst jest także jasny (biblioteka VTE w wersji co najmniej 0.52)'
            WordWrap = True
            OnClick = SettingChanged
          end
          object lblBackgroundImageFilechooser: TLabel
            Left = 16
            Top = 268
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Background image:'
          end
          object browseBackgroundImageFilechooser: TButton
            Left = 692
            Top = 264
            Width = 72
            Height = 26
            Tag = 43
            Caption = '…'
            OnClick = BrowseClick
          end
          object clearBackground: TButton
            Left = 692
            Top = 294
            Width = 72
            Height = 26
            Caption = 'Wyczyść'
            OnClick = ClearBackgroundClick
          end
          object ctlBackgroundImageFilechooser: TEdit
            Left = 450
            Top = 264
            Width = 234
            Height = 25
            Tag = 43
            Hint = 'When setup, the selected background image will show on guake'
            ShowHint = True
            OnExit = SettingChanged
          end
          object lblBackgroundImageLayoutMode: TLabel
            Left = 16
            Top = 332
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Background image layout:'
          end
          object ctlBackgroundImageLayoutMode: TComboBox
            Left = 450
            Top = 328
            Width = 314
            Height = 25
            Tag = 44
            Hint = 'To select which layout mode want to use for background image.'
            ShowHint = True
            Style = csDropDownList
            OnChange = SettingChanged
            Items.Strings = (
              'Skalowanie'
              'Kafelki'
              'Na środku'
              'Rozciąganie')
          end
          object lblCellHeightScale: TLabel
            Left = 16
            Top = 373
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Line Height Scale (VTE >= 0.52)'
          end
          object valueCellHeightScale: TLabel
            Left = 718
            Top = 374
            Width = 60
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = ''
          end
          object ctlCellHeightScale: TTrackBar
            Left = 450
            Top = 368
            Width = 260
            Height = 40
            Tag = 74
            Hint = 'This can be used to increase the line spacing. (The font''s height is not affected.) Valid values go from 1.0 (default) to 2.0 ("double spacing").'
            ShowHint = True
            Min = 100
            Max = 200
            Frequency = 10
            PageSize = 10
            OnChange = SettingChanged
          end
          object lblCellWidthScale: TLabel
            Left = 16
            Top = 421
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Line Width Scale (VTE >= 0.52)'
          end
          object valueCellWidthScale: TLabel
            Left = 718
            Top = 422
            Width = 60
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = ''
          end
          object ctlCellWidthScale: TTrackBar
            Left = 450
            Top = 416
            Width = 260
            Height = 40
            Tag = 75
            Hint = 'This can be used to increase the letter spacing. (The font''s width is not affected.) Valid values go from 1.0 (default) to 2.0 ("double spacing").'
            ShowHint = True
            Min = 100
            Max = 200
            Frequency = 10
            PageSize = 10
            OnChange = SettingChanged
          end
        end
        object grpAppearance1: TGroupBox
          Left = 16
          Top = 502
          Width = 900
          Height = 360
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Paleta'
          object lblPaletteName: TLabel
            Left = 16
            Top = 28
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Wbudowane schematy:'
          end
          object ctlPaletteName: TComboBox
            Left = 450
            Top = 24
            Width = 314
            Height = 25
            Tag = 71
            Hint = 'Color scheme name that will be used in terminal.'
            ShowHint = True
            Style = csDropDown
            OnChange = SettingChanged
            OnExit = SettingChanged
          end
          object lblPalette0: TLabel
            Left = 16
            Top = 64
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '0'
          end
          object colorPalette0: TColorBox
            Left = 16
            Top = 90
            Width = 96
            Height = 25
            Tag = -100
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette1: TLabel
            Left = 120
            Top = 64
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '1'
          end
          object colorPalette1: TColorBox
            Left = 120
            Top = 90
            Width = 96
            Height = 25
            Tag = -101
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette2: TLabel
            Left = 224
            Top = 64
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '2'
          end
          object colorPalette2: TColorBox
            Left = 224
            Top = 90
            Width = 96
            Height = 25
            Tag = -102
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette3: TLabel
            Left = 328
            Top = 64
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '3'
          end
          object colorPalette3: TColorBox
            Left = 328
            Top = 90
            Width = 96
            Height = 25
            Tag = -103
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette4: TLabel
            Left = 432
            Top = 64
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '4'
          end
          object colorPalette4: TColorBox
            Left = 432
            Top = 90
            Width = 96
            Height = 25
            Tag = -104
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette5: TLabel
            Left = 536
            Top = 64
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '5'
          end
          object colorPalette5: TColorBox
            Left = 536
            Top = 90
            Width = 96
            Height = 25
            Tag = -105
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette6: TLabel
            Left = 640
            Top = 64
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '6'
          end
          object colorPalette6: TColorBox
            Left = 640
            Top = 90
            Width = 96
            Height = 25
            Tag = -106
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette7: TLabel
            Left = 744
            Top = 64
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '7'
          end
          object colorPalette7: TColorBox
            Left = 744
            Top = 90
            Width = 96
            Height = 25
            Tag = -107
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette8: TLabel
            Left = 16
            Top = 126
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '8'
          end
          object colorPalette8: TColorBox
            Left = 16
            Top = 152
            Width = 96
            Height = 25
            Tag = -108
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette9: TLabel
            Left = 120
            Top = 126
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '9'
          end
          object colorPalette9: TColorBox
            Left = 120
            Top = 152
            Width = 96
            Height = 25
            Tag = -109
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette10: TLabel
            Left = 224
            Top = 126
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '10'
          end
          object colorPalette10: TColorBox
            Left = 224
            Top = 152
            Width = 96
            Height = 25
            Tag = -110
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette11: TLabel
            Left = 328
            Top = 126
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '11'
          end
          object colorPalette11: TColorBox
            Left = 328
            Top = 152
            Width = 96
            Height = 25
            Tag = -111
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette12: TLabel
            Left = 432
            Top = 126
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '12'
          end
          object colorPalette12: TColorBox
            Left = 432
            Top = 152
            Width = 96
            Height = 25
            Tag = -112
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette13: TLabel
            Left = 536
            Top = 126
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '13'
          end
          object colorPalette13: TColorBox
            Left = 536
            Top = 152
            Width = 96
            Height = 25
            Tag = -113
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette14: TLabel
            Left = 640
            Top = 126
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '14'
          end
          object colorPalette14: TColorBox
            Left = 640
            Top = 152
            Width = 96
            Height = 25
            Tag = -114
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette15: TLabel
            Left = 744
            Top = 126
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '15'
          end
          object colorPalette15: TColorBox
            Left = 744
            Top = 152
            Width = 96
            Height = 25
            Tag = -115
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette16: TLabel
            Left = 16
            Top = 188
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Foreground'
          end
          object colorPalette16: TColorBox
            Left = 16
            Top = 214
            Width = 96
            Height = 25
            Tag = -116
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object lblPalette17: TLabel
            Left = 120
            Top = 188
            Width = 100
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Background'
          end
          object colorPalette17: TColorBox
            Left = 120
            Top = 214
            Width = 96
            Height = 25
            Tag = -117
            Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
            OnChange = PaletteColorChanged
          end
          object paletteDemo: TPaintBox
            Left = 16
            Top = 260
            Width = 840
            Height = 78
            OnPaint = DemoPaint
          end
        end
        object grpAppearance2: TGroupBox
          Left = 16
          Top = 876
          Width = 900
          Height = 84
          Anchors = [akLeft, akTop, akRight]
          Caption = ''
          object lblBackgroundTransparency: TLabel
            Left = 16
            Top = 29
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Przezroczystość:'
          end
          object valueBackgroundTransparency: TLabel
            Left = 718
            Top = 30
            Width = 60
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = ''
          end
          object ctlBackgroundTransparency: TTrackBar
            Left = 450
            Top = 24
            Width = 260
            Height = 40
            Tag = 76
            Hint = 'Alpha that will be applied to the terminal background.'
            ShowHint = True
            Min = 0
            Max = 100
            Frequency = 10
            PageSize = 10
            OnChange = SettingChanged
          end
        end
      end
    end
    object tabKeyboard: TTabSheet
      TabVisible = False
      ExplicitWidth = 952
      ExplicitHeight = 640
      Caption = 'Skróty klawiszowe'
      object scrollKeyboard: TScrollBox
        Width = 952
        Height = 640
        Align = alClient
        BorderStyle = bsNone
        HorzScrollBar.Visible = False
        VertScrollBar.Tracking = True
        TabOrder = 0
        object lblShortcutHelp: TLabel
          Left = 16
          Top = 12
          Width = 780
          Height = 32
          AutoSize = False
          WordWrap = True
          Caption = 'Klikając nazwę skrótu można go zmienić.' + #13#10 + 'Naciśnięcie klawisza „Backspace” wyłącza skrót.'
        end
        object gridShortcuts: TStringGrid
          Left = 16
          Top = 62
          Width = 900
          Height = 510
          Anchors = [akLeft, akTop, akRight, akBottom]
          ColCount = 2
          DefaultColWidth = 420
          DefaultRowHeight = 25
          FixedCols = 0
          RowCount = 51
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goRowSelect]
          ScrollBars = ssVertical
          OnKeyDown = ShortcutKeyDown
          OnDblClick = ShortcutDblClick
        end
      end
    end
    object tabQuickOpen: TTabSheet
      TabVisible = False
      ExplicitWidth = 952
      ExplicitHeight = 640
      Caption = 'Szybkie otwieranie'
      object scrollQuickOpen: TScrollBox
        Width = 952
        Height = 640
        Align = alClient
        BorderStyle = bsNone
        HorzScrollBar.Visible = False
        VertScrollBar.Tracking = True
        TabOrder = 0
        object grpQuickOpen0: TGroupBox
          Left = 16
          Top = 12
          Width = 900
          Height = 156
          Anchors = [akLeft, akTop, akRight]
          Caption = ''
          object ctlQuickOpenEnable: TCheckBox
            Left = 16
            Top = 24
            Width = 760
            Height = 36
            Tag = 27
            Hint = 'If this property is set as true, guake will open a text editor when the user does a Ctrl+Click on a filename printed in the terminal.'
            ShowHint = True
            Caption = 'Szybkie otwieranie po kliknięciu na nazwie pliku w terminalu przytrzymując klawisz Ctrl'
            WordWrap = True
            OnClick = SettingChanged
          end
          object lblQuickOpenCommandLine: TLabel
            Left = 16
            Top = 68
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Polecenie edytora:'
          end
          object ctlQuickOpenCommandLine: TEdit
            Left = 450
            Top = 64
            Width = 314
            Height = 25
            Tag = 28
            Hint = 'This property gives the command line to execute when doing a Quick Open. You can enter the following python string pattern in it: ''%(file_path)s'' will be replaced with the full path to the captured filename, ''%(line_number)s'' will be replaced by the line number if found (set to the empty string otherwise).'
            ShowHint = True
            OnExit = SettingChanged
          end
          object ctlQuickOpenInCurrentTerminal: TCheckBox
            Left = 16
            Top = 104
            Width = 760
            Height = 36
            Tag = 29
            Hint = 'If this property is set as true, guake will use the current terminal to execute the Quick open feature. Use if you want to inherit your terminal environment in your text editor'
            ShowHint = True
            Caption = 'Szybkie otwieranie w bieżącym terminalu'
            WordWrap = True
            OnClick = SettingChanged
          end
        end
        object lblQuickOpenHelp: TLabel
          Left = 20
          Top = 190
          Width = 860
          Height = 32
          AutoSize = False
          WordWrap = True
          Caption = 'Quick open is a feature allowing you to open a file directly into your favorite text editor by clicking on its filename when it appears in your terminal.'
        end
        object lblQuickOpenArguments: TLabel
          Left = 20
          Top = 246
          Width = 860
          Height = 32
          AutoSize = False
          WordWrap = True
          Caption = '%(file&path)s — ścieżka pliku; %(line&number)s — numer wiersza. Przykład: code -g %(file&path)s:%(line&number)s'
        end
      end
    end
    object tabHooks: TTabSheet
      TabVisible = False
      ExplicitWidth = 952
      ExplicitHeight = 640
      Caption = 'Zaczepy'
      object scrollHooks: TScrollBox
        Width = 952
        Height = 640
        Align = alClient
        BorderStyle = bsNone
        HorzScrollBar.Visible = False
        VertScrollBar.Tracking = True
        TabOrder = 0
        object grpHooks1: TGroupBox
          Left = 16
          Top = 12
          Width = 900
          Height = 116
          Anchors = [akLeft, akTop, akRight]
          Caption = ''
          object lblHookShow: TLabel
            Left = 16
            Top = 28
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Podczas wyświetlania:'
          end
          object ctlHookShow: TEdit
            Left = 450
            Top = 24
            Width = 314
            Height = 25
            Tag = 130
            Hint = 'Run this script on show.'
            ShowHint = True
            OnExit = SettingChanged
          end
          object lblStartupScript: TLabel
            Left = 16
            Top = 68
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Podczas uruchamiania:'
          end
          object ctlStartupScript: TEdit
            Left = 450
            Top = 64
            Width = 314
            Height = 25
            Tag = 30
            Hint = 'This property allows you to execute a startup bash script each time guake starts. You can configure your initial tab settings within this script. Please see the command line argument of guake (''guake --help'') for complete help.'
            ShowHint = True
            OnExit = SettingChanged
          end
        end
      end
    end
    object tabCompatibility: TTabSheet
      TabVisible = False
      ExplicitWidth = 952
      ExplicitHeight = 640
      Caption = 'Zgodność'
      object scrollCompatibility: TScrollBox
        Width = 952
        Height = 640
        Align = alClient
        BorderStyle = bsNone
        HorzScrollBar.Visible = False
        VertScrollBar.Tracking = True
        TabOrder = 0
        object grpCompatibility0: TGroupBox
          Left = 16
          Top = 12
          Width = 900
          Height = 198
          Anchors = [akLeft, akTop, akRight]
          Caption = ''
          object lblBackspaceBindingCombobox: TLabel
            Left = 16
            Top = 28
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Klawisz &Backspace generuje:'
          end
          object ctlBackspaceBindingCombobox: TComboBox
            Left = 450
            Top = 24
            Width = 314
            Height = 25
            Tag = 53
            Hint = 'Defines the behavior of backspace key.'
            ShowHint = True
            Style = csDropDownList
            OnChange = SettingChanged
            Items.Strings = (
              'ASCII DEL'
              'Sekwencja Escape'
              'Ctrl-H')
          end
          object lblDeleteBindingCombobox: TLabel
            Left = 16
            Top = 68
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = 'Klawisz &Delete generuje:'
          end
          object ctlDeleteBindingCombobox: TComboBox
            Left = 450
            Top = 64
            Width = 314
            Height = 25
            Tag = 54
            Hint = 'Defines the behavior of delete key.'
            ShowHint = True
            Style = csDropDownList
            OnChange = SettingChanged
            Items.Strings = (
              'ASCII DEL'
              'Sekwencja Escape'
              'Ctrl-H')
          end
          object lblWordCharsEntry: TLabel
            Left = 16
            Top = 108
            Width = 420
            Height = 32
            AutoSize = False
            WordWrap = True
            Caption = '&Word characters:'
          end
          object ctlWordCharsEntry: TEdit
            Left = 450
            Top = 104
            Width = 314
            Height = 25
            Tag = 55
            Hint = 'When selecting text by word, sequences of these characters are considered single words. Ranges can be given as "A-Z". Literal hyphen (not expressing a range) should be the first character given.'
            ShowHint = True
            OnExit = SettingChanged
          end
          object btnResetCompatibility: TButton
            Left = 16
            Top = 144
            Width = 520
            Height = 30
            Caption = 'P&rzywróć domyślne opcje zgodności'
            OnClick = ResetCompatibilityClick
          end
        end
      end
    end
  end
  object dlgBackground: TOpenDialog
    Filter = 'Obrazy|*.png;*.jpg;*.jpeg;*.gif;*.bmp|Wszystkie pliki|*.*'
    Left = 72
    Top = 680
  end
  object dlgCustomCommands: TOpenDialog
    Filter = 'Pliki JSON|*.json|Wszystkie pliki|*.*'
    Left = 112
    Top = 680
  end
  object dlgFont: TFontDialog
    Left = 152
    Top = 680
  end
  object appEvents: TApplicationEvents
    OnException = ApplicationException
    Left = 192
    Top = 680
  end
end
