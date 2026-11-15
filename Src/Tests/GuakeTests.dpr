{$StackFrames On}

/// <summary>Runs DUnitX scenarios with structured reports and an error exit status.</summary>
Program GuakeTests;

{$APPTYPE CONSOLE}
{$R *.res}

Uses
 StackTrace               In '..\Vendor\stacktrace\source\StackTrace.pas',
 Guake.IPC.Tests          In 'Guake.IPC.Tests.pas',
 Guake.CommandLine        In '..\Integration\Guake.CommandLine.pas',
 Guake.IPC                In '..\Integration\Guake.IPC.pas',
 Guake.WindowsIntegration In '..\Integration\Guake.WindowsIntegration.pas',
 Guake.ProjectConfig      In '..\Integration\Guake.ProjectConfig.pas',
 Guake.Unicode            In '..\Terminal\Guake.Unicode.pas',
 Guake.Composition        In '..\Appearance\Guake.Composition.pas',
 Guake.AnimatedBackground In '..\Appearance\Guake.AnimatedBackground.pas',
 Guake.Links              In '..\Terminal\Guake.Links.pas',
 Guake.QuickOpen          In '..\Terminal\Guake.QuickOpen.pas',
 Guake.Resources          In '..\Resources\Guake.Resources.pas',
 Guake.ConPTY             In '..\Terminal\Guake.ConPTY.pas',
 Guake.VT                 In '..\Terminal\Guake.VT.pas',
 Guake.Sessions           In '..\Terminal\Guake.Sessions.pas',
 Guake.Keybindings        In '..\Terminal\Guake.Keybindings.pas',
 fraTerminalU             In '..\Frames\fraTerminalU.pas',
 fraSplitU                In '..\Frames\fraSplitU.pas',
 Guake.Terminal.Tests     In 'Guake.Terminal.Tests.pas',
 Vcl.Forms,
 Guake.Preferences.Tests  In 'Guake.Preferences.Tests.pas',
 frmAboutU                In '..\Forms\frmAboutU.pas',
 frmSearchU               In '..\Forms\frmSearchU.pas',
 frmRenameU               In '..\Forms\frmRenameU.pas',
 frmConfirmU              In '..\Forms\frmConfirmU.pas',
 frmMainU                 In '..\Forms\frmMainU.pas',
 dmDialogsU               In '..\DataModules\dmDialogsU.pas',

 Guake.Palettes           In '..\Appearance\Guake.Palettes.pas',
 frmPreferencesU          In '..\Forms\frmPreferencesU.pas',
 System.SysUtils,
 DUnitX.TestFramework,
 DUnitX.Loggers.Console,
 DUnitX.Loggers.XML.NUnit,
 Guake.Services.Tests     In 'Guake.Services.Tests.pas',
 Guake.Localization       In '..\Localization\Guake.Localization.pas',
 Guake.Logging            In '..\Diagnostics\Guake.Logging.pas',
 Guake.Core.Tests         In 'Guake.Core.Tests.pas',
 Guake.Settings           In '..\Settings\Guake.Settings.pas',
 Guake.Shells             In '..\Terminal\Guake.Shells.pas',
 VersionU                 In '..\Common\VersionU.pas';

Var
 Runner  : ITestRunner;
 Results : IRunResults;
 Log     : TGuakeLog;

Begin
 Try
  Application.Initialize;
  TDUnitX.CheckCommandLine;
  Runner                  := TDUnitX.CreateRunner;
  Runner.UseRTTI          := True;
  Runner.FailsOnNoAsserts := True;
  Runner.AddLogger(TDUnitXConsoleLogger.Create(True));
  Runner.AddLogger(TDUnitXXMLNUnitFileLogger.Create(ExtractFilePath(ParamStr(0)) + 'test-results.xml'));
  Results := Runner.Execute;
  If Not Results.AllPassed Then
   ExitCode := 1;
 Except
  On E : Exception Do
   Begin
    Log := TGuakeLog.Create(ExtractFilePath(ParamStr(0)) + 'exceptions.log');
    Try
     Log.TryLogException(E, 'DUnitX runner');
    Finally
     Log.Free;
    End;
    Writeln(E.ClassName, ': ', E.Message);
    ExitCode := 2;
   End;
 End;
End.
