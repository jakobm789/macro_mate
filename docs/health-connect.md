# Health Connect

MacroMate liest Gesundheitsdaten ausschließlich nach einer expliziten Nutzerfreigabe. Die Android-Integration verwendet `health` und fragt Schritte, aktive/basale Kalorien, Distanz, Herzfrequenz, Schlaf und Workouts ab. Rohdaten werden in Drift dedupliziert (Provider-UUID) und pro lokalem Kalendertag aggregiert.

## Berechtigungen und Datenschutz

- Die App deklariert nur `READ_*`-Berechtigungen; sie schreibt keine Health-Connect-Daten.
- Historische Daten und Hintergrundzugriff sind separate Opt-ins.
- Ein Health-Connect-Entzug löscht keine MacroMate-Daten, verhindert aber weitere Synchronisation.
- Rohpayloads bleiben lokal in `health_records.payload_json`; Backups sind optional AES-256-GCM-verschlüsselt.

## Synchronisation

Der manuelle Sync liest standardmäßig die letzten 30 Tage. Ein WorkManager-Task aktualisiert bei aktiviertem Hintergrundzugriff ein gleitendes Zwei-Tage-Fenster alle sechs Stunden. Ein Fehler führt zu einem fehlgeschlagenen Task und wird beim nächsten Lauf erneut versucht; Berechtigungen werden niemals aus dem Worker heraus angefordert.

## Android-Konfiguration

`MainActivity` muss `FlutterFragmentActivity` verwenden, weil Health Connect ab Android 14 den Activity-Result-API-Pfad nutzt. Die Manifest-Datei enthält außerdem die Health-Connect-Paketabfrage, die Rationale-Intent-Filter und das Permission-Usage-Alias.
