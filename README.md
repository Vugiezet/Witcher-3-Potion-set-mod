# Witcher 3: Potion Set (Zestawy Eliksirów)

Modyfikacja do gry **Wiedźmin 3: Dziki Gon** (wersja Next-Gen 4.00+), która pozwala graczowi skonfigurować w ekwipunku **dwa niezależne zestawy eliksirów** (Zestaw 1 oraz Zestaw 2), każdy składający się z maksymalnie **4 zwykłych eliksirów**, a następnie natychmiastowo wypić wybrany zestaw jednym skrótem klawiszowym podczas walki lub eksploracji (z zachowaniem mechaniki toksyczności).

---

## 🎯 Cel moda

W podstawowej wersji gry korzystanie z wielu eliksirów wymaga częstego otwierania ekwipunku lub żonglowania slotami szybkiego dostępu. Mod **Potion Set** rozwiązuje ten problem:
- Umożliwia przygotowanie **dwóch gotowych zestawów mikstur** na różne okazje (np. Zestaw 1 ofensywny: *Grom*, *Las Mariborski*, *Puszczyk*, *Czarna Krew*; Zestaw 2 defensywny/regeneracyjny: *Jaskółka*, *Wilga*, *Biały Miód*, *Kot*).
- Pozwala użyć całej kombinacji mikstur w ułamku sekundy w trakcie walki.
- Dba o bezpieczeństwo Geralta – eliksiry wypijane są po kolei, dopóki pozwala na to dostępny próg toksyczności (jeśli kolejny eliksir przekroczyłby limit 100% toksyczności, Geralt zażyje tylko te mikstury, na które wystarczyło tolerancji).

---

## 🎮 Sterowanie

### 1. W Ekwipunku (Tworzenie i edycja zestawów)

W menu ekwipunku na dolnym pasku widnieje przycisk **Zestawy eliksirow (Z1: X/4 | Z2: Y/4)**:

| Akcja | Klawiatura + Mysz | Kontroler (Xbox / PS5) |
|---|---|---|
| **Otwórz menu zestawów** | Klawisz **`T`** | Przycisk **`LT`** / **`L2`** |
| **Przełączanie Zestaw 1 ⟷ Zestaw 2** | Przyciski **`1`** lub **`3`** (przyciski kategorii w nagłówku) | Przyciski **`LB`** / **`RB`** |
| **Dodaj / Usuń eliksir z aktywnego zestawu** | **Podwójne kliknięcie LPM** *(pojedyncze zaznacza)* <br> *lub* **`E`** / **`Enter`** / **`Spacja`** | Przycisk **`A`** (Xbox) / **`X`** (PS5) |
| **Nawigacja po siatce** | Ruch myszką *lub* strzałki / **WASD** | Lewy drążek / **D-Pad** |
| **Wyczyść aktywny zestaw (0/4)** | Klawisz **`R`** | Przycisk **`X`** (Xbox) / **`Kwadrat`** (PS5) |
| **Zapisz i wróć do ekwipunku** | Klawisz **`Escape`**, **`Backspace`** lub **`T`** | Przycisk **`B`** (Xbox) / **`Kółko`** (PS5) |

> **Wskazówki dot. menu:**
> - W nagłówku okna wyświetla się aktualnie edytowany zestaw (np. `ZESTAW 1 (3/4)` lub `ZESTAW 2 (2/4)`).
> - Podwójne kliknięcie myszą (lub klawisz `E` / `A`) dodaje eliksir do edytowanego zestawu lub go usuwa, jeśli już w nim jest.
> - W dolnym polu tekstowym wyświetlane jest przejrzyste podsumowanie obu zestawów (z kursorem `->` wskazującym aktywny zestaw) oraz wskazówki sterowania.
> - Zbędne opisy fabularne eliksirów oraz statystyki toksyczności zostały usunięte z menu dla maksymalnej czytelności.

---

### 2. Podczas rozgrywki (Wypicie zestawu)

Mod wykorzystuje podwójne naciśnięcia klawiszy dobycia mieczy (lub przytrzymanie na kontrolerze):

| Zestaw | Klawiatura | Kontroler (Xbox / PS5) | Menu kołowe |
|---|---|---|---|
| **ZESTAW 1** | **Szybkie podwójne naciśnięcie klawisza `1`** (Miecz stalowy) | **Podwójne naciśnięcie D-Pad Lewo** *(lub przytrzymanie ~0.3s)* | Przycisk nałożenia oleju stalowego |
| **ZESTAW 2** | **Szybkie podwójne naciśnięcie klawisza `2`** (Miecz srebrny) | **Podwójne naciśnięcie D-Pad Prawo** *(lub przytrzymanie ~0.3s)* | Przycisk nałożenia oleju srebrnego |

> Pojedyncze naciśnięcie `1` lub `2` (bądź D-Pada) nadal normalnie dobywa i chowa odpowiedni miecz.

---

## 🧪 Zasady działania i toksyczność

1. **Kolejność wypijania:**
   Eliksiry są używane dokładnie w takiej kolejności, w jakiej zostały dodane do zestawu (`#1` ➔ `#2` ➔ `#3` ➔ `#4`).
2. **Ochrona przed przedawkowaniem:**
   Przed wypiciem każdej kolejnej mikstury gra sprawdza aktualną toksyczność Geralta oraz jego maksymalną tolerancję.
   - Jeśli limit pozwala na wypicie – mikstura zostaje zażyta, odtwarza się efekt dźwiękowy i zużywa ładunek.
   - Jeśli poziom toksyczności na to nie pozwala – proces zostaje zatrzymany, a na ekranie pojawia się komunikat o zablokowaniu kolejnych eliksirów przez toksyczność.
3. **Komunikaty HUD:**
   Na ekranie pojawia się informacja o użytym zestawie i zażytych miksturach (np. `Uzyto Zestawu 1: Grom, Jaskolka, Puszczyk`).
4. **Trwałość zapisów:**
   Oba zestawy zapisują się w stanie zapisu gry (GameplayFacts DB), dzięki czemu nie znikają po wczytaniu rozgrywki ani restarcie gry.

---

## 💻 Komendy konsoli (opcjonalne)

Jeżeli masz aktywną konsolę deweloperską (`~`), możesz używać poleceń:
- `potionset_drink1` – natychmiast wypija Zestaw 1.
- `potionset_drink2` – natychmiast wypija Zestaw 2.
- `potionset_drink(numer)` – wypija Zestaw 1 lub 2 (np. `potionset_drink(2)`).
- `potionset_clear(numer)` – czyści wskazany zestaw (np. `potionset_clear(1)` lub `potionset_clear(2)`).
- `potionset_clear` – czyści oba zestawy naraz (reset do 0/4).

---

## 📁 Zmodyfikowane pliki moda

```text
modPotionSet/
└── content/
    └── scripts/
        ├── local/
        │   └── modPotionSet.ws                 # Logika Zestawu 1 i 2, sprawdzanie toksyczności, formatowanie menu
        └── game/
            ├── gui/
            │   ├── menus/
            │   │   └── inventoryMenu.ws        # Otwieranie ItemSelectionPopup z ekwipunku, routing wejścia
            │   └── popups/
            │       └── ItemSelectionPopup.ws   # Przełączanie zestawów (1 / 3 / LB / RB), 2x klik myszą, obsługa R
            └── player/
                └── playerInput.ws              # Wykrywanie 2x wciśnięcia (klawisze 1 / 2, D-Pad Lewo / Prawo)
```

---

## 🛠️ Instalacja

1. Folder `modPotionSet` umieść w katalogu `Mods` w głównym folderze gry:
   ```text
   The Witcher 3 Wild Hunt/Mods/modPotionSet
   ```
2. Jeśli używasz innych modów modyfikujących skrypty interfejsu lub sterowania gracza (`inventoryMenu.ws`, `playerInput.ws`), uruchom **Script Merger**, aby połączyć zmiany.
3. Uruchom grę i ciesz się dwoma zestawami eliksirów!
