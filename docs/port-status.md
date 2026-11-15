# Stan portu Guake dla Windows

Stan kodu na 15 listopada 2026, wersja 1.0.13.47. Punkt odniesienia: lokalny `../guake`, rewizja `0911ddfe25a0c4019d2516b90982854d192e91cd`, oraz [zrzuty Manjaro](visual-reference.md). [Inwentarz źródłowy](guake-contract.json) opisuje oryginał, nie zakres ukończonego portu. Pełna zgodność funkcjonalna i wizualna pozostaje do osiągnięcia.

## Co działa, a co jeszcze wymaga implementacji

| Obszar | Zaimplementowano | Pozostało |
| --- | --- | --- |
| Terminal | Osobny proces ConPTY dla każdej sesji; asynchroniczne I/O, zmiana rozmiaru, zamykanie procesów, katalog i środowisko | Dalsze testy długich sesji i programów pełnoekranowych |
| Emulator VT | Przyrostowe UTF-8/CSI/OSC, kolory ANSI/256/RGB, kursor, historia, alternatywny ekran, region przewijania, odpowiedzi urządzenia, bracketed paste, raportowanie myszy, reflow historii i klastry ICU | Pełne pokrycie sekwencji VTE/xterm, dalsze testy reflow i segmentacji grafemów |
| Powłoki | CMD, PowerShell, Bash i Zsh z Git SDK; cztery osobne skróty/menu; Zsh przez `git-zsh.exe --nomintty` | Weryfikacja szerszego zestawu konfiguracji użytkowników i instalacji SDK |
| Karty i podziały | Tworzenie, zamykanie, zmiana nazw, kolejność, wybór po identyfikatorze, podziały poziome/pionowe oraz fokus myszą i kierunkowo, przesuwanie granic podziałów | kolory indywidualnej karty i ich reset, zamknięcie przyciskiem na karcie, pełne oznaczanie aktywności |
| Widok terminala | Palety, font, kursor, obrazy PNG/JPEG/BMP/statyczny GIF, cztery układy tła, przewijanie, zaznaczenie przeciągnięciem, słowo po dwukliku, schowek i zapis tekstu | Pełna zgodność renderowania z VTE, animowany GIF; przezroczystość samego tła zamiast całego okna |
| Okno główne | Animacja wysuwania/chowania z regulacją czasu, geometria, monitor, zawsze na wierzchu, fullscreen, tray, płaski pasek kart u góry/dołu, osobne menu kart/terminala/powłok | Pełne zachowanie refocus/lazy hide, zestawy kart obszarów roboczych i zgodność wizualna ze wzorcem |
| Skróty | Globalne i lokalne, grave/tylda, konflikty, siedem zwijanych grup; akcje WWW/URL i kierunkowe podziały | Dalsza macierz pozostałych akcji i integracji |
| Preferencje | Dziewięć stron DFM, zapis od razu z walidacją i rollbackiem, zależności kontrolek, przewijanie myszą, edycja skrótów | Podłączenie efektów wszystkich przeniesionych ustawień; obecność pola i zapis INI nie oznaczają pełnej obsługi funkcji |
| Konfiguracja | Osobna klasa TMemIniFile, hierarchiczne rekordy, 130 kluczy Guake, cztery klucze powłok Windows i dwie opcje animacji, zachowanie nieznanych kluczy; tytuł projektu z `.guake.yml` i menu poleceń JSON | Pełny parser YAML poza obsługiwanymi skalarnymi tytułami i pozostałe efekty ustawień |
| Sesje | JSON v1: zapis i przywracanie kart, aktywnej karty/panelu, profili, katalogów i proporcji drzewa; menu ręczne, autosave i odtwarzanie po starcie; atomowy zapis i transakcyjne wczytanie | procesy i pamięć terminala nie są wznawiane |
| Wyszukiwanie | Tekst/regex, kierunek, wielkość liter, zawijanie; kodowane zapytania WWW i URL tekstowe/OSC 8 pod kursorem | Tekstowe URL zawinięte między wierszami |
| Integracje systemowe | Prywatne Named Pipes, ACL bieżącego użytkownika, blokada klientów zdalnych, pojedyncza instancja na sesję logowania, CLI, autostart HKCU, hooki start/show, powiadomienia i dzwonek | Pozostałe opcje CLI oryginału, zapytania o stan i długotrwałe testy integracji |
| Quick Open | Pola preferencji i układ menu | Rozpoznawanie plików/wierszy i wykonanie komendy edytora; pozycja menu pozostaje nieaktywna |
| Lokalizacja | Vendor i18n, 26 źródłowych PO, odtwarzalny import i uzupełnienia polskiego PO; aplikacja ładuje polski katalog | Wybór języka w aplikacji, przegląd wszystkich komunikatów i brakujących tłumaczeń innych języków |
| Diagnostyka | Vendor stacktrace, stack frames, szczegółowe MAP i osobne PDB; logger używa Exception.StackTrace i chroni pierwotny wyjątek | Pełne scentralizowanie obsługi wyjątków we wszystkich zdarzeniach i długotrwałe testy awarii |
| O programie i dialogi | Autorzy/GPL wysuwani od dołu, zmiana nazwy, potwierdzenie zamknięcia, zapis tekstu | Dalsze porównanie wizualne i zachowania dialogów z oryginałem |

## Bieżące poprawki

Aktualizacja scrollbara najpierw zeruje poprzedni PageSize, potem zmienia zakres i przywraca nowy rozmiar strony. Eliminuje to konkretny wyjątek VCL `SScrollBarRange` po zmniejszeniu terminala/fullscreen. Test wykonuje 15 cykli i sprawdza parametry przewijania. Zgłoszony późniejszy Runtime error 231 nie został niezależnie odtworzony; poprawka usuwa źródło powtarzających się wyjątków scrollbara.

Alfa okna jest stosowana jako wartość bezwzględna po zmianie ustawień i odtworzeniu HWND; rysowanie tła zaczyna od pełnego wypełnienia kolorem palety. Test sprawdza niezmienną alfę WinAPI po fullscreen i zmianie FormStyle. Nie zastępuje to obserwacji przezroczystości na pulpicie użytkownika. Obecna implementacja VCL obejmuje alfą całe okno, również tekst i pasek kart.

Pojedynczy klik tylko aktywuje terminal i usuwa stare zaznaczenie. Dopiero ruch przekraczający systemowy próg przeciągania rozpoczyna zaznaczenie; kopiowanie po zaznaczeniu nie kopiuje znaku po zwykłym kliknięciu. Dwuklik nadal zaznacza słowo.

Grupy skrótów odpowiadają HOTKEYS z `prefs.py`: Ogólne, Zarządzanie kartami, Zarządzanie podziałem, Nawigacja, Wygląd, Schowek i Dodatkowe funkcje. Klik nagłówka lub Enter/Spacja zwija/rozwija; strzałki lewo/prawo zamykają/otwierają grupę. Klik działania rozpoczyna przechwytywanie. Mapowanie wierszy zachowuje tożsamość ustawienia po zwinięciu innych kategorii.

## Wrapper Git Zsh

Projekt `Src/Launchers/git-zsh.dproj` buduje `bin/Win64/git-zsh.exe` i pasujące PDB. Bez parametrów uruchamia `usr/bin/mintty.exe` z `zsh --login -i`. `--nomintty` uruchamia Zsh w odziedziczonej konsoli/ConPTY i przekazuje kod zakończenia. Dalsze argumenty trafiają do Zsh z zachowaniem cytowania Windows.

Katalog SDK: `--git-sdk-root <katalog>`, następnie `GIT_SDK_ROOT`, katalog wrappera zawierający `usr/bin/zsh.exe`, a ostatecznie `C:/git-sdk-64`. Wrapper ustawia MSYSTEM=MINGW64, MSYS2_PATH_TYPE=inherit, CHERE_INVOKING=1, TERM=xterm-256color, COLORTERM=truecolor, PATH Git SDK oraz HOME, jeśli go brak. Nie zmienia katalogu roboczego. W Guake profil `zsh` używa wrappera obok EXE i katalogu `windows/git-sdk-root` z INI; preferencja powłoki logowania nadal działa. Wrapper i PDB są częścią pakietu.

## Mapa źródeł

| Źródło Guake | Port Delphi |
| --- | --- |
| org.guake.gschema.xml | Src/Settings/Guake.Settings.pas |
| prefs.glade, prefs.py | Src/Forms/frmPreferencesU.pas/.dfm |
| guake.glade, część guake_app.py | Src/Forms/frmMainU.pas/.dfm |
| terminal.py, boxes.py, notebook.py — część działania | Src/Terminal i Src/Frames |
| about.glade, about.py | Src/Forms/frmAboutU.pas/.dfm |
| search.glade | Src/Forms/frmSearchU.pas/.dfm |
| dialogs.py | Src/Forms/frmRenameU, frmConfirmU oraz Src/DataModules/dmDialogsU |
| palety i pixmapy | Src/Appearance, Src/Resources |

To mapa odpowiedzialności, nie deklaracja przeniesienia całych modułów Python. Dalsza kolejność: przezroczystość samego tła i animowany GIF, pozostałe sekwencje VT i macierz renderowania, Quick Open, brakujące akcje kart i efekty ustawień. Integracje wykonane w bieżącym etapie opisano poniżej.

## Budowanie i weryfikacja

Cztery projekty Win64: aplikacja, wrapper, DUnitX i podgląd formularzy. DPROJ mają Base jako wspólne opcje oraz Debug/Release. Standardowe PreBuildEvent/PostBuildEvent przygotowują niestandardowe RC, wrapper, PDB i lokalizacje zarówno dla IDE, jak i bezpośredniego MSBuild; brak BeforeTargets/AfterTargets i podwójnych importów CodeGear. Katalogi wyjściowe i DCU są osobne dla projektów oraz konfiguracji. VersionInfo i manifest generuje MSBuild; RES nie są śledzone. StackTrace jest pierwszy w DPR, PDB powstają bez modyfikowania EXE przez map2pdb. Check-Projects.py sprawdza konfiguracje, wspólne opcje, importy i zgodność DPR z DCCReference. Wszystkie projekty i grupa przechodzą starszy parser Microsoft.Build.BuildEngine. Bezpośredni build aplikacji do osobnego katalogu przygotował EXE, wrapper, PDB i lokalizacje bez Test.ps1. Kliknięcie Build i ponowny zapis w IDE pozostają niezweryfikowane: natywny pomocnik automatyzacji pulpitu jest niedostępny.

Wersjonowanie jest jawne: `Src/Tools/Update-Version.ps1 -Part Build` raz na przebieg prac, `-Part Release` przed commitem. Wszystkie cztery projekty mają tę samą wersję, major/minor pozostają 1.0, build nie jest resetowany. `Src/Tools/Test.ps1` i zwykły build nie zmieniają wersji.

Raport DUnitX: `bin/tests/test-results.xml`; podglądy: `bin/tests/preferences-preview/` i `bin/tests/terminal-preview.png`. Weryfikacja 1.0.10.45: 62/62 testy DUnitX, cztery projekty Win64 Debug, aplikacja i wrapper Win64 Release, osobne PDB oraz kontrola niezmienności DPROJ podczas budowania. Dodatkowa próba uruchomiła rzeczywiste mintty i potwierdziła środowisko MINGW64/xterm-256color. Sprawdzono podgląd strony skrótów. Pakiet: `bin/guake-1.0.10.45-Win64.zip`.

## Animacja, akcje i sesje — 1.0.11.46

`General.DropDownAnimation` i `General.DropDownAnimationDuration` mają kontrolki preferencji i zapis INI (`general/drop-down-animation`, `general/drop-down-animation-duration`). Domyślnie animacja trwa 180 ms; zakres 0–2000 ms, 0 wyłącza efekt. Timer przesuwa i przycina okno przy wybranej krawędzi bez zmiany rozmiaru ConPTY. Powtórny skrót odwraca ruch. Fullscreen korzysta z natychmiastowego pokazywania/chowania.

Kierunkowe przełączanie paneli wykorzystuje geometrię drzewa. Przesuwanie najbliższej granicy zmienia proporcję o 5 punktów w zakresie 10–90%. Ręczne przesunięcie splittera trafia do modelu i zapisu sesji. URL tekstowy i OSC 8 jest otwierany przez domyślną aplikację Windows; obsługiwane schematy to HTTP(S), FTP(S) i mailto. Wyszukiwanie zaznaczenia koduje zapytanie i korzysta z wybranego silnika lub adresu własnego.

Plik `.session.json` obok INI zawiera opis ponownego uruchomienia powłok, nie ich pamięć ani zadania. Odtwarzanie buduje osobne drzewo, więc błąd JSON lub startu procesu zachowuje dotychczasowe sesje. Limity: 2 MiB, 64 karty, 128 paneli, głębokość 64. Autosave porównuje stan co sekundę; błąd zatrzymuje ponawianie do ręcznego zapisu. Uszkodzony plik przy starcie nie jest automatycznie nadpisywany.

Weryfikacja etapu: 65 testów DUnitX, w tym animacja przy obu krawędziach, odwracanie ruchu, URL/OSC 8, kodowanie WWW, geometria nawigacji oraz zapis/odtworzenie mieszanego drzewa z aktywnymi panelami. Pozostałe pozycje tabeli nadal wymagają pracy.

## Reflow i grafemy — 1.0.12.46

Zawinięcia automatyczne są odróżniane od jawnych końców linii. Zmiana rozmiaru przebudowuje logiczne linie historii i ekranu głównego, zachowując atrybuty komórek, odnośniki, szerokie znaki i położenie kursora. Ekran alternatywny zachowuje charakter siatki. Kopiowanie łączy zawinięcia automatyczne i zachowuje jawne nowe linie; odstęp pozostawiony przed szerokim znakiem na granicy wiersza nie trafia do tekstu.

`Guake.Unicode` korzysta z silnika podziału znaków systemowego `icu.dll`, ładowanego wyłącznie z katalogu Windows. Wersja reguł Unicode jest wersją ICU dostarczoną z systemem. Starszy system bez tych eksportów zachowuje uproszczoną obsługę znaków łączących; nie zapewnia wtedy pełnej segmentacji UAX #29. Klaster ma limit ochronny 4096 jednostek UTF-16. Nie jest to jeszcze potwierdzenie pełnej zgodności renderowania z VTE.

Weryfikacja: 67/67 testów DUnitX, w tym grafemy podawane po pojedynczym bajcie UTF-8 (rodzina ZWJ, flagi, keycap, odcień skóry i znak łączący), wielokrotne zwężanie/poszerzanie historii, zachowanie SGR i kursora oraz powrót z ekranu alternatywnego. Pozostałe sekwencje VTE/xterm i integracje z listy pozostają w toku.

## Integracje systemowe i tray — 1.0.13.47

Potok `\\.\pipe\Guake.Windows.<SID>.<sesja>` i mutex `Local` identyfikują użytkownika oraz sesję logowania. DACL dopuszcza tylko bieżący SID, serwer używa PIPE_REJECT_REMOTE_CLIENTS, a klient sprawdza SID procesu serwera. Protokół przenosi UTF-8 z prefiksem długości, ograniczeniem 64 KiB i kolejką 64 poleceń. Potwierdzenie oznacza przyjęcie do kolejki UI; błędy wykonania trafiają do logu i powiadomienia. Zamykanie anuluje oczekujące operacje overlapped, również przy bezczynnym kliencie. Opcja `--instance` izoluje przestrzeń poleceń, m.in. w testach; domyślna instancja pozostaje pojedyncza.

CLI obejmuje pokazywanie/chowanie/przełączanie, karty i wybór powłoki, podziały, wykonanie tekstu w aktywnej powłoce, zmianę i wybór karty, zapis/odtworzenie sesji, fullscreen, preferencje, informacje i zakończenie. `--help` podaje obsługiwany zakres; nieobsługiwana opcja zwraca błąd. Cytowanie przechodzi przez CommandLineToArgvW. Ponowne uruchomienie bez poleceń przełącza widoczność, a `--hidden` pozostawia terminal schowany. Pozostałe opcje oryginalnego CLI i zapytania zwrotne nie są jeszcze przeniesione.

Autostart jest wartością Guake w HKCU Run, z cytowaną ścieżką EXE i `--hidden`. Hook startowy i hook show są uruchamiane asynchronicznie przez CMD bez dodatkowej konsoli. Przywracanie po starcie i menu zapisu/odtworzenia są teraz objęte testem całej ścieżki startowej okna, nie tylko samego kontrolera. Uszkodzony plik sesji pozostaje nienadpisany.

Powiadomienia obejmują start z nazwą głównego skrótu, ręczne przywrócenie kart, uszkodzony plik sesji, konflikt skrótu i błąd polecenia IPC. Są lokalizowane i kolejkowane; native Shell_NotifyIcon używa ikony Guake, a klik aktywuje terminal. Zestaw kontroluje opcja powiadomień, a komunikat o odtworzeniu także osobna opcja restore-tabs-notify. Focus Assist i ustawienia Windows mogą ograniczyć ich widoczność. Dzwonek BEL jest konsumowany raz przez sesję i podlega ustawieniu dźwięku.

Menu tray „Wyświetl” jest przełącznikiem widoczności, wspólnym z głównym skrótem. Terminal oraz pomocniczy HWND aplikacji VCL mają WS_EX_TOOLWINDOW i nie mają WS_EX_APPWINDOW, także po odtworzeniu uchwytu. Aplikacja ma pozostawać wyłącznie w trayu — nigdy na pasku zadań.

`.guake.yml` dostarcza znany z tej rewizji Guake klucz title: skalary zwykłe, cytowane, blokowe i obiekt JSON. Tagi, konstruktory i aliasy nie są wykonywane; pełny ogólny parser YAML nie jest deklarowany. Odczyt UTF-8 ma limit 64 KiB i odświeża się co sekundę. Plik poleceń zachowuje schemat customcommands.py: menu/description/items/cmd; podmenu są budowane z danych, a polecenie trafia do powłoki dopiero po kliknięciu. Limit pliku to 1 MiB, 1000 pozycji i głębokość 16.

Weryfikacja: 74/74 scenariusze DUnitX obejmujące także prywatny transport, odrzucenie klienta anonimowego, limit kolejki, przerwanie bezczynnego połączenia, osobny EXE CLI z polskimi znakami i cudzysłowami, izolowany klucz HKCU, hook, BEL, tytuł YAML i faktyczne wykonanie polecenia z menu. Testy natywnych uprawnień wymagają zwykłego tokenu użytkownika; ograniczony sandbox blokuje zapis testowego klucza rejestru.

## Projekty Delphi — 1.0.13.47

Przywrócono wspólne opcje Base, dziedziczenie Debug/Release dla Win64, pojedynczy import CodeGear oraz standardowe zdarzenia budowania. Grupa zachowuje identyfikator projektu i zależność aplikacji od wrappera. Bezpośredni Build aplikacji Debug i grupy Release przygotował EXE, PDB, wrapper i katalogi lokalizacji bez skryptu testowego. Test.ps1 nie kopiuje już brakujących zależności; uruchamia kontrolę projektu i 74 scenariusze DUnitX. Potwierdzono niezmienność DPROJ oraz wersji 1.0.13.47 podczas budowania. Osobny test chroni styl TOOLWINDOW przed zmianą przez VCL. Weryfikacja graficzna Build i ponownego zapisu projektu w IDE pozostaje do wykonania z powodu niedostępnego pomocnika pulpitu.
