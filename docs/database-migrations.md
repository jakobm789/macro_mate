# Datenbank-Migrationen

Die bestehende sqflite-Datenbank bleibt kompatibel. Drift verwendet dasselbe `food_database.db` und startet bei Schema 27:

- **v26:** deterministische UUIDs für Legacy-Zeilen, Metadatensatz und Suchindizes.
- **v27:** Health-Connect-Rohdaten/Aggregate, Schlaf/Workout/Route, Zyklusprofile/-logs/-prognosen, Benachrichtigungspräferenzen und Backup-Manifeste.

Migrationen sind vorwärtsgerichtet, transaktional innerhalb von Drift und aktivieren `PRAGMA foreign_keys = ON`. Die Legacy-Fallback-Schicht (`DatabaseHelper`) führt beim Öffnen dieselben Tabellen und Indizes an, damit ältere Installationen ohne Datenverlust weiterlaufen.

Jede Migration braucht eine Fixture- oder Regressionstestdatei. Für v25→v27 prüft der Test Legacy-Zeilen, deterministische UUIDs, Metadaten, neue Tabellen und Indizes.
