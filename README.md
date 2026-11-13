# Guake dla Windows

Port Guake na Windows 64-bit: Delphi, VCL, natywne WinAPI i ConPTY. Celem jest pełna zgodność funkcji i wyglądu z Guake. Obecny stan to pierwsze moduły infrastruktury; aplikacja terminalowa nie jest jeszcze dostępna.

- Ustawienia: osobna klasa `TGuakeSettings`, oparta na `TMemIniFile`.
- Powłoki: profile CMD, Windows PowerShell, Bash i Zsh z git-sdk-64.
- Docelowa komunikacja między procesami: Named Pipes.
- Formularze: DFM; zasoby niestandardowe: RC; VersionInfo i manifest generowane przez MSBuild.
- Odczyt wersji: submoduł `Src/Common`, jednostka `VersionU.pas`.

Przed budowaniem zainicjuj submoduły: `git submodule update --init --recursive`. Testy dla Delphi 10.2: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/Test.ps1`. Raport: `bin/tests/test-results.xml`. Każde wywołanie skryptu zwiększa build. Formatter i zasady repozytorium opisuje [AGENTS.md](AGENTS.md).

Szczegóły zakresu, brakujące funkcje i zasady wersjonowania: [stan portu](docs/port-status.md). Inwentarz źródła: [guake-contract.json](docs/guake-contract.json).