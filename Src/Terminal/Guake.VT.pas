{$StackFrames On}
/// <summary>Incremental UTF-8 and VT parsing into a Unicode screen, alternate buffer and bounded scrollback.</summary>
Unit Guake.VT;

Interface

 Uses
  System.SysUtils, System.Classes, System.Generics.Collections;

 Type
  TTerminalCell = Record
   Text           : String;
   Hyperlink      : String;
   SoftWrapped    : Boolean;
   WrapPadding    : Boolean;
   Foreground     : Integer;
   Background     : Integer;
   Bold           : Boolean;
   Italic         : Boolean;
   Underline      : Boolean;
   UnderlineStyle : Byte;
   UnderlineColor : Integer;
   Faint          : Boolean;
   Conceal        : Boolean;
   Blink          : Boolean;
   Strike         : Boolean;
   Overline       : Boolean;
   Inverse        : Boolean;
   /// <summary>DECSCA protects the complete character from DECSEL/DECSED, independently of SGR.</summary>
   EraseProtected : Boolean;
   Continuation   : Boolean;
  End;

  TTerminalLine = TArray<TTerminalCell>;

  TTerminalScreen = TArray<TTerminalLine>;

  TTerminalCharsets = Array[0..3] Of Char;

/// <summary>DEC cursor state is saved independently for the primary and alternate screens.</summary>

  TTerminalSavedCursor = Record
   x           : Integer;
   y           : Integer;
   Attributes  : TTerminalCell;
   Charsets    : TTerminalCharsets;
   GL          : Integer;
   SingleShift : Integer;
   Origin      : Boolean;
   AutoWrap    : Boolean;
   WrapPending : Boolean;
  End;

  TVTState = (vsGround, vsEscape, vsCSI, vsOSC, vsOSCEscape, vsIgnore, vsIgnoreEscape, vsCharset, vsEscapeIntermediate, vsDCS, vsDCSEscape);

  TTerminalBuffer = Class
   Private
    fScreen             : TTerminalScreen;
    fPrimary            : TTerminalScreen;
    fHistory            : TList<TTerminalLine>;
    fTitleStack         : TList<String>;
    fSavedModes         : TDictionary<Integer, Boolean>;
    fTabStops           : TArray<Boolean>;
    fColumns            : Integer;
    fRows               : Integer;
    fX                  : Integer;
    fY                  : Integer;
    fDECSaved           : Array[Boolean] Of TTerminalSavedCursor;
    fCharsets           : TTerminalCharsets;
    fCharsetSlot        : Integer;
    fGL                 : Integer;
    fSingleShift        : Integer;
    fPrimaryX           : Integer;
    fPrimaryY           : Integer;
    fPrimaryWrapPending : Boolean;
    fTop                : Integer;
    fBottom             : Integer;
    fHistoryLimit       : Integer;
    fAttr               : TTerminalCell;
    fState              : TVTState;
    fSequence           : String;
    fSequenceInvalid    : Boolean;
    fBellCount          : UInt64;
    fTitle              : String;
    fHyperlink          : String;
    fDirectory          : String;
    fResponses          : String;
    fUtf8               : Cardinal;
    fRemaining          : Integer;
    fMinimum            : Cardinal;
    fWrapPending        : Boolean;
    fAutoWrap           : Boolean;
    fOrigin             : Boolean;
    fInsert             : Boolean;
    fAlternate          : Boolean;
    fCursorVisible      : Boolean;
    fCursorStyle        : Integer;
    fApplicationCursor  : Boolean;
    fApplicationKeypad  : Boolean;
    fFocusReporting     : Boolean;
    fNewLineMode        : Boolean;
    fBracketedPaste     : Boolean;
    fMouseMode          : Integer;
    fMouseX10           : Boolean;
    fMouseButtons       : Boolean;
    fMouseButtonMotion  : Boolean;
    fMouseAnyMotion     : Boolean;
    fMouseRevision      : Int64;
    fSGRMouse           : Boolean;
    fUtf8Mouse          : Boolean;
    fUrxvtMouse         : Boolean;
    fPixelMouse         : Boolean;
    fAlternateScroll    : Boolean;
    fRevision           : Int64;
    fLastGraphic        : Cardinal;
    Function  Blank                                                   : TTerminalCell;
    Procedure ClearLine       (Var Line : TTerminalLine; First, Last : Integer);
    Procedure EraseLine       (Var Line : TTerminalLine; First, Last : Integer; Selective : Boolean);
    Procedure ShiftColumns    (Count : Integer; Insert : Boolean);
    Procedure AllocateScreen  (Var Screen : TTerminalScreen; Columns, Rows : Integer);
    Procedure ProcessCode     (Code : Cardinal);
    Procedure PutCode         (Code : Cardinal);
    Procedure SaveCursorState;
    Procedure RestoreCursorState;
    Function  TranslateGraphic(Code : Cardinal)                       : Cardinal;
    Procedure LineFeed;
    Procedure MoveTab         (Count : Integer; ForwardTab : Boolean);
    Procedure Scroll          (Up : Boolean; Count : Integer);
    Procedure BreakLineAfter  (Row : Integer);
    Procedure ExecuteCSI      (Final : Char);
    Procedure ResetTerminal   (HardReset : Boolean);
    Procedure ScreenAlignmentPattern;
    Procedure ApplyPrivateMode(Mode : Integer; Enabled : Boolean);
    Function  ModeStatus      (Mode : Integer; PrivateMode : Boolean) : Integer;
    Procedure ExecuteSGR;
    Procedure ExecuteControl  (Code : Cardinal);
    Procedure ExecuteOSC;
    Procedure ExecuteDCS;
    Function  SGRState                                                : String;
    Procedure SwitchScreen    (Alternate : Boolean; SaveCursor : Boolean);
    Function  GetCell         (x, y : Integer)                        : TTerminalCell;
    Function  GetTotalLines                                           : Integer;
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
    /// <summary>Returns a borrowed read-only row on the UI thread; clone it before retaining a previous state.</summary>
    Function LineCells(Index : Integer) : TTerminalLine;
    Function LineText (Index : Integer) : String;
    /// <summary>Joins soft-wrapped rows with a UTF-16 index at a clicked cell; rejects logical lines beyond 65536 units.</summary>
    Function LogicalLineText(Column, Row : Integer; Out CharacterIndex : Integer) : String;
    Function Text                                                                 : String;
    /// <summary>Returns inclusive selected cells as Unicode text, excluding continuation cells.</summary>
    Function    RangeText(StartX, StartY, EndX, EndY : Integer) : String;
    Property Cell[x, y : Integer] : TTerminalCell Read GetCell;
    Property Columns              : Integer Read fColumns;
    Property Rows                 : Integer Read fRows;
    Property CursorX              : Integer Read fX;
    Property CursorY              : Integer Read fY;
    Property TotalLines           : Integer Read GetTotalLines;
    /// <summary>DECSCUSR 0 follows terminal preferences; 1..6 override shape and blink, globally across screens.</summary>
    Property CursorStyle       : Integer Read fCursorStyle;
    Property CursorVisible     : Boolean Read fCursorVisible;
    Property AlternateScreen   : Boolean Read fAlternate;
    Property ApplicationCursor : Boolean Read fApplicationCursor;
    Property ApplicationKeypad : Boolean Read fApplicationKeypad;
    Property FocusReporting    : Boolean Read fFocusReporting;
    Property NewLineMode       : Boolean Read fNewLineMode;
    Property BracketedPaste    : Boolean Read fBracketedPaste;
    /// <summary>Invalidates view mouse-position caches after protocol negotiation and terminal reset.</summary>
    Property MouseRevision : Int64 Read fMouseRevision;
    Property MouseMode     : Integer Read fMouseMode;
    /// <summary>DEC mode 1005 permits UTF-8 mouse coordinates; SGR 1006 takes precedence when both are set.</summary>
    Property Utf8Mouse       : Boolean Read fUtf8Mouse;
    Property UrxvtMouse      : Boolean Read fUrxvtMouse;
    Property PixelMouse      : Boolean Read fPixelMouse;
    Property AlternateScroll : Boolean Read fAlternateScroll;
    Property SGRMouse        : Boolean Read fSGRMouse;
    Property BellCount       : UInt64 Read fBellCount;
    Property Title           : String Read fTitle;
    Property DirectoryURI    : String Read fDirectory;
    Property Revision        : Int64 Read fRevision;
  End;

Implementation

 Uses
  System.Math, System.StrUtils, Guake.Unicode;

 Function TTerminalBuffer.Blank : TTerminalCell;
  Begin
   Result                := fAttr;
   Result.Text           := ' ';
   Result.Continuation   := False;
   Result.EraseProtected := False;
  End;

 Procedure TTerminalBuffer.ClearLine(Var Line : TTerminalLine; First, Last : Integer);
  Var
   i : Integer;
  Begin
   For i    := Max(0, First) To Min(High(Line), Last) Do
    Line[i] := Blank;
  End;

/// <summary>Erases whole character cells, including a wide character crossing the requested edge.</summary>

 Procedure TTerminalBuffer.EraseLine(Var Line : TTerminalLine; First, Last : Integer; Selective : Boolean);
  Var
   x, Start, Finish, i : Integer;
   KeepCharacter       : Boolean;
  Begin
   First := Max(0, First);
   Last  := Min(High(Line), Last);
   x     := First;
   While x <= Last Do
    Begin
     Start := x;
     While (Start > 0) And Line[Start].Continuation Do
      Dec(Start);
     Finish := Start;
     While (Finish < High(Line)) And Line[Finish + 1].Continuation Do
      Inc(Finish);
     KeepCharacter  := False;
     For i          := Start To Finish Do
      KeepCharacter := KeepCharacter Or Line[i].EraseProtected;
     If Not Selective Or Not KeepCharacter Then
      For i    := Start To Finish Do
       Line[i] := Blank;
     x         := Finish + 1;
    End;
  End;

/// <summary>Shifts columns while replacing wide characters intersected by edit boundaries with blanks.</summary>

 Procedure TTerminalBuffer.ShiftColumns(Count : Integer; Insert : Boolean);
  Var
   x       : Integer;
   Wrapped : Boolean;
  Begin
   Count := EnsureRange(Count, 0, fColumns - fX);
   If Count = 0 Then
    Exit;
   Wrapped := fScreen[fY][fColumns - 1].SoftWrapped;
   If Insert Then
    Begin
     If fScreen[fY][fX].Continuation Then
      EraseLine(fScreen[fY], fX, fX, False);
     If fScreen[fY][fColumns - Count].Continuation Then
      EraseLine(fScreen[fY], fColumns - Count, fColumns - Count, False);
     For x           := fColumns - 1 Downto fX + Count Do
      fScreen[fY][x] := fScreen[fY][x - Count];
     ClearLine(fScreen[fY], fX, fX + Count - 1);
    End
   Else
    Begin
     EraseLine(fScreen[fY], fX, fX + Count - 1, False);
     For x           := fX To fColumns - Count - 1 Do
      fScreen[fY][x] := fScreen[fY][x + Count];
     ClearLine(fScreen[fY], fColumns - Count, fColumns - 1);
    End;
   // Wrapping belongs to the physical row, not to the cell being shifted.
   For x := 0 To fColumns - 1 Do
    Begin
     fScreen[fY][x].SoftWrapped := False;
     fScreen[fY][x].WrapPadding := False;
    End;
   fScreen[fY][fColumns - 1].SoftWrapped := Wrapped;
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
   fTitleStack   := TList<String>.Create;
   fSavedModes   := TDictionary<Integer, Boolean>.Create;
   fHistoryLimit := HistoryLimit;
   fColumns      := Columns;
   fRows         := Rows;
   If (Columns < 1) Or (Rows < 1) Then
    Raise EArgumentOutOfRangeException.Create('Terminal size');
   Reset;
  End;

 Destructor TTerminalBuffer.Destroy;
  Begin
   fSavedModes.Free;
   fTitleStack.Free;
   fHistory.Free;
   Inherited;
  End;

 Procedure TTerminalBuffer.Reset;
  Begin
   ResetTerminal(True);
  End;

/// <summary>Resets modes and rendition; DECSTR preserves existing screens, history, coordinates and tab stops.</summary>

 Procedure TTerminalBuffer.ResetTerminal(HardReset : Boolean);
  Var
   i         : Integer;
   Alternate : Boolean;
  Begin
   fLastGraphic := 0;
   fSavedModes.Clear;
   If HardReset Then
    Begin
     fTitleStack.Clear;
     SetLength(fTabStops, fColumns);
     For i         := 0 To High(fTabStops) Do
      fTabStops[i] := (i > 0) And (i Mod 8 = 0);
     fX            := 0;
     fY            := 0;
     fPrimary      := Nil;
     fAlternate    := False;
     fWrapPending  := False;
    End;
   fHyperlink           := '';
   fAttr                := Default(TTerminalCell);
   fAttr.Foreground     := -1;
   fAttr.Background     := -2;
   fAttr.UnderlineColor := -1;
   For i                := 0 To High(fCharsets) Do
    fCharsets[i]        := 'B';
   fGL                  := 0;
   fCharsetSlot         := 0;
   fSingleShift         := -1;
   For Alternate        := False To True Do
    Begin
     fDECSaved[Alternate]             := Default(TTerminalSavedCursor);
     fDECSaved[Alternate].Attributes  := fAttr;
     fDECSaved[Alternate].Charsets    := fCharsets;
     fDECSaved[Alternate].AutoWrap    := True;
     fDECSaved[Alternate].SingleShift := -1;
    End;
   fTop               := 0;
   fBottom            := fRows - 1;
   fCursorVisible     := True;
   fCursorStyle       := 0;
   fApplicationCursor := False;
   fApplicationKeypad := False;
   fFocusReporting    := False;
   fNewLineMode       := False;
   fBracketedPaste    := False;
   fMouseMode         := 0;
   fMouseX10          := False;
   fMouseButtons      := False;
   fMouseButtonMotion := False;
   fMouseAnyMotion    := False;
   Inc(fMouseRevision);
   fSGRMouse        := False;
   fUtf8Mouse       := False;
   fUrxvtMouse      := False;
   fPixelMouse      := False;
   fAlternateScroll := True;
   fAutoWrap        := True;
   fOrigin          := False;
   fInsert          := False;
   fState           := vsGround;
   fSequence        := '';
   fSequenceInvalid := False;
   fRemaining       := 0;
   If HardReset Then
    Begin
     fHistory.Clear;
     AllocateScreen(fScreen, fColumns, fRows);
    End
   Else
    Begin
     fResponses := '';
     If fAlternate Then
      Begin
       fDECSaved[False].x           := fPrimaryX;
       fDECSaved[False].y           := fPrimaryY;
       fDECSaved[False].WrapPending := fPrimaryWrapPending;
      End;
     SaveCursorState;
    End;
   Inc(fRevision);
  End;

/// <summary>DECALN fills only the active screen with basic E cells, resets margins and origin, and homes the cursor.</summary>

 Procedure TTerminalBuffer.ScreenAlignmentPattern;
  Var
   Cell : TTerminalCell;
   x, y : Integer;
  Begin
   fTop                := 0;
   fBottom             := fRows - 1;
   fOrigin             := False;
   fX                  := 0;
   fY                  := 0;
   fWrapPending        := False;
   Cell                := Default(TTerminalCell);
   Cell.Text           := 'E';
   Cell.Foreground     := -1;
   Cell.Background     := -2;
   Cell.UnderlineColor := -1;
   For y               := 0 To fRows - 1 Do
    For x              := 0 To fColumns - 1 Do
     fScreen[y][x]     := Cell;
  End;

 Procedure TTerminalBuffer.SetHistoryLimit(Value : Integer);
  Begin
   fHistoryLimit := Value;
   If Value >= 0 Then
    While fHistory.Count > Value Do
     fHistory.Delete(0);
  End;

/// <summary>Breaks a logical paragraph at a scrolling boundary, including the last history row above the screen.</summary>

 Procedure TTerminalBuffer.BreakLineAfter(Row : Integer);
  Var
   Line : TTerminalLine;
  Begin
   If (Row >= 0) And (Row < fRows) Then
    Line := fScreen[Row]
   Else If (Row = -1) And Not fAlternate And (fHistory.Count > 0) Then
    Line := fHistory.Last
   Else
    Exit;
   If Length(Line) > 0 Then
    Begin
     Line[High(Line)].SoftWrapped := False;
     Line[High(Line)].WrapPadding := False;
    End;
  End;

 Procedure TTerminalBuffer.Scroll(Up : Boolean; Count : Integer);
  Var
   i, n, h, Amount : Integer;
   Line            : TTerminalLine;
  Begin
   h      := fBottom - fTop + 1;
   Amount := Min(Max(Count, 0), h);
   If Amount = 0 Then
    Exit;
   If Up And ((fTop > 0) Or (fBottom < fRows - 1)) Then
    Begin
     If fTop > 0 Then
      BreakLineAfter(fTop - 1);
     BreakLineAfter(fBottom);
    End;
   For n := 1 To Amount Do
    If Up Then
     Begin
      If Not fAlternate And (fTop = 0) And (fHistoryLimit <> 0) Then
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
   If Not Up Then
    Begin
     BreakLineAfter(fTop - 1);
     BreakLineAfter(fBottom);
    End;
  End;

 Procedure TTerminalBuffer.LineFeed;
  Begin
   If fNewLineMode Then
    fX          := 0;
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

/// <summary>Maps only GL graphics; UTF-8 characters outside ASCII retain their Unicode value.</summary>

 Function TTerminalBuffer.TranslateGraphic(Code : Cardinal) : Cardinal;
  Const
   DECGraphics : String = ' ◆▒␉␌␍␊°±␤␋┘┐┌└┼⎺⎻─⎼⎽├┤┴┬│≤≥π≠£·';
  Var
   Slot : Integer;
  Begin
   Result := Code;
   Slot   := fGL;
   If fSingleShift >= 0 Then
    Slot        := fSingleShift;
   fSingleShift := -1;
   If (Code < $20) Or (Code > $7E) Then
    Exit;
   Case fCharsets[Slot] Of
    '0' :
     If Code >= $5F Then
      Result := Ord(DECGraphics[Code - $5F + 1]);
    'A' :
     If Code = Ord('#') Then
      Result := $A3;
   End;
  End;

/// <summary>Saves coordinates, rendition, GL character mapping and DEC origin/wrapping state.</summary>

 Procedure TTerminalBuffer.SaveCursorState;
  Begin
   With fDECSaved[fAlternate] Do
    Begin
     x           := fX;
     y           := fY;
     Attributes  := fAttr;
     Charsets    := fCharsets;
     GL          := fGL;
     SingleShift := fSingleShift;
     Origin      := fOrigin;
     AutoWrap    := fAutoWrap;
     WrapPending := fWrapPending;
    End;
  End;

/// <summary>Restores the current screen's DEC state, clamping coordinates to its current geometry.</summary>

 Procedure TTerminalBuffer.RestoreCursorState;
  Begin
   With fDECSaved[fAlternate] Do
    Begin
     fAttr        := Attributes;
     fCharsets    := Charsets;
     fGL          := GL;
     fSingleShift := SingleShift;
     fOrigin      := Origin;
     fAutoWrap    := AutoWrap;
     fX           := EnsureRange(x, 0, fColumns - 1);
     If fOrigin Then
      fY := EnsureRange(y, fTop, fBottom)
     Else
      fY          := EnsureRange(y, 0, fRows - 1);
     fWrapPending := WrapPending And fAutoWrap And (fX = fColumns - 1);
    End;
  End;

 Procedure TTerminalBuffer.PutCode(Code : Cardinal);
  Var
   w, Previous, OldWidth, NewWidth : Integer;
   Next                            : String;
   Unmapped                        : Cardinal;
   Wrapped                         : Boolean;
  Begin
   Unmapped := Code;
   Code     := TranslateGraphic(Code);
   Next     := CodeText(Code);
   Previous := fX - 1;
   If fWrapPending Then
    Previous := fX;
   If (Previous >= 0) And fScreen[fY][Previous].Continuation Then
    Dec(Previous);
   If (Previous >= 0) And JoinsGrapheme(fScreen[fY][Previous].Text, Next) Then
    Begin
     OldWidth := 1;
     If (Previous + 1 < fColumns) And fScreen[fY][Previous + 1].Continuation Then
      OldWidth                  := 2;
     fScreen[fY][Previous].Text := fScreen[fY][Previous].Text + Next;
     NewWidth                   := Min(GraphemeWidth(fScreen[fY][Previous].Text), fColumns - Previous);
     If NewWidth > OldWidth Then
      Begin
       Wrapped := fScreen[fY][fColumns - 1].SoftWrapped;
       If (Previous + 2 < fColumns) And fScreen[fY][Previous + 2].Continuation Then
        fScreen[fY][Previous + 2]               := Blank;
       fScreen[fY][Previous + 1]                := Blank;
       fScreen[fY][Previous + 1].Text           := '';
       fScreen[fY][Previous + 1].Continuation   := True;
       fScreen[fY][Previous + 1].EraseProtected := fScreen[fY][Previous].EraseProtected;
       fScreen[fY][fColumns - 1].SoftWrapped    := Wrapped;
       If Not fWrapPending Then
        Begin
         Inc(fX);
         If fX >= fColumns Then
          Begin
           fX           := fColumns - 1;
           fWrapPending := fAutoWrap;
          End;
        End;
      End;
     Exit;
    End;
   fLastGraphic := Unmapped;
   w            := GraphemeWidth(Next);
   If w > fColumns Then
    w := 1;
   If fWrapPending Or ((w = 2) And (fX = fColumns - 1)) Then
    If fAutoWrap Then
     Begin
      fScreen[fY][fColumns - 1].SoftWrapped := True;
      If (w = 2) And (fX = fColumns - 1) And Not fWrapPending Then
       fScreen[fY][fColumns - 1].WrapPadding := True;
      fX                                     := 0;
      LineFeed;
     End
    Else
     fX         := fColumns - w;
   fWrapPending := False;
   Wrapped      := fScreen[fY][fColumns - 1].SoftWrapped;
   If fInsert Then
    ShiftColumns(w, True);
   If fScreen[fY][fX].Continuation And (fX > 0) Then
    fScreen[fY][fX - 1] := Blank;
   If (fX + w < fColumns) And fScreen[fY][fX + w].Continuation Then
    fScreen[fY][fX + w]         := Blank;
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
   fScreen[fY][fColumns - 1].SoftWrapped := Wrapped;
   Inc(fX, w);
   If fX >= fColumns Then
    Begin
     fX           := fColumns - 1;
     fWrapPending := fAutoWrap;
    End;
  End;

/// <summary>Switch buffers while retaining the primary cursor and its deferred wrap.</summary>

 Procedure TTerminalBuffer.SwitchScreen(Alternate, SaveCursor : Boolean);
  Begin
   If Alternate = fAlternate Then
    Exit;
   If Alternate Then
    Begin
     If SaveCursor Then
      SaveCursorState;
     fPrimary            := fScreen;
     fPrimaryWrapPending := fWrapPending;
     fPrimaryX           := fX;
     fPrimaryY           := fY;
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
   fWrapPending := Not Alternate And fPrimaryWrapPending;
   If Not Alternate And SaveCursor Then
    RestoreCursorState;
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

/// <summary>Returns canonical supported SGR attributes and colors for DECRQSS round trips.</summary>

 Function TTerminalBuffer.SGRState : String;

   Procedure Add(Const Value : String);
    Begin
     Result := Result + ';' + Value;
    End;

   Procedure Color(Code, Value : Integer);
    Begin
     If Value < 0 Then
      Exit;
     If (Value And $01000000) <> 0 Then
      Add(Format('%d;2;%d;%d;%d', [Code, Value And 255, (Value Shr 8) And 255, (Value Shr 16) And 255]))
     Else
      Add(Format('%d;5;%d', [Code, Value]));
    End;

  Begin
   Result := '0';
   If fAttr.Bold Then
    Add('1');
   If fAttr.Faint Then
    Add('2');
   If fAttr.Italic Then
    Add('3');
   If fAttr.Underline Then
    If fAttr.UnderlineStyle <= 1 Then
     Add('4')
    Else
     Add('4:' + IntToStr(fAttr.UnderlineStyle));
   If fAttr.Blink Then
    Add('5');
   If fAttr.Inverse Then
    Add('7');
   If fAttr.Conceal Then
    Add('8');
   If fAttr.Strike Then
    Add('9');
   If fAttr.Overline Then
    Add('53');
   Color(38, fAttr.Foreground);
   Color(48, fAttr.Background);
   Color(58, fAttr.UnderlineColor);
  End;

/// <summary>Answers bounded DECRQSS requests; unknown status strings receive a negative reply.</summary>

 Procedure TTerminalBuffer.ExecuteDCS;
  Var
   Request, Reply : String;
  Begin
   If Copy(fSequence, 1, 2) <> '$q' Then
    Exit;
   Request := Copy(fSequence, 3, MaxInt);
   If Request = 'm' Then
    Reply := SGRState + 'm'
   Else If Request = #34'q' Then
    Reply := IntToStr(Ord(fAttr.EraseProtected)) + #34'q'
   Else If Request = ' q' Then
    Reply := IntToStr(fCursorStyle) + ' q'
   Else If Request = 'r' Then
    Reply := Format('%d;%dr', [fTop + 1, fBottom + 1])
   Else
    Begin
     fResponses := fResponses + #27'P0$r'#27'\';
     Exit;
    End;
   fResponses := fResponses + #27'P1$r' + Reply + #27'\';
  End;

/// <summary>Moves between programmed tab stops without inserting text or crossing a screen edge.</summary>

 Procedure TTerminalBuffer.MoveTab(Count : Integer; ForwardTab : Boolean);
  Var
   Step, i : Integer;
  Begin
   // A forward tab cannot advance a cursor already awaiting autowrap.
   If ForwardTab And fWrapPending Then
    Exit;
   If ForwardTab Then
    Step := 1
   Else
    Step := -1;
   For i := 1 To Min(Count, fColumns) Do
    Begin
     Repeat
      fX := EnsureRange(fX + Step, 0, fColumns - 1);
     Until(fX = 0) Or (fX = fColumns - 1) Or fTabStops[fX];
    End;
   fWrapPending := False;
  End;

/// <summary>Returns DECRPM 1/2 for implemented mutable modes and 0 for unrecognized modes.</summary>

 Function TTerminalBuffer.ModeStatus(Mode : Integer; PrivateMode : Boolean) : Integer;
  Var
   Enabled : Boolean;
  Begin
   Result  := 0;
   Enabled := False;
   If PrivateMode Then
    Case Mode Of
     1              : Enabled := fApplicationCursor;
     6              : Enabled := fOrigin;
     7              : Enabled := fAutoWrap;
     25             : Enabled := fCursorVisible;
     47, 1047, 1049 : Enabled := fAlternate;
     9              : Enabled := fMouseX10;
     1000           : Enabled := fMouseButtons;
     1002           : Enabled := fMouseButtonMotion;
     1003           : Enabled := fMouseAnyMotion;
     66             : Enabled := fApplicationKeypad;
     1004           : Enabled := fFocusReporting;
     1005           : Enabled := fUtf8Mouse;
     1006           : Enabled := fSGRMouse;
     1015           : Enabled := fUrxvtMouse;
     1016           : Enabled := fPixelMouse;
     1007           : Enabled := fAlternateScroll;
     2004           : Enabled := fBracketedPaste;
    Else Exit;
    End
   Else
    Case Mode Of
     4  : Enabled := fInsert;
     20 : Enabled := fNewLineMode;
    Else Exit;
    End;
   Result := 2 - Ord(Enabled);
  End;

/// <summary>Applies DECSET/DECRST and restored values through the same side effects.</summary>

 Procedure TTerminalBuffer.ApplyPrivateMode(Mode : Integer; Enabled : Boolean);
  Begin
   Case Mode Of
    1 :
     fApplicationCursor := Enabled;
    6 :
     Begin
      fOrigin := Enabled;
      fX      := 0;
      If fOrigin Then
       fY := fTop
      Else
       fY          := 0;
      fWrapPending := False;
     End;
    7 :
     fAutoWrap := Enabled;
    25 :
     fCursorVisible := Enabled;
    66 :
     fApplicationKeypad := Enabled;
    1048 :
     If Enabled Then
      SaveCursorState
     Else
      RestoreCursorState;
    47, 1047, 1049 :
     SwitchScreen(Enabled, Mode = 1049);
    9, 1000, 1002, 1003 :
     Begin
      Inc(fMouseRevision);
      Case Mode Of
       9    : fMouseX10 := Enabled;
       1000 : fMouseButtons := Enabled;
       1002 : fMouseButtonMotion := Enabled;
       1003 : fMouseAnyMotion := Enabled;
      End;
      If fMouseAnyMotion Then
       fMouseMode := 1003
      Else If fMouseButtonMotion Then
       fMouseMode := 1002
      Else If fMouseButtons Then
       fMouseMode := 1000
      Else If fMouseX10 Then
       fMouseMode := 9
      Else
       fMouseMode := 0;
     End;
    1004 :
     fFocusReporting := Enabled;
    1005 :
     Begin
      Inc(fMouseRevision);
      fUtf8Mouse := Enabled;
     End;
    1006 :
     Begin
      Inc(fMouseRevision);
      fSGRMouse := Enabled;
     End;
    1007 :
     fAlternateScroll := Enabled;
    1015 :
     Begin
      Inc(fMouseRevision);
      fUrxvtMouse := Enabled;
     End;
    1016 :
     Begin
      Inc(fMouseRevision);
      fPixelMouse := Enabled;
     End;
    2004 :
     fBracketedPaste := Enabled;
   End;
  End;

 Procedure TTerminalBuffer.ExecuteCSI(Final : Char);
  Var
   Parts                              : TArray<String>;
   Params                             : TArray<Integer>;
   PrivateMode                        : Boolean;
   SecondaryDA, TertiaryDA, ModeQuery : Boolean;
   SavedValue                         : Boolean;
   LastGraphic                        : Cardinal;
   Prefix                             : String;
   i, n, a, b, x, y, OldTop           : Integer;

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

  /// <summary>Relative vertical motion stops at the directional margin, or the screen edge when starting beyond it.</summary>

   Procedure MoveVertical(Up, CarriageReturn : Boolean);
    Var
     Limit, NewY, NewX : Integer;
    Begin
     NewX := fX;
     If CarriageReturn Then
      NewX := 0;
     If Up Then
      Begin
       Limit := 0;
       If fY >= fTop Then
        Limit := fTop;
       NewY   := Max(Limit, fY - Min(n, fRows));
      End
     Else
      Begin
       Limit := fRows - 1;
       If fY <= fBottom Then
        Limit := fBottom;
       NewY   := Min(Limit, fY + Min(n, fRows));
      End;
     MoveCursor(NewX, NewY);
    End;

  Begin
   LastGraphic  := fLastGraphic;
   fLastGraphic := 0;
   If (Final = 'p') And (fSequence = '!') Then
    Begin
     ResetTerminal(False);
     Exit;
    End;
   If (Final = 'q') And (Copy(fSequence, Length(fSequence), 1) = #34) Then
    Begin
     Prefix := Copy(fSequence, 1, Length(fSequence) - 1);
     For i  := 1 To Length(Prefix) Do
      If Not CharInSet(Prefix[i], ['0'..'9']) Then
       Exit;
     If Prefix = '' Then
      n := 0
     Else If Not TryStrToInt(Prefix, n) Then
      Exit;
     Case n Of
      0, 2 : fAttr.EraseProtected := False;
      1    : fAttr.EraseProtected := True;
     End;
     Exit;
    End;
   If (Final = 'q') And (Copy(fSequence, Length(fSequence), 1) = ' ') Then
    Begin
     Prefix := Copy(fSequence, 1, Length(fSequence) - 1);
     For i  := 1 To Length(Prefix) Do
      If Not CharInSet(Prefix[i], ['0'..'9']) Then
       Exit;
     If Prefix = '' Then
      n := 0
     Else If Not TryStrToInt(Prefix, n) Then
      Exit;
     If (n >= 0) And (n <= 6) Then
      fCursorStyle := n;
     Exit;
    End;
   ModeQuery := (Final = 'p') And (Copy(fSequence, Length(fSequence), 1) = '$');
   If ModeQuery Then
    Delete(fSequence, Length(fSequence), 1);
   SecondaryDA := Copy(fSequence, 1, 1) = '>';
   TertiaryDA  := Copy(fSequence, 1, 1) = '=';
   If SecondaryDA Or TertiaryDA Then
    Begin
     If Final <> 'c' Then
      Exit;
     Delete(fSequence, 1, 1);
    End;
   PrivateMode := Copy(fSequence, 1, 1) = '?';
   If PrivateMode Then
    Begin
     If Not ModeQuery And Not CharInSet(Final, ['h', 'l', 'n', 'W', 's', 'r', 'J', 'K']) Then
      Exit;
     Delete(fSequence, 1, 1);
    End;
   For i := 1 To Length(fSequence) Do
    If Not CharInSet(fSequence[i], ['0'..'9', ';', ':']) Then
     Exit;
   If (Pos(':', fSequence) > 0) And (Final <> 'm') Then
    Exit;
   If Final = 'm' Then
    Begin
     ExecuteSGR;
     Exit;
    End;
   Parts := fSequence.Split([';']);
   SetLength(Params, Max(1, Length(Parts)));
   For i := 0 To High(Parts) Do
    If Parts[i] = '' Then
     Params[i] := 0
    Else If Not TryStrToInt(Parts[i], Params[i]) Then
     Exit;
   If PrivateMode And CharInSet(Final, ['J', 'K']) And
   ((Length(Params) <> 1) Or (Params[0] < 0) Or (Params[0] > 2)) Then
    Exit;
   If PrivateMode And CharInSet(Final, ['s', 'r']) Then
    Begin
     For i := 0 To High(Params) Do
      Case Params[i] Of
       1, 6, 7, 9, 25, 66, 1000, 1002, 1003, 1004, 1005, 1006, 1007, 1015, 1016, 2004 :
        If Final = 's' Then
         fSavedModes.AddOrSetValue(Params[i], ModeStatus(Params[i], True) = 1)
        Else If fSavedModes.TryGetValue(Params[i], SavedValue) Then
         ApplyPrivateMode(Params[i], SavedValue);
      End;
     Exit;
    End;
   If ModeQuery Then
    Begin
     Prefix := '';
     If PrivateMode Then
      Prefix     := '?';
     For i       := 0 To High(Params) Do
      fResponses := fResponses + Format(#27'[%s%d;%d$y', [Prefix, Params[i], ModeStatus(Params[i], PrivateMode)]);
     Exit;
    End;
   If SecondaryDA Or TertiaryDA Then
    Begin
     If (Length(Params) = 1) And (Params[0] = 0) Then
      If TertiaryDA Then
      // DECRPTUI: stable four-byte port identifier "~GKW", encoded as eight hexadecimal digits.
       fResponses := fResponses + #27 + 'P!|7E474B57' + #27 + Chr(92)
      Else
       fResponses := fResponses + #27'[>0;0;0c';
     Exit;
    End;
   If Not CharInSet(Final, ['m', 'h', 'l', 's', 'u', 'n', 'c', 't', 'b', 'L', 'M', 'I']) And
   Not((Final = 'K') And Not PrivateMode And (P(0, 0) = 0)) Then
    fWrapPending := False;
   n             := Min(P(0, 1), Max(fColumns, fRows));
   Case Final Of
    'b' :
     If (LastGraphic <> 0) And (Length(Params) = 1) Then
      Begin
       // VTE limits repetitions to the remaining column count, not the requested integer.
       n     := Min(P(0, 1), fColumns - fX - Ord(fWrapPending));
       For i := 1 To n Do
        PutCode(LastGraphic);
       // REP is itself a command: another REP needs a new graphic character first.
       fLastGraphic := 0;
      End;
    'W' :
     If PrivateMode And (P(0, 0) = 5) Then
      For x         := 0 To High(fTabStops) Do
       fTabStops[x] := (x > 0) And (x Mod 8 = 0);
    'I' :
     If Not PrivateMode Then
      MoveTab(P(0, 1), True);
    'Z' :
     If Not PrivateMode Then
      MoveTab(P(0, 1), False);
    'g' :
     If Not PrivateMode Then
      Case P(0, 0) Of
       0 :
        fTabStops[fX] := False;
       3 :
        For x         := 0 To High(fTabStops) Do
         fTabStops[x] := False;
      End;
    'A' :
     MoveVertical(True, False);
    'B', 'e' :
     MoveVertical(False, False);
    'C', 'a' :
     MoveCursor(fX + n, fY);
    'D' :
     MoveCursor(fX - n, fY);
    'E' :
     MoveVertical(False, True);
    'F' :
     MoveVertical(True, True);
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
        EraseLine(fScreen[fY], fX, fColumns - 1, PrivateMode);
        For y := fY + 1 To fRows - 1 Do
         EraseLine(fScreen[y], 0, fColumns - 1, PrivateMode);
       End;
      1 :
       Begin
        // Ordinary ED above breaks the paragraph joining history to the cleared screen.
        If Not PrivateMode Then
         BreakLineAfter( -1);
        For y := 0 To fY - 1 Do
         EraseLine(fScreen[y], 0, fColumns - 1, PrivateMode);
        EraseLine(fScreen[fY], 0, fX, PrivateMode);
       End;
      2 :
       For y := 0 To fRows - 1 Do
        EraseLine(fScreen[y], 0, fColumns - 1, PrivateMode);
      3 :
       If Not PrivateMode Then
        fHistory.Clear;
     End;
    'K' :
     Case P(0, 0) Of
      0 :
       Begin
        // VTE keeps the logical cursor beyond a full row for ordinary EL 0.
        EraseLine(fScreen[fY], fX + Ord(fWrapPending), fColumns - 1, PrivateMode);
        If Not PrivateMode Then
         BreakLineAfter(fY);
       End;
      1 :
       EraseLine(fScreen[fY], 0, fX, PrivateMode);
      2 :
       EraseLine(fScreen[fY], 0, fColumns - 1, PrivateMode);
     End;
    '@' :
     ShiftColumns(n, True);
    'P' :
     ShiftColumns(n, False);
    'X' :
     EraseLine(fScreen[fY], fX, fX + n - 1, False);
    'L', 'M' :
     If (fY >= fTop) And (fY <= fBottom) Then
      Begin
       // IL/DL return the carriage only when they operate inside the region.
       fX           := 0;
       fWrapPending := False;
       OldTop       := fTop;
       fTop         := fY;
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
     SaveCursorState;
    'u' :
     RestoreCursorState;
    'h', 'l' :
     For i := 0 To High(Params) Do
      If PrivateMode Then
       ApplyPrivateMode(Params[i], Final = 'h')
      Else If Params[i] = 4 Then
       fInsert := Final = 'h'
      Else If Params[i] = 20 Then
       fNewLineMode := Final = 'h';
    'n' :
     If P(0, 0) = 6 Then
      Begin
       a := fY + 1;
       If fOrigin Then
        Dec(a, fTop);
       If PrivateMode Then
        fResponses := fResponses + Format(#27'[?%d;%d;1R', [a, fX + 1])
       Else
        fResponses := fResponses + Format(#27'[%d;%dR', [a, fX + 1]);
      End
     Else If (P(0, 0) = 5) And Not PrivateMode Then
      fResponses := fResponses + #27'[0n'
     Else If PrivateMode And (Length(Params) = 1) Then
      Case Params[0] Of
       // Report absent or unsupported DEC facilities without advertising them as available.
       15 :
        fResponses := fResponses + #27 + '[?13n';
       25 :
        fResponses := fResponses + #27 + '[?21n';
       55 :
        fResponses := fResponses + #27 + '[?53n';
       56 :
        fResponses := fResponses + #27 + '[?57;0n';
      End;
    'c' :
     If (Length(Params) = 1) And (Params[0] = 0) Then
      fResponses := fResponses + #27'[?1;2c';
    't' :
     If (Length(Params) = 1) And (Params[0] = 18) Then
      fResponses := fResponses + Format(#27'[8;%d;%dt', [fRows, fColumns])
     Else If (Length(Params) <= 2) And ((P(1, 0) = 0) Or (P(1, 0) = 2)) Then
      Case P(0, 0) Of
       22 :
        Begin
         // A bounded per-terminal LIFO; icon labels and indexed slots are not implemented.
         If fTitleStack.Count = 64 Then
          fTitleStack.Delete(0);
         fTitleStack.Add(fTitle);
        End;
       23 :
        If fTitleStack.Count > 0 Then
         Begin
          fTitle := fTitleStack.Last;
          fTitleStack.Delete(fTitleStack.Count - 1);
         End;
      End;
   End;
  End;

/// <summary>Parses SGR parameters without flattening colon-delimited subparameters into separate commands.</summary>

 Procedure TTerminalBuffer.ExecuteSGR;
  Var
   SavedProtection                          : Boolean;
   Parts, Sub                               : TArray<String>;
   i, a, Mode, Color, r, g, b, First, Count : Integer;
   Values                                   : TArray<String>;

   Function Number(Const Value : String) : Integer;
    Begin
     Result := -1;
     If Value <> '' Then
      If Not TryStrToInt(Value, Result) Then
       Result := -1;
    End;

   Function Channel(Index : Integer) : Integer;
    Begin
     Result := -1;
     If Index < Length(Values) Then
      Result := Number(Values[Index]);
    End;

  Begin
   Parts := fSequence.Split([';']);
   If Length(Parts) = 0 Then
    Parts := TArray<String>.Create('');
   i      := 0;
   While i < Length(Parts) Do
    Begin
     Sub := Parts[i].Split([':']);
     If Parts[i] = '' Then
      a := 0
     Else
      a := Number(Sub[0]);
     Case a Of
      0 :
       Begin
        SavedProtection      := fAttr.EraseProtected;
        fAttr                := Default(TTerminalCell);
        fAttr.EraseProtected := SavedProtection;
        fAttr.Foreground     := -1;
        fAttr.Background     := -2;
        fAttr.UnderlineColor := -1;
       End;
      1 :
       fAttr.Bold := True;
      3 :
       fAttr.Italic := True;
      2 :
       fAttr.Faint := True;
      4 :
       Begin
        Mode := 1;
        If (Length(Sub) > 1) And (Sub[1] <> '') Then
         Mode := Number(Sub[1]);
        If (Mode >= 0) And (Mode <= 5) Then
         Begin
          fAttr.Underline      := Mode <> 0;
          fAttr.UnderlineStyle := Mode;
         End;
       End;
      21 :
       Begin
        fAttr.Underline      := True;
        fAttr.UnderlineStyle := 2;
       End;
      5, 6 :
       fAttr.Blink := True;
      25 :
       fAttr.Blink := False;
      8 :
       fAttr.Conceal := True;
      9 :
       fAttr.Strike := True;
      28 :
       fAttr.Conceal := False;
      29 :
       fAttr.Strike := False;
      53 :
       fAttr.Overline := True;
      55 :
       fAttr.Overline := False;
      59 :
       fAttr.UnderlineColor := -1;
      7 :
       fAttr.Inverse := True;
      22 :
       Begin
        fAttr.Bold  := False;
        fAttr.Faint := False;
       End;
      23 :
       fAttr.Italic := False;
      24 :
       Begin
        fAttr.Underline      := False;
        fAttr.UnderlineStyle := 0;
       End;
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
      38, 48, 58 :
       Begin
        Color := -1;
        If Length(Sub) > 1 Then
         Begin
          Values := Sub;
          Mode   := Number(Sub[1]);
          First  := 2;
          If (Mode = 2) And (Length(Sub) > 5) Then
           Begin
            Inc(First);
            If Sub[2] <> '' Then
             Mode := -1;
           End;
         End
        Else
         Begin
          Values := Parts;
          Inc(i);
          Mode  := Channel(i);
          First := i + 1;
          Count := 0;
          If Mode = 2 Then
           Count := 3
          Else If Mode = 5 Then
           Count := 1;
          Inc(i, Count);
         End;
        If Mode = 5 Then
         Begin
          r := Channel(First);
          If (r >= 0) And (r <= 255) Then
           Color := r;
         End
        Else If Mode = 2 Then
         Begin
          r := Channel(First);
          g := Channel(First + 1);
          b := Channel(First + 2);
          If (r >= 0) And (r <= 255) And (g >= 0) And (g <= 255) And (b >= 0) And (b <= 255) Then
           Color := $01000000 Or r Or (g Shl 8) Or (b Shl 16);
         End;
        If Color <> -1 Then
         If a = 38 Then
          fAttr.Foreground := Color
         Else If a = 48 Then
          fAttr.Background := Color
         Else
          fAttr.UnderlineColor := Color;
       End;
     End;
     Inc(i);
    End;
  End;

/// <summary>Executes C0 controls without consuming the surrounding escape or CSI sequence.</summary>

 Procedure TTerminalBuffer.ExecuteControl(Code : Cardinal);
  Begin
   If (Code >= 7) And (Code <= 15) Then
    fLastGraphic := 0;
   Case Code Of
    7 :
     Inc(fBellCount);
    8 :
     Begin
      fX           := Max(0, fX - 1);
      fWrapPending := False;
     End;
    9 :
     MoveTab(1, True);
    10, 11, 12 :
     LineFeed;
    13 :
     Begin
      fX           := 0;
      fWrapPending := False;
     End;
    14 :
     fGL := 1;
    15 :
     fGL := 0;
   End;
  End;

 Procedure TTerminalBuffer.ProcessCode(Code : Cardinal);
  Begin
   If Code = $1B Then
    Begin
     Case fState Of
      vsOSC    : fState := vsOSCEscape;
      vsDCS    : fState := vsDCSEscape;
      vsIgnore : fState := vsIgnoreEscape;
     Else fState := vsEscape;
     End;
     Exit;
    End;
   If (Code = 24) Or (Code = 26) Then
    Begin
     fState           := vsGround;
     fSequence        := '';
     fSequenceInvalid := False;
     Exit;
    End;
   If Code = 127 Then
    Exit;
   If (Code < 32) And (fState In [vsGround, vsEscape, vsCSI, vsCharset, vsEscapeIntermediate]) Then
    Begin
     ExecuteControl(Code);
     Exit;
    End;
   Case fState Of
    vsGround :
     If Code >= 32 Then
      PutCode(Code);
    vsEscape :
     Begin
      fState := vsGround;
      Case Code Of
       Ord('[') :
        Begin
         fSequence        := '';
         fSequenceInvalid := False;
         fState           := vsCSI;
        End;
       Ord(']') :
        Begin
         fSequence        := '';
         fSequenceInvalid := False;
         fState           := vsOSC;
        End;
       Ord('P') :
        Begin
         fSequence        := '';
         fSequenceInvalid := False;
         fState           := vsDCS;
        End;
       Ord('^'), Ord('_'), Ord('X') :
        fState := vsIgnore;
       Ord('=') :
        fApplicationKeypad := True;
       Ord('>') :
        fApplicationKeypad := False;
       Ord('('), Ord(')'), Ord('*'), Ord('+') :
        Begin
         fCharsetSlot := Code - Ord('(');
         fSequence    := '';
         fState       := vsCharset;
        End;
       Ord('N') :
        fSingleShift := 2;
       Ord('O') :
        fSingleShift := 3;
       Ord('n') :
        fGL := 2;
       Ord('o') :
        fGL := 3;
       Ord('7') :
        SaveCursorState;
       Ord('8') :
        RestoreCursorState;
       Ord('H') :
        fTabStops[fX] := True;
       Ord('D') :
        LineFeed;
       Ord('E') :
        Begin
         fX := 0;
         LineFeed;
        End;
       Ord('M') :
        Begin
         // RI is explicit cursor motion, even when it scrolls at the top margin.
         fWrapPending := False;
         If fY = fTop Then
          Scroll(False, 1)
         Else
          fY := Max(0, fY - 1);
        End;
       Ord('c') :
        Reset;
       Ord('Z') :
        fResponses := fResponses + #27'[?1;2c';
      End;
      If (Code >= $20) And (Code <= $2F) And ((Code < Ord('(')) Or (Code > Ord('+'))) Then
       Begin
        fSequence        := Char(Code);
        fSequenceInvalid := False;
        fState           := vsEscapeIntermediate;
       End;
      If fState = vsGround Then
       fLastGraphic := 0;
     End;
    vsCSI :
     If (Code >= $40) And (Code <= $7E) Then
      Begin
       If Not fSequenceInvalid Then
        ExecuteCSI(Char(Code));
       fLastGraphic := 0;
       fState       := vsGround;
      End
     Else If (Code >= $20) And (Code <= $3F) Then
      Begin
       If Length(fSequence) < 256 Then
        fSequence := fSequence + Char(Code)
       Else
        fSequenceInvalid := True;
      End
     Else
      Begin
       fState := vsGround;
       If Code >= $A0 Then
        ProcessCode(Code);
      End;
    vsOSC :
     If Code = 7 Then
      Begin
       If Not fSequenceInvalid Then
        ExecuteOSC;
       fLastGraphic := 0;
       fState       := vsGround;
      End
     Else If Code >= 32 Then
      Begin
       If Length(fSequence) + Length(CodeText(Code)) <= 4096 Then
        fSequence := fSequence + CodeText(Code)
       Else
        fSequenceInvalid := True;
      End;
    vsOSCEscape :
     Begin
      If Code = Ord('\') Then
       Begin
        If Not fSequenceInvalid Then
         ExecuteOSC;
        fLastGraphic := 0;
        fState       := vsGround;
       End
      Else
       Begin
        fState := vsEscape;
        ProcessCode(Code);
       End;
     End;
    vsDCS :
     If Code >= 32 Then
      If Length(fSequence) + Length(CodeText(Code)) <= 4096 Then
       fSequence := fSequence + CodeText(Code)
      Else
       fSequenceInvalid := True;
    vsDCSEscape :
     If Code = Ord('\') Then
      Begin
       If Not fSequenceInvalid Then
        ExecuteDCS;
       fLastGraphic := 0;
       fState       := vsGround;
      End
     Else
      Begin
       fState := vsEscape;
       ProcessCode(Code);
      End;
    vsIgnore :
     ;
    vsIgnoreEscape :
     If Code = Ord('\') Then
      fState := vsGround
     Else
      Begin
       fState := vsEscape;
       ProcessCode(Code);
      End;
    vsEscapeIntermediate :
     If (Code >= $20) And (Code <= $2F) Then
      Begin
       If Length(fSequence) < 256 Then
        fSequence := fSequence + Char(Code)
       Else
        fSequenceInvalid := True;
      End
     Else
      Begin
       If Not fSequenceInvalid And (fSequence = '#') And (Code = Ord('8')) Then
        ScreenAlignmentPattern;
       fState       := vsGround;
       fLastGraphic := 0;
       If Code >= $A0 Then
        ProcessCode(Code);
      End;
    vsCharset :
     If (Code >= $20) And (Code <= $2F) Then
      fSequence := 'unsupported'
     Else
      Begin
       If (fSequence = '') And ((Code = Ord('0')) Or (Code = Ord('A')) Or (Code = Ord('B'))) Then
        fCharsets[fCharsetSlot] := Char(Code);
       fState                   := vsGround;
       fLastGraphic             := 0;
      End;
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

/// <summary>Reflows primary logical lines and history, preserving grapheme cells, style, links and cursor position.</summary>

 Procedure TTerminalBuffer.Resize(Columns, Rows : Integer);
  Var
   NewScreen  : TTerminalScreen;
   NewPending : Boolean;
   TabIndex   : Integer;

   /// <summary>Clip the alternate grid without retaining half of a cut wide glyph.</summary>

   Procedure ResizeGrid(Var Screen : TTerminalScreen);
    Var
     x, y : Integer;
    Begin
     AllocateScreen(NewScreen, Columns, Rows);
     For y := 0 To Min(High(Screen), Rows - 1) Do
      Begin
       For x            := 0 To Min(High(Screen[y]), Columns - 1) Do
        NewScreen[y][x] := Screen[y][x];
       If (Columns < Length(Screen[y])) And Screen[y][Columns].Continuation Then
        EraseLine(NewScreen[y], Columns - 1, Columns - 1, False);
      End;
     Screen    := NewScreen;
     NewScreen := Nil;
    End;

  /// <summary>Rewrap primary text and map both live and DEC-saved cursor positions.</summary>

   Procedure Reflow(Var Screen : TTerminalScreen; Var CursorX, CursorY : Integer; Pending : Boolean);
    Var
     SavedRow, SavedCol, SavedX, SavedY                                                : Integer;
     SavedPending, FoundSaved                                                          : Boolean;
     Input, Output                                                                     : TList<TTerminalLine>;
     Current, Source                                                                   : TTerminalLine;
     Cell                                                                              : TTerminalCell;
     x, y, i, Count, Bottom, Col, Width, CursorRow, CursorCol, MappedX, MappedY, Start : Integer;
     HaveLine, MappedPending, FoundCursor                                              : Boolean;

     Procedure StartLine;
      Var
       j : Integer;
      Begin
       Current := Nil;
       SetLength(Current, Columns);
       For j := 0 To Columns - 1 Do
        Begin
         Current[j]             := Blank;
         Current[j].SoftWrapped := False;
         Current[j].WrapPadding := False;
        End;
       Col      := 0;
       HaveLine := True;
      End;

     Procedure FinishLine(Wrapped : Boolean);
      Begin
       If Not HaveLine Then
        StartLine;
       Current[Columns - 1].SoftWrapped := Wrapped;
       Output.Add(Current);
       Current  := Nil;
       HaveLine := False;
      End;

     Procedure MakeRoom(Width : Integer);
      Begin
       If Not HaveLine Then
        StartLine;
       If Col + Width > Columns Then
        Begin
         If Col < Columns Then
          Current[Columns - 1].WrapPadding := True;
         FinishLine(True);
         StartLine;
        End;
      End;

    Begin
     Input  := TList<TTerminalLine>.Create;
     Output := TList<TTerminalLine>.Create;
     Try
      Bottom := Max(CursorY, fDECSaved[False].y);
      For y  := 0 To High(Screen) Do
       For x := 0 To High(Screen[y]) Do
        If (Screen[y][x].Text <> '') And (Screen[y][x].Text <> ' ') Then
         Bottom := Max(Bottom, y);
      For Source In fHistory Do
       Input.Add(Source);
      CursorRow    := fHistory.Count + CursorY;
      CursorCol    := CursorX + Ord(Pending);
      SavedRow     := fHistory.Count + fDECSaved[False].y;
      SavedCol     := fDECSaved[False].x + Ord(fDECSaved[False].WrapPending);
      SavedX       := 0;
      SavedY       := 0;
      SavedPending := False;
      FoundSaved   := False;
      For y        := 0 To Min(Bottom, High(Screen)) Do
       Input.Add(Screen[y]);
      HaveLine      := False;
      FoundCursor   := False;
      MappedPending := False;
      MappedX       := 0;
      MappedY       := 0;
      For y         := 0 To Input.Count - 1 Do
       Begin
        Source := Input[y];
        Count  := Length(Source);
        If (Count > 0) And Not Source[Count - 1].SoftWrapped Then
         Begin
          While (Count > 0) And ((Source[Count - 1].Text = ' ') Or (Source[Count - 1].Text = '')) And
          Not Source[Count - 1].Continuation Do
           Dec(Count);
         End;
        If y = CursorRow Then
         Count := Max(Count, CursorCol);
        If y = SavedRow Then
         Count := Max(Count, SavedCol);
        i      := 0;
        While i <= Count Do
         Begin
          If Not HaveLine Then
           StartLine;
          If (i < Count) And (i < Length(Source)) And Not Source[i].Continuation And Not Source[i].WrapPadding Then
           MakeRoom(Min(Columns, GraphemeWidth(Source[i].Text)));
          If (y = CursorRow) And (i = CursorCol) Then
           Begin
            MappedY       := Output.Count;
            MappedX       := Min(Columns - 1, Col);
            MappedPending := Col >= Columns;
            FoundCursor   := True;
           End;
          If (y = SavedRow) And (i = SavedCol) Then
           Begin
            SavedY       := Output.Count;
            SavedX       := Min(Columns - 1, Col);
            SavedPending := Col >= Columns;
            FoundSaved   := True;
           End;
          If i = Count Then
           Break;
          If (i < Length(Source)) And Not Source[i].Continuation And Not Source[i].WrapPadding Then
           Begin
            Cell             := Source[i];
            Cell.SoftWrapped := False;
            Cell.WrapPadding := False;
            Width            := Min(Columns, GraphemeWidth(Cell.Text));
            Current[Col]     := Cell;
            If Width = 2 Then
             Begin
              Current[Col + 1]              := Cell;
              Current[Col + 1].Text         := '';
              Current[Col + 1].Continuation := True;
             End;
            Inc(Col, Width);
           End;
          Inc(i);
         End;
        If (Length(Source) = 0) Or Not Source[High(Source)].SoftWrapped Then
         FinishLine(False);
       End;
      If HaveLine Then
       FinishLine(False);
      If Output.Count = 0 Then
       Begin
        StartLine;
        FinishLine(False);
       End;
      Start := Max(0, Output.Count - Rows);
      If FoundCursor Then
       Start := Min(Start, MappedY);
      fHistory.Clear;
      For y := 0 To Start - 1 Do
       fHistory.Add(Output[y]);
      If fHistoryLimit >= 0 Then
       While fHistory.Count > fHistoryLimit Do
        fHistory.Delete(0);
      AllocateScreen(NewScreen, Columns, Rows);
      For y         := 0 To Min(Rows - 1, Output.Count - Start - 1) Do
       NewScreen[y] := Output[Start + y];
      Screen        := NewScreen;
      NewScreen     := Nil;
      CursorX       := EnsureRange(MappedX, 0, Columns - 1);
      CursorY       := EnsureRange(MappedY - Start, 0, Rows - 1);
      NewPending    := MappedPending;
      If FoundSaved Then
       Begin
        fDECSaved[False].x           := SavedX;
        fDECSaved[False].y           := EnsureRange(SavedY - Start, 0, Rows - 1);
        fDECSaved[False].WrapPending := SavedPending;
       End;
     Finally
      Input.Free;
      Output.Free;
     End;
    End;

  Begin
   If (Columns < 1) Or (Rows < 1) Or (Columns > 32767) Or (Rows > 32767) Then
    Raise EArgumentOutOfRangeException.Create('Terminal size');
   If (Columns = fColumns) And (Rows = fRows) Then
    Exit;
   If Columns > Length(fTabStops) Then
    Begin
     TabIndex := Length(fTabStops);
     SetLength(fTabStops, Columns);
     While TabIndex < Columns Do
      Begin
       fTabStops[TabIndex] := (TabIndex > 0) And (TabIndex Mod 8 = 0);
       Inc(TabIndex);
      End;
    End;
   NewPending := False;
   If fAlternate Then
    Begin
     Reflow(fPrimary, fPrimaryX, fPrimaryY, fPrimaryWrapPending);
     fPrimaryWrapPending := NewPending;
     ResizeGrid(fScreen);
     NewPending := False;
    End
   Else
    Reflow(fScreen, fX, fY, fWrapPending);
   // Alternate content is clipped as a grid; its saved cursor must not reappear outside that grid later.
   With fDECSaved[True] Do
    Begin
     WrapPending := WrapPending And (x = Columns - 1);
     x           := EnsureRange(x, 0, Columns - 1);
     y           := EnsureRange(y, 0, Rows - 1);
    End;
   fColumns     := Columns;
   fRows        := Rows;
   fX           := Min(fX, Columns - 1);
   fY           := Min(fY, Rows - 1);
   fTop         := 0;
   fBottom      := Rows - 1;
   fWrapPending := NewPending;
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

 Function TTerminalBuffer.LineCells(Index : Integer) : TTerminalLine;
  Begin
   Result := Nil;
   If (Index < 0) Or (Index >= TotalLines) Then
    Exit;
   If fAlternate Then
    Result := fScreen[Index]
   Else If Index < fHistory.Count Then
    Result := fHistory[Index]
   Else
    Result := fScreen[Index - fHistory.Count];
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
     If Not c.Continuation And Not c.WrapPadding Then
      Result := Result + c.Text;
    End;
   Result := TrimRight(Result);
  End;

 Function TTerminalBuffer.LogicalLineText(Column, Row : Integer; Out CharacterIndex : Integer) : String;
  Const
   Limit = 65536;
  Var
   First, Last, y, x, Target, MaxRows : Integer;
   Cell                               : TTerminalCell;
   Builder                            : TStringBuilder;
  Begin
   Result         := '';
   CharacterIndex := -1;
   If (Column < 0) Or (Column >= fColumns) Or (Row < 0) Or (Row >= TotalLines) Then
    Exit;
   If GetCell(Column, Row).WrapPadding Then
    Exit;
   While (Column > 0) And GetCell(Column, Row).Continuation Do
    Dec(Column);
   First   := Row;
   Last    := Row;
   MaxRows := Max(1, Limit Div fColumns);
   While (First > 0) And GetCell(fColumns - 1, First - 1).SoftWrapped Do
    Begin
     Dec(First);
     If Last - First + 1 > MaxRows Then
      Exit;
    End;
   While (Last + 1 < TotalLines) And GetCell(fColumns - 1, Last).SoftWrapped Do
    Begin
     Inc(Last);
     If Last - First + 1 > MaxRows Then
      Exit;
    End;
   Builder := TStringBuilder.Create;
   Target  := -1;
   Try
    For y  := First To Last Do
     For x := 0 To fColumns - 1 Do
      Begin
       If (x = Column) And (y = Row) Then
        Target := Builder.Length;
       Cell    := GetCell(x, y);
       If Cell.Continuation Or Cell.WrapPadding Then
        Continue;
       If Builder.Length + Length(Cell.Text) > Limit Then
        Exit;
       Builder.Append(Cell.Text);
      End;
    Result := TrimRight(Builder.ToString);
    If (Target >= 0) And (Target < Length(Result)) Then
     CharacterIndex := Target;
   Finally
    Builder.Free;
   End;
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
        If Not c.Continuation And Not c.WrapPadding Then
         s := s + c.Text;
       End;
     If (y > StartY) And Not GetCell(fColumns - 1, y - 1).SoftWrapped Then
      Result := Result + sLineBreak;
     If (y < EndY) And GetCell(fColumns - 1, y).SoftWrapped Then
      Result := Result + s
     Else
      Result := Result + TrimRight(s);
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
