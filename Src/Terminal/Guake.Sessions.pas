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
    /// <summary>Enumerates terminal leaves across all tabs in display order.</summary>
    Function    Sessions : TArray<TTerminalSession>;
    /// <summary>Processes queued terminal output on the calling thread and updates session state.</summary>
    Function    Poll : Boolean;
    Property Count                 : Integer Read GetCount;
    Property Tabs[Index : Integer] : TTerminalTab Read GetTab;
    Property ActiveIndex           : Integer Read fActiveIndex;
    Property ActiveTab             : TTerminalTab Read GetActiveTab;
    Property ActiveSession         : TTerminalSession Read GetActiveSession;
    Property OnChanged             : TNotifyEvent Read fOnChanged Write fOnChanged;
  End;

Implementation

 Uses
  System.IOUtils, System.Math, System.NetEncoding;

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
     Else If SameText(ExtractFileName(Value), 'zsh.exe') Then
      Result.Kind := gsZsh
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
      Result.Arguments := '-l -i'
     Else
      Result.Arguments := '-i';
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
      Profile.Arguments := '-l -i'
     Else
      Profile.Arguments := '-i';
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
