object dmDialogs: TdmDialogs
  Height = 150
  Width = 215
  object dlgSaveTerminal: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Tekst i logi|*.txt;*.log|Wszystkie pliki|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Zapisz zawartość terminala'
    Left = 40
    Top = 32
  end
end
