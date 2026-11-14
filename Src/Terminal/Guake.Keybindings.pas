{$StackFrames On}
/// <summary>Maps persisted Guake accelerator names to Windows keyboard and global-hotkey values.</summary>
Unit Guake.Keybindings;
/// <summary>Translates persisted GTK accelerator names into native Windows keyboard and hotkey values.</summary>

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Guake.Settings;

 Function ParseAccelerator(Const Value : String; Out Key : Word; Out Modifiers : Cardinal) : Boolean;
 Function MatchAccelerator(Const Value : String; Key : Word; Shift : TShiftState) : Boolean;

Implementation

 Uses
  System.StrUtils;

 Function ParseAccelerator(Const Value : String; Out Key : Word; Out Modifiers : Cardinal) : Boolean;
  Var
   s      : String;
   Tag    : String;
   p      : Integer;
   Number : Integer;
  Begin
   s         := LowerCase(Trim(Value));
   Key       := 0;
   Modifiers := 0;
   Result    := False;
   If (s = '') Or (s = 'disabled') Then
    Exit;
   While Copy(s, 1, 1) = '<' Do
    Begin
     p := Pos('>', s);
     If p = 0 Then
      Exit;
     Tag := Copy(s, 2, p - 2);
     Delete(s, 1, p);
     If (Tag = 'control') Or (Tag = 'primary') Or (Tag = 'ctrl') Then
      Modifiers := Modifiers Or MOD_CONTROL
     Else If Tag = 'alt' Then
      Modifiers := Modifiers Or MOD_ALT
     Else If Tag = 'shift' Then
      Modifiers := Modifiers Or MOD_SHIFT
     Else If (Tag = 'super') Or (Tag = 'win') Then
      Modifiers := Modifiers Or MOD_WIN
     Else
      Exit;
    End;
   If (s = '`') Or (s = 'grave') Or (s = 'quoteleft') Then
    Key := VK_OEM_3
   Else If (s = '~') Or (s = 'asciitilde') Then
    Begin
     Key       := VK_OEM_3;
     Modifiers := Modifiers Or MOD_SHIFT;
    End;
   If Length(s) = 1 Then
    Begin
     If CharInSet(s[1], ['a'..'z']) Then
      Key := Ord(UpCase(s[1]))
     Else If CharInSet(s[1], ['0'..'9']) Then
      Key := Ord(s[1]);
    End
   Else If (Length(s) > 1) And (s[1] = 'f') And TryStrToInt(Copy(s, 2, MaxInt), Number) And (Number >= 1) And (Number <= 24) Then
    Key := VK_F1 + Number - 1;
   If Key = 0 Then
    Case IndexText(s, ['return', 'tab', 'space', 'page_up', 'page_down', 'home', 'end', 'up', 'down', 'left', 'right', 'insert', 'delete', 'backspace', 'escape', 'minus', 'plus', 'equal', 'comma', 'period']) Of
     0 :
      Key := VK_RETURN;
     1 :
      Key := VK_TAB;
     2 :
      Key := VK_SPACE;
     3 :
      Key := VK_PRIOR;
     4 :
      Key := VK_NEXT;
     5 :
      Key := VK_HOME;
     6 :
      Key := VK_END;
     7 :
      Key := VK_UP;
     8 :
      Key := VK_DOWN;
     9 :
      Key := VK_LEFT;
     10 :
      Key := VK_RIGHT;
     11 :
      Key := VK_INSERT;
     12 :
      Key := VK_DELETE;
     13 :
      Key := VK_BACK;
     14 :
      Key := VK_ESCAPE;
     15 :
      Key := VK_OEM_MINUS;
     16 :
      Begin
       Key       := VK_OEM_PLUS;
       Modifiers := Modifiers Or MOD_SHIFT;
      End;
     17 :
      Key := VK_OEM_PLUS;
     18 :
      Key := VK_OEM_COMMA;
     19 :
      Key := VK_OEM_PERIOD;
    End;
   Result := Key <> 0;
  End;

 Function MatchAccelerator(Const Value : String; Key : Word; Shift : TShiftState) : Boolean;
  Var
   Expected  : Word;
   Modifiers : Cardinal;
   Actual    : Cardinal;
  Begin
   Result := False;
   If Not ParseAccelerator(Value, Expected, Modifiers) Or (Key <> Expected) Then
    Exit;
   Actual := 0;
   If ssCtrl In Shift Then
    Actual := Actual Or MOD_CONTROL;
   If ssAlt In Shift Then
    Actual := Actual Or MOD_ALT;
   If ssShift In Shift Then
    Actual := Actual Or MOD_SHIFT;
   If (GetKeyState(VK_LWIN) < 0) Or (GetKeyState(VK_RWIN) < 0) Then
    Actual := Actual Or MOD_WIN;
   Result  := Actual = Modifiers;
  End;

End.
