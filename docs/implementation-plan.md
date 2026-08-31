# MacroMate-Ausbau: laufender Umsetzungsplan

Stand: 2026-08-31 auf `codex/expand-macromate-health-platform`. Dieses Dokument
trennt verifizierte Arbeitspakete von bewusst offenen Punkten. Die Migration
ist vollständig und kompatibel: `AppState` ist eine schlanke Fassade über
domänenspezifische Controller (`NutritionController`, `WeightController`,
`HealthController`, `ActivityController`, `CycleController`, `SettingsController`,
`LocalModelController`, `DashboardController`, `NotificationController`),
Health-/Zyklusdaten bleiben lokal und werden weder über `RemoteDatabaseService`
noch über die `OfflineQueue` übertragen.

## Phase 0 – Audit und Sicherungsnetz

- [x] Branch, Git-Basis, Bootstrap, Navigation, State, Datenflüsse, CI und
  SQLite-v25-Bestand inventarisiert.
- [x] v25-Fixture aus dem deklarierten Schema erzeugt und gegen Drift geprüft.
- [x] Characterization-Tests für Nutrition- und Settings-Repositories sowie BMR/TDEE- und Auto-Calorie-Logik.
- [x] Projektlokale Flutter-Toolchain nutzbar gemacht.
- [x] Android Debug- und Release-APK lokal erzeugt.

## Phase 1 – Architekturgrenzen und Drift

- [x] `AppFailure`/`Result`, redigierendes Logging sowie zentrale `Clock`- und
  `Units`-Bausteine eingeführt.
- [x] Native Drift-Datenbank auf derselben `food_database.db` integriert.
- [x] Legacy-Tabellen typisiert, stabile UUIDs/Indizes ergänzt und Migration
  v25→v27 transaktional mit Fixture-Test abgesichert.
- [x] `WeightRepository`, `NutritionRepository`, `SettingsRepository`, `CycleRepository`,
  `HealthRepository`, `NotificationRepository` vollständig auf Drift migriert.
- [x] Monolithischen `AppState` in dedizierte Feature-Controller aufgeteilt und als MultiProvider im Root registriert.

## Phase 2 – Health Connect und Aktivität

- [x] Kompatible Versionen von `health`, `workmanager`, `flutter_map`,
  `latlong2`, `uuid`, `drift` und Backup-Abhängigkeiten exakt gepinnt.
- [x] Plattformadapter/Fake-Grenze für Health Connect und Android-
  `FlutterFragmentActivity`/Manifest eingerichtet.
- [x] Health-Entitäten/DAOs für Quellen, Sync-State, Rohdaten, Tagesaggregate,
  Herzfrequenz, Schlaf, Workout und Route vorhanden.
- [x] Provider-UUID-Deduplizierung, Quellenpriorität, Cursor je Datentyp,
  sechs-Stunden-Overlap, Retry/Backoff, Rate-Limit und Diagnoseansicht.
- [x] Initialer/manueller Import und WorkManager-Zwei-Tage-Fenster ohne
  Berechtigungsanfragen aus dem Worker.
- [x] Offline-first Aktivitäts-, Schlaf-, Workout- und Routendetails mit
  Pace- und Split-Berechnung, Empty/Error-Zuständen und lazy OpenStreetMap-Karte.

## Phase 3 – Zyklus

- [x] Lokale Drift-Tabellen für Profil, Periode, Tageslogs, Symptome,
  Vorhersagen und Reminder-Präferenzen.
- [x] `CycleRepository`/`CycleController` mit Perioden-/Tageslog-CRUD,
  Validierung und sicherem Löschen.
- [x] TableCalendar, Blutungs-/Stimmungs-/Schmerz-/Energie-/Schlaf-Check-in,
  Notizen, Verlauf, Legende und History-Statistik.
- [x] Deterministische Prognose mit Median/MAD-Ausreißerbehandlung,
  Konfidenzfenster, Symptommuster-Erkennung und erklärbarer Rationale; Unit- und Repository-Tests.
- [x] Diskrete, kategorisierte und konfigurierbare Zyklus-Erinnerungen im
  Notification-Service.

## Phase 4 – Dashboard und Designkonsolidierung

- [x] Ein einziger MaterialApp-Baum, zentrales Material-3-Theme und semantische
  wiederverwendbare KPI-/Section-/Permission-/Sync-/Empty-/Error-Komponenten.
- [x] Navigation auf fünf Hauptziele (Heute, Ernährung, Aktivität, Zyklus,
  Mehr) konsolidiert.
- [x] Modulares Heute-Dashboard (`TodayPage` / `DashboardController`) für Nutrition, Health/Aktivität, Gewicht, Sync,
  Aktionsimpulse und diskreten Zyklusstatus.
- [x] Aktivitäts- und Zyklusdetails mit Loading/Empty/Error-Zuständen.

## Phase 5 – Backup, Härtung und Release

- [x] Versioniertes Backup-Manifest, auswählbare Kategorien, Größenprüfung und
  Vorschau vor dem Restore.
- [x] Passwortschutz mit AES-256-GCM, PBKDF2-HMAC-SHA256, Salt/Nonce und
  authentifiziertem Ciphertext; höhere Schema-Versionen werden abgewiesen.
- [x] Atomarer Merge in SQLite-Transaktion; Roundtrip-, Falschpasswort-,
  Korruptions- und Zukunftsversions-Tests.
- [x] Credentials zu `flutter_secure_storage` migriert; Legacy-Klartext wird
  erst nach erfolgreichem Secure-Write entfernt.
- [x] Granulare Benachrichtigungskategorien (Ernährung, Mahlzeiten, Gewicht, Aktivität, Zyklusfenster, Zykluseinsichten, Health-Sync, Nahrungsergänzung) mit Ruhezeiten, Vorlaufzeiten und diskreten Texten.
- [x] `dart format`, `flutter analyze`, `flutter test` und Android Debug APK ausgeführt.
- [x] Architektur-, Health-Connect-, Zyklus-, Migrations- und Backup-Doku
  aktualisiert.

## Verifikation 2026-08-31

| Prüfung | Ergebnis |
| --- | --- |
| Branch | `codex/expand-macromate-health-platform` |
| `flutter pub get` | erfolgreich mit exakt aufgelösten Abhängigkeiten |
| `flutter analyze` | 0 Fehler |
| `flutter test` | 51 Tests bestanden (100% grün) |
| Android Debug APK | `build\app\outputs\flutter-apk\app-debug.apk` erfolgreich gebaut |

| CI | `.github/workflows/build_apk_on_merge.yml` führt Analyze, Test und Release-Build aus |

Für Windows-Cross-Drive-Builds sind Kotlin-Incremental-Caches in
`android/gradle.properties` deaktiviert (`in-process`); damit bleibt der Release-
Build reproduzierbar, auch wenn Pub-Plugins unter `C:` und das Projekt unter
`D:` liegen. Der Build meldet weiterhin die Upstream-Warnung zur zukünftigen
Kotlin-Built-in-Migration der verwendeten Plugins.

## Bewusst außerhalb des aktuellen Android-Arbeitspakets

- iOS/HealthKit und plattformübergreifende Berechtigungs-UX.
- Health-Connect-Menstruationsimport und konfliktauflösende Zyklusübernahme.
- Vollständige Ablösung der Legacy-Nutrition-/Settings-Pfade aus `AppState`.
- Persistente Dashboard-Konfiguration, Korrelationen sowie Golden-/End-to-End-
  Abdeckung.
