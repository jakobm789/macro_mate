# Backup-Format

## Unverschlüsseltes Legacy-Format

`DatabaseHelper.exportData()` liefert weiterhin JSON mit den bisherigen Tabellen-Schlüsseln. Zusätzlich enthält es `format`, `format_version`, `schema_version`, `app_version`, `created_at_utc` und `categories`. Alte Exporte ohne Metadaten bleiben importierbar.

## Verschlüsseltes Format v3

`EncryptedBackupService` verpackt den Export in ein JSON-Envelope:

- `algorithm`: `AES-256-GCM`
- `kdf`: `PBKDF2-HMAC-SHA256`, 210000 Iterationen
- zufälliges 16-Byte-Salt und zufälliger GCM-Nonce
- authentifizierter Ciphertext inklusive MAC
- `schema_version`, `app_version` und Erstellzeitpunkt als Metadaten

Das Passwort wird nicht gespeichert. Ein falsches Passwort oder veränderter Ciphertext bricht den Import mit einem Authentifizierungsfehler ab. Der Import führt Daten zusammen und ersetzt keine lokale Datenbankdatei; unbekannte Felder werden ignoriert.
