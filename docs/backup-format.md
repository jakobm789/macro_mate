# Backup-Format

## Unverschlüsseltes Legacy-Format

`DatabaseHelper.exportData()` liefert weiterhin JSON mit den bisherigen Tabellen-Schlüsseln. Zusätzlich enthält es `format`, `format_version`, `schema_version`, `app_version`, `created_at_utc` und `categories`. Die Oberfläche erlaubt die Auswahl von Ernährung, Zielen, Einstellungen, Gewicht, Health/Aktivität, Zyklus und Benachrichtigungen. Alte Exporte ohne Metadaten bleiben importierbar.

## Verschlüsseltes Format v3

`EncryptedBackupService` verpackt den Export in ein JSON-Envelope:

- `algorithm`: `AES-256-GCM`
- `kdf`: `PBKDF2-HMAC-SHA256`, 210000 Iterationen
- zufälliges 16-Byte-Salt und zufälliger GCM-Nonce
- authentifizierter Ciphertext inklusive MAC
- `schema_version`, `app_version` und Erstellzeitpunkt als Metadaten
- Größenlimit von 25 MB vor dem Lesen; Vorschau mit Schema, Kategorien und Datensatzanzahl vor dem Restore

Das Passwort wird nicht gespeichert. Ein falsches Passwort oder veränderter Ciphertext bricht den Import mit einem Authentifizierungsfehler ab. Der Import läuft in einer SQLite-Transaktion und wird bei einem Fehler vollständig zurückgerollt; er führt Daten zusammen und ersetzt keine lokale Datenbankdatei. Backups mit einer höheren als Schema-Version 27 werden vor dem Restore abgewiesen. Envelope-Version 2 bleibt lesbar, Version 3 ist der aktuelle Standard.
