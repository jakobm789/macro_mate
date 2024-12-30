// lib/main.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'models/app_state.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart'; // <-- NEU: Login-Seite importieren
import 'package:path/path.dart' as p; // Für Dateiname-Prüfung
import 'package:path_provider/path_provider.dart'; // Falls benötigt

/// Simple LoadingScreen, der angezeigt wird, solange AppState noch initialisiert.
/// Hier mit drehendem CircularProgressIndicator und dunklem Hintergrund.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Wir setzen den Hintergrund dunkel, damit der Spinner gut sichtbar ist.
      backgroundColor: Colors.black87,
      body: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prüfe, ob beim Starten der App ein bestimmter Pfad (Datei) übergeben wurde.
  String initialFilePath = PlatformDispatcher.instance.defaultRouteName;

  /// Wir erstellen unseren AppState-Provider
  final appState = AppState();

  /// Bevor wir das UI aufbauen, warten wir, bis appState vollständig initialisiert ist.
  /// Währenddessen zeigen wir kurz den LoadingScreen mit dem drehenden Spinner.
  runApp(
    MaterialApp(
      home: const LoadingScreen(),
    ),
  );

  // AppState-Logik laden
  await appState.initializeCompletely();

  // Jetzt mit fertig initialisiertem AppState unsere Haupt-App starten
  runApp(
    ChangeNotifierProvider.value(
      value: appState,
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

    // Wir führen den Importvorgang nur einmal aus
    if (!_importAttempted) {
      _importAttempted = true;
      _handleIncomingFile();
    }
  }

  Future<void> _handleIncomingFile() async {
    final appState = Provider.of<AppState>(context, listen: false);

    if (widget.initialFilePath == '/' || widget.initialFilePath.isEmpty) {
      return;
    }

    String filename = p.basename(widget.initialFilePath.toLowerCase());

    if (filename == 'macro_mate_export.json') {
      try {
        final file = File(widget.initialFilePath);
        if (await file.exists()) {
          String jsonData = await file.readAsString();
          await appState.importDatabase(jsonData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Daten aus macro_mate_export.json erfolgreich importiert.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Die angegebene Datei existiert nicht.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Importieren der Daten: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Die gewählte Datei ist nicht macro_mate_export.json. Kein Import.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Hier holen wir den aktuellen AppState. 
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Falls der User nicht eingeloggt ist, zeigen wir die LoginPage
        if (!appState.isLoggedIn) {
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
            // Statt initialRoute => home: ...
            home: const LoginPage(),
          );
        }

        // Wenn eingeloggt, normale HomePage + Settings
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
          // Wir setzen KEIN initialRoute, sondern "home"
          home: const MyHomePage(title: 'MacroMate'),
          routes: {
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
