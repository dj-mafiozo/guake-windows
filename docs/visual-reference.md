# Wzorzec interfejsu Guake

Wzorzec: oryginalny Guake 3.9.1.dev0 uruchomiony na Manjaro w VirtualBox. Zrzuty przekazane przez użytkownika 14 listopada 2026 uzupełniają lokalne źródła `../guake/guake/data/prefs.glade`, `prefs.py`, `menus.py` i `dialogs.py`.

## Preferencje

Nagłówek zawiera oryginalną ikonę, tytuł właściwości Guake i opis. Po lewej znajduje się dziewięć kategorii: Ogólne, Główne okno, Powłoka, Przewijanie, Wygląd, Skróty klawiszowe, Szybkie otwieranie, Zaczepy i Zgodność. Zawartość zmienia się po prawej, a przycisk Zamknij pozostaje na dole po prawej. W porcie pasek boczny jest kontrolką VCL zdefiniowaną w DFM; istniejące strony przechowują kontrolki i powiązania ustawień.

Wnętrza stron wymagają jeszcze dalszego dopasowania odstępów, grupowania i proporcji do zrzutów. Natywne kontrolki, czcionki i kolory systemowe Windows różnią się od motywu GTK Manjaro. Przejście testów nie oznacza zgodności piksel w piksel.

## Pasek i menu kart

Jasny pasek kart ma przyciski nowej karty i listy otwartych kart po prawej. Lista powstaje z bieżących sesji, wskazuje aktywną kartę i wybiera po jej trwałym identyfikatorze. Windows używa natywnego menu zamiast popovera GTK z trójkątnym wskaźnikiem.

Menu karty: Nowa karta, Zmień nazwę, Przywróć niestandardowe kolory, Zamknij. Reset indywidualnych kolorów pozostaje nieaktywny, dopóki port nie przechowuje palety dla konkretnej karty.

Menu terminala zachowuje kolejność kopiowania i wklejania, pełnego ekranu, podziałów, zamknięcia terminala, zapisu zawartości, resetu, integracji odnośników i Quick Open oraz preferencji, informacji i zakończenia programu. Zapis zawartości korzysta z dialogu DFM w `Src/DataModules`. Integracje odnośników, wyszukiwania internetowego i Quick Open pozostają nieaktywne do implementacji ich obsługi.

Menu tray zawiera nową kartę, zapis i przywracanie kart, preferencje, informacje i zakończenie. Zapis i odtwarzanie sesji są widoczne jako nieaktywne polecenia; dodanie pozycji menu nie oznacza ukończenia tych funkcji.

## O programie i potwierdzenia

Okno informacji jest zwarte. Zachowuje logo, nazwę, wersję portu, opis, odnośnik i oryginalne prawa autorskie oraz wymagane wpisy portu Windows. Przyciski Zasługi i Licencja rozwijają panel od dołu. Kontrolki i timer animacji należą do DFM; animacja zmienia jedynie stan i granice istniejącego panelu. GPL i autorzy pozostają osobnymi widokami.

Zmiana nazwy karty to pojedyncze pole tekstowe z Anuluj i OK. Potwierdzenie zamknięcia pokazuje pytanie, pogrubione podsumowanie działających procesów i kart oraz przyciski Nie i Tak. Lista procesów zachowuje możliwość przewijania przy większej liczbie sesji.

## Weryfikacja

Scenariusze DUnitX sprawdzają przechodzenie między kategoriami, obecność oryginalnej ikony, stany animowanego panelu, zachowanie praw autorskich i GPL, kontekst poleceń oraz wybór karty przez jej identyfikator. Podglądy stron preferencji znajdują się w `bin/tests/preferences-preview`. Ostateczna zgodność wizualna i płynność animacji wymagają także obserwacji interaktywnej aplikacji Windows.
