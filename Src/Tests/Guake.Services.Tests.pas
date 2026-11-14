{$StackFrames On}

/// <summary>DUnitX verification of services tests.</summary>
Unit Guake.Services.Tests;

Interface

 Uses
  DUnitX.TestFramework, Guake.Localization, Guake.Logging;

 Type

  [TestFixture]
  TServiceTests = Class
   Private
    fDirectory : String;
    fLocalizer : TGuakeLocalization;
   Public
    [Setup]    Procedure Setup;
    [TearDown] Procedure TearDown;
    [Test]     Procedure OriginalPolishTranslation;
    [Test]     Procedure AllOriginalCatalogsLoad;
    [Test]     Procedure ContextAndPluralForms;
    [Test]     Procedure FailedLoadPreservesLanguage;
    [Test]     Procedure ExceptionLogContainsCapturedStack;
    [Test]     Procedure LoggingFailureDoesNotReplaceException;
  End;

Implementation

 Uses
  System.SysUtils, System.Classes, System.IOUtils;

 Function CatalogDirectory : String;
  Begin
   Result := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..\Src\Localization\catalogs'));
  End;

 Procedure TServiceTests.Setup;
  Begin
   fDirectory := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
   ForceDirectories(fDirectory);
   fLocalizer := TGuakeLocalization.Create;
  End;

 Procedure TServiceTests.TearDown;
  Begin
   fLocalizer.Free;
   TDirectory.Delete(fDirectory, True);
  End;

 Procedure TServiceTests.OriginalPolishTranslation;
  Begin
   fLocalizer.Load(TPath.Combine(CatalogDirectory, 'pl.json'));
   Assert.AreEqual('pl', fLocalizer.Language);
   Assert.AreEqual('Terminal Guake', fLocalizer.Text('Guake Terminal'));
   Assert.AreEqual('No translation yet', fLocalizer.Text('No translation yet'));
  End;

 Procedure TServiceTests.AllOriginalCatalogsLoad;
  Var
   FileName : String;
   Count    : Integer;
  Begin
   Count := 0;
   For FileName In TDirectory.GetFiles(CatalogDirectory, '*.json') Do
    Begin
     fLocalizer.Load(FileName);
     Assert.IsTrue(fLocalizer.Language <> '', FileName);
     Inc(Count);
    End;
   Assert.AreEqual(26, Count);
  End;

 Procedure TServiceTests.ContextAndPluralForms;
  Var
   FileName : String;
  Begin
   FileName := TPath.Combine(fDirectory, 'test.json');
   TFile.WriteAllText(FileName,
   '{"language":"pl","pluralRule":"nplurals=3; plural=n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;",' +
   '"entries":[{"context":"menu","singular":"Open","plural":"","translations":["Otwórz"]},' +
   '{"context":"","singular":"tab","plural":"tabs","translations":["karta","karty","kart"]}]}', TEncoding.UTF8);
   fLocalizer.Load(FileName);
   Assert.AreEqual('Otwórz', fLocalizer.Text('Open', 'menu'));
   Assert.AreEqual('Open', fLocalizer.Text('Open'));
   Assert.AreEqual('karta', fLocalizer.NText('tab', 'tabs', 1));
   Assert.AreEqual('karty', fLocalizer.NText('tab', 'tabs', 2));
   Assert.AreEqual('kart', fLocalizer.NText('tab', 'tabs', 5));
   Assert.AreEqual('kart', fLocalizer.NText('tab', 'tabs', 12));
   Assert.AreEqual('karty', fLocalizer.NText('tab', 'tabs', 22));
  End;

 Procedure TServiceTests.FailedLoadPreservesLanguage;
  Var
   FileName : String;
  Begin
   fLocalizer.Load(TPath.Combine(CatalogDirectory, 'pl.json'));
   FileName := TPath.Combine(fDirectory, 'broken.json');
   TFile.WriteAllText(FileName, '{broken', TEncoding.UTF8);
   Assert.WillRaise(Procedure Begin fLocalizer.Load(FileName); End, EConvertError);
   Assert.AreEqual('Terminal Guake', fLocalizer.Text('Guake Terminal'));
  End;

 Procedure TServiceTests.ExceptionLogContainsCapturedStack;
  Var
   Log      : TGuakeLog;
   FileName : String;
   Text     : String;
  Begin
   FileName := TPath.Combine(fDirectory, 'exceptions.log');
   Log      := TGuakeLog.Create(FileName);
   Try
    Try
     Raise EInvalidOpException.Create('Błąd testowy — 日本語');
    Except
     On E : Exception Do
      Begin
       Assert.IsTrue(E.StackTrace <> '', 'StackTrace must capture the raising stack');
       Assert.IsTrue(Log.TryLogException(E, 'integration test'));
      End;
    End;
    Text := TFile.ReadAllText(FileName, TEncoding.UTF8);
    Assert.IsTrue(Pos('EInvalidOpException', Text) > 0);
    Assert.IsTrue(Pos('Błąd testowy — 日本語', Text) > 0);
    Assert.IsTrue(Pos('integration test', Text) > 0);
    Assert.IsFalse(Pos('(stack unavailable)', Text) > 0);
   Finally
    Log.Free;
   End;
  End;

 Procedure TServiceTests.LoggingFailureDoesNotReplaceException;
  Var
   Log      : TGuakeLog;
   FileName : String;
  Begin
   FileName := TPath.Combine(fDirectory, 'is-a-file');
   TFile.WriteAllText(FileName, 'block directory');
   Log := TGuakeLog.Create(TPath.Combine(FileName, 'exceptions.log'));
   Try
    Try
     Raise EInvalidOpException.Create('original error');
    Except
     On E : Exception Do
      Begin
       Assert.IsFalse(Log.TryLogException(E, 'test'));
       Assert.AreEqual('original error', E.Message);
      End;
    End;
   Finally
    Log.Free;
   End;
  End;

Initialization
 TDUnitX.RegisterTestFixture(TServiceTests);

End.
