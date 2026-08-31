# MacroMate: Ist-Architektur vor dem Ausbau

Stand: 2026-08-31, Branch `codex/expand-macromate-health-platform`, Basis-Commit
`055e770`.

## Anwendung und Bootstrap

- Flutter/Dart mit Material 3 und `provider`.
- `lib/main.dart` initialisiert FlutterGemma, lokale Benachrichtigungen und genau
  eine globale `AppState`-Instanz. Abhängig von Initialisierung und Login werden
  drei getrennte `MaterialApp`-Bäume erzeugt.
- Die Android-App verwendet `FlutterActivity`. `MainActivity` hält zusätzlich den
  Method Channel `macro_mate/widget` für das Homescreen-Widget.
- Der App-Start fordert Notification- und Exact-Alarm-Berechtigungen an, lädt den
  vollständigen Zustand, synchronisiert die Offline-Queue und plant sämtliche
  Erinnerungen neu.

## Präsentation und Navigation

- `home_page.dart` ist gleichzeitig Tages-Dashboard und Ernährungserfassung.
- Gewicht, Wochenübersicht und Einstellungen sind benannte Routen. Der Einstieg
  erfolgt über ein aufklappbares Floating-Action-Menü; eine dauerhafte
  Hauptnavigation existiert nicht.
- Die größten UI-Dateien sind `ai_food_sheet.dart` (ca. 81 KB),
  `settings_page.dart` (ca. 57 KB) und `home_page.dart` (ca. 49 KB).
- Themes werden dreimal in `main.dart` dupliziert. Es existiert noch kein
  eigenständiges Designsystem für Abstände, semantische Farben, Statuskarten und
  datenabhängige Zustände.

## State und Geschäftslogik

- `AppState` ist eine ca. 2.000 Zeilen/66 KB große `ChangeNotifier`-Fassade.
- Sie enthält Login, Remote- und lokale Datenzugriffe, Nutrition-Aggregation,
  Gewicht, Ziele, Notifications, Offline-Synchronisation, Open Food Facts,
  lokale Modelle, Import/Export, Widget-Updates und UI-Fehlerzustand.
- Widgets greifen direkt auf `AppState` zu; `AppState` greift direkt auf
  `DatabaseHelper`, `RemoteDatabaseService`, Shared Preferences, HTTP und
  Plattform-Plugins zu. Repository-Interfaces fehlen.

## Lokale Persistenz

`DatabaseHelper` öffnet `food_database.db` über `sqflite`. Aktuelle
Schema-Version ist 25. Das Schema enthält zehn Tabellen:

| Tabelle | Zweck | Auffälligkeiten |
| --- | --- | --- |
| `Goals` | Kalorien-, Makro-, Körper- und Gewichtsziel | Singleton implizit, kein Constraint |
| `ConsumedFoods` | lokale Tages-/Mahlzeiteneinträge | keine FK, kein Index auf Datum |
| `SavedMeals` | Mahlzeitenvorlagen | Integer-ID |
| `SavedMealIngredients` | Zutaten einer Vorlage | deklarierte FK, Foreign Keys werden beim Öffnen nicht aktiviert |
| `FavoriteFoods` | Favoriten | referenziert Remote-/lokale IDs ohne Quelltyp |
| `FoodUsage` | letzte Menge und Nutzung | referenziert Remote-/lokale IDs ohne Quelltyp |
| `OfflineQueue` | ausstehende Remote-Aktion | unterstützt effektiv nur `food_upsert` |
| `LocalFoods` | lokal/AI erzeugte Lebensmittel | Integer-ID, kein eindeutiger Barcode |
| `Settings` | Theme und einfache Erinnerungen | Singleton über `id = 1` angenommen |
| `WeightEntries` | Gewichtsverlauf | kein Index/Unique-Constraint auf Datum |

Es sind keine expliziten Indizes vorhanden. Migrationen 19 bis 25 bestehen aus
`ALTER TABLE` und bedingtem `CREATE TABLE`; mehrere Fehler werden pauschal
ignoriert. Datumswerte sind Strings ohne zentral dokumentierte UTC-/Lokaltag-
Semantik. Neue domänenübergreifende UUIDs und Deduplication Keys fehlen.

Der JSON-Export besitzt weder Schema- noch App-Version. Er exportiert nahezu alle
lokalen Tabellen einschließlich Offline-Queue, aber keine Remote-Lebensmittel.
Der Restore wird zeilenweise und nicht atomar ausgeführt. Relationen zwischen
Mahlzeiten und Zutaten können beim Zusammenführen falsche IDs erhalten.

## Remote-Daten und Sicherheit

- `RemoteDatabaseService` verbindet die App direkt per TLS mit PostgreSQL und
  verwaltet Benutzer sowie den gemeinsamen Lebensmittelbestand.
- Build-Secrets werden als `--dart-define` in die APK eingebettet. Health- und
  Zyklusdaten existieren aktuell nicht und dürfen diesen Pfad später nicht
  verwenden.
- E-Mail und Passwort werden derzeit über Shared Preferences gespeichert; das
  Passwort liegt damit lokal im Klartext.
- Die Offline-Queue deckt ausschließlich das Hochladen von Lebensmitteln ab.

## Notifications und Plattform

- `flutter_local_notifications`, Zeitzoneninitialisierung und tägliche
  Erinnerungen sind direkt in `AppState` eingebaut.
- Kategorien, Ruhezeiten, diskrete Zyklustexte, robuste IDs und getrennte
  Präferenzen fehlen.
- Das Android-Manifest enthält Kamera-, Audio-, Notification- und
  Exact-Alarm-Berechtigungen. Health Connect und Workmanager sind nicht
  konfiguriert.

## Tests und CI

- Im Repository sind 29 Testdeklarationen in fünf Unit-/Widget-Dateien und neun
  lokalen LLM-Integrationstests vorhanden.
- Abgedeckt sind insbesondere Kalorienzielberechnung, Food-Parsing,
  Modellmetadaten, Speech-to-Text-Anhängen und ein einfacher Widget-Smoke-Test.
- Datenbankmigration, Import/Restore, Repositories, Offline-Fehler, Navigation,
  Notifications und Plattformadapter sind nicht charakterisiert.
- Der Android-CI-Workflow führt `flutter analyze`, `flutter test` und einen
  Release-APK-Build aus. iOS baut nach Merge ohne Tests/Analyse.

## Unmittelbare Risiken

1. Eine Big-Bang-Ablösung von `DatabaseHelper` oder `AppState` würde nahezu alle
   bestehenden Nutzerflüsse gleichzeitig gefährden.
2. Integer-IDs können lokale und Remote-Lebensmittel nicht eindeutig
   unterscheiden und sind für Backup-/Restore-Merges ungeeignet.
3. Nicht atomarer Restore und fehlende Migrations-Fixtures gefährden Bestandsdaten.
4. Klartext-Credentials und eingebettete Datenbank-Zugangsdaten vergrößern den
   Schaden bei APK- oder Gerätezugriff.
5. Health Connect benötigt ein geprüftes Android-Plattformsetup, eine klare
   Source-Priorität und eine von Widgets entkoppelte Adaptergrenze.

