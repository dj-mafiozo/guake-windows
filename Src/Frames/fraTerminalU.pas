{$StackFrames On}
/// <summary>Native cell renderer and terminal keyboard, selection, clipboard and mouse input view.</summary>
Unit fraTerminalU;

/// <summary>DFM-backed native VCL terminal view. Session and buffer lifetimes belong to the controller.</summary>

Interface

 Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Graphics,
  Guake.Sessions, Guake.Settings, Guake.AnimatedBackground;

 Type
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
    fAnimation       : TAnimatedBackground;
    fBackgroundTick  : UInt64;
    fColorSurface    : TBitmap;
    fBackSurface     : TBitmap;
    fMaskSurface     : TBitmap;
    fOnVisualChanged : TNotifyEvent;
    Procedure InvalidateSurface;
    Procedure PaintSurface(Canvas : TCanvas; Mask : Boolean);
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
    fSurrogate         : Char;
    fOnActivate        : TNotifyEvent;
    fOnShortcut        : TTerminalKeyEvent;
    Function  MouseCell   (x, y : Integer)                              : TPoint;
    Function  IsSelected  (x, y : Integer)                              : Boolean;
    Function  ResolveColor(Value : Integer; Foreground, Bold : Boolean) : TColor;
    Procedure SendMouse   (Button : Integer; Release : Boolean; Shift : TShiftState; x, y : Integer);
    Procedure Send        (Const Value : String);
    Procedure FollowOutput;
    Procedure WMDropFiles (Var Message : TMessage); Message WM_DROPFILES;
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
    /// <summary>Advances the configured GIF using elapsed milliseconds, without a second GUI timer.</summary>
    Function AdvanceBackground(ElapsedMilliseconds : Cardinal) : Boolean;
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
    Property Session    : TTerminalSession Read fSession;
    Property OnActivate : TNotifyEvent Read fOnActivate Write fOnActivate;
    Property OnShortcut : TTerminalKeyEvent Read fOnShortcut Write fOnShortcut;
  End;

Implementation

 Uses
  Guake.Composition, Guake.Links, System.Math, System.Character, System.StrUtils, Vcl.Clipbrd, Winapi.ShellAPI, Guake.VT, Guake.Shells, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, Vcl.Imaging.GIFImg;
{$R *.dfm}

 Type
   TControlAccess = Class(TControl);

  Destructor TfraTerminal.Destroy;
   Begin
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
    Canvas.Brush.Color := fPalette[17];
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
   Inherited;
  End;

 Procedure TfraTerminal.Bind(Session : TTerminalSession; Settings : TGuakeSettings);
  Begin
   fSession      := Session;
   fSettings     := Settings;
   fLastRevision := -1;
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
    fAnimation := TAnimatedBackground.Create(TGIFImage(fBackground.Graphic), fPalette[17]);
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
    Exit(fPalette[16]);
   If Value = -2 Then
    Exit(fPalette[17]);
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

 Procedure TfraTerminal.PaintSurface(Canvas : TCanvas; Mask : Boolean);
  Var
   x               : Integer;
   y               : Integer;
   WorldY          : Integer;
   CursorRow       : Integer;
   Temp            : Integer;
   c               : TTerminalCell;
   Fore            : TColor;
   Back            : TColor;
   r               : TRect;
   Style           : TFontStyles;
   TransparentCell : Boolean;
   Options         : Cardinal;
  Begin
   If Mask Then
    Begin
     Canvas.Brush.Color := clBlack;
     Canvas.FillRect(surface.ClientRect);
    End
   Else
    DrawBackground(Canvas, surface.ClientRect);
   If (fSession = Nil) Or (fCellWidth = 0) Or (fCellHeight = 0) Then
    Exit;
   Canvas.Font.Assign(Font);
   For y  := 0 To fSession.Buffer.Rows - 1 Do
    For x := 0 To fSession.Buffer.Columns - 1 Do
     Begin
      WorldY := scroll.Position + y;
      c      := fSession.Buffer.Cell[x, WorldY];
      Fore   := ResolveColor(c.Foreground, True, c.Bold);
      Back   := ResolveColor(c.Background, False, False);
      If c.Inverse Or IsSelected(x, WorldY) Then
       Begin
        Temp := Fore;
        Fore := Back;
        Back := Temp;
       End;
      r := Rect(4 + x * fCellWidth, 4 + y * fCellHeight, 4 + (x + 1) * fCellWidth, 4 + (y + 1) * fCellHeight);
      If c.Continuation Then
       Continue;
      If (x + 1 < fSession.Buffer.Columns) And fSession.Buffer.Cell[x + 1, WorldY].Continuation Then
       Inc(r.Right, fCellWidth);
      Style := [];
      If c.Bold And fSettings.Style.Font.AllowBold Then
       Include(Style, fsBold);
      If c.Italic Then
       Include(Style, fsItalic);
      If c.Underline Then
       Include(Style, fsUnderline);
      Canvas.Font.Style := Style;
      TransparentCell   := (c.Background = -2) And Not c.Inverse And Not IsSelected(x, WorldY);
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
      SetTextColor(Canvas.Handle, ColorToRGB(Fore));
      SetBkColor(Canvas.Handle, ColorToRGB(Back));
      ExtTextOut(Canvas.Handle, r.Left, r.Top, Options, @r, PChar(c.Text), Length(c.Text), Nil);
     End;
   If Focused And fSession.Buffer.CursorVisible And Not fSession.Exited And
   ((fSettings.Style.CursorBlinkMode = 2) Or ((GetTickCount64 Div 500) Mod 2 = 0)) Then
    Begin
     CursorRow := fSession.Buffer.TotalLines - fSession.Buffer.Rows + fSession.Buffer.CursorY - scroll.Position;
     If (CursorRow >= 0) And (CursorRow < fSession.Buffer.Rows) Then
      Begin
       r := Rect(4 + fSession.Buffer.CursorX * fCellWidth, 4 + CursorRow * fCellHeight,
       4 + (fSession.Buffer.CursorX + 1) * fCellWidth, 4 + (CursorRow + 1) * fCellHeight);
       If Mask Then
        Canvas.Brush.Color := clWhite
       Else
        Canvas.Brush.Color := fPalette[16];
       Case fSettings.Style.CursorShape Of
        1 : r.Right := r.Left + 2;
        2 : r.Top := r.Bottom - 2;
       End;
       If fSettings.Style.CursorShape = 0 Then
        Canvas.FrameRect(r)
       Else
        Canvas.FillRect(r);
      End;
    End;
  End;

 Procedure TfraTerminal.InvalidateSurface;
  Begin
   surface.Invalidate;
   If Assigned(fOnVisualChanged) Then
    fOnVisualChanged(Self);
  End;

 Procedure TfraTerminal.SurfacePaint(Sender : TObject);
  Begin
   PaintSurface(surface.Canvas, False);
  End;

 Procedure TfraTerminal.RenderAlpha(Destination : TBitmap; Opacity : Byte);
  Var
   Bitmap : TBitmap;
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
   DrawBackground(fBackSurface.Canvas, surface.ClientRect);
   PaintSurface(fColorSurface.Canvas, False);
   PaintSurface(fMaskSurface.Canvas, True);
   ComposeTerminalAlpha(fColorSurface, fBackSurface, fMaskSurface, Destination, Opacity);
  End;

 Function TfraTerminal.AdvanceBackground(ElapsedMilliseconds : Cardinal) : Boolean;
  Begin
   Result := (fAnimation <> Nil) And fAnimation.Advance(ElapsedMilliseconds);
   If Result Then
    InvalidateSurface;
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
    AdvanceBackground(Min(Tick - fBackgroundTick, UInt64(60000)));
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
   CursorVisible := Focused And fSession.Buffer.CursorVisible And Not fSession.Exited And
   ((fSettings.Style.CursorBlinkMode = 2) Or ((GetTickCount64 Div 500) Mod 2 = 0));
   If Changed Or (CursorVisible <> fLastCursorVisible) Then
    InvalidateSurface;
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
   fHasSelection := False;
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
    s := #27'[Z';
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

 Procedure TfraTerminal.SendMouse(Button : Integer; Release : Boolean; Shift : TShiftState; x, y : Integer);
  Var
   p     : TPoint;
   Final : String;
  Begin
   p := MouseCell(x, y);
   Dec(p.y, scroll.Position);
   If ssShift In Shift Then
    Inc(Button, 4);
   If ssAlt In Shift Then
    Inc(Button, 8);
   If ssCtrl In Shift Then
    Inc(Button, 16);
   If fSession.Buffer.SGRMouse Then
    Begin
     If Release Then
      Final := 'm'
     Else
      Final := 'M';
     Send(Format(#27'[<%d;%d;%d%s', [Button, p.x + 1, p.y + 1, Final]));
    End
   Else If (p.x < 223) And (p.y < 223) Then
    Begin
     If Release Then
      Button := 3;
     Send(#27'[M' + Char(Button + 32) + Char(p.x + 33) + Char(p.y + 33));
    End;
  End;

 Procedure TfraTerminal.SurfaceMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Begin
   If fSession = Nil Then
    Exit;
   SetFocus;
   If Assigned(fOnActivate) Then
    fOnActivate(Self);
   If (fSession.Buffer.MouseMode > 0) And Not(ssShift In Shift) Then
    Begin
     SendMouse(Ord(Button), False, Shift, x, y);
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
  Begin
   If fSession = Nil Then
    Exit;
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
   Else If Not(ssShift In Shift) And ((fSession.Buffer.MouseMode = 1003) Or ((fSession.Buffer.MouseMode = 1002) And (ssLeft In Shift))) Then
    SendMouse(32, False, Shift, x, y);
  End;

 Procedure TfraTerminal.SurfaceMouseUp(Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Begin
   If fSession = Nil Then
    Exit;
   If (fSession.Buffer.MouseMode > 0) And Not(ssShift In Shift) Then
    Begin
     SendMouse(Ord(Button), True, Shift, x, y);
     Exit;
    End;
   If fSelecting Then
    Begin
     If fHasSelection Then
      fSelectionEnd                       := MouseCell(x, y);
     fSelecting                           := False;
     TControlAccess(surface).MouseCapture := False;
     If fHasSelection And fSettings.General.CopyOnSelect Then
      CopySelection;
    End;
  End;

 Procedure TfraTerminal.SurfaceDblClick(Sender : TObject);
  Var
   p : TPoint;
   x : Integer;
   s : String;

   Function WordCell(Column : Integer) : Boolean;
    Begin
     s      := fSession.Buffer.Cell[Column, p.y].Text;
     Result := (s <> '') And (s[1].IsLetterOrDigit Or (Pos(s[1], '-_./:@~') > 0));
    End;

  Begin
   If fSession = Nil Then
    Exit;
   p := MouseCell(surface.ScreenToClient(Mouse.CursorPos).x, surface.ScreenToClient(Mouse.CursorPos).y);
   x := p.x;
   While (x > 0) And WordCell(x - 1) Do
    Dec(x);
   fSelectionStart := Point(x, p.y);
   x               := p.x;
   While (x < fSession.Buffer.Columns - 1) And WordCell(x + 1) Do
    Inc(x);
   fSelectionEnd                        := Point(x, p.y);
   fHasSelection                        := True;
   fSelecting                           := False;
   TControlAccess(surface).MouseCapture := False;
   InvalidateSurface;
   If fSettings.General.CopyOnSelect Then
    CopySelection;
  End;

 Function TfraTerminal.DoMouseWheel(Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint) : Boolean;
  Var
   Step : Integer;
   p    : TPoint;
  Begin
   Result := fSession <> Nil;
   If Not Result Then
    Exit;
   If (fSession.Buffer.MouseMode > 0) And Not(ssShift In Shift) Then
    Begin
     p := surface.ScreenToClient(MousePos);
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

 Function TfraTerminal.LinkAt(x, y : Integer) : String;
  Var
   p     : TPoint;
   i     : Integer;
   Index : Integer;
  Begin
   Result := '';
   If (fSession = Nil) Or Not PtInRect(surface.ClientRect, Point(x, y)) Then
    Exit;
   p      := MouseCell(x, y);
   Result := NormalizeTerminalLink(fSession.Buffer.Cell[p.x, p.y].Hyperlink);
   If Result <> '' Then
    Exit;
   Index := 0;
   For i := 0 To p.x - 1 Do
    Inc(Index, Length(fSession.Buffer.Cell[i, p.y].Text));
   Result := TerminalLinkAt(fSession.Buffer.LineText(p.y), Index);
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
  Var
   s : String;
  Begin
   If Not Clipboard.HasFormat(CF_UNICODETEXT) Or (fSession = Nil) Then
    Exit;
   s := Clipboard.AsText;
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
