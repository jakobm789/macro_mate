# MacroMate: aktuelle Architektur

Stand: 2026-08-31, Branch `codex/expand-macromate-health-platform`. Die
Architektur wird bewusst strangweise migriert: `AppState` bleibt als
Kompatibilitätsfassade erhalten, neue Funktionen liegen hinter typisierten
Repositories und Controllern.

## Anwendung und Navigation

- `main.dart` baut genau einen `MaterialApp`-Baum und entscheidet darunter nur
  zwischen Loading, Login und `AppShell`.
- `AppShell` bündelt die fünf Hauptziele Heute, Ernährung, Aktivität, Zyklus und
  Mehr. Bestehende benannte Routen bleiben für Deep Links und alte Widgets
  erhalten.
- Das Material-3-Theme und die wiederverwendbaren UI-Bausteine liegen in
  `lib/core/ui/design_system.dart`. KPI-, Section-, Permission-, Sync-, Empty-
  und Error-Zustände sind damit nicht mehr an einzelne Seiten gebunden.

## State und Grenzen

`AppState` bleibt mit rund 2.000 Zeilen groß und enthält weiterhin Legacy-Flows
für Ernährung, Login, Remote-Lebensmittel, Offline-Queue und Benachrichtigungen.
Gewicht ist bereits über `WeightRepository`/`DriftWeightRepository` typisiert
eingeschleust. Health und Zyklus verwenden eigene Repository-/Controller-
Grenzen. `Clock`, `Units`, `AppFailure`/`Result` und redigierendes Logging liegen
unter `lib/core` und können in neuen Features direkt injiziert werden.

Der verbleibende direkte `DatabaseHelper`-Zugriff in Nutrition/Settings wird in
weiteren Strängen ersetzt; ein Big-Bang-Umbau ist absichtlich ausgeschlossen.

## Lokale Persistenz

Drift öffnet dieselbe `food_database.db` wie der bestehende sqflite-Pfad. Das
aktuelle Schema ist Version 27:

- v26: Metadaten, stabile UUIDs und Indizes für Legacy-Tabellen
- v27: Health-Connect-Rohdaten/Aggregate, Schlaf, Workouts, Routen, Zyklus,
  Benachrichtigungspräferenzen und Backup-Manifeste

Migrationen laufen transaktional, aktivieren Foreign Keys und werden gegen eine
v25-Fixture getestet. Legacy-IDs bleiben erhalten; neue UUIDs sind zunächst
nullable und werden deterministisch nachgefüllt.

## Health Connect und Aktivität

`HealthConnectSource` ist der Android-Adapter. Der Repository-Sync dedupliziert
Provider-UUIDs, führt pro Metric einen Cursor mit sechs Stunden Überlappung,
persistiert Status/Fehler und baut Tagesaggregate aus den bevorzugten Quellen
neu auf. Schlaf-, Workout- und Routendaten werden in eigenen Drift-Tabellen
gespeichert. Ein WorkManager-Task nutzt ein Zwei-Tage-Fenster und fordert keine
Berechtigungen im Hintergrund an.

Die Aktivitätsseite zeigt die lokalen Details offline-first. Routen werden nur
bei vorhandenen Punkten als `flutter_map`-Karte mit OpenStreetMap-Kacheln
gerendert.

## Zyklus

`DriftCycleRepository` bietet Profil-, Perioden- und Tageslog-CRUD inklusive
Validierung und sicherem Löschen. `CycleEngine` arbeitet deterministisch mit
Median/MAD-Ausreißerbehandlung, Unsicherheits-Konfidenz und erklärbarer
Rationale. Die UI bietet TableCalendar, Blutungs-/Symptom-/Stimmungs-/Schmerz-
und Energie-Check-ins sowie Historienstatistik. Der optionale Import von
Menstruationsdaten aus Health Connect ist noch nicht aktiviert.

## Sicherheit und Backup

- E-Mail/Passwort werden über `flutter_secure_storage` gespeichert. Eine
  einmalige Migration entfernt Legacy-Shared-Preferences erst nach erfolgreichem
  Secure-Write.
- Backups sind kategorisierbar, versioniert und optional AES-256-GCM-
  verschlüsselt (PBKDF2-HMAC-SHA256). Vor dem Restore werden Größe, Schema,
  Kategorien und Datensatzanzahl geprüft; der Merge läuft in einer Transaktion.
- Fehlertexte in neuen Controllern sind nutzersicher; technische Details gehen
  nur redigiert in den Logger. Build-Secrets bleiben ein offener Altbestand und
  werden nicht in Health-/Zykluspfade übernommen.

## Tests und CI

Der lokale Lauf umfasst 37 Tests inklusive Migration, Health-Sync/Deduplizierung,
Zyklus-Engine/Repository, Gewicht, Einheiten, Backup und Speech-to-Text. `flutter
analyze` ist fehlerfrei kompilierbar und meldet 152 bestehende Info-Hinweise.
Der Android-Workflow führt Analyze, Tests und Release-APK-Build auf Flutter
stable aus; lokal wurden Debug und Release separat verifiziert bzw. werden in
der Phasenbilanz dokumentiert.
