# Stan portu Guake dla Windows

Punkt odniesienia: lokalny `../guake`, rewizja `0911ddfe25a0c4019d2516b90982854d192e91cd`. Inwentarz: [guake-contract.json](guake-contract.json); odświeżenie: `Src/Tools/Export-GuakeContract.ps1` z katalogu repozytorium. Pełna zgodność funkcji i wyglądu pozostaje celem.

## Struktura

| Katalog | Zawartość |
| --- | --- |
| `Src/guake.dpr`, `Src/guake.dproj` | Główny projekt VCL Win64 |
| `Src/Settings` | Klasa ustawień i hierarchia rekordów |
| `Src/Forms` | Statyczne formularze PAS/DFM |
| `Src/DataModules` | Moduły danych PAS/DFM, standardowe dialogi plikowe |
| `Src/Terminal` | Profile CMD, Windows PowerShell, Bash i Zsh |
| `Src/Appearance` | 169 palet przeniesionych z Guake |
| `Src/Localization` | Warstwa lokalizacji, oryginalne PO i katalogi wynikowe |
| `Src/Diagnostics` | Logger wyjątków |
| `Src/Common` | Submoduł Common z VersionU |
| `Src/Vendor` | i18n i stacktrace |
| `Src/Tests` | DUnitX, dane referencyjne i pomocniczy podgląd formularzy |
| `Src/Tools` | Budowanie, wersjonowanie, PDB, importy i pakowanie |

## Ustawienia

Przeniesiono 130 kluczy, ich typy, nazwy sekcji, wartości domyślne i opisy z `org.guake.gschema.xml`. Hierarchia odpowiada sekcjom źródła:

```pascal
Settings.General.WindowWidth := 90;
Settings.Style.Font.CellHeightScale := 1.25;
Settings.Style.Background.Transparency := 90;
Settings.Keybindings.Global.ShowHide := 'F12';
Settings.Keybindings.Local.NewTab := '<Control><Shift>t';
Settings.Hooks.Show := 'echo gotowe';
Settings.Save;
```

`TGuakeSettings` zarządza `TMemIniFile`, ładowaniem rekordów, walidacją i jawnym zapisem przez plik tymczasowy w katalogu docelowym. Double zapisuje z kropką niezależnie od ustawień regionalnych. Błędne dane z INI wracają do wartości domyślnych; niepoprawne bezpośrednie zmiany rekordów blokują zapis. Zachowywane są nieznane klucze. Klasa jest przeznaczona dla jednego wątku zarządzającego konfiguracją.

Domyślne `General.DefaultShell` jest puste, zgodnie ze schematem Guake. Wybór powłoki domyślnej dla Windows należy do warstwy uruchamiania sesji. Istniejące aliasy `WindowWidth`, `WindowHeight`, `HistorySize` i `Shell` pozostają dostępne.

## Formularze i kod

| Źródło Guake | Port |
| --- | --- |
| `prefs.glade`, `prefs.py` | `Src/Forms/frmPreferencesU.pas/.dfm` |
| `guake.glade`, część okienkowa `guake_app.py` | `Src/Forms/frmMainU.pas/.dfm` |
| `about.glade`, `about.py` | `Src/Forms/frmAboutU.pas/.dfm` |
| `search.glade`, wyszukiwanie z `boxes.py` | `Src/Forms/frmSearchU.pas/.dfm` |
| `dialogs.py`: RenameDialog | `Src/Forms/frmRenameU.pas/.dfm` |
| `dialogs.py`: PromptQuitDialog, PromptResetColorsDialog | `Src/Forms/frmConfirmU.pas/.dfm` |
| `dialogs.py`: SaveTerminalDialog | `Src/DataModules/dmDialogsU.pas/.dfm` |

Preferencje zachowują dziewięć zakładek i grupy ustawień. Zapis odbywa się od razu, tak jak w Guake. Kandydat konfiguracji jest walidowany i zapisywany przed zmianą obiektu współdzielonego z aplikacją; nieudany zapis nie podmienia jego danych. Działają zależności kontrolek, wybór powłoki i monitora, palety z podglądem kolorów, font i obraz tła, skróty z wykrywaniem konfliktów oraz reset wyłącznie opcji zgodności. Trzy przyciski wyrównania odpowiadają radiobuttonom z Glade. Układ używa natywnych kontrolek VCL i przewijanych stron; nie jest to jeszcze potwierdzona zgodność wizualna piksel w piksel.

Wyszukiwanie obsługuje tekst, regex, kierunek, wielkość liter, zawijanie i zdarzenie wyniku. Indeksy wyniku są liczone od 1. Dialog zapisu przyjmuje tekst od kontrolera terminala i zapisuje UTF-8. Dialog informacji zachowuje logo, autorów, tłumaczy i licencję źródła oraz wpisy portu Windows:

- `Copyright © 2026 DJ M@fi0z0™ - native Windows port`
- `DJ M@fi0z0™ <inz.germanista@gmail.com>`

Okno główne obsługuje geometrię i położenie, przezroczystość, pozycję paska kart, pełny ekran, tray i otwieranie preferencji oraz informacji. Start aplikacji podłącza kontroler i uruchamia powłokę. Działają nowe karty, podziały, zmiana nazw, kopiowanie, wklejanie i wyszukiwanie. Test integracyjny ładuje widoki terminala i podziału z DFM, uruchamia CMD oraz sprawdza wielokrotne sprzątanie.

## Lokalizacja i diagnostyka

26 oryginalnych PO pozostaje bez zmian wraz z autorami. `Src/Tools/Import-Translations.py` generuje powtarzalne katalogi przez GNU msgfmt. `Guake.Localization` korzysta z `TTranslationCatalog` i `TPluralForms` z `Src/Vendor/i18n`. Formularz preferencji używa oryginalnych tekstów do zmiany języka; usuwa znaczniki GTK i dostosowuje mnemoniki do VCL. Nieprzetłumaczone napisy pozostają angielskie. Obecne punkty startowe wczytują polski katalog; wybór języka użytkownika wymaga jeszcze integracji.

`{$StackFrames On}` jest w pierwszej linii PAS i DPR. `StackTrace` jest pierwszą jednostką projektów. MSBuild generuje szczegółowy MAP, a `Src/Tools/Build-Symbols.py` wywołuje `map2pdb.exe -include:0001;0002`. PDB jest dostarczany obok właściwego EXE i trafia do ZIP. Test potwierdza przechwycony stos i rozwiązaną nazwę funkcji przy obecnym PDB. Dostępność numerów linii zależy od danych wygenerowanych przez konwerter; obecna konfiguracja nie gwarantuje ich dla każdej ramki.

Logger zapisuje klasę i treść wyjątku, jego oryginalny `Exception.StackTrace`, wersję, czas, PID i wątek. Rotuje plik po 4 MiB do `.old`. Awaria logowania nie zastępuje pierwotnego wyjątku. Pliki VersionInfo i manifestu pozostają generowane przez MSBuild; repozytorium nie śledzi RES.

## Weryfikacja i pozostały zakres

49 testów DUnitX Win64 obejmuje wszystkie wartości domyślne schematu, zapis i odczyt rekordów, Double w polskich ustawieniach regionalnych, walidację, nieznane klucze, ładowanie DFM, zależności, natychmiastowy zapis, błędy zapisu, reset zgodności, konflikty skrótów, palety, wyszukiwanie, zapis tekstu, wszystkie katalogi tłumaczeń, Common i logowanie stosów. Raport i podglądy dziewięciu zakładek powstają w `bin/tests/`.

Działają backend ConPTY, przyrostowy parser UTF-8 i VT, renderer komórek oraz kontroler kart i podziałów. Testy uruchamiają CMD, PowerShell, Bash i Zsh, sprawdzają środowisko, zakończenie procesów, zamykanie przy dużym wyjściu i zachowanie zasobów przy błędach startu. Emulator wymaga dalszego uzupełniania zgodności VT, m.in. reflow i pełnej obsługi grafemów. Nadal brakuje odtwarzania sesji, Named Pipes i zgodnego CLI. Zapis opcji w preferencjach nie oznacza jeszcze działania ich efektów poza formularzem: np. automatycznego startu, hooków, Quick Open czy ustawień renderowania. Niezaimplementowane pozostają integracje systemowe i funkcje zależne od tych modułów. Kontrolka widocznego dzwonka pozostaje wyłączona, ponieważ nie ma odpowiadającego jej klucza w źródłowym schemacie.

## Wersjonowanie

Początek: `1.0.0.1`. Major i minor pozostają niezmienione. Sam build i `Src/Tools/Test.ps1` nie zmieniają wersji. Build kolejnego przebiegu prac zwiększa się jawnie przez `Src/Tools/Update-Version.ps1 -Part Build`. Przed każdym commitem `Src/Tools/Update-Version.ps1 -Part Release` zwiększa release bez resetowania build. Wszystkie trzy projekty dostają tę samą wersję. Skrypt odmawia przekroczenia 65535 zamiast zawijać licznik.

## Zgodność projektów z IDE

DPROJ zawierają konfigurację wspólną Base oraz dziedziczące Debug i Release z kluczami Cfg_1 i Cfg_2, metadane osobowości Delphi i platformę Win64. Base oznacza wspólne opcje, a nie docelowy profil budowania. Usunięto niepublikowane zdarzenie TTabControl.OnDblClick; dwuklik jest przypisywany w FormCreate przez klasę dostępową TTabControlAccess. Sprzątanie formularza toleruje niepełne wczytanie DFM. Zapis projektu przez IDE wymaga jeszcze osobnej weryfikacji.

## Zasoby graficzne i bieżąca walidacja

Oryginalne pixmapy są w `Src/Resources/Pixmaps`, z sumami kontrolnymi w `pixmaps-source.json`. Klon Guake nie zawierał ICO; `guake.ico` i `tray.ico` opakowują oryginalne obrazy PNG w format ikon Windows. `Guake.Images.rc` zawiera wyłącznie niestandardowe zasoby. Ikonę główną, manifest i wersję EXE generuje MSBuild.

Wersja 1.0.3.38: 48/48 testów DUnitX, kompilacja Win64 Debug i Release, generowanie pasujących PDB. Testy sprawdzają też tworzenie i zwalnianie ramek terminala oraz podziałów. Budowanie zachowało sumy kontrolne DPROJ. Ponieważ uruchomiony wcześniejszy `guake.exe` blokował zwykły katalog wyjściowy, bieżące EXE i PDB zweryfikowano w `.build/verified-main` i `.build/verified-release`. Nie potwierdzono jeszcze zapisu projektu przez IDE ani pełnej zgodności wizualnej z Guake.

Dwuklik karty jest podłączany przez TTabControlAccess w FormCreate. DFM przechowuje wyłącznie publikowane zdarzenie OnCreate. Test sprawdza przypisanie OnDblClick po wczytaniu formularza. Konwersja MAP do PDB nie używa już opcji -bind i nie modyfikuje EXE; porównanie SHA-256 przed i po konwersji jest obowiązkową kontrolą skryptu. Test odczytu symbolicznego stosu przeszedł także z osobnym PDB. Wcześniejszy wariant Debug po modyfikacji przez -bind został zablokowany przez Windows kodem 225.

Wersja 1.0.4.39: 48/48 testów DUnitX, ponowne kompilacje Win64 Debug i Release oraz poprawny odczyt wersji obu EXE po utworzeniu osobnych PDB. Zwykły build nie zmienił numerów ani DPROJ. Pakiet `bin/guake-1.0.4.39-Win64.zip` zawiera EXE, PDB, tłumaczenia i licencje.

## Konflikty skrótów i zgodność MSBuild

Zajęty skrót globalny (błąd Windows 1409) nie przerywa startu terminala. Rejestracja obu skrótów odbywa się niezależnie; dostępny skrót nadal działa. Informacja o błędzie zawiera kombinację klawiszy i kod systemowy, trafia do podpowiedzi ikony tray i OutputDebugString. Kolejna rejestracja po zmianie ustawień ponawia próbę i usuwa nieaktualny komunikat. Test rezerwuje rzeczywisty skrót WinAPI, sprawdza start CMD mimo konfliktu, drugi skrót oraz ponowną rejestrację po zwolnieniu klawisza.

Wszystkie DPROJ dołączają BuildGuakeImages przez ResourceBuildDependsOn po imporcie standardowych targets. Nie używają BeforeTargets, którego starszy parser projektów Delphi nie rozpoznaje. Wszystkie trzy projekty przeszły odczyt przez Microsoft.Build.BuildEngine.Project, oprócz kompilacji współczesnym MSBuild. Kontrola odczytu nie zastępuje sprawdzenia zapisu z poziomu IDE.

Wersja 1.0.5.40: 49/49 testów DUnitX, kompilacja wszystkich trzech projektów Win64 Debug, odczyt trzech DPROJ przez starszy Microsoft.Build.BuildEngine.Project i paczka `bin/guake-1.0.5.40-Win64.zip`. Test PowerShell czeka na pierwszy prompt PSReadLine i nie zapisuje historii użytkownika. Pomiar uchwytów po nieudanym starcie oddziela jednorazową inicjalizację obsługi symboli od kolejnych prób.
