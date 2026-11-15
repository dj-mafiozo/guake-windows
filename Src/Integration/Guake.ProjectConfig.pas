{$StackFrames On}
/// <summary>Reads project titles and bounded custom-command descriptions without executing loaded data.</summary>
Unit Guake.ProjectConfig;

Interface

 Uses
  System.SysUtils, System.Generics.Collections;

 Type
  TCustomCommand = Class
   Public
    Description : String;
    Command     : String;
    IsMenu      : Boolean;
    Children    : TObjectList<TCustomCommand>;
    Constructor Create;
    Destructor  Destroy; Override;
  End;

 Function ExpandUserPath(Const Value : String) : String;
 Function ProjectTitleFromYaml(Const Value : String) : String;
 Function ReadProjectTitle(Const Directory : String) : String;
 Function ReadCustomCommands(Const FileName : String) : TObjectList<TCustomCommand>;

Implementation

 Uses
  Winapi.Windows, System.Classes, System.IOUtils, System.JSON, System.RegularExpressions;

 Constructor TCustomCommand.Create;
  Begin
   Inherited;
   Children := TObjectList<TCustomCommand>.Create(True);
  End;

 Destructor TCustomCommand.Destroy;
  Begin
   Children.Free;
   Inherited;
  End;

 Function ExpandUserPath(Const Value : String) : String;
  Var
   Count : DWORD;
  Begin
   Count := ExpandEnvironmentStrings(PChar(Value), Nil, 0);
   SetLength(Result, Count);
   If Count > 0 Then
    Begin
     ExpandEnvironmentStrings(PChar(Value), PChar(Result), Count);
     SetLength(Result, Count - 1);
    End;
   If (Result = '~') Or (Copy(Result, 1, 2) = '~/') Or (Copy(Result, 1, 2) = '~\') Then
    Result := GetEnvironmentVariable('USERPROFILE') + Copy(Result, 2, MaxInt);
  End;

 Function ProjectTitleFromYaml(Const Value : String) : String;
  Var
   Lines   : TArray<String>;
   Scalar  : String;
   Piece   : String;
   i       : Integer;
   j       : Integer;
   Last    : Integer;
   Indent  : Integer;
   Minimum : Integer;
   Hash    : Integer;
   Root    : TJSONValue;
   Match   : TMatch;
   Folded  : Boolean;
  Begin
   Result := '';
   If Length(Value) > 65536 Then
    Exit;
   If Copy(TrimLeft(Value), 1, 1) = '{' Then
    Begin
     Root := TJSONObject.ParseJSONValue(Value);
     Try
      If (Root Is TJSONObject) And (TJSONObject(Root).GetValue('title') Is TJSONString) Then
       Result := TJSONObject(Root).GetValue('title').Value;
     Finally
      Root.Free;
     End;
     Exit;
    End;
   Lines := StringReplace(Value, #13, '', [rfReplaceAll]).Split([#10]);
   For i := 0 To High(Lines) Do
    Begin
     Match := TRegEx.Match(Lines[i], '^(?:title|"title"|''title''):\s*(.*)$');
     If Not Match.Success Then
      Continue;
     Scalar := Trim(Match.Groups[1].Value);
     If Scalar = '' Then
      Exit;
     If Scalar[1] = '"' Then
      Begin
       Match := TRegEx.Match(Scalar, '^"(?:[^"\\]|\\.)*"');
       If Not Match.Success Then
        Exit;
       Root := TJSONObject.ParseJSONValue(Match.Value);
       Try
        If Root Is TJSONString Then
         Result := Root.Value;
       Finally
        Root.Free;
       End;
       Exit;
      End;
     If Scalar[1] = #39 Then
      Begin
       Match := TRegEx.Match(Scalar, '^''(?:[^'']|'''')*''');
       If Match.Success Then
        Result := StringReplace(Copy(Match.Value, 2, Length(Match.Value) - 2), #39#39, #39, [rfReplaceAll]);
       Exit;
      End;
     If CharInSet(Scalar[1], ['|', '>']) Then
      Begin
       Folded  := Scalar[1] = '>';
       Minimum := MaxInt;
       Last    := i;
       For j   := i + 1 To High(Lines) Do
        Begin
         Piece := Lines[j];
         If (Trim(Piece) <> '') And (Piece[1] <> ' ') Then
          Break;
         If Trim(Piece) <> '' Then
          Begin
           Indent := 0;
           While (Indent < Length(Piece)) And (Piece[Indent + 1] = ' ') Do
            Inc(Indent);
           If Indent < Minimum Then
            Minimum := Indent;
          End;
         Last := j;
        End;
       If Minimum = MaxInt Then
        Minimum := 0;
       For j    := i + 1 To Last Do
        Begin
         Piece := Copy(Lines[j], Minimum + 1, MaxInt);
         If (Result <> '') And Folded And (Piece <> '') Then
          Result := Result + ' '
         Else If Result <> '' Then
          Result := Result + #10;
         Result  := Result + Piece;
        End;
       If Pos('-', Scalar) = 0 Then
        Result := Result + #10;
       Exit;
      End;
     // No tags, constructors, aliases or implicit object types are interpreted.
     If CharInSet(Scalar[1], ['!', '&', '*', '[', '{']) Then
      Exit;
     Hash := Pos(' #', Scalar);
     If Hash > 0 Then
      Scalar := TrimRight(Copy(Scalar, 1, Hash - 1));
     Result  := Scalar;
     Exit;
    End;
  End;

 Function ReadProjectTitle(Const Directory : String) : String;
  Var
   FileName : String;
   Stream   : TFileStream;
   Reader   : TStreamReader;
   Encoding : TUTF8Encoding;
  Begin
   Result   := '';
   FileName := TPath.Combine(Directory, '.guake.yml');
   If Not TFile.Exists(FileName) Then
    Exit;
   Try
    Stream := TFileStream.Create(FileName, fmOpenRead Or fmShareDenyWrite);
    Try
     If Stream.Size > 65536 Then
      Exit;
     Encoding := TUTF8Encoding.Create;
     Try
      Reader := TStreamReader.Create(Stream, Encoding, True);
      Try
       Result := ProjectTitleFromYaml(Reader.ReadToEnd);
      Finally
       Reader.Free;
      End;
     Finally
      Encoding.Free;
     End;
    Finally
     Stream.Free;
    End;
   Except
    On E : Exception Do
     OutputDebugString(PChar(E.ClassName + ': ' + E.Message));
   End;
  End;

 Function ReadCustomCommands(Const FileName : String) : TObjectList<TCustomCommand>;
  Var
   Root   : TJSONValue;
   Stream : TFileStream;
   Reader : TStreamReader;
   Count  : Integer;

   Procedure Parse(Values : TJSONArray; Target : TObjectList<TCustomCommand>; Depth : Integer);
    Var
     Entry     : TJSONValue;
     Argument  : TJSONValue;
     TypeValue : TJSONValue;
     Obj       : TJSONObject;
     Item      : TCustomCommand;
    Begin
     If Depth > 16 Then
      Raise EArgumentException.Create('Custom command menu is too deep');
     For Entry In Values Do
      Begin
       Inc(Count);
       If Count > 1000 Then
        Raise EArgumentException.Create('Too many custom commands');
       If Not(Entry Is TJSONObject) Then
        Raise EArgumentException.Create('Invalid custom command');
       Obj := TJSONObject(Entry);
       If Not(Obj.GetValue('description') Is TJSONString) Then
        Raise EArgumentException.Create('Missing custom command description');
       Item := TCustomCommand.Create;
       Target.Add(Item);
       Item.Description := Obj.GetValue('description').Value;
       TypeValue        := Obj.GetValue('type');
       Item.IsMenu      := (TypeValue <> Nil) And (TypeValue.Value = 'menu');
       If Item.IsMenu Then
        Begin
         If Not(Obj.GetValue('items') Is TJSONArray) Then
          Raise EArgumentException.Create('Invalid custom submenu');
         Parse(TJSONArray(Obj.GetValue('items')), Item.Children, Depth + 1);
        End
       Else
        Begin
         If Not(Obj.GetValue('cmd') Is TJSONArray) Then
          Raise EArgumentException.Create('Missing custom command arguments');
         For Argument In TJSONArray(Obj.GetValue('cmd')) Do
          Begin
           If Not(Argument Is TJSONString) Then
            Raise EArgumentException.Create('Invalid custom command argument');
           If Item.Command <> '' Then
            Item.Command := Item.Command + ' ';
           Item.Command  := Item.Command + Argument.Value;
          End;
        End;
      End;
    End;

  Begin
   Result := TObjectList<TCustomCommand>.Create(True);
   Root   := Nil;
   Try
    Try
     Stream := TFileStream.Create(ExpandUserPath(FileName), fmOpenRead Or fmShareDenyWrite);
     Try
      If Stream.Size > 1024 * 1024 Then
       Raise EArgumentException.Create('Custom command file exceeds 1 MiB');
      Reader := TStreamReader.Create(Stream, TEncoding.UTF8, True);
      Try
       Root := TJSONObject.ParseJSONValue(Reader.ReadToEnd);
      Finally
       Reader.Free;
      End;
     Finally
      Stream.Free;
     End;
     If Not(Root Is TJSONArray) Then
      Raise EArgumentException.Create('Custom commands must be a JSON array');
     Count := 0;
     Parse(TJSONArray(Root), Result, 0);
    Except
     Result.Free;
     Raise;
    End;
   Finally
    Root.Free;
   End;
  End;

End.
