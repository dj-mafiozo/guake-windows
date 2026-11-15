{$StackFrames On}
/// <summary>Resolves existing local files in terminal diagnostics and expands editor commands for the active shell.</summary>
Unit Guake.QuickOpen;

Interface

 Uses
  Guake.Shells;

 Type
  /// <summary>A validated native path with one-based source coordinates.</summary>
  TQuickOpenTarget = Record
   FileName     : String;
   LineNumber   : Integer;
   ColumnNumber : Integer;
  End;

/// <summary>A negative character index searches a selected string; otherwise the match must contain the clicked UTF-16 index.</summary>

 Function FindQuickOpenTarget(Const Text : String; CharacterIndex : Integer; Const Directory, GitSdkRoot : String; Out Target : TQuickOpenTarget) : Boolean;
 /// <summary>Quotes file paths according to CMD, PowerShell or POSIX rules, including quoted placeholders.</summary>
 Function QuickOpenCommand(Const Template : String; Const Target : TQuickOpenTarget; Shell : TGuakeShell) : String;

Implementation

 Uses
  System.Classes, System.Math, System.SysUtils, System.IOUtils, System.RegularExpressions;

 Function GroupValue(Const Match : TMatch; Index : Integer) : String;
  Begin
   If Index < Match.Groups.Count Then
    Result := Match.Groups[Index].Value
   Else
    Result := '';
  End;

 Function ResolveFile(Const Value, Directory, GitSdkRoot : String; Out FileName : String) : Boolean;
  Var
   s : String;
  Begin
   Result   := False;
   FileName := '';
   s        := Trim(Value);
   If (Length(s) >= 2) And (((s[1] = '"') And (s[Length(s)] = '"')) Or
   ((s[1] = #39) And (s[Length(s)] = #39))) Then
    s := Copy(s, 2, Length(s) - 2);
   If (s = '') Or (Pos('://', s) > 0) Or (Pos(#0, s) > 0) Or
   (Pos(#13, s) > 0) Or (Pos(#10, s) > 0) Then
    Exit;
   If (s = '~') Or (Copy(s, 1, 2) = '~/') Or (Copy(s, 1, 2) = '~\') Then
    s := GetEnvironmentVariable('USERPROFILE') + Copy(s, 2, MaxInt);
   If (Length(s) >= 3) And (s[1] = '/') And CharInSet(s[2], ['A'..'Z', 'a'..'z']) And (s[3] = '/') Then
    s := UpCase(s[2]) + ':' + Copy(s, 3, MaxInt)
   Else If (s[1] = '/') And (Copy(s, 1, 2) <> '//') Then
    s := ExcludeTrailingPathDelimiter(GitSdkRoot) + s;
   s  := StringReplace(s, '/', '\', [rfReplaceAll]);
   Try
    If Not TPath.IsPathRooted(s) Then
     s := TPath.Combine(Directory, s);
    s  := ExpandFileName(s);
    If TFile.Exists(s) Then
     Begin
      FileName := s;
      Result   := True;
     End;
   Except
    On E : EArgumentException Do
     Exit;
    On E : EPathTooLongException Do
     Exit;
   End;
  End;

 Function FindQuickOpenTarget(Const Text : String; CharacterIndex : Integer; Const Directory, GitSdkRoot : String; Out Target : TQuickOpenTarget) : Boolean;
  Var
   Match        : TMatch;
   Candidate    : String;
   FunctionName : String;
   Line         : String;
   Lines        : TStringList;
   Source       : TFileStream;
   i            : Integer;

   Function Accept(Const Value : String; LineNumber, ColumnNumber : Integer) : Boolean;
    Begin
     Result := ResolveFile(Value, Directory, GitSdkRoot, Target.FileName);
     If Result Then
      Begin
       Target.LineNumber   := Max(1, LineNumber);
       Target.ColumnNumber := Max(1, ColumnNumber);
      End;
    End;

   Function UnderPointer(Const m : TMatch) : Boolean;
    Begin
     Result := (CharacterIndex < 0) Or ((CharacterIndex >= m.Index - 1) And (CharacterIndex < m.Index - 1 + m.Length));
    End;

  Begin
   Target := Default(TQuickOpenTarget);
   Result := False;
   If (Text = '') Or (Length(Text) > 8192) Then
    Exit;
   If (CharacterIndex < 0) And Accept(Text, 1, 1) Then
    Exit(True);
   For Match In TRegEx.Matches(Text, 'File\s+"([^"]+)",\s*line\s+(\d+)') Do
    If UnderPointer(Match) And Accept(GroupValue(Match, 1), StrToIntDef(GroupValue(Match, 2), 1), 1) Then
     Exit(True);
    // Delphi/MSVC diagnostics, including unquoted Windows paths containing spaces.
   For Match In TRegEx.Matches(Text, '(?:^|\s)([^<>"\r\n]+?)\((\d+)(?:,(\d+))?\)') Do
    If UnderPointer(Match) And Accept(Trim(GroupValue(Match, 1)), StrToIntDef(GroupValue(Match, 2), 1),
    StrToIntDef(GroupValue(Match, 3), 1)) Then
     Exit(True);
    // GCC and selected file:line[:column] values; a drive colon remains part of the path.
   For Match In TRegEx.Matches(Text, '^\s*(?:ERROR in\s+)?(.+?):(\d+)(?::(\d+))?') Do
    If UnderPointer(Match) And Accept(Trim(GroupValue(Match, 1)), StrToIntDef(GroupValue(Match, 2), 1),
    StrToIntDef(GroupValue(Match, 3), 1)) Then
     Exit(True);
   For Match In TRegEx.Matches(Text, '"([^"]+)":(\d+)(?::(\d+))?|([^\s<>"'']+?):(\d+)(?::(\d+))?') Do
    If UnderPointer(Match) Then
     Begin
      If GroupValue(Match, 1) <> '' Then
       Begin
        Candidate := GroupValue(Match, 1);
        i         := 2;
       End
      Else
       Begin
        Candidate := GroupValue(Match, 4);
        i         := 5;
       End;
      If Accept(Candidate, StrToIntDef(GroupValue(Match, i), 1), StrToIntDef(GroupValue(Match, i + 1), 1)) Then
       Exit(True);
     End;
   For Match In TRegEx.Matches(Text, '([^\s<>"'']+?)::([\w]+(?:::[\w]+)*)') Do
    If UnderPointer(Match) And Accept(GroupValue(Match, 1), 1, 1) Then
     Begin
      FunctionName := GroupValue(Match, 2);
      i            := LastDelimiter(':', FunctionName);
      If i > 0 Then
       Delete(FunctionName, 1, i);
      Source := Nil;
      Lines  := Nil;
      Try
       Try
        Source := TFileStream.Create(Target.FileName, fmOpenRead Or fmShareDenyNone);
        If Source.Size <= 8 * 1024 * 1024 Then
         Begin
          Lines := TStringList.Create;
          Lines.LoadFromStream(Source, TEncoding.UTF8);
          For i := 0 To Lines.Count - 1 Do
           Begin
            Line := TrimLeft(Lines[i]);
            If TRegEx.IsMatch(Line, '^(?:async\s+)?def\s+' + TRegEx.Escape(FunctionName) + '\b') Then
             Begin
              Target.LineNumber := i + 1;
              Break;
             End;
           End;
         End;
       Except
        On E : EStreamError Do
         Begin
         End;
        On E : EOSError Do
         Begin
         End;
       End;
      Finally
       Lines.Free;
       Source.Free;
      End;
      Exit(True);
     End;
   For Match In TRegEx.Matches(Text, '"([^"]+)"|''([^'']+)''|([^\s<>"'']+)') Do
    If UnderPointer(Match) And Accept(Match.Value, 1, 1) Then
     Exit(True);
  End;

 Function QuickOpenCommand(Const Template : String; Const Target : TQuickOpenTarget; Shell : TGuakeShell) : String;
  Var
   i     : Integer;
   Quote : Char;
   Path  : String;
   Value : String;
  Begin
   If Trim(Template) = '' Then
    Raise EArgumentException.Create('The editor command is empty');
   Path := Target.FileName;
   If Shell In [gsBash, gsZsh] Then
    Begin
     Path := StringReplace(Path, '\', '/', [rfReplaceAll]);
     If (Length(Path) > 2) And (Path[2] = ':') Then
      Path := '/' + LowerCase(Path[1]) + Copy(Path, 3, MaxInt);
    End;
   Result := '';
   Quote  := #0;
   i      := 1;
   While i <= Length(Template) Do
    Begin
     If Copy(Template, i, 13) = '%(file_path)s' Then
      Begin
       Value := Path;
       If Quote = #0 Then
        If Shell = gsCmd Then
         Value := QuoteProcessArgument(Value)
        Else If Shell = gsPowerShell Then
         Value := #39 + StringReplace(Value, #39, #39#39, [rfReplaceAll]) + #39
        Else
         Value := #39 + StringReplace(Value, #39, #39'"'#39'"'#39, [rfReplaceAll]) + #39
       Else If Quote = #39 Then
        If Shell = gsPowerShell Then
         Value := StringReplace(Value, #39, #39#39, [rfReplaceAll])
        Else
         Value := StringReplace(Value, #39, #39'"'#39'"'#39, [rfReplaceAll])
       Else If Shell = gsPowerShell Then
        Begin
         Value := StringReplace(Value, '`', '``', [rfReplaceAll]);
         Value := StringReplace(Value, '$', '`$', [rfReplaceAll]);
        End
       Else If Shell In [gsBash, gsZsh] Then
        Begin
         Value := StringReplace(Value, '\', '\\', [rfReplaceAll]);
         Value := StringReplace(Value, '$', '\$', [rfReplaceAll]);
         Value := StringReplace(Value, '`', '\`', [rfReplaceAll]);
        End;
       Result := Result + Value;
       Inc(i, 13);
      End
     Else If Copy(Template, i, 15) = '%(line_number)s' Then
      Begin
       Result := Result + IntToStr(Target.LineNumber);
       Inc(i, 15);
      End
     Else If Copy(Template, i, 17) = '%(column_number)s' Then
      Begin
       Result := Result + IntToStr(Target.ColumnNumber);
       Inc(i, 17);
      End
     Else
      Begin
       If (Template[i] = '"') Or ((Template[i] = #39) And (Shell <> gsCmd)) Then
        If Quote = #0 Then
         Quote := Template[i]
        Else If Quote = Template[i] Then
         Quote := #0;
       Result  := Result + Template[i];
       Inc(i);
      End;
    End;
  End;

End.
