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
- Zwiększenie release: tools/Update-Version.ps1 -Part Release. Kolejny przebieg i testy: tools/Test.ps1.
- Twórz commity lokalne z naturalnym polskim opisem problemu, rozwiązania i testów, bez metainformacji o lokalnym commicie i braku push.

## Lokalizacja i diagnostyka

- Lokalizację opieraj na vendor/i18n. Tłumaczenia przenoś z oryginalnych PO Guake, zachowując źródła, autorów, konteksty i liczbę mnogą. Odtwarzalny import: tools/Import-Translations.py.
- Stacktrace zapewnia vendor/stacktrace. StackTrace musi być pierwszą jednostką DPR. Włącz stack frames i szczegółowy MAP. Nie loguj stosu bieżącego miejsca obsługi jako stosu miejsca powstania wyjątku: używaj Exception.StackTrace.
- Logger nie może zastępować pierwotnego wyjątku błędem zapisu logu. Nazwy funkcji i numery linii wymagają aktualnych PDB wygenerowanych z MAP przez map2pdb.
