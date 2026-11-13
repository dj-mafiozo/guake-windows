{$StackFrames On}

Program GuakeTests;

{$APPTYPE CONSOLE}
{$R *.res}

Uses
 StackTrace              In '..\Vendor\stacktrace\source\StackTrace.pas',
 Vcl.Forms,
 Guake.Preferences.Tests In 'Guake.Preferences.Tests.pas',
 frmAboutU               In '..\Forms\frmAboutU.pas',
 frmSearchU              In '..\Forms\frmSearchU.pas',
 frmRenameU              In '..\Forms\frmRenameU.pas',
 frmConfirmU             In '..\Forms\frmConfirmU.pas',
 frmMainU                In '..\Forms\frmMainU.pas',
 dmDialogsU              In '..\DataModules\dmDialogsU.pas',

 Guake.Palettes          In '..\Appearance\Guake.Palettes.pas',
 frmPreferencesU         In '..\Forms\frmPreferencesU.pas',
 System.SysUtils,
 DUnitX.TestFramework,
 DUnitX.Loggers.Console,
 DUnitX.Loggers.XML.NUnit,
 Guake.Services.Tests    In 'Guake.Services.Tests.pas',
 Guake.Localization      In '..\Localization\Guake.Localization.pas',
 Guake.Logging           In '..\Diagnostics\Guake.Logging.pas',
 Guake.Core.Tests        In 'Guake.Core.Tests.pas',
 Guake.Settings          In '..\Settings\Guake.Settings.pas',
 Guake.Shells            In '..\Terminal\Guake.Shells.pas',
 VersionU                In '..\Common\VersionU.pas';

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
