{$StackFrames On}
/// <summary>DFM-defined two-pane splitter instantiated only for data-driven terminal split nodes.</summary>
Unit fraSplitU;
/// <summary>Static split template instantiated only for nodes in the session layout tree.</summary>

Interface

 Uses
  System.Classes, Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls;

 Type
  TfraSplit = Class(TFrame)
    firstHost  : TPanel;
    secondHost : TPanel;
    splitter   : TSplitter;
   Public
    Procedure Configure(Vertical : Boolean; Ratio : Integer);
  End;

Implementation
{$R *.dfm}

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
