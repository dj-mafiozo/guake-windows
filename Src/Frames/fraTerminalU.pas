{$StackFrames On}
/// <summary>Native cell renderer and terminal keyboard, selection, clipboard and mouse input view.</summary>
Unit fraTerminalU;

/// <summary>DFM-backed native VCL terminal view. Session and buffer lifetimes belong to the controller.</summary>

Interface

 Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Graphics,
  Guake.VT, Guake.Sessions, Guake.Settings, Guake.AnimatedBackground;

 Type
  TTerminalPointEvent = Procedure(Sender : TObject; x, y : Integer; Var Handled : Boolean) Of Object;

  TTerminalKeyEvent = Procedure(Sender : TObject; Key : Word; Shift : TShiftState; Var Handled : Boolean) Of Object;

  TfraTerminal = Class(TFrame)
    surface      : TPaintBox;
    scroll       : TScrollBar;
    refreshTimer : TTimer;
    Procedure SurfacePaint    (Sender : TObject);
    Procedure SurfaceMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
    Procedure SurfaceMouseMove(Sender : TObject; Shift : TShiftState; x, y : Integer);
    Procedure SurfaceMouseUp  (Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
    Procedure SurfaceDblClick (Sender : TObject);
    Procedure ScrollChanged   (Sender : TObject);
    Procedure RefreshTick     (Sender : TObject);
    Procedure FrameResize     (Sender : TObject);
   Private
    Class Var fPrimarySelection : String;
   Private
    fMouseShift            : TShiftState;
    fMouseCellValid        : Boolean;
    fReportedMouseCell     : TPoint;
    fMouseProtocolRevision : Int64;
    fMouseColumns          : Integer;
    fMouseRows             : Integer;
    Procedure RememberSelection;
    Procedure SelectWordAt(x, y : Integer);
    Procedure PasteText   (Const Value : String);
   Private
    fRasterLines       : TArray<TTerminalLine>;
    fDirtyRows         : TArray<Boolean>;
    fFullRasterDirty   : Boolean;
    fMaskValid         : Boolean;
    fRasterCursorRow   : Integer;
    fRasterRowCount    : UInt64;
    fBlinkRows         : TArray<Boolean>;
    fHasBlinkRows      : Boolean;
    fTextBlinkElapsed  : UInt64;
    fTextBlinkOff      : Boolean;
    fAlphaTextBlinkOff : Boolean;
    fOpaqueSurface     : TBitmap;
    fAsciiClip         : Array[0..1] Of HRGN;
    fClipColumns       : Integer;
    fClipRows          : Integer;
    fClipWidth         : Integer;
    fClipHeight        : Integer;
    Procedure PrepareAsciiClips;
   Private
    fCaptureBackgroundOnly : Boolean;
    fVisualRevision        : Int64;
    fAlphaVisualRevision   : Int64;
    fAlphaBufferRevision   : Int64;
    fAlphaSurface          : TBitmap;
    fAlphaOpacity          : Byte;
    fAlphaScroll           : Integer;
    fAlphaCursor           : Boolean;
    fAlphaFocused          : Boolean;
    fAlphaRenderCount      : UInt64;
    fBackgroundDirty       : Boolean;
    fAnimation             : TAnimatedBackground;
    fBackgroundTick        : UInt64;
    fColorSurface          : TBitmap;
    fBackSurface           : TBitmap;
    fMaskSurface           : TBitmap;
    fOnCtrlClick           : TTerminalPointEvent;
    fConsumedClick         : Boolean;
    fOnVisualChanged       : TNotifyEvent;
    Procedure InvalidateSurface(Full : Boolean = True);
    Procedure PaintSurface     (Canvas : TCanvas; Mask : Boolean; Backdrop : Boolean = True; Incremental : Boolean = False);
   Private
    fBackground        : TPicture;
    fSession           : TTerminalSession;
    fSettings          : TGuakeSettings;
    fCellWidth         : Integer;
    fCellHeight        : Integer;
    fPalette           : Array[0..17] Of TColor;
    fLastRevision      : Int64;
    fOldMaximum        : Integer;
    fLastCursorVisible : Boolean;
    fSelectionStart    : TPoint;
    fSelectionEnd      : TPoint;
    fSelecting         : Boolean;
    fMouseAnchor       : TPoint;
    fHasSelection      : Boolean;
    fSuppressChar      : Boolean;
    fKeypadPhysical    : Boolean;
    fExtendedKey       : Boolean;
    fSurrogate         : Char;
    fOnActivate        : TNotifyEvent;
    fOnShortcut        : TTerminalKeyEvent;
    Function  MouseCell         (x, y : Integer)                              : TPoint;
    Function  IsSelected        (x, y : Integer)                              : Boolean;
    Function  ResolveColor      (Value : Integer; Foreground, Bold : Boolean) : TColor;
    Procedure SendMouse         (Button : Integer; Release : Boolean; Shift : TShiftState; x, y : Integer);
    Function  ApplicationMouseAt(x, y : Integer)                              : Boolean;
    Procedure Send              (Const Value : String);
    Function  EffectiveCursorShape                                            : Integer;
    Procedure FollowOutput;
    Procedure WMDropFiles       (Var Message : TMessage); Message WM_DROPFILES;
   Protected
    Procedure CreateWnd; Override;
    Procedure WndProc     (Var Message : TMessage); Override;
    Procedure KeyDown     (Var Key : Word; Shift : TShiftState); Override;
    Procedure KeyPress    (Var Key : Char); Override;
    Function  DoMouseWheel(Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint) : Boolean; Override;
   Public
    /// <summary>Releases the cached background graphic.</summary>
    Destructor Destroy; Override;
    /// <summary>Draws the configured image behind default-background cells in scale, tile, center or stretch mode.</summary>
    Procedure DrawBackground(Canvas : TCanvas; Const Bounds : TRect);
    /// <summary>Renders foreground coverage and background opacity into premultiplied ARGB.</summary>
    Procedure RenderAlpha(Destination : TBitmap; Opacity : Byte);
    /// <summary>Resolves visibility and blink phase consistently for paint, alpha cache and timer updates.</summary>
    Function CursorVisibleAt(Tick : UInt64) : Boolean;
    /// <summary>Suppresses a duplicate surface paint while the parent captures native window chrome.</summary>
    Property CaptureBackgroundOnly : Boolean Read fCaptureBackgroundOnly Write fCaptureBackgroundOnly;
    /// <summary>Counts actual alpha renders so idle and unchanged-pane reuse can be verified.</summary>
    Property AlphaRenderCount : UInt64 Read fAlphaRenderCount;
    /// <summary>Counts rows rasterized after snapshot comparison, excluding reused rows.</summary>
    Property RasterRowCount : UInt64 Read fRasterRowCount;
    /// <summary>Advances the configured GIF using elapsed milliseconds, without a second GUI timer.</summary>
    Function AdvanceBackground(ElapsedMilliseconds : Cardinal) : Boolean;
    /// <summary>Advances text blink deterministically; invalidates only if a visible row has blinking foreground.</summary>
    Function AdvanceTextBlink(ElapsedMilliseconds : Cardinal) : Boolean;
    Property OnVisualChanged : TNotifyEvent Read fOnVisualChanged Write fOnVisualChanged;
    /// <summary>Binds a borrowed session and settings. It never creates or closes a terminal process.</summary>
    Procedure Bind         (Session : TTerminalSession; Settings : TGuakeSettings);
    Procedure ApplySettings;
    Procedure CopySelection;
    Procedure Paste;
    Procedure SelectAll;
    Procedure HighlightText(Start, Count : Integer);
    Function  SelectedText : String;
    /// <summary>Resolves OSC 8 or a textual URL at a view pixel, including scrollback.</summary>
    Function LinkAt(x, y : Integer) : String;
    /// <summary>Returns the clicked physical row and its UTF-16 index without changing selection.</summary>
    Function TextAt(x, y : Integer; Out CharacterIndex : Integer) : String;
    Property OnCtrlClick : TTerminalPointEvent Read fOnCtrlClick Write fOnCtrlClick;
    Property Session     : TTerminalSession Read fSession;
    Property OnActivate  : TNotifyEvent Read fOnActivate Write fOnActivate;
    Property OnShortcut  : TTerminalKeyEvent Read fOnShortcut Write fOnShortcut;
  End;

Implementation

 Uses
  Guake.Composition, Guake.Links, System.Math, System.Character, System.StrUtils, Vcl.Clipbrd, Winapi.ShellAPI, Guake.Shells, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, Vcl.Imaging.GIFImg;
{$R *.dfm}

 Type
   TControlAccess = Class(TControl);

  Destructor TfraTerminal.Destroy;
   Begin
    If fAsciiClip[0] <> 0 Then
     DeleteObject(fAsciiClip[0]);
    If fAsciiClip[1] <> 0 Then
     DeleteObject(fAsciiClip[1]);
    fOpaqueSurface.Free;
    fAlphaSurface.Free;
    fAnimation.Free;
    fColorSurface.Free;
    fBackSurface.Free;
    fMaskSurface.Free;
    fBackground.Free;
    Inherited;
   End;

  Procedure TfraTerminal.DrawBackground(Canvas : TCanvas; Const Bounds : TRect);
   Var
    Target  : TRect;
    Ratio   : Double;
    x       : Integer;
    y       : Integer;
    Width   : Integer;
    Height  : Integer;
    Graphic : TGraphic;
   Begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := ResolveColor( -2, False, False);
    SetBkMode(Canvas.Handle, OPAQUE);
    Canvas.FillRect(Bounds);
    If (fBackground = Nil) Or (fBackground.Graphic = Nil) Or fBackground.Graphic.Empty Then
     Exit;
    Graphic := fBackground.Graphic;
    If fAnimation <> Nil Then
     Graphic := fAnimation.Bitmap;
    Width    := Graphic.Width;
    Height   := Graphic.Height;
    If (Width <= 0) Or (Height <= 0) Then
     Exit;
    If fSettings.General.BackgroundImageLayoutMode = 1 Then
     Begin
      y := Bounds.Top;
      While y < Bounds.Bottom Do
       Begin
        x := Bounds.Left;
        While x < Bounds.Right Do
         Begin
          Canvas.Draw(x, y, Graphic);
          Inc(x, Width);
         End;
        Inc(y, Height);
       End;
      Exit;
     End;
    Target := Bounds;
    Case fSettings.General.BackgroundImageLayoutMode Of
     0 :
      Begin
       Ratio         := Max((Bounds.Right - Bounds.Left) / Width, (Bounds.Bottom - Bounds.Top) / Height);
       Width         := Max(1, Round(Width * Ratio));
       Height        := Max(1, Round(Height * Ratio));
       Target.Left   := Bounds.Left + ((Bounds.Right - Bounds.Left) - Width) Div 2;
       Target.Top    := Bounds.Top + ((Bounds.Bottom - Bounds.Top) - Height) Div 2;
       Target.Right  := Target.Left + Width;
       Target.Bottom := Target.Top + Height;
      End;
     2 :
      Begin
       Target.Left   := Bounds.Left + ((Bounds.Right - Bounds.Left) - Width) Div 2;
       Target.Top    := Bounds.Top + ((Bounds.Bottom - Bounds.Top) - Height) Div 2;
       Target.Right  := Target.Left + Width;
       Target.Bottom := Target.Top + Height;
      End;
    End;
    Canvas.StretchDraw(Target, Graphic);
  End;

 Procedure TfraTerminal.CreateWnd;
  Begin
   Inherited;
   DragAcceptFiles(Handle, True);
  End;

 Procedure TfraTerminal.WndProc(Var Message : TMessage);
  Begin
   If Message.Msg = WM_GETDLGCODE Then
    Begin
     Message.Result := DLGC_WANTALLKEYS Or DLGC_WANTCHARS Or DLGC_WANTARROWS Or DLGC_WANTTAB;
     Exit;
    End;
   If (Message.Msg = WM_KEYDOWN) Or (Message.Msg = WM_SYSKEYDOWN) Then
    Begin
     fExtendedKey    := (Message.LParam And $01000000) <> 0;
     fKeypadPhysical := Not fExtendedKey;
     Try
      Inherited;
     Finally
      fKeypadPhysical := False;
      fExtendedKey    := False;
     End;
    End
   Else
    Inherited;
   If Not(csDestroying In ComponentState) And (fSession <> Nil) Then
    If (Message.Msg = WM_SETFOCUS) Or (Message.Msg = WM_KILLFOCUS) Then
     Begin
      InvalidateSurface(False);
      If Not fSession.Exited And fSession.Buffer.FocusReporting Then
       If Message.Msg = WM_SETFOCUS Then
        fSession.SendText(#27'[I')
       Else
        fSession.SendText(#27'[O');
     End;
  End;

 Procedure TfraTerminal.Bind(Session : TTerminalSession; Settings : TGuakeSettings);
  Begin
   fMouseCellValid   := False;
   fSession          := Session;
   fSettings         := Settings;
   fLastRevision     := -1;
   fTextBlinkElapsed := 0;
   fTextBlinkOff     := False;
   fHasBlinkRows     := False;
   fBlinkRows        := Nil;
   ApplySettings;
   refreshTimer.Enabled := Session <> Nil;
   RefreshTick(Nil);
  End;

 Procedure TfraTerminal.ApplySettings;
  Var
   Colors : TArray<String>;
   i      : Integer;
   p      : Integer;
   Size   : Integer;
   s      : String;
   Name   : String;
  Begin
   fBackgroundDirty := True;
   If fSettings = Nil Then
    Exit;
   If fBackground = Nil Then
    fBackground := TPicture.Create;
   FreeAndNil(fAnimation);
   fBackgroundTick := GetTickCount64;
   fBackground.Assign(Nil);
   If fSettings.General.BackgroundImageFile <> '' Then
    Try
     fBackground.LoadFromFile(fSettings.General.BackgroundImageFile);
    Except
     On E : Exception Do
      Begin
       fBackground.Assign(Nil);
       OutputDebugString(PChar('Guake background image: ' + E.ClassName + ': ' + E.Message + sLineBreak + E.StackTrace));
      End;
    End;
   Font.Name := 'Consolas';
   Font.Size := 10;
   If Not fSettings.General.UseDefaultFont Then
    Begin
     s    := fSettings.Style.Font.Style;
     p    := LastDelimiter(' ', s);
     Size := StrToIntDef(Copy(s, p + 1, MaxInt), 10);
     Name := Copy(s, 1, p - 1);
     If (Name <> '') And Not SameText(Name, 'Monospace') Then
      Font.Name := Name;
     Font.Size  := EnsureRange(Size, 4, 72);
    End;
   Font.Quality := fqAntialiased;
   surface.Canvas.Font.Assign(Font);
   fCellWidth  := Max(1, Round(surface.Canvas.TextWidth('M') * fSettings.Style.Font.CellWidthScale));
   fCellHeight := Max(1, Round(surface.Canvas.TextHeight('Mg') * fSettings.Style.Font.CellHeightScale));
   Colors      := fSettings.Style.Font.Palette.Split([':']);
   For i       := 0 To 17 Do
    Begin
     fPalette[i] := clBlack;
     If i < Length(Colors) Then
      Begin
       s := Colors[i];
       If Copy(s, 1, 1) = '#' Then
        Delete(s, 1, 1);
       If Length(s) = 12 Then
        fPalette[i] := RGB(StrToIntDef('$' + Copy(s, 1, 4), 0) Div 257, StrToIntDef('$' + Copy(s, 5, 4), 0) Div 257, StrToIntDef('$' + Copy(s, 9, 4), 0) Div 257);
      End;
    End;
   If fBackground.Graphic Is TGIFImage Then
    fAnimation := TAnimatedBackground.Create(TGIFImage(fBackground.Graphic), ResolveColor( -2, False, False));
   If fAnimation <> Nil Then
    refreshTimer.Interval := 20
   Else
    refreshTimer.Interval := 100;
   scroll.Visible         := fSettings.General.UseScrollbar;
   If fSession <> Nil Then
    If fSettings.General.InfiniteHistory Then
     fSession.Buffer.SetHistoryLimit( -1)
    Else
     fSession.Buffer.SetHistoryLimit(fSettings.General.HistorySize);
   FrameResize(Nil);
   InvalidateSurface;
  End;

 Procedure TfraTerminal.FrameResize(Sender : TObject);
  Begin
   fMouseCellValid := False;
   If (fSession <> Nil) And (fCellWidth > 0) And (fCellHeight > 0) Then
    fSession.Resize(Max(2, (surface.Width - 8) Div fCellWidth), Max(1, (surface.Height - 8) Div fCellHeight));
  End;

 Function TfraTerminal.ResolveColor(Value : Integer; Foreground, Bold : Boolean) : TColor;
  Const
   Levels : Array[0..5] Of Integer = (0, 95, 135, 175, 215, 255);
  Var
   n : Integer;
   r : Integer;
   g : Integer;
   b : Integer;
  Begin
   If Value = -1 Then
    Begin
     If (fSession <> Nil) And (fSession.CustomForeground >= 0) Then
      Exit(fSession.CustomForeground);
     Exit(fPalette[16]);
    End;
   If Value = -2 Then
    Begin
     If (fSession <> Nil) And (fSession.CustomBackground >= 0) Then
      Exit(fSession.CustomBackground);
     Exit(fPalette[17]);
    End;
   If (Value And $01000000) <> 0 Then
    Exit(Value And $FFFFFF);
   If Value < 16 Then
    Begin
     If Foreground And Bold And fSettings.Style.Font.BoldIsBright And (Value < 8) Then
      Inc(Value, 8);
     Exit(fPalette[EnsureRange(Value, 0, 15)]);
    End;
   If Value < 232 Then
    Begin
     n := Value - 16;
     r := Levels[n Div 36];
     g := Levels[(n Div 6) Mod 6];
     b := Levels[n Mod 6];
    End
   Else
    Begin
     r := 8 + (Value - 232) * 10;
     g := r;
     b := r;
    End;
   Result := RGB(r, g, b);
  End;

 Function TfraTerminal.IsSelected(x, y : Integer) : Boolean;
  Var
   a : Int64;
   b : Int64;
   p : Int64;
   t : Int64;
  Begin
   Result := False;
   If Not fHasSelection Or (fSession = Nil) Then
    Exit;
   a := Int64(fSelectionStart.y) * fSession.Buffer.Columns + fSelectionStart.x;
   b := Int64(fSelectionEnd.y) * fSession.Buffer.Columns + fSelectionEnd.x;
   p := Int64(y) * fSession.Buffer.Columns + x;
   If a > b Then
    Begin
     t := a;
     a := b;
     b := t;
    End;
   Result := (p >= a) And (p <= b);
  End;

 Procedure TfraTerminal.PrepareAsciiClips;
  Var
   Points   : TArray<TPoint>;
   Counts   : TArray<Integer>;
   Parity   : Integer;
   x        : Integer;
   Count    : Integer;
   MaxCount : Integer;
   Left     : Integer;
   Bottom   : Integer;
  Begin
   If (fClipColumns = fSession.Buffer.Columns) And (fClipRows = fSession.Buffer.Rows) And
   (fClipWidth = fCellWidth) And (fClipHeight = fCellHeight) Then
    Exit;
   // Adjacent rows merge into the same vertical strip; store each strip only once.
   MaxCount := (fSession.Buffer.Columns + 1) Div 2;
   SetLength(Points, MaxCount * 4);
   SetLength(Counts, MaxCount);
   Bottom     := 4 + fSession.Buffer.Rows * fCellHeight;
   For Parity := 0 To 1 Do
    Begin
     If fAsciiClip[Parity] <> 0 Then
      DeleteObject(fAsciiClip[Parity]);
     fAsciiClip[Parity] := 0;
     Count              := 0;
     x                  := Parity;
     While x < fSession.Buffer.Columns Do
      Begin
       Left                  := 4 + x * fCellWidth;
       Points[Count * 4]     := Point(Left, 4);
       Points[Count * 4 + 1] := Point(Left + fCellWidth, 4);
       Points[Count * 4 + 2] := Point(Left + fCellWidth, Bottom);
       Points[Count * 4 + 3] := Point(Left, Bottom);
       Counts[Count]         := 4;
       Inc(Count);
       Inc(x, 2);
      End;
     fAsciiClip[Parity] := CreatePolyPolygonRgn(Points[0], Counts[0], Count, WINDING);
     Win32Check(fAsciiClip[Parity] <> 0);
    End;
   fClipColumns := fSession.Buffer.Columns;
   fClipRows    := fSession.Buffer.Rows;
   fClipWidth   := fCellWidth;
   fClipHeight  := fCellHeight;
  End;

 Procedure TfraTerminal.PaintSurface(Canvas : TCanvas; Mask : Boolean; Backdrop, Incremental : Boolean);
  Var
   x               : Integer;
   y               : Integer;
   WorldY          : Integer;
   CursorRow       : Integer;
   CursorColumn    : Integer;
   CursorWidth     : Integer;
   CursorShape     : Integer;
   Temp            : Integer;
   c               : TTerminalCell;
   Fore            : TColor;
   Back            : TColor;
   r               : TRect;
   Style           : TFontStyles;
   TransparentCell : Boolean;
   Options         : Cardinal;
   Selected        : Boolean;
   Batch           : Boolean;
   NextCell        : TTerminalCell;
   RunText         : String;
   RunLength       : Integer;
   RunStart        : Integer;
   i               : Integer;
   Advances        : TArray<Integer>;
   Clip            : HRGN;
   ViewOrigin      : TPoint;
   WindowOrigin    : TPoint;
   Decoration      : TColor;
   UnderlineKind   : Integer;
   GlyphHidden     : Boolean;

   Procedure DrawDecorations;
    Var
     xx    : Integer;
     yy    : Integer;
     BaseY : Integer;
    Begin
     If GlyphHidden Then
      Exit;
     Canvas.Brush.Color := Fore;
     If c.Overline Then
      Canvas.FillRect(Rect(r.Left, r.Top + 1, r.Right, r.Top + 2));
     If Not c.Underline Or ((UnderlineKind = 1) And (c.UnderlineColor = -1)) Then
      Exit;
     Canvas.Brush.Color := Decoration;
     BaseY              := r.Bottom - 2;
     For xx             := r.Left To r.Right - 1 Do
      Begin
       yy := BaseY;
       Case UnderlineKind Of
        3 :
         yy := BaseY - Abs((xx Mod 4) - 2);
        4 :
         If (xx Mod 4) >= 2 Then
          Continue;
        5 :
         If (xx Mod 6) >= 4 Then
          Continue;
       End;
       Canvas.FillRect(Rect(xx, yy, xx + 1, yy + 1));
       If UnderlineKind = 2 Then
        Canvas.FillRect(Rect(xx, Max(r.Top, BaseY - 2), xx + 1, Max(r.Top, BaseY - 2) + 1));
      End;
    End;

   Function AsciiCell(Const Cell : TTerminalCell) : Boolean;
    Begin
     Result := (Length(Cell.Text) = 1) And Not Cell.Continuation And (Cell.Text[1] >= #32) And (Cell.Text[1] <= #126);
    End;

   Procedure DrawAsciiRun;
    Var
     Parity : Integer;
     j      : Integer;
     Saved  : Integer;
     Spaced : String;
    Begin
     For Parity := 0 To 1 Do
      Begin
       Spaced := RunText;
       For j  := 1 To RunLength Do
        If ((RunStart + j - 1) And 1) <> Parity Then
         Spaced[j] := ' ';
       Saved       := SaveDC(Canvas.Handle);
       Try
        CombineRgn(Clip, fAsciiClip[Parity], 0, RGN_COPY);
        OffsetRgn(Clip, ViewOrigin.x - WindowOrigin.x, ViewOrigin.y - WindowOrigin.y);
        ExtSelectClipRgn(Canvas.Handle, Clip, RGN_AND);
        ExtTextOut(Canvas.Handle, r.Left, r.Top, Options, @r, PChar(Spaced), RunLength, @Advances[0]);
       Finally
        RestoreDC(Canvas.Handle, Saved);
       End;
      End;
    End;

  Begin
   If Mask And Not Incremental Then
    Begin
     Canvas.Brush.Color := clBlack;
     Canvas.FillRect(surface.ClientRect);
    End
   Else If Not Mask And Backdrop Then
    DrawBackground(Canvas, surface.ClientRect);
   If (fSession = Nil) Or (fCellWidth = 0) Or (fCellHeight = 0) Then
    Exit;
   Canvas.Font.Assign(Font);
   Batch := (fSettings.Style.Font.CellWidthScale >= 1) And
   (Canvas.TextWidth('i') = Canvas.TextWidth('W'));
   Clip := 0;
   If Batch Then
    Begin
     PrepareAsciiClips;
     Clip := CreateRectRgn(0, 0, 0, 0);
     Win32Check(Clip <> 0);
     GetViewportOrgEx(Canvas.Handle, ViewOrigin);
     GetWindowOrgEx(Canvas.Handle, WindowOrigin);
    End;
   Try
    SetLength(Advances, fSession.Buffer.Columns);
    For i        := 0 To High(Advances) Do
     Advances[i] := fCellWidth;
    For y        := 0 To fSession.Buffer.Rows - 1 Do
     Begin
      If Incremental And Not fDirtyRows[y] Then
       Continue;
      x := 0;
      While x < fSession.Buffer.Columns Do
       Begin
        WorldY := scroll.Position + y;
        c      := fSession.Buffer.Cell[x, WorldY];
        If c.Continuation Then
         Begin
          Inc(x);
          Continue;
         End;
        If (c.Background = -2) And Not c.Inverse And Not c.Underline And Not c.Strike And Not c.Overline And Not IsSelected(x, WorldY) And
        ((c.Text = '') Or (c.Text = ' ')) Then
         Begin
          Inc(x);
          Continue;
         End;
        GlyphHidden := c.Conceal Or (c.Blink And fTextBlinkOff);
        Selected    := IsSelected(x, WorldY);
        Fore        := ResolveColor(c.Foreground, True, c.Bold);
        Back        := ResolveColor(c.Background, False, False);
        If c.Faint Then
         Fore := RGB((GetRValue(ColorToRGB(Fore)) + GetRValue(ColorToRGB(Back))) Div 2,
         (GetGValue(ColorToRGB(Fore)) + GetGValue(ColorToRGB(Back))) Div 2,
         (GetBValue(ColorToRGB(Fore)) + GetBValue(ColorToRGB(Back))) Div 2);
        If c.Inverse Or Selected Then
         Begin
          Temp := Fore;
          Fore := Back;
          Back := Temp;
         End;
        r := Rect(4 + x * fCellWidth, 4 + y * fCellHeight, 4 + (x + 1) * fCellWidth, 4 + (y + 1) * fCellHeight);
        If (x + 1 < fSession.Buffer.Columns) And fSession.Buffer.Cell[x + 1, WorldY].Continuation Then
         Inc(r.Right, fCellWidth);
        RunStart  := x;
        RunLength := 0;
        If Batch And AsciiCell(c) Then
         Begin
          SetLength(RunText, fSession.Buffer.Columns - x);
          While x + RunLength < fSession.Buffer.Columns Do
           Begin
            NextCell := fSession.Buffer.Cell[x + RunLength, WorldY];
            If Not AsciiCell(NextCell) Or (NextCell.Foreground <> c.Foreground) Or
            (NextCell.Background <> c.Background) Or (NextCell.Bold <> c.Bold) Or
            (NextCell.Italic <> c.Italic) Or (NextCell.Underline <> c.Underline) Or
            (NextCell.UnderlineStyle <> c.UnderlineStyle) Or (NextCell.UnderlineColor <> c.UnderlineColor) Or
            (NextCell.Faint <> c.Faint) Or (NextCell.Conceal <> c.Conceal) Or (NextCell.Blink <> c.Blink) Or
            (NextCell.Strike <> c.Strike) Or (NextCell.Overline <> c.Overline) Or
            (NextCell.Inverse <> c.Inverse) Or (IsSelected(x + RunLength, WorldY) <> Selected) Then
             Break;
            Inc(RunLength);
            RunText[RunLength] := NextCell.Text[1];
           End;
          SetLength(RunText, RunLength);
          r.Right := r.Left + RunLength * fCellWidth;
         End;
        Style := [];
        If c.Bold And fSettings.Style.Font.AllowBold Then
         Include(Style, fsBold);
        If c.Italic Then
         Include(Style, fsItalic);
        UnderlineKind := Max(1, c.UnderlineStyle);
        If Not GlyphHidden Then
         Begin
          If c.Underline And (UnderlineKind = 1) And (c.UnderlineColor = -1) Then
           Include(Style, fsUnderline);
          If c.Strike Then
           Include(Style, fsStrikeOut);
         End;
        Canvas.Font.Style := Style;
        TransparentCell   := (c.Background = -2) And Not c.Inverse And Not Selected;
        If Mask Then
         Begin
          Fore := clWhite;
          Back := clWhite;
         End;
        Options := ETO_CLIPPED;
        If TransparentCell Then
         SetBkMode(Canvas.Handle, TRANSPARENT)
        Else
         Begin
          SetBkMode(Canvas.Handle, OPAQUE);
          Options := Options Or ETO_OPAQUE;
         End;
        Decoration := Fore;
        If c.UnderlineColor <> -1 Then
         Decoration := ResolveColor(c.UnderlineColor, True, False);
        If Mask Then
         Decoration := clWhite;
        SetTextColor(Canvas.Handle, ColorToRGB(Fore));
        SetBkColor(Canvas.Handle, ColorToRGB(Back));
        If RunLength > 0 Then
         Begin
          If GlyphHidden Then
           RunText := StringOfChar(' ', RunLength);
          DrawAsciiRun;
          x := RunStart + RunLength;
         End
        Else
         Begin
          If GlyphHidden Then
           ExtTextOut(Canvas.Handle, r.Left, r.Top, Options, @r, Nil, 0, Nil)
          Else
           ExtTextOut(Canvas.Handle, r.Left, r.Top, Options, @r, PChar(c.Text), Length(c.Text), Nil);
          Inc(x);
         End;
        DrawDecorations;
       End;
     End;
    If CursorVisibleAt(GetTickCount64) Then
     Begin
      CursorRow := fSession.Buffer.TotalLines - fSession.Buffer.Rows + fSession.Buffer.CursorY - scroll.Position;
      If (CursorRow >= 0) And (CursorRow < fSession.Buffer.Rows) Then
       Begin
        CursorColumn := fSession.Buffer.CursorX;
        WorldY       := fSession.Buffer.TotalLines - fSession.Buffer.Rows + fSession.Buffer.CursorY;
        While (CursorColumn > 0) And fSession.Buffer.Cell[CursorColumn, WorldY].Continuation Do
         Dec(CursorColumn);
        c           := fSession.Buffer.Cell[CursorColumn, WorldY];
        CursorWidth := 1;
        If (CursorColumn + 1 < fSession.Buffer.Columns) And fSession.Buffer.Cell[CursorColumn + 1, WorldY].Continuation Then
         CursorWidth := 2;
        r            := Rect(4 + CursorColumn * fCellWidth, 4 + CursorRow * fCellHeight,
        4 + (CursorColumn + CursorWidth) * fCellWidth, 4 + (CursorRow + 1) * fCellHeight);
        Fore := ResolveColor(c.Foreground, True, c.Bold);
        Back := ResolveColor(c.Background, False, False);
        If c.Inverse Then
         Begin
          Temp := Fore;
          Fore := Back;
          Back := Temp;
         End;
        If Mask Then
         Canvas.Brush.Color := clWhite
        Else
         Canvas.Brush.Color := Fore;
        CursorShape         := EffectiveCursorShape;
        Case CursorShape Of
         1 : r.Right := r.Left + 2;
         2 : r.Top := r.Bottom - 2;
        End;
        If (CursorShape = 0) And Not Focused Then
         Canvas.FrameRect(r)
        Else
         Canvas.FillRect(r);
        If (CursorShape = 0) And Focused And Not Mask Then
         Begin
          // The coverage mask stays opaque for the whole block, including inverted glyph pixels.
          Canvas.Font.Assign(Font);
          Style := [];
          If c.Bold And fSettings.Style.Font.AllowBold Then
           Include(Style, fsBold);
          If c.Italic Then
           Include(Style, fsItalic);
          UnderlineKind := Max(1, c.UnderlineStyle);
          GlyphHidden   := c.Conceal Or (c.Blink And fTextBlinkOff);
          If Not GlyphHidden Then
           Begin
            If c.Underline And (UnderlineKind = 1) And (c.UnderlineColor = -1) Then
             Include(Style, fsUnderline);
            If c.Strike Then
             Include(Style, fsStrikeOut);
           End;
          Canvas.Font.Style := Style;
          Canvas.Font.Color := Back;
          SetBkMode(Canvas.Handle, TRANSPARENT);
          If Not GlyphHidden Then
           ExtTextOut(Canvas.Handle, r.Left, r.Top, ETO_CLIPPED, @r, PChar(c.Text), Length(c.Text), Nil);
          Fore := Back;
          If c.UnderlineColor = -1 Then
           Decoration := Fore
          Else
           Decoration := ResolveColor(c.UnderlineColor, True, False);
          DrawDecorations;
         End;
       End;
     End;
   Finally
    If Clip <> 0 Then
     DeleteObject(Clip);
   End;
  End;

/// <summary>Application-selected cursor styles override preferences until DECSCUSR 0 or RIS.</summary>

 Function TfraTerminal.EffectiveCursorShape : Integer;
  Begin
   Result := fSettings.Style.CursorShape;
   If fSession = Nil Then
    Exit;
   Case fSession.Buffer.CursorStyle Of
    1, 2 : Result := 0;
    3, 4 : Result := 2;
    5, 6 : Result := 1;
   End;
  End;

 Function TfraTerminal.CursorVisibleAt(Tick : UInt64) : Boolean;
  Var
   Style    : Integer;
   Interval : Cardinal;
  Begin
   Result := False;
   If (fSession = Nil) Or Not IsWindowVisible(Handle) Or Not fSession.Buffer.CursorVisible Or fSession.Exited Then
    Exit;
   // Unfocused cursors remain visible and steady; only the active cursor blinks.
   If Not Focused Then
    Exit(True);
   Style    := fSession.Buffer.CursorStyle;
   Interval := 500;
   If Style = 0 Then
    Case fSettings.Style.CursorBlinkMode Of
     0 : Interval := GetCaretBlinkTime;
     2 : Interval := INFINITE;
    End
   Else If Style Mod 2 = 0 Then
    Interval := INFINITE;
   Result    := (Interval = 0) Or (Interval = INFINITE);
   If Not Result Then
    Result := (Tick Div Interval) Mod 2 = 0;
  End;

 Procedure TfraTerminal.InvalidateSurface(Full : Boolean);
  Begin
   fFullRasterDirty := fFullRasterDirty Or Full;
   Inc(fVisualRevision);
   // A layered parent presents one bitmap; invalidating the child would draw the same terminal again.
   If Not Assigned(fOnVisualChanged) Or (GetParentForm(Self) = Nil) Or
   ((GetWindowLongPtr(GetParentForm(Self).Handle, GWL_EXSTYLE) And WS_EX_LAYERED) = 0) Then
    surface.Invalidate;
   If Assigned(fOnVisualChanged) Then
    fOnVisualChanged(Self);
  End;

 Procedure TfraTerminal.SurfacePaint(Sender : TObject);
  Begin
   If fCaptureBackgroundOnly Then
    Exit;
   If Assigned(fOnVisualChanged) And (GetParentForm(Self) <> Nil) And
   ((GetWindowLongPtr(GetParentForm(Self).Handle, GWL_EXSTYLE) And WS_EX_LAYERED) <> 0) And
   Not(csPaintCopy In ControlState) Then
    Exit;
   If fOpaqueSurface = Nil Then
    fOpaqueSurface := TBitmap.Create;
   RenderAlpha(fOpaqueSurface, 255);
   BitBlt(surface.Canvas.Handle, 0, 0, surface.Width, surface.Height, fOpaqueSurface.Canvas.Handle, 0, 0, SRCCOPY);
  End;

/// <summary>Reports only blinking foreground that can affect a visible cell, excluding conceal and wide continuations.</summary>

 Function LineHasBlink(Const Line : TTerminalLine; Columns : Integer) : Boolean;
  Var
   x : Integer;
  Begin
   Result := False;
   For x  := 0 To Min(High(Line), Columns - 1) Do
    If Line[x].Blink And Not Line[x].Conceal And Not Line[x].Continuation And
    (((Line[x].Text <> '') And (Line[x].Text <> ' ')) Or Line[x].Underline Or Line[x].Strike Or Line[x].Overline) Then
     Exit(True);
  End;

 Procedure TfraTerminal.RenderAlpha(Destination : TBitmap; Opacity : Byte);
  Var
   Bitmap       : TBitmap;
   Revision     : Int64;
   Full         : Boolean;
   CurrentLine  : TTerminalLine;
   Row          : Integer;
   CursorRow    : Integer;
   Bounds       : TRect;
   Cursor       : Boolean;
   SourceBase   : PByte;
   TargetBase   : PByte;
   SourceStride : NativeInt;
   TargetStride : NativeInt;
   y            : Integer;
  Begin
   If fSession = Nil Then
    Begin
     If fColorSurface = Nil Then
      fColorSurface := TBitmap.Create;
     If fBackSurface = Nil Then
      fBackSurface := TBitmap.Create;
     If fMaskSurface = Nil Then
      fMaskSurface := TBitmap.Create;
     For Bitmap In TArray<TBitmap>.Create(fColorSurface, fBackSurface, fMaskSurface) Do
      Begin
       Bitmap.PixelFormat := pf32bit;
       Bitmap.SetSize(surface.Width, surface.Height);
      End;
     DrawBackground(fColorSurface.Canvas, surface.ClientRect);
     DrawBackground(fBackSurface.Canvas, surface.ClientRect);
     fMaskSurface.Canvas.Brush.Color := clBlack;
     fMaskSurface.Canvas.FillRect(surface.ClientRect);
     ComposeTerminalAlpha(fColorSurface, fBackSurface, fMaskSurface, Destination, Opacity);
     Exit;
    End;
   Revision := -1;
   If fSession <> Nil Then
    Revision := fSession.Buffer.Revision;
   Cursor    := CursorVisibleAt(GetTickCount64);
   If (fAlphaSurface = Nil) Or (fAlphaSurface.Width <> surface.Width) Or (fAlphaSurface.Height <> surface.Height) Or
   (fAlphaVisualRevision <> fVisualRevision) Or (fAlphaBufferRevision <> Revision) Or
   (fAlphaOpacity <> Opacity) Or (fAlphaScroll <> scroll.Position) Or (fAlphaCursor <> Cursor) Or (fAlphaFocused <> Focused) Or
   (fHasBlinkRows And (fAlphaTextBlinkOff <> fTextBlinkOff)) Then
    Begin
     Full := fFullRasterDirty Or fBackgroundDirty Or (fBackSurface = Nil) Or
     (fAlphaScroll <> scroll.Position) Or (Length(fRasterLines) <> fSession.Buffer.Rows) Or
     ((Opacity < 255) And Not fMaskValid) Or (fBackSurface.Width <> surface.Width) Or (fBackSurface.Height <> surface.Height);
     If fColorSurface = Nil Then
      fColorSurface := TBitmap.Create;
     If fBackSurface = Nil Then
      fBackSurface := TBitmap.Create;
     If fMaskSurface = Nil Then
      fMaskSurface := TBitmap.Create;
     If fAlphaSurface = Nil Then
      fAlphaSurface := TBitmap.Create;
     If (fBackSurface.Width <> surface.Width) Or (fBackSurface.Height <> surface.Height) Then
      fBackgroundDirty := True;
     For Bitmap In TArray<TBitmap>.Create(fColorSurface, fBackSurface, fMaskSurface) Do
      Begin
       Bitmap.PixelFormat := pf32bit;
       Bitmap.SetSize(surface.Width, surface.Height);
      End;
     If fBackgroundDirty Then
      Begin
       DrawBackground(fBackSurface.Canvas, surface.ClientRect);
       fBackgroundDirty := False;
      End;
     SetLength(fDirtyRows, fSession.Buffer.Rows);
     SetLength(fRasterLines, fSession.Buffer.Rows);
     SetLength(fBlinkRows, fSession.Buffer.Rows);
     fHasBlinkRows := False;
     For Row       := 0 To fSession.Buffer.Rows - 1 Do
      Begin
       CurrentLine     := fSession.Buffer.LineCells(scroll.Position + Row);
       fDirtyRows[Row] := Full Or (Length(CurrentLine) <> Length(fRasterLines[Row])) Or
       ((Length(CurrentLine) > 0) And Not CompareMem(@CurrentLine[0], @fRasterLines[Row][0], Length(CurrentLine) * SizeOf(TTerminalCell)));
       If fDirtyRows[Row] Then
        Begin
         fRasterLines[Row] := Copy(CurrentLine);
         fBlinkRows[Row]   := LineHasBlink(CurrentLine, fSession.Buffer.Columns);
        End;
       fDirtyRows[Row] := fDirtyRows[Row] Or (fBlinkRows[Row] And (fAlphaTextBlinkOff <> fTextBlinkOff));
       fHasBlinkRows   := fHasBlinkRows Or fBlinkRows[Row];
      End;
     If (fRasterCursorRow >= 0) And (fRasterCursorRow < Length(fDirtyRows)) Then
      fDirtyRows[fRasterCursorRow] := True;
     CursorRow                     := -1;
     If Cursor Then
      CursorRow := fSession.Buffer.TotalLines - fSession.Buffer.Rows + fSession.Buffer.CursorY - scroll.Position;
     If (CursorRow >= 0) And (CursorRow < Length(fDirtyRows)) Then
      fDirtyRows[CursorRow] := True;
     fRasterCursorRow       := CursorRow;
     If Full Then
      Begin
       BitBlt(fColorSurface.Canvas.Handle, 0, 0, surface.Width, surface.Height, fBackSurface.Canvas.Handle, 0, 0, SRCCOPY);
       fMaskSurface.Canvas.Brush.Color := clBlack;
       fMaskSurface.Canvas.FillRect(surface.ClientRect);
      End
     Else
      For Row := 0 To High(fDirtyRows) Do
       If fDirtyRows[Row] Then
        Begin
         Bounds := Rect(0, 4 + Row * fCellHeight, surface.Width, 4 + (Row + 1) * fCellHeight);
         BitBlt(fColorSurface.Canvas.Handle, Bounds.Left, Bounds.Top, Bounds.Right, fCellHeight,
         fBackSurface.Canvas.Handle, Bounds.Left, Bounds.Top, SRCCOPY);
         fMaskSurface.Canvas.Brush.Color := clBlack;
         fMaskSurface.Canvas.FillRect(Bounds);
        End;
     For Row := 0 To High(fDirtyRows) Do
      If fDirtyRows[Row] Then
       Inc(fRasterRowCount);
     PaintSurface(fColorSurface.Canvas, False, False, True);
     If Opacity < 255 Then
      PaintSurface(fMaskSurface.Canvas, True, False, True);
     fMaskValid       := Opacity < 255;
     fFullRasterDirty := False;
     ComposeTerminalAlpha(fColorSurface, fBackSurface, fMaskSurface, fAlphaSurface, Opacity);
     fAlphaVisualRevision := fVisualRevision;
     fAlphaBufferRevision := Revision;
     fAlphaOpacity        := Opacity;
     fAlphaScroll         := scroll.Position;
     fAlphaCursor         := Cursor;
     fAlphaFocused        := Focused;
     fAlphaTextBlinkOff   := fTextBlinkOff;
     Inc(fAlphaRenderCount);
    End;
   Destination.PixelFormat := pf32bit;
   Destination.SetSize(surface.Width, surface.Height);
   Destination.AlphaFormat := afPremultiplied;
   If (surface.Width = 0) Or (surface.Height = 0) Then
    Exit;
   SourceBase   := fAlphaSurface.ScanLine[0];
   TargetBase   := Destination.ScanLine[0];
   SourceStride := 0;
   TargetStride := 0;
   If surface.Height > 1 Then
    Begin
     SourceStride := NativeInt(fAlphaSurface.ScanLine[1]) - NativeInt(SourceBase);
     TargetStride := NativeInt(Destination.ScanLine[1]) - NativeInt(TargetBase);
    End;
   For y := 0 To surface.Height - 1 Do
    Move(PByte(NativeInt(SourceBase) + y * SourceStride)^, PByte(NativeInt(TargetBase) + y * TargetStride)^, surface.Width * SizeOf(TRGBQuad));
  End;

 Function TfraTerminal.AdvanceBackground(ElapsedMilliseconds : Cardinal) : Boolean;
  Begin
   Result := (fAnimation <> Nil) And fAnimation.Advance(ElapsedMilliseconds);
   If Result Then
    Begin
     fBackgroundDirty := True;
     InvalidateSurface;
    End;
  End;

 Function TfraTerminal.AdvanceTextBlink(ElapsedMilliseconds : Cardinal) : Boolean;
  Var
   Previous : Boolean;
  Begin
   Previous          := fTextBlinkOff;
   fTextBlinkElapsed := (fTextBlinkElapsed + ElapsedMilliseconds) Mod 1000;
   fTextBlinkOff     := fTextBlinkElapsed >= 500;
   Result            := (Previous <> fTextBlinkOff) And fHasBlinkRows And (fSession <> Nil);
   If Result Then
    InvalidateSurface(False);
  End;

 Procedure TfraTerminal.FollowOutput;
  Begin
   If fSession <> Nil Then
    scroll.Position := Max(0, fSession.Buffer.TotalLines - fSession.Buffer.Rows);
  End;

 Procedure TfraTerminal.RefreshTick(Sender : TObject);
  Var
   Maximum       : Integer;
   Position      : Integer;
   Follow        : Boolean;
   Changed       : Boolean;
   CursorVisible : Boolean;
   Tick          : UInt64;
  Begin
   Tick := GetTickCount64;
   If IsWindowVisible(Handle) Then
    Begin
     AdvanceBackground(Min(Tick - fBackgroundTick, UInt64(60000)));
     AdvanceTextBlink(Min(Tick - fBackgroundTick, UInt64(60000)));
    End;
   fBackgroundTick := Tick;
   If fSession = Nil Then
    Exit;
   Changed := fLastRevision <> fSession.Buffer.Revision;
   If Changed Then
    Begin
     Maximum  := Max(0, fSession.Buffer.TotalLines - fSession.Buffer.Rows);
     Follow   := (scroll.Position >= fOldMaximum) Or fSettings.General.ScrollOutput;
     Position := scroll.Position;
     If Follow Then
      Position := Maximum;
     // Delphi 10.2 rejects a range smaller than the PREVIOUS page size.
     // Reset it before changing the range, including the no-history case.
     scroll.PageSize := 0;
     scroll.SetParams(EnsureRange(Position, 0, Maximum), 0, Max(fSession.Buffer.Rows, fSession.Buffer.TotalLines - 1));
     scroll.PageSize    := fSession.Buffer.Rows;
     scroll.LargeChange := fSession.Buffer.Rows;
     scroll.Position    := EnsureRange(Position, 0, Maximum);
     fOldMaximum        := Maximum;
     fLastRevision      := fSession.Buffer.Revision;
    End;
   CursorVisible := CursorVisibleAt(GetTickCount64);
   If Changed Or (CursorVisible <> fLastCursorVisible) Then
    InvalidateSurface(False);
   fLastCursorVisible := CursorVisible;
  End;

 Procedure TfraTerminal.ScrollChanged(Sender : TObject);
  Begin
   If fSession <> Nil Then
    If scroll.Position > Max(0, fSession.Buffer.TotalLines - fSession.Buffer.Rows) Then
     scroll.Position := Max(0, fSession.Buffer.TotalLines - fSession.Buffer.Rows);
   InvalidateSurface;
  End;

 Procedure TfraTerminal.Send(Const Value : String);
  Begin
   If (fSession = Nil) Or fSession.Exited Then
    Exit;
   If fHasSelection Then
    Begin
     fHasSelection := False;
     InvalidateSurface;
    End;
   If fSettings.General.ScrollKeystroke Then
    FollowOutput;
   fSession.SendText(Value);
  End;

 Procedure TfraTerminal.KeyDown(Var Key : Word; Shift : TShiftState);
  Const
   FNumbers : Array[0..11] Of Integer = (0, 0, 0, 0, 15, 17, 18, 19, 20, 21, 23, 24);
  Var
   Handled  : Boolean;
   s        : String;
   Final    : String;
   Modifier : Integer;
   Number   : Integer;
   Keypad   : Char;
  Begin
   Inherited;
   Handled := False;
   If Assigned(fOnShortcut) Then
    fOnShortcut(Self, Key, Shift, Handled);
   If Handled Then
    Begin
     Key           := 0;
     fSuppressChar := True;
     Exit;
    End;
   If fSession = Nil Then
    Exit;
   Modifier := 1 + Ord(ssShift In Shift) + 2 * Ord(ssAlt In Shift) + 4 * Ord(ssCtrl In Shift);
   Final    := '';
   s        := '';
   Case Key Of
    VK_UP    : Final := 'A';
    VK_DOWN  : Final := 'B';
    VK_RIGHT : Final := 'C';
    VK_LEFT  : Final := 'D';
    VK_HOME  : Final := 'H';
    VK_END   : Final := 'F';
   End;
   If Final <> '' Then
    If Modifier <> 1 Then
     s := Format(#27'[1;%d%s', [Modifier, Final])
    Else If fSession.Buffer.ApplicationCursor Then
     s := #27'O' + Final
    Else
     s := #27'[' + Final;
   If (Key >= VK_F1) And (Key <= VK_F4) Then
    Begin
     Final := Char(Ord('P') + Key - VK_F1);
     If Modifier = 1 Then
      s := #27'O' + Final
     Else
      s := Format(#27'[1;%d%s', [Modifier, Final]);
    End;
   Number := 0;
   Case Key Of
    VK_INSERT : Number := 2;
    VK_DELETE : Number := 3;
    VK_PRIOR  : Number := 5;
    VK_NEXT   : Number := 6;
   End;
   If (Key >= VK_F5) And (Key <= VK_F12) Then
    Number := FNumbers[Key - VK_F1];
   If Number > 0 Then
    If Modifier = 1 Then
     s := Format(#27'[%d~', [Number])
    Else
     s := Format(#27'[%d;%d~', [Number, Modifier]);
   If (Key = VK_TAB) And (ssShift In Shift) Then
    s     := #27'[Z';
   Keypad := #0;
   If fSession.Buffer.ApplicationKeypad And (Modifier = 1) Then
    Begin
     If (Key >= VK_NUMPAD0) And (Key <= VK_NUMPAD9) Then
      Keypad := Char(Ord('p') + Key - VK_NUMPAD0);
     Case Key Of
      VK_DECIMAL :
       Keypad := 'n';
      VK_DIVIDE :
       Keypad := 'o';
      VK_MULTIPLY :
       Keypad := 'j';
      VK_SUBTRACT :
       Keypad := 'm';
      VK_ADD :
       Keypad := 'k';
      VK_SEPARATOR :
       Keypad := 'l';
      VK_RETURN :
       If fExtendedKey Then
        Keypad := 'M';
     End;
     If fKeypadPhysical Then
      Case Key Of
       VK_INSERT : Keypad := 'p';
       VK_END    : Keypad := 'q';
       VK_DOWN   : Keypad := 'r';
       VK_NEXT   : Keypad := 's';
       VK_LEFT   : Keypad := 't';
       VK_CLEAR  : Keypad := 'u';
       VK_RIGHT  : Keypad := 'v';
       VK_HOME   : Keypad := 'w';
       VK_UP     : Keypad := 'x';
       VK_PRIOR  : Keypad := 'y';
       VK_DELETE : Keypad := 'n';
      End;
     If Keypad <> #0 Then
      Begin
       s             := #27'O' + Keypad;
       fSuppressChar := ((Key >= VK_NUMPAD0) And (Key <= VK_DIVIDE)) Or (Key = VK_RETURN);
      End;
    End;
   If s <> '' Then
    Begin
     Send(s);
     Key := 0;
    End;
  End;

 Procedure TfraTerminal.KeyPress(Var Key : Char);
  Var
   s : String;
  Begin
   Inherited;
   If fSuppressChar Then
    Begin
     fSuppressChar := False;
     Key           := #0;
     Exit;
    End;
   If Key = #0 Then
    Exit;
   s := Key;
   If (Key = #13) And (fSession <> Nil) And fSession.Buffer.NewLineMode Then
    s := #13#10;
   If (Key >= #$D800) And (Key <= #$DBFF) Then
    Begin
     fSurrogate := Key;
     Key        := #0;
     Exit;
    End;
   If (fSurrogate <> #0) And (Key >= #$DC00) And (Key <= #$DFFF) Then
    s         := fSurrogate + s;
   fSurrogate := #0;
   If Key = #8 Then
    If fSettings.General.CompatBackspace = 'ascii-delete' Then
     s := #127
    Else If fSettings.General.CompatBackspace = 'delete-sequence' Then
     s := #27'[3~';
   If (GetKeyState(VK_MENU) < 0) And (GetKeyState(VK_CONTROL) >= 0) Then
    s := #27 + s;
   Send(s);
   Key := #0;
  End;

 Function TfraTerminal.MouseCell(x, y : Integer) : TPoint;
  Begin
   Result.x := EnsureRange((x - 4) Div Max(1, fCellWidth), 0, fSession.Buffer.Columns - 1);
   Result.y := EnsureRange(scroll.Position + (y - 4) Div Max(1, fCellHeight), 0, fSession.Buffer.TotalLines - 1);
  End;

/// <summary>Application mouse protocols address only active-screen rows, never scrollback contents.</summary>

 Function TfraTerminal.ApplicationMouseAt(x, y : Integer) : Boolean;
  Begin
   Result := (fSession <> Nil) And (fSession.Buffer.MouseMode > 0);
   If Result Then
    Result := MouseCell(x, y).y >= fSession.Buffer.TotalLines - fSession.Buffer.Rows;
  End;

/// <summary>Sends application mouse input without keyboard selection/scroll effects; suppresses same-cell motion.</summary>

 Procedure TfraTerminal.SendMouse(Button : Integer; Release : Boolean; Shift : TShiftState; x, y : Integer);
  Var
   p      : TPoint;
   Final  : String;
   Report : String;
   Motion : Boolean;
  Begin
   If (fSession = Nil) Or fSession.Exited Then
    Exit;
   If (fSession.Buffer.MouseMode = 9) And (Release Or ((Button And 32) <> 0)) Then
    Exit;
   p := MouseCell(x, y);
   Dec(p.y, fSession.Buffer.TotalLines - fSession.Buffer.Rows);
   If p.y < 0 Then
    Begin
     fMouseCellValid := False;
     Exit;
    End;
   Motion := (Button And 32) <> 0;
   If Motion And fMouseCellValid And
   (fMouseProtocolRevision = fSession.Buffer.MouseRevision) And
   (fMouseColumns = fSession.Buffer.Columns) And (fMouseRows = fSession.Buffer.Rows) And
   (p.x = fReportedMouseCell.x) And (p.y = fReportedMouseCell.y) Then
    Exit;
   If fSession.Buffer.MouseMode <> 9 Then
    Begin
     If ssShift In Shift Then
      Inc(Button, 4);
     If ssAlt In Shift Then
      Inc(Button, 8);
     If ssCtrl In Shift Then
      Inc(Button, 16);
    End;
   If fSession.Buffer.SGRMouse Then
    Begin
     If Release Then
      Final := 'm'
     Else
      Final := 'M';
     Report := Format(#27'[<%d;%d;%d%s', [Button, p.x + 1, p.y + 1, Final]);
    End
   Else If fSession.Buffer.UrxvtMouse Then
    Begin
     If Release Then
      Button := (Button And Not 3) Or 3;
     Report  := Format(#27 + '[%d;%d;%dM', [Button + 32, p.x + 1, p.y + 1]);
    End
   Else If ((fSession.Buffer.Utf8Mouse And (p.x < 2015) And (p.y < 2015) And
   Not InRange(p.x + 33, 128, 159) And Not InRange(p.y + 33, 128, 159)) Or
   (Not fSession.Buffer.Utf8Mouse And (p.x < 95) And (p.y < 95))) Then
    Begin
     If Release Then
      Button := (Button And Not 3) Or 3;
     Report  := #27'[M' + Char(Button + 32) + Char(p.x + 33) + Char(p.y + 33);
    End
   Else
    Exit;
   fSession.SendText(Report);
   fReportedMouseCell     := p;
   fMouseCellValid        := True;
   fMouseProtocolRevision := fSession.Buffer.MouseRevision;
   fMouseColumns          := fSession.Buffer.Columns;
   fMouseRows             := fSession.Buffer.Rows;
  End;

/// <summary>VCL orders right before middle; VT protocols order middle before right.</summary>

 Function MouseButtonCode(Button : TMouseButton) : Integer;
  Begin
   Case Button Of
    mbLeft   : Result := 0;
    mbMiddle : Result := 1;
   Else Result := 2;
   End;
  End;

 Procedure TfraTerminal.SurfaceMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Var
   Handled : Boolean;
  Begin
   If fSession = Nil Then
    Exit;
   If (ssShift In Shift) Or Not ApplicationMouseAt(x, y) Then
    fMouseCellValid := False;
   fMouseShift      := Shift;
   fMouseAnchor     := Point(x, y);
   SetFocus;
   If Assigned(fOnActivate) Then
    fOnActivate(Self);
   fConsumedClick := False;
   If (Button = mbLeft) And (ssCtrl In Shift) And Assigned(fOnCtrlClick) Then
    Begin
     Handled := False;
     fOnCtrlClick(Self, x, y, Handled);
     If Handled Then
      Begin
       fConsumedClick := True;
       Exit;
      End;
    End;
   If ApplicationMouseAt(x, y) And Not(ssShift In Shift) Then
    Begin
     SendMouse(MouseButtonCode(Button), False, Shift, x, y);
     Exit;
    End;
   If Button = mbMiddle Then
    Begin
     fConsumedClick := True;
     PasteText(fPrimarySelection);
     Exit;
    End;
   If (Button = mbLeft) And (ssDouble In Shift) Then
    Begin
     SelectWordAt(x, y);
     Exit;
    End;
   If Button <> mbLeft Then
    Exit;
   fSelectionStart                      := MouseCell(x, y);
   fSelectionEnd                        := fSelectionStart;
   fSelecting                           := True;
   fHasSelection                        := False;
   fMouseAnchor                         := Point(x, y);
   TControlAccess(surface).MouseCapture := True;
   InvalidateSurface;
  End;

 Procedure TfraTerminal.SurfaceMouseMove(Sender : TObject; Shift : TShiftState; x, y : Integer);
  Var
   Button : Integer;
  Begin
   If fSession = Nil Then
    Exit;
   If ssShift In Shift Then
    fMouseCellValid := False;
   If fSelecting Then
    Begin
     If Not fHasSelection And
     (Abs(x - fMouseAnchor.x) < GetSystemMetrics(SM_CXDRAG)) And
     (Abs(y - fMouseAnchor.y) < GetSystemMetrics(SM_CYDRAG)) Then
      Exit;
     fHasSelection := True;
     fSelectionEnd := MouseCell(x, y);
     InvalidateSurface;
    End
   Else If Not(ssShift In Shift) And
   ((fSession.Buffer.MouseMode = 1003) Or
   ((fSession.Buffer.MouseMode = 1002) And ((Shift * [ssLeft, ssMiddle, ssRight]) <> []))) Then
    Begin
     // VT motion adds 32 to the actual button; 3 means no button is pressed.
     Button := 3;
     If ssLeft In Shift Then
      Button := 0
     Else If ssMiddle In Shift Then
      Button := 1
     Else If ssRight In Shift Then
      Button := 2;
     SendMouse(32 + Button, False, Shift, x, y);
    End;
  End;

 Procedure TfraTerminal.SurfaceMouseUp(Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Begin
   If fConsumedClick Then
    Begin
     fConsumedClick := False;
     Exit;
    End;
   If fSession = Nil Then
    Exit;
   If Not fSelecting And ApplicationMouseAt(x, y) And Not(ssShift In Shift) Then
    Begin
     SendMouse(MouseButtonCode(Button), True, Shift, x, y);
     Exit;
    End;
   If fSelecting Then
    Begin
     If fHasSelection Then
      fSelectionEnd                       := MouseCell(x, y);
     fSelecting                           := False;
     TControlAccess(surface).MouseCapture := False;
     If fHasSelection Then
      RememberSelection;
    End;
  End;

 Procedure TfraTerminal.RememberSelection;
  Var
   Value : String;
  Begin
   Value := SelectedText;
   If Value <> '' Then
    fPrimarySelection := Value;
   If fSettings.General.CopyOnSelect Then
    CopySelection;
  End;

/// <summary>Selects whole grapheme cells of the same word class, respecting configured exceptions and soft wraps.</summary>

 Procedure TfraTerminal.SelectWordAt(x, y : Integer);
  Var
   p         : TPoint;
   First     : TPoint;
   Last      : TPoint;
   Candidate : TPoint;
   Kind      : Integer;
   Steps     : Integer;
   ClickText : String;

   Function Category(Const Point : TPoint) : Integer;
    Var
     Value   : String;
     Pattern : String;
     i       : Integer;
     ch      : Char;
    Begin
     Value := fSession.Buffer.Cell[Point.x, Point.y].Text;
     If Trim(Value) = '' Then
      Exit(0);
     ch := Value[1];
     If ch.IsLetterOrDigit Then
      Exit(1);
     Pattern := fSettings.General.WordChars;
     i       := 1;
     While i <= Length(Pattern) Do
      Begin
       If (i + 2 <= Length(Pattern)) And (Pattern[i + 1] = '-') Then
        Begin
         If (ch >= Pattern[i]) And (ch <= Pattern[i + 2]) Then
          Exit(1);
         Inc(i, 3);
        End
       Else
        Begin
         If ch = Pattern[i] Then
          Exit(1);
         Inc(i);
        End;
      End;
     Result := 2;
    End;

   Function Step(Var Point : TPoint; Direction : Integer) : Boolean;
    Begin
     Result := False;
     Repeat
      Inc(Steps);
      If Steps > 65536 Then
       Exit;
      Inc(Point.x, Direction);
      If Point.x < 0 Then
       Begin
        If (Point.y = 0) Or Not fSession.Buffer.Cell[fSession.Buffer.Columns - 1, Point.y - 1].SoftWrapped Then
         Exit;
        Dec(Point.y);
        Point.x := fSession.Buffer.Columns - 1;
       End;
      If Point.x >= fSession.Buffer.Columns Then
       Begin
        If (Point.y + 1 >= fSession.Buffer.TotalLines) Or Not fSession.Buffer.Cell[fSession.Buffer.Columns - 1, Point.y].SoftWrapped Then
         Exit;
        Inc(Point.y);
        Point.x := 0;
       End;
     Until Not fSession.Buffer.Cell[Point.x, Point.y].Continuation And Not fSession.Buffer.Cell[Point.x, Point.y].WrapPadding;
     Result := (Category(Point) = Kind) And ((Kind <> 2) Or (fSession.Buffer.Cell[Point.x, Point.y].Text = ClickText));
    End;

  Begin
   If fSession = Nil Then
    Exit;
   p := MouseCell(x, y);
   While (p.x > 0) And fSession.Buffer.Cell[p.x, p.y].Continuation Do
    Dec(p.x);
   Kind      := Category(p);
   ClickText := fSession.Buffer.Cell[p.x, p.y].Text;
   Steps     := 0;
   First     := p;
   Last      := p;
   Candidate := p;
   While Step(Candidate, -1) Do
    First    := Candidate;
   Candidate := p;
   While Step(Candidate, 1) Do
    Last                                := Candidate;
   fSelectionStart                      := First;
   fSelectionEnd                        := Last;
   fHasSelection                        := True;
   fSelecting                           := False;
   TControlAccess(surface).MouseCapture := False;
   InvalidateSurface;
   RememberSelection;
  End;

 Procedure TfraTerminal.SurfaceDblClick(Sender : TObject);
  Begin
   If fSession = Nil Then
    Exit;
   If ApplicationMouseAt(fMouseAnchor.x, fMouseAnchor.y) And Not(ssShift In fMouseShift) Then
    Exit;
   If (ssCtrl In fMouseShift) And Assigned(fOnCtrlClick) Then
    Exit;
   SelectWordAt(fMouseAnchor.x, fMouseAnchor.y);
  End;

 Function TfraTerminal.DoMouseWheel(Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint) : Boolean;
  Var
   Step : Integer;
   p    : TPoint;
  Begin
   Result := fSession <> Nil;
   If Not Result Then
    Exit;
   p := surface.ScreenToClient(MousePos);
   If ApplicationMouseAt(p.x, p.y) And Not(ssShift In Shift) Then
    Begin
     If WheelDelta > 0 Then
      SendMouse(64, False, Shift, p.x, p.y)
     Else
      SendMouse(65, False, Shift, p.x, p.y);
    End
   Else
    Begin
     Step := 3;
     If ssShift In Shift Then
      Step := fSession.Buffer.Rows;
     If (ssShift In Shift) And (ssCtrl In Shift) Then
      Step := Step * 4;
     If WheelDelta > 0 Then
      scroll.Position := scroll.Position - Step
     Else
      scroll.Position := scroll.Position + Step;
    End;
  End;

 Function TfraTerminal.TextAt(x, y : Integer; Out CharacterIndex : Integer) : String;
  Var
   Cell : TPoint;
  Begin
   Result         := '';
   CharacterIndex := -1;
   If (fSession = Nil) Or Not PtInRect(surface.ClientRect, Point(x, y)) Then
    Exit;
   Cell   := MouseCell(x, y);
   Result := fSession.Buffer.LogicalLineText(Cell.x, Cell.y, CharacterIndex);
  End;

 Function TfraTerminal.LinkAt(x, y : Integer) : String;
  Var
   p     : TPoint;
   i     : Integer;
   Index : Integer;
  Begin
   Result := '';
   If (fSession = Nil) Or Not PtInRect(surface.ClientRect, Point(x, y)) Then
    Exit;
   p := MouseCell(x, y);
   While (p.x > 0) And fSession.Buffer.Cell[p.x, p.y].Continuation Do
    Dec(p.x);
   Result := NormalizeTerminalLink(fSession.Buffer.Cell[p.x, p.y].Hyperlink);
   If Result <> '' Then
    Exit;
   Result := fSession.Buffer.LogicalLineText(p.x, p.y, Index);
   Result := TerminalLinkAt(Result, Index);
  End;

 Function TfraTerminal.SelectedText : String;
  Begin
   Result := '';
   If fHasSelection And (fSession <> Nil) Then
    Result := fSession.Buffer.RangeText(fSelectionStart.x, fSelectionStart.y, fSelectionEnd.x, fSelectionEnd.y);
  End;

 Procedure TfraTerminal.CopySelection;
  Var
   s : String;
  Begin
   s := SelectedText;
   If s <> '' Then
    Clipboard.AsText := s;
  End;

 Procedure TfraTerminal.Paste;
  Begin
   If Clipboard.HasFormat(CF_UNICODETEXT) Then
    PasteText(Clipboard.AsText);
  End;

/// <summary>Pastes at the shell's existing input caret, sharing newline handling and bracketed-paste framing.</summary>

 Procedure TfraTerminal.PasteText(Const Value : String);
  Var
   s : String;
  Begin
   If (fSession = Nil) Or (Value = '') Then
    Exit;
   s := Value;
   If fSession.Buffer.BracketedPaste Then
    s := #27'[200~' + s + #27'[201~'
   Else
    Begin
     s := StringReplace(s, #13#10, #10, [rfReplaceAll]);
     s := StringReplace(s, #10, #13, [rfReplaceAll]);
    End;
   Send(s);
  End;

 Procedure TfraTerminal.SelectAll;
  Begin
   If fSession = Nil Then
    Exit;
   fSelectionStart := Point(0, 0);
   fSelectionEnd   := Point(fSession.Buffer.Columns - 1, fSession.Buffer.TotalLines - 1);
   fHasSelection   := True;
   InvalidateSurface;
   RememberSelection;
  End;

 Procedure TfraTerminal.WMDropFiles(Var Message : TMessage);
  Var
   i     : Cardinal;
   Count : Cardinal;
   Size  : Cardinal;
   Name  : String;
   Text  : String;
  Begin
   Try
    Text  := '';
    Count := DragQueryFile(Message.WParam, $FFFFFFFF, Nil, 0);
    If Count > 0 Then
     For i := 0 To Count - 1 Do
      Begin
       Size := DragQueryFile(Message.WParam, i, Nil, 0);
       SetLength(Name, Size + 1);
       DragQueryFile(Message.WParam, i, PChar(Name), Size + 1);
       SetLength(Name, Size);
       If Text <> '' Then
        Text := Text + ' ';
       Text  := Text + QuoteProcessArgument(Name);
      End;
    Send(Text);
   Finally
    DragFinish(Message.WParam);
   End;
  End;

 Procedure TfraTerminal.HighlightText(Start, Count : Integer);

   Function Locate(Index : Integer) : TPoint;
    Var
     Row    : Integer;
     Column : Integer;
     Offset : Integer;
     Length : Integer;
     s      : String;
     Cell   : TTerminalCell;
    Begin
     Offset  := 1;
     Result  := Point(0, 0);
     For Row := 0 To fSession.Buffer.TotalLines - 1 Do
      Begin
       s      := fSession.Buffer.LineText(Row);
       Length := System.Length(s);
       If Index <= Offset + Length Then
        Begin
         For Column := 0 To fSession.Buffer.Columns - 1 Do
          Begin
           Cell := fSession.Buffer.Cell[Column, Row];
           If Not Cell.Continuation Then
            Begin
             If Index < Offset + System.Length(Cell.Text) Then
              Exit(Point(Column, Row));
             Inc(Offset, System.Length(Cell.Text));
            End;
          End;
         Exit(Point(fSession.Buffer.Columns - 1, Row));
        End;
       Inc(Offset, Length + 2);
      End;
    End;

  Begin
   If (fSession = Nil) Or (Start < 1) Or (Count < 1) Then
    Begin
     fHasSelection := False;
     Exit;
    End;
   fSelectionStart := Locate(Start);
   fSelectionEnd   := Locate(Start + Count - 1);
   fHasSelection   := True;
   scroll.Position := Min(fSelectionStart.y, Max(0, fSession.Buffer.TotalLines - fSession.Buffer.Rows));
   InvalidateSurface;
  End;

End.
