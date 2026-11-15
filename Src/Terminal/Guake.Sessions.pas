{$StackFrames On}
/// <summary>Owns terminal processes and the tab/split layout independently of the VCL view.</summary>
Unit Guake.Sessions;

/// <summary>Owns terminal processes, VT models and the tab/split tree independently of VCL.</summary>

Interface

 Uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Guake.ConPTY, Guake.VT, Guake.Shells, Guake.Settings;

 Type
  /// <summary>A session owns one ConPTY process and one UI-thread VT model.</summary>
  TTerminalSession = Class
   Private
    fId            : String;
    fDirectory     : String;
    fName          : String;
    fProfile       : TShellProfile;
    fPty           : TConPtySession;
    fBuffer        : TTerminalBuffer;
    fExitCode      : Cardinal;
    fExited        : Boolean;
    fReportedError : String;
    Function GetTitle : String;
   Public
    /// <summary>Initializes this service and acquires the resources whose lifetime it owns.</summary>
    Constructor Create(Const Profile : TShellProfile; Const Directory : String; Settings : TGuakeSettings);
    /// <summary>Releases owned resources; borrowed settings and view references are not freed.</summary>
    Destructor  Destroy; Override;
    /// <summary>Moves queued bytes into the model and answers terminal device queries on the calling UI thread.</summary>
    Function  Poll : Boolean;
    Procedure Resize(Columns, Rows : Integer);
    /// <summary>Encodes Unicode input as UTF-8 and queues it for the pseudoconsole writer.</summary>
    Procedure SendText(Const Value : String);
    Property Id            : String Read fId;
    Property Directory     : String Read fDirectory;
    Property Profile       : TShellProfile Read fProfile;
    Property Title         : String Read GetTitle;
    Property CustomTitle   : String Read fName Write fName;
    Property Buffer        : TTerminalBuffer Read fBuffer;
    Property Exited        : Boolean Read fExited;
    Property ExitCode      : Cardinal Read fExitCode;
    Property ReportedError : String Read fReportedError;
  End;

  TTerminalNodeKind = (tnTerminal, tnHorizontal, tnVertical);
/// <summary>A split owns its children; a leaf owns its terminal session.</summary>

  TTerminalNode = Class
   Public
    Kind    : TTerminalNodeKind;
    Session : TTerminalSession;
    First   : TTerminalNode;
    Second  : TTerminalNode;
    Parent  : TTerminalNode;
    Ratio   : Integer;
    /// <summary>Initializes this service and acquires the resources whose lifetime it owns.</summary>
    Constructor Create(Session : TTerminalSession);
    /// <summary>Releases owned resources; borrowed settings and view references are not freed.</summary>
    Destructor Destroy; Override;
    Function   FirstLeaf : TTerminalNode;
    Procedure  Collect(List : TList<TTerminalSession>);
  End;

  TTerminalTab = Class
   Public
    Id     : String;
    Name   : String;
    Root   : TTerminalNode;
    Active : TTerminalNode;
    /// <summary>Releases owned resources; borrowed settings and view references are not freed.</summary>
    Destructor Destroy; Override;
    Function   Title : String;
  End;
/// <summary>Creates processes before mutating the layout so failed starts preserve existing tabs.</summary>

  TTerminalController = Class
   Private
    fTabs        : TObjectList<TTerminalTab>;
    fSettings    : TGuakeSettings;
    fActiveIndex : Integer;
    fOnChanged   : TNotifyEvent;
    Function  GetActiveTab            : TTerminalTab;
    Function  GetActiveSession        : TTerminalSession;
    Function  GetCount                : Integer;
    Function  GetTab(Index : Integer) : TTerminalTab;
    Procedure Changed;
   Public
    /// <summary>Initializes this service and acquires the resources whose lifetime it owns.</summary>
    Constructor Create(Settings : TGuakeSettings);
    /// <summary>Releases owned resources; borrowed settings and view references are not freed.</summary>
    Destructor Destroy; Override;
    Function   DefaultProfile : TShellProfile;
    /// <summary>Starts a shell before adding its tab, preserving the existing layout on startup failure.</summary>
    Function  NewTab   (Const Directory : String = ''; Const Shell : String = '') : TTerminalTab;
    Procedure SelectTab(Index : Integer);
    /// <summary>Removes a tab and destroys its owned terminal process trees.</summary>
    Procedure CloseTab(Index : Integer);
    Procedure MoveTab (FromIndex, ToIndex : Integer);
    /// <summary>Starts a terminal and replaces the active leaf with a horizontal or vertical split.</summary>
    Procedure   Split(Vertical : Boolean; Const Directory : String = '');
    /// <summary>Removes the active leaf and collapses its split parent while preserving its sibling.</summary>
    Procedure CloseTerminal;
    Procedure FocusSession(Session : TTerminalSession);
    /// <summary>Focuses the nearest pane in a cardinal direction using split geometry.</summary>
    Function FocusDirection(DX, DY : Integer) : Boolean;
    /// <summary>Moves the nearest split boundary on the requested axis by five percent.</summary>
    Function MoveSplit(DX, DY : Integer) : Boolean;
    /// <summary>Enumerates terminal leaves across all tabs in display order.</summary>
    Function    Sessions : TArray<TTerminalSession>;
    /// <summary>Processes queued terminal output on the calling thread and updates session state.</summary>
    Function    Poll : Boolean;
    /// <summary>Serializes layout, active panes, profiles and working directories without terminal output or running commands.</summary>
    Function SessionState : String;
    /// <summary>Restores into a separate owned tree; any failure leaves existing sessions intact.</summary>
    Procedure RestoreState(Const Value : String);
    Procedure SaveSession (Const FileName : String);
    Procedure LoadSession (Const FileName : String);
    Property Count                 : Integer Read GetCount;
    Property Tabs[Index : Integer] : TTerminalTab Read GetTab;
    Property ActiveIndex           : Integer Read fActiveIndex;
    Property ActiveTab             : TTerminalTab Read GetActiveTab;
    Property ActiveSession         : TTerminalSession Read GetActiveSession;
    Property OnChanged             : TNotifyEvent Read fOnChanged Write fOnChanged;
  End;

Implementation

 Uses
  Winapi.Windows, System.JSON, System.Types, System.IOUtils, System.Math, System.NetEncoding;

 Function NewId : String;
  Var
   Id : TGUID;
  Begin
   CreateGUID(Id);
   Result := LowerCase(Copy(GUIDToString(Id), 2, 36));
  End;

 Constructor TTerminalSession.Create(Const Profile : TShellProfile; Const Directory : String; Settings : TGuakeSettings);
  Var
   Env   : TStringList;
   Limit : Integer;
   Sdk   : String;
  Begin
   Inherited Create;
   fId        := NewId;
   fProfile   := Profile;
   fDirectory := Directory;
   If fDirectory = '' Then
    fDirectory := GetEnvironmentVariable('USERPROFILE');
   If fDirectory = '' Then
    fDirectory := GetCurrentDir;
   Limit       := Settings.General.HistorySize;
   If Settings.General.InfiniteHistory Then
    Limit  := -1;
   fBuffer := TTerminalBuffer.Create(80, 24, Limit);
   Env     := TStringList.Create;
   Try
    If Profile.Kind In [gsBash, gsZsh] Then
     Begin
      Sdk                           := TPath.GetFullPath(TPath.Combine(ExtractFileDir(Profile.Executable), '..\..'));
      Env.Values['MSYSTEM']         := 'MINGW64';
      Env.Values['TERM']            := 'xterm-256color';
      Env.Values['COLORTERM']       := 'truecolor';
      Env.Values['CHERE_INVOKING']  := '1';
      Env.Values['PATH']            := TPath.Combine(Sdk, 'usr\bin') + ';' + TPath.Combine(Sdk, 'mingw64\bin') + ';' + GetEnvironmentVariable('PATH');
      Env.Values['MSYS2_PATH_TYPE'] := 'inherit';
     End;
    fPty := TConPtySession.Create(Profile.Executable, Profile.Arguments, fDirectory, 80, 24, Env);
   Finally
    Env.Free;
   End;
  End;

 Destructor TTerminalSession.Destroy;
  Begin
   fPty.Free;
   fBuffer.Free;
   Inherited;
  End;

 Function TTerminalSession.Poll : Boolean;
  Var
   Bytes               : TBytes;
   Response, URI, Path : String;
   p                   : Integer;
  Begin
   Bytes  := fPty.ReadAvailable;
   Result := Length(Bytes) > 0;
   If Result Then
    fBuffer.Feed(Bytes);
   Response := fBuffer.TakeResponses;
   If (Response <> '') And fPty.Running Then
    fPty.SendText(Response);
   fReportedError := fPty.ErrorText;
   If Not fPty.Running And Not fExited Then
    Begin
     fExitCode := fPty.ExitCode;
     fPty.CompleteOutput;
     fBuffer.Feed(fPty.ReadAvailable);
     fExited := True;
     Result  := True;
    End;
   URI := fBuffer.DirectoryURI;
   If Copy(URI, 1, 7) = 'file://' Then
    Begin
     Path := Copy(URI, 8, MaxInt);
     p    := Pos('/', Path);
     If p > 0 Then
      Path := Copy(Path, p + 1, MaxInt);
     Path  := TNetEncoding.URL.Decode(Path);
     If (Length(Path) > 2) And (Path[1] = '/') And (Path[3] = ':') Then
      Delete(Path, 1, 1);
     Path := StringReplace(Path, '/', '\', [rfReplaceAll]);
     If DirectoryExists(Path) Then
      fDirectory := Path;
    End;
  End;

 Procedure TTerminalSession.Resize(Columns, Rows : Integer);
  Begin
   If (Columns = fBuffer.Columns) And (Rows = fBuffer.Rows) Then
    Exit;
   fPty.Resize(Columns, Rows);
   fBuffer.Resize(Columns, Rows);
  End;

 Procedure TTerminalSession.SendText(Const Value : String);
  Begin
   fPty.SendText(Value);
  End;

 Function TTerminalSession.GetTitle : String;
  Begin
   If fName <> '' Then
    Result := fName
   Else If fBuffer.Title <> '' Then
    Result := fBuffer.Title
   Else
    Result := ChangeFileExt(ExtractFileName(fProfile.Executable), '');
   If fExited Then
    Result := Result + Format(' [exit %d]', [fExitCode]);
  End;

 Constructor TTerminalNode.Create(Session : TTerminalSession);
  Begin
   Inherited Create;
   Self.Session := Session;
   Ratio        := 50;
  End;

 Destructor TTerminalNode.Destroy;
  Begin
   First.Free;
   Second.Free;
   Session.Free;
   Inherited;
  End;

 Function TTerminalNode.FirstLeaf : TTerminalNode;
  Begin
   If Kind = tnTerminal Then
    Result := Self
   Else
    Result := First.FirstLeaf;
  End;

 Procedure TTerminalNode.Collect(List : TList<TTerminalSession>);
  Begin
   If Kind = tnTerminal Then
    List.Add(Session)
   Else
    Begin
     First.Collect(List);
     Second.Collect(List);
    End;
  End;

 Destructor TTerminalTab.Destroy;
  Begin
   Root.Free;
   Inherited;
  End;

 Function TTerminalTab.Title : String;
  Begin
   If Name <> '' Then
    Result := Name
   Else
    Result := Root.FirstLeaf.Session.Title;
  End;

 Constructor TTerminalController.Create(Settings : TGuakeSettings);
  Begin
   Inherited Create;
   If Settings = Nil Then
    Raise EArgumentNilException.Create('Settings');
   fSettings    := Settings;
   fTabs        := TObjectList<TTerminalTab>.Create(True);
   fActiveIndex := -1;
  End;

 Destructor TTerminalController.Destroy;
  Begin
   fTabs.Free;
   Inherited;
  End;

 Procedure TTerminalController.Changed;
  Begin
   If Assigned(fOnChanged) Then
    fOnChanged(Self);
  End;

 Function TTerminalController.GetCount : Integer;
  Begin
   Result := fTabs.Count;
  End;

 Function TTerminalController.GetTab(Index : Integer) : TTerminalTab;
  Begin
   Result := fTabs[Index];
  End;

 Function TTerminalController.GetActiveTab : TTerminalTab;
  Begin
   If (fActiveIndex >= 0) And (fActiveIndex < Count) Then
    Result := fTabs[fActiveIndex]
   Else
    Result := Nil;
  End;

 Function TTerminalController.GetActiveSession : TTerminalSession;
  Begin
   If ActiveTab <> Nil Then
    Result := ActiveTab.Active.Session
   Else
    Result := Nil;
  End;

 Function TTerminalController.DefaultProfile : TShellProfile;
  Var
   Value : String;
   Kind  : TGuakeShell;
  Begin
   Value := fSettings.General.DefaultShell;
   Kind  := gsPowerShell;
   If SameText(Value, 'cmd') Then
    Kind := gsCmd
   Else If SameText(Value, 'bash') Then
    Kind := gsBash
   Else If SameText(Value, 'zsh') Then
    Kind  := gsZsh;
   Result := TShellProfile.Resolve(Kind, fSettings.ReadString('windows', 'git-sdk-root', 'C:\git-sdk-64'));
   If (Value <> '') And Not SameText(Value, 'powershell') And Not SameText(Value, 'cmd') And Not SameText(Value, 'bash') And Not SameText(Value, 'zsh') Then
    Begin
     Result.Executable := Value;
     If SameText(ExtractFileName(Value), 'bash.exe') Then
      Result.Kind := gsBash
     Else If SameText(ExtractFileName(Value), 'zsh.exe') Or SameText(ExtractFileName(Value), 'git-zsh.exe') Then
      Result := TShellProfile.Resolve(gsZsh, fSettings.ReadString('windows', 'git-sdk-root', 'C:\git-sdk-64'))
     Else If SameText(ExtractFileName(Value), 'cmd.exe') Then
      Result.Kind := gsCmd
     Else
      Result.Kind := gsPowerShell;
     Case Result.Kind Of
      gsCmd        : Result.Arguments := '/D';
      gsPowerShell : Result.Arguments := '-NoLogo';
     End;
    End;
   Case Result.Kind Of
    gsBash :
     If fSettings.General.UseLoginShell Then
      Result.Arguments := '--login -i'
     Else
      Result.Arguments := '-i';
    gsZsh :
     If fSettings.General.UseLoginShell Then
      Result.Arguments := '--nomintty --git-sdk-root ' + QuoteProcessArgument(fSettings.ReadString('windows', 'git-sdk-root', 'C:\git-sdk-64')) + ' --login -i'
     Else
      Result.Arguments := '--nomintty --git-sdk-root ' + QuoteProcessArgument(fSettings.ReadString('windows', 'git-sdk-root', 'C:\git-sdk-64')) + ' -i';
   End;
  End;

 Function TTerminalController.NewTab(Const Directory, Shell : String) : TTerminalTab;
  Var
   Profile  : TShellProfile;
   Session  : TTerminalSession;
   Target   : String;
   InsertAt : Integer;
  Begin
   Profile := DefaultProfile;
   If Shell <> '' Then
    Begin
     If SameText(Shell, 'cmd') Then
      Profile := TShellProfile.Resolve(gsCmd, fSettings.ReadString('windows', 'git-sdk-root', 'C:\git-sdk-64'))
     Else If SameText(Shell, 'powershell') Then
      Profile := TShellProfile.Resolve(gsPowerShell, fSettings.ReadString('windows', 'git-sdk-root', 'C:\git-sdk-64'))
     Else If SameText(Shell, 'bash') Then
      Profile := TShellProfile.Resolve(gsBash, fSettings.ReadString('windows', 'git-sdk-root', 'C:\git-sdk-64'))
     Else If SameText(Shell, 'zsh') Then
      Profile := TShellProfile.Resolve(gsZsh, fSettings.ReadString('windows', 'git-sdk-root', 'C:\git-sdk-64'))
     Else
      Begin
       Profile.Executable := Shell;
       Profile.Arguments  := '';
      End;
    End;
   Case Profile.Kind Of
    gsBash :
     If fSettings.General.UseLoginShell Then
      Profile.Arguments := '--login -i'
     Else
      Profile.Arguments := '-i';
    gsZsh :
     If fSettings.General.UseLoginShell Then
      Profile.Arguments := '--nomintty --git-sdk-root ' + QuoteProcessArgument(fSettings.ReadString('windows', 'git-sdk-root', 'C:\git-sdk-64')) + ' --login -i'
     Else
      Profile.Arguments := '--nomintty --git-sdk-root ' + QuoteProcessArgument(fSettings.ReadString('windows', 'git-sdk-root', 'C:\git-sdk-64')) + ' -i';
   End;
   Target := Directory;
   If (Target = '') And fSettings.General.OpenTabCwd And (ActiveSession <> Nil) Then
    Target := ActiveSession.Directory;
   Session := TTerminalSession.Create(Profile, Target, fSettings);
   Result  := TTerminalTab.Create;
   Try
    Result.Id     := NewId;
    Result.Root   := TTerminalNode.Create(Session);
    Session       := Nil;
    Result.Active := Result.Root;
    InsertAt      := Count;
    If fSettings.General.NewTabAfter And (fActiveIndex >= 0) Then
     InsertAt := fActiveIndex + 1;
    fTabs.Insert(InsertAt, Result);
    fActiveIndex := InsertAt;
   Except
    Result.Free;
    Session.Free;
    Raise;
   End;
   Changed;
  End;

 Procedure TTerminalController.SelectTab(Index : Integer);
  Begin
   If (Index < 0) Or (Index >= Count) Then
    Raise EArgumentOutOfRangeException.Create('Tab index');
   fActiveIndex := Index;
   Changed;
  End;

 Procedure TTerminalController.CloseTab(Index : Integer);
  Begin
   If (Index < 0) Or (Index >= Count) Then
    Raise EArgumentOutOfRangeException.Create('Tab index');
   fTabs.Delete(Index);
   If Index < fActiveIndex Then
    Dec(fActiveIndex);
   fActiveIndex := Min(fActiveIndex, Count - 1);
   Changed;
  End;

 Procedure TTerminalController.MoveTab(FromIndex, ToIndex : Integer);
  Var
   Active : TTerminalTab;
  Begin
   If (FromIndex < 0) Or (FromIndex >= Count) Or (ToIndex < 0) Or (ToIndex >= Count) Then
    Raise EArgumentOutOfRangeException.Create('Tab index');
   Active := ActiveTab;
   fTabs.Move(FromIndex, ToIndex);
   fActiveIndex := fTabs.IndexOf(Active);
   Changed;
  End;

 Procedure TTerminalController.Split(Vertical : Boolean; Const Directory : String);
  Var
   Session               : TTerminalSession;
   NewNode, Leaf, Parent : TTerminalNode;
   Target                : String;
  Begin
   If ActiveTab = Nil Then
    Begin
     NewTab(Directory);
     Exit;
    End;
   Target := Directory;
   If Target = '' Then
    Target := ActiveSession.Directory;
   Session := TTerminalSession.Create(ActiveSession.Profile, Target, fSettings);
   Leaf    := ActiveTab.Active;
   Parent  := Leaf.Parent;
   Try
    NewNode := TTerminalNode.Create(Nil);
   Except
    Session.Free;
    Raise;
   End;
   Try
    NewNode.Second := TTerminalNode.Create(Session);
   Except
    Session.Free;
    NewNode.Free;
    Raise;
   End;
   If Vertical Then
    NewNode.Kind := tnVertical
   Else
    NewNode.Kind         := tnHorizontal;
   NewNode.Parent        := Parent;
   NewNode.First         := Leaf;
   Leaf.Parent           := NewNode;
   NewNode.Second.Parent := NewNode;
   If Parent = Nil Then
    ActiveTab.Root := NewNode
   Else If Parent.First = Leaf Then
    Parent.First := NewNode
   Else
    Parent.Second   := NewNode;
   ActiveTab.Active := NewNode.Second;
   Changed;
  End;

 Procedure TTerminalController.CloseTerminal;
  Var
   Leaf, Parent, Sibling, Grand : TTerminalNode;
  Begin
   If ActiveTab = Nil Then
    Exit;
   Leaf   := ActiveTab.Active;
   Parent := Leaf.Parent;
   If Parent = Nil Then
    Begin
     CloseTab(fActiveIndex);
     Exit;
    End;
   Grand := Parent.Parent;
   If Parent.First = Leaf Then
    Sibling := Parent.Second
   Else
    Sibling       := Parent.First;
   Sibling.Parent := Grand;
   If Grand = Nil Then
    ActiveTab.Root := Sibling
   Else If Grand.First = Parent Then
    Grand.First := Sibling
   Else
    Grand.Second    := Sibling;
   ActiveTab.Active := Sibling.FirstLeaf;
   Parent.First     := Nil;
   Parent.Second    := Nil;
   Parent.Free;
   Leaf.Free;
   Changed;
  End;

 Procedure TTerminalController.FocusSession(Session : TTerminalSession);

   Function Find(Node : TTerminalNode) : TTerminalNode;
    Begin
     Result := Nil;
     If Node.Kind = tnTerminal Then
      Begin
       If Node.Session = Session Then
        Result := Node;
      End
     Else
      Begin
       Result := Find(Node.First);
       If Result = Nil Then
        Result := Find(Node.Second);
      End;
    End;
  Var
   i    : Integer;
   Node : TTerminalNode;

  Begin
   For i := 0 To Count - 1 Do
    Begin
     Node := Find(Tabs[i].Root);
     If Node <> Nil Then
      Begin
       fActiveIndex   := i;
       Tabs[i].Active := Node;
       Exit;
      End;
    End;
  End;

 Function TTerminalController.FocusDirection(DX, DY : Integer) : Boolean;
  Var
   Rectangles                            : TDictionary<TTerminalNode, TRect>;
   Node, Best                            : TTerminalNode;
   Source, Target                        : TRect;
   x, y, TX, TY, Forward, Cross, Overlap : Integer;
   Score, BestScore                      : Int64;

   Procedure Collect(Node : TTerminalNode; Bounds : TRect);
    Var
     a, b : TRect;
     Cut  : Integer;
    Begin
     If Node.Kind = tnTerminal Then
      Begin
       Rectangles.Add(Node, Bounds);
       Exit;
      End;
     a := Bounds;
     b := Bounds;
     If Node.Kind = tnVertical Then
      Begin
       Cut     := Bounds.Left + (Bounds.Right - Bounds.Left) * Node.Ratio Div 100;
       a.Right := Cut;
       b.Left  := Cut;
      End
     Else
      Begin
       Cut      := Bounds.Top + (Bounds.Bottom - Bounds.Top) * Node.Ratio Div 100;
       a.Bottom := Cut;
       b.Top    := Cut;
      End;
     Collect(Node.First, a);
     Collect(Node.Second, b);
    End;

  Begin
   Result := False;
   If (ActiveTab = Nil) Or (Abs(DX) + Abs(DY) <> 1) Then
    Exit;
   Rectangles := TDictionary<TTerminalNode, TRect>.Create;
   Try
    Collect(ActiveTab.Root, Rect(0, 0, 10000, 10000));
    Source    := Rectangles[ActiveTab.Active];
    x         := (Source.Left + Source.Right) Div 2;
    y         := (Source.Top + Source.Bottom) Div 2;
    Best      := Nil;
    BestScore := High(Int64);
    For Node In Rectangles.Keys Do
     Begin
      If Node = ActiveTab.Active Then
       Continue;
      Target  := Rectangles[Node];
      TX      := (Target.Left + Target.Right) Div 2;
      TY      := (Target.Top + Target.Bottom) Div 2;
      Forward := (TX - x) * DX + (TY - y) * DY;
      If Forward <= 0 Then
       Continue;
      Cross := Abs((TX - x) * DY + (TY - y) * DX);
      If DX <> 0 Then
       Overlap := Min(Source.Bottom, Target.Bottom) - Max(Source.Top, Target.Top)
      Else
       Overlap := Min(Source.Right, Target.Right) - Max(Source.Left, Target.Left);
      Score    := Int64(Forward) * 10000 + Cross;
      If Overlap <= 0 Then
       Inc(Score, Int64(1000000000));
      If Score < BestScore Then
       Begin
        BestScore := Score;
        Best      := Node;
       End;
     End;
    If Best <> Nil Then
     Begin
      ActiveTab.Active := Best;
      Result           := True;
     End;
   Finally
    Rectangles.Free;
   End;
  End;

 Function TTerminalController.MoveSplit(DX, DY : Integer) : Boolean;
  Var
   Node  : TTerminalNode;
   Kind  : TTerminalNodeKind;
   Ratio : Integer;
  Begin
   Result := False;
   If (ActiveTab = Nil) Or (Abs(DX) + Abs(DY) <> 1) Then
    Exit;
   If DX <> 0 Then
    Kind := tnVertical
   Else
    Kind := tnHorizontal;
   Node  := ActiveTab.Active.Parent;
   While (Node <> Nil) And (Node.Kind <> Kind) Do
    Node := Node.Parent;
   If Node = Nil Then
    Exit;
   Ratio := EnsureRange(Node.Ratio + 5 * (DX + DY), 10, 90);
   If Ratio = Node.Ratio Then
    Exit;
   Node.Ratio := Ratio;
   Changed;
   Result := True;
  End;

/// <summary>JSON v1 contains only restartable session descriptions; process memory and scrollback are intentionally excluded.</summary>

 Function TTerminalController.SessionState : String;
  Var
   Root, Item : TJSONObject;
   TabsArray  : TJSONArray;
   Tab        : TTerminalTab;

   Function NodeValue(Node : TTerminalNode) : TJSONObject;
    Var
     Profile : TShellProfile;
    Begin
     Result := TJSONObject.Create;
     Try
      Result.AddPair('kind', TJSONNumber.Create(Ord(Node.Kind)));
      Result.AddPair('ratio', TJSONNumber.Create(Node.Ratio));
      If Node.Kind = tnTerminal Then
       Begin
        Profile := Node.Session.Profile;
        Result.AddPair('id', Node.Session.Id);
        Result.AddPair('directory', Node.Session.Directory);
        Result.AddPair('title', Node.Session.CustomTitle);
        Result.AddPair('shell', TJSONNumber.Create(Ord(Profile.Kind)));
        Result.AddPair('executable', Profile.Executable);
        Result.AddPair('arguments', Profile.Arguments);
        Result.AddPair('git-sdk-root', Profile.GitSdkRoot);
       End
      Else
       Begin
        Result.AddPair('first', NodeValue(Node.First));
        Result.AddPair('second', NodeValue(Node.Second));
       End;
     Except
      Result.Free;
      Raise;
     End;
    End;

  Begin
   Root := TJSONObject.Create;
   Try
    Root.AddPair('version', TJSONNumber.Create(1));
    Root.AddPair('active-tab', TJSONNumber.Create(fActiveIndex));
    TabsArray := TJSONArray.Create;
    Root.AddPair('tabs', TabsArray);
    For Tab In fTabs Do
     Begin
      Item := TJSONObject.Create;
      TabsArray.AddElement(Item);
      Item.AddPair('id', Tab.Id);
      Item.AddPair('name', Tab.Name);
      Item.AddPair('active-session', Tab.Active.Session.Id);
      Item.AddPair('root', NodeValue(Tab.Root));
     End;
    Result := Root.ToJSON;
   Finally
    Root.Free;
   End;
  End;

 Procedure TTerminalController.RestoreState(Const Value : String);
  Var
   Root                : TJSONValue;
   Obj, Item           : TJSONObject;
   ArrayValue          : TJSONArray;
   NewTabs, OldTabs    : TObjectList<TTerminalTab>;
   Tab                 : TTerminalTab;
   Entry               : TJSONValue;
   ActiveIndex, Leaves : Integer;

   Function Field(Obj : TJSONObject; Const Name : String) : String;
    Var
     Value : TJSONValue;
    Begin
     Value := Obj.GetValue(Name);
     If Value = Nil Then
      Raise EArgumentException.Create('Missing session field: ' + Name);
     Result := Value.Value;
    End;

   Function ReadNode(Value : TJSONValue; Parent : TTerminalNode; Depth : Integer; Const ActiveId : String; Var Active : TTerminalNode) : TTerminalNode;
    Var
     Obj                : TJSONObject;
     Kind, Shell, Ratio : Integer;
     Profile            : TShellProfile;
     Session            : TTerminalSession;
    Begin
     If (Depth > 64) Or Not(Value Is TJSONObject) Then
      Raise EArgumentException.Create('Invalid session tree');
     Obj   := TJSONObject(Value);
     Kind  := StrToInt(Field(Obj, 'kind'));
     Ratio := StrToInt(Field(Obj, 'ratio'));
     If (Kind < Ord(Low(TTerminalNodeKind))) Or (Kind > Ord(High(TTerminalNodeKind))) Or (Ratio < 10) Or (Ratio > 90) Then
      Raise EArgumentException.Create('Invalid split geometry');
     Result := TTerminalNode.Create(Nil);
     Try
      Result.Parent := Parent;
      Result.Kind   := TTerminalNodeKind(Kind);
      Result.Ratio  := Ratio;
      If Result.Kind = tnTerminal Then
       Begin
        Inc(Leaves);
        If Leaves > 128 Then
         Raise EArgumentException.Create('Too many session panes');
        Shell := StrToInt(Field(Obj, 'shell'));
        If (Shell < Ord(Low(TGuakeShell))) Or (Shell > Ord(High(TGuakeShell))) Then
         Raise EArgumentException.Create('Invalid shell');
        Profile := TShellProfile.Resolve(TGuakeShell(Shell), Field(Obj, 'git-sdk-root'));
        // Built-in launchers are resolved relative to this installation. Preserve custom shell paths.
        If Not SameText(ExtractFileName(Field(Obj, 'executable')), ExtractFileName(Profile.Executable)) Then
         Profile.Executable := Field(Obj, 'executable');
        Profile.Arguments   := Field(Obj, 'arguments');
        Session             := TTerminalSession.Create(Profile, Field(Obj, 'directory'), fSettings);
        Result.Session      := Session;
        Session.fId         := Field(Obj, 'id');
        Session.CustomTitle := Field(Obj, 'title');
        If Session.Id = ActiveId Then
         Active := Result;
       End
      Else
       Begin
        Result.First  := ReadNode(Obj.GetValue('first'), Result, Depth + 1, ActiveId, Active);
        Result.Second := ReadNode(Obj.GetValue('second'), Result, Depth + 1, ActiveId, Active);
       End;
     Except
      Result.Free;
      Raise;
     End;
    End;

  Begin
   If Length(Value) > 2 * 1024 * 1024 Then
    Raise EArgumentException.Create('Session file exceeds 2 MiB');
   Root    := TJSONObject.ParseJSONValue(Value);
   NewTabs := TObjectList<TTerminalTab>.Create(True);
   Try
    If Not(Root Is TJSONObject) Then
     Raise EArgumentException.Create('Invalid session JSON');
    Obj := TJSONObject(Root);
    If Field(Obj, 'version') <> '1' Then
     Raise EArgumentException.Create('Unsupported session version');
    If Not(Obj.GetValue('tabs') Is TJSONArray) Then
     Raise EArgumentException.Create('Invalid tabs');
    ArrayValue := TJSONArray(Obj.GetValue('tabs'));
    If ArrayValue.Count > 64 Then
     Raise EArgumentException.Create('Too many tabs');
    ActiveIndex := StrToInt(Field(Obj, 'active-tab'));
    Leaves      := 0;
    If (ArrayValue.Count > 0) And ((ActiveIndex < 0) Or (ActiveIndex >= ArrayValue.Count)) Then
     Raise EArgumentException.Create('Invalid active tab');
    For Entry In ArrayValue Do
     Begin
      If Not(Entry Is TJSONObject) Then
       Raise EArgumentException.Create('Invalid tab');
      Item := TJSONObject(Entry);
      Tab  := TTerminalTab.Create;
      NewTabs.Add(Tab);
      Tab.Id   := Field(Item, 'id');
      Tab.Name := Field(Item, 'name');
      Tab.Root := ReadNode(Item.GetValue('root'), Nil, 0, Field(Item, 'active-session'), Tab.Active);
      If Tab.Active = Nil Then
       Raise EArgumentException.Create('Invalid active session');
     End;
    OldTabs      := fTabs;
    fTabs        := NewTabs;
    NewTabs      := OldTabs;
    fActiveIndex := ActiveIndex;
    Changed;
   Finally
    NewTabs.Free;
    Root.Free;
   End;
  End;

 Procedure TTerminalController.SaveSession(Const FileName : String);
  Var
   Temporary, Text : String;
  Begin
   Text := SessionState;
   ForceDirectories(ExtractFilePath(ExpandFileName(FileName)));
   Temporary := FileName + '.' + NewId + '.tmp';
   Try
    TFile.WriteAllText(Temporary, Text, TEncoding.UTF8);
    Win32Check(MoveFileEx(PChar(Temporary), PChar(FileName), MOVEFILE_REPLACE_EXISTING Or MOVEFILE_WRITE_THROUGH));
   Finally
    If TFile.Exists(Temporary) Then
     TFile.Delete(Temporary);
   End;
  End;

 Procedure TTerminalController.LoadSession(Const FileName : String);
  Var
   Stream : TFileStream;
   Text   : TStreamReader;
  Begin
   Stream := TFileStream.Create(FileName, fmOpenRead Or fmShareDenyWrite);
   Try
    If Stream.Size > 2 * 1024 * 1024 Then
     Raise EArgumentException.Create('Session file exceeds 2 MiB');
    Text := TStreamReader.Create(Stream, TEncoding.UTF8, True);
    Try
     RestoreState(Text.ReadToEnd);
    Finally
     Text.Free;
    End;
   Finally
    Stream.Free;
   End;
  End;

 Function TTerminalController.Sessions : TArray<TTerminalSession>;
  Var
   List : TList<TTerminalSession>;
   Tab  : TTerminalTab;
  Begin
   List := TList<TTerminalSession>.Create;
   Try
    For Tab In fTabs Do
     Tab.Root.Collect(List);
    Result := List.ToArray;
   Finally
    List.Free;
   End;
  End;

 Function TTerminalController.Poll : Boolean;
  Var
   Session : TTerminalSession;
  Begin
   Result := False;
   For Session In Sessions Do
    If Session.Poll Then
     Result := True;
  End;

End.
