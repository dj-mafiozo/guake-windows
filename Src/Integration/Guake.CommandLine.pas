{$StackFrames On}
/// <summary>Parses Windows command-line arguments into explicit named-pipe actions without changing shell quoting.</summary>
Unit Guake.CommandLine;

Interface

 Type
  TGuakeLaunchOptions = Record
   Hidden        : Boolean;
   Help          : Boolean;
   Version       : Boolean;
   InstanceScope : String;
   Commands      : TArray<String>;
  End;

 Function WindowsArguments : TArray<String>;
 Function ParseGuakeArguments(Const Arguments : TArray<String>) : TGuakeLaunchOptions;
 Procedure WriteCommandLineMessage(Const Value : String; Error : Boolean = False);

 Const
  GuakeCommandLineHelp = 'Guake dla Windows'#13#10 +
  '--show | --hide | --toggle-visibility | --hidden'#13#10 +
  '--new-tab [katalog] [--shell cmd|powershell|bash|zsh]'#13#10 +
  '--select-tab indeks | --close-tab | --rename-current-tab nazwa'#13#10 +
  '--split-horizontal | --split-vertical | --fullscreen | --unfullscreen'#13#10 +
  '--execute-command polecenie | --save-tabs | --restore-tabs'#13#10 +
  '--preferences | --about | --quit | --no-startup-script'#13#10 +
  '--bgcolor HEX | --fgcolor HEX | --bgcolor-current HEX | --fgcolor-current HEX'#13#10 +
  '--reset-colors | --reset-colors-current'#13#10 +
  '--version | --help'#13#10;

Implementation

 Uses
  Winapi.Windows, Winapi.ShellAPI, Guake.Colors, System.SysUtils, System.JSON, System.Generics.Collections;

 Function AttachParentConsole(ProcessId : DWORD) : BOOL; Stdcall; External 'kernel32.dll' name 'AttachConsole';

 Function WindowsArguments : TArray<String>;
  Type
   TArguments = Array[0..65535] Of PWideChar;
   PArguments = ^TArguments;
  Var
   Values : PPWideChar;
   Count  : Integer;
   i      : Integer;
  Begin
   Values := CommandLineToArgvW(GetCommandLineW, Count);
   If Values = Nil Then
    RaiseLastOSError;
   Try
    SetLength(Result, Count - 1);
    For i          := 1 To Count - 1 Do
     Result[i - 1] := PArguments(Values)^[i];
   Finally
    LocalFree(HLOCAL(Values));
   End;
  End;

 Function ParseGuakeArguments(Const Arguments : TArray<String>) : TGuakeLaunchOptions;
  Var
   i         : Integer;
   Index     : Integer;
   Arg       : String;
   Value     : String;
   Shell     : String;
   Directory : String;
   Commands  : TObjectList<TJSONObject>;
   Command   : TJSONObject;
   Pair      : TJSONPair;

   Function Parameter : String;
    Begin
     Inc(i);
     If i >= Length(Arguments) Then
      Raise EArgumentException.Create('Missing argument: ' + Arg);
     Result := Arguments[i];
    End;

   Procedure Add(Const Action : String; Const Field : String = ''; Const Data : String = '');
    Var
     Item : TJSONObject;
    Begin
     Item := TJSONObject.Create;
     Commands.Add(Item);
     Item.AddPair('action', Action);
     If Field <> '' Then
      Item.AddPair(Field, Data);
    End;

  Begin
   Result   := Default(TGuakeLaunchOptions);
   Commands := TObjectList<TJSONObject>.Create(True);
   Try
    i         := 0;
    Shell     := '';
    Directory := '';
    While i < Length(Arguments) Do
     Begin
      Arg := Arguments[i];
      If (Arg = '--help') Or (Arg = '-h') Then
       Result.Help := True
      Else If (Arg = '--version') Or (Arg = '-V') Then
       Result.Version := True
      Else If Arg = '--instance' Then
       Result.InstanceScope := Parameter
      Else If Arg = '--hidden' Then
       Result.Hidden := True
      Else If Arg = '--no-startup-script' Then
       Begin
       End
      Else If Arg = '--show' Then
       Add('show')
      Else If Arg = '--hide' Then
       Begin
        Add('hide');
        Result.Hidden := True;
       End
      Else If (Arg = '--toggle-visibility') Or (Arg = '--toggle') Or (Arg = '-t') Then
       Add('toggle')
      Else If (Arg = '--fullscreen') Or (Arg = '-f') Then
       Add('fullscreen')
      Else If Arg = '--unfullscreen' Then
       Add('unfullscreen')
      Else If (Arg = '--preferences') Or (Arg = '-p') Then
       Add('preferences')
      Else If (Arg = '--about') Or (Arg = '-a') Then
       Add('about')
      Else If (Arg = '--quit') Or (Arg = '-q') Then
       Begin
        Add('quit');
        Result.Hidden := True;
       End
      Else If (Arg = '--bgcolor') Or (Arg = '--fgcolor') Or (Arg = '--bgcolor-current') Or (Arg = '--fgcolor-current') Then
       Begin
        Value := Parameter;
        ParseTerminalColor(Value);
        If Pos('--bgcolor', Arg) = 1 Then
         Add('bgcolor', 'color', Value)
        Else
         Add('fgcolor', 'color', Value);
        If Pos('-current', Arg) > 0 Then
         Commands.Last.AddPair('current', 'true');
       End
      Else If (Arg = '--reset-colors') Or (Arg = '--reset-colors-current') Then
       Begin
        Add('reset-colors');
        If Arg = '--reset-colors-current' Then
         Commands.Last.AddPair('current', 'true');
       End
      Else If Arg = '--close-tab' Then
       Add('close-tab')
      Else If Arg = '--split-horizontal' Then
       Add('split-horizontal')
      Else If Arg = '--split-vertical' Then
       Add('split-vertical')
      Else If (Arg = '--save-tabs') Or (Arg = '--save-session') Then
       Add('save-session')
      Else If (Arg = '--restore-tabs') Or (Arg = '--restore-session') Then
       Add('restore-session')
      Else If (Arg = '--execute-command') Or (Arg = '--execute') Or (Arg = '-e') Then
       Add('execute', 'text', Parameter)
      Else If (Arg = '--rename-current-tab') Or (Arg = '--rename-tab') Then
       Add('rename-tab', 'name', Parameter)
      Else If Arg = '--select-tab' Then
       Begin
        Value := Parameter;
        Index := StrToInt(Value);
        If Index < 0 Then
         Raise EArgumentException.Create('Tab index must be nonnegative');
        Add('select-tab', 'index', Value);
       End
      Else If Arg = '--shell' Then
       Begin
        Shell := LowerCase(Parameter);
        If (Shell <> 'cmd') And (Shell <> 'powershell') And (Shell <> 'bash') And (Shell <> 'zsh') Then
         Raise EArgumentException.Create('Unsupported shell: ' + Shell);
       End
      Else If Arg = '--working-directory' Then
       Directory := Parameter
      Else If (Arg = '--new-tab') Or (Arg = '-n') Then
       Begin
        Value := '';
        If (i + 1 < Length(Arguments)) And (Copy(Arguments[i + 1], 1, 1) <> '-') Then
         Value := Parameter;
        Add('new-tab', 'directory', Value);
       End
      Else If Copy(Arg, 1, 1) <> '-' Then
       Add('new-tab', 'directory', Arg)
      Else
       Raise EArgumentException.Create('Unsupported option: ' + Arg);
      Inc(i);
     End;
    If ((Shell <> '') Or (Directory <> '')) And (Commands.Count = 0) Then
     Add('new-tab');
    SetLength(Result.Commands, Commands.Count);
    For i := 0 To Commands.Count - 1 Do
     Begin
      Command := Commands[i];
      If Command.GetValue('action').Value = 'new-tab' Then
       Begin
        If Shell <> '' Then
         Command.AddPair('shell', Shell);
        If Directory <> '' Then
         Begin
          Pair := Command.RemovePair('directory');
          Pair.Free;
          Command.AddPair('directory', ExpandFileName(Directory));
         End
        Else If Command.GetValue('directory') <> Nil Then
         Begin
          Value := Command.GetValue('directory').Value;
          If Value <> '' Then
           Begin
            Pair := Command.RemovePair('directory');
            Pair.Free;
            Command.AddPair('directory', ExpandFileName(Value));
           End;
         End;
       End;
      Result.Commands[i] := Command.ToJSON;
     End;
   Finally
    Commands.Free;
   End;
  End;

 Procedure WriteCommandLineMessage(Const Value : String; Error : Boolean);
  Var
   Handle  : THandle;
   Mode    : DWORD;
   Written : DWORD;
   Bytes   : TBytes;
   Text    : String;
  Begin
   If Error Then
    Handle := GetStdHandle(STD_ERROR_HANDLE)
   Else
    Handle := GetStdHandle(STD_OUTPUT_HANDLE);
   If (Handle = 0) Or (Handle = INVALID_HANDLE_VALUE) Then
    Begin
     AttachParentConsole(DWORD( -1));
     If Error Then
      Handle := GetStdHandle(STD_ERROR_HANDLE)
     Else
      Handle := GetStdHandle(STD_OUTPUT_HANDLE);
    End;
   Text := Value + sLineBreak;
   If (Handle = 0) Or (Handle = INVALID_HANDLE_VALUE) Then
    Begin
     MessageBox(0, PChar(Value), 'Guake', MB_OK);
     Exit;
    End;
   If GetConsoleMode(Handle, Mode) Then
    WriteConsoleW(Handle, PWideChar(Text), Length(Text), Written, Nil)
   Else
    Begin
     Bytes := TEncoding.UTF8.GetBytes(Text);
     WriteFile(Handle, Bytes[0], Length(Bytes), Written, Nil);
    End;
  End;

End.
