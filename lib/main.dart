// lib/main.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'models/app_state.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'package:path/path.dart' as p; // Für Dateiname-Prüfung
import 'package:path_provider/path_provider.dart'; // Falls benötigt

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prüfe, ob beim Starten der App ein bestimmter Pfad (Datei) übergeben wurde.
  // `PlatformDispatcher.instance.defaultRouteName` gibt unter bestimmten Umständen
  // den Pfad oder URI an, der zum Öffnen übergeben wurde.
  String initialFilePath = PlatformDispatcher.instance.defaultRouteName;

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(initialFilePath: initialFilePath),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialFilePath;

  const MyApp({super.key, required this.initialFilePath});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _importAttempted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Wir führen den Importvorgang nur einmal aus, um nicht bei jedem Build erneut zu importieren.
    if (!_importAttempted) {
      _importAttempted = true;
      _handleIncomingFile();
    }
  }

  Future<void> _handleIncomingFile() async {
    final appState = Provider.of<AppState>(context, listen: false);

    // Wenn kein Pfad oder nur "/" übergeben wurde, gibt es keine Datei zu laden.
    if (widget.initialFilePath == '/' || widget.initialFilePath.isEmpty) {
      return;
    }

    // Prüfe, ob es sich um eine Datei mit dem Namen "macro_mate_export.json" handelt.
    // Je nachdem wie das Betriebssystem den Pfad übergibt, müssen wir eventuell anpassen.
    // Hier nehmen wir an, dass wir einen absoluten Pfad oder einen URI bekommen.
    String filename = p.basename(widget.initialFilePath.toLowerCase());

    if (filename == 'macro_mate_export.json') {
      try {
        // Lese die Datei ein
        final file = File(widget.initialFilePath);
        if (await file.exists()) {
          String jsonData = await file.readAsString();
          // Importiere die Daten in die App-Datenbank
          await appState.importDatabase(jsonData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Daten aus macro_mate_export.json erfolgreich importiert.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Die angegebene Datei existiert nicht.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Importieren der Daten: $e')),
        );
      }
    } else {
      // Es ist keine passende Datei, daher ignorieren wir den Import.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Die gewählte Datei ist nicht macro_mate_export.json. Kein Import.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'MacroMate',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.lightBlueAccent,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.lightBlueAccent,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => const MyHomePage(title: 'MacroMate'),
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
