{$StackFrames On}
/// <summary>DFM-owned native file dialogs and UTF-8 terminal-content export.</summary>
Unit dmDialogsU;

Interface

 Uses
  System.SysUtils, System.Classes, Vcl.Dialogs;

 Type
  TdmDialogs = Class(TDataModule)
    dlgSaveTerminal : TSaveDialog;
   Public
    Function  SaveTerminal(Const Content : String; OwnerHandle : THandle) : Boolean;
    Procedure SaveText    (Const FileName, Content : String);
  End;

Implementation

 Uses
  System.IOUtils;
{$R *.dfm}

 Procedure TdmDialogs.SaveText(Const FileName, Content : String);
  Begin
   TFile.WriteAllText(FileName, Trim(Content), TEncoding.UTF8);
  End;

 Function TdmDialogs.SaveTerminal(Const Content : String; OwnerHandle : THandle) : Boolean;
  Begin
   Result := False;
   If Trim(Content) = '' Then
    Exit;
   If dlgSaveTerminal.Execute(OwnerHandle) Then
    Begin
     SaveText(dlgSaveTerminal.FileName, Content);
     Result := True;
    End;
  End;

End.
