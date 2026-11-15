{$StackFrames On}
/// <summary>Extracts explicitly supported terminal links and builds encoded web search addresses.</summary>
Unit Guake.Links;

Interface

 Function NormalizeTerminalLink(Const Value : String) : String;
 Function TerminalLinkAt(Const Line : String; CharacterIndex : Integer) : String;
 Function WebSearchAddress(Const Text : String; Engine : Integer; Const CustomEngine : String) : String;

Implementation

 Uses
  System.SysUtils, System.RegularExpressions, System.NetEncoding;

 Function NormalizeTerminalLink(Const Value : String) : String;
  Var
   s : String;
  Begin
   s := Trim(Value);
   If Pos('www.', LowerCase(s)) = 1 Then
    s := 'https://' + s;
   If (Pos('https://', LowerCase(s)) = 1) Or (Pos('http://', LowerCase(s)) = 1) Or
   (Pos('ftp://', LowerCase(s)) = 1) Or (Pos('ftps://', LowerCase(s)) = 1) Or
   (Pos('mailto:', LowerCase(s)) = 1) Then
    Result := s
   Else
    Result := '';
   If (Pos(#0, Result) > 0) Or (Pos(#13, Result) > 0) Or (Pos(#10, Result) > 0) Then
    Result := '';
  End;

 Function TerminalLinkAt(Const Line : String; CharacterIndex : Integer) : String;
  Var
   Match : TMatch;
   Value : String;
  Begin
   Result := '';
   For Match In TRegEx.Matches(Line, '(?i)(?:https?://|ftps?://|mailto:|www\.)[^\s<>"'']+') Do
    Begin
     Value := Match.Value;
     While (Value <> '') And CharInSet(Value[Length(Value)], ['.', ',', ';', '!', '?', ')', ']', '}']) Do
      Delete(Value, Length(Value), 1);
     If (CharacterIndex >= Match.Index - 1) And (CharacterIndex < Match.Index - 1 + Length(Value)) Then
      Exit(NormalizeTerminalLink(Value));
    End;
  End;

 Function WebSearchAddress(Const Text : String; Engine : Integer; Const CustomEngine : String) : String;
  Var
   Query : String;
   Base  : String;
  Begin
   Result := '';
   If Trim(Text) = '' Then
    Exit;
   Query := TNetEncoding.URL.Encode(Text);
   Case Engine Of
    1 : Base := 'https://duckduckgo.com/?q=';
    2 : Base := 'https://www.bing.com/search?q=';
    3 : Base := 'https://www.yandex.com/search?text=';
    4 : Base := 'https://neeva.com/search?q=';
    5 : Base := CustomEngine;
   Else Base := 'https://www.google.com/search?q=';
   End;
   If Pos('%s', Base) > 0 Then
    Base := StringReplace(Base, '%s', Query, [rfReplaceAll])
   Else
    Base  := Base + Query;
   Result := NormalizeTerminalLink(Base);
  End;

End.
