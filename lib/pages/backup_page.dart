import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/logging/app_logger.dart';
import '../models/app_state.dart';
import '../services/encrypted_backup_service.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final _passwordController = TextEditingController();
  final _logger = const AppLogger();
  bool _busy = false;
  String? _message;
  final Map<String, bool> _categories = {
    'nutrition': true,
    'goals': true,
    'settings': true,
    'weight': true,
    'health': true,
    'cycle': true,
    'notifications': true,
  };

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final password = _passwordController.text;
    if (password.length < 8) {
      setState(() =>
          _message = 'Bitte ein Passwort mit mindestens 8 Zeichen verwenden.');
      return;
    }
    final selected = _categories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toSet();
    if (selected.isEmpty) {
      setState(() => _message = 'Bitte mindestens eine Kategorie auswählen.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final json = await context.read<AppState>().exportDatabase(
            password: password,
            categories: selected,
          );
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(json)),
            mimeType: 'application/json',
            name: 'macromate-backup.json',
          ),
        ],
        subject: 'MacroMate Backup',
      );
      if (mounted) {
        setState(() =>
            _message = 'Backup erstellt. Bewahre das Passwort separat auf.');
      }
    } catch (error) {
      _logger.error('backup_export', error);
      if (mounted) {
        setState(() => _message =
            'Export fehlgeschlagen. Bitte Eingaben und Speicher prüfen.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _import() async {
    final appState = context.read<AppState>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final picked = result.files.single;
      final Uint8List bytes;
      if (picked.bytes != null) {
        bytes = picked.bytes!;
      } else if (picked.path != null) {
        bytes = await File(picked.path!).readAsBytes();
      } else {
        throw const FormatException('Datei konnte nicht gelesen werden.');
      }
      if (bytes.length > 25 * 1024 * 1024) {
        throw const FormatException('Das Backup ist größer als 25 MB.');
      }
      final rawJson = utf8.decode(bytes);
      final preview = await _decodeForPreview(rawJson);
      if (!mounted) return;
      final confirmed = await _confirmPreview(preview);
      if (!mounted || !confirmed) return;
      await appState.importDatabase(
        rawJson,
        password: _passwordController.text,
      );
      if (mounted) {
        setState(() => _message =
            'Backup importiert und mit dem Bestand zusammengeführt.');
      }
    } catch (error) {
      _logger.error('backup_import', error);
      if (mounted) {
        setState(() => _message =
            'Import fehlgeschlagen. Das Backup wurde nicht verändert.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<Map<String, dynamic>> _decodeForPreview(String rawJson) async {
    final decoded = jsonDecode(rawJson);
    if (decoded is Map && decoded['format'] == EncryptedBackupService.format) {
      if (_passwordController.text.isEmpty) {
        throw const FormatException(
            'Für die Vorschau wird das Backup-Passwort benötigt.');
      }
      return EncryptedBackupService().decrypt(
        rawJson,
        password: _passwordController.text,
      );
    }
    if (decoded is! Map) throw const FormatException('Ungültiges Backup.');
    return Map<String, dynamic>.from(decoded);
  }

  Future<bool> _confirmPreview(Map<String, dynamic> payload) async {
    final categories = (payload['categories'] as List?)
            ?.map((value) => value.toString())
            .toList() ??
        const <String>[];
    final recordCount = payload.entries
        .where((entry) => entry.value is List)
        .fold<int>(0, (sum, entry) => sum + (entry.value as List).length);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Backup prüfen'),
            content: Text(
              'Schema ${payload['schema_version'] ?? 'unbekannt'} · '
              '${payload['app_version'] ?? 'unbekannte App-Version'}\n'
              'Kategorien: ${categories.isEmpty ? 'Legacy/alle' : categories.join(', ')}\n'
              'Datensätze: $recordCount\n\n'
              'Der Restore führt lokale Daten zusammen und ersetzt keine Datenbankdatei.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Wiederherstellen'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Backup & Wiederherstellung')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Backups enthalten Ernährung, Gewicht, Gesundheitsdaten und Zyklus-Logs. '
                  'Sie werden lokal mit AES-256-GCM verschlüsselt; MacroMate lädt sie nicht hoch.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Exportkategorien',
                style: TextStyle(fontWeight: FontWeight.bold)),
            for (final category in _categories.keys)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: _categories[category],
                title: Text(_categoryLabel(category)),
                onChanged: _busy
                    ? null
                    : (value) =>
                        setState(() => _categories[category] = value ?? false),
              ),
            const SizedBox(height: 4),
            TextField(
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: const InputDecoration(
                labelText: 'Backup-Passwort',
                helperText: 'Mindestens 8 Zeichen; nicht im Backup gespeichert',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.lock),
              label: const Text('Verschlüsseltes Backup teilen'),
            ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _import,
              icon: const Icon(Icons.file_open),
              label: const Text('Backup importieren'),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_message!),
              ),
          ],
        ),
      );

  String _categoryLabel(String category) => switch (category) {
        'nutrition' => 'Ernährung und Lebensmittel',
        'goals' => 'Ziele',
        'settings' => 'Einstellungen',
        'weight' => 'Gewicht',
        'health' => 'Health Connect und Aktivität',
        'cycle' => 'Zyklus',
        'notifications' => 'Benachrichtigungen',
        _ => category,
      };
}
