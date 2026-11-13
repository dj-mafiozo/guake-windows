# Guake dla Windows

Port Guake na Windows 64-bit w Delphi/VCL z natywnym WinAPI. Celem jest zgodność funkcji i wyglądu z Guake. Obecnie dostępne są ustawienia i formularze; backend ConPTY, emulator VT oraz Named Pipes pozostają do implementacji. Główne okno nie uruchamia jeszcze powłoki.

Główny projekt: [Src/guake.dpr](Src/guake.dpr), [Src/guake.dproj](Src/guake.dproj). Cały kod, projekty, narzędzia i dane lokalizacji znajdują się pod `Src/`. Wyniki budowania trafiają do ignorowanego `bin/`, pliki pośrednie do `.build/`.

- [Ustawienia](Src/Settings/Guake.Settings.pas): 130 kluczy z oryginalnego schematu, hierarchiczne rekordy i osobna klasa z `TMemIniFile`.
- [Preferencje](Src/Forms/frmPreferencesU.pas): dziewięć zakładek z `prefs.glade`, zapis zmian, zależności kontrolek, skróty, 169 palet i dialogi plikowe.
- [Formularze](Src/Forms): okno główne, preferencje, informacje o programie, wyszukiwanie, zmiana nazwy i potwierdzenia. [Moduły danych](Src/DataModules) zawierają komponenty dialogów plikowych.
- [Lokalizacja](Src/Localization/README.md): 26 oryginalnych PO Guake, import przez GNU msgfmt, biblioteka `Src/Vendor/i18n`.
- [Diagnostyka](Src/Diagnostics/Guake.Logging.pas): logowanie `Exception.StackTrace`, biblioteka `Src/Vendor/stacktrace`, MAP i PDB dla każdego EXE.
- [Common](Src/Common/README.md): submoduł z odczytem wersji EXE przez `VersionU.pas`.

Budowanie i testy dla Delphi 10.2 (z katalogu repozytorium):

```powershell
git submodule update --init --recursive
powershell -NoProfile -ExecutionPolicy Bypass -File Src/Tools/Test.ps1
```

Wymagane: Delphi Win64, Python 3 i `map2pdb.exe` w PATH. Każdy przebieg zwiększa build. Skrypt buduje projekt główny, DUnitX oraz podgląd formularzy; generuje i wiąże PDB z EXE. Raport: `bin/tests/test-results.xml`. Podglądy zakładek: `bin/tests/preferences-preview/`. Testy używają własnego katalogu tymczasowego pod `.build/`.

Główny EXE: `bin/Win64/guake.exe`. Samodzielny edytor preferencji do sprawdzenia formularza: `bin/forms/GuakeFormsPreview.exe`. Edytor zapisuje ustawienia do `%APPDATA%/Guake/guake.ini`. Zbudowaną aplikację z PDB i lokalizacją można spakować przez `Src/Tools/Package.ps1`.

[Stan portu i mapa formularzy](docs/port-status.md) opisują zakres działającego kodu i braki. [Inwentarz źródłowego Guake](docs/guake-contract.json) nie oznacza implementacji wszystkich wymienionych funkcji. [AGENTS.md](AGENTS.md) określa formatowanie, zasoby i wersjonowanie.
