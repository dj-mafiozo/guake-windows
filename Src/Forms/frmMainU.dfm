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
  object tabBar: TTabControl
    Left = 0
    Top = 508
    Width = 1000
    Height = 32
    Align = alBottom
    TabOrder = 1
    TabPosition = tpBottom
    OnChange = TabChanged
    OnMouseDown = TabMouseDown
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
      Caption = 'Zakończ'
      OnClick = QuitClick
    end
  end
  object terminalMenu: TPopupMenu
    Left = 136
    Top = 40
    object miNewTab: TMenuItem
      Caption = 'Nowa karta'
      Enabled = False
      OnClick = CommandClick
    end
    object miCloseTab: TMenuItem
      Tag = 1
      Caption = 'Zamknij kartę'
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
  object pollTimer: TTimer
    Enabled = False
    Interval = 30
    OnTimer = PollTerminal
    Left = 184
    Top = 40
  end
end
