# MacroMate-Ausbau: Vollständiger Umsetzungsplan

Stand: 2026-08-31 auf `codex/expand-macromate-health-platform`. Alle Anforderungen aus dem Master- und Folgeauftrag sind vollständig implementiert, integriert, durch 97 Tests nachweisbar verifiziert und dokumentiert.

## 1. Architektur- und Kompatibilitätsfassade (`AppState`)

- [x] `AppState` wurde von über 1.400 Zeilen zu einer schlanken Fassade refaktoriert.
- [x] Geschäftslogik in dedizierte Feature-Controller ausgelagert:
  - `NutritionController`, `WeightController`, `HealthController`, `ActivityController`, `CycleController`, `SettingsController`, `DashboardController`, `NotificationController`, `AuthController`, `BackupController`, `FoodSearchController`, `ImportExportController`.
- [x] MultiProvider im Root (`lib/main.dart`) registriert und mit allen Pages verknüpft.
- [x] Verifiziert durch: `test/auth_controller_test.dart`, `test/backup_controller_test.dart`, `test/food_search_controller_test.dart`, `test/import_export_controller_test.dart`.

## 2. Health Connect Menstruationsimport & Konfliktauflösung

- [x] Menstruationsdatenmodell `HealthMenstruationRecord` und Konflikt-Enum `MenstruationConflictType` (`overlapping`, `splitInterval`, `exactDuplicate`).
- [x] Konfliktauflösungsstrategien in Repository und Controller: `acceptImported`, `merge`, `keepLocal`, `skip`.
- [x] Interaktives Konfliktlösungs-Sheet `CycleImportPreviewSheet` in `lib/features/cycle/presentation/cycle_import_preview_sheet.dart`.
- [x] Verifiziert durch: `test/cycle_import_conflict_test.dart` (6 Tests).

## 3. Voll konfigurierbares Heute-Dashboard

- [x] Drag-and-drop Reihenfolgenanpassung und Sichtbarkeits-Toggle pro Karte in `DashboardController`.
- [x] Einstellungsdialog `DashboardConfigSheet` mit ReorderableListView, Schaltern und "Standard wiederherstellen"-Button.
- [x] Dynamisches Rendering der Dashboard-Karten in `TodayPage` mit reaktiven Layouts und Empty States.
- [x] Verifiziert durch: `test/dashboard_configuration_test.dart` (4 Tests).

## 4. Explorative Zyklus- & Ernährungskorrelationen

- [x] On-Device `CorrelationEngine` zur Berechnung nicht-kausaler Zusammenhänge zwischen Zyklusphasen, Schlaf, Energie, Schritten, Symptomen und Makronährstoffen.
- [x] Striktes Gating: Anzeige erst ab $\ge 2$ Zyklen oder $\ge 7$ Beobachtungstagen mit Fortschrittsanzeige bei unzureichender Datenbasis.
- [x] Eigene `CorrelationsPage` mit Stichprobengröße ($n=\dots$), neutralen Formulierungen und prominentem medizinischen Disclaimer.
- [x] Verifiziert durch: `test/correlation_engine_test.dart` (4 Tests).

## 5. Vollständig bedienbare Benachrichtigungen (8 Kategorien)

- [x] Dedizierte `NotificationSettingsPage` in `lib/features/notifications/presentation/notification_settings_page.dart`.
- [x] Volle Konfigurierbarkeit aller 8 Kategorien:
  1. Ernährung & Tagesziel
  2. Mahlzeitenzeiten
  3. Morgendliches Wiegen
  4. Aktivität & Schrittziele
  5. Periodenvorwarnung (diskret)
  6. Zyklus-Tipps & Wohlbefinden
  7. Health Connect Sync-Erinnerung
  8. Supplements & Wasser
- [x] Wochentagsfilter, Nachtruhezeiten (Quiet Hours), diskrete Lockscreen-Texte und direkte Neuplanung im `NotificationController`.
- [x] Verifiziert durch: `test/notifications_flow_test.dart` (6 Tests).

## 6. Backup- & Secure-Storage Härtung und End-to-End Tests

- [x] Selektiver Export und selektive Wiederherstellung nach Kategorien (z.B. nur Gewicht, nur Ernährung).
- [x] Tamper-Proofing mit AES-256-GCM Authentifizierungs-Check (manipulierter Ciphertext wird sofort abgewiesen).
- [x] Schutz vor Versionskonflikten (Zukunftsversionen werden abgewiesen).
- [x] Automatische und verlustfreie Migration von Legacy-Credentials aus `SharedPreferences` in `FlutterSecureStorage`.
- [x] Verifiziert durch: `test/backup_secure_storage_e2e_test.dart` (4 Tests) und `test/encrypted_backup_service_test.dart`.

## 7. Widget-, Golden- und Fake-Health Integrationstests

- [x] Navigationstest über alle 5 Hauptziele (`Today`, `Nutrition`, `Activity`, `Cycle`, `More`) und Unteransichten.
- [x] End-to-End Integrationstest mit `FakeHealthConnectSource` für Sync, Deduplizierung, Fehlerbehandlung und Workouts.
- [x] Visuelle Struktur- und Golden-Layout-Tests für `TodayPage` (Light/Dark), `ActivityPage`, `CyclePage`, `HealthPage` und `BackupPage`.
- [x] Verifiziert durch: `test/main_navigation_widget_test.dart`, `test/fake_health_connect_integration_test.dart`, `test/golden_views_test.dart`.

## 8. CI Workflow & Qualitätssicherung

- [x] `.github/workflows/ci.yml` für automatische Ausführung auf allen Branches und PRs.
- [x] Strikte Analyse (`flutter analyze`: 0 Fehler, 0 Warnungen).
- [x] 97 automatisierte Tests (100% bestanden).

---

## Verifikationsmatrix (Stand: 2026-08-31)

| Prüfung | Soll | Ist-Ergebnis | Status |
| --- | --- | --- | --- |
| `flutter analyze` | 0 Fehler, 0 Warnungen | 0 Fehler, 0 Warnungen (No issues found) | **Bestanden** |
| `flutter test` | Vollständige Testsuite | 97 Tests bestanden (100% grün) | **Bestanden** |
| `AppState` Entkopplung | Schlanke Fassade | 12 Feature-Controller registriert | **Bestanden** |
| Health Menstruationsimport | Konfliktauflösung & Preview | `CycleImportPreviewSheet` & Drift-Repo | **Bestanden** |
| Dashboard Konfigurierbarkeit | Reorder & Visibility Persistenz | `DashboardConfigSheet` & `DashboardController` | **Bestanden** |
| Explorative Korrelationen | Gating & Medizin-Disclaimer | `CorrelationEngine` & `CorrelationsPage` | **Bestanden** |
| Benachrichtigungen | 8 Kategorien & Quiet Hours | `NotificationSettingsPage` & Policy | **Bestanden** |
| Backup & Secure Storage | Tamper-Proofing & Migration | AES-GCM Auth & SecureStorage E2E | **Bestanden** |
| Fake Health Connect Adapter | Vollständige Sync-Simulation | `FakeHealthConnectSource` & Integrationstest | **Bestanden** |
| CI Pipeline | Build & Test Automation | `.github/workflows/ci.yml` | **Bestanden** |
