{$StackFrames On}
/// <summary>Uses the Windows ICU character-break engine for extended grapheme clusters and terminal cell widths.</summary>
Unit Guake.Unicode;

Interface

 Function JoinsGrapheme(Const Previous, Following : String) : Boolean;
 Function GraphemeWidth(Const Value : String) : Integer;
 Function UnicodeBreakEngineAvailable : Boolean;

Implementation

 Uses
  Winapi.Windows, System.SysUtils;

 Type
  TBreakOpen = Function(Kind : Integer; Locale : PAnsiChar; Text : PWideChar; Length : Integer; Var Status : Integer) : Pointer;

  Cdecl;

  TBreakBoundary = Function(Iterator : Pointer; Offset : Integer) : ShortInt;

  Cdecl;

  TBreakClose = Procedure(Iterator : Pointer);

  Cdecl;

  TIntProperty = Function(Code, PropertyId : Integer) : Integer;

  Cdecl;

  TBinaryProperty = Function(Code, PropertyId : Integer) : ShortInt;

  Cdecl;

 Var
  LibraryHandle  : HMODULE;
  BreakOpen      : TBreakOpen;
  BreakBoundary  : TBreakBoundary;
  BreakClose     : TBreakClose;
  IntProperty    : TIntProperty;
  BinaryProperty : TBinaryProperty;

 Function UnicodeBreakEngineAvailable : Boolean;
  Begin
   Result := Assigned(BreakOpen) And Assigned(BreakBoundary) And Assigned(BreakClose);
  End;

 Function Scalar(Const Text : String; Var Index : Integer) : Cardinal;
  Var
   First : Cardinal;
  Begin
   First := Ord(Text[Index]);
   Inc(Index);
   Result := First;
   If (First >= $D800) And (First <= $DBFF) And (Index <= Length(Text)) And
   (Ord(Text[Index]) >= $DC00) And (Ord(Text[Index]) <= $DFFF) Then
    Begin
     Result := $10000 + (First - $D800) * $400 + Ord(Text[Index]) - $DC00;
     Inc(Index);
    End;
  End;

 Function JoinsGrapheme(Const Previous, Following : String) : Boolean;
  Var
   Iterator : Pointer;
   Text     : String;
   Status   : Integer;
   Code     : Cardinal;
   Index    : Integer;
  Begin
   Result := False;
   If (Previous = '') Or (Following = '') Or (Length(Previous) > 4096) Then
    Exit;
   If (Ord(Previous[Length(Previous)]) < 127) And (Ord(Following[1]) < 127) Then
    Exit;
   Text := Previous + Following;
   If UnicodeBreakEngineAvailable Then
    Begin
     Status   := 0;
     Iterator := BreakOpen(0, Nil, PWideChar(Text), Length(Text), Status);
     If (Iterator <> Nil) And (Status <= 0) Then
      Begin
       Try
        Result := BreakBoundary(Iterator, Length(Previous)) = 0;
       Finally
        BreakClose(Iterator);
       End;
       Exit;
      End;
     If Iterator <> Nil Then
      BreakClose(Iterator);
    End;
   // Older Windows without ICU retains combining marks; full UAX #29 requires the system break engine.
   Index  := 1;
   Code   := Scalar(Following, Index);
   Result := ((Code >= $0300) And (Code <= $036F)) Or ((Code >= $1AB0) And (Code <= $1AFF)) Or
   ((Code >= $FE00) And (Code <= $FE0F)) Or (Code = $200D) Or (Previous[Length(Previous)] = #$200D);
  End;

 Function GraphemeWidth(Const Value : String) : Integer;
  Var
   Index            : Integer;
   Width            : Integer;
   Code             : Cardinal;
   Emoji            : Boolean;
   TextPresentation : Boolean;
  Begin
   Result           := 1;
   Emoji            := False;
   TextPresentation := False;
   Index            := 1;
   If (Length(Value) = 1) And (Ord(Value[1]) < 127) Then
    Exit;
   While Index <= Length(Value) Do
    Begin
     Code := Scalar(Value, Index);
     If Code = $FE0F Then
      Emoji := True;
     If Code = $FE0E Then
      TextPresentation := True;
     If Code = $20E3 Then
      Emoji := True;
     If Assigned(IntProperty) Then
      Begin
       Width := IntProperty(Code, $1004);
       If (Width = 3) Or (Width = 5) Then
        Result := 2;
      End
     Else If ((Code >= $1100) And (Code <= $115F)) Or ((Code >= $2E80) And (Code <= $A4CF)) Or
     ((Code >= $AC00) And (Code <= $D7A3)) Or ((Code >= $FF01) And (Code <= $FF60)) Or (Code >= $1F000) Then
      Result := 2;
     If Assigned(BinaryProperty) And (BinaryProperty(Code, 58) <> 0) Then
      Emoji := True;
    End;
   If Emoji And Not TextPresentation Then
    Result := 2;
  End;

 Procedure LoadSystemICU;
  Var
   Directory : Array[0..MAX_PATH] Of Char;
  Begin
   GetSystemDirectory(Directory, Length(Directory));
   LibraryHandle := LoadLibrary(PChar(IncludeTrailingPathDelimiter(Directory) + 'icu.dll'));
   If LibraryHandle = 0 Then
    Exit;
   BreakOpen      := TBreakOpen(GetProcAddress(LibraryHandle, 'ubrk_open'));
   BreakBoundary  := TBreakBoundary(GetProcAddress(LibraryHandle, 'ubrk_isBoundary'));
   BreakClose     := TBreakClose(GetProcAddress(LibraryHandle, 'ubrk_close'));
   IntProperty    := TIntProperty(GetProcAddress(LibraryHandle, 'u_getIntPropertyValue'));
   BinaryProperty := TBinaryProperty(GetProcAddress(LibraryHandle, 'u_hasBinaryProperty'));
  End;

Initialization
 LoadSystemICU;

Finalization
 If LibraryHandle <> 0 Then
  FreeLibrary(LibraryHandle);

End.
