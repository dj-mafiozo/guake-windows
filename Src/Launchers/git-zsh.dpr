{$StackFrames On}
/// <summary>Starts Git SDK Zsh in mintty by default, or in the inherited console with --nomintty.</summary>
Program GitZsh;
{$APPTYPE CONSOLE}
{$R git-zsh.res}

Uses
 StackTrace   In '..\Vendor\stacktrace\source\StackTrace.pas',
 System.SysUtils, Winapi.Windows,
 Guake.Shells In '..\Terminal\Guake.Shells.pas',
 Guake.GitZsh In 'Guake.GitZsh.pas';

Begin
 Try
  ExitCode := RunGitZsh;
 Except
  On E : Exception Do
   Begin
    Writeln(ErrOutput, E.ClassName + ': ' + E.Message);
    Writeln(ErrOutput, E.StackTrace);
    ExitCode := 1;
   End;
 End;
End.
