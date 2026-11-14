{$StackFrames On}
/// <summary>Displays the native Windows port version, original artwork, contributor credits and license.</summary>
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
    btnWebsite     : TLabel;
    memoCredits    : TMemo;
    memoLicense    : TMemo;
    lblCopyright   : TLabel;
    btnCredits     : TButton;
    btnLicense     : TButton;
    btnClose       : TButton;
    pnlDetails     : TPanel;
    animationTimer : TTimer;
    Procedure AnimationTick(Sender : TObject);
    Procedure CreditsClick (Sender : TObject);
    Procedure LicenseClick (Sender : TObject);
    Procedure WebsiteClick (Sender : TObject);
   Private
    fDetailMode     : Integer;
    fAnimationStart : UInt64;
    fAnimationFrom  : Integer;
    fAnimationTo    : Integer;
    fDetailsBottom  : Integer;
    Procedure SelectDetails(Mode : Integer);
   Public
    Procedure LoadVersion;
    Procedure Localize(Localizer : TGuakeLocalization);
  End;

Implementation
{$R *.dfm}

/// <summary>Switches between the compact summary, original contributors and GPL notice.</summary>

 Procedure TfrmAbout.SelectDetails(Mode : Integer);
  Begin
   animationTimer.Enabled := False;
   fDetailsBottom         := btnClose.Top - MulDiv(16, PixelsPerInch, 96);
   If (Mode <> 0) And (Mode <> fDetailMode) Then
    pnlDetails.SetBounds(pnlDetails.Left, fDetailsBottom, pnlDetails.Width, 0);
   fDetailMode := Mode;
   If Mode <> 0 Then
    Begin
     memoCredits.Visible := Mode = 1;
     memoLicense.Visible := Mode = 2;
    End;
   If Mode <> 0 Then
    Begin
     lblVersion.Visible     := False;
     lblDescription.Visible := False;
     btnWebsite.Visible     := False;
     lblCopyright.Visible   := False;
    End;
   fAnimationFrom := pnlDetails.Height;
   If Mode = 0 Then
    fAnimationTo := 0
   Else
    fAnimationTo      := MulDiv(208, PixelsPerInch, 96);
   pnlDetails.Visible := True;
   pnlDetails.BringToFront;
   fAnimationStart        := GetTickCount64;
   animationTimer.Enabled := True;
  End;

/// <summary>Reveals the DFM-owned credits or license panel upwards from its bottom edge.</summary>

 Procedure TfrmAbout.AnimationTick(Sender : TObject);
  Var
   Progress : Double;
   Height   : Integer;
  Begin
   Progress := (GetTickCount64 - fAnimationStart) / 180;
   If Progress > 1 Then
    Progress := 1;
   Height    := fAnimationFrom + Round((fAnimationTo - fAnimationFrom) * Progress);
   pnlDetails.SetBounds(pnlDetails.Left, fDetailsBottom - Height, pnlDetails.Width, Height);
   If Progress >= 1 Then
    Begin
     animationTimer.Enabled := False;
     If fDetailMode = 0 Then
      Begin
       pnlDetails.Visible     := False;
       memoCredits.Visible    := False;
       memoLicense.Visible    := False;
       lblVersion.Visible     := True;
       lblDescription.Visible := True;
       btnWebsite.Visible     := True;
       lblCopyright.Visible   := True;
      End;
    End;
  End;

 Procedure TfrmAbout.CreditsClick(Sender : TObject);
  Begin
   If fDetailMode = 1 Then
    SelectDetails(0)
   Else
    SelectDetails(1);
  End;

 Procedure TfrmAbout.LicenseClick(Sender : TObject);
  Begin
   If fDetailMode = 2 Then
    SelectDetails(0)
   Else
    SelectDetails(2);
  End;

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
     lblProduct.Caption     := 'Guake';
     lblDescription.Caption := Localizer.Text('Guake is an easy to access' + #10 + 'terminal based on FPS games terminal');
     btnClose.Caption       := Localizer.Text('Close');
     btnCredits.Caption     := Localizer.Text('Credits');
     btnLicense.Caption     := Localizer.Text('License');
    End;
  End;

End.
