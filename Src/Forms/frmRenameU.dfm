object frmRename: TfrmRename
  Caption = 'Zmiana nazwy karty'
  ClientWidth = 440
  ClientHeight = 118
  Font.Name = 'Segoe UI'
  Font.Height = -12
  Position = poOwnerFormCenter
  BorderStyle = bsDialog
  PixelsPerInch = 96
  TextHeight = 15
  object edtName: TEdit
    Left = 16
    Top = 16
    Width = 408
    Height = 25
  end
  object btnCancel: TButton
    Left = 212
    Top = 72
    Width = 100
    Height = 28
    Caption = 'Anuluj'
    Cancel = True
    ModalResult = 2
  end
  object btnOK: TButton
    Left = 324
    Top = 72
    Width = 100
    Height = 28
    Caption = 'OK'
    Default = True
    ModalResult = 1
  end
end
