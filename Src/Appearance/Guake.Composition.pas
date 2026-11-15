{$StackFrames On}
/// <summary>Builds premultiplied per-pixel alpha while keeping terminal foreground and explicit cell backgrounds opaque.</summary>
Unit Guake.Composition;

Interface

 Uses
  Vcl.Graphics;
/// <summary>Combines an opaque render with its text-free background and white foreground coverage mask.</summary>

 Procedure ComposeTerminalAlpha(Color, Background, Coverage, Destination : Vcl.Graphics.TBitmap; Opacity : Byte);

Implementation

 Uses
  Winapi.Windows, System.SysUtils, System.Math;

 Type
  TPixelRow = Array[0..MaxInt Div SizeOf(TRGBQuad) - 1] Of TRGBQuad;

  PPixelRow = ^TPixelRow;

 Procedure ComposeTerminalAlpha(Color, Background, Coverage, Destination : Vcl.Graphics.TBitmap; Opacity : Byte);
  Var
   x     : Integer;
   y     : Integer;
   Mask  : Integer;
   Alpha : Integer;
   c     : PPixelRow;
   b     : PPixelRow;
   m     : PPixelRow;
   d     : PPixelRow;

   Function Channel(Value, Back : Integer) : Byte;
    Var
     ResultValue : Integer;
    Begin
     ResultValue := Value - (Back * (255 - Mask) * (255 - Opacity) + 32512) Div 65025;
     Result      := EnsureRange(ResultValue, 0, Alpha);
    End;

  Begin
   If (Color.PixelFormat <> pf32bit) Or (Background.PixelFormat <> pf32bit) Or (Coverage.PixelFormat <> pf32bit) Or
   (Color.Width <> Background.Width) Or (Color.Height <> Background.Height) Or
   (Color.Width <> Coverage.Width) Or (Color.Height <> Coverage.Height) Then
    Raise EArgumentException.Create('Composition requires equally sized 32-bit bitmaps');
   Destination.PixelFormat := pf32bit;
   Destination.SetSize(Color.Width, Color.Height);
   // Set the flag before writing: VCL otherwise premultiplies an already premultiplied image.
   Destination.AlphaFormat := afPremultiplied;
   For y                   := 0 To Color.Height - 1 Do
    Begin
     c     := Color.ScanLine[y];
     b     := Background.ScanLine[y];
     m     := Coverage.ScanLine[y];
     d     := Destination.ScanLine[y];
     For x := 0 To Color.Width - 1 Do
      Begin
       Mask             := Max(m[x].rgbRed, Max(m[x].rgbGreen, m[x].rgbBlue));
       Alpha            := Mask + (Opacity * (255 - Mask) + 127) Div 255;
       d[x].rgbRed      := Channel(c[x].rgbRed, b[x].rgbRed);
       d[x].rgbGreen    := Channel(c[x].rgbGreen, b[x].rgbGreen);
       d[x].rgbBlue     := Channel(c[x].rgbBlue, b[x].rgbBlue);
       d[x].rgbReserved := Alpha;
      End;
    End;
  End;

End.
