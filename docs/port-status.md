# Stan portu Guake dla Windows

Stan kodu na 15 listopada 2026, wersja 1.0.12.46. Punkt odniesienia: lokalny `../guake`, rewizja `0911ddfe25a0c4019d2516b90982854d192e91cd`, oraz [zrzuty Manjaro](visual-reference.md). [Inwentarz źródłowy](guake-contract.json) opisuje oryginał, nie zakres ukończonego portu. Pełna zgodność funkcjonalna i wizualna pozostaje do osiągnięcia.

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
| Konfiguracja | Osobna klasa TMemIniFile, hierarchiczne rekordy, 130 kluczy Guake i cztery klucze powłok Windows, zachowanie nieznanych kluczy | Odczyt `.guake.yml`, plik poleceń i brakujące integracje ustawień |
| Sesje | JSON v1: zapis i przywracanie kart, aktywnej karty/panelu, profili, katalogów i proporcji drzewa; menu ręczne, autosave i odtwarzanie po starcie; atomowy zapis i transakcyjne wczytanie | Powiadomienie po odtworzeniu; procesy i pamięć terminala nie są wznawiane |
| Wyszukiwanie | Tekst/regex, kierunek, wielkość liter, zawijanie; kodowane zapytania WWW i URL tekstowe/OSC 8 pod kursorem | Tekstowe URL zawinięte między wierszami |
| Integracje systemowe | Tray i natywne skróty globalne | Named Pipes z ACL bieżącego użytkownika i odrzucaniem klientów zdalnych, pojedyncza instancja, CLI sterujące, autostart, hooki start/show, powiadomienia i dzwonek |
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

To mapa odpowiedzialności, nie deklaracja przeniesienia całych modułów Python. Dalsza kolejność: integracja pojedynczej instancji/CLI przez Named Pipes, trwałość sesji, brakujące akcje podziałów i kart, Quick Open/URL/WWW, hooki i pozostałe efekty ustawień, następnie pełna macierz zgodności VT i wizualnej.

## Budowanie i weryfikacja

Cztery projekty Win64: aplikacja, wrapper, DUnitX i podgląd formularzy. DPROJ mają Base jako wspólne opcje oraz Debug/Release. Niestandardowe RC są kompilowane przez ResourceBuildDependsOn, bez BeforeTargets/AfterTargets. VersionInfo i manifest generuje MSBuild; RES nie są śledzone. StackTrace jest pierwszy w DPR, PDB powstają bez modyfikowania EXE przez map2pdb. Zapis projektu przez IDE nadal wymaga osobnego sprawdzenia.

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
