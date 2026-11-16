# Pokrycie emulatora VT

Stan: 1.0.17.50. To macierz aktualnej implementacji, nie deklaracja pełnej zgodności z VTE ani xterm. Źródło: `Src/Terminal/Guake.VT.pas`; scenariusze DUnitX: `Src/Tests/Guake.Terminal.Tests.pas`. Normatywny punkt odniesienia dla nazw i parametrów: [XTerm Control Sequences](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html). Ostateczna zgodność z VTE wymaga także porównania z jego zachowaniem.

| Grupa | Aktualny zakres | Braki i ograniczenia |
| --- | --- | --- |
| Dekoder | Przyrostowe UTF-8, znaki zastępcze dla błędnych danych, podział odczytów wewnątrz znaków | Dalsza macierz błędnych strumieni i anulowania sekwencji |
| Kontrolki C0 | BEL, BS, HT, LF/VT/FF, CR | SI/SO i zestawy znaków, ENQ, kompletna obsługa C0 wewnątrz sekwencji |
| Tabulatory | HT, HTS (ESC H), TBC (CSI g, CSI 3 g), CHT (CSI I), CBT (CSI Z), DECST8C (CSI ? 5 W); domyślne co 8 kolumn | Testy porównawcze z VTE przy zmianach geometrii i ekranów |
| Ruch | CUU/CUD/CUF/CUB, CNL/CPL, CHA/HPA, VPA, CUP/HVP, HPR/VPR | Pełne zachowanie marginesów, dodatkowe tryby i warianty |
| Edycja | ED/EL, ICH/DCH/ECH, IL/DL, SU/SD, DECSTBM | Selective erase i chronione komórki; prostokąty DEC; poziome marginesy; szerokie znaki przecinające granice edycji |
| Stan | DECOM, DECAWM, IRM, widoczność kursora, współrzędne zapisane/przywrócone, RIS | Pełny DECSC/DECRC (atrybuty, zestawy znaków i tryby), DECSTR i zapisywanie trybów prywatnych |
| Ekrany | Ekran główny i alternatywny, 47/1047/1049, historia i reflow ekranu głównego | Osobna macierz wariantów przełączania i zapisów kursora, przypadki brzegowe reflow |
| SGR | Reset, bold, italic, underline, inverse, ich wyłączenie; ANSI 16/256 i RGB | Faint, conceal, strike, overline, style/kolory podkreślenia; pełna gramatyka podparametrów z dwukropkami |
| Odpowiedzi | DSR 5, CPR 6, DECXCPR ?6; wiersz względem regionu przy DECOM; podstawowe DA/DECID | Secondary/tertiary DA, DECRQM, DECRQSS, raporty rozmiaru i pozostałe zapytania |
| OSC | 0/2: tytuł, 7: katalog, 8: odnośniki | Paleta i zapytania kolorów, stos tytułów, pozostałe OSC; polityka dostępu do schowka |
| DCS/APC/PM | Pomijanie danych do zakończenia sekwencji | Brak implementacji funkcji DCS; kompletna macierz odzyskiwania po błędach i limitach |
| Zestawy znaków | UTF-8; sekwencje wyboru zestawu są konsumowane | DEC Special Graphics, G0–G3, locking/single shifts, warianty ESC z bajtami pośrednimi |
| Wejście | Application cursor, bracketed paste, tryby myszy 1000/1002/1003 i 1006 | Klawiatura aplikacyjna, raporty fokusu, pozostałe protokoły klawiatury i myszy |
| Grafemy i widok | Segmentacja ICU, szerokie komórki, znaki łączące, reflow; cache wierszy renderera | Pełny shaping, bidi i zgodność wizualna z VTE; segmentacja zależy od systemowego ICU |

## Regresje objęte testami w tym etapie

- Niestandardowe tabulatory ustawiane również sekwencją podzieloną między odczyty.
- Usuwanie pojedynczego i wszystkich przystanków; ruch w obie strony i ograniczenie do krawędzi bez dopisywania tekstu.
- Zachowanie przystanków po zmianie szerokości oraz odtworzenie domyślnych przez RIS i DECST8C.
- Nieobsługiwane prefiksy/bajty pośrednie nie wykonują przypadkiem zwykłych poleceń o tym samym znaku końcowym.
- Zwykłe i prywatne raporty kursora przy DECOM mają prawidłową postać i współrzędne względem regionu.

## Następne etapy

1. Zestawy znaków DEC i pełny zapis/odtworzenie stanu kursora.
2. Odzyskiwanie parsera po błędach, C0 w sekwencjach i gramatyka parametrów SGR.
3. Brakujące atrybuty, zapytania oraz tryby wejścia wraz z integracją widoku.
4. Edycja szerokich komórek, marginesy i reflow; porównania strumieni i obrazów z VTE.

Samo dodanie rozpoznawania sekwencji nie wystarcza do uznania funkcji za ukończoną: tryby wejścia muszą działać w kontrolerze, a atrybuty komórek w rendererze.
