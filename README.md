# Witcher 3: Potion Set

Mod do gry Wiedźmin 3: Dziki Gon (Next-Gen v5.01). Pozwala skonfigurować w ekwipunku dwa zestawy mikstur (do 4 eliksirów w każdym) i wypijać je w trakcie walki jednym przytrzymaniem klawisza.

---

## Jak to działa

W podstawowej wersji gry Geralt ma do dyspozycji cztery sloty szybkiego dostępu na eliksiry i jedzenie. Zmiana mikstur podczas walki wymaga otwierania ekwipunku i ręcznego przekładania przedmiotów.

Mod pozwala przygotować dwa gotowe zestawy (np. Zestaw 1 ofensywny: Grom, Las Mariborski, Puszczyk, Czarna Krew) i zażywać je bezpośrednio podczas starcia.

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
* Pojedyncze kliknięcie myszą podświetla eliksir, a podwójne dodaje go do aktywnego zestawu lub usuwa, jeśli już się w nim znajduje.
* Dolny panel tekstowy pokazuje zawartość aktualnie edytowanego zestawu (każdy eliksir w osobnej linii z bieżącą liczbą ładunków).
* Długie opisy fabularne i zbędne statystyki zostały ukryte w tym oknie, aby lista mikstur pozostała zwarta i czytelna.

---

### 2. Wypijanie zestawu podczas gry

Mod wykorzystuje klawisze dobywania mieczy oraz akcje menu kołowego:

| Zestaw | Klawiatura | Kontroler (Xbox / PlayStation) | Menu kołowe |
|---|---|---|---|
| Zestaw 1 | Przytrzymanie klawisza `1` (miecz stalowy) | Przytrzymanie `D-Pad Lewo` (~0.3 s) | Przycisk nałożenia oleju stalowego |
| Zestaw 2 | Przytrzymanie klawisza `2` (miecz srebrny) | Przytrzymanie `D-Pad Prawo` (~0.3 s) | Przycisk nałożenia oleju srebrnego |

Krótkie naciśnięcie klawiszy `1` i `2` (oraz kierunków D-Pada) zachowuje domyślne działanie — dobywa lub chowa odpowiedni miecz. Zażycie zestawu następuje wyłącznie po przytrzymaniu przycisku.

---

## Toksyczność i mechanika

* **Kolejność:** Eliksiry są wypijane w kolejności przypisania do zestawu (od pozycji #1 do #4).
* **Kontrola toksyczności:** Przed zażyciem każdego kolejnego eliksiru gra sprawdza bieżący poziom zatrucia i maksymalną tolerancję Geralta. Jeśli kolejna mikstura przekroczyłaby bezpieczny limit, sekwencja zostaje przerwana, a na ekranie pojawia się ostrzeżenie.
* **Puste mikstury:** Eliksiry z zerową liczbą ładunków (0/X) są automatycznie pomijane.
* **Komunikaty HUD:** Po użyciu zestawu na ekranie pojawia się lista zażytych mikstur (np. `Uzyto Zestawu 1: Grom, Jaskolka, Puszczyk`).

---

## Instalacja

1. Skopiuj folder `modPotionSet` do katalogu `Mods` w głównym folderze gry:
   ```text
   The Witcher 3 Wild Hunt/Mods/modPotionSet
   ```
2. Jeśli używasz innych modyfikacji zmieniających skrypty interfejsu lub sterowania (`inventoryMenu.ws`, `playerInput.ws`), połącz je programem Script Merger.
3. Uruchom grę.
