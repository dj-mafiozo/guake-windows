{$StackFrames On}
/// <summary>Starts and shuts down the native Windows Guake application and its shared services.</summary>
Program Guake;
{$R *.res}

Uses
 StackTrace               In 'Vendor\stacktrace\source\StackTrace.pas',
 System.SysUtils, System.IOUtils, Vcl.Forms,
 Guake.CommandLine        In 'Integration\Guake.CommandLine.pas',
 Guake.IPC                In 'Integration\Guake.IPC.pas',
 Guake.WindowsIntegration In 'Integration\Guake.WindowsIntegration.pas',
 Guake.ProjectConfig      In 'Integration\Guake.ProjectConfig.pas',
 Guake.Unicode            In 'Terminal\Guake.Unicode.pas',
 Guake.Composition        In 'Appearance\Guake.Composition.pas',
 Guake.Colors             In 'Appearance\Guake.Colors.pas',
 Guake.AnimatedBackground In 'Appearance\Guake.AnimatedBackground.pas',
 Guake.Links              In 'Terminal\Guake.Links.pas',
 Guake.QuickOpen          In 'Terminal\Guake.QuickOpen.pas',
 Guake.Resources          In 'Resources\Guake.Resources.pas',
 Guake.ConPTY             In 'Terminal\Guake.ConPTY.pas',
 Guake.VT                 In 'Terminal\Guake.VT.pas',
 Guake.Sessions           In 'Terminal\Guake.Sessions.pas',
 Guake.Keybindings        In 'Terminal\Guake.Keybindings.pas',
 fraTerminalU             In 'Frames\fraTerminalU.pas',
 fraSplitU                In 'Frames\fraSplitU.pas',
 VersionU                 In 'Common\VersionU.pas',
 Guake.Settings           In 'Settings\Guake.Settings.pas',
 Guake.Localization       In 'Localization\Guake.Localization.pas',
 Guake.Logging            In 'Diagnostics\Guake.Logging.pas',
 Guake.Shells             In 'Terminal\Guake.Shells.pas',
 Guake.Palettes           In 'Appearance\Guake.Palettes.pas',
 frmMainU                 In 'Forms\frmMainU.pas',
 frmPreferencesU          In 'Forms\frmPreferencesU.pas',
 frmAboutU                In 'Forms\frmAboutU.pas',
 frmSearchU               In 'Forms\frmSearchU.pas',
 frmRenameU               In 'Forms\frmRenameU.pas',
 frmConfirmU              In 'Forms\frmConfirmU.pas',
 dmDialogsU               In 'DataModules\dmDialogsU.pas';

/// <summary>Forwards secondary launches before loading settings or starting terminal processes.</summary>

Procedure RunGuake;
 Var
  MainForm  : TfrmMain;
  Settings  : TGuakeSettings;
  Localizer : TGuakeLocalization;
  Log       : TGuakeLog;
  Instance  : TGuakeInstance;
  Options   : TGuakeLaunchOptions;
  Catalog   : String;
  Command   : String;
 Begin
  Options := ParseGuakeArguments(WindowsArguments);
  If Options.Help Then
   Begin
    WriteCommandLineMessage(GuakeCommandLineHelp);
    Exit;
   End;
  If Options.Version Then
   Begin
    WriteCommandLineMessage('Guake ' + ExeVersionInfo.FileVersion);
    Exit;
   End;
  Instance := TGuakeInstance.Create(Options.InstanceScope);
  Try
   If Not Instance.IsPrimary Then
    Begin
     If Length(Options.Commands) = 0 Then
      Begin
       If Options.Hidden Then
        Instance.SendCommand('{"action":"hide"}')
       Else
        Instance.SendCommand('{"action":"toggle"}');
      End
     Else
      For Command In Options.Commands Do
       Instance.SendCommand(Command);
     Exit;
    End;
   Application.Initialize;
   Application.ShowMainForm      := False;
   Application.MainFormOnTaskBar := False;
   MainForm                      := Nil;
   Settings                      := Nil;
   Localizer                     := Nil;
   Log                           := Nil;
   Try
    Settings  := TGuakeSettings.Create(TGuakeSettings.DefaultFileName);
    Localizer := TGuakeLocalization.Create;
    Log       := TGuakeLog.Create(ChangeFileExt(Settings.FileName, '.log'));
    Try
     Catalog := TPath.Combine(ExtractFilePath(ParamStr(0)), 'locale\catalogs\pl.json');
     If FileExists(Catalog) Then
      Localizer.Load(Catalog);
     Application.CreateForm(TfrmMain, MainForm);
     MainForm.Instance := Instance;
     MainForm.Bind(Settings, Localizer, Log);
     MainForm.StartTerminal;
     For Command In Options.Commands Do
      MainForm.ExecuteIPCCommand(Command);
     If Not Options.Hidden Then
      MainForm.SetTerminalVisible(True);
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
  Finally
   Instance.Free;
  End;
 End;

Begin
 Try
  RunGuake;
 Except
  On E : Exception Do
   Begin
    WriteCommandLineMessage(E.ClassName + ': ' + E.Message, True);
    ExitCode := 1;
   End;
 End;
End.
