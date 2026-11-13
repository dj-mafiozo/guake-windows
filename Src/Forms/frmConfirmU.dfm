object frmConfirm: TfrmConfirm
  Caption = 'Guake'
  ClientWidth = 540
  ClientHeight = 360
  Font.Name = 'Segoe UI'
  Font.Height = -12
  Position = poOwnerFormCenter
  BorderStyle = bsDialog
  PixelsPerInch = 96
  TextHeight = 15
  object lblQuestion: TLabel
    Left = 20
    Top = 20
    Width = 500
    Height = 60
    AutoSize = False
    WordWrap = True
    Font.Style = [fsBold]
    Caption = 'Na pewno zakończyć program Guake?'
  end
  object memoProcesses: TMemo
    Left = 20
    Top = 90
    Width = 500
    Height = 200
    ReadOnly = True
    ScrollBars = ssVertical
    TabStop = False
  end
  object btnNo: TButton
    Left = 304
    Top = 312
    Width = 100
    Height = 28
    Caption = 'Nie'
    Cancel = True
    Default = True
    ModalResult = 7
  end
  object btnYes: TButton
    Left = 420
    Top = 312
    Width = 100
    Height = 28
    Caption = 'Tak'
    ModalResult = 6
  end
end
