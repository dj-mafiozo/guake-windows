{$StackFrames On}
/// <summary>Starts the standalone preference-view development preview with shared settings and logging.</summary>
Program GuakeFormsPreview;
{$R *.res}

Uses
 StackTrace               In '..\Vendor\stacktrace\source\StackTrace.pas',
 Guake.CommandLine        In '..\Integration\Guake.CommandLine.pas',
 Guake.IPC                In '..\Integration\Guake.IPC.pas',
 Guake.WindowsIntegration In '..\Integration\Guake.WindowsIntegration.pas',
 Guake.ProjectConfig      In '..\Integration\Guake.ProjectConfig.pas',
 Guake.Unicode            In '..\Terminal\Guake.Unicode.pas',
 Guake.Composition        In '..\Appearance\Guake.Composition.pas',
 Guake.AnimatedBackground In '..\Appearance\Guake.AnimatedBackground.pas',
 Guake.Links              In '..\Terminal\Guake.Links.pas',
 Guake.Resources          In '..\Resources\Guake.Resources.pas',
 Guake.ConPTY             In '..\Terminal\Guake.ConPTY.pas',
 Guake.VT                 In '..\Terminal\Guake.VT.pas',
 Guake.Sessions           In '..\Terminal\Guake.Sessions.pas',
 Guake.Keybindings        In '..\Terminal\Guake.Keybindings.pas',
 fraTerminalU             In '..\Frames\fraTerminalU.pas',
 fraSplitU                In '..\Frames\fraSplitU.pas',
 System.SysUtils, System.IOUtils, Vcl.Forms,
 Guake.Settings           In '..\Settings\Guake.Settings.pas',
 Guake.Localization       In '..\Localization\Guake.Localization.pas',
 Guake.Logging            In '..\Diagnostics\Guake.Logging.pas',
 Guake.Shells             In '..\Terminal\Guake.Shells.pas',
 Guake.Palettes           In '..\Appearance\Guake.Palettes.pas',
 VersionU                 In '..\Common\VersionU.pas',
 frmPreferencesU          In '..\Forms\frmPreferencesU.pas',
 frmAboutU                In '..\Forms\frmAboutU.pas',
 frmSearchU               In '..\Forms\frmSearchU.pas',
 frmRenameU               In '..\Forms\frmRenameU.pas',
 frmConfirmU              In '..\Forms\frmConfirmU.pas',
 frmMainU                 In '..\Forms\frmMainU.pas',
 dmDialogsU               In '..\DataModules\dmDialogsU.pas';

Var
 Preferences : TfrmPreferences;
 Settings    : TGuakeSettings;
 Localizer   : TGuakeLocalization;
 Log         : TGuakeLog;
 Catalog     : String;

Begin
 Application.Initialize;
 Application.MainFormOnTaskBar := True;
 Settings                      := TGuakeSettings.Create(TGuakeSettings.DefaultFileName);
 Localizer                     := TGuakeLocalization.Create;
 Log                           := TGuakeLog.Create(ChangeFileExt(Settings.FileName, '.log'));
 Try
  Try
   Catalog := TPath.Combine(ExtractFilePath(ParamStr(0)), 'locale\catalogs\pl.json');
   If FileExists(Catalog) Then
    Localizer.Load(Catalog);
   Application.CreateForm(TfrmPreferences, Preferences);
   Preferences.Bind(Settings, Localizer, Log);
   Application.Run;
  Except
   On E : Exception Do
    Begin
     Log.TryLogException(E, 'Forms preview');
     Application.ShowException(E);
     ExitCode := 1;
    End;
  End;
 Finally
  Log.Free;
  Localizer.Free;
  Settings.Free;
 End;
End.
