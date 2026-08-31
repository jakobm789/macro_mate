# MacroMate-Ausbau: Gap-Analyse und Umsetzungsplan

Diese Checkliste ist das laufende Arbeitsdokument für den vollständigen Ausbau.
Sie wird nach jedem überprüfbaren Schritt aktualisiert. Der Bestand bleibt bis
zur jeweiligen Umschaltung über Fassaden kompatibel.

## Leitplanken

- Keine Health- oder Zyklusdaten über `RemoteDatabaseService` oder die
  `OfflineQueue` übertragen.
- Bestehende Tabellen und IDs während der Drift-Einführung zunächst übernehmen;
  neue UUID-Spalten rückfüllbar und nullable einführen, danach erst verschärfen.
- Jede Schemaänderung in einer Transaktion ausführen und gegen eine v25-Fixture
  sowie eine frisch erstellte Datenbank testen.
- `AppState` bleibt während der Migration eine API-Fassade. Neue Logik entsteht
  ausschließlich hinter Repository- und Controller-Grenzen.
- Phasen enden mit Formatierung, Analyse, Tests und Android-Build. Abweichungen
  und Toolchain-Blocker werden in der Phasenbilanz dokumentiert.

## Phase 0 – Audit und Sicherungsnetz

- [x] Branch und saubere Git-Basis verifizieren.
- [x] Bootstrap, Navigation, State, lokale/remote Datenflüsse und CI inventarisieren.
- [x] SQLite-v25-Tabellen, Migrationen und Exportfelder erfassen.
- [x] Ist-Architektur und Hauptrisiken dokumentieren.
- [x] Bestehende DB-v25-Fixture aus dem deklarierten Schema erzeugen.
- [ ] Characterization Tests für Datenexport/-restore, Nutrition-Aggregation,
  Gewichtsänderungen und Offline-Queue ergänzen.
- [x] Lokale Flutter-Toolchain reparieren und Analyze-/Test-Baseline erfassen.
- [ ] Android Debug-/Release-Build-Baseline erfassen.

## Phase 1 – Architekturgrenzen und Drift

### Zielstruktur

```text
lib/
  app/{bootstrap,navigation,theme}/
  core/{database,errors,logging,notifications,permissions,time,units}/
  features/
    nutrition/{data,domain,presentation}/
    weight/{data,domain,presentation}/
    health/{data,domain,presentation}/
    activity/{data,domain,presentation}/
    cycle/{data,domain,presentation}/
    dashboard/{data,domain,presentation}/
    settings/{data,domain,presentation}/
    backup/{data,domain,presentation}/
```

- [ ] `AppFailure`/`Result`, redigierendes Logging und zentrale Clock/Units einführen.
- [ ] Repository-Interfaces für Nutrition, Weight, Settings, Health, Activity,
  Cycle, Dashboard und Backup definieren.
- [ ] Drift mit nativer SQLite-Öffnung auf dieselbe `food_database.db` integrieren.
- [ ] Bestehende zehn Tabellen exakt typisieren; v25 als Alt-Schema behandeln.
- [ ] Migration v25 → v26: Metadaten, stabile UUIDs und notwendige Indizes ergänzen,
  ohne bestehende Spalten oder IDs zu entfernen.
- [ ] Migrationstests mit Daten für Ziele, Konsum, lokale Foods, Vorlagen,
  Favoriten, Gewicht, Settings und Queue.
- [ ] Nutrition-, Weight- und Settings-Repositories implementieren und über die
  bestehende `AppState`-API einschleusen.
- [ ] `NutritionController`, `WeightController`, `SettingsController` und
  `LocalModelController` extrahieren.

### Geplante v26-Migrationsdetails

- Metatabelle `AppDatabaseMetadata(schema_version, created_at_utc,
  migrated_at_utc)`.
- UUID-Spalten für lokale Lebensmittel, Konsumeinträge, Gewicht und Vorlagen;
  deterministisches Backfill aus Installation-ID, Tabellenname und Legacy-ID.
- Indizes auf `ConsumedFoods(date, meal_name)`, `WeightEntries(date)`,
  `FoodUsage(last_used_at)` und `OfflineQueue(created_at)`.
- Keine Löschung oder Umbenennung vorhandener Spalten in derselben Phase.
- Foreign-Key-Aktivierung erst nach Integritätsprüfung und Bereinigung verwaister
  Vorlagenzutaten.

## Phase 2 – Health Connect und Aktivität

- [ ] Kompatible stabile Versionen von `health`, `workmanager`, `flutter_map`,
  `latlong2`, `uuid` und Test-Abhängigkeiten anhand offizieller Anforderungen pinnen.
- [ ] Plattformunabhängigen `HealthDataSource`/`HealthRepository`-Adapter und
  Fake-Adapter für Tests implementieren.
- [ ] Drift-Entitäten/DAOs: Quelle, Permission-/Sync-State, Tagesaggregate,
  Herzfrequenz-Buckets, Schlaf, Workout und Route.
- [ ] Eindeutige Source-/Record-/Deduplication Keys und dokumentierte
  Quellenpriorisierung einführen.
- [ ] Android-Manifest, Health-Connect-Intents und ggf. `FlutterFragmentActivity`
  ergänzen; Method Channel und Widget per Smoke-Test erhalten.
- [ ] Permission-Onboarding, Teilberechtigungen, Diagnose und Trennen umsetzen.
- [ ] Initialen/incrementellen/manuellen Import mit Transaktion, Cursor, Fortschritt,
  Rate Limiting, Retry/Backoff und Historienberechtigung umsetzen.
- [ ] Periodischen Workmanager-Import registrieren, ohne Echtzeitversprechen.
- [ ] Aktivitäts-, Schlaf-, Workout- und Routendetails mit Empty/Error/Offline-
  Zuständen erstellen.

## Phase 3 – Zyklus

- [ ] Lokale Drift-Tabellen für Profil, Periode, Tageslog, Symptome, Vorhersagen
  und Reminder erstellen; Remote-Schreibpfade architektonisch ausschließen.
- [ ] `CycleRepository` und `CycleController` mit vollständigem CRUD und sicherem
  Löschfluss implementieren.
- [ ] Angepassten `table_calendar`-Kalender, Schnellerfassung, Detailbearbeitung,
  Historie, Legende und barrierefreie Semantik umsetzen.
- [ ] Deterministische robuste Prognose-Engine mit Mindestdatenmenge,
  Ausreißerbehandlung, Unsicherheitsfenster und erklärbaren Mustern implementieren.
- [ ] Unit-Tests für regelmäßige, unregelmäßige, kurze, lange und unvollständige
  Zyklen ergänzen.
- [ ] Optionale Health-Connect-Übernahme mit Vorschau, Bestätigung und
  Konfliktlösung ergänzen.
- [ ] Diskrete, kategorisierte und konfigurierbare Erinnerungen integrieren.

## Phase 4 – Dashboard und Designkonsolidierung

- [ ] Einen einzigen App-Baum, zentrales Material-3-Theme und semantische Tokens
  für Light/Dark, Abstände, Radien und Statusfarben schaffen.
- [ ] Wiederverwendbare KPI-, Section-, Permission-, Sync-, Chart-, Empty- und
  Error-Komponenten extrahieren.
- [ ] Navigation auf maximal fünf Ziele konsolidieren: Heute, Ernährung,
  Aktivität, Zyklus und Mehr.
- [ ] Modulares Heute-Dashboard für Nutrition, Aktivität, Energie, Gewicht, Sync
  und optional diskreten Zyklusstatus erstellen.
- [ ] Kartenreihenfolge/-sichtbarkeit persistent konfigurierbar machen.
- [ ] Korrelationen nur ab ausreichender Datenmenge, mit Stichprobengröße und
  klarer Nicht-Kausalitäts-Sprache darstellen.
- [ ] Textskalierung, Screenreader, Kontrast, Touch Targets und kleine/große
  Android-Layouts per Widget-/Golden-Tests prüfen.

## Phase 5 – Backup, Härtung und Release

- [ ] Versioniertes Backup-Manifest und auswählbare Kategorien implementieren.
- [ ] Passwortgeschütztes Archiv mit `cryptography`, Salt, dokumentierter KDF,
  authentifizierter Verschlüsselung und keinerlei Klartextpasswort umsetzen.
- [ ] Vorschau, Versions-/Größenprüfung, Konfliktstrategie und atomaren Restore
  mit Rollback implementieren.
- [ ] Roundtrip, falsches Passwort, beschädigtes Archiv und Altversion testen.
- [ ] Credentials zu `flutter_secure_storage` migrieren und Shared-Preferences-
  Klartext nach erfolgreicher Migration löschen.
- [ ] Unbenutzte Build-Secrets entfernen; sensible Logs redigieren.
- [ ] Query-/Chart-Performance und Retention/Aggregation profilieren.
- [ ] Vollständige Unit-, Widget-, Migration-, Integration- und Golden-Testmatrix.
- [ ] `dart format`, `flutter analyze`, `flutter test`, Android Debug/Release und
  Migrations-Smoke-Test erfolgreich ausführen.
- [ ] README, Architektur, Health Connect, Zyklusprognosen, Migrationen,
  Backupformat und ADRs auf den finalen Stand bringen.

## Test-Baseline vom 2026-08-31

| Prüfung | Ergebnis |
| --- | --- |
| Git-Status | sauber auf Basis `055e770` |
| Testbestand | 29 deklarierte Tests; Schwerpunkte Food/LLM/Speech/Goal |
| Toolchain | Flutter 3.44.1, Dart 3.12.1; fehlender lokaler Dart-Cache wiederhergestellt |
| `flutter analyze` | ausführbar; 153 bestehende Findings (151 Infos, 2 Warnungen, keine Fehler) |
| `flutter test` | 18 Tests erfolgreich |
| Android Debug Build | erfolgreich; APK erzeugt, erster Lauf 493 s inkl. SDK/NDK/CMake/native Downloads |
| CI | Android führt Analyze/Test/Release-Build auf Flutter stable aus |

Der lokale Flutter-Cache war inkonsistent: Engine-Stempel vorhanden, Dart-SDK
fehlend. Der fehlerhafte Stempel wurde gesichert und der zu Flutter 3.44.1
gehörige Dart-Cache neu geladen. Windows meldet außerdem deaktivierte
Symlink-Unterstützung; Analyze und Tests sind davon nicht blockiert, Plugin-
Builds können Developer Mode benötigen.
