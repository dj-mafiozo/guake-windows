# Tłumaczenia Guake

`po/` zawiera niezmienione katalogi z lokalnego Guake, rewizja `0911ddfe25a0c4019d2516b90982854d192e91cd`. Nagłówki zachowują autorów i warunki licencji; tekst licencji źródła znajduje się w COPYING.

`catalogs/` to odtwarzalne dane dla Guake.Localization. Z katalogu repozytorium uruchom `python Src/Tools/Import-Translations.py`, opcjonalnie `--msgfmt <ścieżka>`. GNU msgfmt pomija fuzzy, wpisy przestarzałe i nieprzetłumaczone. Import zachowuje kontekst, UTF-8, msgid, wszystkie formy liczby mnogiej i Plural-Forms.

W czasie działania `Guake.Localization.pas` buduje `TTranslationCatalog` z `Src/Vendor/i18n` i korzysta z jego identyfikatorów, wyszukiwania i silnika liczby mnogiej. Brak tłumaczenia pozostawia tekst źródłowy. Formularze dostosowują znaczniki i mnemoniki GTK do VCL; placeholdery poleceń pozostają danymi dla przyszłego kontrolera Quick Open.

`Src/Tools/Test.ps1` kopiuje katalogi obok EXE do `locale/catalogs`. Obecne punkty startowe ładują polski katalog. Sam formularz preferencji może otrzymać dowolny załadowany `TGuakeLocalization`; automatyczny wybór języka wymaga dalszej integracji.
