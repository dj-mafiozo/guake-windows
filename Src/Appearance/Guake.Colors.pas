{$StackFrames On}
/// <summary>Parses Guake CLI RGB colors into the native COLORREF representation without changing global settings.</summary>
Unit Guake.Colors;

Interface

/// <summary>Accepts RGB hex with one to four digits per channel and an optional leading hash.</summary>

 Function ParseTerminalColor(Const Text : String) : Integer;

Implementation

 Uses
  System.SysUtils;

 Function ParseTerminalColor(Const Text : String) : Integer;
  Var
   s       : String;
   Digits  : Integer;
   Maximum : Integer;
   r       : Integer;
   g       : Integer;
   b       : Integer;
   c       : Char;
  Begin
   s := Trim(Text);
   If Copy(s, 1, 1) = '#' Then
    Delete(s, 1, 1);
   If Not(Length(s) In [3, 6, 9, 12]) Then
    Raise EArgumentException.Create('Color must contain 3, 6, 9 or 12 RGB hexadecimal digits');
   For c In s Do
    If Not CharInSet(c, ['0'..'9', 'a'..'f', 'A'..'F']) Then
     Raise EArgumentException.Create('Invalid RGB color');
   Digits  := Length(s) Div 3;
   Maximum := (1 Shl (Digits * 4)) - 1;
   r       := (StrToInt('$' + Copy(s, 1, Digits)) * 255 + Maximum Div 2) Div Maximum;
   g       := (StrToInt('$' + Copy(s, Digits + 1, Digits)) * 255 + Maximum Div 2) Div Maximum;
   b       := (StrToInt('$' + Copy(s, Digits * 2 + 1, Digits)) * 255 + Maximum Div 2) Div Maximum;
   Result  := r Or (g Shl 8) Or (b Shl 16);
  End;

End.
