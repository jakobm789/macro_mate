import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'models/app_state.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/weight_page.dart';
import 'pages/weekly_dashboard_page.dart';
import 'features/health/presentation/health_page.dart';
import 'features/health/data/health_background_sync.dart';
import 'features/cycle/presentation/cycle_page.dart';
import 'pages/backup_page.dart';
import 'app/navigation/app_shell.dart';
import 'features/activity/presentation/activity_page.dart';
import 'features/gym/presentation/gym_page.dart';
import 'features/gym/presentation/gym_controller.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'features/activity/presentation/activity_controller.dart';
import 'features/activity/presentation/live_running_tracker_page.dart';
import 'features/activity/presentation/running_tracker_controller.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/backup/presentation/backup_controller.dart';
import 'features/cycle/presentation/cycle_controller.dart';
import 'features/dashboard/presentation/dashboard_controller.dart';
import 'features/health/presentation/health_controller.dart';
import 'features/local_llm/presentation/local_model_controller.dart';
import 'features/nutrition/presentation/food_search_controller.dart';
import 'features/nutrition/presentation/import_export_controller.dart';
import 'features/nutrition/presentation/nutrition_controller.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'features/weight/presentation/weight_controller.dart';
import 'core/notifications/notification_controller.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
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
  await FlutterGemma.initialize(
    huggingFaceToken: const String.fromEnvironment('HUGGINGFACE_TOKEN').isEmpty
        ? null
        : const String.fromEnvironment('HUGGINGFACE_TOKEN'),
    maxDownloadRetries: 10,
  );
  const initializationSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/launcher_icon',
  );
  const initializationSettingsIOS = DarwinInitializationSettings();
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await notificationsPlugin.initialize(initializationSettings);
  String initialFilePath = PlatformDispatcher.instance.defaultRouteName;
  final appState = AppState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<NutritionController>.value(
          value: appState.nutritionController,
        ),
        ChangeNotifierProvider<WeightController>.value(
          value: appState.weightController,
        ),
        ChangeNotifierProvider<HealthController>.value(
          value: appState.healthController,
        ),
        ChangeNotifierProvider<ActivityController>.value(
          value: appState.activityController,
        ),
        ChangeNotifierProvider<CycleController>.value(
          value: appState.cycleController,
        ),
        ChangeNotifierProvider<SettingsController>.value(
          value: appState.settingsController,
        ),
        ChangeNotifierProvider<LocalModelController>.value(
          value: appState.localModelController,
        ),
        ChangeNotifierProvider<DashboardController>.value(
          value: appState.dashboardController,
        ),
        ChangeNotifierProvider<NotificationController>.value(
          value: appState.notificationController,
        ),
        ChangeNotifierProvider<AuthController>.value(
          value: appState.authController,
        ),
        ChangeNotifierProvider<BackupController>.value(
          value: appState.backupController,
        ),
        ChangeNotifierProvider<FoodSearchController>.value(
          value: appState.foodSearchController,
        ),
        ChangeNotifierProvider<ImportExportController>.value(
          value: appState.importExportController,
        ),
        ChangeNotifierProvider<GymController>.value(
          value: appState.gymController,
        ),
        ChangeNotifierProvider<RunningTrackerController>.value(
          value: appState.runningTrackerController,
        ),
      ],
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
      await initializeHealthBackgroundSync();
    } catch (e, st) {
      // Background execution is optional and unsupported on desktop.
      appState.reportUiError('initializeHealthBackgroundSync', e, st);
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
        final exists = await file.exists();
        if (!mounted) return;
        if (exists) {
          String jsonData = await file.readAsString();
          if (!mounted) return;
          await appState.importDatabase(jsonData);
          if (!mounted) return;
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Importieren der Daten: $e')),
        );
      }
    } else {
      if (!mounted) return;
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
      builder: (context, appState, _) => MaterialApp(
        title: 'MacroMate',
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const AppRoot(),
        routes: {
          '/nutrition': (context) =>
              const AppDiagnosticsBanner(child: MyHomePage(title: 'MacroMate')),
          '/settings': (context) =>
              const AppDiagnosticsBanner(child: SettingsPage()),
          '/weight': (context) =>
              const AppDiagnosticsBanner(child: WeightPage()),
          '/weekly_dashboard': (context) =>
              const AppDiagnosticsBanner(child: WeeklyDashboardPage()),
          '/health': (context) =>
              const AppDiagnosticsBanner(child: HealthPage()),
          '/activity': (context) =>
              const AppDiagnosticsBanner(child: ActivityPage()),
          '/cycle': (context) => const AppDiagnosticsBanner(child: CyclePage()),
          '/backup': (context) =>
              const AppDiagnosticsBanner(child: BackupPage()),
          '/gym': (context) =>
              const AppDiagnosticsBanner(child: GymPage()),
          '/tracker': (context) =>
              const AppDiagnosticsBanner(child: LiveRunningTrackerPage()),
        },
      ),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.lightBlueAccent,
        brightness: brightness,
      ),
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (!appState.isInitialized) return const LoadingScreen();
        if (!appState.isLoggedIn) {
          return const AppDiagnosticsBanner(child: LoginPage());
        }
        return const AppDiagnosticsBanner(child: AppShell());
      },
    );
  }
}
