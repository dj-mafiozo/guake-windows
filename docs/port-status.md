# Stan portu Guake dla Windows

Źródło odniesienia: lokalny klon `..\guake`, rewizja `0911ddfe25a0c4019d2516b90982854d192e91cd`.
`guake-contract.json` zawiera inwentarz ustawień, metod zdalnych i opcji CLI tego źródła. Odtworzenie: `tools/Export-GuakeContract.ps1`. Inwentarz nie jest deklaracją obsługi funkcji.

| Obszar | Stan |
| --- | --- |
| Ustawienia | TGuakeSettings, TMemIniFile, UTF-8, jawny zapis i przeładowanie, zapis przez plik tymczasowy w tym samym katalogu, zachowanie nieznanych kluczy, podstawowe właściwości z walidacją |
| Profile powłok | CMD i Windows PowerShell z SystemRoot; Bash i Zsh z konfigurowalnego git-sdk-64; cytowanie argumentu programu i wykrywanie brakującego pliku |
| Wersja | Common/VersionU odczytuje VersionInfo wygenerowane przez MSBuild; liczniki w DPROJ |
| Testy | DUnitX, Win64, kod wyjścia i raport NUnit XML |
| ConPTY i procesy | Do implementacji i testów integracyjnych |
| Emulator VT i renderowanie | Do implementacji; parser strumieniowy, Unicode, SGR/256/truecolor, ekran alternatywny, historia, wejście klawiatury i myszy |
| Główne okno i preferencje | Do implementacji w VCL/DFM; zrzuty Guake jako wzorzec porównań |
| Zakładki, podziały, sesje | Do implementacji |
| Named Pipes i CLI | Do implementacji; protokół żądanie/odpowiedź, ograniczony rozmiar ramek, ACL użytkownika, lokalni klienci, timeouty |
| Skróty, monitory, animacja, tray | Do implementacji |
| Pełna zgodność funkcji i wyglądu | Nieosiągnięta |

Klasy ustawień są przeznaczone dla jednego wątku zarządzającego konfiguracją. Destruktor nie zapisuje niejawnie danych. Interfejs widoku nie powinien bezpośrednio używać TMemIniFile. Powłoki muszą otrzymać własne środowisko sesji przy CreateProcessW; nie należy zmieniać globalnego środowiska aplikacji pod uruchamiany terminal. PowerShell 7 wymaga osobnego profilu lub rozszerzenia mechanizmu wykrywania; obecny profil wskazuje wbudowany Windows PowerShell.

## Wersjonowanie

Pierwsza wersja: **1.0.0.1**. Major i minor pozostają niezmienione. Każdy kolejny przebieg budowania zwiększa build, również jeśli kompilacja zakończy się błędem. Przygotowanie każdego commita zwiększa release o jeden; build nigdy nie jest resetowany. Skrypt odmawia przekroczenia limitu 65535 zamiast zawijać licznik.

`tools/Test.ps1` zwiększa build, buduje projekt przez MSBuild i uruchamia DUnitX. Przed commitem uruchom `tools/Update-Version.ps1 -Part Release`, wykonaj wymagane formatowanie zmienionych źródeł Delphi, zweryfikuj projekt i uruchom testy. Sprawdź, że Common odczytuje tę samą wersję, którą wygenerował MSBuild. Nie dodawaj RES ani wrappera RC dla VersionInfo lub manifestu.
## Lokalizacja i logi

Zaimportowano 26 oryginalnych PO Guake do locale/po wraz z nagłówkami autorów. tools/Import-Translations.py generuje katalogi JSON przez GNU msgfmt. Guake.Localization ładuje je do TTranslationCatalog z vendor/i18n; zachowuje konteksty i reguły liczby mnogiej. Testy obejmują wszystkie katalogi, polski tekst, brakujące tłumaczenie i formy 1/2/5/12/22.

Guake.Logging zapisuje klasę i treść wyjątku, przechwycony Exception.StackTrace, wersję, czas, PID i identyfikator wątku. Po przekroczeniu 4 MiB poprzedni plik przechodzi do .old. Błąd zapisu jest sygnalizowany przez False oraz OutputDebugString, bez zastępowania pierwotnego wyjątku. Blokada chroni współbieżne zapisy jednego obiektu loggera; różne procesy powinny mieć oddzielne logi.

vendor/stacktrace pochodzi z dostarczonego vendor/Delphi-StackTrace; katalog otrzymał nazwę wymaganą dla tego projektu. Jednostka StackTrace jest pierwsza w DPR testów. Włączono stack frames i szczegółowy MAP. Nie znaleziono lokalnego map2pdb: aktualne testy potwierdzają przechwycenie stosu, ale nie rozwiązywanie nazw funkcji i numerów linii. Do dystrybucji symboli należy dodać map2pdb i pakować zgodny PDB z każdym EXE. Podłączenie loggera do zdarzeń VCL pozostaje częścią implementacji formularzy aplikacji.
