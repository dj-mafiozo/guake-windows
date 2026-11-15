{$StackFrames On}
/// <summary>DFM-defined two-pane splitter instantiated only for data-driven terminal split nodes.</summary>
Unit fraSplitU;
/// <summary>Static split template instantiated only for nodes in the session layout tree.</summary>

Interface

 Uses
  System.Classes, Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Guake.Sessions;

 Type
  TfraSplit = Class(TFrame)
    firstHost  : TPanel;
    secondHost : TPanel;
    splitter   : TSplitter;
    Procedure SplitterMoved(Sender : TObject);
   Private
    fNode : TTerminalNode;
   Public
    Property Node : TTerminalNode Read fNode Write fNode;
    Procedure Configure(Vertical : Boolean; Ratio : Integer);
  End;

Implementation

 Uses
  System.Math, Winapi.Windows;
{$R *.dfm}

 Procedure TfraSplit.SplitterMoved(Sender : TObject);
  Begin
   If fNode = Nil Then
    Exit;
   If fNode.Kind = tnVertical Then
    fNode.Ratio := EnsureRange(MulDiv(firstHost.Width, 100, Max(1, ClientWidth)), 10, 90)
   Else
    fNode.Ratio := EnsureRange(MulDiv(firstHost.Height, 100, Max(1, ClientHeight)), 10, 90);
  End;

 Procedure TfraSplit.Configure(Vertical : Boolean; Ratio : Integer);
  Begin
   If Vertical Then
    Begin
     firstHost.Align := alLeft;
     firstHost.Width := Width * Ratio Div 100;
     splitter.Align  := alLeft;
    End
   Else
    Begin
     firstHost.Align  := alTop;
     firstHost.Height := Height * Ratio Div 100;
     splitter.Align   := alTop;
    End;
  End;

End.
