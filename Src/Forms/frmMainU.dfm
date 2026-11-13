object frmMain: TfrmMain
  Caption = 'Guake!'
  ClientWidth = 1000
  ClientHeight = 540
  BorderStyle = bsNone
  Color = clBlack
  Font.Name = 'Segoe UI'
  Font.Height = -12
  OnShow = FormShow
  OnDeactivate = FormDeactivate
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 15
  object terminalHost: TPanel
    Align = alClient
    BevelOuter = bvNone
    Color = clBlack
    ParentBackground = False
    PopupMenu = terminalMenu
    TabOrder = 0
  end
  object tabBar: TTabControl
    Align = alBottom
    Height = 32
    TabOrder = 1
    TabPosition = tpBottom
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
      Caption = 'Zako?cz'
      OnClick = QuitClick
    end
  end
  object terminalMenu: TPopupMenu
    Left = 136
    Top = 40
    object miNewTab: TMenuItem
      Tag = 0
      Caption = 'Nowa karta'
      Enabled = False
      OnClick = CommandClick
    end
    object miCloseTab: TMenuItem
      Tag = 1
      Caption = 'Zamknij kart?'
      Enabled = False
      OnClick = CommandClick
    end
    object miSplitHorizontal: TMenuItem
      Tag = 2
      Caption = 'Podziel w poziomie'
      Enabled = False
      OnClick = CommandClick
    end
    object miSplitVertical: TMenuItem
      Tag = 3
      Caption = 'Podziel w pionie'
      Enabled = False
      OnClick = CommandClick
    end
    object miCopy: TMenuItem
      Tag = 4
      Caption = 'Kopiuj'
      Enabled = False
      OnClick = CommandClick
    end
    object miPaste: TMenuItem
      Tag = 5
      Caption = 'Wklej'
      Enabled = False
      OnClick = CommandClick
    end
    object miSearch: TMenuItem
      Tag = 6
      Caption = 'Szukaj'
      Enabled = False
      OnClick = CommandClick
    end
  end
end
