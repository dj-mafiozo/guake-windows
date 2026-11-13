Unit Guake.Settings;

Interface

 Uses
  System.SysUtils, System.Classes, System.IniFiles;

 Type
  TGuakeSettings = Class
   Private
    fIni      : TMemIniFile;
    fFileName : String;
    Function  GetWindowWidth  : Integer;
    Function  GetWindowHeight : Integer;
    Function  GetHistorySize  : Integer;
    Function  GetShell        : String;
    Procedure SetWindowWidth (Value : Integer);
    Procedure SetWindowHeight(Value : Integer);
    Procedure SetHistorySize (Value : Integer);
    Procedure SetShell       (Const Value : String);
   Public
    Constructor    Create      (Const FileName : String);
    Destructor     Destroy; Override;
    Class Function DefaultFileName                                              : String; Static;
    Procedure      Reload;
    Procedure      Save;
    Function       ReadString  (Const Section, Key, Default : String)           : String;
    Function       ReadInteger (Const Section, Key : String; Default : Integer) : Integer;
    Function       ReadBool    (Const Section, Key : String; Default : Boolean) : Boolean;
    Procedure      WriteString (Const Section, Key, Value : String);
    Procedure      WriteInteger(Const Section, Key : String; Value : Integer);
    Procedure      WriteBool   (Const Section, Key : String; Value : Boolean);
    Property FileName     : String Read fFileName;
    Property WindowWidth  : Integer Read GetWindowWidth Write SetWindowWidth;
    Property WindowHeight : Integer Read GetWindowHeight Write SetWindowHeight;
    Property HistorySize  : Integer Read GetHistorySize Write SetHistorySize;
    Property Shell        : String Read GetShell Write SetShell;
  End;

Implementation

 Uses
  Winapi.Windows, System.IOUtils;

 Constructor TGuakeSettings.Create(Const FileName : String);
  Begin
   Inherited Create;
   If FileName = '' Then
    Raise EArgumentException.Create('Settings file name must not be empty');
   fFileName := ExpandFileName(FileName);
   fIni      := TMemIniFile.Create(fFileName, TEncoding.UTF8);
  End;

 Destructor TGuakeSettings.Destroy;
  Begin
   fIni.Free;
   Inherited;
  End;

  Class Function TGuakeSettings.DefaultFileName : String;

 Var
  Base : String;

Begin
 Base := GetEnvironmentVariable('APPDATA');
 If Base = '' Then
  Raise EInvalidOpException.Create('APPDATA is not defined');
 Result := TPath.Combine(TPath.Combine(Base, 'Guake'), 'guake.ini');
End;

 Procedure TGuakeSettings.Reload;
  Var
   Replacement : TMemIniFile;
  Begin
   Replacement := TMemIniFile.Create(fFileName, TEncoding.UTF8);
   fIni.Free;
   fIni := Replacement;
  End;

 Procedure TGuakeSettings.Save;
  Var
   TempName      : String;
   DirectoryName : String;
   Lines         : TStringList;
   TempIni       : TMemIniFile;
  Begin
   DirectoryName := ExtractFileDir(fFileName);
   If Not ForceDirectories(DirectoryName) Then
    Raise EInOutError.CreateFmt('Cannot create settings directory: %s', [DirectoryName]);
   TempName := TPath.Combine(DirectoryName, TPath.GetRandomFileName);
   Try
    Lines := TStringList.Create;
    Try
     fIni.GetStrings(Lines);
     TempIni := TMemIniFile.Create(TempName, TEncoding.UTF8);
     Try
      TempIni.SetStrings(Lines);
      TempIni.UpdateFile;
     Finally
      TempIni.Free;
     End;
    Finally
     Lines.Free;
    End;
    If Not MoveFileEx(PChar(TempName), PChar(fFileName),
    MOVEFILE_REPLACE_EXISTING Or MOVEFILE_WRITE_THROUGH) Then
     RaiseLastOSError;
   Finally
    If FileExists(TempName) Then
     System.SysUtils.DeleteFile(TempName);
   End;
  End;

 Function TGuakeSettings.ReadString(Const Section, Key, Default : String) : String;
  Begin
   Result := fIni.ReadString(Section, Key, Default);
  End;

 Function TGuakeSettings.ReadInteger(Const Section, Key : String; Default : Integer) : Integer;
  Begin
   Result := fIni.ReadInteger(Section, Key, Default);
  End;

 Function TGuakeSettings.ReadBool(Const Section, Key : String; Default : Boolean) : Boolean;
  Begin
   Result := fIni.ReadBool(Section, Key, Default);
  End;

 Procedure TGuakeSettings.WriteString(Const Section, Key, Value : String);
  Begin
   If (Pos(#13, Value) > 0) Or (Pos(#10, Value) > 0) Then
    Raise EArgumentException.Create('INI values must be single-line');
   fIni.WriteString(Section, Key, Value);
  End;

 Procedure TGuakeSettings.WriteInteger(Const Section, Key : String; Value : Integer);
  Begin
   fIni.WriteInteger(Section, Key, Value);
  End;

 Procedure TGuakeSettings.WriteBool(Const Section, Key : String; Value : Boolean);
  Begin
   fIni.WriteBool(Section, Key, Value);
  End;

 Function TGuakeSettings.GetWindowWidth : Integer;
  Begin
   Result := ReadInteger('general', 'window-width', 100);
   If (Result < 1) Or (Result > 100) Then
    Result := 100;
  End;

 Function TGuakeSettings.GetWindowHeight : Integer;
  Begin
   Result := ReadInteger('general', 'window-height', 50);
   If (Result < 1) Or (Result > 100) Then
    Result := 50;
  End;

 Function TGuakeSettings.GetHistorySize : Integer;
  Begin
   Result := ReadInteger('general', 'history-size', 1000);
   If Result < 0 Then
    Result := 1000;
  End;

 Function TGuakeSettings.GetShell : String;
  Begin
   Result := ReadString('general', 'default-shell', 'powershell');
  End;

 Procedure TGuakeSettings.SetWindowWidth(Value : Integer);
  Begin
   If (Value < 1) Or (Value > 100) Then
    Raise EArgumentOutOfRangeException.Create('Window width must be between 1 and 100');
   WriteInteger('general', 'window-width', Value);
  End;

 Procedure TGuakeSettings.SetWindowHeight(Value : Integer);
  Begin
   If (Value < 1) Or (Value > 100) Then
    Raise EArgumentOutOfRangeException.Create('Window height must be between 1 and 100');
   WriteInteger('general', 'window-height', Value);
  End;

 Procedure TGuakeSettings.SetHistorySize(Value : Integer);
  Begin
   If Value < 0 Then
    Raise EArgumentOutOfRangeException.Create('History size must not be negative');
   WriteInteger('general', 'history-size', Value);
  End;

 Procedure TGuakeSettings.SetShell(Const Value : String);
  Begin
   WriteString('general', 'default-shell', Value);
  End;

End.
