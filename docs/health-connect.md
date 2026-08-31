# Health Connect

MacroMate liest Gesundheitsdaten ausschließlich nach einer expliziten Nutzerfreigabe. Die Android-Integration verwendet `health` und fragt Schritte, aktive/basale Kalorien, Distanz, Herzfrequenz, Schlaf und Workouts ab. Rohdaten werden in Drift dedupliziert (Provider-UUID) und pro lokalem Kalendertag aggregiert.

## Berechtigungen und Datenschutz

- Die App deklariert nur `READ_*`-Berechtigungen und schreibt keine Health-Connect-Daten.
- Historische Daten und Hintergrundzugriff sind separate Opt-ins.
- Ein Entzug löscht keine MacroMate-Daten, verhindert aber weitere Synchronisation.
- Rohpayloads bleiben lokal in `health_records.payload_json`; Backups sind optional AES-256-GCM-verschlüsselt.

## Synchronisation

Der manuelle Sync liest standardmäßig die letzten 30 Tage. Für jeden Datentyp wird ein eigener Cursor persistiert. Beim nächsten Lauf werden Cursor und ein sechs Stunden langer Überlappungsbereich gelesen, damit verspätete oder korrigierte Samples nicht verloren gehen. Provider-UUIDs verhindern Doppelzählungen; bei konkurrierenden Quellen gewinnt die dokumentierte Priorität (Samsung, Garmin/Fitbit, Wearables, Google/Telefon).

Ein WorkManager-Task aktualisiert bei aktiviertem Hintergrundzugriff ein gleitendes Zwei-Tage-Fenster alle sechs Stunden. Ein Fehler führt zu einem fehlgeschlagenen Task und wird beim nächsten Lauf erneut versucht; Berechtigungen werden niemals aus dem Worker heraus angefordert. Die Seite zeigt Cursor, letzten Erfolg, Fehler, Quellen und Datensatzanzahl als Diagnose an.

Schlaf, Workouts und optionale Routen werden zusätzlich in `sleep_sessions`, `workout_sessions` und `workout_route_points` abgelegt. Die Aktivitätsansicht zeigt Dauer, Distanz, Pace und – falls vorhanden – eine OpenStreetMap-Karte. Die Kartenkacheln werden nur bei geöffneter Routendetailansicht angefordert.

## Android-Konfiguration

`MainActivity` verwendet `FlutterFragmentActivity`, weil Health Connect ab Android 14 den Activity-Result-API-Pfad nutzt. Die Manifest-Datei enthält außerdem die Health-Connect-Paketabfrage, die Rationale-Intent-Filter und das Permission-Usage-Alias. iOS/HealthKit bleibt außerhalb des beauftragten Android-Scopes.
