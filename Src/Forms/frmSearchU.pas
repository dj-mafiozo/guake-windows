{$StackFrames On}
/// <summary>Finds literal or regular-expression matches in terminal text with direction and wrapping.</summary>
Unit frmSearchU;

Interface

 Uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Forms, Vcl.Controls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs, Vcl.Menus, Vcl.Graphics,
  Guake.Localization, System.RegularExpressions, System.RegularExpressionsCore;

 Type
  TfrmSearch = Class(TForm)
    edtSearch    : TEdit;
    cmbMode      : TComboBox;
    btnPrevious  : TButton;
    btnNext      : TButton;
    chkForward   : TCheckBox;
    chkMatchCase : TCheckBox;
    lblDirection : TLabel;
    btnClose     : TButton;
    Procedure SearchChanged   (Sender : TObject);
    Procedure SearchKeyDown   (Sender : TObject; Var Key : Word; Shift : TShiftState);
    Procedure PreviousClick   (Sender : TObject);
    Procedure NextClick       (Sender : TObject);
    Procedure DirectionChanged(Sender : TObject);
    Procedure CloseClick      (Sender : TObject);
   Private
    fContent     : String;
    fPosition    : Integer;
    fMatchStart  : Integer;
    fMatchLength : Integer;
    fOnMatch     : TNotifyEvent;
    fLocalizer   : TGuakeLocalization;
    Procedure Find(Forward : Boolean);
   Public
    Procedure SetContent(Const Value : String);
    Procedure Localize  (Localizer : TGuakeLocalization);
    Property MatchStart  : Integer Read fMatchStart;
    Property MatchLength : Integer Read fMatchLength;
    Property OnMatch     : TNotifyEvent Read fOnMatch Write fOnMatch;
  End;

Implementation
{$R *.dfm}

 Procedure TfrmSearch.SetContent(Const Value : String);
  Begin
   fContent     := Value;
   fPosition    := Length(Value) + 1;
   fMatchStart  := 0;
   fMatchLength := 0;
  End;

 Procedure TfrmSearch.Find(Forward : Boolean);
  Var
   Pattern : String;
   Matches : TMatchCollection;
   m       : TMatch;
   Options : TRegExOptions;
   Index   : Integer;
   Chosen  : Integer;
  Begin
   fMatchStart  := 0;
   fMatchLength := 0;
   If edtSearch.Text = '' Then
    Exit;
   Pattern := edtSearch.Text;
   If cmbMode.ItemIndex = 0 Then
    Pattern := TRegEx.Escape(Pattern);
   Options  := [roMultiLine];
   If Not chkMatchCase.Checked Then
    Include(Options, roIgnoreCase);
   Try
    Matches := TRegEx.Matches(fContent, Pattern, Options);
    If Matches.Count > 0 Then
     Begin
      If Forward Then
       Begin
        Chosen    := 0;
        For Index := 0 To Matches.Count - 1 Do
         If Matches.Item[Index].Index > fPosition Then
          Begin
           Chosen := Index;
           Break;
          End;
       End
      Else
       Begin
        Chosen    := Matches.Count - 1;
        For Index := Matches.Count - 1 Downto 0 Do
         If Matches.Item[Index].Index < fPosition Then
          Begin
           Chosen := Index;
           Break;
          End;
       End;
      m            := Matches.Item[Chosen];
      fPosition    := m.Index;
      fMatchStart  := m.Index;
      fMatchLength := m.Length;
     End;
    If fMatchStart = 0 Then
     lblDirection.Caption := 'Nie znaleziono'
    Else
     DirectionChanged(Nil);
    If Assigned(fOnMatch) Then
     fOnMatch(Self);
   Except
    On E : ERegularExpressionError Do
     Begin
      lblDirection.Caption := E.Message;
     End;
   End;
  End;

 Procedure TfrmSearch.SearchChanged(Sender : TObject);
  Begin
   If chkForward.Checked Then
    fPosition := 0
   Else
    fPosition := Length(fContent) + 1;
   Find(chkForward.Checked);
  End;

 Procedure TfrmSearch.SearchKeyDown(Sender : TObject; Var Key : Word; Shift : TShiftState);
  Begin
   If Key = VK_ESCAPE Then
    Begin
     Hide;
     Key := 0;
    End
   Else If Key = VK_RETURN Then
    Begin
     Find(chkForward.Checked Xor (ssShift In Shift));
     Key := 0;
    End;
  End;

 Procedure TfrmSearch.PreviousClick(Sender : TObject);
  Begin
   Find(False);
  End;

 Procedure TfrmSearch.NextClick(Sender : TObject);
  Begin
   Find(True);
  End;

 Procedure TfrmSearch.DirectionChanged(Sender : TObject);
  Begin
   If chkForward.Checked Then
    lblDirection.Caption := 'Current search direction: Forward'
   Else
    lblDirection.Caption := 'Current search direction: Backward';
   If fLocalizer <> Nil Then
    lblDirection.Caption := fLocalizer.Text(lblDirection.Caption);
  End;

 Procedure TfrmSearch.CloseClick(Sender : TObject);
  Begin
   Hide;
  End;

 Procedure TfrmSearch.Localize(Localizer : TGuakeLocalization);
  Begin
   fLocalizer := Localizer;
   If Localizer <> Nil Then
    Begin
     btnClose.Caption     := Localizer.Text('Close');
     chkForward.Caption   := Localizer.Text('Search forward');
     chkMatchCase.Caption := Localizer.Text('Match case');
    End;
   DirectionChanged(Nil);
  End;

End.
