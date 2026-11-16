# Pokrycie emulatora VT

Stan: 1.0.21.54. To macierz aktualnej implementacji, nie deklaracja pełnej zgodności z VTE ani xterm. Źródło: `Src/Terminal/Guake.VT.pas`; scenariusze DUnitX: `Src/Tests/Guake.Terminal.Tests.pas`. Normatywny punkt odniesienia dla nazw i parametrów: [XTerm Control Sequences](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html). Ostateczna zgodność z VTE wymaga także porównania z jego zachowaniem.

| Grupa | Aktualny zakres | Braki i ograniczenia |
| --- | --- | --- |
| Dekoder | Przyrostowe UTF-8, znaki zastępcze dla błędnych danych, podział odczytów wewnątrz znaków | Dalsze porównania obsługi błędnych UTF-8 i C1 z VTE |
| Kontrolki C0 | BEL, BS, HT, LF/VT/FF, CR, SI/SO także wewnątrz ESC/CSI/oznaczeń zestawów; CAN/SUB anuluje, NUL/DEL nie drukuje | Odpowiedź ENQ jest pusta; dalsza macierz C1 i kontrolek w ciągach sterujących |
| Tabulatory | HT, HTS (ESC H), TBC (CSI g, CSI 3 g), CHT (CSI I), CBT (CSI Z), DECST8C (CSI ? 5 W); domyślne co 8 kolumn | Testy porównawcze z VTE przy zmianach geometrii i ekranów |
| Ruch | CUU/CUD/CUF/CUB, CNL/CPL, CHA/HPA, VPA, CUP/HVP, HPR/VPR | Pełne zachowanie marginesów, dodatkowe tryby i warianty |
| Edycja | ED/EL, ICH/DCH/ECH, IL/DL, SU/SD, DECSTBM | Selective erase i chronione komórki; prostokąty DEC; poziome marginesy; szerokie znaki przecinające granice edycji |
| Stan | DECOM, DECAWM, IRM, widoczność kursora, DECSC/DECRC, SCOSC/SCORC i 1048 (współrzędne, atrybuty, zestawy znaków, origin, autowrap, oczekujące zawinięcie i single shift), RIS | Chronione komórki/selective erase, DECSTR i zapisywanie trybów prywatnych |
| Ekrany | Ekran główny i alternatywny, 47/1047/1049, historia i reflow ekranu głównego | Osobna macierz wariantów przełączania i zapisów kursora, przypadki brzegowe reflow |
| SGR | Reset, bold/faint, italic, conceal, strike, overline, inverse; pięć stylów podkreślenia i jego kolor 58/59; miganie 5/6/25; ANSI 16/256 i RGB przez średniki i dwukropki | Dalsze warianty SGR, integracja systemowych preferencji migania i porównanie geometrii dekoracji z VTE |
| Odpowiedzi | DSR 5, CPR 6, DECXCPR ?6; wiersz względem regionu przy DECOM; podstawowe DA/DECID | Secondary/tertiary DA, DECRQM, DECRQSS, raporty rozmiaru i pozostałe zapytania |
| OSC | 0/2: tytuł, 7: katalog, 8: odnośniki | Paleta i zapytania kolorów, stos tytułów, pozostałe OSC; polityka dostępu do schowka |
| DCS/APC/PM | Pomijanie DCS/APC/PM/SOS; nowy ESC może przerwać ciąg i rozpocząć nowe polecenie | Brak implementacji funkcji DCS; dalsze porównania ciągów z VTE |
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

1. Brakujące zapytania urządzenia i tryby wejścia z integracją kontrolera.
2. Edycja szerokich komórek, marginesy i reflow; porównania strumieni i obrazów z VTE.
3. Dalsze przypadki błędnych strumieni, C1 i ciągów sterujących.

Samo dodanie rozpoznawania sekwencji nie wystarcza do uznania funkcji za ukończoną: tryby wejścia muszą działać w kontrolerze, a atrybuty komórek w rendererze.

## Zestawy znaków i zapis kursora — 1.0.18.51

DEC Special Graphics mapuje znaki ASCII od `_` do `~` na symbole i elementy ramek Unicode. Zestaw brytyjski zamienia `#` na `£`, ASCII pozostawia znaki bez zmian. Oznaczenia G0–G3 wybierają ESC (, ), * i +; SI/SO przełącza G0/G1, ESC n/o wybiera G2/G3, ESC N/O wybiera G2/G3 dla następnego znaku. Znaki UTF-8 spoza zakresu ASCII pozostają niezmienione. Nieobsługiwane oznaczenia zestawów nie zastępują działającego mapowania, a ich bajty pośrednie nie trafiają do tekstu ekranu.

DECSC/DECRC, SCOSC/SCORC (CSI s/u) oraz 1048 korzystają z osobnego zapisu dla każdego ekranu. Przywracają pozycję ograniczoną do aktualnej geometrii, przeniesione atrybuty SGR, zestawy i wybór GL, origin, autowrap, oczekujące zawinięcie i single shift. CSI s/u współdzieli zapis z ESC 7/8, jak w VTE. 1049 zapisuje stan przed przejściem na ekran alternatywny i przywraca go po powrocie. Reset inicjuje oba zapisy wartościami domyślnymi. Nie jest to zapis procesu ani trwała sesja na dysku.

Porównanie źródłowe: [mapowanie znaków i zapis kursora w VTE](https://github.com/GNOME/vte/blob/master/src/vte.cc), [DECSC i SCOSC/SCORC w VTE](https://github.com/GNOME/vte/blob/master/src/vteseq.cc) oraz specyfikacja xterm. To przegląd semantyki w źródłach, bez deklaracji ukończenia porównania graficznego na uruchomionym VTE.

Scenariusze tego etapu obejmują ramki DEC, wszystkie cztery sloty i przełączenia jednorazowe, sekwencje dzielone na bajty, anulowanie oznaczenia zestawu, niezmienność znaków Unicode, atrybuty i tryby po odtworzeniu, zawinięcie na prawej krawędzi, niezależność zapisów ekranów, 1048/1049, reset, zmianę rozmiaru i zamienne użycie CSI s/u z ESC 7/8. Pełne zachowanie wariantów 47/1047, reflow zapisanego kursora i renderowanie ramek z różnymi fontami pozostają do dalszych porównań.

## Odzyskiwanie parsera i podparametry SGR — 1.0.19.52

W ESC, CSI i oznaczeniach zestawów znane kontrolki C0 wykonują swoją funkcję bez kończenia sekwencji. NUL i DEL nie dopisują znaków. CAN/SUB anuluje rozpoznawanie. Nieobsługiwane sekwencje ESC z bajtami pośrednimi są konsumowane do końcowego znaku; samo ich pominięcie nie oznacza implementacji np. DECALN. Nowy ESC przerywa nieukończone polecenie; także OSC i ignorowane ciągi mogą ustąpić nowej sekwencji ESC/CSI. Niepoprawny znak Unicode w CSI kończy sekwencję i trafia do normalnego tekstu.

Limity pozostają ochronne: 256 znaków CSI i 4096 jednostek UTF-16 OSC. Przekroczenie oznacza odrzucenie całej sekwencji przy jej zakończeniu; parser nie wykonuje obciętego CSI ani nie publikuje obciętego tytułu/odnośnika. Przepełniona liczba w zwykłym CSI nie jest zamieniana na domyślne zero. W OSC pozostałe C0 są ignorowane, BEL i ESC \ kończą ciąg, a CAN/SUB go anuluje.

SGR zachowuje granice grup oddzielanych średnikami i podparametrów oddzielanych dwukropkami. Obsługiwane kolory: `38;5;n`, `48;5;n`, `38:5:n`, `48:5:n`, `38;2;r;g;b`, `48;2;r;g;b`, `38:2:r:g:b`, `48:2:r:g:b` oraz warianty z pustym identyfikatorem przestrzeni kolorów, np. `38:2::r:g:b`. Składowe muszą mieścić się w 0–255; niepuste identyfikatory przestrzeni nie są obsługiwane. Niepełne lub błędne składowe nie stają się osobnymi poleceniami SGR. `4:0` i `4:1` wyłączają/włączają obsługiwane pojedyncze podkreślenie; pozostałe style nadal wymagają widoku. Parametry koloru podkreślenia SGR 58 są konsumowane bez zmiany innych atrybutów; jego renderowanie nie jest jeszcze zaimplementowane.

Punkt odniesienia dla składni i konsumowania parametrów: [parser SGR VTE](https://github.com/GNOME/vte/blob/master/src/sgr.hh). Test podziału danych porównuje ekran, kolory, kursor, tytuł, dzwonek i odpowiedź urządzenia dla każdego miejsca podziału oraz dalszych odczytów po pojedynczym bajcie. Nie zastępuje to pełnej macierzy różnic z uruchomionym VTE.

## Atrybuty i dekoracje tekstu — 1.0.20.53

SGR 2 przyciemnia tekst; 22 wyłącza zarówno bold, jak i faint. SGR 8/28 ukrywa/przywraca glify i dekoracje bez kasowania tekstu z modelu, historii i kopiowanego zaznaczenia. Nie jest to mechanizm usuwania poufnych danych. SGR 9/29 steruje przekreśleniem, a 53/55 linią nad tekstem.

SGR 4:0–5 wybiera brak podkreślenia, pojedynczą linię, linię podwójną, falistą, kropkowaną albo kreskowaną. Zwykłe 4 wybiera pojedyncze, 21 podwójne, 24 wyłącza. Nieobsługiwany numer stylu nie zmienia poprzedniego. SGR 58 przyjmuje paletę albo RGB przez średniki/dwukropki; 59 przywraca kolor bieżącego tekstu. Te pola są przechowywane w komórkach, reflow oraz zapisie DECSC/DECRC i resetowane przez SGR 0/RIS.

Widok rysuje zwykłe jednokolorowe podkreślenie i przekreślenie przez GDI; kolorowe i pozostałe podkreślenia oraz overline rysuje w granicach komórek. Wzór linii jest zakotwiczony we współrzędnych widoku, więc grupowanie ASCII nie zmienia jego fazy. Faint uśrednia składowe RGB koloru tekstu i rozwiązanego koloru tła przed inwersją; obraz tła nie jest próbkowany do tego obliczenia. Maska pokrycia zachowuje nieprzezroczystość dekoracji niezależnie od nieprzezroczystości tła. Conceal nie ujawnia tekstu po zaznaczeniu, ale jawne tło SGR pozostaje widoczne.

Cache wierszy oraz grupowanie ASCII uwzględniają wszystkie nowe atrybuty. Testy sprawdzają stan i reset, zachowanie przy zapisie kursora/reflow, pięć widocznych stylów, kolor i alfę dekoracji, conceal przy tle domyślnym/jawnym, przygaszenie, przekreślenie spacji i odświeżenie jednego wiersza po zmianie samego atrybutu. Podgląd: bin/tests/sgr-preview.png. Geometria GDI nadal wymaga porównań z Pango/VTE dla różnych fontów i DPI; miganie tekstu dodano w kolejnym etapie 1.0.21.54.

## Miganie tekstu — 1.0.21.54

SGR 5 i 6 włączają ten sam atrybut migania, a 25 go wyłącza, zgodnie z rozróżnieniem przyjętym w [parserze SGR VTE](https://github.com/GNOME/vte/blob/master/src/sgr.hh). SGR 0 i RIS przywracają brak migania. Atrybut pozostaje w komórkach, historii, reflow i zapisie kursora; faza animacji należy do widoku, nie do danych terminala. Tekst można kopiować również w fazie niewidocznej.

Widok przełącza fazę co 500 ms, korzystając z istniejącego timera i upływu czasu od poprzedniego tyknięcia. Ukryte okno/panel nie przesuwa fazy. Znikają glify i dekoracje, a tło komórki, zaznaczenie i obraz pozostają. Po powrocie fazy maska pokrycia przywraca krycie tekstu i dekoracji. To mechanizm odrębny od migania kursora; ustawienie CursorBlinkMode go nie steruje. Integracja systemowych preferencji dostępności i ustawień migania tekstu pozostaje do wykonania.

Cache zapamiętuje, które widoczne wiersze mają migającą treść. Informacja jest przeliczana przy zmianie wiersza albo widoku, bez przeglądania całej historii na każdym tyknięciu. Conceal, same niedekorowane spacje i kontynuacje szerokich znaków nie tworzą dodatkowej pracy. Zmiana fazy nie unieważnia cache panelu bez widocznych migających komórek. Rasteryzowane są tylko właściwe wiersze (oraz niezależnie wymagane wiersze kursora); kompozycja ARGB i prezentacja okna pozostają bitmapowe.

Scenariusze sprawdzają SGR 5/6/25, reset, zapis/odtworzenie kursora i reflow, granicę 499/500 ms, ponowne użycie cache, rasteryzację jednego wiersza, tło domyślne i jawne, krycie po powrocie fazy, conceal, spacje, przewijanie historii oraz ekran alternatywny. Nie deklarują pełnej zgodności wszystkich polityk fokusu i migania VTE.
