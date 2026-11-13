{$StackFrames On}
Unit frmConfirmU;

Interface

 Uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Forms, Vcl.Controls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs, Vcl.Menus, Vcl.Graphics,
  Guake.Localization;

 Type
  TfrmConfirm = Class(TForm)
    lblQuestion   : TLabel;
    memoProcesses : TMemo;
    btnNo         : TButton;
    btnYes        : TButton;
   Public
    Procedure ConfigureQuit       (Processes : TStrings; Tabs, Workspaces : Integer; Localizer : TGuakeLocalization = Nil);
    Procedure ConfigureResetColors(Localizer : TGuakeLocalization = Nil);
  End;

Implementation
{$R *.dfm}

 Procedure TfrmConfirm.ConfigureQuit(Processes : TStrings; Tabs, Workspaces : Integer; Localizer : TGuakeLocalization);
  Var
   s : String;

   Function Tr(Const Value : String) : String;
    Begin
     If Localizer <> Nil Then
      Result := Localizer.Text(Value)
     Else
      Result := Value;
    End;

  Begin
   If Tabs = -1 Then
    lblQuestion.Caption := Tr('Do you want to close the tab?')
   Else
    lblQuestion.Caption := Tr('Do you really want to quit Guake?');
   memoProcesses.Clear;
   If (Processes = Nil) Or (Processes.Count = 0) Then
    s := Tr('There are no processes running')
   Else If Processes.Count = 1 Then
    s := Tr('There is a process still running')
   Else
    s := StringReplace(Tr('There are {0} processes still running'), '{0}', IntToStr(Processes.Count), [rfReplaceAll]);
   If Tabs = 1 Then
    s := s + Tr(' and one tab open')
   Else If Tabs > 1 Then
    s := s + StringReplace(Tr(' and {0} tabs open'), '{0}', IntToStr(Tabs), [rfReplaceAll]);
   If Workspaces > 1 Then
    s := s + StringReplace(Tr(' on {0} workspaces'), '{0}', IntToStr(Workspaces), [rfReplaceAll]);
   memoProcesses.Lines.Add(s + '.');
   If (Processes <> Nil) And (Processes.Count > 0) Then
    Begin
     memoProcesses.Lines.Add('');
     memoProcesses.Lines.AddStrings(Processes);
    End;
   btnNo.Caption  := Tr('No');
   btnYes.Caption := Tr('Yes');
  End;

 Procedure TfrmConfirm.ConfigureResetColors(Localizer : TGuakeLocalization);
  Begin
   memoProcesses.Clear;
   If Localizer <> Nil Then
    lblQuestion.Caption := Localizer.Text('Do you want to reset custom colors for this tab?')
   Else
    lblQuestion.Caption := 'Przywrócić domyślne kolory tej karty?';
  End;

End.
