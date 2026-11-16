# Guake dla Windows

Port Guake na Windows 64-bit w Delphi/VCL z natywnym WinAPI. Celem jest zgodność funkcji i wyglądu z Guake. Dostępne są ustawienia, formularze, backend ConPTY, podstawowy emulator VT oraz kontroler kart i podziałów. Działają też pojedyncza instancja i CLI przez prywatne Named Pipes; pozostałe różnice opisuje stan portu.

Główny projekt: [Src/guake.dpr](Src/guake.dpr), [Src/guake.dproj](Src/guake.dproj). Cały kod, projekty, narzędzia i dane lokalizacji znajdują się pod `Src/`. Wyniki budowania trafiają do ignorowanego `bin/`, pliki pośrednie do `.build/`.

- [Ustawienia](Src/Settings/Guake.Settings.pas): 130 kluczy z oryginalnego schematu, cztery skróty powłok dla Windows i dwie opcje animacji, hierarchiczne rekordy i osobna klasa z `TMemIniFile`.
- [Preferencje](Src/Forms/frmPreferencesU.pas): dziewięć kategorii z lewym paskiem nawigacji według `prefs.glade`, zapis zmian, zależności kontrolek, skróty, 169 palet i dialogi plikowe.
- [Formularze](Src/Forms): okno główne, preferencje, informacje o programie, wyszukiwanie, zmiana nazwy i potwierdzenia. [Moduły danych](Src/DataModules) zawierają komponenty dialogów plikowych.
- [Lokalizacja](Src/Localization/README.md): 26 oryginalnych PO Guake i osobne uzupełnienia portu Windows, import przez GNU msgfmt, biblioteka `Src/Vendor/i18n`.
- [Diagnostyka](Src/Diagnostics/Guake.Logging.pas): logowanie `Exception.StackTrace`, biblioteka `Src/Vendor/stacktrace`, MAP i PDB dla każdego EXE.
- [Common](Src/Common/README.md): submoduł z odczytem wersji EXE przez `VersionU.pas`.

Budowanie i testy dla Delphi 10.2 (z katalogu repozytorium):

```powershell
git submodule update --init --recursive
powershell -NoProfile -ExecutionPolicy Bypass -File Src/Tools/Test.ps1
```

Wymagane: Delphi Win64, Python 3 i `map2pdb.exe` w PATH. Budowanie nie zmienia wersji. Na początku kolejnego przebiegu prac zwiększ build jawnie przez `Src/Tools/Update-Version.ps1 -Part Build`; przed commitem zwiększ release przez `-Part Release`. Skrypt buduje projekt główny, wrapper Git Zsh, DUnitX oraz podgląd formularzy; generuje osobne PDB, zachowując niezmienione EXE. Raport: `bin/tests/test-results.xml`. Podglądy zakładek: `bin/tests/preferences-preview/`. Testy używają własnego katalogu tymczasowego pod `.build/`.

Główny EXE: `bin/Win64/guake.exe`. Samodzielny edytor preferencji do sprawdzenia formularza: `bin/forms/GuakeFormsPreview.exe`. Edytor zapisuje ustawienia do `%APPDATA%/Guake/guake.ini`. Zbudowaną aplikację z PDB i lokalizacją można spakować przez `Src/Tools/Package.ps1`.

[Stan portu i mapa formularzy](docs/port-status.md) opisują zakres działającego kodu i braki. [Inwentarz źródłowego Guake](docs/guake-contract.json) nie oznacza implementacji wszystkich wymienionych funkcji. [AGENTS.md](AGENTS.md) określa formatowanie, zasoby i wersjonowanie.

Jeżeli uruchomiona aplikacja blokuje docelowy EXE, można zweryfikować kompilację przez `Src/Tools/Test.ps1 -MainOutput .build/verified-main`. Ten parametr zmienia katalog wyjściowy EXE i PDB aplikacji oraz wrappera, a także lokalizacji aplikacji. Paczkę z takiego katalogu tworzy `Src/Tools/Package.ps1 -OutputDirectory .build/verified-main`. `Base` w IDE przechowuje wspólne opcje; do budowania wybierz `Debug` albo `Release`.

Konflikt skrótu globalnego nie blokuje uruchomienia terminala. Szczegóły są widoczne w podpowiedzi ikony tray; zajętą kombinację można zmienić w preferencjach. Projekty używają standardowych `PreBuildEvent`/`PostBuildEvent`, tak samo przy budowaniu z IDE i MSBuild: przygotowują niestandardowe zasoby, wrapper, PDB i tłumaczenia. Otwórz `Src/Guake-Windows.groupproj` albo bezpośrednio `Src/guake.dproj`. Wymagane są Windows SDK (rc.exe), Python i map2pdb dostępne dla procesu IDE.

Skróty z klawiszem grave (U+0060) i tyldą (~) można przechwytywać w preferencjach; rozpoznawane są również te znaki zapisane bezpośrednio w INI. Sesje Bash/Zsh mają jawnie ustawiony typ terminala `xterm-256color`.

[Wzorzec interfejsu na Manjaro](docs/visual-reference.md) opisuje układ ze zrzutów oryginalnego Guake, mapowanie na formularze DFM i pozostałe różnice.

Obraz tła terminala obsługuje PNG, JPEG, BMP i animowany GIF: skalowanie z zachowaniem proporcji i kadrowaniem, kafelkowanie, wyśrodkowanie i rozciąganie. Przezroczystość dotyczy domyślnego tła i obrazu, a tekst, pasek kart, scrollbar, jawne kolory tła aplikacji terminalowych i zaznaczenie pozostają nieprzezroczyste. GIF zachowuje czasy klatek, usuwanie klatek i liczbę powtórzeń; animacja jest wstrzymywana, gdy terminal jest ukryty.

Menu karty zawiera wybór Zsh, Bash, CMD i PowerShell. Każda powłoka ma własne działanie w preferencjach skrótów; domyślnie skróty są wyłączone. Są to skróty lokalne działające w terminalu Guake. Etykiety i podpowiedzi uzupełnia polski katalog portu Windows.

Pasek kart używa płaskich przycisków (`TTabControl.Style = tsFlatButtons`). Menu karty jest dostępne również na pustej części paska. Lewy klik ikony nowej karty otwiera domyślną powłokę z preferencji; prawy pokazuje bezpośredni wybór Zsh/Bash/CMD/PowerShell. Jednorazowy wybór nie zmienia ustawienia powłoki domyślnej.

Wrapper `bin/Win64/git-zsh.exe` bez parametrów otwiera Zsh w mintty. Z `--nomintty` korzysta z bieżącej konsoli; ten wariant jest podłączony pod profil `zsh` w Guake. Katalog Git SDK można przekazać przez `--git-sdk-root`, `GIT_SDK_ROOT`, a w Guake przez `windows/git-sdk-root` w INI. Domyślny katalog to `C:/git-sdk-64`. Wrapper wymaga zainstalowanego SDK z Zsh i mintty; nie zawiera dystrybucji tych programów.

Skróty mają siedem zwijanych sekcji, obsługiwanych myszą i klawiaturą. Zaznaczenie w terminalu zaczyna się od przeciągnięcia; zwykły klik nie wybiera znaku. [Aktualna tabela stanu portu](docs/port-status.md) oddziela działające funkcje od zakresu pozostałego do przeniesienia.

Preferencje ogólne pozwalają włączyć animację wysuwania/chowania i ustawić jej czas. Działają skróty kierunkowego fokusu i przesuwania granicy podziału, otwieranie URL/OSC 8 oraz wyszukiwanie zaznaczenia w WWW. Menu tray zapisuje i przywraca karty z drzewem podziałów. Odtwarzanie po starcie i autosave korzystają z pliku `.session.json` obok INI i uruchamiają nowe powłoki w zapisanych katalogach.

Historia i ekran główny są ponownie zawijane po zmianie szerokości. Segmentacja grafemów używa systemowego ICU; nie trzeba dostarczać biblioteki wraz z aplikacją. Na starszych systemach bez odpowiednich eksportów ICU działa uproszczony wariant opisany w stanie portu.

Guake działa jako pojedyncza instancja użytkownika w sesji Windows. Kolejne uruchomienie przełącza widoczność; `guake.exe --help` pokazuje dostępne polecenia CLI. Komunikacja korzysta z prywatnego Named Pipe, nie z D-Bus. Tryb `--hidden` służy m.in. autostartowi. Menu tray „Wyświetl” przełącza widoczność jak główny skrót. Ikona nie ma pojawiać się na pasku zadań ani po aktywacji terminala.

Działają powiadomienia startowe i diagnostyczne z ikoną Guake, hooki start/show, autostart HKCU oraz dzwonek BEL. `.guake.yml` może nadawać tytuł projektu, a plik poleceń JSON tworzy menu użytkownika. Zakres parsera i ograniczenia integracji opisuje [stan portu](docs/port-status.md).

Quick Open otwiera istniejący plik z numerem wiersza przez Ctrl+klik albo menu zaznaczenia. Obsługuje diagnostykę Python/pytest/GCC/Delphi/MSVC i ścieżki Windows/Git SDK. W preferencjach włącz funkcję i ustaw polecenie edytora dostępnego w Windows, np. `notepad.exe %(file_path)s` albo `code -g %(file_path)s:%(line_number)s`. Można uruchamiać edytor osobno lub wysyłać polecenie do bieżącej powłoki.

Pasek kart obsługuje opcjonalne przyciski zamykania i pogrubienie tytułu po aktywności w tle, z okresami ignorowania po utworzeniu karty i utracie fokusu. Kolory można ustawiać przez CLI (`--bgcolor`, `--fgcolor`, warianty `-current`) i przywracać z menu karty lub `--reset-colors`. Kolory paneli są zapisywane razem z sesją.

Renderer buforuje niezmienione panele i wiersze, grupuje znaki ASCII z zachowaniem przycinania do komórek i przelicza alfę bez ponownego rysowania całego tekstu. Testy zapisują pomiar kompozycji 1920×1080 do `bin/tests/composition-latency.txt` oraz sprawdzają zgodność pikseli i ponowne użycie paneli.
