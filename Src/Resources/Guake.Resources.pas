{$StackFrames On}
/// <summary>Loads the original Guake bitmaps and tray icon from custom RC resources.</summary>
Unit Guake.Resources;

Interface

 Uses
  System.Classes, Vcl.Graphics, Vcl.ExtCtrls;
/// <summary>Loads a named PNG RCDATA image without temporary files.</summary>

 Procedure LoadGuakeImage(Image : TImage; Const ResourceName : String);
 /// <summary>Assigns the original tray artwork as a native Windows icon.</summary>
 Procedure LoadGuakeTrayIcon(Icon : TIcon);

Implementation

 Uses
  Vcl.Imaging.pngimage, Winapi.Windows;
{$R Guake.Images.res}

 Procedure LoadGuakeImage(Image : TImage; Const ResourceName : String);
  Var
   Stream : TResourceStream;
   Png    : TPngImage;
  Begin
   Stream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
   Try
    Png := TPngImage.Create;
    Try
     Png.LoadFromStream(Stream);
     Image.Picture.Assign(Png);
    Finally
     Png.Free;
    End;
   Finally
    Stream.Free;
   End;
  End;

 Procedure LoadGuakeTrayIcon(Icon : TIcon);
  Begin
   Icon.LoadFromResourceName(HInstance, 'GUAKE_TRAY');
  End;

End.
