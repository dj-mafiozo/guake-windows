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
    PopupMenu = tabMenu
    TabOrder = 1
    object btnTabList: TSpeedButton
      Align = alRight
      Width = 28
      Caption = '▾'
      Flat = True
      Enabled = False
      OnClick = TabListClick
    end
    object btnAddTab: TSpeedButton
      PopupMenu = shellMenu
      Align = alRight
      Width = 28
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000000000C40E0000C40E00000000000000000000EBEBEBE3E4E4
        E3E5E4E6E9E7E6E8E7E6E8E7E7E9E8E6E8E7E6E8E6E7E9E7E3E9E8D9E8E8D0EA
        E9CCEAE9D0EAE9DBEAE9EAEAEADDDFDFDFE1E0E2E5E3E2E5E4E2E5E4E1E4E3E0
        E4E2E0E6E4D0E6E4C0E8E7B0E9E8A2EAE99CEAEAA1EBEAACEAEAE8E8E8D9DBDA
        D9DCDBDEE2E0DEE2E0DEE2E0DDE1DFD9E2E0CDE3E1B0E7E58FE7E875E8EB6CEA
        EB69ECEC67EAEC6DE9EDE5E5E5D3D5D4D4D8D6DADFDDDADFDDDADFDDD8DFDCCA
        E1DEA8E3E28FE8E758E4E92EE1EC37E9EF3CF0F12EE8EF2FE3EDE3E4E4D0D1D1
        D0D4D2D7DDDAD7DCDAD7DCD9CADEDBB2E1DE90E7E546DFE973E8F19DF0F74CE5
        F31FDEEF61E8F397EFF6E3E3E3CCCECECDD2D0D6DCD9D5DBD7D2DBD8BEDDDB9F
        E2DF7DE9E726DBEB7EEAF4E1FAFCA8F1F989EBF6B8F3F9C4F4FAE2E2E2CACCCC
        CBD0CDD3DAD6D2D8D4CDD9D7B3DCDA8FE1E067E7E724DCEC86ECF5FFFFFEFFFF
        FFFFFFFFFFFFFFD5F8FCE1E1E1C8CAC9C9CECBD2DAD6D1D8D4C8D8D5AEDDDA83
        E1E14EE3E934E4EE95F1F7FFFEFEFFFFFFFFFFFFFFFFFFE8FBFDE0E1E1C7CAC9
        C8CECBD0D8D4D0D6D2C7D8D4AEDDDA80E0E13BDEE88CEDF4D3F8FBFFFFFFFFFF
        FFFFFFFFFFFFFFF9FEFEE0E1E1C7CAC9C8CDCBD1D8D5D1D7D3C9D8D4B1DCD983
        DFE13BDEEB9EEEF6CFF7FBE7FBFDFFFFFFFFFFFFFAFEFEEFFCFDE0E0E0C8CAC9
        C8CDCBD2D8D5CFD6D3CAD7D4B6D9D68FDCDE52DFEA83E9F197EEF6AFF3F9EBFC
        FDF9FDFEDDF9FCB2F4FADFDFDFC8CBCACCD0CED4DBD7CCD4D0CAD5D1BED7D4A7
        DBD983E0E053E0E537E2EB4CE7F2AEF1F9EBFCFE91EEF827E2F1E8E8E8C2C5C3
        CCD0CEE2E5E4E1E4E3E1E4E3D9E5E4C9E6E6AEE8E98CE9EB70E9EC59E6EC44DE
        EA43DEEF46E2ED4DE5E8EEEEEED6D7D6CBCDCCC9CCCBCACDCCCACDCCC7CDCCC0
        CECDB1D1D19DD5D589D9D976DEE15DE3EA55E4EE66E9EE7DECECF0F0F0ECECEC
        D4D5D5BDBFBEBCBFBDBCBFBDBCBFBDBCC0BFB8C5C4B0CACAA5D1D1A2DDDDAAEF
        EFADF3F2ABF1F2AFF1F3F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0
        F0F0F0F0F0EEF0F0E7F1F1DEF1F1D8F0F1D6F0F1D8F0F0DDF0F0}
      Flat = True
      Enabled = False
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
      Style = tsFlatButtons
      TabPosition = tpTop
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
    object miTrayToggle: TMenuItem
      Caption = 'Wyświetl'
      OnClick = TrayDblClick
    end
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
      OnClick = SaveTabsClick
    end
    object miRestoreTabs: TMenuItem
      Caption = 'Przywróć karty'
      Enabled = False
      OnClick = RestoreTabsClick
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
      OnClick = LinkActionClick
    end
    object miSearchWeb: TMenuItem
      Caption = 'Znajdź w Internecie'
      Enabled = False
      OnClick = LinkActionClick
    end
    object miQuickOpen: TMenuItem
      Caption = 'Szybko otwórz...'
      Enabled = False
      OnClick = QuickOpenClick
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
    object miCustomCommands: TMenuItem
      Caption = 'Polecenia użytkownika'
      Visible = False
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
    object miNewShellTab: TMenuItem
      Caption = 'Nowa karta z powłoką'
      object miNewZsh: TMenuItem
        Caption = 'Zsh'
        OnClick = ShellTabClick
      end
      object miNewBash: TMenuItem
        Tag = 1
        Caption = 'Bash'
        OnClick = ShellTabClick
      end
      object miNewCmd: TMenuItem
        Tag = 2
        Caption = 'CMD'
        OnClick = ShellTabClick
      end
      object miNewPowerShell: TMenuItem
        Tag = 3
        Caption = 'PowerShell'
        OnClick = ShellTabClick
      end
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
  object shellMenu: TPopupMenu
    object miPopupZsh: TMenuItem
      Caption = 'Zsh'
      OnClick = ShellTabClick
    end
    object miPopupBash: TMenuItem
      Tag = 1
      Caption = 'Bash'
      OnClick = ShellTabClick
    end
    object miPopupCmd: TMenuItem
      Tag = 2
      Caption = 'CMD'
      OnClick = ShellTabClick
    end
    object miPopupPowerShell: TMenuItem
      Tag = 3
      Caption = 'PowerShell'
      OnClick = ShellTabClick
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
  object animationTimer: TTimer
    Enabled = False
    Interval = 15
    OnTimer = AnimationTick
  end
  object sessionTimer: TTimer
    Enabled = False
    Interval = 1000
    OnTimer = SessionSaveTick
  end
  object notificationTimer: TTimer
    Enabled = False
    Interval = 8000
    OnTimer = NotificationExpired
  end
end
