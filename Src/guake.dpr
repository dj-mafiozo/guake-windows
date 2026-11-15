{$StackFrames On}
/// <summary>Starts and shuts down the native Windows Guake application and its shared services.</summary>
Program Guake;
{$R *.res}

Uses
 StackTrace         In 'Vendor\stacktrace\source\StackTrace.pas',
 Guake.Links        In 'Terminal\Guake.Links.pas',
 Guake.Resources    In 'Resources\Guake.Resources.pas',
 Guake.ConPTY       In 'Terminal\Guake.ConPTY.pas',
 Guake.VT           In 'Terminal\Guake.VT.pas',
 Guake.Sessions     In 'Terminal\Guake.Sessions.pas',
 Guake.Keybindings  In 'Terminal\Guake.Keybindings.pas',
 fraTerminalU       In 'Frames\fraTerminalU.pas',
 fraSplitU          In 'Frames\fraSplitU.pas',
 System.SysUtils, System.IOUtils, Vcl.Forms,
 VersionU           In 'Common\VersionU.pas',
 Guake.Settings     In 'Settings\Guake.Settings.pas',
 Guake.Localization In 'Localization\Guake.Localization.pas',
 Guake.Logging      In 'Diagnostics\Guake.Logging.pas',
 Guake.Shells       In 'Terminal\Guake.Shells.pas',
 Guake.Palettes     In 'Appearance\Guake.Palettes.pas',
 frmMainU           In 'Forms\frmMainU.pas',
 frmPreferencesU    In 'Forms\frmPreferencesU.pas',
 frmAboutU          In 'Forms\frmAboutU.pas',
 frmSearchU         In 'Forms\frmSearchU.pas',
 frmRenameU         In 'Forms\frmRenameU.pas',
 frmConfirmU        In 'Forms\frmConfirmU.pas',
 dmDialogsU         In 'DataModules\dmDialogsU.pas';

Var
 MainForm  : TfrmMain;
 Settings  : TGuakeSettings;
 Localizer : TGuakeLocalization;
 Log       : TGuakeLog;
 Catalog   : String;

Begin
 Application.Initialize;
 Application.MainFormOnTaskBar := False;
 Settings                      := TGuakeSettings.Create(TGuakeSettings.DefaultFileName);
 Localizer                     := TGuakeLocalization.Create;
 Log                           := TGuakeLog.Create(ChangeFileExt(Settings.FileName, '.log'));
 Try
  Try
   Catalog := TPath.Combine(ExtractFilePath(ParamStr(0)), 'locale\catalogs\pl.json');
   If FileExists(Catalog) Then
    Localizer.Load(Catalog);
   Application.CreateForm(TfrmMain, MainForm);
   MainForm.Bind(Settings, Localizer, Log);
   MainForm.StartTerminal;
   Application.Run;
  Except
   On E : Exception Do
    Begin
     Log.TryLogException(E, 'Guake main');
     Application.ShowException(E);
     ExitCode := 1;
    End;
  End;
 Finally
  If MainForm <> Nil Then
   MainForm.StopTerminal;
  Log.Free;
  Localizer.Free;
  Settings.Free;
 End;
End.
