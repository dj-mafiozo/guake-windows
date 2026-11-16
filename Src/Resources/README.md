# Zasoby graficzne

`Pixmaps/` zachowuje oryginalne obrazy Guake, opisane w `pixmaps-source.json`. `add_tab.png` jest kopią oryginalnej ikony `Pixmaps/add_tab.png` pod ścieżką wymaganą dla przycisku nowej karty.

`btnAddTab` i `btnTabList` są standardowymi TSpeedButton w DFM. Glyph pierwszego przycisku pochodzi z `Src/Resources/add_tab.png`. Ponieważ TSpeedButton.Glyph jest TBitmap, DFM przechowuje pochodną BMP z maskowanym tłem. Ikona jest widoczna także w projektancie; nie powstają kontrolki w kodzie Pascal.

Jawna aktualizacja po zmianie PNG: `powershell -NoProfile -ExecutionPolicy Bypass -File Src/Tools/Update-AddTabGlyph.ps1`. Sprawdzenie bez zapisu: to samo polecenie z `-Check`. Skrypt zmienia wyłącznie dane Glyph w DFM i nie należy do zwykłego budowania.

`Guake.Images.rc` zawiera wyłącznie własne zasoby graficzne. RES są generowane i ignorowane przez Git. Wersję EXE, manifest i główną ikonę projektu nadal generuje MSBuild.

Ikona wrappera `zsh.ico` pochodzi z `C:/git-sdk-64/usr/bin/zsh.exe`; `zsh.source.json` przechowuje pochodzenie i SHA-256. Import: `python Src/Tools/Import-ZshIcon.py`. Sprawdzenie względem instalacji: ten sam skrypt z `--check`. Sprawdzenie zbudowanego wrappera: `python Src/Tools/Import-ZshIcon.py --source bin/Win64/git-zsh.exe --check`. Importer odczytuje zasoby PE bez uruchamiania EXE. Zwykły build korzysta z ICO wskazanego przez `Icon_MainIcon`, bez własnego RC/RES i bez dostępu do źródłowego EXE.
