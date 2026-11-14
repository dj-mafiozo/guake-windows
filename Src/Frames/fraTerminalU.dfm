object fraTerminal: TfraTerminal
  Width = 720
  Height = 360
  TabStop = True
  OnResize = FrameResize
  object surface: TPaintBox
    Width = 703
    Height = 360
    Align = alClient
    OnPaint = SurfacePaint
    OnMouseDown = SurfaceMouseDown
    OnMouseMove = SurfaceMouseMove
    OnMouseUp = SurfaceMouseUp
    OnDblClick = SurfaceDblClick
  end
  object scroll: TScrollBar
    Left = 703
    Width = 17
    Height = 360
    Align = alRight
    Kind = sbVertical
    OnChange = ScrollChanged
    TabStop = False
  end
  object refreshTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = RefreshTick
    Left = 40
    Top = 24
  end
end
