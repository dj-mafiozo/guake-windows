# Pokrycie emulatora VT

Stan: 1.0.30.63. To macierz aktualnej implementacji, nie deklaracja pełnej zgodności z VTE ani xterm. Źródło: `Src/Terminal/Guake.VT.pas`; scenariusze DUnitX: `Src/Tests/Guake.Terminal.Tests.pas`. Normatywny punkt odniesienia dla nazw i parametrów: [XTerm Control Sequences](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html). Ostateczna zgodność z VTE wymaga także porównania z jego zachowaniem.

| Grupa | Aktualny zakres | Braki i ograniczenia |
| --- | --- | --- |
| Dekoder | Przyrostowe UTF-8, znaki zastępcze dla błędnych danych, podział odczytów wewnątrz znaków | Dalsze porównania obsługi błędnych UTF-8 i C1 z VTE |
| Kontrolki C0 | BEL, BS, HT, LF/VT/FF, CR, SI/SO także wewnątrz ESC/CSI/oznaczeń zestawów; CAN/SUB anuluje, NUL/DEL nie drukuje | Odpowiedź ENQ jest pusta; dalsza macierz C1 i kontrolek w ciągach sterujących |
| Tabulatory | HT, HTS (ESC H), TBC (CSI g, CSI 3 g), CHT (CSI I), CBT (CSI Z), DECST8C (CSI ? 5 W); domyślne co 8 kolumn | Testy porównawcze z VTE przy zmianach geometrii i ekranów |
| Ruch | CUU/CUD/CUF/CUB, CNL/CPL, CHA/HPA, VPA, CUP/HVP, HPR/VPR | Pełne zachowanie marginesów, dodatkowe tryby i warianty |
| Edycja | ED/EL, ICH/DCH/ECH, IL/DL, SU/SD, DECSTBM | Selective erase i chronione komórki; prostokąty DEC; poziome marginesy; szerokie znaki przecinające granice edycji |
| Stan | DECOM, DECAWM, IRM, widoczność kursora, DECSC/DECRC, SCOSC/SCORC i 1048 (współrzędne, atrybuty, zestawy znaków, origin, autowrap, oczekujące zawinięcie i single shift), RIS | Chronione komórki/selective erase, DECSTR i zapisywanie trybów prywatnych |
| Kursor | Widoczność DECTCEM, DECSCUSR 0–6: preferencje lub blok/podkreślenie/pionowa kreska, warianty migające i stałe; odczyt przez DECRQSS | Dalsza zgodność geometrii i wypełnienia bloku z VTE; wariant xterm 7 nie jest obsługiwany |
| Ekrany | Ekran główny i alternatywny, 47/1047/1049, historia i reflow ekranu głównego | Osobna macierz wariantów przełączania i zapisów kursora, przypadki brzegowe reflow |
| SGR | Reset, bold/faint, italic, conceal, strike, overline, inverse; pięć stylów podkreślenia i jego kolor 58/59; miganie 5/6/25; ANSI 16/256 i RGB przez średniki i dwukropki | Dalsze warianty SGR, integracja systemowych preferencji migania i porównanie geometrii dekoracji z VTE |
| Odpowiedzi | DSR 5, CPR 6, DECXCPR ?6; wiersz względem regionu przy DECOM; DA/DECID i DA2, DECRQM/DECRPM dla obsługiwanych trybów, rozmiar w znakach CSI 18 t, DECRQSS SGR, marginesów i stylu kursora | Tertiary DA, pozostałe DECRQSS, raporty rozmiaru w pikselach/monitora i pozostałe zapytania |
| OSC i tytuł | 0/2: tytuł, 7: katalog, 8: odnośniki; CSI 22/23 t: stos tytułów okna dla 0/2 | Paleta i zapytania kolorów, osobny tytuł ikony i indeksowane sloty stosu, pozostałe OSC; polityka dostępu do schowka |
| DCS/APC/PM | DCS DECRQSS dla SGR, marginesów i stylu kursora; pozostałe DCS/APC/PM/SOS są konsumowane | Pozostałe DCS i dalsze porównania ciągów z VTE |
| Zestawy znaków | UTF-8, ASCII B, brytyjski A, DEC Special Graphics 0 w G0–G3; SI/SO, LS2/LS3, SS2/SS3 | Pozostałe zestawy narodowe, GR i 96-znakowe zestawy, warianty ESC z bajtami pośrednimi |
| Wejście | Application cursor, bracketed paste, tryby myszy 1000/1002/1003, częściowy format UTF-8 1005 i SGR 1006, fokus 1004, LNM 20 dla LF/Enter, aplikacyjna klawiatura numeryczna ESC = / ESC > / 66 | Pełna macierz modyfikatorów klawiatury, pozostałe protokoły klawiatury i myszy, niezależne nakładanie trybów myszy, klasyczne współrzędne poza ASCII i C1 w formacie 1005 na ConPTY |
| Grafemy i widok | Segmentacja ICU, szerokie komórki, znaki łączące, reflow; cache wierszy renderera | Pełny shaping, bidi i zgodność wizualna z VTE; segmentacja zależy od systemowego ICU |

## Regresje objęte testami w tym etapie

- Niestandardowe tabulatory ustawiane również sekwencją podzieloną między odczyty.
- Usuwanie pojedynczego i wszystkich przystanków; ruch w obie strony i ograniczenie do krawędzi bez dopisywania tekstu.
- Zachowanie przystanków po zmianie szerokości oraz odtworzenie domyślnych przez RIS i DECST8C.
- Nieobsługiwane prefiksy/bajty pośrednie nie wykonują przypadkiem zwykłych poleceń o tym samym znaku końcowym.
- Zwykłe i prywatne raporty kursora przy DECOM mają prawidłową postać i współrzędne względem regionu.

## Następne etapy

1. Pozostałe zapytania i tryby wejścia, pełna macierz modyfikatorów klawiatury.
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

## Zapytania urządzenia, fokus i nowa linia — 1.0.22.55

DA1 (CSI c / CSI 0 c) zachowuje odpowiedź VT100 `CSI ? 1 ; 2 c`. DA2 (CSI > c / CSI > 0 c) odpowiada `CSI > 0 ; 0 ; 0 c`: typ VT100 i neutralne identyfikatory firmware/ROM, bez podszywania się pod numer wydania xterm lub VTE. Niezerowe żądania i odebrane odpowiedzi DA nie wywołują kolejnych odpowiedzi. CSI 18 t zwraca `CSI 8 ; rows ; columns t` dla aktualnego bufora, również po zmianie rozmiaru. Nie zgłasza rozmiaru monitora ani pikseli.

DECRQM (`CSI mode $ p` / `CSI ? mode $ p`) zwraca DECRPM ze statusem 1 dla włączonego, 2 dla wyłączonego oraz 0 dla nieznanego trybu. Standardowe tryby: 4 i 20. Prywatne: 1, 6, 7, 25, 47/1047/1049, 1000/1002/1003, 1004, 1006 i 2004. Raporty odzwierciedlają aktualny stan implementacji, nie gwarantują pełnego pokrycia każdego wariantu tych trybów w VTE. Zapytania nie zmieniają oczekującego zawinięcia na prawej krawędzi.

Prywatny tryb 1004 włącza wysyłanie CSI I / CSI O przy WM_SETFOCUS / WM_KILLFOCUS ramki terminala. Raporty trafiają bezpośrednio do wejścia sesji, bez działań właściwych dla pisania, np. usuwania zaznaczenia. Wyłączenie trybu i reset blokują dalsze raporty. LNM (standardowy tryb 20) zmienia LF na początek następnego wiersza oraz Enter z CR na CR LF. Domyślnie jest wyłączony. Klawiaturę numeryczną aplikacyjną i część DECRQSS dodano w etapie 1.0.23.56.

Punkty odniesienia: [Xterm Control Sequences](https://www.xfree86.org/current/ctlseqs.html) i [obsługa sekwencji w VTE](https://github.com/GNOME/vte/blob/master/src/vteseq.cc). Test transportu używa potomnego PowerShell/C# z wejściem konsoli w trybie VT; proces sam włącza raporty fokusu, a test sprawdza dotarcie jego żądania do modelu. Scenariusz wysyła komunikaty fokusu do ramki oraz sprawdza odebrane kody znaków. To weryfikacja drogi parser–sesja–ConPTY i zdarzeń ramki, nie pełny test przełączania rzeczywistych okien na pulpicie.

## DECRQSS i klawiatura numeryczna — 1.0.23.56

DCS $ q m ST zwraca bieżące obsługiwane atrybuty i kolory SGR jako DCS 1 $ r ... m ST. Zapis zaczyna się od resetu 0 i pozwala odtworzyć semantycznie te same atrybuty przez CSI; nie wymaga identycznej kolejności/kodowania jak w VTE. DCS $ q r ST raportuje górny i dolny margines. Nieznany typ żądania otrzymuje DCS 0 $ r ST. Odczyt jest przyrostowy, zachowuje limit 4096 jednostek UTF-16 i odrzuca przekroczone żądanie w całości. CAN/SUB anuluje, a nowy ESC może rozpocząć inne polecenie. Pozostałe rodzaje DCS nadal są ignorowane. Punkt odniesienia: [DECRQSS w VTE](https://github.com/GNOME/vte/blob/master/src/vteseq.cc).

ESC = oraz prywatny tryb 66 włączają klawiaturę numeryczną aplikacyjną; ESC >, reset trybu i RIS ją wyłączają. Cyfry, operatory, separator, kropka i osobny Enter wysyłają sekwencje SS3. Widok rozróżnia rozszerzony bit komunikatu Windows, więc główne strzałki/Enter zachowują swoje znaczenie, a klawisze numeryczne przy wyłączonym Num Lock pozostają klawiszami numerycznymi. WM_CHAR po obsłużonym klawiszu cyfry/operatora/Enter jest konsumowany, aby nie dopisać znaku drugi raz. Rozszerzona macierz Shift/Ctrl/Alt i dodatkowe klawisze rzadkich układów nadal wymagają pracy.

Test natywny rozszerza proces wejścia VT o żądanie klawiatury aplikacyjnej i sprawdza dostarczone odpowiedzi DCS, cyfrę, numeryczny Enter, zwykłą strzałkę, strzałkę z części numerycznej i powrót do zwykłej cyfry. Test modelu odtwarza atrybuty z odpowiedzi DECRQSS i sprawdza nieznane/przerwane/przepełnione żądania.

## Styl kursora i jego odczyt — 1.0.26.59

CSI Ps SP q (DECSCUSR) przyjmuje wartości 0–6. Wartość 0 lub brak parametru przywraca kształt i miganie z preferencji, zgodnie z [wyborem domyślnego kursora w VTE](https://github.com/GNOME/vte/blob/master/src/vte.cc). 1/2 wybiera blok, 3/4 podkreślenie, 5/6 pionową kreskę; nieparzyste wartości migają, parzyste są stałe. Zmiana stylu nie włącza ukrytego kursora ani nie zmienia preferencji INI. Parametry spoza zakresu i błędne warianty składni są ignorowane. Dalszy punkt odniesienia: [DECSCUSR i DECRQSS w VTE](https://github.com/GNOME/vte/blob/master/src/vteseq.cc), [sekwencje xterm](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html).

DCS $q SP q ST odpowiada DCS 1$r Ps SP q ST z bieżącą wartością stylu. Zapytanie i ustawienie nie zmieniają pozycji ani oczekującego zawinięcia. Styl należy do terminala: jest wspólny dla ekranów i nie wchodzi do zapisu DECSC/DECRC; RIS przywraca 0. Odpowiedź przechodzi zwykłą drogą do wejścia ConPTY.

Widok stosuje tę samą funkcję fazy w rysowaniu, cache alfy i odświeżaniu. Jawne miganie ma okres półfazy 500 ms; ustawienie systemowe przy stylu 0 odczytuje GetCaretBlinkTime, również wyłączenie migania. Reset do 0 ponownie udostępnia preferencje. Zmiana stylu odświeża wiersz kursora i usuwa piksele poprzedniego kształtu. Testy porównują alfę kształtów oraz deterministyczne fazy migania, a natywny odbiorca ConPTY sprawdza bajty odpowiedzi. Obecny blok pozostaje obrysem GDI; pełne wypełnienie i geometria kursora zgodne z VTE wymagają dalszych prac i porównań.

## Przyciski i ruch myszy — 1.0.27.60

Ruch w trybie 1002 obejmuje wszystkie trzy przyciski; 1003 dodatkowo raportuje brak przycisku. Kod ruchu to numer przycisku 0/1/2 albo 3 przy hover, powiększony o 32 i bity modyfikatorów. Klasyczne zwolnienie zachowuje modyfikatory przy zastąpieniu numeru przycisku przez 3; SGR używa numeru przycisku i końcowego m. Punkt odniesienia: [źródło dokumentacji xterm, Mouse Tracking](https://github.com/ThomasDickey/xterm-snapshots/blob/master/ctlseqs.ms).

Shift pozostaje lokalnym obejściem raportowania. Natywny test ConPTY porównuje kody SGR dla prawego, środkowego i lewego przeciągania, hover z modyfikatorami, brak raportu ruchu w 1000 i hover w 1002 oraz klasyczne zwolnienie z Ctrl/Alt. Odbiorca sam zmienia 1006, aby testować rzeczywistą negocjację z ConPTY.

Dalsze ograniczenia: tryby 1000/1002/1003 nadal reprezentuje jeden aktywny tryb; filtrowanie powtórzeń w tej samej komórce dodano w 1.0.28.61. Od 1.0.29.62 klasyczne współrzędne na ConPTY są ograniczone do zakresu ASCII, a większe obsługuje negocjowany format 1005 lub SGR. Zalecanym obsługiwanym formatem pozostaje SGR 1006; brak jeszcze 1015/1016 i pełnej macierzy protokołów.

## Filtrowanie raportów i oddzielenie wejścia myszy — 1.0.28.61

Zgodnie z regułą ruchu między komórkami opisaną w [dokumentacji xterm](https://github.com/ThomasDickey/xterm-snapshots/blob/master/ctlseqs.ms), 1002/1003 nie powtarzają raportu dla ruchu wewnątrz zapamiętanej komórki. Przyciski nie są filtrowane. Format i tryb raportowania mają niezależną od tekstu rewizję negocjacji; widok uwzględnia także rozmiar siatki, reset, ponowne podłączenie sesji i lokalne użycie Shift. Dzięki temu nie pomija pierwszego raportu po renegocjacji ani nie resetuje filtra przy każdym fragmencie wyjścia.

Wysyłanie raportów nie usuwa zaznaczenia i nie uruchamia scroll-keystroke. Natywny test ConPTY porównuje pełny strumień wejścia po 200 powtórzeniach ruchu, przejściu do kolejnej komórki, zmianie trybu i geometrii oraz ponownym Bind. Test widoku sprawdza zachowanie zaznaczenia i przewijania. Pozostałe braki formatów i nakładania trybów opisuje tabela.

## UTF-8 mouse 1005 i granice klasycznego formatu — 1.0.29.62

Tryb 1005 przenosi współrzędne w UTF-8: do pozycji 1–2015 dodawane jest 32. Klasyczny format na tym porcie dopuszcza wyłącznie indeksy 0–94, aby zakodowana współrzędna nie przekraczała ASCII 127. Wymaganie UTF-8 wynika z wybranego formatu, nie jest domyślnie stosowanym rozszerzeniem klasycznego X10. Punkt odniesienia: [xterm, Extended coordinates](https://github.com/ThomasDickey/xterm-snapshots/blob/master/ctlseqs.ms) oraz [ograniczenie klasycznego wejścia Windows Terminal](https://github.com/microsoft/terminal/blob/main/src/terminal/input/mouseInput.cpp).

Bufor rozpoznaje 1005 w DECSET/DECRST i DECRQM; RIS go wyłącza. Każda negocjacja odświeża rewizję formatu dla filtra myszy. Przy obu ustawionych formatach w tej implementacji pierwszeństwo ma 1006. To nie oznacza pełnego odwzorowania nakładania formatów innych terminali.

Test ConPTY ustawia kodowanie wejścia odbiorcy na UTF-8 i negocjuje 1005 z procesu potomnego. W pierwszym przebiegu wartość 128 zniknęła w ścieżce wejścia, podczas gdy 2047 dotarła prawidłowo. Dlatego raporty zawierające C1 (128–159, indeksy 95–126 w dowolnej osi) są w tym porcie pomijane w całości. Jest to jawne ograniczenie częściowo obsługiwanego 1005. Końcowy test sprawdza poprawne wartości 127, 160 i 2047 oraz pominięcie 128. Weryfikuje również pominięcie pozycji poza zakresem oraz powrót do ograniczenia klasycznego po wyłączeniu 1005. SGR jest sprawdzany również dla pozycji 96 i 2016 i nie ma tych luk. Pełne bajtowe X10 do 223, zakres C1 w 1005 i formaty 1015/1016 pozostają poza zakresem tej implementacji.

## Stos tytułów okna — 1.0.30.63

XTWINOPS CSI 22;2 t zapisuje tytuł okna z OSC 0/2, a CSI 23;2 t go przywraca. Pominięty drugi parametr i wartość 0 obsługują ten sam tytuł okna. Parametr 1 (osobna etykieta ikony), trzeci parametr (indeksowany dostęp do slotów) i błędne warianty są ignorowane. Punkt odniesienia: [xterm, XTWINOPS 22/23](https://github.com/ThomasDickey/xterm-snapshots/blob/master/ctlseqs.ms).

Stos LIFO jest ograniczony do 64 wpisów z usuwaniem najstarszego przy przepełnieniu. Pusty wpis jest przywracany, pusty stos nie zmienia tytułu. Stos należy do sesji terminala, jest wspólny dla jej ekranów i przeżywa resize; RIS go czyści. Nie jest częścią trwałego zapisu sesji ani pamięci wznawianego procesu.

Dwa scenariusze DUnitX obejmują każde miejsce podziału sekwencji OSC/CSI, zagnieżdżenie, parametry 0/2 i domyślny, pusty tytuł, podpełnienie i przepełnienie, ignorowane operacje ikon/slotów, niezależność terminali, ekran alternatywny, resize i reset. Sprawdzają także zachowanie oczekującego zawinięcia oraz brak dodatkowych odpowiedzi. Nie zastępuje to pełnego porównania wszystkich operacji tytułów i okna z uruchomionym VTE.
