# Pokrycie emulatora VT

Stan: 1.0.61.94. To macierz aktualnej implementacji, nie deklaracja pełnej zgodności z VTE ani xterm. Źródło: `Src/Terminal/Guake.VT.pas`; scenariusze DUnitX: `Src/Tests/Guake.Terminal.Tests.pas`. Normatywny punkt odniesienia dla nazw i parametrów: [XTerm Control Sequences](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html). Ostateczna zgodność z VTE wymaga także porównania z jego zachowaniem.

| Grupa | Aktualny zakres | Braki i ograniczenia |
| --- | --- | --- |
| Dekoder | Przyrostowe UTF-8, znaki zastępcze dla błędnych danych, podział odczytów wewnątrz znaków | Dalsze porównania obsługi błędnych UTF-8 i C1 z VTE |
| Kontrolki C0 | BEL, BS, HT, LF/VT/FF, CR, SI/SO także wewnątrz ESC/CSI/oznaczeń zestawów; CAN/SUB anuluje, NUL/DEL nie drukuje | Odpowiedź ENQ jest pusta; dalsza macierz C1 i kontrolek w ciągach sterujących |
| Tabulatory | HT, HTS (ESC H), TBC (CSI g, CSI 3 g), CHT (CSI I), CBT (CSI Z), CTC (CSI W: 0/2/4/5), DECST8C (CSI ? 5 W); domyślne co 8 kolumn | Testy porównawcze z VTE przy zmianach geometrii i ekranów |
| Ruch | CUU/CUD/CUF/CUB, CNL/CPL, CHA/HPA, VPA, CUP/HVP, HPR/VPR; pionowy ruch względny respektuje kierunkowe marginesy DECSTBM | Poziome marginesy, dalsze tryby i warianty ruchu |
| Edycja | REP (CSI Ps b), ED/EL, DECSEL/DECSED 0–2 i DECSCA, ICH/DCH/ECH, IL/DL, SU/SD, DECSTBM; ED/EL/ECH i ICH/DCH/IRM oraz zwykłe nadpisywanie naprawiają przecięte szerokie znaki | Selektywne ?3J i prostokąty DEC; poziome marginesy; dalsze przypadki szerokich znaków i reflow |
| Stan | DECOM, DECAWM, IRM, widoczność kursora, DECSC/DECRC, SCOSC/SCORC i 1048 (współrzędne, atrybuty, ochrona komórek, zestawy znaków, origin, autowrap, oczekujące zawinięcie i single shift), RIS i DECSTR; XTSAVE/XTRESTORE dla szesnastu wybranych trybów | Pozostałe tryby prywatne |
| Kursor | Widoczność DECTCEM, DECSCUSR 0–6: preferencje lub blok/podkreślenie/pionowa kreska, warianty migające i stałe; odczyt przez DECRQSS | Dalsza zgodność geometrii z VTE, w tym zewnętrzny obrys i szerokość wystających glifów; wariant xterm 7 nie jest obsługiwany |
| Ekrany | DECALN (ESC # 8), ekran główny i alternatywny, 47/1047/1049, historia i reflow ekranu głównego | Osobna macierz wariantów przełączania i zapisów kursora, przypadki brzegowe reflow |
| SGR | Reset, bold/faint, italic, conceal, strike, overline, inverse; pięć stylów podkreślenia i jego kolor 58/59; miganie 5/6/25; ANSI 16/256 i RGB przez średniki i dwukropki | Dalsze warianty SGR, integracja systemowych preferencji migania i porównanie geometrii dekoracji z VTE |
| Odpowiedzi | DSR 5, CPR 6, DECXCPR ?6 ze stroną 1, raporty DEC ?15/?25/?55/?56; wiersz względem regionu przy DECOM; DA/DECID, DA2 i DA3, DECRQM/DECRPM dla obsługiwanych trybów, rozmiar w znakach CSI 18 t, DECRQSS SGR, marginesów pionowych i pełnego zakresu kolumn, stylu kursora i ochrony komórek | Pozostałe DECRQSS, raporty rozmiaru w pikselach/monitora i pozostałe zapytania |
| OSC i tytuł | 0/2: tytuł, 7: katalog, 8: odnośniki; CSI 22/23 t: stos tytułów okna dla 0/2 | Paleta i zapytania kolorów, osobny tytuł ikony i indeksowane sloty stosu, pozostałe OSC; polityka dostępu do schowka |
| DCS/APC/PM | DCS DECRQSS dla SGR, marginesów, stylu kursora i ochrony komórek; pozostałe DCS/APC/PM/SOS są konsumowane | Pozostałe DCS i dalsze porównania ciągów z VTE |
| Zestawy znaków | UTF-8, ASCII B, brytyjski A, DEC Special Graphics 0 w G0–G3; SI/SO, LS2/LS3, SS2/SS3 | Pozostałe zestawy narodowe, GR i 96-znakowe zestawy, warianty ESC z bajtami pośrednimi |
| Wejście | Application cursor, bracketed paste, niezależne tryby myszy X10 (9) i 1000/1002/1003 z priorytetem, częściowy format UTF-8 1005, SGR 1006, URXVT 1015 i SGR-Pixels 1016, fokus 1004, LNM 20 dla LF/Enter, aplikacyjna klawiatura numeryczna ESC = / ESC > / 66 | Pełna macierz modyfikatorów klawiatury, pozostałe protokoły klawiatury i myszy, klasyczne współrzędne poza ASCII i C1 w formacie 1005 na ConPTY |
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

DECRQM (`CSI mode $ p` / `CSI ? mode $ p`) zwraca DECRPM ze statusem 1 dla włączonego, 2 dla wyłączonego oraz 0 dla nieznanego trybu. Standardowe tryby: 4 i 20. Prywatne: 1, 6, 7, 9, 25, 47/1047/1049, 66, 1000/1002/1003, 1004, 1005, 1006, 1007, 1015, 1016 i 2004. Raporty odzwierciedlają aktualny stan implementacji, nie gwarantują pełnego pokrycia każdego wariantu tych trybów w VTE. Zapytania nie zmieniają oczekującego zawinięcia na prawej krawędzi.

Prywatny tryb 1004 włącza wysyłanie CSI I / CSI O przy WM_SETFOCUS / WM_KILLFOCUS ramki terminala. Raporty trafiają bezpośrednio do wejścia sesji, bez działań właściwych dla pisania, np. usuwania zaznaczenia. Wyłączenie trybu i reset blokują dalsze raporty. LNM (standardowy tryb 20) zmienia LF na początek następnego wiersza oraz Enter z CR na CR LF. Domyślnie jest wyłączony. Klawiaturę numeryczną aplikacyjną i część DECRQSS dodano w etapie 1.0.23.56.

Punkty odniesienia: [Xterm Control Sequences](https://www.xfree86.org/current/ctlseqs.html) i [obsługa sekwencji w VTE](https://github.com/GNOME/vte/blob/master/src/vteseq.cc). Test transportu używa potomnego PowerShell/C# z wejściem konsoli w trybie VT; proces sam włącza raporty fokusu, a test sprawdza dotarcie jego żądania do modelu. Scenariusz wysyła komunikaty fokusu do ramki oraz sprawdza odebrane kody znaków. To weryfikacja drogi parser–sesja–ConPTY i zdarzeń ramki, nie pełny test przełączania rzeczywistych okien na pulpicie.

## DECRQSS i klawiatura numeryczna — 1.0.23.56

DCS $ q m ST zwraca bieżące obsługiwane atrybuty i kolory SGR jako DCS 1 $ r ... m ST. Zapis zaczyna się od resetu 0 i pozwala odtworzyć semantycznie te same atrybuty przez CSI; nie wymaga identycznej kolejności/kodowania jak w VTE. DCS $ q r ST raportuje górny i dolny margines. Nieznany typ żądania otrzymuje DCS 0 $ r ST. Odczyt jest przyrostowy, zachowuje limit 4096 jednostek UTF-16 i odrzuca przekroczone żądanie w całości. CAN/SUB anuluje, a nowy ESC może rozpocząć inne polecenie. Pozostałe rodzaje DCS nadal są ignorowane. Punkt odniesienia: [DECRQSS w VTE](https://github.com/GNOME/vte/blob/master/src/vteseq.cc).

ESC = oraz prywatny tryb 66 włączają klawiaturę numeryczną aplikacyjną; ESC >, reset trybu i RIS ją wyłączają. Cyfry, operatory, separator, kropka i osobny Enter wysyłają sekwencje SS3. Widok rozróżnia rozszerzony bit komunikatu Windows, więc główne strzałki/Enter zachowują swoje znaczenie, a klawisze numeryczne przy wyłączonym Num Lock pozostają klawiszami numerycznymi. WM_CHAR po obsłużonym klawiszu cyfry/operatora/Enter jest konsumowany, aby nie dopisać znaku drugi raz. Rozszerzona macierz Shift/Ctrl/Alt i dodatkowe klawisze rzadkich układów nadal wymagają pracy.

Test natywny rozszerza proces wejścia VT o żądanie klawiatury aplikacyjnej i sprawdza dostarczone odpowiedzi DCS, cyfrę, numeryczny Enter, zwykłą strzałkę, strzałkę z części numerycznej i powrót do zwykłej cyfry. Test modelu odtwarza atrybuty z odpowiedzi DECRQSS i sprawdza nieznane/przerwane/przepełnione żądania.

## Styl kursora i jego odczyt — 1.0.26.59

CSI Ps SP q (DECSCUSR) przyjmuje wartości 0–6. Wartość 0 lub brak parametru przywraca kształt i miganie z preferencji, zgodnie z [wyborem domyślnego kursora w VTE](https://github.com/GNOME/vte/blob/master/src/vte.cc). 1/2 wybiera blok, 3/4 podkreślenie, 5/6 pionową kreskę; nieparzyste wartości migają, parzyste są stałe. Zmiana stylu nie włącza ukrytego kursora ani nie zmienia preferencji INI. Parametry spoza zakresu i błędne warianty składni są ignorowane. Dalszy punkt odniesienia: [DECSCUSR i DECRQSS w VTE](https://github.com/GNOME/vte/blob/master/src/vteseq.cc), [sekwencje xterm](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html).

DCS $q SP q ST odpowiada DCS 1$r Ps SP q ST z bieżącą wartością stylu. Zapytanie i ustawienie nie zmieniają pozycji ani oczekującego zawinięcia. Styl należy do terminala: jest wspólny dla ekranów i nie wchodzi do zapisu DECSC/DECRC; RIS przywraca 0. Odpowiedź przechodzi zwykłą drogą do wejścia ConPTY.

Widok stosuje tę samą funkcję fazy w rysowaniu, cache alfy i odświeżaniu. Jawne miganie ma okres półfazy 500 ms; ustawienie systemowe przy stylu 0 odczytuje GetCaretBlinkTime, również wyłączenie migania. Reset do 0 ponownie udostępnia preferencje. Zmiana stylu odświeża wiersz kursora i usuwa piksele poprzedniego kształtu. Testy porównują alfę kształtów oraz deterministyczne fazy migania, a natywny odbiorca ConPTY sprawdza bajty odpowiedzi. W tej wersji blok pozostawał obrysem GDI; wypełnienie aktywnego bloku dodano w 1.0.35.68. Dalsza geometria wymaga porównań z VTE.

## Przyciski i ruch myszy — 1.0.27.60

Ruch w trybie 1002 obejmuje wszystkie trzy przyciski; 1003 dodatkowo raportuje brak przycisku. Kod ruchu to numer przycisku 0/1/2 albo 3 przy hover, powiększony o 32 i bity modyfikatorów. Klasyczne zwolnienie zachowuje modyfikatory przy zastąpieniu numeru przycisku przez 3; SGR używa numeru przycisku i końcowego m. Punkt odniesienia: [źródło dokumentacji xterm, Mouse Tracking](https://github.com/ThomasDickey/xterm-snapshots/blob/master/ctlseqs.ms).

Shift pozostaje lokalnym obejściem raportowania. Natywny test ConPTY porównuje kody SGR dla prawego, środkowego i lewego przeciągania, hover z modyfikatorami, brak raportu ruchu w 1000 i hover w 1002 oraz klasyczne zwolnienie z Ctrl/Alt. Odbiorca sam zmienia 1006, aby testować rzeczywistą negocjację z ConPTY.

Do 1.0.45.78 tryby 1000/1002/1003 reprezentował jeden aktywny tryb; niezależne bity i priorytet dodano w 1.0.46.79; filtrowanie powtórzeń w tej samej komórce dodano w 1.0.28.61. Od 1.0.29.62 klasyczne współrzędne na ConPTY są ograniczone do zakresu ASCII, a większe obsługuje negocjowany format 1005 lub SGR. Zalecanym obsługiwanym formatem pozostaje SGR 1006; URXVT 1015 dodano w 1.0.49.82; SGR-Pixels 1016 dodano w 1.0.50.83. Pełna macierz protokołów pozostaje do sprawdzenia.

## Filtrowanie raportów i oddzielenie wejścia myszy — 1.0.28.61

Zgodnie z regułą ruchu między komórkami opisaną w [dokumentacji xterm](https://github.com/ThomasDickey/xterm-snapshots/blob/master/ctlseqs.ms), 1002/1003 nie powtarzają raportu dla ruchu wewnątrz zapamiętanej komórki. Przyciski nie są filtrowane. Format i tryb raportowania mają niezależną od tekstu rewizję negocjacji; widok uwzględnia także rozmiar siatki, reset, ponowne podłączenie sesji i lokalne użycie Shift. Dzięki temu nie pomija pierwszego raportu po renegocjacji ani nie resetuje filtra przy każdym fragmencie wyjścia.

Wysyłanie raportów nie usuwa zaznaczenia i nie uruchamia scroll-keystroke. Natywny test ConPTY porównuje pełny strumień wejścia po 200 powtórzeniach ruchu, przejściu do kolejnej komórki, zmianie trybu i geometrii oraz ponownym Bind. Test widoku sprawdza zachowanie zaznaczenia i przewijania. Pozostałe braki formatów opisuje tabela; niezależne bity śledzenia dodano w 1.0.46.79.

## UTF-8 mouse 1005 i granice klasycznego formatu — 1.0.29.62

Tryb 1005 przenosi współrzędne w UTF-8: do pozycji 1–2015 dodawane jest 32. Klasyczny format na tym porcie dopuszcza wyłącznie indeksy 0–94, aby zakodowana współrzędna nie przekraczała ASCII 127. Wymaganie UTF-8 wynika z wybranego formatu, nie jest domyślnie stosowanym rozszerzeniem klasycznego X10. Punkt odniesienia: [xterm, Extended coordinates](https://github.com/ThomasDickey/xterm-snapshots/blob/master/ctlseqs.ms) oraz [ograniczenie klasycznego wejścia Windows Terminal](https://github.com/microsoft/terminal/blob/main/src/terminal/input/mouseInput.cpp).

Bufor rozpoznaje 1005 w DECSET/DECRST i DECRQM; RIS go wyłącza. Każda negocjacja odświeża rewizję formatu dla filtra myszy. Przy obu ustawionych formatach w tej implementacji pierwszeństwo ma 1006. To nie oznacza pełnego odwzorowania nakładania formatów innych terminali.

Test ConPTY ustawia kodowanie wejścia odbiorcy na UTF-8 i negocjuje 1005 z procesu potomnego. W pierwszym przebiegu wartość 128 zniknęła w ścieżce wejścia, podczas gdy 2047 dotarła prawidłowo. Dlatego raporty zawierające C1 (128–159, indeksy 95–126 w dowolnej osi) są w tym porcie pomijane w całości. Jest to jawne ograniczenie częściowo obsługiwanego 1005. Końcowy test sprawdza poprawne wartości 127, 160 i 2047 oraz pominięcie 128. Weryfikuje również pominięcie pozycji poza zakresem oraz powrót do ograniczenia klasycznego po wyłączeniu 1005. SGR jest sprawdzany również dla pozycji 96 i 2016 i nie ma tych luk. Pełne bajtowe X10 do 223, zakres C1 w 1005 pozostają ograniczeniami tej implementacji. SGR-Pixels 1016 dodano w 1.0.50.83. URXVT 1015 dodano w 1.0.49.82.

## Stos tytułów okna — 1.0.30.63

XTWINOPS CSI 22;2 t zapisuje tytuł okna z OSC 0/2, a CSI 23;2 t go przywraca. Pominięty drugi parametr i wartość 0 obsługują ten sam tytuł okna. Parametr 1 (osobna etykieta ikony), trzeci parametr (indeksowany dostęp do slotów) i błędne warianty są ignorowane. Punkt odniesienia: [xterm, XTWINOPS 22/23](https://github.com/ThomasDickey/xterm-snapshots/blob/master/ctlseqs.ms).

Stos LIFO jest ograniczony do 64 wpisów z usuwaniem najstarszego przy przepełnieniu. Pusty wpis jest przywracany, pusty stos nie zmienia tytułu. Stos należy do sesji terminala, jest wspólny dla jej ekranów i przeżywa resize; RIS go czyści. Nie jest częścią trwałego zapisu sesji ani pamięci wznawianego procesu.

Dwa scenariusze DUnitX obejmują każde miejsce podziału sekwencji OSC/CSI, zagnieżdżenie, parametry 0/2 i domyślny, pusty tytuł, podpełnienie i przepełnienie, ignorowane operacje ikon/slotów, niezależność terminali, ekran alternatywny, resize i reset. Sprawdzają także zachowanie oczekującego zawinięcia oraz brak dodatkowych odpowiedzi. Nie zastępuje to pełnego porównania wszystkich operacji tytułów i okna z uruchomionym VTE.

## XTSAVE i XTRESTORE — 1.0.31.64

CSI ? Pm s zapisuje wybrane tryby prywatne, a CSI ? Pm r odtwarza wskazane wartości, zgodnie z jednopoziomowym cache opisanym w [dokumentacji xterm](https://github.com/ThomasDickey/xterm-snapshots/blob/master/ctlseqs.ms). Obsługiwane identyfikatory: 1, 6, 7, 25, 66, 1004, 1005, 1006, 2004. Zapisy true i false są niezależne dla każdego trybu. Powtórny save nadpisuje zapis, a restore bez save niczego nie zmienia. CSI s/u bez prefiksu pozostaje zapisem kursora.

Restore stosuje te same skutki co DECSET/DECRST. Origin powoduje homing w bieżących marginesach i wyłącza oczekujące zawinięcie. Przywrócenie formatu myszy unieważnia filtr raportów tak samo jak bezpośrednia negocjacja. Cache jest osobny dla każdego terminala, wspólny dla jego ekranów i zachowywany po resize; RIS go czyści. Zapisy nie trafiają do pliku sesji.

Dwa nowe scenariusze DUnitX obejmują wartości true/false, nadpisywanie, wiele trybów, wszystkie miejsca podziału sekwencji, błędne parametry, brak zapisu, origin i oczekujące zawinięcie, reset, zmianę rozmiaru, ekrany i niezależność terminali. Rozszerzony natywny odbiornik ConPTY sprawdza efekty przywrócenia fokusu 1004, klawiatury numerycznej 66 i bracketed paste 2004. Śledzenie myszy 1000/1002/1003 dodano do save/restore w 1.0.46.79. Poza zakresem pozostają przełączanie ekranów, zapisy kursora i pozostałe identyfikatory prywatne. Samo rozpoznanie trybu przez DECRQM nie oznacza, że jest już objęty save/restore.

## DECSTR — 1.0.32.65

CSI ! p wykonuje miękki reset w ramach obsługiwanych trybów. Podstawą semantyki zachowania ekranów, historii, pozycji, tabulatorów i stosu tytułów jest [implementacja resetu VTE](https://github.com/GNOME/vte/blob/master/src/vte.cc) oraz [rozdzielenie pozycji i regionu przewijania](https://github.com/GNOME/vte/blob/master/src/vteinternal.hh). RIS i publiczny Reset nadal wykonują twardy reset; wspólna metoda przywraca tryby i atrybuty, rozdzielając zachowanie danych.

DECSTR przywraca obsługiwane domyślne tryby, pełne marginesy, zestawy ASCII, widoczny kursor w stylu 0 i atrybuty dla przyszłych komórek. Wyłącza tryby aplikacyjnego wejścia, myszy, fokusu i bracketed paste, zamyka aktywne OSC 8 dla kolejnych znaków i czyści cache prywatnych trybów oraz oczekujące odpowiedzi. Nie zmienia istniejących komórek, historii, pozycji, tytułu, stosu tytułów ani tabulatorów. Pozostaje w ekranie alternatywnym, jeśli tam wykonano reset. Odświeża zapis kursora na obu ekranach; zachowuje oczekujące zawinięcie przy prawej krawędzi.

Testy obejmują zachowanie danych i starych atrybutów, domyślne atrybuty nowego tekstu, reset obsługiwanych trybów, DECRQSS SGR i marginesów, tabulatory, tytuły, ekrany, pozycje i zapis kursora, zawinięcie, wszystkie podziały sekwencji, CAN i nieobsługiwane warianty. Native ConPTY potwierdza reset wejścia (fokus, keypad, Enter i paste). Nadal wymagane są porównania szerszej macierzy z uruchomionym VTE; tryby, OSC palety i SIXEL nieobecne w emulatorze pozostają niezaimplementowane. Parametryzowane warianty typu CSI 0 ! p są ignorowane; obsługiwane jest dokładne CSI ! p.

## DECSCA, DECSEL i DECSED — 1.0.33.66

DECSCA (CSI Ps " q) przypisuje ochronę znakom drukowanym później: 1 włącza, 0/2 wyłącza. Pusta wartość oznacza 0; nieobsługiwane wartości nie zmieniają stanu. SGR 0 jej nie resetuje. Atrybut jest częścią zapisu DECSC/DECRC i komórek kopiowanych przy reflow. DCS $q "q ST odczytuje aktualny stan jako DCS 1$r 0/1 "q ST. Punkt odniesienia: [xterm, DECSCA i selektywne kasowanie](https://github.com/ThomasDickey/xterm-snapshots/blob/master/ctlseqs.ms).

DECSEL/DECSED 0/1/2 oraz domyślne pomijają chronione znaki; zwykłe ED/EL nie respektują ochrony. Obie ścieżki ED/EL operują całymi znakami, jeżeli krawędź zakresu trafia w kontynuację szerokiej komórki. Ochrona dowolnej części szerokiego znaku chroni cały znak. Komórki wyczyszczone nie dziedziczą ochrony bieżącego DECSCA. Zmiana ochrony nie jest zmianą wyglądu ani blokadą kopiowania/nadpisywania.

DECSTR resetuje przyszłą ochronę, zachowując stare komórki; RIS kasuje zawartość. Selektywne ED nie kasuje scrollbacku i nie jest ograniczone marginesami przewijania. Rozszerzenie ?3J i prostokąty pozostają nieobsługiwane. Testy obejmują wszystkie kierunki ED/EL, parametry i domyślny, fragmentację, odczyt, SGR i zapis kursora, historię, reflow i szerokie znaki. Natywny odbiorca ConPTY potwierdza odpowiedź ochrony. Pełne porównanie z VTE i pozostałe operacje edycji pozostają do wykonania.

## ICH, DCH, ECH i IRM na granicach grafemów — 1.0.34.67

ICH i DCH przesuwają określoną liczbę kolumn, ograniczoną do końca wiersza. Jeżeli granica przecina szeroki znak, cały znak jest zastępowany spacjami przed przesunięciem. Nie zwiększa to liczby przesuwanych kolumn. Na przykład DCH 1 na prowadzącej części `A中BC` pozostawia `A BC`, a nie osieroconą kontynuację. ECH kasuje całe przecięte znaki bez przesuwania. IRM korzysta z tej samej operacji wstawiania kolumn. Punkt odniesienia dla semantyki przesunięć: [ICH/DCH w VTE](https://github.com/GNOME/vte/blob/master/src/vteseq.cc).

Ruch komórek zachowuje ich atrybuty i ochronę, ale sama edycja ignoruje ochronę (nie jest DECSEL/DECSED). Nowe spacje powstają z bieżącymi atrybutami i bez ochrony. Flaga miękkiego zawinięcia jest utrzymywana na ostatniej komórce fizycznego wiersza; stare znaczniki paddingu nie są przesuwane jako tekst.

Testy obejmują cięcie początku i końca szerokiego znaku, odrzucenie znaku przecinającego prawą granicę, oba warianty IRM, kolory i ochronę oraz 768 kombinacji czterech wzorców tekstu, trzech operacji, ośmiu pozycji i ośmiu liczników. Każdy wynik jest sprawdzany pod kątem par prowadząca/kontynuacja; wzorce zawierają też znak łączący. Dalsze porównania z uruchomionym VTE, poziome marginesy i skrajny druk szerokich znaków bez autowrap pozostają do wykonania.

## Wypełnienie aktywnego kursora — 1.0.35.68

Aktywny blok otrzymał pełne wypełnienie kolorem tekstu i glif w kolorze tła komórki, z uwzględnieniem inverse i stylów. Kursor na drugiej części szerokiego znaku obejmuje cały znak. Maska alfy pozostaje nieprzezroczysta na całym bloku; conceal nie odsłania ukrytego tekstu. Test renderowania sprawdza wypełnienie, szeroki znak, granicę następnej komórki i usuwanie poprzedniego kształtu. Nieaktywny kursor dodano w 1.0.36.69. Pełne kształtowanie tekstu i dalsze porównania geometrii z VTE pozostają do wykonania.

## Kursor po utracie fokusu — 1.0.36.69

Widoczny panel bez fokusu zachowuje stały kursor: obrys bloku lub wybraną kreskę/podkreślenie. DECTCEM nadal go ukrywa; ukryte panele i zakończone sesje nie rysują kursora. Zmiana fokusu unieważnia widok i jest osobnym kluczem cache alfy, także gdy widoczność przed i po zmianie pozostaje taka sama. Obrys obejmuje dwie komórki szerokiego znaku i pozostawia zwykły glif wewnątrz.

Punkt odniesienia: [paint_cursor w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vte.cc#L8935). Port rysuje obecnie obrys wewnątrz komórki. VTE rozszerza go na zewnątrz i uwzględnia wystające glify oraz kierunek tekstu; te różnice geometrii, kształtowanie i IME pozostają do zaimplementowania. Nowy scenariusz DUnitX sprawdza przejścia fokusu, szeroki obrys, stałe fazy kursora nieaktywnego, DECTCEM i ukrycie panelu.

## Powtarzanie poprzedniego znaku REP — 1.0.37.70

CSI Ps b powtarza poprzedni znak drukowalny; brak parametru i zero oznaczają jedno powtórzenie. Liczba operacji jest ograniczona do pozostałych kolumn, także dla maksymalnego licznika Integer. Przy oczekującym zawinięciu na pełnym wierszu REP nic nie dopisuje i zachowuje zawinięcie dla następnego zwykłego znaku. Szeroki znak korzysta z normalnej ścieżki wstawiania i może zawinąć się w obrębie tej ograniczonej liczby operacji.

Emulator pamięta kod sprzed mapowania zestawu DEC, korzysta z bieżących atrybutów i IRM. Dołączony akcent nie zastępuje zapamiętanej litery bazowej: po e + U+0301 REP dopisuje e bez akcentu. Nie jest to kopiowanie całej komórki ani całego klastra emoji. Dalsze przypadki złożonych klastrów wymagają porównań z VTE.

Zakończone CSI, OSC/DCS, komendy ESC, oznaczenia zestawów i obsługiwane kontrolki C0 kasują pamięć REP. Samo REP również ją kasuje: kolejne REP bez nowego znaku nie powtarza poprzedniej operacji. NUL i DEL są ignorowane. Reset kasuje pamięć. Prywatne, pośrednie i dwukropkowe warianty REP oraz nadmiarowe parametry nie wykonują powtórzenia.

Punkt odniesienia: [REP w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L6414) oraz [insert_char i zakończenie komend parsera](https://github.com/GNOME/vte/blob/0.76.0/src/vte.cc#L3131). Trzy scenariusze DUnitX obejmują fragmentację, wartości domyślne, limity, oczekujące zawinięcie, Unicode, akcent, DEC Special Graphics, IRM, atrybuty, granice komend i reset. To porównanie źródłowe i testy portu, bez deklaracji pełnego pokrycia VTE/xterm.

## Wzorzec wyrównania ekranu DECALN — 1.0.38.71

Dokładne ESC # 8 wypełnia aktywny ekran literami E w podstawowych atrybutach, bez hiperlinków, ochrony komórek, kontynuacji szerokich znaków i metadanych miękkiego zawinięcia. Przywraca pełne marginesy, wyłącza DECOM, ustawia kursor w lewym górnym rogu i kasuje oczekujące zawinięcie. Pamięć REP nie traktuje liter wzorca jako ostatniego drukowanego znaku.

DECALN zachowuje historię i nieaktywny ekran. Nie resetuje bieżących atrybutów przyszłego tekstu, ochrony DECSCA, trybów wejścia, IRM, tabulatorów ani zapisanego kursora. Punkt odniesienia: [DECALN w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L2335).

Parser rozróżnia teraz dokładny ciąg bajtów pośrednich ESC. Przechowuje najwyżej 256 bajtów; nadmiar konsumuje bez wykonania komendy. ESC # 7, ESC ! 8 i ESC ## 8 nie uruchamiają wzorca. CAN/SUB anuluje sekwencję, a BEL może wykonać się wewnątrz niej bez jej zakończenia. Pozostałe komendy ESC z bajtami pośrednimi nadal wymagają implementacji.

Trzy scenariusze DUnitX sprawdzają wszystkie miejsca podziału sekwencji, podstawowe komórki, marginesy, origin, kursor, zachowanie trybów i historii, ekran alternatywny, anulowanie i odrzucanie innych/za długich sekwencji. Dawny test ignorowanego ESC # 8 używa teraz nieobsługiwanego ESC # 7. Testy portu i przegląd źródeł nie oznaczają pełnej zgodności z działającym VTE.

## Tertiary Device Attributes DA3 — 1.0.39.72

CSI = c i CSI = 0 c (bez spacji w strumieniu) odpowiadają DECRPTUI: DCS ! | 7E474B57 ST. Osiem cyfr szesnastkowych koduje stały identyfikator portu ~GKW. Nie jest to identyfikator komputera ani deklaracja obsługi funkcji VTE; pozostaje jednakowy pomiędzy uruchomieniami i wersjami portu. Sekwencje DA1 i DA2 zachowują dotychczasowe odpowiedzi.

Zapytanie zachowuje komórki, atrybuty, pozycję kursora i oczekujące zawinięcie. Niezerowe parametry, nadmiarowe parametry, dwukropki, bajty pośrednie i prefiks = z inną komendą są ignorowane. Odbicie odpowiedzi DCS do parsera nie wyświetla jej treści ani nie generuje kolejnej odpowiedzi.

Punkt odniesienia: [DA3 w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L2192). Dwa nowe scenariusze DUnitX obejmują wszystkie podziały zapytania, domyślny/zerowy parametr, zawinięcie, stan i odrzucanie błędnych wariantów. Rozszerzony test natywnego odbiornika ConPTY sprawdza bajty DECRPTUI przesłane do procesu. Pozostałe zapytania i pełna zgodność emulatora nadal wymagają pracy.

## Względny ruch pionowy i marginesy DECSTBM — 1.0.40.73

CUU (CSI A), CUD (CSI B), VPR (CSI e), CNL (CSI E) i CPL (CSI F) respektują marginesy także przy wyłączonym DECOM. Ruch w górę z pozycji na górnym marginesie lub poniżej niego zatrzymuje się na tym marginesie; z pozycji nad nim dochodzi do górnej krawędzi ekranu. Ruch w dół działa symetrycznie względem dolnego marginesu i dolnej krawędzi. Kursor rozpoczynający poza regionem może wejść do niego.

CNL/CPL ustawiają dodatkowo pierwszą kolumnę; pozostałe komendy zachowują kolumnę. Ruch anuluje oczekujące zawinięcie, nie przewija ekranu i nie zmienia zawartości komórek ani historii. Domyślny i zerowy licznik oznacza jeden; duże liczniki są ograniczane geometrią ekranu. DECOM nadal ogranicza pozycję do regionu, a ruchy bezwzględne zachowują swoje odrębne reguły.

Punkt odniesienia: [move_cursor_up/down w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L833). Dwa scenariusze DUnitX obejmują macierz 140 kombinacji pozycji/komend/liczników, fragmentację, DECOM, wartości domyślne, oczekujące zawinięcie i niezmienność tekstu/historii. Poziome marginesy i pozostałe różnice ruchu pozostają do wykonania.

## IL/DL, Reverse Index i oczekujące zawinięcie — 1.0.41.74

Wstawianie/usuwanie wierszy (CSI L/M) wewnątrz regionu DECSTBM ustawia pierwszą kolumnę i kasuje oczekujące zawinięcie. Przesuwa tylko wiersze od pozycji kursora do dolnego marginesu. Poza regionem komenda pozostaje ignorowana i zachowuje kolumnę oraz oczekujące zawinięcie dla kolejnego znaku. Wcześniej kolumna nie była zerowana podczas operacji, a zawinięcie było kasowane również poza regionem.

Reverse Index (ESC M) kasuje oczekujące zawinięcie zarówno przy ruchu w górę, jak i przewijaniu w dół na górnym marginesie. Zachowuje kolumnę, również przy włączonym LNM. Wiersze poza przewijanym regionem pozostają bez zmian; RI nie dopisuje scrollbacku.

Punkt odniesienia: [IL w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L5741), [DL](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L4763) i [RI](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L6436). Trzy scenariusze DUnitX sprawdzają IL/DL na siedmiu pozycjach, zawartość wszystkich wierszy, zachowanie zawinięcia poza regionem oraz RI na siedmiu pozycjach przy każdym podziale sekwencji. Dalsze przypadki przewijania, historii i poziomych marginesów pozostają do porównania z VTE.

## Nadpisywanie szerokich znaków i prawa krawędź — 1.0.42.75

Drukowanie nowego znaku usuwa fragmenty dawnych szerokich znaków przecinające lewą lub prawą granicę nadpisywanego obszaru. Obejmuje to szeroki znak pokrywający fragmenty dwóch starych znaków. Poszerzenie grafemu z jednej do dwóch komórek, np. po selektorze prezentacji emoji, usuwa również osieroconą kontynuację sąsiada.

Przy wyłączonym DECAWM szeroki znak drukowany w ostatniej kolumnie cofa się o kolumnę, aby zmieścić się w całości, także w IRM. Nie przewija ekranu ani nie tworzy paddingu zawinięcia. Jest to zachowanie VTE; xterm może taki znak pominąć. Włączony autowrap nadal przenosi cały szeroki znak do nowego wiersza.

Nadpisanie końca wcześniej zawiniętego wiersza i poszerzenie grafemu zachowują znacznik SoftWrapped w ostatniej fizycznej komórce. Nadpisany techniczny padding jest usuwany. Trzy scenariusze DUnitX obejmują obie granice, sąsiednie szerokie znaki, selektor prezentacji, IRM, DECAWM i metadane wiersza.

Punkt odniesienia: [insert_char w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vte.cc#L3024). Pełna segmentacja, kształtowanie, przypadki jednokolumnowego terminala i dalsze porównania reflow pozostają odrębnymi ograniczeniami portu.

## Historia i granice przewijania — 1.0.43.76

Przewijanie w górę na ekranie głównym dopisuje opuszczające ekran wiersze do historii zawsze, gdy region zaczyna się na górnej krawędzi, również przy dolnym marginesie przed końcem ekranu. Dotyczy wspólnej ścieżki SU, DL i przewijania po LF/IND. Limit historii i jej wyłączenie nadal obowiązują; ekran alternatywny nie dopisuje historii.

Przy przewijaniu częściowego regionu rozłączane są miękkie zawinięcia na granicach nowego układu. Ruch w górę rozłącza górną/dolną granicę przed przesunięciem; ruch w dół po przesunięciu. Nienaruszone połączenia wewnątrz przesuwanych wierszy pozostają zachowane. Pełnoekranowy ruch w górę zachowuje połączenie historii z ekranem, a ruch w dół je przerywa. Operacje ekranu alternatywnego nie zmieniają metadanych historii głównej. Techniczny padding usuniętego zawinięcia przestaje być paddingiem.

Punkt odniesienia: [scroll_text_up/down w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vte.cc#L2533). Trzy scenariusze DUnitX sprawdzają historię częściowego regionu dla SU i DL, zawartość wierszy poza regionem, granice i wnętrze zawinięć, limity historii oraz izolację alternatywnego ekranu. Poziome marginesy, dalsze przypadki reflow i długie sesje nadal wymagają pracy.

## Tabulacja i oczekujące zawinięcie — 1.0.44.77

HT (C0 TAB) i CHT (CSI I) nie kasują oczekującego zawinięcia po zapełnieniu wiersza. Nie przesuwają wtedy kursora; kolejny znak zawija się normalnie zamiast nadpisywać ostatnią kolumnę. Dotyczy również niestandardowego przystanku w ostatniej kolumnie, licznika domyślnego, zera i bardzo dużego licznika.

CBT (CSI Z) nadal kasuje oczekujące zawinięcie i przechodzi do wcześniejszego przystanku. Przy wyłączonym DECAWM tabulacja w przód nie tworzy zawinięcia; druk przy prawej krawędzi zachowuje dotychczasową regułę nadpisania.

Punkt odniesienia: [move_cursor_tab_forward/backward w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L934). Dwa scenariusze DUnitX obejmują wszystkie podziały sprawdzanych sekwencji CHT, HT, przystanki niestandardowe, CBT i DECAWM. Smart tabs VTE (kopiowanie tabulatora jako znaku zamiast spacji) oraz poziome marginesy pozostają niezaimplementowane.

## Prywatne raporty DEC i strona kursora — 1.0.45.78

DECXCPR odpowiada teraz na CSI ? 6 n pełnym raportem CSI ? wiersz ; kolumna ; 1 R (bez spacji w strumieniu). Ostatnie pole oznacza jedyną stronę terminala. Wiersz nadal uwzględnia DECOM, a standardowe CPR (CSI 6 n) pozostaje raportem dwóch współrzędnych. Zapytania nie zmieniają pozycji ani oczekującego zawinięcia.

Dodane prywatne raporty DSR:

- CSI ? 15 n → CSI ? 13 n: terminal nie ma interfejsu drukarki.
- CSI ? 25 n → CSI ? 21 n: klawisze UDK są zablokowane; port nie obsługuje ich programowania.
- CSI ? 55 n → CSI ? 53 n: brak lokalizatora DEC.
- CSI ? 56 n → CSI ? 57 ; 0 n: typ lokalizatora DEC nieznany.

Są to informacje o funkcjach protokołu terminala, nie o drukarkach Windows ani dostępności myszy. Raportowanie myszy xterm/SGR pozostaje niezależne. Nowe zapytania przyjmują jeden parametr; inne warianty są ignorowane. Odbicie odpowiedzi nie uruchamia kolejnego raportu.

Punkt odniesienia: [DSR_DEC w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L4880). Dwa scenariusze DUnitX sprawdzają fragmentację, stronę raportu, origin, zawinięcie i odrzucanie błędnych wariantów. Rozszerzony natywny odbiornik ConPTY porównuje bajty czterech raportów statusu. Pozostałe raporty DEC i pełna zgodność emulatora wymagają dalszych prac.

## Niezależne tryby śledzenia myszy — 1.0.46.79

Tryby 1000 (przyciski), 1002 (ruch z przyciskiem) i 1003 (dowolny ruch) mają niezależne bity DECSET/DECRST. Efektywny protokół wynika z priorytetu 1003 → 1002 → 1000. Włączenie niższego trybu nie zastępuje wyższego; wyłączenie wyższego przywraca wcześniej włączony niższy. Wyłączenie nieaktywnego trybu nie wyłącza pozostałych.

DECRQM raportuje każdy bit, a nie tylko aktywny protokół. XTSAVE/XTRESTORE zapisuje i przywraca te trzy bity niezależnie, także wartości false; w tym etapie zakres zapisu obejmował dwanaście identyfikatorów; bieżący zakres opisuje nowsza sekcja poniżej. RIS i DECSTR kasują bity i ich zapis. Negocjacja nadal unieważnia filtr raportów tej samej komórki, więc pierwszy raport po zmianie protokołu nie ginie.

Punkt odniesienia: [update_mouse_protocol w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L392). Dwa nowe scenariusze DUnitX sprawdzają osiem kombinacji bitów, ich raporty, wyłączanie, fragmentację save/restore i reset. Natywny odbiornik ConPTY weryfikuje powrót z 1003 do 1002 i 1000 wraz z rzeczywistym ruchem myszy. X10 dodano w 1.0.47.80. URXVT 1015 dodano w 1.0.49.82. SGR-Pixels 1016 dodano w 1.0.50.83. Highlight nadal wymaga implementacji.

## Tryb myszy X10 — 1.0.47.80

DECSET/DECRST 9 steruje niezależnym bitem X10. Jest to najniższy priorytet śledzenia: 1003 → 1002 → 1000 → 9. Po wyłączeniu wyższych trybów aktywny X10 zostaje przywrócony. DECRQM raportuje jego własny bit, a XTSAVE/XTRESTORE zapisuje true i false; zakres zapisu obejmował wówczas trzynaście identyfikatorów; URXVT 1015 zwiększył go do czternastu w 1.0.49.82. RIS i DECSTR kasują stan oraz zapis X10.

Widok wysyła naciśnięcia bez bitów modyfikatorów, a pomija ruch i zwolnienie przycisku. Shift nadal umożliwia lokalną obsługę terminala. Format współrzędnych pozostaje negocjowany osobno: klasyczny, częściowy UTF-8 1005 lub SGR 1006. Ograniczenia zakresu klasycznego formatu na ConPTY pozostają bez zmian.

Punkt odniesienia: [priorytet protokołów w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L392), [zdarzenia i modyfikatory](https://github.com/GNOME/vte/blob/0.76.0/src/vte.cc#L5575). Dwa scenariusze DUnitX sprawdzają stan, priorytet, save/restore, fragmentację i reset. Natywny odbiornik ConPTY porównuje naciśnięcia w klasycznym i SGR oraz brak ruchu/zwolnienia i modyfikatorów. URXVT 1015 dodano w 1.0.49.82. SGR-Pixels 1016 dodano w 1.0.50.83. Highlight i dalsze porównania protokołów nadal wymagają pracy.

## Mysz na przewiniętej historii — 1.0.48.81

Zdarzenia myszy nad scrollbackiem nie są wysyłane do procesu terminala. Raporty dotyczą wyłącznie aktywnego ekranu, a numer wiersza jest liczony względem jego początku, nie początku przewiniętego widoku. Jeśli u góry widoku jest jeden wiersz historii, pierwszy widoczny wiersz aktywnego ekranu raportuje wiersz 1, a nie 2. Powrót wskaźnika z historii unieważnia filtr poprzedniej komórki.

Przy włączonym śledzeniu myszy historia nadal pozwala lokalnie kliknąć, zaznaczyć słowo dwuklikiem, przeciągnąć zaznaczenie i przewijać kółkiem. Zaznaczenie rozpoczęte w historii może zakończyć się nad aktywnym ekranem bez wysłania zwolnienia do procesu. Shift nadal wymusza lokalną obsługę także nad aktywnym ekranem.

Punkt odniesienia: [feed_mouse_event w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vte.cc#L5575). Nowy scenariusz DUnitX sprawdza lokalne zaznaczenie i kółko. Rozszerzony natywny odbiornik ConPTY potwierdza brak raportów dla historii, współrzędne pierwszego aktywnego wiersza po przewinięciu i pierwszy raport po powrocie z historii. Dalsze porównania menu i zachowania przy zmianie zawartości podczas przeciągania pozostają do wykonania.

## Format myszy URXVT 1015 — 1.0.49.82

DECSET/DECRST 1015 negocjuje dziesiętny format URXVT niezależnie od trybu śledzenia. Raport ma postać CSI Cb ; Cx ; Cy M: Cb zawiera kod przycisku powiększony o 32, a współrzędne są od 1. Zwolnienie używa kodu 3 z zachowaniem bitów modyfikatorów i końcowego M. Format nie ma limitu 95/2015 ani luk C1 istniejących w ścieżce klasycznej i częściowym 1005 portu; nadal obowiązuje geometria terminala.

Gdy 1016 jest wyłączony, przy kilku bitach kodowania włączonych jednocześnie port wybiera SGR 1006, następnie URXVT 1015, potem UTF-8 1005 i format klasyczny. Wyłączenie wyższego formatu przywraca włączony niższy. Jest to jawny priorytet tej implementacji, nie deklaracja jednakowego zachowania wszystkich terminali. Samo kodowanie nie włącza śledzenia.

DECRQM raportuje 1015, XTSAVE/XTRESTORE obsługuje true i false, a RIS/DECSTR kasują stan i zapis. Zmiana 1015 unieważnia filtr ruchu w tej samej komórce. W tym etapie zakres save/restore obejmował czternaście identyfikatorów; 1016 zwiększa go do piętnastu.

Punkt odniesienia: [URXVT w dokumentacji xterm](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Extended-coordinates). Dwa scenariusze DUnitX sprawdzają fragmentację, raporty trybów, niezależność, save/restore i reset. Natywny odbiornik ConPTY porównuje kolumnę 2016, modyfikatory, zwolnienie i priorytet/przywracanie SGR oraz URXVT. SGR-Pixels 1016 dodano w 1.0.50.83; dalsze porównania protokołów pozostają do wykonania.

## Raporty myszy w pikselach SGR-Pixels 1016 — 1.0.50.83

DECSET/DECRST 1016 włącza pikselowe współrzędne raportów SGR, niezależnie od bitu 1006. Format używa CSI < przycisk ; x ; y M/m. Pozycje są od 1 względem obszaru komórek aktywnego ekranu, bez czteropikselowego marginesu widoku. Przy przewiniętej historii uwzględnione jest przesunięcie do aktywnego ekranu; zdarzenia historii nadal pozostają lokalne. Pozycja jest ograniczana do obszaru komórek.

Priorytet kodowania w porcie: piksele 1016 → SGR 1006 → URXVT 1015 → UTF-8 1005 → klasyczny. Sam bit kodowania nie włącza śledzenia. DECRQM raportuje 1016, save/restore zachowuje true i false, RIS/DECSTR kasują stan i zapis. W tej wersji zakres save/restore obejmował piętnaście identyfikatorów; 1007 zwiększa go do szesnastu w 1.0.51.84.

Filtr powtórzeń porównuje w tym trybie piksele, więc ruch wewnątrz jednej komórki generuje nowy raport, a powtórzenia tego samego piksela są pomijane. Po wyłączeniu 1016 wraca porównywanie komórek. Zmiana formatu unieważnia filtr.

Punkt odniesienia: [SGR-Pixels w dokumentacji xterm](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Extended-coordinates). Dwa scenariusze DUnitX obejmują negocjację, niezależne flagi, fragmentację, save/restore i reset. Natywny odbiornik ConPTY sprawdza ruch co piksel, tłumienie duplikatów, zwolnienie, priorytet i powrót do komórek oraz współrzędne przy przewiniętej historii. Dalsze testy DPI, skalowania fontów i highlight tracking pozostają do wykonania.

## Alternate Scroll Mode 1007 — 1.0.51.84

Na ekranie alternatywnym włączony tryb 1007 zamienia kółko na sekwencje strzałek góra/dół, jeśli raportowanie myszy nie przejęło zdarzenia. W stanie domyślnym i po RIS/DECSTR tryb jest włączony, jak w VTE. DECSET/DECRST steruje nim niezależnie od wyboru ekranu i trybów myszy; DECRQM raportuje stan, a XTSAVE/XTRESTORE zapisuje true i false. Obsługiwany zakres zapisu obejmuje szesnaście trybów.

Sekwencje korzystają z tego samego kodowania co klawiatura: zwykłe CSI A/B, aplikacyjne SS3 A/B przy DECCKM oraz parametry Alt/Ctrl. Jeden odebrany impuls kółka wysyła ceil(liczba_wierszy/10) strzałek, co najmniej jedną. Raportowanie myszy ma pierwszeństwo. Shift zachowuje lokalne przewijanie, a zerowy WheelDelta nie powoduje wejścia. Ekran główny nadal przewija historię lokalnie.

Punkt odniesienia: [kółko na ekranie alternatywnym w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vte.cc#L9373), [domyślny tryb 1007](https://github.com/GNOME/vte/blob/0.76.0/src/modes.py#L1106) i [Alternate Scroll w xterm](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Wheel-mice). Dwa scenariusze DUnitX sprawdzają fragmentację, domyślny stan, zapis i reset. Natywny odbiornik ConPTY negocjuje DECCKM z procesu potomnego i porównuje strzałki normalne/aplikacyjne, modyfikatory, pierwszeństwo myszy i brak wejścia po wyłączeniu 1007 lub przy Shift/zerowej delcie. Akumulację częściowych delt i kilku skoków w jednym zdarzeniu dodano w 1.0.52.85 (opis poniżej).

## Częściowe ruchy kółka — 1.0.52.85

Widok sumuje dodatnie i ujemne delty zgodnie z progiem Windows `WHEEL_DELTA = 120`. Niepełny ruch pozostaje w akumulatorze; zmiana kierunku odejmuje go, a delta ±240 wykonuje dwa skoki. Dotyczy to historii, raportów myszy oraz strzałek Alternate Scroll. Każdy skok zachowuje dotychczasową liczbę przewijanych wierszy lub strzałek. Zerowa delta nie wysyła wejścia.

Akumulator jest zerowany po przypięciu sesji i zmianie rozmiaru. Zmiana odbiorcy (historia, aplikacja, Alternate Scroll), modyfikatorów, ekranu, DECCKM lub rewizji protokołu myszy odrzuca resztę przy kolejnym ruchu. Zapobiega to dokończeniu ruchu rozpoczętego w innym kontekście. To przewijanie skokowe z akumulacją precyzyjnego kółka, bez animacji przewijania pikselowego.

Test odbiornika ConPTY porównuje dokładne sekwencje dla delt częściowych, przeciwnych i wielokrotnych, a scenariusz historii sprawdza brak przewijania przed osiągnięciem progu. Punkt odniesienia: [obsługa kółka w Windows](https://learn.microsoft.com/en-us/windows/win32/learnwin32/other-mouse-operations).

## Oczekujące zawinięcie ukrytego ekranu głównego — 1.0.53.86

Powrót z ekranu alternatywnego przywraca zapamiętany stan oczekującego zawinięcia ekranu głównego. Dla 47/1047 pełny ostatni wiersz nie traci tego stanu: następny znak przechodzi do nowego wiersza zamiast nadpisywać prawą komórkę. Tryb 1049 nadal przywraca pełny stan zapisany przez DECSC.

Zmiana szerokości podczas wyświetlania ekranu alternatywnego przekazuje oczekujące zawinięcie ukrytego ekranu głównego do reflow i zachowuje wynik mapowania. Testy obejmują powrót po 47/1047/1049 bez zmiany rozmiaru oraz zwężenie z 6 do 3 kolumn w 47/1047. Nie oznacza to ukończenia całej macierzy ekranów: zachowanie zawartości i czyszczenia w poszczególnych wariantach nadal wymaga osobnych prac. Mapowanie zapisu DECSC ekranu głównego, w tym powrotu z 1049, dodano w 1.0.54.87 (opis poniżej).

## Reflow zapisanego kursora ekranu głównego — 1.0.54.87

Reflow przelicza teraz dwie pozycje: bieżący kursor oraz zapis DECSC ekranu głównego (współdzielony z CSI s/u i 1048). Mapowanie obejmuje kolumnę, wiersz i oczekujące zawinięcie. Działa też przy ukrytym ekranie głównym, dlatego powrót przez 1049 korzysta z pozycji przeliczonej do nowej szerokości. Pozycja poza nowym widocznym ekranem jest ograniczana do jego granic.

Zapisany kolor, atrybuty, zestawy znaków i tryby nie są zastępowane stanem bieżącego kursora. Zapis w pustej części wiersza lub poniżej ostatniego tekstu uczestniczy w ustalaniu zakresu reflow. Testy sprawdzają zwężenie pełnego wiersza z 6 do 3 kolumn po DECSC i przy aktywnym 1049, a także niezależność bieżącego kursora i zachowanie koloru oraz DEC Special Graphics po DECRC.

Pozostają dalsze przypadki mapowania przy obcinaniu historii, szerokich grafemach i marginesach oraz pełna macierz ekranów alternatywnych. Ta zmiana nie dodaje reflow ekranu alternatywnego; jest on nadal przycinany lub rozszerzany jako siatka.

## Szerokie znaki przy przycinaniu ekranu alternatywnego — 1.0.55.88

Zwężenie siatki ekranu alternatywnego usuwa widoczną część szerokiego znaku, jeśli jego komórka kontynuacji wypada poza nową prawą krawędzią. Wcześniej pozostawał samotny początek znaku bez drugiej komórki. Ponowne poszerzenie nie odtwarza przyciętej zawartości. Znaki mieszczące się w całości zachowują tekst, kontynuację i atrybuty.

Dwa scenariusze DUnitX obejmują CJK i emoji przy szerokościach 1–4 kolumn, poszerzenie po przycięciu, zachowanie całego znaku na krawędzi i jego koloru oraz niezależność zawartości ekranu głównego. To naprawa integralności siatki; ekran alternatywny nadal nie ma reflow. Pozostają pełna macierz 47/1047/1049 i porównania renderowania z VTE. Ograniczanie zapisu kursora alternatywnego do zmienionej siatki dodano w 1.0.56.89 (opis poniżej).

## Zapis kursora ekranu alternatywnego po zmianie rozmiaru — 1.0.56.89

Zmiana rozmiaru ogranicza zapisane współrzędne DECSC ekranu alternatywnego do nowej siatki. Po zwężeniu i ponownym poszerzeniu DECRC nie przywraca już pozycji z obszaru, który został przycięty. Dotyczy to również wspólnego zapisu używanego przez CSI s/u i 1048. Kolory, atrybuty i tryby zapisu pozostają zachowane.

Zapisane oczekujące zawinięcie pozostaje aktywne tylko wtedy, gdy zapisana kolumna nadal odpowiada prawej krawędzi. Zwężenie usuwa nieaktualne zawinięcie, a zmiana samej wysokości je zachowuje. Dwa scenariusze DUnitX sprawdzają zwężenie i poszerzenie obu wymiarów, pozycję odtworzenia, kolor oraz drukowanie po odtworzeniu z zawinięciem i bez niego.

Ekran alternatywny nadal jest przycinany jako siatka, bez reflow. Pełna macierz mieszanych przełączeń 47/1047/1049, czyszczenia i wielokrotnych zapisów oraz porównania z uruchomionym VTE pozostają do wykonania.

## Granica historii po ED 1 — 1.0.57.90

Zwykłe `CSI 1 J` (kasowanie od początku ekranu do kursora) przerywa logiczne połączenie ostatniego wiersza historii z ekranem. Usuwa na tej granicy znaczniki miękkiego zawinięcia i wypełnienia przed szerokim znakiem. Nie usuwa tekstu historii ani nie przesuwa kursora. Nowy tekst nie jest przez to sklejany z dawnym akapitem podczas kopiowania i reflow.

Testy obejmują ASCII, zawinięcie przed CJK, podawanie sekwencji znak po znaku, odczyt logicznego wiersza i zmianę szerokości po kasowaniu. Kasowanie na ekranie alternatywnym pozostawia połączenia ukrytej historii głównej bez zmian. Selektywne DECSED `CSI ? 1 J` nie otrzymuje tej zmiany; jego dalsza macierz ochrony i granic akapitów pozostaje osobnym zadaniem.

Punkt odniesienia: [clear_above_current w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L287), gdzie kasowanie powyżej kursora zamyka miękkie zawinięcie wiersza nad obszarem zapisu. Pełne zachowanie ED 2 i pozostałych wariantów kasowania nadal wymaga dalszych porównań.

## EL 0 na pełnym wierszu — 1.0.58.91

Zwykłe `CSI K` i `CSI 0 K` zachowują oczekujące zawinięcie po zapełnieniu wiersza. Kursor logicznie znajduje się wtedy za prawą krawędzią: kasowanie nie usuwa ostatniego znaku ani jego komórki kontynuacji i nie zmienia tła tej komórki. Kolejny znak przechodzi do następnego wiersza. Zwykłe EL 0 zamyka też istniejące miękkie połączenie kasowanego wiersza z następnym, zgodnie z VTE.

To świadome zachowanie VTE, różniące się w tym przypadku od ścisłej emulacji xterm. Punkt odniesienia: [clear_to_eol w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L670). EL 1, EL 2 i selektywne DECSEL nadal anulują oczekujące zawinięcie; jawne przesunięcie kursora na ostatnią kolumnę pozwala zwykłemu EL 0 wymazać znak w tej kolumnie.

Dwa scenariusze DUnitX obejmują ASCII i CJK, sekwencje podawane znak po znaku, oba zapisy EL 0, zachowanie tła i następnego drukowanego znaku, tekst logicznego akapitu oraz pozostałe warianty kasowania. Pełne porównanie kasowania, ochrony komórek i granic akapitów pozostaje do dalszych prac.

## ECH zachowuje granicę zawiniętego akapitu — 1.0.59.92

`CSI Ps X` zastępuje komórki spacjami, zachowując miękkie połączenie bieżącego wiersza z następnym. Wcześniej wymazanie ostatniej komórki usuwało także znacznik akapitu i wprowadzało dodatkowy podział podczas kopiowania oraz reflow. Ochrona integralności szerokiego znaku pozostaje aktywna: kasowanie jego kontynuacji usuwa cały znak.

Wymazanie wypełnienia przed zawiniętym CJK zamienia je w zwykłą spację, zachowując połączenie wierszy. ECH nadal nie przesuwa kursora i anuluje oczekujące zawinięcie pełnego wiersza. Testy sprawdzają ASCII, CJK, domyślny parametr, zero, duży zakres, fragmentację sekwencji, tło wymazanych komórek, kopiowany tekst i reflow.

Punkt odniesienia: [erase_characters w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L794), które wymienia komórki bez zamykania miękkiego połączenia wiersza. Dalsza macierz kasowania i selektywnej ochrony oraz pełna zgodność renderowania pozostają do wykonania.

## CTC — sterowanie tabulatorami — 1.0.60.93

Zwykłe `CSI W` i `CSI 0 W` ustawiają przystanek w bieżącej kolumnie, `CSI 2 W` usuwa go, a `CSI 4 W` i `CSI 5 W` usuwają wszystkie przystanki. Współdzielą stan z HT, HTS, TBC i DECST8C. CTC nie przesuwa kursora ani nie anuluje oczekującego zawinięcia; przy pełnym wierszu korzysta z widocznej ostatniej kolumny.

Zgodnie z VTE opcje przystanków wierszowych 1/3/6 są ignorowane. Używany jest pierwszy parametr polecenia. Prywatne `CSI ? 5 W` pozostaje odrębnym DECST8C, przywracającym domyślne tabulatory co osiem kolumn. Testy sprawdzają domyślny i jawny parametr zero, fragmentację, ustawienie i usunięcie przystanku, oba warianty wyczyszczenia wszystkich oraz zachowanie zawinięcia i ignorowanie opcji wierszowych.

Punkt odniesienia: [CTC w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L1831). Smart tabs zachowujące znak tabulacji podczas kopiowania i pełna macierz tabulatorów przy zmianach geometrii pozostają do wykonania.

## DECRQSS — odczyt poziomego zakresu — 1.0.61.94

Żądanie `DCS $q s ST` otrzymuje odpowiedź `DCS 1$r 1;Ns ST`, gdzie N jest aktualną liczbą kolumn. Terminal nie obsługuje jeszcze ustawiania poziomych marginesów, więc raportuje pełną szerokość. Raport aktualizuje się po zmianie rozmiaru i działa na obu ekranach bez zmiany pozycji kursora, tekstu ani oczekującego zawinięcia.

Identyfikator musi być dokładnie `s`; parametry, prefiksy i dodatkowe bajty pośrednie otrzymują negatywną odpowiedź DECRQSS. Testy sprawdzają fragmentację, zmianę szerokości, ekran alternatywny, zachowanie zawinięcia i odrzucanie niepoprawnych żądań. Natywny odbiornik ConPTY porównuje dokładną odpowiedź dostarczoną procesowi potomnemu.

Punkt odniesienia: [DECRQSS DECSLRM w VTE 0.76.0](https://github.com/GNOME/vte/blob/0.76.0/src/vteseq.cc#L3531). Sam raport nie oznacza implementacji DECLRMM/DECSLRM ani przesuwania i edycji w poziomych marginesach; te funkcje pozostają do wykonania.
