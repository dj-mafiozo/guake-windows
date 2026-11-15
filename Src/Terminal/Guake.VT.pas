{$StackFrames On}
/// <summary>Incremental UTF-8 and VT parsing into a Unicode screen, alternate buffer and bounded scrollback.</summary>
Unit Guake.VT;

Interface

 Uses
  System.SysUtils, System.Classes, System.Generics.Collections;

 Type
  TTerminalCell = Record
   Text         : String;
   Hyperlink    : String;
   Foreground   : Integer;
   Background   : Integer;
   Bold         : Boolean;
   Italic       : Boolean;
   Underline    : Boolean;
   Inverse      : Boolean;
   Continuation : Boolean;
  End;

  TTerminalLine = TArray<TTerminalCell>;

  TTerminalScreen = TArray<TTerminalLine>;

  TVTState = (vsGround, vsEscape, vsCSI, vsOSC, vsOSCEscape, vsIgnore, vsIgnoreEscape, vsCharset);

  TTerminalBuffer = Class
   Private
    fScreen            : TTerminalScreen;
    fPrimary           : TTerminalScreen;
    fHistory           : TList<TTerminalLine>;
    fColumns           : Integer;
    fRows              : Integer;
    fX                 : Integer;
    fY                 : Integer;
    fSavedX            : Integer;
    fSavedY            : Integer;
    fPrimaryX          : Integer;
    fPrimaryY          : Integer;
    fTop               : Integer;
    fBottom            : Integer;
    fHistoryLimit      : Integer;
    fAttr              : TTerminalCell;
    fState             : TVTState;
    fSequence          : String;
    fTitle             : String;
    fHyperlink         : String;
    fDirectory         : String;
    fResponses         : String;
    fUtf8              : Cardinal;
    fRemaining         : Integer;
    fMinimum           : Cardinal;
    fWrapPending       : Boolean;
    fAutoWrap          : Boolean;
    fOrigin            : Boolean;
    fInsert            : Boolean;
    fAlternate         : Boolean;
    fCursorVisible     : Boolean;
    fApplicationCursor : Boolean;
    fBracketedPaste    : Boolean;
    fMouseMode         : Integer;
    fSGRMouse          : Boolean;
    fRevision          : Int64;
    Function  Blank                          : TTerminalCell;
    Procedure ClearLine     (Var Line : TTerminalLine; First, Last : Integer);
    Procedure AllocateScreen(Var Screen : TTerminalScreen; Columns, Rows : Integer);
    Procedure ProcessCode   (Code : Cardinal);
    Procedure PutCode       (Code : Cardinal);
    Procedure LineFeed;
    Procedure Scroll        (Up : Boolean; Count : Integer);
    Procedure ExecuteCSI    (Final : Char);
    Procedure ExecuteOSC;
    Procedure SwitchScreen  (Alternate : Boolean; SaveCursor : Boolean);
    Function  GetCell       (x, y : Integer) : TTerminalCell;
    Function  GetTotalLines                  : Integer;
   Public
    /// <summary>Initializes this service and acquires the resources whose lifetime it owns.</summary>
    Constructor Create(Columns, Rows : Integer; HistoryLimit : Integer = 1000);
    /// <summary>Releases owned resources; borrowed settings and view references are not freed.</summary>
    Destructor  Destroy; Override;
    /// <summary>Consumes arbitrary UTF-8 byte fragments while preserving decoder and VT parser state.</summary>
    Procedure   Feed(Const Bytes : TBytes);
    /// <summary>Encodes a Unicode string and feeds it through the same incremental VT parser.</summary>
    Procedure FeedText(Const Text : String);
    Procedure Resize  (Columns, Rows : Integer);
    Procedure Reset;
    /// <summary>Applies the configured scrollback limit; a negative value keeps unlimited history.</summary>
    Procedure   SetHistoryLimit(Value : Integer);
    /// <summary>Returns and clears replies to device-status and cursor-position queries.</summary>
    Function    TakeResponses : String;
    /// <summary>Returns one history/screen line without trailing blank cells.</summary>
    Function LineText(Index : Integer) : String;
    Function Text                      : String;
    /// <summary>Returns inclusive selected cells as Unicode text, excluding continuation cells.</summary>
    Function    RangeText(StartX, StartY, EndX, EndY : Integer) : String;
    Property Cell[x, y : Integer] : TTerminalCell Read GetCell;
    Property Columns              : Integer Read fColumns;
    Property Rows                 : Integer Read fRows;
    Property CursorX              : Integer Read fX;
    Property CursorY              : Integer Read fY;
    Property TotalLines           : Integer Read GetTotalLines;
    Property CursorVisible        : Boolean Read fCursorVisible;
    Property AlternateScreen      : Boolean Read fAlternate;
    Property ApplicationCursor    : Boolean Read fApplicationCursor;
    Property BracketedPaste       : Boolean Read fBracketedPaste;
    Property MouseMode            : Integer Read fMouseMode;
    Property SGRMouse             : Boolean Read fSGRMouse;
    Property Title                : String Read fTitle;
    Property DirectoryURI         : String Read fDirectory;
    Property Revision             : Int64 Read fRevision;
  End;

Implementation

 Uses
  System.Math, System.StrUtils;

 Function TTerminalBuffer.Blank : TTerminalCell;
  Begin
   Result              := fAttr;
   Result.Text         := ' ';
   Result.Continuation := False;
  End;

 Procedure TTerminalBuffer.ClearLine(Var Line : TTerminalLine; First, Last : Integer);
  Var
   i : Integer;
  Begin
   For i    := Max(0, First) To Min(High(Line), Last) Do
    Line[i] := Blank;
  End;

 Procedure TTerminalBuffer.AllocateScreen(Var Screen : TTerminalScreen; Columns, Rows : Integer);
  Var
   y : Integer;
  Begin
   Screen := Nil;
   SetLength(Screen, Rows);
   For y := 0 To Rows - 1 Do
    Begin
     SetLength(Screen[y], Columns);
     ClearLine(Screen[y], 0, Columns - 1);
    End;
  End;

 Constructor TTerminalBuffer.Create(Columns, Rows, HistoryLimit : Integer);
  Begin
   Inherited Create;
   fHistory      := TList<TTerminalLine>.Create;
   fHistoryLimit := HistoryLimit;
   fColumns      := Columns;
   fRows         := Rows;
   If (Columns < 1) Or (Rows < 1) Then
    Raise EArgumentOutOfRangeException.Create('Terminal size');
   Reset;
  End;

 Destructor TTerminalBuffer.Destroy;
  Begin
   fHistory.Free;
   Inherited;
  End;

 Procedure TTerminalBuffer.Reset;
  Begin
   fHyperlink         := '';
   fAttr              := Default(TTerminalCell);
   fAttr.Foreground   := -1;
   fAttr.Background   := -2;
   fX                 := 0;
   fY                 := 0;
   fSavedX            := 0;
   fSavedY            := 0;
   fTop               := 0;
   fBottom            := fRows - 1;
   fPrimary           := Nil;
   fAlternate         := False;
   fCursorVisible     := True;
   fApplicationCursor := False;
   fBracketedPaste    := False;
   fMouseMode         := 0;
   fSGRMouse          := False;
   fAutoWrap          := True;
   fWrapPending       := False;
   fOrigin            := False;
   fInsert            := False;
   fState             := vsGround;
   fSequence          := '';
   fRemaining         := 0;
   fHistory.Clear;
   AllocateScreen(fScreen, fColumns, fRows);
   Inc(fRevision);
  End;

 Procedure TTerminalBuffer.SetHistoryLimit(Value : Integer);
  Begin
   fHistoryLimit := Value;
   If Value >= 0 Then
    While fHistory.Count > Value Do
     fHistory.Delete(0);
  End;

 Procedure TTerminalBuffer.Scroll(Up : Boolean; Count : Integer);
  Var
   i, n, h : Integer;
   Line    : TTerminalLine;
  Begin
   h     := fBottom - fTop + 1;
   For n := 1 To Min(Max(Count, 0), h) Do
    If Up Then
     Begin
      If Not fAlternate And (fTop = 0) And (fBottom = fRows - 1) And (fHistoryLimit <> 0) Then
       Begin
        fHistory.Add(Copy(fScreen[fTop]));
        If fHistoryLimit >= 0 Then
         While fHistory.Count > fHistoryLimit Do
          fHistory.Delete(0);
       End;
      Line             := fScreen[fTop];
      For i            := fTop To fBottom - 1 Do
       fScreen[i]      := fScreen[i + 1];
      fScreen[fBottom] := Line;
      ClearLine(fScreen[fBottom], 0, fColumns - 1);
     End
    Else
     Begin
      Line          := fScreen[fBottom];
      For i         := fBottom Downto fTop + 1 Do
       fScreen[i]   := fScreen[i - 1];
      fScreen[fTop] := Line;
      ClearLine(fScreen[fTop], 0, fColumns - 1);
     End;
  End;

 Procedure TTerminalBuffer.LineFeed;
  Begin
   fWrapPending := False;
   If fY = fBottom Then
    Scroll(True, 1)
   Else
    fY := Min(fRows - 1, fY + 1);
  End;

 Function CodeText(Code : Cardinal) : String;
  Begin
   If Code <= $FFFF Then
    Result := Char(Code)
   Else
    Begin
     Dec(Code, $10000);
     Result := Char($D800 + (Code Shr 10)) + Char($DC00 + (Code And $3FF));
    End;
  End;

 Function Combining(Code : Cardinal) : Boolean;
  Begin
   Result := ((Code >= $0300) And (Code <= $036F)) Or ((Code >= $1AB0) And (Code <= $1AFF)) Or ((Code >= $1DC0) And (Code <= $1DFF)) Or ((Code >= $FE00) And (Code <= $FE0F)) Or ((Code >= $FE20) And (Code <= $FE2F)) Or (Code = $200D);
  End;

 Function WideCode(Code : Cardinal) : Boolean;
  Begin
   Result := ((Code >= $1100) And (Code <= $115F)) Or ((Code >= $2E80) And (Code <= $A4CF)) Or ((Code >= $AC00) And (Code <= $D7A3)) Or ((Code >= $F900) And (Code <= $FAFF)) Or ((Code >= $FE10) And (Code <= $FE6F)) Or ((Code >= $FF01) And (Code <= $FF60)) Or ((Code >= $1F300) And (Code <= $1FAFF)) Or ((Code >= $20000) And (Code <= $3FFFD));
  End;

 Procedure TTerminalBuffer.PutCode(Code : Cardinal);
  Var
   w, i, Previous : Integer;
  Begin
   If Combining(Code) Then
    Begin
     Previous := fX - 1;
     If fWrapPending Then
      Previous := fX;
     If (Previous >= 0) And fScreen[fY][Previous].Continuation Then
      Dec(Previous);
     If Previous >= 0 Then
      fScreen[fY][Previous].Text := fScreen[fY][Previous].Text + CodeText(Code);
     Exit;
    End;
   w := 1;
   If WideCode(Code) Then
    w := 2;
   If w > fColumns Then
    w := 1;
   If fWrapPending Or ((w = 2) And (fX = fColumns - 1)) Then
    If fAutoWrap Then
     Begin
      fX := 0;
      LineFeed;
     End;
   fWrapPending := False;
   If fInsert Then
    For i           := fColumns - 1 Downto fX + w Do
     fScreen[fY][i] := fScreen[fY][i - w];
   If fScreen[fY][fX].Continuation And (fX > 0) Then
    fScreen[fY][fX - 1] := Blank;
   If (fX < fColumns - 1) And fScreen[fY][fX + 1].Continuation Then
    fScreen[fY][fX + 1]         := Blank;
   fScreen[fY][fX]              := fAttr;
   fScreen[fY][fX].Text         := CodeText(Code);
   fScreen[fY][fX].Hyperlink    := fHyperlink;
   fScreen[fY][fX].Continuation := False;
   If (w = 2) And (fX + 1 < fColumns) Then
    Begin
     fScreen[fY][fX + 1]              := fAttr;
     fScreen[fY][fX + 1].Text         := '';
     fScreen[fY][fX + 1].Continuation := True;
    End;
   Inc(fX, w);
   If fX >= fColumns Then
    Begin
     fX           := fColumns - 1;
     fWrapPending := fAutoWrap;
    End;
  End;

 Procedure TTerminalBuffer.SwitchScreen(Alternate, SaveCursor : Boolean);
  Begin
   If Alternate = fAlternate Then
    Exit;
   If Alternate Then
    Begin
     fPrimary  := fScreen;
     fPrimaryX := fX;
     fPrimaryY := fY;
     AllocateScreen(fScreen, fColumns, fRows);
     fX := 0;
     fY := 0;
    End
   Else
    Begin
     fScreen  := fPrimary;
     fPrimary := Nil;
     fX       := EnsureRange(fPrimaryX, 0, fColumns - 1);
     fY       := EnsureRange(fPrimaryY, 0, fRows - 1);
    End;
   fAlternate   := Alternate;
   fTop         := 0;
   fBottom      := fRows - 1;
   fWrapPending := False;
  End;

 Procedure TTerminalBuffer.ExecuteOSC;
  Var
   P              : Integer;
   Command, Value : String;
  Begin
   P := Pos(';', fSequence);
   If P = 0 Then
    Exit;
   Command := Copy(fSequence, 1, P - 1);
   Value   := Copy(fSequence, P + 1, MaxInt);
   If (Command = '0') Or (Command = '2') Then
    fTitle := Value
   Else If Command = '7' Then
    fDirectory := Value
   Else If Command = '8' Then
    Begin
     P := Pos(';', Value);
     If P > 0 Then
      fHyperlink := Copy(Value, P + 1, MaxInt);
    End;
  End;

 Procedure TTerminalBuffer.ExecuteCSI(Final : Char);
  Var
   Parts                                                  : TArray<String>;
   Params                                                 : TArray<Integer>;
   PrivateMode                                            : Boolean;
   i, n, a, b, x, y, OldTop, OldBottom, r, g, Blue, Color : Integer;

   Function P(Index, Default : Integer) : Integer;
    Begin
     If (Index >= Length(Params)) Or (Params[Index] = 0) Then
      Result := Default
     Else
      Result := Params[Index];
    End;

   Procedure MoveCursor(NewX, NewY : Integer);
    Begin
     fX := EnsureRange(NewX, 0, fColumns - 1);
     If fOrigin Then
      fY := EnsureRange(NewY, fTop, fBottom)
     Else
      fY := EnsureRange(NewY, 0, fRows - 1);
    End;

  Begin
   PrivateMode := Copy(fSequence, 1, 1) = '?';
   If PrivateMode Or (Copy(fSequence, 1, 1) = '>') Then
    Delete(fSequence, 1, 1);
   Parts := StringReplace(fSequence, ':', ';', [rfReplaceAll]).Split([';']);
   SetLength(Params, Max(1, Length(Parts)));
   For i      := 0 To High(Parts) Do
    Params[i] := StrToIntDef(Parts[i], 0);
   If Not CharInSet(Final, ['m', 'h', 'l']) Then
    fWrapPending := False;
   n             := Min(P(0, 1), Max(fColumns, fRows));
   Case Final Of
    'A' :
     MoveCursor(fX, fY - n);
    'B', 'e' :
     MoveCursor(fX, fY + n);
    'C', 'a' :
     MoveCursor(fX + n, fY);
    'D' :
     MoveCursor(fX - n, fY);
    'E' :
     MoveCursor(0, fY + n);
    'F' :
     MoveCursor(0, fY - n);
    'G', '`' :
     MoveCursor(P(0, 1) - 1, fY);
    'd' :
     MoveCursor(fX, P(0, 1) - 1 + IfThen(fOrigin, fTop, 0));
    'H', 'f' :
     MoveCursor(P(1, 1) - 1, P(0, 1) - 1 + IfThen(fOrigin, fTop, 0));
    'J' :
     Case P(0, 0) Of
      0 :
       Begin
        ClearLine(fScreen[fY], fX, fColumns - 1);
        For y := fY + 1 To fRows - 1 Do
         ClearLine(fScreen[y], 0, fColumns - 1);
       End;
      1 :
       Begin
        For y := 0 To fY - 1 Do
         ClearLine(fScreen[y], 0, fColumns - 1);
        ClearLine(fScreen[fY], 0, fX);
       End;
      2 :
       For y := 0 To fRows - 1 Do
        ClearLine(fScreen[y], 0, fColumns - 1);
      3 :
       fHistory.Clear;
     End;
    'K' :
     Case P(0, 0) Of
      0 : ClearLine(fScreen[fY], fX, fColumns - 1);
      1 : ClearLine(fScreen[fY], 0, fX);
      2 : ClearLine(fScreen[fY], 0, fColumns - 1);
     End;
    '@' :
     Begin
      For x           := fColumns - 1 Downto fX + n Do
       fScreen[fY][x] := fScreen[fY][x - n];
      ClearLine(fScreen[fY], fX, fX + n - 1);
     End;
    'P' :
     Begin
      For x           := fX To fColumns - n - 1 Do
       fScreen[fY][x] := fScreen[fY][x + n];
      ClearLine(fScreen[fY], Max(fX, fColumns - n), fColumns - 1);
     End;
    'X' :
     ClearLine(fScreen[fY], fX, fX + n - 1);
    'L', 'M' :
     If (fY >= fTop) And (fY <= fBottom) Then
      Begin
       OldTop := fTop;
       fTop   := fY;
       Scroll(Final = 'M', n);
       fTop := OldTop;
      End;
    'S' :
     Scroll(True, n);
    'T' :
     Scroll(False, n);
    'r' :
     Begin
      a := P(0, 1) - 1;
      b := P(1, fRows) - 1;
      If (a >= 0) And (b < fRows) And (a < b) Then
       Begin
        fTop    := a;
        fBottom := b;
        MoveCursor(0, IfThen(fOrigin, fTop, 0));
       End;
     End;
    's' :
     Begin
      fSavedX := fX;
      fSavedY := fY;
     End;
    'u' :
     MoveCursor(fSavedX, fSavedY);
    'h', 'l' :
     For i := 0 To High(Params) Do
      If PrivateMode Then
       Case Params[i] Of
        1 :
         fApplicationCursor := Final = 'h';
        6 :
         Begin
          fOrigin := Final = 'h';
          MoveCursor(0, IfThen(fOrigin, fTop, 0));
         End;
        7 :
         fAutoWrap := Final = 'h';
        25 :
         fCursorVisible := Final = 'h';
        47, 1047, 1049 :
         SwitchScreen(Final = 'h', Params[i] = 1049);
        1000, 1002, 1003 :
         If Final = 'h' Then
          fMouseMode := Params[i]
         Else
          fMouseMode := 0;
        1006 :
         fSGRMouse := Final = 'h';
        2004 :
         fBracketedPaste := Final = 'h';
       End
      Else If Params[i] = 4 Then
       fInsert := Final = 'h';
    'n' :
     If P(0, 0) = 6 Then
      fResponses := fResponses + Format(#27'[%d;%dR', [fY + 1, fX + 1])
     Else If P(0, 0) = 5 Then
      fResponses := fResponses + #27'[0n';
    'c' :
     fResponses := fResponses + #27'[?1;2c';
    'm' :
     Begin
      i := 0;
      While i < Length(Params) Do
       Begin
        a := Params[i];
        Case a Of
         0 :
          Begin
           fAttr            := Default(TTerminalCell);
           fAttr.Foreground := -1;
           fAttr.Background := -2;
          End;
         1 :
          fAttr.Bold := True;
         3 :
          fAttr.Italic := True;
         4, 21 :
          fAttr.Underline := True;
         7 :
          fAttr.Inverse := True;
         22 :
          fAttr.Bold := False;
         23 :
          fAttr.Italic := False;
         24 :
          fAttr.Underline := False;
         27 :
          fAttr.Inverse := False;
         30..37 :
          fAttr.Foreground := a - 30;
         40..47 :
          fAttr.Background := a - 40;
         90..97 :
          fAttr.Foreground := a - 90 + 8;
         100..107 :
          fAttr.Background := a - 100 + 8;
         39 :
          fAttr.Foreground := -1;
         49 :
          fAttr.Background := -2;
         38, 48 :
          Begin
           Color := -1;
           If (i + 2 < Length(Params)) And (Params[i + 1] = 5) Then
            Begin
             Color := EnsureRange(Params[i + 2], 0, 255);
             Inc(i, 2);
            End
           Else If (i + 4 < Length(Params)) And (Params[i + 1] = 2) Then
            Begin
             r     := EnsureRange(Params[i + 2], 0, 255);
             g     := EnsureRange(Params[i + 3], 0, 255);
             Blue  := EnsureRange(Params[i + 4], 0, 255);
             Color := $01000000 Or r Or (g Shl 8) Or (Blue Shl 16);
             Inc(i, 4);
            End;
           If Color <> -1 Then
            If a = 38 Then
             fAttr.Foreground := Color
            Else
             fAttr.Background := Color;
          End;
        End;
        Inc(i);
       End;
     End;
   End;
  End;

 Procedure TTerminalBuffer.ProcessCode(Code : Cardinal);
  Begin
   If Code = $1B Then
    Begin
     Case fState Of
      vsOSC    : fState := vsOSCEscape;
      vsIgnore : fState := vsIgnoreEscape;
     Else fState := vsEscape;
     End;
     Exit;
    End;
   Case fState Of
    vsGround :
     Case Code Of
      0, 7 :
       ;
      8 :
       Begin
        fX           := Max(0, fX - 1);
        fWrapPending := False;
       End;
      9 :
       Begin
        fX           := Min(fColumns - 1, ((fX Div 8) + 1) * 8);
        fWrapPending := False;
       End;
      10, 11, 12 :
       LineFeed;
      13 :
       Begin
        fX           := 0;
        fWrapPending := False;
       End;
      14, 15 :
       ;
     Else
       If Code >= 32 Then
        PutCode(Code);
     End;
    vsEscape :
     Begin
      fState := vsGround;
      Case Code Of
       Ord('[') :
        Begin
         fSequence := '';
         fState    := vsCSI;
        End;
       Ord(']') :
        Begin
         fSequence := '';
         fState    := vsOSC;
        End;
       Ord('P'), Ord('^'), Ord('_') :
        fState := vsIgnore;
       Ord('('), Ord(')'), Ord('*'), Ord('+') :
        fState := vsCharset;
       Ord('7') :
        Begin
         fSavedX := fX;
         fSavedY := fY;
        End;
       Ord('8') :
        Begin
         fX := EnsureRange(fSavedX, 0, fColumns - 1);
         fY := EnsureRange(fSavedY, 0, fRows - 1);
        End;
       Ord('D') :
        LineFeed;
       Ord('E') :
        Begin
         fX := 0;
         LineFeed;
        End;
       Ord('M') :
        If fY = fTop Then
         Scroll(False, 1)
        Else
         fY := Max(0, fY - 1);
       Ord('c') :
        Reset;
       Ord('Z') :
        fResponses := fResponses + #27'[?1;2c';
      End;
     End;
    vsCSI :
     If (Code >= $40) And (Code <= $7E) Then
      Begin
       ExecuteCSI(Char(Code));
       fState := vsGround;
      End
     Else If (Code >= $20) And (Code <= $3F) And (Length(fSequence) < 256) Then
      fSequence := fSequence + Char(Code)
     Else If (Code = 24) Or (Code = 26) Then
      fState := vsGround;
    vsOSC :
     If Code = 7 Then
      Begin
       ExecuteOSC;
       fState := vsGround;
      End
     Else If Length(fSequence) < 4096 Then
      fSequence := fSequence + CodeText(Code);
    vsOSCEscape :
     Begin
      If Code = Ord('\') Then
       Begin
        ExecuteOSC;
        fState := vsGround;
       End
      Else
       fState := vsOSC;
     End;
    vsIgnore :
     ;
    vsIgnoreEscape :
     If Code = Ord('\') Then
      fState := vsGround
     Else
      fState := vsIgnore;
    vsCharset :
     fState := vsGround;
   End;
  End;

 Procedure TTerminalBuffer.Feed(Const Bytes : TBytes);
  Var
   b : Byte;

   Procedure ByteValue(Value : Byte);
    Begin
     If fRemaining > 0 Then
      Begin
       If (Value And $C0) = $80 Then
        Begin
         fUtf8 := (fUtf8 Shl 6) Or (Value And $3F);
         Dec(fRemaining);
         If fRemaining = 0 Then
          If (fUtf8 < fMinimum) Or (fUtf8 > $10FFFF) Or ((fUtf8 >= $D800) And (fUtf8 <= $DFFF)) Then
           ProcessCode($FFFD)
          Else
           ProcessCode(fUtf8);
         Exit;
        End;
       fRemaining := 0;
       ProcessCode($FFFD);
      End;
     If Value < $80 Then
      ProcessCode(Value)
     Else If (Value >= $C2) And (Value <= $DF) Then
      Begin
       fUtf8      := Value And $1F;
       fRemaining := 1;
       fMinimum   := $80;
      End
     Else If (Value >= $E0) And (Value <= $EF) Then
      Begin
       fUtf8      := Value And $0F;
       fRemaining := 2;
       fMinimum   := $800;
      End
     Else If (Value >= $F0) And (Value <= $F4) Then
      Begin
       fUtf8      := Value And $07;
       fRemaining := 3;
       fMinimum   := $10000;
      End
     Else
      ProcessCode($FFFD);
    End;

  Begin
   For b In Bytes Do
    ByteValue(b);
   If Length(Bytes) > 0 Then
    Inc(fRevision);
  End;

 Procedure TTerminalBuffer.FeedText(Const Text : String);
  Begin
   Feed(TEncoding.UTF8.GetBytes(Text));
  End;

 Procedure TTerminalBuffer.Resize(Columns, Rows : Integer);
  Var
   NewScreen : TTerminalScreen;
   x, y      : Integer;

   Procedure Change(Var Screen : TTerminalScreen);
    Var
     x, y : Integer;
    Begin
     AllocateScreen(NewScreen, Columns, Rows);
     For y             := 0 To Min(High(Screen), Rows - 1) Do
      For x            := 0 To Min(High(Screen[y]), Columns - 1) Do
       NewScreen[y][x] := Screen[y][x];
     Screen            := NewScreen;
     NewScreen         := Nil;
    End;

  Begin
   If (Columns < 1) Or (Rows < 1) Or (Columns > 32767) Or (Rows > 32767) Then
    Raise EArgumentOutOfRangeException.Create('Terminal size');
   If (Columns = fColumns) And (Rows = fRows) Then
    Exit;
   Change(fScreen);
   If fAlternate Then
    Change(fPrimary);
   fColumns     := Columns;
   fRows        := Rows;
   fX           := Min(fX, Columns - 1);
   fY           := Min(fY, Rows - 1);
   fTop         := 0;
   fBottom      := Rows - 1;
   fWrapPending := False;
   Inc(fRevision);
  End;

 Function TTerminalBuffer.GetTotalLines : Integer;
  Begin
   Result := fRows;
   If Not fAlternate Then
    Inc(Result, fHistory.Count);
  End;

 Function TTerminalBuffer.GetCell(x, y : Integer) : TTerminalCell;
  Begin
   Result := Blank;
   If (y < 0) Or (y >= TotalLines) Or (x < 0) Then
    Exit;
   If Not fAlternate And (y < fHistory.Count) Then
    Begin
     If x < Length(fHistory[y]) Then
      Result := fHistory[y][x];
     Exit;
    End;
   If Not fAlternate Then
    Dec(y, fHistory.Count);
   If x < fColumns Then
    Result := fScreen[y][x];
  End;

 Function TTerminalBuffer.LineText(Index : Integer) : String;
  Var
   x : Integer;
   c : TTerminalCell;
  Begin
   Result := '';
   For x  := 0 To fColumns - 1 Do
    Begin
     c := GetCell(x, Index);
     If Not c.Continuation Then
      Result := Result + c.Text;
    End;
   Result := TrimRight(Result);
  End;

 Function TTerminalBuffer.RangeText(StartX, StartY, EndX, EndY : Integer) : String;
  Var
   x, y, Temp : Integer;
   c          : TTerminalCell;
   s          : String;
  Begin
   Result := '';
   If (StartY > EndY) Or ((StartY = EndY) And (StartX > EndX)) Then
    Begin
     Temp   := StartX;
     StartX := EndX;
     EndX   := Temp;
     Temp   := StartY;
     StartY := EndY;
     EndY   := Temp;
    End;
   StartY := EnsureRange(StartY, 0, TotalLines - 1);
   EndY   := EnsureRange(EndY, 0, TotalLines - 1);
   For y  := StartY To EndY Do
    Begin
     s     := '';
     For x := 0 To fColumns - 1 Do
      If ((y > StartY) Or (x >= StartX)) And ((y < EndY) Or (x <= EndX)) Then
       Begin
        c := GetCell(x, y);
        If Not c.Continuation Then
         s := s + c.Text;
       End;
     If y > StartY Then
      Result := Result + sLineBreak;
     Result  := Result + TrimRight(s);
    End;
  End;

 Function TTerminalBuffer.Text : String;
  Begin
   Result := RangeText(0, 0, fColumns - 1, TotalLines - 1);
   Result := TrimRight(Result);
  End;

 Function TTerminalBuffer.TakeResponses : String;
  Begin
   Result     := fResponses;
   fResponses := '';
  End;

End.
