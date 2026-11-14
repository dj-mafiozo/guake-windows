# Guake dla Windows

## Wymagania portu

- Punktem odniesienia funkcji i wyglądu jest lokalny klon `..\guake`.
- Delphi, wyłącznie Windows 64-bit, VCL i natywne WinAPI. Backend terminala: ConPTY.
- Statyczne formularze, ramki, komponenty i dialogi definiuj w DFM (UTF-8 z BOM).
- Ustawienia przechowuje osobna klasa używająca TMemIniFile; bez GSettings.
- Komunikacja między procesami przez Named Pipes, bez D-Bus. Ogranicz dostęp do bieżącego użytkownika i odrzucaj klientów zdalnych.
- Obsługiwane powłoki: CMD, PowerShell, Bash i Zsh z git-sdk-64. Każda sesja ma własny proces ConPTY, katalog roboczy i środowisko.
- ConPTY dostarcza strumień VT, nie gotowy widok. Emulator musi zachować stan parsera i dekodera UTF-8 między odczytami; zwykłe pole tekstowe nie zastępuje emulatora.
- Pełna zgodność jest celem; nie deklaruj jej bez sprawdzenia funkcji oraz porównania interfejsu z Guake. Stan prac opisuje docs/port-status.md.

## Delphi

- Jednostki projektu deklaruj jawnie w DPR/DPK z `in` i ścieżką względną; synchronizuj z DCCReference.
- Nie śledź plików RES. Niestandardowe zasoby przechowuj jako RC i kompiluj podczas budowania. VersionInfo i manifest pozostaw MSBuild; nie powielaj ich w RC.
- Po każdej zmianie PAS/DPR/DPK/INC, przed kompilacją, testami i commitem uruchom wyłącznie `C:\Users\Mateusz\Documents\GitHub\Delphi-Formatter\doFormat.bat` na zmienionych źródłach. Sprawdź diff i integralność kodu. Błąd formattera zatrzymuje kompilację i commit.
- Formatter nie może zapisywać DPROJ/GROUPPROJ. Zachowuj dyrektywy formatowania.
- Testy scenariuszy i asercje pisz w DUnitX; raport XML i niezerowy kod wyjścia przy niepowodzeniu są wymagane.
- Domyślne wiadomości commitów: szczegółowe, naturalne, po polsku, z problemem, rozwiązaniem i istotnymi wynikami testów.
- Zachowuj zmiany użytkownika. Nie wykonuj push bez polecenia.
## Wersjonowanie i commity

- Używaj submodułu `Src/Common` i `VersionU.pas` do odczytu wersji EXE. Nie kopiuj tej jednostki do projektu i nie modyfikuj submodułu przy zmianie wersji aplikacji.
- Początek: 1.0.0.1. Każdy kolejny przebieg zwiększa build. Każdy commit zwiększa release. Nie zmieniaj major/minor i nigdy nie resetuj build.
- Liczniki i tekstowe FileVersion/ProductVersion utrzymuj zgodne w konfiguracji MSBuild; nie twórz RC dla tych zasobów.
- Zwiększenie release: Src/Tools/Update-Version.ps1 -Part Release. Build kolejnego przebiegu prac: Src/Tools/Update-Version.ps1 -Part Build. Testy: Src/Tools/Test.ps1. Samo budowanie i testowanie nie zmienia wersji.
- Twórz commity lokalne z naturalnym polskim opisem problemu, rozwiązania i testów, bez metainformacji o lokalnym commicie i braku push.

## Lokalizacja i diagnostyka

- Lokalizację opieraj na Src/Vendor/i18n. Tłumaczenia przenoś z oryginalnych PO Guake, zachowując źródła, autorów, konteksty i liczbę mnogą. Odtwarzalny import: Src/Tools/Import-Translations.py.
- Stacktrace zapewnia Src/Vendor/stacktrace. StackTrace musi być pierwszą jednostką DPR. Włącz stack frames i szczegółowy MAP. Nie loguj stosu bieżącego miejsca obsługi jako stosu miejsca powstania wyjątku: używaj Exception.StackTrace.
- Logger nie może zastępować pierwotnego wyjątku błędem zapisu logu. Nazwy funkcji i numery linii wymagają aktualnych PDB wygenerowanych z MAP przez map2pdb.

## Struktura źródeł i aktualność dokumentacji

- Cały kod, projekty, testy, narzędzia i źródłowe dane aplikacji utrzymuj pod `Src/`, w podkatalogach odpowiadających ich roli. Projekt główny: `Src/guake.dpr` i `Src/guake.dproj`.
- Formularze PAS/DFM należą do `Src/Forms/`; moduły danych `dm*.pas` i `dm*.dfm` wyłącznie do `Src/DataModules/`.
- Ustawienia dziel na rekordy hierarchiczne: General, Style.Font, Style.Background, Keybindings.Global, Keybindings.Local i Hooks. Osobna klasa zarządza INI, walidacją i zapisem.
- Umieszczaj `{$StackFrames On}` w pierwszej linii każdego PAS i DPR. Budowanie ma generować PDB z MAP przez map2pdb i dostarczać PDB obok właściwego EXE, także w paczkach.
- Zachowaj w credits: `Copyright © 2026 DJ M@fi0z0™ - native Windows port` i `DJ M@fi0z0™ <inz.germanista@gmail.com>`, obok oryginalnych autorów i licencji.
- Aktualizuj pliki Markdown razem ze zmianami kodu, układu katalogów, poleceń, testów i rzeczywistego zakresu funkcji. Usuń nieaktualne opisy zamiast dopisywać sprzeczne uzupełnienia.
- W DPROJ używaj list zależności targets, np. ResourceBuildDependsOn, zamiast BeforeTargets i AfterTargets nierozpoznawanych przez starszy parser IDE.

## Wzorzec wizualny

- Oprócz lokalnych źródeł Guake korzystaj ze zrzutów Manjaro opisanych w `docs/visual-reference.md`. Aktualizuj opis wzorca i `docs/port-status.md` razem z interfejsem.
- W oknie informacji panel autorów i licencji wysuwa się od dołu. Zachowuj animację istniejących kontrolek DFM zamiast zastępować ją samym przełączaniem Visible.
- Nieaktywne pozycje menu nie oznaczają zaimplementowanych funkcji. W dokumentacji rozróżniaj odtworzenie układu od działania zapisu sesji, Quick Open i pozostałych integracji.
