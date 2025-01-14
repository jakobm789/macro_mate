import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'models/app_state.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/weight_page.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  final initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final initializationSettingsIOS = DarwinInitializationSettings();
  final initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await notificationsPlugin.initialize(initializationSettings);
  await _checkNotificationPermission();
  String initialFilePath = PlatformDispatcher.instance.defaultRouteName;
  final appState = AppState();
  runApp(MaterialApp(home: const LoadingScreen()));
  await appState.initializeCompletely();
  appState.scheduleAllNotifications();
  runApp(ChangeNotifierProvider.value(value: appState, child: MyApp(initialFilePath: initialFilePath)));
}

Future<void> _checkNotificationPermission() async {
  if (Platform.isAndroid) {
    final version = (await Permission.notification.status).isGranted;
    if (!version) {
      final result = await Permission.notification.request();
      if (!result.isGranted) {
        return;
      }
    }
  }
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daten aus macro_mate_export.json erfolgreich importiert.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Die angegebene Datei existiert nicht.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Importieren der Daten: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Die gewählte Datei ist nicht macro_mate_export.json. Kein Import.')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, child) {
      if (!appState.isLoggedIn) {
        return MaterialApp(
          title: 'MacroMate',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent, brightness: Brightness.light),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const LoginPage(),
        );
      }
      return MaterialApp(
        title: 'MacroMate',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent, brightness: Brightness.light),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const MyHomePage(title: 'MacroMate'),
        routes: {
          '/settings': (context) => const SettingsPage(),
          '/weight': (context) => const WeightPage(),
        },
      );
    });
  }
}
