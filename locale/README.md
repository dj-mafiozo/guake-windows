# Tłumaczenia Guake

`po/` zawiera niezmienione katalogi z lokalnego Guake, rewizja `0911ddfe25a0c4019d2516b90982854d192e91cd`. Nagłówki plików zachowują autorów i warunki licencji; tekst licencji źródłowej znajduje się w COPYING.

`catalogs/` to odtwarzalne dane wejściowe dla Guake.Localization. Odświeżenie: `python tools/Import-Translations.py`, opcjonalnie `--msgfmt <ścieżka>`. GNU msgfmt pomija wpisy fuzzy, przestarzałe i nieprzetłumaczone. Import zachowuje kontekst, UTF-8, oryginalne msgid, wszystkie formy liczby mnogiej i regułę Plural-Forms. Nie przerabia automatycznie znaczników GTK, skrótów mnemonicznych ani placeholderów Pythona; dostosowanie ich do właściwych kontrolek VCL należy do warstwy widoku.

W czasie działania Guake.Localization buduje TTranslationCatalog z vendor/i18n i używa jego identyfikatorów, wyszukiwania tłumaczeń oraz silnika TPluralForms. Brak tłumaczenia pozostawia angielski tekst źródłowy. Katalogi należy dostarczać obok EXE w katalogu locale/catalogs; testy wskazują katalog źródłowy w repozytorium.