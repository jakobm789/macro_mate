import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'models/app_state.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/weight_page.dart';
import 'pages/weekly_dashboard_page.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

class AppDiagnosticsBanner extends StatelessWidget {
  final Widget child;
  const AppDiagnosticsBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final error = appState.lastUiError;
        if (error == null || error.isEmpty) {
          return child;
        }

        return Stack(
          children: [
            child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Material(
                  color: Colors.red.shade800,
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Diagnose: $error',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Ausblenden',
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: appState.clearUiError,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initializationSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/launcher_icon',
  );
  final initializationSettingsIOS = DarwinInitializationSettings();
  final initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await notificationsPlugin.initialize(initializationSettings);
  String initialFilePath = PlatformDispatcher.instance.defaultRouteName;
  final appState = AppState();
  
  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MyApp(initialFilePath: initialFilePath),
    ),
  );
}

Future<void> _checkNotificationPermission() async {
  if (Platform.isAndroid || Platform.isIOS) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
    if (Platform.isAndroid) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (!exactAlarmStatus.isGranted) {
        await Permission.scheduleExactAlarm.request();
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
  bool _initializationStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_importAttempted) {
      _importAttempted = true;
      _handleIncomingFile();
    }
    if (!_initializationStarted) {
      _initializationStarted = true;
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final appState = Provider.of<AppState>(context, listen: false);
    // Yield to let Flutter draw the first frame (LoadingScreen) and remove the native splash screen
    await Future.delayed(Duration.zero);
    try {
      await _checkNotificationPermission();
    } catch (e, st) {
      appState.reportUiError('checkNotificationPermission', e, st);
    }
    try {
      await appState.initializeCompletely();
    } catch (e, st) {
      appState.reportUiError('initializeCompletely', e, st);
    }
    try {
      await appState.scheduleAllNotifications().timeout(
            const Duration(seconds: 8),
          );
    } catch (e, st) {
      appState.reportUiError('scheduleAllNotifications', e, st);
    }
    appState.markInitialized();
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
            const SnackBar(
              content: Text(
                'Daten aus macro_mate_export.json erfolgreich importiert.',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Die angegebene Datei existiert nicht.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Importieren der Daten: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Die gewählte Datei ist nicht macro_mate_export.json. Kein Import.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (!appState.isInitialized) {
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
            home: const LoadingScreen(),
          );
        }
        
        if (!appState.isLoggedIn) {
          return MaterialApp(
            title: 'MacroMate',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.lightBlueAccent,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.lightBlueAccent,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AppDiagnosticsBanner(child: LoginPage()),
          );
        }
        return MaterialApp(
          title: 'MacroMate',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.lightBlueAccent,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.lightBlueAccent,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const AppDiagnosticsBanner(
            child: MyHomePage(title: 'MacroMate'),
          ),
          routes: {
            '/settings': (context) =>
                const AppDiagnosticsBanner(child: SettingsPage()),
            '/weight': (context) =>
                const AppDiagnosticsBanner(child: WeightPage()),
            '/weekly_dashboard': (context) =>
                const AppDiagnosticsBanner(child: WeeklyDashboardPage()),
          },
        );
      },
    );
  }
}
