import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_state.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final _passwordController = TextEditingController();
  bool _busy = false;
  String? _message;

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
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final json =
          await context.read<AppState>().exportDatabase(password: password);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(utf8.encode(json)),
              mimeType: 'application/json',
            ),
          ],
          fileNameOverrides: const ['macromate-backup.json'],
          subject: 'MacroMate Backup',
          title: 'Verschlüsseltes MacroMate-Backup',
        ),
      );
      if (mounted) {
        setState(() =>
            _message = 'Backup erstellt. Bewahre das Passwort separat auf.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Export fehlgeschlagen: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _import() async {
    final appState = context.read<AppState>();
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final bytes = await files.single.readAsBytes();
      await appState.importDatabase(
        utf8.decode(bytes),
        password: _passwordController.text,
      );
      if (mounted) {
        setState(() => _message =
            'Backup importiert und mit dem Bestand zusammengeführt.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Import fehlgeschlagen: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
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
}
