object frmSearch: TfrmSearch
  Caption = 'Wyszukiwanie w terminalu'
  ClientWidth = 680
  ClientHeight = 230
  Font.Name = 'Segoe UI'
  Font.Height = -12
  Position = poOwnerFormCenter
  BorderStyle = bsDialog
  PixelsPerInch = 96
  TextHeight = 15
  object edtSearch: TEdit
    Left = 16
    Top = 20
    Width = 380
    Height = 25
    OnChange = SearchChanged
    OnKeyDown = SearchKeyDown
  end
  object cmbMode: TComboBox
    Left = 406
    Top = 20
    Width = 120
    Height = 25
    Style = csDropDownList
    ItemIndex = 0
    Items.Strings = (
      'Tekst'
      'Regex'
    )
    OnChange = SearchChanged
  end
  object btnPrevious: TButton
    Left = 536
    Top = 18
    Width = 62
    Height = 28
    Caption = '←'
    OnClick = PreviousClick
  end
  object btnNext: TButton
    Left = 604
    Top = 18
    Width = 60
    Height = 28
    Caption = '→'
    OnClick = NextClick
  end
  object chkForward: TCheckBox
    Left = 16
    Top = 64
    Width = 260
    Height = 24
    Caption = 'Szukaj do przodu'
    OnClick = DirectionChanged
  end
  object chkMatchCase: TCheckBox
    Left = 16
    Top = 96
    Width = 300
    Height = 24
    Caption = 'Rozróżnianie wielkości liter'
    OnClick = SearchChanged
  end
  object lblDirection: TLabel
    Left = 16
    Top = 136
    Width = 640
    Height = 24
    Caption = 'Aktualny kierunek wyszukiwania: wstecz'
  end
  object btnClose: TButton
    Left = 564
    Top = 184
    Width = 100
    Height = 28
    Caption = 'Zamknij'
    Cancel = True
    OnClick = CloseClick
  end
end
