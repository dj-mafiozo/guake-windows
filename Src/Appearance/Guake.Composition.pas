{$StackFrames On}
{$O+}
/// <summary>Builds premultiplied per-pixel alpha while keeping terminal foreground and explicit cell backgrounds opaque.</summary>
Unit Guake.Composition;

Interface

 Uses
  Vcl.Graphics;
/// <summary>Combines an opaque render with its text-free background and white foreground coverage mask.</summary>

/// <summary>Marks native chrome opaque using one synchronized DIB pointer rather than a ScanLine call for every row.</summary>

 Procedure MakeBitmapOpaque(Bitmap : Vcl.Graphics.TBitmap);
 Procedure ComposeTerminalAlpha(Color, Background, Coverage, Destination : Vcl.Graphics.TBitmap; Opacity : Byte);

Implementation

 Uses
  Winapi.Windows, System.SysUtils;

 Type
  TPixelRow = Array[0..MaxInt Div SizeOf(TRGBQuad) - 1] Of TRGBQuad;

  PPixelRow = ^TPixelRow;

 Procedure MakeBitmapOpaque(Bitmap : Vcl.Graphics.TBitmap);
  Var
   Base   : PByte;
   Row    : PCardinal;
   Stride : NativeInt;
   x      : Integer;
   y      : Integer;
  Begin
   If Bitmap.PixelFormat <> pf32bit Then
    Raise EArgumentException.Create('Opaque chrome requires a 32-bit bitmap');
   If (Bitmap.Width = 0) Or (Bitmap.Height = 0) Then
    Exit;
   Base   := Bitmap.ScanLine[0];
   Stride := 0;
   If Bitmap.Height > 1 Then
    Stride := NativeInt(Bitmap.ScanLine[1]) - NativeInt(Base);
   For y   := 0 To Bitmap.Height - 1 Do
    Begin
     Row   := PCardinal(NativeInt(Base) + y * Stride);
     For x := 0 To Bitmap.Width - 1 Do
      Begin
       Row^ := Row^ Or $FF000000;
       Inc(Row);
      End;
    End;
  End;

 Var
  CachedOpacity : Integer = -1;
  AlphaTable    : Array[Byte] Of Byte;
  Removal       : Array[Byte, Byte] Of Byte;
  Scaled        : Array[Byte] Of Byte;

 Procedure ComposeTerminalAlpha(Color, Background, Coverage, Destination : Vcl.Graphics.TBitmap; Opacity : Byte);
  Var
   x           : Integer;
   y           : Integer;
   Mask        : Integer;
   Alpha       : Integer;
   Value       : Integer;
   Back        : Integer;
   c           : PPixelRow;
   b           : PPixelRow;
   m           : PPixelRow;
   d           : PPixelRow;
   CBase       : PByte;
   BBase       : PByte;
   MBase       : PByte;
   DBase       : PByte;
   CStride     : NativeInt;
   BStride     : NativeInt;
   MStride     : NativeInt;
   DStride     : NativeInt;
   ColorRGB    : Cardinal;
   BackRGB     : Cardinal;
   OpaqueAlpha : Cardinal;
  Begin
   If (Color.PixelFormat <> pf32bit) Or (Background.PixelFormat <> pf32bit) Or (Coverage.PixelFormat <> pf32bit) Or
   (Color.Width <> Background.Width) Or (Color.Height <> Background.Height) Or
   (Color.Width <> Coverage.Width) Or (Color.Height <> Coverage.Height) Then
    Raise EArgumentException.Create('Composition requires equally sized 32-bit bitmaps');
   If CachedOpacity <> Opacity Then
    Begin
     For Mask := 0 To 255 Do
      Begin
       AlphaTable[Mask]     := Mask + (Opacity * (255 - Mask) + 127) Div 255;
       Scaled[Mask]         := (Mask * Opacity + 127) Div 255;
       For Back             := 0 To 255 Do
        Removal[Mask, Back] := (Back * (255 - Mask) * (255 - Opacity) + 32512) Div 65025;
      End;
     CachedOpacity := Opacity;
    End;
   Destination.PixelFormat := pf32bit;
   Destination.SetSize(Color.Width, Color.Height);
   Destination.AlphaFormat := afPremultiplied;
   If (Color.Width = 0) Or (Color.Height = 0) Then
    Exit;
   // Fetch DIB pointers once: ScanLine synchronizes GDI and must not be called per pixel or row.
   CBase   := Color.ScanLine[0];
   BBase   := Background.ScanLine[0];
   MBase   := Coverage.ScanLine[0];
   DBase   := Destination.ScanLine[0];
   CStride := 0;
   BStride := 0;
   MStride := 0;
   DStride := 0;
   If Color.Height > 1 Then
    Begin
     CStride := NativeInt(Color.ScanLine[1]) - NativeInt(CBase);
     BStride := NativeInt(Background.ScanLine[1]) - NativeInt(BBase);
     MStride := NativeInt(Coverage.ScanLine[1]) - NativeInt(MBase);
     DStride := NativeInt(Destination.ScanLine[1]) - NativeInt(DBase);
    End;
   OpaqueAlpha := Cardinal(Opacity) Shl 24;
   For y       := 0 To Color.Height - 1 Do
    Begin
     c     := PPixelRow(NativeInt(CBase) + y * CStride);
     b     := PPixelRow(NativeInt(BBase) + y * BStride);
     m     := PPixelRow(NativeInt(MBase) + y * MStride);
     d     := PPixelRow(NativeInt(DBase) + y * DStride);
     For x := 0 To Color.Width - 1 Do
      Begin
       Mask := m[x].rgbRed;
       If m[x].rgbGreen > Mask Then
        Mask := m[x].rgbGreen;
       If m[x].rgbBlue > Mask Then
        Mask := m[x].rgbBlue;
       If (Mask = 255) Or (Opacity = 255) Then
        Begin
         d[x]             := c[x];
         d[x].rgbReserved := 255;
         Continue;
        End;
       If Mask = 0 Then
        Begin
         ColorRGB := PCardinal(@c[x])^ And $FFFFFF;
         BackRGB  := PCardinal(@b[x])^ And $FFFFFF;
         If ColorRGB = BackRGB Then
          Begin
           If ColorRGB = 0 Then
            PCardinal(@d[x])^ := OpaqueAlpha
           Else
            Begin
             d[x].rgbRed      := Scaled[c[x].rgbRed];
             d[x].rgbGreen    := Scaled[c[x].rgbGreen];
             d[x].rgbBlue     := Scaled[c[x].rgbBlue];
             d[x].rgbReserved := Opacity;
            End;
           Continue;
          End;
        End;
       Alpha := AlphaTable[Mask];
       Value := c[x].rgbRed - Removal[Mask, b[x].rgbRed];
       If Value < 0 Then
        Value := 0
       Else If Value > Alpha Then
        Value      := Alpha;
       d[x].rgbRed := Value;
       Value       := c[x].rgbGreen - Removal[Mask, b[x].rgbGreen];
       If Value < 0 Then
        Value := 0
       Else If Value > Alpha Then
        Value        := Alpha;
       d[x].rgbGreen := Value;
       Value         := c[x].rgbBlue - Removal[Mask, b[x].rgbBlue];
       If Value < 0 Then
        Value := 0
       Else If Value > Alpha Then
        Value           := Alpha;
       d[x].rgbBlue     := Value;
       d[x].rgbReserved := Alpha;
      End;
    End;
  End;

End.
