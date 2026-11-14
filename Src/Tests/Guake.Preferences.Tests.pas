{$StackFrames On}
/// <summary>DUnitX verification of preferences tests.</summary>
Unit Guake.Preferences.Tests;

Interface

 Uses
  System.SysUtils, DUnitX.TestFramework, Guake.Settings, Guake.Localization, frmPreferencesU;

 Type

  [TestFixture]
  TPreferencesTests = Class
   Private
    fUnexpectedError : String;
    Procedure UnexpectedError(Sender : TObject; e : Exception);
   Private
    fDirectory : String;
    fSettings  : TGuakeSettings;
    fForm      : TfrmPreferences;
   Public
    [Setup]    Procedure Setup;
    [TearDown] Procedure TearDown;
    [Test]     Procedure CompleteSchemaAndDefaults;
    [Test]     Procedure AllDefaultsSurviveSaveReload;
    [Test]     Procedure HierarchicalRecordsRoundTrip;
    [Test]     Procedure InvariantDoublePersistence;
    [Test]     Procedure InvalidRecordCannotBeSaved;
    [Test]     Procedure FormLoadsDFMWithoutWriting;
    [Test]     Procedure FormPersistsChangesImmediately;
    [Test]     Procedure DependenciesTrackSettings;
    [Test]     Procedure ResetOnlyCompatibility;
    [Test]     Procedure DuplicateShortcutIsRejected;
    [Test]     Procedure CaptureGraveAndTilde;
    [Test]     Procedure FailedSavePreservesSharedSettings;
    [Test]     Procedure PaletteUpdatesAllColors;
    [Test]     Procedure RenderAllPreferencePages;
    [Test]     Procedure OtherFormsLoadAndSearchWorks;
    [Test]     Procedure SymbolicStackUsesMatchingPdb;
    [Test]     Procedure SidebarSelectsReferencePages;
    [Test]     Procedure AboutDetailsSlideUp;
  End;

Implementation

 Uses
  Winapi.Windows, System.Classes, System.IOUtils, System.JSON,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Graphics, Vcl.Imaging.pngimage,
  Guake.Palettes, frmAboutU, frmSearchU, frmRenameU, frmConfirmU, dmDialogsU, frmMainU;

 Procedure TPreferencesTests.UnexpectedError(Sender : TObject; e : Exception);
  Begin
   fUnexpectedError := e.ClassName + ': ' + e.Message;
   Writeln(fUnexpectedError);
   Writeln(e.StackTrace);
   Flush(Output);
  End;

 Procedure TPreferencesTests.Setup;
  Begin
   fDirectory := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
   ForceDirectories(fDirectory);
   fSettings        := TGuakeSettings.Create(TPath.Combine(fDirectory, 'guake.ini'));
   fUnexpectedError := '';
   fForm            := TfrmPreferences.Create(Nil);
   fForm.OnError    := UnexpectedError;
  End;

 Procedure TPreferencesTests.TearDown;
  Begin
   fForm.Free;
   fSettings.Free;
   TDirectory.Delete(fDirectory, True);
   Assert.AreEqual('', fUnexpectedError);
  End;

 Procedure TPreferencesTests.CompleteSchemaAndDefaults;
  Var
   Root    : TJSONValue;
   Entries : TJSONArray;
   Entry   : TJSONValue;
   k       : TGuakeSetting;
   d       : TGuakeSettingDefinition;
   Path    : String;
  Begin
   Path := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..\Src\Tests\fixtures\guake-schema.json'));
   Root := TJSONObject.ParseJSONValue(TFile.ReadAllText(Path, TEncoding.UTF8));
   Try
    Entries := Root As TJSONArray;
    Assert.AreEqual(Entries.Count, Ord(High(TGuakeSetting)) + 1);
    For Entry In Entries Do
     Begin
      Assert.IsTrue(TGuakeSettings.FindKey(Entry.GetValue<String>('section'), Entry.GetValue<String>('name'), k));
      d := TGuakeSettings.Definition(k);
      Assert.AreEqual(Entry.GetValue<String>('default'), d.DefaultValue, d.Section + '.' + d.Key);
      If d.Kind = skDouble Then
       Assert.AreEqual(FloatToStr(StrToFloat(d.DefaultValue, TFormatSettings.Invariant), TFormatSettings.Invariant), fSettings.GetValue(k))
      Else
       Assert.AreEqual(d.DefaultValue, fSettings.GetValue(k), d.Section + '.' + d.Key);
      Assert.IsTrue(TGuakeSettings.ValidValue(k, d.DefaultValue), d.Key);
     End;
   Finally
    Root.Free;
   End;
  End;

 Procedure TPreferencesTests.AllDefaultsSurviveSaveReload;
  Var
   Values : Array[TGuakeSetting] Of String;
   Key    : TGuakeSetting;
  Begin
   For Key      := Low(TGuakeSetting) To High(TGuakeSetting) Do
    Values[Key] := fSettings.GetValue(Key);
   fSettings.Save;
   fSettings.Reload;
   For Key := Low(TGuakeSetting) To High(TGuakeSetting) Do
    Assert.AreEqual(Values[Key], fSettings.GetValue(Key), TGuakeSettings.Definition(Key).Key);
  End;

 Procedure TPreferencesTests.HierarchicalRecordsRoundTrip;
  Begin
   fSettings.General.WindowWidth           := 82;
   fSettings.Style.Font.CellHeightScale    := 1.25;
   fSettings.Style.Background.Transparency := 75;
   fSettings.Keybindings.Global.ShowHide   := '<Control>F12';
   fSettings.Keybindings.Local.NewTab      := '<Alt>t';
   fSettings.Hooks.Show                    := 'echo gotowe';
   fSettings.Save;
   fSettings.Reload;
   Assert.AreEqual(82, fSettings.General.WindowWidth);
   Assert.AreEqual('1.25', fSettings.GetValue(gskStyleFontCellHeightScale));
   Assert.AreEqual(75, fSettings.Style.Background.Transparency);
   Assert.AreEqual('<Control>F12', fSettings.Keybindings.Global.ShowHide);
   Assert.AreEqual('<Alt>t', fSettings.Keybindings.Local.NewTab);
   Assert.AreEqual('echo gotowe', fSettings.Hooks.Show);
  End;

 Procedure TPreferencesTests.InvariantDoublePersistence;
  Var
   Previous : TFormatSettings;
  Begin
   Previous := FormatSettings;
   Try
    FormatSettings.DecimalSeparator          := ',';
    fSettings.General.TabActivityNewTabGrace := 3.5;
    fSettings.Save;
    fSettings.Reload;
    Assert.AreEqual('3.5', fSettings.GetValue(gskGeneralTabActivityNewTabGrace));
    Assert.IsTrue(Pos('tab-activity-new-tab-grace=3.5', TFile.ReadAllText(fSettings.FileName, TEncoding.UTF8)) > 0);
   Finally
    FormatSettings := Previous;
   End;
  End;

 Procedure TPreferencesTests.InvalidRecordCannotBeSaved;
  Begin
   fSettings.General.WindowWidth := 0;
   Assert.WillRaise(Procedure Begin fSettings.Save; End, EArgumentOutOfRangeException);
   Assert.IsFalse(TFile.Exists(fSettings.FileName));
  End;

 Procedure TPreferencesTests.FormLoadsDFMWithoutWriting;
  Begin
   fForm.Bind(fSettings);
   Assert.AreEqual(9, fForm.pages.PageCount);
   Assert.IsTrue(fForm.ctlRestoreTabsStartup.Checked);
   Assert.IsTrue(fForm.ctlMouseDisplay.Checked);
   Assert.AreEqual(10, fForm.ctlBackgroundTransparency.Position);
   Assert.AreEqual('Tango', fForm.ctlPaletteName.Text);
   Assert.IsFalse(TFile.Exists(fSettings.FileName));
   Assert.IsTrue(fForm.gridShortcuts.RowCount > 45);
  End;

 Procedure TPreferencesTests.FormPersistsChangesImmediately;
  Begin
   fForm.Bind(fSettings);
   fForm.ctlWindowOntop.Checked := False;
   fForm.SettingChanged(fForm.ctlWindowOntop);
   Assert.IsFalse(fSettings.General.WindowOntop);
   fSettings.Reload;
   Assert.IsFalse(fSettings.General.WindowOntop);
  End;

 Procedure TPreferencesTests.DependenciesTrackSettings;
  Begin
   fForm.Bind(fSettings);
   fForm.SetPreference(gskGeneralInfiniteHistory, 'true');
   Assert.IsFalse(fForm.ctlHistorySize.Enabled);
   fForm.SetPreference(gskGeneralMouseDisplay, 'false');
   Assert.IsTrue(fForm.ctlDisplayN.Enabled);
   fForm.SetPreference(gskGeneralPromptOnCloseTab, '2');
   Assert.IsFalse(fForm.ctlPromptOnQuit.Enabled);
   fForm.SetPreference(gskGeneralWindowLosefocus, 'true');
   Assert.IsTrue(fForm.ctlLazyLoseFocus.Enabled);
   fForm.SetPreference(gskGeneralUseDefaultFont, 'false');
   Assert.IsTrue(fForm.ctlFontStyle.Enabled);
  End;

 Procedure TPreferencesTests.ResetOnlyCompatibility;
  Begin
   fSettings.General.WindowWidth     := 83;
   fSettings.General.CompatBackspace := 'ascii-backspace';
   fSettings.General.WordChars       := 'abc';
   fForm.Bind(fSettings);
   fForm.ResetCompatibility;
   Assert.AreEqual(83, fSettings.General.WindowWidth);
   Assert.AreEqual('ascii-delete', fSettings.General.CompatBackspace);
   Assert.AreEqual('-A-Za-z0-9,./?%&#:_~', fSettings.General.WordChars);
  End;

 Procedure TPreferencesTests.DuplicateShortcutIsRejected;
  Begin
   fForm.Bind(fSettings);
   Assert.WillRaise(Procedure Begin fForm.SetShortcut(gskKeybindingsLocalNewTab, '<shift><CONTROL>q'); End, EArgumentException);
   Assert.AreEqual('<Control><Shift>t', fSettings.Keybindings.Local.NewTab);
   fForm.SetShortcut(gskKeybindingsLocalNewTab, 'disabled');
   Assert.AreEqual('disabled', fSettings.Keybindings.Local.NewTab);
  End;

 Procedure TPreferencesTests.FailedSavePreservesSharedSettings;
  Var
   FileName : String;
   Other    : TGuakeSettings;
  Begin
   FileName := TPath.Combine(fDirectory, 'blocking-file');
   TFile.WriteAllText(FileName, 'x');
   Other := TGuakeSettings.Create(TPath.Combine(FileName, 'settings.ini'));
   Try
    fForm.Bind(Other);
    Assert.WillRaise(Procedure Begin fForm.SetPreference(gskGeneralWindowWidth, '80'); End);
    Assert.AreEqual(100, Other.General.WindowWidth);
   Finally
    fForm.Bind(fSettings);
    Other.Free;
   End;
  End;

 Procedure TPreferencesTests.PaletteUpdatesAllColors;
  Begin
   fForm.Bind(fSettings);
   Assert.AreEqual(169, GuakePaletteCount);
   fForm.ctlPaletteName.ItemIndex := 0;
   fForm.SettingChanged(fForm.ctlPaletteName);
   Assert.AreEqual(GuakePaletteValue(0), fSettings.Style.Font.Palette);
   Assert.AreEqual(GuakePaletteName(0), fSettings.Style.Font.PaletteName);
  End;

 Procedure TPreferencesTests.RenderAllPreferencePages;
  Var
   i             : Integer;
   Bitmap        : TBitmap;
   Image         : TPngImage;
   DirectoryName : String;
   Localizer     : TGuakeLocalization;
  Begin
   Localizer := TGuakeLocalization.Create;
   Try
    Localizer.Load(TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..\Src\Localization\catalogs\pl.json')));
    fForm.Bind(fSettings, Localizer);
    DirectoryName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'preferences-preview');
    ForceDirectories(DirectoryName);
    fForm.Position := poDesigned;
    fForm.Left     := -30000;
    fForm.Show;
    fForm.Update;
    Application.ProcessMessages;
    Assert.IsTrue(fForm.scrollGeneral.VertScrollBar.Range > fForm.scrollGeneral.ClientHeight);
    fForm.HandleNeeded;
    For i := 0 To fForm.pages.PageCount - 1 Do
     Begin
      fForm.pages.ActivePageIndex := i;
      Application.ProcessMessages;
      fForm.Update;
      fForm.pages.ActivePage.HandleNeeded;
      Bitmap := fForm.GetFormImage;
      Try
       Assert.IsTrue((Bitmap.Width > 800) And (Bitmap.Height > 600));
       Image := TPngImage.Create;
       Try
        Image.Assign(Bitmap);
        Image.SaveToFile(TPath.Combine(DirectoryName, IntToStr(i) + '.png'));
       Finally
        Image.Free;
       End;
      Finally
       Bitmap.Free;
      End;
     End;
   Finally
    fForm.Bind(fSettings);
    Localizer.Free;
   End;
  End;

 Procedure TPreferencesTests.OtherFormsLoadAndSearchWorks;
  Var
   AboutForm   : TfrmAbout;
   RenameForm  : TfrmRename;
   ConfirmForm : TfrmConfirm;
   SearchForm  : TfrmSearch;
   MainForm    : TfrmMain;
   Dialogs     : TdmDialogs;
   FileName    : String;
  Begin
   AboutForm := TfrmAbout.Create(Nil);
   Try
    AboutForm.LoadVersion;
    Assert.IsTrue(AboutForm.lblVersion.Caption <> '');
   Finally
    AboutForm.Free;
   End;
   RenameForm := TfrmRename.Create(Nil);
   Try
    Assert.AreEqual(mrOk, RenameForm.btnOK.ModalResult);
   Finally
    RenameForm.Free;
   End;
   ConfirmForm := TfrmConfirm.Create(Nil);
   Try
    ConfirmForm.ConfigureQuit(Nil, 2, 1);
    Assert.IsTrue(Pos('2', ConfirmForm.memoProcesses.Text) > 0);
   Finally
    ConfirmForm.Free;
   End;
   MainForm := TfrmMain.Create(Nil);
   Try
    MainForm.Bind(fSettings);
    Assert.IsFalse(MainForm.miNewTab.Enabled);
   Finally
    MainForm.Free;
   End;
   SearchForm := TfrmSearch.Create(Nil);
   Try
    SearchForm.SetContent('abc ABC abc');
    SearchForm.edtSearch.Text := 'abc';
    Assert.AreEqual(9, SearchForm.MatchStart);
    SearchForm.PreviousClick(Nil);
    Assert.AreEqual(5, SearchForm.MatchStart);
    SearchForm.chkMatchCase.Checked := True;
    SearchForm.SearchChanged(Nil);
    SearchForm.PreviousClick(Nil);
    Assert.AreEqual(1, SearchForm.MatchStart);
    SearchForm.PreviousClick(Nil);
    Assert.AreEqual(9, SearchForm.MatchStart);
   Finally
    SearchForm.Free;
   End;
   Dialogs := TdmDialogs.Create(Nil);
   Try
    FileName := TPath.Combine(fDirectory, 'terminal.txt');
    Dialogs.SaveText(FileName, '  Zażółć ');
    Assert.AreEqual('Zażółć', TFile.ReadAllText(FileName, TEncoding.UTF8));
   Finally
    Dialogs.Free;
   End;
  End;

 Procedure TPreferencesTests.SymbolicStackUsesMatchingPdb;
  Begin
   Try
    Raise EInvalidOpException.Create('symbol test');
   Except
    On e : Exception Do
     Begin
      Assert.IsTrue(Pos('SymbolicStackUsesMatchingPdb', e.StackTrace) > 0, e.StackTrace);
      Assert.IsTrue(TFile.Exists(ChangeFileExt(ParamStr(0), '.pdb')));
     End;
   End;
  End;

/// <summary>Captures the OEM grave key and its shifted tilde form in the actual preferences grid.</summary>

 Procedure TPreferencesTests.CaptureGraveAndTilde;
  Var
   Key : Word;
  Begin
   fForm.Bind(fSettings);
   fForm.gridShortcuts.Row := 1;
   fForm.ShortcutDblClick(Nil);
   Key := VK_OEM_3;
   fForm.ShortcutKeyDown(Nil, Key, []);
   Assert.IsTrue(Pos('grave', fForm.gridShortcuts.Cells[1, 1]) > 0);
   fForm.ShortcutDblClick(Nil);
   Key := VK_OEM_3;
   fForm.ShortcutKeyDown(Nil, Key, [ssShift]);
   Assert.IsTrue(Pos('asciitilde', fForm.gridShortcuts.Cells[1, 1]) > 0);
  End;

/// <summary>Verifies the reference sidebar against all existing DFM pages and the original logo.</summary>

 Procedure TPreferencesTests.SidebarSelectsReferencePages;
  Var
   Index : Integer;
  Begin
   fForm.Bind(fSettings);
   Assert.AreEqual(9, fForm.navPages.Items.Count);
   Assert.IsNotNull(fForm.imgHeader.Picture.Graphic);
   For Index := 0 To 8 Do
    Begin
     Assert.IsFalse(fForm.pages.pages[Index].TabVisible);
     fForm.navPages.ItemIndex := Index;
     fForm.NavigationClick(Nil);
     Assert.AreEqual(Index, fForm.pages.ActivePageIndex);
     Assert.AreEqual(fForm.pages.pages[Index].Caption, fForm.navPages.Items[Index]);
    End;
  End;

/// <summary>Credits and GPL details rise from the lower edge and collapse back to the compact summary.</summary>

 Procedure TPreferencesTests.AboutDetailsSlideUp;
  Var
   Dialog    : TfrmAbout;
   Localizer : TGuakeLocalization;
   Bottom    : Integer;
  Begin
   Localizer := TGuakeLocalization.Create;
   Dialog    := TfrmAbout.Create(Nil);
   Try
    Localizer.Load(TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..\Src\Localization\catalogs\pl.json')));
    Dialog.Localize(Localizer);
    Assert.AreEqual('Zasługi', Dialog.btnCredits.Caption);
    Assert.AreEqual('Licencja', Dialog.btnLicense.Caption);
    Assert.IsFalse(Dialog.pnlDetails.Visible);
    Dialog.CreditsClick(Nil);
    Assert.IsTrue(Dialog.animationTimer.Enabled);
    Assert.AreEqual(0, Dialog.pnlDetails.Height);
    Sleep(80);
    Dialog.AnimationTick(Nil);
    Assert.IsTrue(Dialog.pnlDetails.Height > 0);
    Assert.IsTrue(Dialog.pnlDetails.Height <= MulDiv(208, Dialog.PixelsPerInch, 96));
    Bottom := Dialog.pnlDetails.Top + Dialog.pnlDetails.Height;
    Sleep(140);
    Dialog.AnimationTick(Nil);
    Assert.IsFalse(Dialog.animationTimer.Enabled);
    Assert.AreEqual(Bottom, Dialog.pnlDetails.Top + Dialog.pnlDetails.Height);
    Assert.IsTrue(Pos('Copyright © 2026 DJ M@fi0z0™ - native Windows port', Dialog.memoCredits.Text) > 0);
    Dialog.LicenseClick(Nil);
    Assert.IsTrue(Dialog.memoLicense.Visible);
    Assert.IsFalse(Dialog.memoCredits.Visible);
    Sleep(220);
    Dialog.AnimationTick(Nil);
    Assert.IsTrue(Pos('GNU General Public', Dialog.memoLicense.Text) > 0);
    Dialog.LicenseClick(Nil);
    Sleep(220);
    Dialog.AnimationTick(Nil);
    Assert.IsFalse(Dialog.pnlDetails.Visible);
    Assert.IsTrue(Dialog.lblVersion.Visible);
   Finally
    Dialog.Free;
    Localizer.Free;
   End;
  End;

Initialization
 TDUnitX.RegisterTestFixture(TPreferencesTests);

End.
