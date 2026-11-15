{$StackFrames On}
/// <summary>Advances GIF backgrounds on the existing VCL refresh timer, including disposal and embedded loop counts.</summary>
Unit Guake.AnimatedBackground;

Interface

 Uses
  Vcl.Graphics, Vcl.Imaging.GIFImg;

 Type
  TAnimatedBackground = Class
   Private
    fRenderer : TGIFRenderer;
    fBitmap   : TBitmap;
    fElapsed  : UInt64;
    fStopped  : Boolean;
    Function FrameDelay : Cardinal;
   Public
    /// <summary>The image is borrowed and must outlive this renderer.</summary>
    Constructor Create (Image : TGIFImage; Background : TColor);
    Destructor  Destroy; Override;
    Function    Advance(ElapsedMilliseconds : Cardinal) : Boolean;
    Property Bitmap : TBitmap Read fBitmap;
  End;

Implementation

 Uses
  System.SysUtils, System.Types, System.Math;

 Type
  /// <summary>Prevents GIFImg from creating its own animation timer; the frame supplies elapsed time.</summary>
  TClockedGIFRenderer = Class(TGIFRenderer)
   Public
    Procedure StartAnimation; Override;
    Procedure IncludeFirstPlayback;
  End;

 Procedure TClockedGIFRenderer.StartAnimation;
  Begin
   // Animate remains enabled so GIFImg allocates the buffers for disposal=previous/background.
   // Animating stays false, preventing TGIFRenderer.Draw from creating its internal TTimer.
  End;

 Procedure TClockedGIFRenderer.IncludeFirstPlayback;
  Var
   i         : Integer;
   j         : Integer;
   Extension : TGIFExtension;
  Begin
   // Netscape stores repetitions AFTER the first playback; GIFImg treats LoopMax as total plays.
   // https://bugs.webkit.org/show_bug.cgi?id=39857
   For i  := 0 To Image.Images.Count - 1 Do
    For j := 0 To Image.Images[i].Extensions.Count - 1 Do
     Begin
      Extension := Image.Images[i].Extensions[j];
      If Extension Is TGIFAppExtNSLoop Then
       Begin
        If TGIFAppExtNSLoop(Extension).Loops > 0 Then
         SetLoopMax(Integer(TGIFAppExtNSLoop(Extension).Loops) + 1);
        Exit;
       End;
     End;
  End;

 Constructor TAnimatedBackground.Create(Image : TGIFImage; Background : TColor);
  Begin
   Inherited Create;
   If (Image = Nil) Or (Image.Images.Count = 0) Then
    Raise EArgumentException.Create('Empty GIF background');
   fBitmap             := TBitmap.Create;
   fBitmap.PixelFormat := pf32bit;
   fBitmap.SetSize(Image.Width, Image.Height);
   fBitmap.Canvas.Brush.Color := Background;
   fBitmap.Canvas.FillRect(Rect(0, 0, fBitmap.Width, fBitmap.Height));
   fRenderer             := TClockedGIFRenderer.Create(Image);
   fRenderer.Animate     := True;
   fRenderer.Transparent := True;
   fRenderer.Draw(fBitmap.Canvas, Rect(0, 0, fBitmap.Width, fBitmap.Height));
   TClockedGIFRenderer(fRenderer).IncludeFirstPlayback;
  End;

 Destructor TAnimatedBackground.Destroy;
  Begin
   fRenderer.Free;
   fBitmap.Free;
   Inherited;
  End;

 Function TAnimatedBackground.FrameDelay : Cardinal;
  Begin
   Result := 100;
   If (fRenderer.Frame <> Nil) And (fRenderer.Frame.GraphicControlExtension <> Nil) Then
    Result := Max(20, Integer(fRenderer.Frame.GraphicControlExtension.Delay) * 10);
  End;

 Function TAnimatedBackground.Advance(ElapsedMilliseconds : Cardinal) : Boolean;
  Var
   Delay    : Cardinal;
   Previous : Integer;
   Steps    : Integer;
  Begin
   Result := False;
   If fStopped Or (fRenderer.Image.Images.Count < 2) Then
    Exit;
   Inc(fElapsed, Min(ElapsedMilliseconds, Cardinal(60000)));
   Steps := 0;
   While Not fStopped Do
    Begin
     Delay := FrameDelay;
     If fElapsed < Delay Then
      Break;
     Dec(fElapsed, Delay);
     Previous := fRenderer.FrameIndex;
     fRenderer.NextFrame;
     If (fRenderer.FrameIndex = Previous) And (fRenderer.LoopMax > 0) And
     (fRenderer.LoopCount >= fRenderer.LoopMax) Then
      Begin
       fStopped := True;
       Break;
      End;
     fRenderer.Draw(fBitmap.Canvas, Rect(0, 0, fBitmap.Width, fBitmap.Height));
     Result := Result Or (fRenderer.FrameIndex <> Previous);
     Inc(Steps);
     If Steps >= 32 Then
      Begin
       fElapsed := 0;
       Break;
      End;
    End;
  End;

End.
