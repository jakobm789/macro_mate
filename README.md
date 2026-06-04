# MacroMate



MacroMate ist eine Flutter-App zum Tracken von Kalorien und Makronährstoffen. Sie bietet Barcode-Scanning, Gewichtserfassung und Erinnerungen, damit du deine Ernährungsziele im Blick behältst.

## Features
- Tagesübersicht mit Ziel- und Ist-Werten für Kalorien, Kohlenhydrate, Proteine, Fette und Zucker
- Mahlzeiten verwalten (Frühstück, Mittagessen, Abendessen, Snacks)
- Lebensmittel per Barcode scannen (Open Food Facts Integration)
- Lokale Bild-/Textanalyse für Lebensmittel über LiteRT / Google AI Edge
- Eigenes Lebensmittellager mit Import/Export als JSON
- Gewicht verfolgen und Auswertungen betrachten
- Lokale Push-Benachrichtigungen und Dark/Light-Mode

## Screenshots
<p align="center">
  <img src="docs/screenshots/dashboard.jpeg" alt="Dashboard" width="24%" />
  <img src="docs/screenshots/add_food.jpeg" alt="Lebensmittel hinzufügen" width="24%" />
  <img src="docs/screenshots/weight.jpeg" alt="Gewichtsverlauf" width="24%" />
  <img src="docs/screenshots/settings.jpeg" alt="Einstellungen" width="24%" />
</p>

## Installation & Entwicklung
1. Flutter-SDK herunterladen (falls noch nicht vorhanden):
   ```bash
   ./scripts/setup_flutter.sh
   export PATH="$(pwd)/flutter_sdk/bin:$PATH"
   ```
2. Abhängigkeiten installieren:
   ```bash
   flutter pub get
   ```
3. App starten:
   ```bash
   flutter run
   ```

## Lokale Modell-Inferenz
Die Lebensmittelanalyse sendet keine Vision-LLM-Requests an externe APIs. In den Einstellungen unter **Lokales Vision-Modell** kann eines dieser Modelle gewählt, installiert, geprüft und mit einem Debug-Prompt getestet werden:

- Gemma 4 E4B
- Gemma 4 E2B
- FastVLM 0.5B

Android ist zuerst unterstützt. Für `.litertlm`-Vision-Inferenz wird ein `arm64-v8a`-Gerät empfohlen. Falls ein Hugging-Face-Token für einen Modell-Download nötig ist, kann er optional als `HUGGINGFACE_TOKEN` per `--dart-define` übergeben werden; für die Inferenz selbst wird kein API-Key verwendet.

## Tests
Automatisierte Tests laufen mit:
```bash
flutter test
```

## iOS-Build (kostenloses Provisioning)
1. Projekt bereinigen und Abhängigkeiten installieren:
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   ```
2. Workspace in Xcode öffnen:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. In Xcode unter **Signing & Capabilities** ein Team auswählen und auf einem Gerät mit \`⌘R\` starten. Das Zertifikat ist sieben Tage gültig.

## iOS-Build in GitHub Actions
Der Workflow `.github/workflows/build_ios_on_merge.yml` kann automatisch signieren. Notwendige Secrets:
- `APPLE_ID_EMAIL`
- `APPLE_ID_PASSWORD` (App-spezifisches Passwort)
Auf jedem Merge in `main` wird `flutter build ipa` ausgeführt und das Artefakt `Runner.ipa` bereitgestellt
