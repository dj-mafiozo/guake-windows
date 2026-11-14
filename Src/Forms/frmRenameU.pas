{$StackFrames On}
/// <summary>Edits a tab name in a DFM-defined modal dialog without changing it on cancellation.</summary>
Unit frmRenameU;

Interface

 Uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Forms, Vcl.Controls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs, Vcl.Menus, Vcl.Graphics,
  Guake.Localization;

 Type
  TfrmRename = Class(TForm)
    edtName   : TEdit;
    btnCancel : TButton;
    btnOK     : TButton;
   Public
    Class Function Execute(Owner : TComponent; Var Name : String; Localizer : TGuakeLocalization = Nil) : Boolean; Static;
  End;

Implementation
{$R *.dfm}

  Class Function TfrmRename.Execute(Owner : TComponent; Var Name : String; Localizer : TGuakeLocalization) : Boolean;

 Var
  Dialog : TfrmRename;

Begin
 Dialog := TfrmRename.Create(Owner);
 Try
  Dialog.edtName.Text := Name;
  Dialog.edtName.SelectAll;
  If Localizer <> Nil Then
   Begin
    Dialog.Caption           := Localizer.Text('Rename tab');
    Dialog.btnCancel.Caption := Localizer.Text('Cancel');
   End;
  Result := Dialog.ShowModal = mrOk;
  If Result Then
   Name := Dialog.edtName.Text;
 Finally
  Dialog.Free;
 End;
End;

End.
