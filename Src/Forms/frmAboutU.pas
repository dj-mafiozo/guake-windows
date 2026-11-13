{$StackFrames On}
Unit frmAboutU;

Interface

 Uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Forms, Vcl.Controls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs, Vcl.Menus, Vcl.Graphics, Vcl.Imaging.pngimage,
  Guake.Localization, VersionU, Winapi.ShellAPI;

 Type
  TfrmAbout = Class(TForm)
    imgLogo        : TImage;
    lblProduct     : TLabel;
    lblVersion     : TLabel;
    lblDescription : TLabel;
    btnWebsite     : TButton;
    memoCredits    : TMemo;
    btnClose       : TButton;
    Procedure WebsiteClick(Sender : TObject);
   Public
    Procedure LoadVersion;
    Procedure Localize(Localizer : TGuakeLocalization);
  End;

Implementation
{$R *.dfm}

 Procedure TfrmAbout.LoadVersion;
  Begin
   lblVersion.Caption := ExeVersionInfo.FileVersion;
  End;

 Procedure TfrmAbout.WebsiteClick(Sender : TObject);
  Begin
   ShellExecute(Handle, 'open', 'https://guake.github.io', Nil, Nil, SW_SHOWNORMAL);
  End;

 Procedure TfrmAbout.Localize(Localizer : TGuakeLocalization);
  Begin
   LoadVersion;
   If Localizer <> Nil Then
    Begin
     Caption                := Localizer.Text('About Guake');
     lblProduct.Caption     := Localizer.Text('Guake Terminal');
     lblDescription.Caption := Localizer.Text('Guake is an easy to access' + #10 + 'terminal based on FPS games terminal');
     btnClose.Caption       := Localizer.Text('Close');
    End;
  End;

End.
