# Stan portu Guake dla Windows

Stan kodu na 16 listopada 2026, wersja 1.0.25.58. Punkt odniesienia: lokalny `../guake`, rewizja `0911ddfe25a0c4019d2516b90982854d192e91cd`, oraz [zrzuty Manjaro](visual-reference.md). [Inwentarz źródłowy](guake-contract.json) opisuje oryginał, nie zakres ukończonego portu. Pełna zgodność funkcjonalna i wizualna pozostaje do osiągnięcia.

## Co działa, a co jeszcze wymaga implementacji

| Obszar | Zaimplementowano | Pozostało |
| --- | --- | --- |
| Terminal | Osobny proces ConPTY dla każdej sesji; asynchroniczne I/O, zmiana rozmiaru, zamykanie procesów, katalog i środowisko | Dalsze testy długich sesji i programów pełnoekranowych |
| Emulator VT | Przyrostowe UTF-8/CSI/OSC, kolory ANSI/256/RGB, kursor, historia, alternatywny ekran, region przewijania, odpowiedzi urządzenia, bracketed paste, raportowanie myszy, reflow historii, klastry ICU, programowalne tabulatory, raporty kursora względem regionu, DEC Special Graphics, zapis stanu kursora, C0 w sekwencjach, podparametry kolorów SGR, faint/conceal/strike/overline i pięć stylów podkreślenia z kolorem i miganie tekstu SGR 5/6/25 | Pełne pokrycie sekwencji VTE/xterm według [macierzy VT](vt-coverage.md), dalsze testy reflow i segmentacji grafemów |
| Powłoki | CMD, PowerShell, Bash i Zsh z Git SDK; cztery osobne skróty/menu; Zsh przez `git-zsh.exe --nomintty` | Weryfikacja szerszego zestawu konfiguracji użytkowników i instalacji SDK |
| Karty i podziały | Tworzenie, zamykanie, zmiana nazw, kolejność, wybór po identyfikatorze, podziały poziome/pionowe oraz fokus myszą i kierunkowo, przesuwanie granic podziałów, kolory paneli/kart i reset, przyciski zamykania, aktywność z okresami ignorowania | Dalsze testy potwierdzeń zamykania i rozpoznawania procesów potomnych |
| Widok terminala | Palety, font, kursor, obrazy PNG/JPEG/BMP/animowany GIF, przezroczystość samego tła, cztery układy tła, przewijanie, zaznaczenie przeciągnięciem, słowo po dwukliku zgodnie z word-chars, wklejanie zaznaczenia kółkiem, schowek i zapis tekstu | Pełna zgodność renderowania i układu grafemów z VTE oraz dalsze porównania wizualne |
| Okno główne | Refocus widocznego okna, lazy hide 300 ms z ochroną własnych dialogów, animacja wysuwania/chowania z regulacją czasu, geometria, monitor, zawsze na wierzchu, fullscreen, tray, płaski pasek kart u góry/dołu, osobne menu kart/terminala/powłok | Testy przejść fokusu z IME i zmianą pulpitu, zestawy kart obszarów roboczych i zgodność wizualna ze wzorcem |
| Skróty | Globalne i lokalne, grave/tylda, konflikty, siedem zwijanych grup; akcje WWW/URL i kierunkowe podziały | Dalsza macierz pozostałych akcji i integracji |
| Preferencje | Dziewięć stron DFM, zapis od razu z walidacją i rollbackiem, zależności kontrolek, przewijanie myszą, edycja skrótów | Podłączenie efektów wszystkich przeniesionych ustawień; obecność pola i zapis INI nie oznaczają pełnej obsługi funkcji |
| Konfiguracja | Osobna klasa TMemIniFile, hierarchiczne rekordy, 130 kluczy Guake, cztery klucze powłok Windows i dwie opcje animacji, zachowanie nieznanych kluczy; tytuł projektu z `.guake.yml` i menu poleceń JSON | Pełny parser YAML poza obsługiwanymi skalarnymi tytułami i pozostałe efekty ustawień |
| Sesje | JSON v1: zapis i przywracanie kart, aktywnej karty/panelu, profili, katalogów, kolorów i proporcji drzewa; menu ręczne, autosave i odtwarzanie po starcie; atomowy zapis i transakcyjne wczytanie | procesy i pamięć terminala nie są wznawiane |
| Wyszukiwanie | Tekst/regex, kierunek, wielkość liter, zawijanie; kodowane zapytania WWW i URL tekstowe/OSC 8 pod kursorem | Dalsze formaty odnośników i porównania z VTE |
| Integracje systemowe | Prywatne Named Pipes, ACL bieżącego użytkownika, blokada klientów zdalnych, pojedyncza instancja na sesję logowania, CLI, autostart HKCU, hooki start/show, powiadomienia i dzwonek | Pozostałe opcje CLI oryginału, zapytania o stan i długotrwałe testy integracji |
| Quick Open | Ctrl+klik i menu zaznaczenia, istniejące pliki, traceback/pytest/GCC/Delphi/MSVC, wiersz i kolumna, ścieżki Windows/Git SDK, edytor osobno lub w bieżącej powłoce | Dalsze formaty diagnostyki i testy integracji edytorów |
| Lokalizacja | Vendor i18n, 26 źródłowych PO, odtwarzalny import i uzupełnienia polskiego PO; aplikacja ładuje polski katalog | Wybór języka w aplikacji, przegląd wszystkich komunikatów i brakujących tłumaczeń innych języków |
| Diagnostyka | Vendor stacktrace, stack frames, szczegółowe MAP i osobne PDB; logger używa Exception.StackTrace i chroni pierwotny wyjątek | Pełne scentralizowanie obsługi wyjątków we wszystkich zdarzeniach i długotrwałe testy awarii |
| O programie i dialogi | Autorzy/GPL wysuwani od dołu, zmiana nazwy, potwierdzenie zamknięcia, zapis tekstu | Dalsze porównanie wizualne i zachowania dialogów z oryginałem |

## Bieżące poprawki

Aktualizacja scrollbara najpierw zeruje poprzedni PageSize, potem zmienia zakres i przywraca nowy rozmiar strony. Eliminuje to konkretny wyjątek VCL `SScrollBarRange` po zmniejszeniu terminala/fullscreen. Test wykonuje 15 cykli i sprawdza parametry przewijania. Zgłoszony późniejszy Runtime error 231 nie został niezależnie odtworzony; poprawka usuwa źródło powtarzających się wyjątków scrollbara.

UpdateLayeredWindow składa okno z alfą dla każdego piksela. Regulacja obejmuje wyłącznie domyślne tło terminala i obraz; tekst, zaznaczenie, jawne tła SGR oraz kontrolki pozostają nieprzezroczyste. Antyaliasing tekstu wykorzystuje maskę pokrycia i premultiplikowane ARGB, bez stałej alfy całego okna. Przy ustawieniu 0% nieprzezroczystości tło zachowuje alfę 1/255, aby Windows nadal kierował kliknięcia do terminala. Przy 100% używany jest zwykły widok VCL. Testy pikseli i cykli fullscreen nie zastępują obserwacji na pulpicie użytkownika.

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

To mapa odpowiedzialności, nie deklaracja przeniesienia całych modułów Python. Bieżąca kolejność: kolejne grupy z macierzy VT, renderowanie, zachowanie okna i pozostałe efekty ustawień. Integracje wykonane w bieżącym etapie opisano poniżej.

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

## Tło terminala — 1.0.14.48

Kompozycja ARGB obejmuje wszystkie widoczne panele i zachowuje nieprzezroczysty pasek kart oraz scrollbar. Bitmapa jest aktualizowana po zmianie danych, zaznaczenia, kursora, geometrii lub klatki GIF-a, a nie bezwarunkowo podczas bezczynności. GIF korzysta z istniejącego timera ramki, obsługuje czasy klatek z minimum 20 ms, częściowe klatki, disposal i skończone lub nieskończone powtórzenia. Brak rozszerzenia pętli oznacza pojedyncze odtworzenie. Ukrycie okna wstrzymuje animację; zmiana obrazu lub palety odtwarza cache. Dla ochrony UI pojedynczy krok wykonuje najwyżej 32 przejścia klatek. Semantyka powtórzeń Netscape uwzględnia pierwsze odtworzenie, zgodnie z [analizą implementacji WebKit](https://bugs.webkit.org/show_bug.cgi?id=39857).

Weryfikacja etapu: 78 scenariuszy DUnitX, w tym wartości premultiplikowanej alfy, krycie tekstu i jawnego tła SGR, rysowanie natywnych zakładek, zmiana 0/40/100%, fullscreen oraz opóźnienia, disposal, przesunięcia klatek i skończone powtórzenia GIF-a. Zapisany podgląd `bin/tests/terminal-alpha-preview.png` służy do kontroli zawartości kompozycji; sama przezroczystość jest sprawdzana w bitmapie ARGB, ponieważ ten podgląd PNG zapisuje RGB. Nie deklarujemy jeszcze pełnej zgodności renderowania z VTE ani weryfikacji na pulpicie użytkownika.

## Quick Open — 1.0.15.48

Ctrl+klik rozpoznaje plik przed przekazaniem zdarzenia do programu w terminalu; obsłużony klik nie wysyła dodatkowego raportu myszy. Menu terminala korzysta z zaznaczenia lub zapamiętanego celu pod kursorem. Plik musi istnieć; względne ścieżki są rozwiązywane względem znanego katalogu sesji. Obsługiwane są cytowane ścieżki, file:line[:column], traceback Pythona, funkcje pytest oraz format path(line,column) z Delphi/MSVC. Ścieżki /c/... są mapowane na dysk Windows, a /usr/... na Git SDK.

Polecenie edytora zastępuje %(file_path)s i %(line_number)s; port dodaje %(column_number)s. Ścieżki są cytowane dla CMD, PowerShell albo Bash/Zsh i uwzględniają istniejące cudzysłowy w szablonie. Uruchomienie osobno korzysta z CMD bez dodatkowego okna konsoli; tryb bieżącego terminala wysyła polecenie do aktywnej powłoki. Należy skonfigurować edytor dostępny w Windows, np. notepad.exe %(file_path)s lub code -g %(file_path)s:%(line_number)s. Domyślna wartość gedit ze źródłowego schematu pozostaje zachowana, podobnie jak domyślne wyłączenie funkcji.

Parser ogranicza tekst do 8192 jednostek UTF-16, a odczyt źródła przy wyszukiwaniu funkcji pytest do 8 MiB. Nie otwiera nieistniejących plików i nie wznawia pracy procesów. Od wersji 1.0.24.57 rozpoznawanie pod kursorem łączy automatycznie zawinięte wiersze; jawne końce linii pozostają granicą. Wiarygodność ścieżek względnych zależy od aktualizacji katalogu sesji przez powłokę/OSC 7. Dodano polski komunikat błędu otwierania pliku.

Weryfikacja Quick Open: 80/80 testów DUnitX, cztery projekty Debug i grupa Release. Scenariusze sprawdzają numery wierszy i kolumn, pytest, ścieżki ze spacjami i polskimi znakami, mapowanie Git SDK, cytowanie dla czterech powłok, kliknięcie i menu zaznaczenia oraz rzeczywiste wykonanie polecenia w bieżącej powłoce i osobnym procesie. Poprawiono też granice rozpoznawania URL: indeks TMatch w Delphi 10.2 jest liczony od 1, a indeks komórki od 0. Build nie zmienił wersji 1.0.15.48.

## Reakcja terminala i karty — 1.0.16.49

Usunięto regresję kompozycji: poprzednia ścieżka rasteryzowała terminal trzykrotnie, wykonywała dzielenia dla kanałów każdego piksela i przeliczała format alfy gotowego obrazu przed jego nadpisaniem. Obecnie pobiera wskaźniki DIB raz, korzysta z tablic współczynników, pomija puste komórki, grupuje sąsiednie ASCII o tych samych atrybutach i buforuje wynik każdego panelu i odtwarza tylko zmienione wiersze. Przycinanie partii ASCII zachowuje granice komórek, a porównanie pikseli sprawdza zgodność z rysowaniem pojedynczych znaków. Niezmieniony panel nie jest ponownie rasteryzowany. Zmiana wyjścia powłoki aktualizuje widok w tym samym cyklu odczytu, zamiast czekać na dodatkowy timer 100 ms; nie odświeża też niezmienionych tytułów kart. Gorąca pętla pikseli jest optymalizowana również w Debug, ze stack frames i symbolami.

Osobny pomiar Debug, Consolas, 1920×1080: przed poprawką 492,132 ms dla krótkiego wiersza i 500,484 ms dla pełnego ekranu ASCII; po końcowej poprawce 14,701 ms i 15,356 ms. To koszt kompozycji bitmapy, nie pomiar całego czasu od klawisza do echa ConPTY. Wynik zależy od sprzętu, fontu i zawartości; pełne pokrycie renderowania Unicode i VTE nadal wymaga pracy. Raport pomiaru: bin/tests/composition-latency.txt.

Przyciski zamykania zależą od tab-close-buttons i respektują potwierdzenie zamknięcia. Obsługa odracza zmianę drzewa do zakończenia natywnego zdarzenia myszy i identyfikuje kartę po UUID. Pasek używa natywnego motywu płaskich przycisków; aktywność pogrubia tytuł. Kontroler ignoruje wyjście podczas okresu po utworzeniu karty i po utracie fokusu, czyści oznaczenie po wyborze karty i po wyłączeniu funkcji.

CLI obsługuje --bgcolor, --fgcolor, --bgcolor-current, --fgcolor-current, --reset-colors i --reset-colors-current. Kolory RGB mają 3, 6, 9 lub 12 cyfr szesnastkowych, z opcjonalnym #. Ustawienie bez -current obejmuje panele bieżącej karty; reset bez -current obejmuje wszystkie sesje, zgodnie z oryginałem. Menu karty resetuje tylko jej panele. Opcjonalne pola custom-foreground/custom-background w zapisie sesji v1 zachowują zgodność ze starszymi plikami bez tych pól; wadliwe wartości nie zastępują działających sesji.

Weryfikacja etapu obejmuje 86 scenariuszy DUnitX: zgodność pikseli ASCII, wymazanie jednego wiersza bez zmiany sąsiednich, odtwarzanie tylko zmienionego wiersza i ponowne użycie drugiego panelu, alfa i GIF, zachowanie zamykania kart, kolory i ich trwałość, okresy ignorowania aktywności oraz dotychczasowe integracje. Natywne elementy kart są jawnie uwzględniane w kompozycji WM_PRINTCLIENT; test sprawdza obecność krzyżyka w bitmapie. Osobne pakiety nadal zawierają pasujące EXE/PDB.

Końcowa weryfikacja 1.0.16.49: 86/86 testów DUnitX, projekty Win64 Debug i grupa Release, niezmienność DPROJ podczas budowania oraz kontrola zgodności DPR/DCCReference. Dodatkowe asercje obejmują ekran alternatywny po utworzeniu historii oraz widoczność napisów i krzyżyków kart w kompozycji. Sprawdzono podgląd paska kart. Pakiet: bin/guake-1.0.16.49-Win64.zip. Przed uruchomieniem nowego pakietu należy zakończyć poprzednią instancję z trayu; ponowne uruchomienie przy działającej instancji jedynie przekazuje jej polecenie przez Named Pipes.

## Tabulatory i rozróżnianie CSI — 1.0.17.50

Tabulatory mają własny stan: HT przechodzi do następnego przystanku, ESC H ustawia przystanek w bieżącej kolumnie, CSI g usuwa bieżący, CSI 3 g usuwa wszystkie, CSI I / CSI Z przesuwa w przód / wstecz o zadaną liczbę przystanków. CSI ? 5 W i reset terminala przywracają przystanki co osiem kolumn, począwszy od dziewiątej. Zwężenie nie usuwa zapamiętanych przystanków; nowe kolumny poza dotychczasowym zakresem otrzymują domyślne. Ruch zatrzymuje się na krawędzi i nie dopisuje spacji do bufora.

Parser nie utożsamia już nieobsługiwanych prefiksów i bajtów pośrednich CSI ze zwykłym ruchem lub kasowaniem. Przykładowo CSI SP A nie wykonuje CUU, a CSI ? 2 J nie kasuje całego ekranu jak zwykłe ED. Nie oznacza to implementacji selective erase ani przesuwania kolumn. CPR oraz DECXCPR zachowują różne prefiksy odpowiedzi i pozycję wiersza względem regionu w trybie origin.

[Macierz VT](vt-coverage.md) opisuje faktyczny zakres parsera i następne grupy do przeniesienia. Pozostałe obszary z tabeli nadal wymagają implementacji; przywracanie sesji pozostaje ponownym uruchomieniem powłok, bez wznowienia pamięci procesów.

Weryfikacja 1.0.17.50: formatter bez błędów, 90/90 scenariuszy DUnitX z raportem XML, cztery projekty Win64 Debug i aplikacja z wrapperem Release, zgodność DPR/DCCReference oraz niezmienność DPROJ podczas Test.ps1. Cztery nowe scenariusze obejmują tabulatory, resize/reset, odrzucanie nieobsługiwanych wariantów CSI i raporty kursora w regionie. Test autostartu używa izolowanego HKCU i wymaga uruchomienia poza ograniczonym sandboxem. Pakiet: bin/guake-1.0.17.50-Win64.zip.

## Zestawy znaków i stan kursora — 1.0.18.51

Emulator obsługuje DEC Special Graphics, ASCII i brytyjski zestaw znaków w G0–G3, wybór GL przez SI/SO i LS2/LS3 oraz pojedyncze przełączenie SS2/SS3. Ramki są przechowywane jako Unicode; mapowanie nie zmienia polskich znaków ani emoji. Sekwencje wyboru zestawu zachowują stan pomiędzy odczytami. CAN/SUB anuluje niekompletną sekwencję.

ESC 7/8, CSI s/u i 1048 współdzielą zapis i odtwarzają pozycję, przeniesione atrybuty SGR, wybór zestawów, origin, autowrap, oczekujące zawinięcie i jednorazowe przełączenie zestawu. Zapisy ekranu głównego i alternatywnego są oddzielne. 1049 wykorzystuje ten zapis przy powrocie do głównego ekranu. Przywrócenie po zmianie rozmiaru ogranicza pozycję do dostępnej geometrii. Szczegóły i pozostałe różnice opisuje [macierz VT](vt-coverage.md).

Weryfikacja 1.0.18.51: obowiązkowy formatter bez błędów, 97/97 scenariuszy DUnitX (siedem nowych), cztery projekty Win64 Debug oraz aplikacja z wrapperem Release. Test.ps1 sprawdził zgodność projektów i niezmienność DPROJ podczas budowania. Pakiet bin/guake-1.0.18.51-Win64.zip zawiera EXE/PDB, wrapper, tłumaczenia i licencje. Porównanie z VTE było źródłowe; zgodność graficzna wszystkich fontów i pełny zestaw wariantów ekranów nadal wymagają testów.

## Odzyskiwanie parsera i kolory SGR — 1.0.19.52

Kontrolki C0 wewnątrz ESC/CSI/wyboru zestawu wykonują funkcję bez utraty rozpoznawanej sekwencji. DEL i NUL nie drukują znaków, CAN/SUB anuluje, a nowy ESC umożliwia rozpoczęcie następnego polecenia również po przerwanym ciągu OSC/DCS/APC/PM/SOS. Nieobsługiwane ESC z bajtami pośrednimi nie pozostawiają końcowych znaków na ekranie.

Przekroczenie limitu CSI/OSC odrzuca całe polecenie zamiast wykonania jego obciętej treści. Przepełnione liczby CSI nie zerują pozycji kursora. SGR nie spłaszcza dwukropków: rozpoznaje paletę i RGB zapisane średnikami lub podparametrami, w tym pustą przestrzeń kolorów w 38:2::r:g:b. Wadliwe składowe nie resetują atrybutów ani nie włączają przypadkiem bold. Pozostałe atrybuty i style podkreślenia nadal czekają na implementację renderowania; szczegóły opisuje macierz VT.

Weryfikacja 1.0.19.52: formatter bez błędów, 104/104 scenariusze DUnitX z raportem XML (siedem nowych), cztery projekty Win64 Debug oraz aplikacja i wrapper Release. Test.ps1 potwierdził zgodność projektów i niezmienność DPROJ podczas budowania. Nowe testy obejmują kontrolki C0, przepełnienie CSI/OSC i liczb, przerwanie sekwencji, warianty kolorów SGR oraz każde miejsce podziału przykładowego strumienia. Pakiet: bin/guake-1.0.19.52-Win64.zip, z pasującymi EXE/PDB. Pełne renderowanie pozostałych atrybutów i dalsze różnice z VTE pozostają do wykonania.

## Renderowanie atrybutów SGR — 1.0.20.53

Działają przygaszenie, ukrywanie glifów/dekoracji, przekreślenie, linia nad tekstem i pięć stylów podkreślenia. Kolor podkreślenia 58/59 jest podłączony do renderera, nie tylko konsumowany przez parser. Reset, zapis kursora, historia i reflow zachowują nowe pola. Ukryty tekst pozostaje w modelu i może być skopiowany; conceal nie jest usuwaniem danych.

Kompozycja alfa obejmuje dekoracje jako treść pierwszoplanową, a conceal zachowuje jawne tło komórki. Faint zmienia kolor, nie alfę tekstu. Grupy ASCII nie łączą komórek o różnych nowych atrybutach; cache wykrywa zmianę samych atrybutów i odtwarza właściwy wiersz. Pozostałe różnice obejmują m.in. miganie tekstu, pełny shaping i porównanie dokładnej geometrii z VTE.

Weryfikacja 1.0.20.53: formatter bez błędów, 107/107 scenariuszy DUnitX (trzy nowe), cztery projekty Win64 Debug oraz aplikacja i wrapper Release. Test.ps1 sprawdził zgodność projektów i niezmienność DPROJ podczas budowania. Sprawdzono zapisany podgląd bin/tests/sgr-preview.png. Testy pikseli potwierdzają krycie dekoracji, ukrywanie tekstu przy tle domyślnym i jawnym, przygaszenie i odświeżenie jednego wiersza; nie zastępują porównania wszystkich fontów i DPI z VTE. Pakiet: bin/guake-1.0.20.53-Win64.zip z pasującymi EXE/PDB.

## Miganie tekstu i cache wierszy — 1.0.21.54

SGR 5/6 włącza miganie glifów i dekoracji, 25 je wyłącza; zapis kursora, historia, reflow i reset zachowują właściwy atrybut. Faza widoku zmienia się co 500 ms i jest wstrzymana przy ukrytym oknie/panelu. Tło i tekst w modelu nie znikają, a miganie kursora pozostaje niezależne.

Metadane widocznych wierszy pozwalają pominąć panel bez migającej treści i odtwarzać tylko potrzebne wiersze przy zmianie fazy. Historia poza widokiem, conceal i niedekorowane spacje nie powodują dodatkowej rasteryzacji. Końcowa kompozycja i prezentacja nadal używają bitmapy ARGB całego panelu/okna; nie jest to deklaracja częściowej prezentacji przez UpdateLayeredWindow. Systemowe preferencje migania/dostępności oraz pełna macierz polityk VTE pozostają do integracji.

Weryfikacja 1.0.21.54: formatter bez błędów, 110/110 scenariuszy DUnitX (trzy nowe), cztery projekty Win64 Debug oraz aplikacja i wrapper Release. Test.ps1 potwierdził zgodność projektów i niezmienność DPROJ podczas budowania. Nowe testy używają kontrolowanego upływu czasu, potwierdzają granice faz, krycie i tło, rasteryzację jednego wiersza oraz zachowanie cache przy conceal, spacjach, przewijaniu i ekranie alternatywnym. Pakiet: bin/guake-1.0.21.54-Win64.zip z pasującymi EXE/PDB.

## Raporty urządzenia i tryby wejścia — 1.0.22.55

Emulator odpowiada na DA2, DECRQM dla obsługiwanych trybów i CSI 18 t z bieżącym rozmiarem w znakach. Nie odpowiada ponownie na odebrane odpowiedzi DA i nie kasuje oczekującego zawinięcia przy zapytaniu. Nieznane tryby raportuje jako nieznane, bez deklarowania ich obsługi.

Tryb 1004 przekazuje zdarzenia fokusu ramki do aktywnego procesu jako CSI I/O. Tryb 20 działa dla wyjściowego LF i klawisza Enter (CR LF po włączeniu, CR po wyłączeniu). Reset wyłącza oba tryby. Pełny zakres odpowiedzi, ograniczenia identyfikacji i pozostałe tryby opisuje macierz VT; klawiaturę aplikacyjną i część DECRQSS opisuje etap 1.0.23.56.

Weryfikacja 1.0.22.55: formatter bez błędów, 114/114 scenariuszy DUnitX (cztery nowe), cztery projekty Win64 Debug oraz aplikacja i wrapper Release. Test.ps1 potwierdził zgodność projektów i niezmienność DPROJ podczas budowania. Proces testowy sam włącza fokus 1004, co dociera do modelu; jego wejście VT odbiera oczekiwane znaki odpowiedzi urządzenia, raportów fokusu i Enter. ConPTY filtruje raporty fokusu, jeżeli proces nie zażądał ich po swojej stronie; scenariusz uwzględnia ten warunek. Pakiet: bin/guake-1.0.22.55-Win64.zip z pasującymi EXE/PDB. Test zdarzeń ramki nie zastępuje dalszych prób przełączania aplikacji na pulpicie.

## Pełne zamknięcie, ikona wrappera i dalsze VT — 1.0.23.56

Parametr --exit przekazuje osobne polecenie IPC kończące proces Guake bez dialogu potwierdzenia. Korzysta ze StopTerminal, więc zapisuje aktualny układ przed zatrzymaniem procesów, gdy SaveTabsWhenChanged jest włączone i zapis nie jest zablokowany po błędzie odtwarzania. Przy wyłączonym zapisie zachowuje poprzedni plik. Gdy instancja nie działa, --exit kończy się bez tworzenia okna, startowania powłoki i zmiany pliku sesji. Nie można go łączyć z innymi poleceniami terminala; --instance może wskazać izolowaną instancję. Dotychczasowe --quit zachowuje potwierdzenie według ustawień.

Ikona git-zsh.exe pochodzi z C:/git-sdk-64/usr/bin/zsh.exe. Źródłowy ICO i metadane sum kontrolnych są w Src/Resources, a odtwarzalny importer w Src/Tools/Import-ZshIcon.py. Icon_MainIcon w DPROJ pozwala wygenerować zasób MSBuild zarówno w IDE, jak i skryptem; repo nie śledzi RES. Zwykłe budowanie nie wymaga ponownego wydobywania ikony ani obecności źródłowego EXE.

DECRQSS zwraca obsługiwane SGR i marginesy; klawiatura numeryczna aplikacyjna obsługuje cyfry, operatory, separator i osobny Enter. Odczyt zapytań DCS jest przyrostowy i ograniczony rozmiarem. Szczegóły i nadal brakujące warianty opisuje macierz VT.

Weryfikacja 1.0.23.56: formatter bez błędów, 117/117 scenariuszy DUnitX (trzy nowe i rozszerzony test wejścia), cztery projekty Win64 Debug oraz aplikacja i wrapper Release. Test --exit uruchamia osobne instancje z izolowanym APPDATA i drugi proces CLI, sprawdza zamknięcie przy włączonych potwierdzeniach, zapis dwóch kart, zachowanie pliku przy wyłączonym zapisie oraz brak startu powłoki bez działającej instancji. Natywny odbiorca ConPTY potwierdza odpowiedź DCS i sekwencje klawiatury numerycznej. Importer porównał ikony źródłowego zsh.exe, ICO oraz wrapperów Debug/Release. Test.ps1 potwierdził niezmienność DPROJ podczas budowania. Pakiet: bin/guake-1.0.23.56-Win64.zip z pasującymi EXE/PDB.

## Zaznaczanie, wklejanie i zawinięte odnośniki — 1.0.24.57

Dwuklik zaznacza słowo z uwzględnieniem ustawienia word-chars (także zakresów znaków), całych komórek grafemów i miękkich zawinięć. Drugi MouseDown VCL nie kasuje zaznaczenia. Pojedynczy klik nadal tylko ustawia fokus; zaznaczanie myszą wymaga przeciągnięcia.

Środkowy przycisk wkleja ostatnie niepuste zaznaczenie terminala do bieżącego wejścia powłoki, bez dopisywania Enter. Zaznaczenie jest wspólne dla paneli aplikacji i niezależne od schowka Windows. Copy-on-select nadal steruje kopiowaniem do schowka. Wklejanie respektuje bracketed paste. Przy aktywnym raportowaniu myszy program otrzymuje klik; Shift pozwala wkleić zaznaczenie. Poprawiono także kody przycisków środkowego i prawego w protokole VT.

Tekstowy URL i niezaznaczona ścieżka Quick Open są rozpoznawane w logicznej linii obejmującej miękkie zawinięcia. Odczyt pomija kontynuacje szerokich znaków i techniczne wypełnienie końca wiersza, mapuje pozycję kliknięcia na indeks UTF-16 i ogranicza pracę do 65536 jednostek. Parser Quick Open zachowuje własny limit 8192. To nie oznacza pełnej zgodności VTE; dalsze braki pozostają w tabeli i macierzy VT.

Weryfikacja 1.0.24.57: formatter bez błędów, 118/118 scenariuszy DUnitX bez błędów i wycieków, cztery projekty Win64 Debug oraz aplikacja i wrapper Release. Natywny odbiorca ConPTY potwierdził tekst i ramki bracketed paste, także z zaznaczenia innego panelu. Testy obejmują kolejność zdarzeń VCL, word-chars, zawinięty URL, twarde końce linii i mapowanie szerokiego znaku. Test.ps1 potwierdził niezmienność DPROJ podczas budowania. Raport: bin/tests/test-results.xml. Pakiet: bin/guake-1.0.24.57-Win64.zip z pasującymi EXE/PDB.

## Refocus i opóźnione chowanie — 1.0.25.58

`window-refocus` działa dla głównego skrótu, menu tray i polecenia toggle: jeżeli terminal jest widoczny, ale fokus należy do innej aplikacji, akcja przywraca fokus aktywnemu panelowi zamiast chować okno. Gdy terminal ma fokus, ta sama akcja chowa okno. Wyłączony refocus zachowuje zwykłe przełączanie widoczności. Jawne polecenie CLI hide nadal chowa okno. Ponowne show już widocznego terminala przywraca fokus bez ponownego uruchamiania hooka show.

`window-losefocus` sprawdza rzeczywiste okno pierwszoplanowe po zakończeniu przejścia aktywacji Windows. Przy `lazy-losefocus` czeka 300 ms, zgodnie z oryginałem. Powrót fokusu lub jawne show anuluje oczekiwanie; wyłączenie chowania przed wykonaniem callbacku zapobiega ukryciu. Własne dialogi i menu nie powodują chowania. Główny skrót nie chowa terminala za aktywnym własnym dialogiem; otwarty dialog modalny chroni okno również po przejściu do innej aplikacji. Timer jest komponentem DFM i jest zatrzymywany przy zamknięciu kontrolera; nie powstaje wątek usypiający UI.

Pozostają testy rzeczywistych przejść IME, zmiany pulpitu i długotrwałej pracy z innymi aplikacjami. Implementacja używa aktywacji i okna pierwszoplanowego WinAPI, bez przenoszenia znaczników czasu X11 oraz jego filtrów zdarzeń do Windows. Zestawy kart obszarów roboczych nadal czekają na port.

Weryfikacja 1.0.25.58: formatter bez błędów, 119/119 scenariuszy DUnitX bez błędów i wycieków, cztery projekty Win64 Debug oraz aplikacja i wrapper Win64 Release. Test osobnego procesu przejmuje rzeczywisty fokus, udziela prawa do aktywacji przez AllowSetForegroundWindow i sprawdza refocus, zwykły toggle, opóźnienie 300 ms, anulowanie po powrocie, ochronę własnego dialogu, wyłączenie opcji w trakcie oczekiwania oraz zatrzymanie oczekującego timera przy StopTerminal. Test.ps1 potwierdził niezmienność DPROJ podczas budowania. Raport: bin/tests/test-results.xml. Pakiet: bin/guake-1.0.25.58-Win64.zip z pasującymi EXE/PDB.
