Program GuakeTests;

{$APPTYPE CONSOLE}
{$R *.res}

Uses
 StackTrace           In '..\vendor\stacktrace\source\StackTrace.pas',
 Guake.Services.Tests In 'Guake.Services.Tests.pas',
 Guake.Localization   In '..\Src\Guake.Localization.pas',
 Guake.Logging        In '..\Src\Guake.Logging.pas',
 System.SysUtils,
 DUnitX.TestFramework,
 DUnitX.Loggers.Console,
 DUnitX.Loggers.XML.NUnit,
 Guake.Core.Tests     In 'Guake.Core.Tests.pas',
 Guake.Settings       In '..\Src\Guake.Settings.pas',
 Guake.Shells         In '..\Src\Guake.Shells.pas',
 VersionU             In '..\Src\Common\VersionU.pas';

Var
 Runner  : ITestRunner;
 Results : IRunResults;
 Log     : TGuakeLog;

Begin
 Try
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
