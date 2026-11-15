{$StackFrames On}
/// <summary>Provides native asynchronous hooks and per-user Windows startup registration.</summary>
Unit Guake.WindowsIntegration;

Interface

 Uses
  System.SysUtils, Winapi.Windows;
/// <summary>Suppresses taskbar and Alt+Tab entries for a terminal or VCL proxy HWND.</summary>

 Procedure ConfigureTrayOnlyWindow(Window : HWND; ProtectStyle : Boolean = False);
 /// <summary>Starts a configured CMD command asynchronously without a visible console.</summary>
 Function StartConfiguredCommand(Const Command, Directory : String) : Cardinal;
 /// <summary>Sets or removes only the Guake value; RegistryPath permits isolated test fixtures.</summary>
 Procedure ConfigureAutoStart(Enabled : Boolean; Const Executable : String; Const RegistryPath : String = 'Software\Microsoft\Windows\CurrentVersion\Run');

Implementation

 Uses
  Winapi.Messages, System.Win.Registry, Guake.Shells;

 Type
  TWindowStyles = Record
   OldStyle : DWORD;
   NewStyle : DWORD;
  End;

  PWindowStyles = ^TWindowStyles;

 Var
  ProxyWindow       : HWND;
  PreviousProxyProc : Pointer;

 Function TrayProxyProc(Window : HWND; Msg : UINT; WParam : WParam; LParam : LParam) : LRESULT; Stdcall;
  Var
   Previous : Pointer;
  Begin
   Previous := PreviousProxyProc;
   If (Msg = WM_STYLECHANGING) And (Integer(WParam) = GWL_EXSTYLE) And (LParam <> 0) Then
    PWindowStyles(LParam).NewStyle := (PWindowStyles(LParam).NewStyle Or WS_EX_TOOLWINDOW) And Not WS_EX_APPWINDOW;
   If Previous <> Nil Then
    Result := CallWindowProc(TFNWndProc(Previous), Window, Msg, WParam, LParam)
   Else
    Result := DefWindowProc(Window, Msg, WParam, LParam);
   If (Msg = WM_NCDESTROY) And (ProxyWindow = Window) Then
    Begin
     ProxyWindow       := 0;
     PreviousProxyProc := Nil;
    End;
  End;

 Procedure RemoveProxyGuard;
  Begin
   If (ProxyWindow <> 0) And IsWindow(ProxyWindow) And
   (GetWindowLongPtr(ProxyWindow, GWLP_WNDPROC) = NativeInt(@TrayProxyProc)) Then
    SetWindowLongPtr(ProxyWindow, GWLP_WNDPROC, NativeInt(PreviousProxyProc));
   ProxyWindow       := 0;
   PreviousProxyProc := Nil;
  End;

 Procedure GuardProxyStyle(Window : HWND);
  Begin
   If (ProxyWindow = Window) And (PreviousProxyProc <> Nil) Then
    Exit;
   RemoveProxyGuard;
   ProxyWindow       := Window;
   PreviousProxyProc := Pointer(SetWindowLongPtr(Window, GWLP_WNDPROC, NativeInt(@TrayProxyProc)));
   Win32Check(PreviousProxyProc <> Nil);
  End;

/// <summary>Hides both the form and the VCL proxy window from the taskbar and Alt+Tab without hiding their content.</summary>

 Procedure ConfigureTrayOnlyWindow(Window : HWND; ProtectStyle : Boolean);
  Var
   Previous : NativeInt;
   Current  : NativeInt;
  Begin
   If ProtectStyle And (Window <> 0) Then
    GuardProxyStyle(Window);
   If Window = 0 Then
    Exit;
   Previous := GetWindowLongPtr(Window, GWL_EXSTYLE);
   Current  := (Previous Or WS_EX_TOOLWINDOW) And Not WS_EX_APPWINDOW;
   If Current = Previous Then
    Exit;
   SetWindowLongPtr(Window, GWL_EXSTYLE, Current);
   SetWindowPos(Window, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOZORDER Or SWP_NOACTIVATE Or SWP_FRAMECHANGED);
  End;

 Function StartConfiguredCommand(Const Command, Directory : String) : Cardinal;
  Var
   Executable  : String;
   CommandLine : String;
   Startup     : TStartupInfo;
   Process     : TProcessInformation;
   WorkDir     : PChar;
  Begin
   Result := 0;
   If Trim(Command) = '' Then
    Exit;
   Executable := GetEnvironmentVariable('ComSpec');
   If Executable = '' Then
    Executable := IncludeTrailingPathDelimiter(GetEnvironmentVariable('SystemRoot')) + 'System32\cmd.exe';
   CommandLine := QuoteProcessArgument(Executable) + ' /D /S /C "' + Command + '"';
   UniqueString(CommandLine);
   FillChar(Startup, SizeOf(Startup), 0);
   Startup.cb := SizeOf(Startup);
   FillChar(Process, SizeOf(Process), 0);
   WorkDir := Nil;
   If Directory <> '' Then
    WorkDir := PChar(Directory);
   Win32Check(CreateProcess(PChar(Executable), PChar(CommandLine), Nil, Nil, False, CREATE_NO_WINDOW, Nil, WorkDir, Startup, Process));
   Result := Process.dwProcessId;
   CloseHandle(Process.hThread);
   CloseHandle(Process.hProcess);
  End;

 Procedure ConfigureAutoStart(Enabled : Boolean; Const Executable, RegistryPath : String);
  Var
   Registry : TRegistry;
   Value    : String;
  Begin
   Registry := TRegistry.Create(KEY_READ Or KEY_WRITE);
   Try
    Registry.RootKey := HKEY_CURRENT_USER;
    If Enabled Then
     Begin
      If Not Registry.OpenKey(RegistryPath, True) Then
       Raise EOSError.Create('Cannot open Windows startup key');
      Value := QuoteProcessArgument(ExpandFileName(Executable)) + ' --hidden';
      If Not Registry.ValueExists('Guake') Or (Registry.ReadString('Guake') <> Value) Then
       Registry.WriteString('Guake', Value);
     End
    Else If Registry.OpenKey(RegistryPath, False) And Registry.ValueExists('Guake') Then
     Registry.DeleteValue('Guake');
   Finally
    Registry.Free;
   End;
  End;

Initialization

Finalization
 RemoveProxyGuard;

End.
