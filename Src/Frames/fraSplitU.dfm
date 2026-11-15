object fraSplit: TfraSplit
  Width = 720
  Height = 360
  object firstHost: TPanel
    Align = alLeft
    Width = 356
    BevelOuter = bvNone
    TabOrder = 0
  end
  object splitter: TSplitter
    Left = 356
    Align = alLeft
    Width = 5
    MinSize = 50
    OnMoved = SplitterMoved
  end
  object secondHost: TPanel
    Left = 361
    Width = 359
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
  end
end
