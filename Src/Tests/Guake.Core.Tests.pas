{$StackFrames On}

/// <summary>DUnitX verification of core tests.</summary>
Unit Guake.Core.Tests;

Interface

 Uses
  DUnitX.TestFramework, Guake.Settings, Guake.Shells;

 Type

  [TestFixture]
  TSettingsTests = Class
   Private
    fDirectory : String;
    fSettings  : TGuakeSettings;
   Public
    [Setup]    Procedure Setup;
    [TearDown] Procedure TearDown;
    [Test]     Procedure DefaultsDoNotCreateFile;
    [Test]     Procedure SaveAndReloadUnicode;
    [Test]     Procedure PreserveUnknownKeys;
    [Test]     Procedure RejectInvalidDimensions;
    [Test]     Procedure RecoverInvalidDimensions;
    [Test]     Procedure ReloadDiscardsUnsavedChanges;
    [Test]     Procedure RejectMultilineValues;
  End;

  [TestFixture]
  TShellTests = Class
   Public
    [Test] Procedure QuoteWindowsArguments;
    [Test] Procedure ResolveGitSdkShells;
    [Test] Procedure ResolveWindowsShells;
    [Test] Procedure MissingShellIsUnavailable;
    [Test] Procedure CommonReadsGeneratedVersion;
  End;

Implementation

 Uses
  System.SysUtils, System.IOUtils, VersionU;

 Procedure TSettingsTests.Setup;
  Begin
   fDirectory := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
   ForceDirectories(fDirectory);
   fSettings := TGuakeSettings.Create(TPath.Combine(fDirectory, 'guake.ini'));
  End;

 Procedure TSettingsTests.TearDown;
  Begin
   fSettings.Free;
   TDirectory.Delete(fDirectory, True);
  End;

 Procedure TSettingsTests.DefaultsDoNotCreateFile;
  Begin
   Assert.AreEqual(100, fSettings.WindowWidth);
   Assert.AreEqual(50, fSettings.WindowHeight);
   Assert.AreEqual('', fSettings.Shell);
   Assert.IsFalse(TFile.Exists(fSettings.FileName));
  End;

 Procedure TSettingsTests.SaveAndReloadUnicode;
  Begin
   fSettings.WriteString('session', 'title', 'Zażółć gęślą jaźń — 日本語');
   fSettings.WindowHeight := 75;
   fSettings.Save;
   fSettings.Reload;
   Assert.AreEqual('Zażółć gęślą jaźń — 日本語', fSettings.ReadString('session', 'title', ''));
   Assert.AreEqual(75, fSettings.WindowHeight);
  End;

 Procedure TSettingsTests.PreserveUnknownKeys;
  Begin
   fSettings.WriteString('future', 'unknown', 'keep me');
   fSettings.Save;
   fSettings.Reload;
   fSettings.WindowWidth := 80;
   fSettings.Save;
   fSettings.Reload;
   Assert.AreEqual('keep me', fSettings.ReadString('future', 'unknown', ''));
  End;

 Procedure TSettingsTests.RejectInvalidDimensions;
  Begin
   Assert.WillRaise(Procedure Begin fSettings.WindowWidth  := 0; End, EArgumentOutOfRangeException);
   Assert.WillRaise(Procedure Begin fSettings.WindowHeight := 101; End, EArgumentOutOfRangeException);
   Assert.WillRaise(Procedure Begin fSettings.HistorySize  := -1; End, EArgumentOutOfRangeException);
  End;

 Procedure TSettingsTests.RecoverInvalidDimensions;
  Begin
   fSettings.WriteInteger('general', 'window-width', -1);
   fSettings.WriteString('general', 'window-height', 'broken');
   fSettings.WriteInteger('general', 'history-size', -3);
   Assert.AreEqual(100, fSettings.WindowWidth);
   Assert.AreEqual(50, fSettings.WindowHeight);
   Assert.AreEqual(1000, fSettings.HistorySize);
  End;

 Procedure TSettingsTests.ReloadDiscardsUnsavedChanges;
  Begin
   fSettings.WindowHeight := 60;
   fSettings.Save;
   fSettings.WindowHeight := 70;
   fSettings.Reload;
   Assert.AreEqual(60, fSettings.WindowHeight);
  End;

 Procedure TSettingsTests.RejectMultilineValues;
  Begin
   Assert.WillRaise(Procedure Begin fSettings.Shell := 'cmd' + #13#10 + 'other=bad'; End, EArgumentException);
  End;

 Procedure TShellTests.QuoteWindowsArguments;
  Begin
   Assert.AreEqual('""', QuoteProcessArgument(''));
   Assert.AreEqual('"C:\Program Files\shell.exe"', QuoteProcessArgument('C:\Program Files\shell.exe'));
   Assert.AreEqual('"a\"b"', QuoteProcessArgument('a"b'));
   Assert.AreEqual('"C:\dir\\"', QuoteProcessArgument('C:\dir\'));
  End;

 Procedure TShellTests.ResolveGitSdkShells;
  Var
   Profile : TShellProfile;
  Begin
   Profile := TShellProfile.Resolve(gsBash, 'C:\SDK with spaces');
   Assert.AreEqual('C:\SDK with spaces\usr\bin\bash.exe', Profile.Executable);
   Assert.AreEqual('--login -i', Profile.Arguments);
   Profile := TShellProfile.Resolve(gsZsh, 'C:\SDK with spaces');
   Assert.AreEqual('git-zsh.exe', ExtractFileName(Profile.Executable));
   Assert.AreEqual('--nomintty --git-sdk-root "C:\SDK with spaces" --login -i', Profile.Arguments);
  End;

 Procedure TShellTests.ResolveWindowsShells;
  Var
   Profile : TShellProfile;
  Begin
   Profile := TShellProfile.Resolve(gsCmd);
   Assert.IsTrue(Profile.Available);
   Assert.AreEqual('/D', Profile.Arguments);
   Profile := TShellProfile.Resolve(gsPowerShell);
   Assert.IsTrue(Profile.Available);
   Assert.AreEqual('-NoLogo', Profile.Arguments);
  End;

 Procedure TShellTests.MissingShellIsUnavailable;
  Var
   Profile : TShellProfile;
  Begin
   Profile := TShellProfile.Resolve(gsZsh, TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName));
   Assert.IsFalse(Profile.Available);
  End;

 Procedure TShellTests.CommonReadsGeneratedVersion;
  Var
   Info : TExeVersionInfo;
  Begin
   Info := ExeVersionInfo;
   Assert.IsTrue(Info.Available);
   Assert.AreEqual(1, Integer(Info.Major));
   Assert.AreEqual(0, Integer(Info.Minor));
   Assert.IsTrue(Info.Build > 0);
   Assert.AreEqual(Format('%d.%d.%d.%d', [Info.Major, Info.Minor, Info.Release, Info.Build]), Info.FileVersion);
   Assert.AreEqual(Info.FileVersion, Info.ProductVersion);
   Assert.AreEqual('GuakeTests.exe', Info.OriginalFilename);
  End;

Initialization
 TDUnitX.RegisterTestFixture(TSettingsTests);
 TDUnitX.RegisterTestFixture(TShellTests);

End.
