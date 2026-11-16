# Pokrycie emulatora VT

Stan: 1.0.18.51. To macierz aktualnej implementacji, nie deklaracja pełnej zgodności z VTE ani xterm. Źródło: `Src/Terminal/Guake.VT.pas`; scenariusze DUnitX: `Src/Tests/Guake.Terminal.Tests.pas`. Normatywny punkt odniesienia dla nazw i parametrów: [XTerm Control Sequences](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html). Ostateczna zgodność z VTE wymaga także porównania z jego zachowaniem.

| Grupa | Aktualny zakres | Braki i ograniczenia |
| --- | --- | --- |
| Dekoder | Przyrostowe UTF-8, znaki zastępcze dla błędnych danych, podział odczytów wewnątrz znaków | Dalsza macierz błędnych strumieni i anulowania sekwencji |
| Kontrolki C0 | BEL, BS, HT, LF/VT/FF, CR, SI/SO; CAN/SUB anuluje sekwencję | ENQ i kompletna obsługa pozostałych C0 wewnątrz sekwencji |
| Tabulatory | HT, HTS (ESC H), TBC (CSI g, CSI 3 g), CHT (CSI I), CBT (CSI Z), DECST8C (CSI ? 5 W); domyślne co 8 kolumn | Testy porównawcze z VTE przy zmianach geometrii i ekranów |
| Ruch | CUU/CUD/CUF/CUB, CNL/CPL, CHA/HPA, VPA, CUP/HVP, HPR/VPR | Pełne zachowanie marginesów, dodatkowe tryby i warianty |
| Edycja | ED/EL, ICH/DCH/ECH, IL/DL, SU/SD, DECSTBM | Selective erase i chronione komórki; prostokąty DEC; poziome marginesy; szerokie znaki przecinające granice edycji |
| Stan | DECOM, DECAWM, IRM, widoczność kursora, DECSC/DECRC, SCOSC/SCORC i 1048 (współrzędne, atrybuty, zestawy znaków, origin, autowrap, oczekujące zawinięcie i single shift), RIS | Chronione komórki/selective erase, DECSTR i zapisywanie trybów prywatnych |
| Ekrany | Ekran główny i alternatywny, 47/1047/1049, historia i reflow ekranu głównego | Osobna macierz wariantów przełączania i zapisów kursora, przypadki brzegowe reflow |
| SGR | Reset, bold, italic, underline, inverse, ich wyłączenie; ANSI 16/256 i RGB | Faint, conceal, strike, overline, style/kolory podkreślenia; pełna gramatyka podparametrów z dwukropkami |
| Odpowiedzi | DSR 5, CPR 6, DECXCPR ?6; wiersz względem regionu przy DECOM; podstawowe DA/DECID | Secondary/tertiary DA, DECRQM, DECRQSS, raporty rozmiaru i pozostałe zapytania |
| OSC | 0/2: tytuł, 7: katalog, 8: odnośniki | Paleta i zapytania kolorów, stos tytułów, pozostałe OSC; polityka dostępu do schowka |
| DCS/APC/PM | Pomijanie danych do zakończenia sekwencji | Brak implementacji funkcji DCS; kompletna macierz odzyskiwania po błędach i limitach |
| Zestawy znaków | UTF-8, ASCII B, brytyjski A, DEC Special Graphics 0 w G0–G3; SI/SO, LS2/LS3, SS2/SS3 | Pozostałe zestawy narodowe, GR i 96-znakowe zestawy, warianty ESC z bajtami pośrednimi |
| Wejście | Application cursor, bracketed paste, tryby myszy 1000/1002/1003 i 1006 | Klawiatura aplikacyjna, raporty fokusu, pozostałe protokoły klawiatury i myszy |
| Grafemy i widok | Segmentacja ICU, szerokie komórki, znaki łączące, reflow; cache wierszy renderera | Pełny shaping, bidi i zgodność wizualna z VTE; segmentacja zależy od systemowego ICU |

## Regresje objęte testami w tym etapie

- Niestandardowe tabulatory ustawiane również sekwencją podzieloną między odczyty.
- Usuwanie pojedynczego i wszystkich przystanków; ruch w obie strony i ograniczenie do krawędzi bez dopisywania tekstu.
- Zachowanie przystanków po zmianie szerokości oraz odtworzenie domyślnych przez RIS i DECST8C.
- Nieobsługiwane prefiksy/bajty pośrednie nie wykonują przypadkiem zwykłych poleceń o tym samym znaku końcowym.
- Zwykłe i prywatne raporty kursora przy DECOM mają prawidłową postać i współrzędne względem regionu.

## Następne etapy

1. Odzyskiwanie parsera po błędach, C0 w sekwencjach i gramatyka parametrów SGR.
2. Brakujące atrybuty, zapytania oraz tryby wejścia wraz z integracją widoku.
3. Edycja szerokich komórek, marginesy i reflow; porównania strumieni i obrazów z VTE.

Samo dodanie rozpoznawania sekwencji nie wystarcza do uznania funkcji za ukończoną: tryby wejścia muszą działać w kontrolerze, a atrybuty komórek w rendererze.

## Zestawy znaków i zapis kursora — 1.0.18.51

DEC Special Graphics mapuje znaki ASCII od `_` do `~` na symbole i elementy ramek Unicode. Zestaw brytyjski zamienia `#` na `£`, ASCII pozostawia znaki bez zmian. Oznaczenia G0–G3 wybierają ESC (, ), * i +; SI/SO przełącza G0/G1, ESC n/o wybiera G2/G3, ESC N/O wybiera G2/G3 dla następnego znaku. Znaki UTF-8 spoza zakresu ASCII pozostają niezmienione. Nieobsługiwane oznaczenia zestawów nie zastępują działającego mapowania, a ich bajty pośrednie nie trafiają do tekstu ekranu.

DECSC/DECRC, SCOSC/SCORC (CSI s/u) oraz 1048 korzystają z osobnego zapisu dla każdego ekranu. Przywracają pozycję ograniczoną do aktualnej geometrii, przeniesione atrybuty SGR, zestawy i wybór GL, origin, autowrap, oczekujące zawinięcie i single shift. CSI s/u współdzieli zapis z ESC 7/8, jak w VTE. 1049 zapisuje stan przed przejściem na ekran alternatywny i przywraca go po powrocie. Reset inicjuje oba zapisy wartościami domyślnymi. Nie jest to zapis procesu ani trwała sesja na dysku.

Porównanie źródłowe: [mapowanie znaków i zapis kursora w VTE](https://github.com/GNOME/vte/blob/master/src/vte.cc), [DECSC i SCOSC/SCORC w VTE](https://github.com/GNOME/vte/blob/master/src/vteseq.cc) oraz specyfikacja xterm. To przegląd semantyki w źródłach, bez deklaracji ukończenia porównania graficznego na uruchomionym VTE.

Scenariusze tego etapu obejmują ramki DEC, wszystkie cztery sloty i przełączenia jednorazowe, sekwencje dzielone na bajty, anulowanie oznaczenia zestawu, niezmienność znaków Unicode, atrybuty i tryby po odtworzeniu, zawinięcie na prawej krawędzi, niezależność zapisów ekranów, 1048/1049, reset, zmianę rozmiaru i zamienne użycie CSI s/u z ESC 7/8. Pełne zachowanie wariantów 47/1047, reflow zapisanego kursora i renderowanie ramek z różnymi fontami pozostają do dalszych porównań.
