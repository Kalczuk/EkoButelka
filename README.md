# ♻️ EKOButelka - Krajowy System Recyklingu (PWA)

**EKOButelka** to nowoczesna, wieloplatformowa aplikacja typu Progressive Web App (PWA) zbudowana we Flutterze. Jej celem jest ułatwienie użytkownikom korzystania z systemu kaucyjnego poprzez lokalizowanie recyklomatów oraz sklepów przyjmujących butelki (PET) i puszki (ALU), a także wirtualne zarządzanie zgromadzonymi środkami.

👉 **🌐 Wypróbuj aplikację na żywo:** https://ekobutelka-776f7.web.app

## ✨ Główne funkcjonalności

* 🗺️ **Interaktywna Mapa (OpenStreetMap API):** Wyszukiwanie punktów kaucyjnych, supermarketów i małych sklepów (Żabka, Biedronka, Dino itp.) w promieniu 5 km od użytkownika.
* 📱 **Natywne Doświadczenie PWA:** Wbudowany, inteligentny mechanizm instruujący użytkownika, jak zainstalować aplikację na ekranie głównym (wykrywanie iOS Safari / Android Chrome).
* 💰 **Kalkulator i Portfel Kaucji:** Obliczanie zwrotów (50 gr / szt.) wraz z synchronizacją salda i historii operacji w czasie rzeczywistym.
* 🌱 **Eko-Profil i Grywalizacja:** Zbieranie punktów za uratowane opakowania, śledzenie redukcji śladu węglowego (CO2) oraz zdobywanie odznak (Nowy Ekolog, Eko-Bohater).
* 🔒 **Bezpieczna Chmura Firebase:** Konta użytkowników i ich historia zwrotów są bezpiecznie przechowywane w Google Firebase.
* 💵 **Gotowa Monetyzacja:** Zaimplementowane dyskretne miejsca pod banery reklamowe Google AdSense.

## 🛠 Technologie
* **Frontend:** Flutter (Dart) ze wsparciem dla architektury Web / PWA.
* **Backend / Baza danych:** Firebase Authentication & Cloud Firestore.
* **Usługi Mapowe:** `flutter_map`, OpenStreetMap, Overpass API.
* **Geolokalizacja:** `geolocator`.

## ⚠️ Status Projektu (Wczesna faza rozwojowa)

Projekt znajduje się obecnie w fazie intensywnego rozwoju (**BETA**). 
Ponieważ korzystamy z darmowych, otwartych źródeł danych (OpenStreetMap) oraz technologii webowych, aplikacja posiada swoje ograniczenia techniczne:
* **Lokalizacja GPS:** Ze względu na blokady bezpieczeństwa przeglądarek internetowych (szczególnie iOS), aplikacja może mieć czasem problemy z automatycznym odczytaniem lokalizacji użytkownika. W takich przypadkach mapa może załadować domyślne współrzędne.
* **Limity API:** Zbyt częste odświeżanie mapy może skutkować chwilowym brakiem ładowania punktów (limit zapytań serwera Overpass).

**Projekt jest w pełni otwarty na modyfikacje!** Zachęcam do pobierania kodu, testowania, wprowadzania poprawek i wspólnego rozwijania aplikacji.


