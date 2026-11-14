object frmConfirm: TfrmConfirm
  Caption = 'Guake'
  ClientWidth = 540
  ClientHeight = 224
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
    Height = 36
    AutoSize = False
    WordWrap = True
    Alignment = taCenter
    Caption = 'Na pewno zakończyć program Guake?'
  end
  object memoProcesses: TMemo
    Left = 20
    Top = 64
    Width = 500
    Height = 104
    BorderStyle = bsNone
    Color = clBtnFace
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabStop = False
  end
  object btnNo: TButton
    Left = 20
    Top = 180
    Width = 244
    Height = 28
    Caption = 'Nie'
    Cancel = True
    Default = True
    ModalResult = 7
  end
  object btnYes: TButton
    Left = 276
    Top = 180
    Width = 244
    Height = 28
    Caption = 'Tak'
    ModalResult = 6
  end
end
