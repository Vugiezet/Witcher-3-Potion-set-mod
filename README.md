# Witcher 3: Potion Set

Modyfikacja do gry Wiedźmin 3: Dziki Gon (Next-Gen 4.00+), która dodaje możliwość skonfigurowania w ekwipunku dwóch zestawów eliksirów (do 4 mikstur w każdym) i szybkiego ich wypijania w trakcie rozgrywki jednym skrótem klawiszowym, z zachowaniem mechaniki toksyczności.

---

## Cel moda

W podstawowej wersji gry Geralt ma do dyspozycji cztery sloty szybkiego dostępu na eliksiry i jedzenie. Zmiana przygotowanych mikstur podczas walki wymaga pauzowania gry i ręcznego przekładania przedmiotów w ekwipunku. 

Ten mod rozwiązuje ten problem, umożliwiając przygotowanie dwóch gotowych zestawów mikstur (np. Zestaw 1 ofensywny: Grom, Las Mariborski, Puszczyk, Czarna Krew; Zestaw 2 defensywny: Jaskółka, Wilga, Biały Miód, Kot) i zażycie całej kombinacji w trakcie starcia bez otwierania menu.

---

## Sterowanie

### 1. Konfiguracja zestawów w ekwipunku

W oknie ekwipunku na dolnym pasku znajduje się przycisk `Zestawy eliksirow (Z1: X/4 | Z2: Y/4)`.

| Akcja | Klawiatura i mysz | Kontroler (Xbox / PlayStation) |
|---|---|---|
| Otwarcie menu zestawów | Klawisz `T` | Przycisk `LT` / `L2` |
| Przełączanie zestawu (1 / 2) | Klawisze `1` lub `3` (przyciski na górnym pasku) | Przyciski `LB` / `RB` |
| Dodanie lub usunięcie eliksiru | Podwójne kliknięcie LPM lub klawisz `E` / `Enter` / `Spacja` | Przycisk `A` (Xbox) / `X` (PS) |
| Poruszanie się po siatce | Kursor myszy lub klawisze `WASD` / strzałki | Lewy drążek / D-Pad |
| Wyczyszczenie edytowanego zestawu | Klawisz `R` | Przycisk `X` (Xbox) / `Kwadrat` (PS) |
| Zamknięcie menu i powrót do ekwipunku | Klawisz `Escape`, `Backspace` lub `T` | Przycisk `B` (Xbox) / `Kółko` (PS) |

Szczegóły obsługi menu:
* Nagłówek okna informuje, który zestaw jest aktualnie modyfikowany (np. `ZESTAW 1 (3/4)`).
* Pojedyncze kliknięcie myszą podświetla miksturę, a podwójne dodaje ją do aktywnego zestawu lub usuwa, jeśli już się w nim znajduje.
* Dolny panel tekstowy pokazuje zawartość obu zestawów (ze wskaźnikiem `->` przy aktywnym zestawie) oraz skróty klawiszowe.
* Opisy fabularne oraz statystyki toksyczności zostały wycięte z tego okna, aby lista mikstur pozostała zwarta i czytelna.

---

### 2. Wypijanie zestawu podczas gry

Mod wykorzystuje klawisze przypisane do dobywania mieczy oraz przyciski menu kołowego:

| Zestaw | Klawiatura | Kontroler (Xbox / PlayStation) | Menu kołowe |
|---|---|---|---|
| Zestaw 1 | Szybkie dwukrotne wciśnięcie klawisza `1` (miecz stalowy) | Dwukrotne wciśnięcie lub przytrzymanie `D-Pad Lewo` (~0.3 s) | Przycisk nałożenia oleju stalowego |
| Zestaw 2 | Szybkie dwukrotne wciśnięcie klawisza `2` (miecz srebrny) | Dwukrotne wciśnięcie lub przytrzymanie `D-Pad Prawo` (~0.3 s) | Przycisk nałożenia oleju srebrnego |

Pojedyncze wciśnięcie klawiszy `1` i `2` (oraz kierunków D-Pada) zachowuje swoje standardowe działanie: dobywa lub chowa odpowiedni miecz.

---

## Zasady działania i toksyczność

* **Kolejność zażywania:** Mikstury są wypijane dokładnie w takiej kolejności, w jakiej zostały dodane do zestawu (od pozycji #1 do #4).
* **Ochrona przed przekroczeniem progu toksyczności:** Przed wypiciem każdego kolejnego eliksiru gra sprawdza bieżący poziom zatrucia Geralta oraz jego maksymalną tolerancję. Jeśli kolejna mikstura spowodowałaby przekroczenie limitu toksyczności, sekwencja zostaje przerwana, a gracz otrzymuje powiadomienie na ekranie.
* **Brak ładunków:** Mikstury o zerowej liczbie ładunków (0/X) są automatycznie pomijane.
* **Komunikaty HUD:** Po użyciu zestawu na ekranie pojawia się lista wypitych mikstur (np. `Uzyto Zestawu 1: Grom, Jaskolka, Puszczyk`).
* **Trwałość konfiguracji:** Skonfigurowane zestawy zapisują się w strukturze pliku zapisu gry (baza GameplayFacts), dzięki czemu nie resetują się po wczytaniu stanu gry ani restarcie aplikacji.

---

## Polecenia konsoli

Jeśli w grze włączona jest konsola deweloperska (`~`), można korzystać z następujących poleceń:
* `potionset_drink1`: natychmiast wypija Zestaw 1.
* `potionset_drink2`: natychmiast wypija Zestaw 2.
* `potionset_drink(numer)`: wypija wskazany zestaw (np. `potionset_drink(2)`).
* `potionset_clear(numer)`: czyści wskazany zestaw (np. `potionset_clear(1)`).
* `potionset_clear`: czyści oba zestawy jednocześnie.

---

## Struktura plików moda

```text
modPotionSet/
└── content/
    └── scripts/
        ├── local/
        │   └── modPotionSet.ws                 # Logika zestawów, kontrola toksyczności, formatowanie tekstu menu
        └── game/
            ├── gui/
            │   ├── menus/
            │   │   └── inventoryMenu.ws        # Otwieranie popupu z poziomu ekwipunku, przekazywanie wejścia
            │   └── popups/
            │       └── ItemSelectionPopup.ws   # Obsługa wyboru zestawu (1/3/LB/RB), 2x klik LPM, czyszczenie (R)
            └── player/
                └── playerInput.ws              # Wykrywanie podwójnych wciśnięć (klawisze 1 i 2, D-Pad Lewo i Prawo)
```

---

## Instalacja

1. Umieść folder `modPotionSet` w katalogu `Mods` w głównym folderze gry:
   ```text
   The Witcher 3 Wild Hunt/Mods/modPotionSet
   ```
2. Jeśli używasz innych modyfikacji wpływających na skrypty interfejsu lub sterowania gracza (`inventoryMenu.ws`, `playerInput.ws`), połącz skrypty za pomocą narzędzia Script Merger.
3. Uruchom grę.
