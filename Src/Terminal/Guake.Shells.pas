{$StackFrames On}

Unit Guake.Shells;

Interface

 Uses
  System.SysUtils;

 Type
  TGuakeShell = (gsCmd, gsPowerShell, gsBash, gsZsh);

  TShellProfile = Record
   Kind       : TGuakeShell;
   Executable : String;
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
 Result.Kind := Kind;
 WindowsRoot := GetEnvironmentVariable('SystemRoot');
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
    Result.Executable := TPath.Combine(GitSdkRoot, 'usr\bin\zsh.exe');
    Result.Arguments  := '-l -i';
   End;
 End;
End;

End.
