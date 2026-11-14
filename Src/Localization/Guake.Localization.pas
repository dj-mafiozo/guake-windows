{$StackFrames On}

/// <summary>Loads translated messages and plural rules through the vendored i18n engine.</summary>
Unit Guake.Localization;

Interface

 Uses
  System.SysUtils, i18nCatalog, i18nPlurals;

 Type
  TGuakeLocalization = Class
   Private
    fCatalog     : TTranslationCatalog;
    fPluralForms : TPluralForms;
    fLanguage    : String;
    Function Translation(Const Text, Context : String; Plural : Boolean) : TTextTranslation;
   Public
    Constructor Create;
    Destructor  Destroy; Override;
    Procedure   Load (Const FileName : String);
    Function    Text (Const Original : String; Const Context : String = '')                          : String;
    Function    NText(Const Singular, Plural : String; Count : Integer; Const Context : String = '') : String;
    Property Language : String Read fLanguage;
  End;

Implementation

 Uses
  System.Classes, System.IOUtils, System.JSON, i18nUtils, i18nHashList, i18nZStrList;

 Constructor TGuakeLocalization.Create;
  Begin
   Inherited;
   fCatalog     := TTranslationCatalog.Create;
   fPluralForms := TPluralForms.Create('nplurals=2; plural=(n != 1);');
   fLanguage    := 'en';
  End;

 Destructor TGuakeLocalization.Destroy;
  Begin
   fPluralForms.Free;
   fCatalog.Free;
   Inherited;
  End;

 Procedure TGuakeLocalization.Load(Const FileName : String);
  Var
   Root       : TJSONObject;
   Parsed     : TJSONValue;
   Entries    : TJSONArray;
   Variants   : TJSONArray;
   Item       : TJSONValue;
   Entry      : TJSONObject;
   Catalog    : TTranslationCatalog;
   Forms      : TPluralForms;
   Domain     : TTextDomain;
   Definition : TTextDefinition;
   Value      : String;
   Original   : String;
   Plural     : String;
   Context    : String;
   Locale     : String;
   ID         : String;
   Index      : Integer;
  Begin
   Parsed := TJSONObject.ParseJSONValue(TFile.ReadAllText(FileName, TEncoding.UTF8));
   Try
    If Not(Parsed Is TJSONObject) Then
     Raise EConvertError.Create('Invalid translation catalog');
    Root    := TJSONObject(Parsed);
    Locale  := Root.GetValue<String>('language');
    Entries := Root.GetValue<TJSONArray>('entries');
    Catalog := TTranslationCatalog.Create;
    Try
     Forms := TPluralForms.Create(Root.GetValue<String>('pluralRule'));
     Try
      Domain := Catalog.TextDomains.Add('guake');
      For Item In Entries Do
       Begin
        Entry    := Item As TJSONObject;
        Original := Entry.GetValue<String>('singular');
        Plural   := Entry.GetValue<String>('plural');
        Context  := Entry.GetValue<String>('context');
        Variants := Entry.GetValue<TJSONArray>('translations');
        If Variants.Count = 0 Then
         Continue;
        ID := GetStringIdentifier(Context + #4 + Original);
        If Plural <> '' Then
         ID        := '#' + ID;
        Definition := Domain.Literals.Add(ID);
        If Plural <> '' Then
         Definition.Value := Original + #0 + Plural
        Else
         Definition.Value := Original;
        Value             := '';
        For Index         := 0 To Variants.Count - 1 Do
         Begin
          If Index > 0 Then
           Value := Value + #0;
          Value  := Value + Variants.Items[Index].Value;
         End;
        Definition.Translations.Add(Locale).Value := Value;
       End;
      fCatalog.Free;
      fCatalog := Catalog;
      Catalog  := Nil;
      fPluralForms.Free;
      fPluralForms := Forms;
      Forms        := Nil;
      fLanguage    := Locale;
     Finally
      Forms.Free;
     End;
    Finally
     Catalog.Free;
    End;
   Finally
    Parsed.Free;
   End;
  End;

 Function TGuakeLocalization.Translation(Const Text, Context : String; Plural : Boolean) : TTextTranslation;
  Var
   Domain : TTextDomain;
   ID     : String;
  Begin
   Result := Nil;
   Domain := fCatalog.TextDomains.Find('guake');
   If Domain = Nil Then
    Exit;
   ID := GetStringIdentifier(Context + #4 + Text);
   If Plural Then
    ID    := '#' + ID;
   Result := Domain.Literals.TranslationOf(ID, fLanguage);
  End;

 Function TGuakeLocalization.Text(Const Original, Context : String) : String;
  Var
   Item : TTextTranslation;
  Begin
   Result := Original;
   Item   := Translation(Original, Context, False);
   If (Item <> Nil) And (Item.Value <> '') Then
    Result := Item.Value;
  End;

 Function TGuakeLocalization.NText(Const Singular, Plural : String; Count : Integer; Const Context : String) : String;
  Var
   Item  : TTextTranslation;
   Index : Integer;
  Begin
   If Count = 1 Then
    Result := Singular
   Else
    Result := Plural;
   Item    := Translation(Singular, Context, True);
   If Item = Nil Then
    Exit;
   Index := fPluralForms.IndexOf(Count);
   If (Index >= 0) And (Index < Item.PluralCount) And (Item.Plurals[Index] <> '') Then
    Result := Item.Plurals[Index];
  End;

End.
