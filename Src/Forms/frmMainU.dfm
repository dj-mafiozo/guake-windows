object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Guake!'
  ClientHeight = 540
  ClientWidth = 1000
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnClose = FormClose
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object terminalHost: TPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 508
    Align = alClient
    BevelOuter = bvNone
    Color = clBlack
    ParentBackground = False
    PopupMenu = terminalMenu
    TabOrder = 0
  end
  object tabHost: TPanel
    Left = 0
    Top = 508
    Width = 1000
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    Color = clBtnFace
    ParentBackground = False
    DoubleBuffered = True
    TabOrder = 1
    object btnTabList: TButton
      Align = alRight
      Width = 28
      Caption = '▾'
      Enabled = False
      TabOrder = 2
      OnClick = TabListClick
    end
    object btnAddTab: TButton
      Align = alRight
      Width = 28
      Caption = '+'
      Enabled = False
      TabOrder = 1
      OnClick = AddTabClick
    end
    object tabBar: TTabControl
      Left = 0
      Top = 0
      Width = 1000
      Height = 32
      Align = alClient
      DoubleBuffered = True
      TabOrder = 0
      TabPosition = tpBottom
      PopupMenu = tabMenu
      OnChange = TabChanged
    end
  end
  object trayIcon: TTrayIcon
    Hint = 'Guake Terminal'
    PopupMenu = trayMenu
    OnDblClick = TrayDblClick
    Left = 40
    Top = 40
  end
  object trayMenu: TPopupMenu
    Left = 88
    Top = 40
    object miTrayNewTab: TMenuItem
      Caption = 'Nowa karta'
      Enabled = False
      OnClick = AddTabClick
    end
    object miTraySeparator1: TMenuItem
      Caption = '-'
    end
    object miSaveTabs: TMenuItem
      Caption = 'Zapisz karty'
      Enabled = False
    end
    object miRestoreTabs: TMenuItem
      Caption = 'Przywróć karty'
      Enabled = False
    end
    object miTraySeparator2: TMenuItem
      Caption = '-'
    end
    object miPreferences: TMenuItem
      Caption = 'Preferencje'
      OnClick = PreferencesClick
    end
    object miAbout: TMenuItem
      Caption = 'O programie'
      OnClick = AboutClick
    end
    object miSeparator: TMenuItem
      Caption = '-'
    end
    object miQuit: TMenuItem
      Caption = 'Zakończ'
      OnClick = QuitClick
    end
  end
  object terminalMenu: TPopupMenu
    OnPopup = TerminalMenuPopup
    object miCopy: TMenuItem
      Tag = 4
      Caption = 'Skopiuj'
      Enabled = False
      OnClick = CommandClick
    end
    object miPaste: TMenuItem
      Tag = 5
      Caption = 'Wklej'
      Enabled = False
      OnClick = CommandClick
    end
    object miTerminalSeparator1: TMenuItem
      Caption = '-'
    end
    object miFullscreen: TMenuItem
      Caption = 'Przełącz pełny ekran'
      OnClick = TerminalActionClick
    end
    object miTerminalSeparator2: TMenuItem
      Caption = '-'
    end
    object miSplitHorizontal: TMenuItem
      Tag = 2
      Caption = 'Podziel —'
      Enabled = False
      OnClick = CommandClick
    end
    object miSplitVertical: TMenuItem
      Tag = 3
      Caption = 'Podziel |'
      Enabled = False
      OnClick = CommandClick
    end
    object miCloseTerminal: TMenuItem
      Tag = 1
      Caption = 'Zamknij terminal'
      OnClick = TerminalActionClick
    end
    object miTerminalSeparator3: TMenuItem
      Caption = '-'
    end
    object miSaveTerminal: TMenuItem
      Tag = 4
      Caption = 'Zapisz zawartość...'
      OnClick = TerminalActionClick
    end
    object miResetTerminal: TMenuItem
      Tag = 2
      Caption = 'Przywróć terminal'
      OnClick = TerminalActionClick
    end
    object miTerminalSeparator4: TMenuItem
      Caption = '-'
    end
    object miOpenLink: TMenuItem
      Caption = 'Otwórz odnośnik...'
      Enabled = False
    end
    object miSearchWeb: TMenuItem
      Caption = 'Znajdź w Internecie'
      Enabled = False
    end
    object miQuickOpen: TMenuItem
      Caption = 'Szybko otwórz...'
      Enabled = False
    end
    object miSearch: TMenuItem
      Tag = 6
      Caption = 'Szukaj'
      Visible = False
      Enabled = False
      OnClick = CommandClick
    end
    object miTerminalSeparator5: TMenuItem
      Caption = '-'
    end
    object miTerminalPreferences: TMenuItem
      Caption = 'Preferencje'
      OnClick = PreferencesClick
    end
    object miTerminalAbout: TMenuItem
      Caption = 'O programie'
      OnClick = AboutClick
    end
    object miTerminalSeparator6: TMenuItem
      Caption = '-'
    end
    object miTerminalQuit: TMenuItem
      Caption = 'Zakończ'
      OnClick = QuitClick
    end
  end
  object tabMenu: TPopupMenu
    OnPopup = TabMenuPopup
    object miNewTab: TMenuItem
      Caption = 'Nowa karta'
      Enabled = False
      OnClick = CommandClick
    end
    object miRenameTab: TMenuItem
      Tag = 3
      Caption = 'Zmień nazwę'
      OnClick = TerminalActionClick
    end
    object miRestoreTabColors: TMenuItem
      Caption = 'Przywróć niestandardowe kolory'
      Enabled = False
    end
    object miCloseTab: TMenuItem
      Tag = 1
      Caption = 'Zamknij'
      Enabled = False
      OnClick = CommandClick
    end
  end
  object tabListMenu: TPopupMenu
    OnPopup = TabListPopup
  end
  object pollTimer: TTimer
    Enabled = False
    Interval = 30
    OnTimer = PollTerminal
    Left = 184
    Top = 40
  end
end
