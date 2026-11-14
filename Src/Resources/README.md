# Zasoby graficzne

`Pixmaps/` zachowuje oryginalne obrazy Guake, opisane w `pixmaps-source.json`. `add_tab.png` jest kopią oryginalnej ikony `Pixmaps/add_tab.png` pod ścieżką wymaganą dla przycisku nowej karty.

`btnAddTab` i `btnTabList` są standardowymi TSpeedButton w DFM. Glyph pierwszego przycisku pochodzi z `Src/Resources/add_tab.png`. Ponieważ TSpeedButton.Glyph jest TBitmap, DFM przechowuje pochodną BMP z maskowanym tłem. Ikona jest widoczna także w projektancie; nie powstają kontrolki w kodzie Pascal.

Jawna aktualizacja po zmianie PNG: `powershell -NoProfile -ExecutionPolicy Bypass -File Src/Tools/Update-AddTabGlyph.ps1`. Sprawdzenie bez zapisu: to samo polecenie z `-Check`. Skrypt zmienia wyłącznie dane Glyph w DFM i nie należy do zwykłego budowania.

`Guake.Images.rc` zawiera wyłącznie własne zasoby graficzne. RES są generowane i ignorowane przez Git. Wersję EXE, manifest i główną ikonę projektu nadal generuje MSBuild.
