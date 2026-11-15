{$StackFrames On}

/// <summary>Native executable discovery and Windows argument quoting for supported interactive shells.</summary>
Unit Guake.Shells;

Interface

 Uses
  System.SysUtils;

 Type
  TGuakeShell = (gsCmd, gsPowerShell, gsBash, gsZsh);

  TShellProfile = Record
   Kind       : TGuakeShell;
   Executable : String;
   GitSdkRoot : String;
   Arguments  : String;
   Function CommandLine : String;
   Function Available : Boolean;
   Class Function Resolve(Kind : TGuakeShell; Const GitSdkRoot : String = 'C:\git-sdk-64') : TShellProfile; Static;
  End;

 Function QuoteProcessArgument(Const Value : String) : String;

Implementation

 Uses
  System.IOUtils;

 Function QuoteProcessArgument(Const Value : String) : String;
  Var
   c       : Char;
   Slashes : Integer;
  Begin
   Result  := '"';
   Slashes := 0;
   For c In Value Do
    If c = '\' Then
     Inc(Slashes)
    Else
     Begin
      If c = '"' Then
       Result := Result + StringOfChar('\', Slashes * 2 + 1) + c
      Else
       Result := Result + StringOfChar('\', Slashes) + c;
      Slashes := 0;
     End;
   Result := Result + StringOfChar('\', Slashes * 2) + '"';
  End;

 Function TShellProfile.Available : Boolean;
  Begin
   Result := (Executable <> '') And TFile.Exists(Executable);
   If Result And (Kind = gsZsh) Then
    Result := TFile.Exists(TPath.Combine(GitSdkRoot, 'usr\bin\zsh.exe'));
  End;

 Function TShellProfile.CommandLine : String;
  Begin
   Result := QuoteProcessArgument(Executable);
   If Arguments <> '' Then
    Result := Result + ' ' + Arguments;
  End;

  Class Function TShellProfile.Resolve(Kind : TGuakeShell; Const GitSdkRoot : String) : TShellProfile;

 Var
  WindowsRoot : String;

Begin
 Result.Kind       := Kind;
 Result.GitSdkRoot := GitSdkRoot;
 WindowsRoot       := GetEnvironmentVariable('SystemRoot');
 Case Kind Of
  gsCmd :
   Begin
    Result.Executable := TPath.Combine(WindowsRoot, 'System32\cmd.exe');
    Result.Arguments  := '/D';
   End;
  gsPowerShell :
   Begin
    Result.Executable := TPath.Combine(WindowsRoot, 'System32\WindowsPowerShell\v1.0\powershell.exe');
    Result.Arguments  := '-NoLogo';
   End;
  gsBash :
   Begin
    Result.Executable := TPath.Combine(GitSdkRoot, 'usr\bin\bash.exe');
    Result.Arguments  := '--login -i';
   End;
  gsZsh :
   Begin
    Result.Executable := TPath.Combine(ExtractFilePath(ParamStr(0)), 'git-zsh.exe');
    Result.Arguments  := '--nomintty --git-sdk-root ' + QuoteProcessArgument(GitSdkRoot) + ' --login -i';
   End;
 End;
End;

End.
