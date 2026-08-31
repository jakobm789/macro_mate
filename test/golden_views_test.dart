import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/core/notifications/drift_notification_repository.dart';
import 'package:macro_mate/core/notifications/notification_controller.dart';
import 'package:macro_mate/features/activity/presentation/activity_controller.dart';
import 'package:macro_mate/features/activity/presentation/activity_page.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_controller.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_page.dart';
import 'package:macro_mate/features/dashboard/presentation/dashboard_config_sheet.dart';
import 'package:macro_mate/features/dashboard/presentation/dashboard_controller.dart';
import 'package:macro_mate/features/dashboard/presentation/today_page.dart';
import 'package:macro_mate/features/health/data/drift_health_repository.dart';
import 'package:macro_mate/features/health/presentation/health_controller.dart';
import 'package:macro_mate/features/health/presentation/health_page.dart';
import 'package:macro_mate/features/notifications/presentation/notification_settings_page.dart';
import 'package:macro_mate/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:macro_mate/features/nutrition/presentation/nutrition_controller.dart';
import 'package:macro_mate/features/settings/data/drift_settings_repository.dart';
import 'package:macro_mate/features/settings/presentation/settings_controller.dart';
import 'package:macro_mate/features/weight/data/drift_weight_repository.dart';
import 'package:macro_mate/features/weight/presentation/weight_controller.dart';
import 'package:macro_mate/models/app_state.dart';
import 'package:macro_mate/pages/backup_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_health_connect_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late NutritionController nutritionController;
  late WeightController weightController;
  late HealthController healthController;
  late ActivityController activityController;
  late CycleController cycleController;
  late SettingsController settingsController;
  late DashboardController dashboardController;
  late NotificationController notificationController;
  late AppState appState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());

    final nutritionRepo = DriftNutritionRepository(database: db);
    final weightRepo = DriftWeightRepository(database: db);
    final settingsRepo = DriftSettingsRepository(database: db);
    final cycleRepo = DriftCycleRepository(database: db);
    final fakeSource = FakeHealthConnectSource();
    final healthRepo = DriftHealthRepository(database: db, source: fakeSource);
    final notificationRepo = DriftNotificationRepository(database: db);

    nutritionController = NutritionController(repository: nutritionRepo);
    weightController = WeightController(repository: weightRepo);
    healthController = HealthController(repository: healthRepo);
    activityController = ActivityController(repository: healthRepo);
    cycleController = CycleController(
      repository: cycleRepo,
      healthRepository: healthRepo,
    );
    settingsController = SettingsController(repository: settingsRepo);
    notificationController =
        NotificationController(repository: notificationRepo);

    dashboardController = DashboardController(
      nutritionController: nutritionController,
      weightController: weightController,
      healthController: healthController,
      activityController: activityController,
      cycleController: cycleController,
      settingsController: settingsController,
    );

    appState = AppState(
      database: db,
      nutritionRepository: nutritionRepo,
      weightRepository: weightRepo,
      settingsRepository: settingsRepo,
      healthRepository: healthRepo,
      cycleRepository: cycleRepo,
      notificationRepository: notificationRepo,
      nutritionCtrl: nutritionController,
      weightCtrl: weightController,
      healthCtrl: healthController,
      activityCtrl: activityController,
      cycleCtrl: cycleController,
      settingsCtrl: settingsController,
      dashboardCtrl: dashboardController,
      notificationCtrl: notificationController,
    );

    await notificationController.initialize();
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrapWithProviders(
    Widget child, {
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
  }) {
    final theme = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          )
        : ThemeData.light(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
          );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<DashboardController>.value(
          value: dashboardController,
        ),
        ChangeNotifierProvider<NutritionController>.value(
          value: nutritionController,
        ),
        ChangeNotifierProvider<WeightController>.value(value: weightController),
        ChangeNotifierProvider<HealthController>.value(value: healthController),
        ChangeNotifierProvider<ActivityController>.value(
          value: activityController,
        ),
        ChangeNotifierProvider<CycleController>.value(value: cycleController),
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
        ),
        ChangeNotifierProvider<NotificationController>.value(
          value: notificationController,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child,
        ),
      ),
    );
  }

  Future<void> testScreenGolden({
    required WidgetTester tester,
    required Widget child,
    required String goldenName,
    Size size = const Size(412, 915),
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size * 2.0;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      wrapWithProviders(
        child,
        brightness: brightness,
        textScale: textScale,
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$goldenName.png'),
    );
  }

  group('Golden Views & Layout Regression Tests', () {
    testWidgets('TodayPage renders in Light Mode (412x915)', (tester) async {
      await testScreenGolden(
        tester: tester,
        child: const TodayPage(),
        goldenName: 'today_page_light',
        brightness: Brightness.light,
      );
    });

    testWidgets('TodayPage renders in Dark Mode (412x915)', (tester) async {
      await testScreenGolden(
        tester: tester,
        child: const TodayPage(),
        goldenName: 'today_page_dark',
        brightness: Brightness.dark,
      );
    });

    testWidgets('TodayPage renders on Small Phone (360x640)', (tester) async {
      await testScreenGolden(
        tester: tester,
        child: const TodayPage(),
        goldenName: 'today_page_small_phone',
        size: const Size(360, 640),
        brightness: Brightness.light,
      );
    });

    testWidgets('TodayPage renders with Large Text Scaling (1.5x)',
        (tester) async {
      await testScreenGolden(
        tester: tester,
        child: const TodayPage(),
        goldenName: 'today_page_large_text',
        brightness: Brightness.light,
        textScale: 1.5,
      );
    });

    testWidgets('ActivityPage renders in Light Mode', (tester) async {
      await testScreenGolden(
        tester: tester,
        child: ActivityPage(database: db),
        goldenName: 'activity_page_light',
        brightness: Brightness.light,
      );
    });

    testWidgets('ActivityPage renders in Dark Mode', (tester) async {
      await testScreenGolden(
        tester: tester,
        child: ActivityPage(database: db),
        goldenName: 'activity_page_dark',
        brightness: Brightness.dark,
      );
    });

    testWidgets('CyclePage renders in Light Mode', (tester) async {
      await testScreenGolden(
        tester: tester,
        child: CyclePage(database: db, controller: cycleController),
        goldenName: 'cycle_page_light',
        brightness: Brightness.light,
      );
    });

    testWidgets('CyclePage renders in Dark Mode', (tester) async {
      await testScreenGolden(
        tester: tester,
        child: CyclePage(database: db, controller: cycleController),
        goldenName: 'cycle_page_dark',
        brightness: Brightness.dark,
      );
    });

    testWidgets('HealthPage renders Diagnostics & Permissions in Light Mode',
        (tester) async {
      await testScreenGolden(
        tester: tester,
        child: HealthPage(database: db, controller: healthController),
        goldenName: 'health_page_light',
        brightness: Brightness.light,
      );
    });

    testWidgets('NotificationSettingsPage renders in Light Mode',
        (tester) async {
      await testScreenGolden(
        tester: tester,
        child: const NotificationSettingsPage(),
        goldenName: 'notifications_settings_light',
        brightness: Brightness.light,
      );
    });

    testWidgets('NotificationSettingsPage renders in Dark Mode',
        (tester) async {
      await testScreenGolden(
        tester: tester,
        child: const NotificationSettingsPage(),
        goldenName: 'notifications_settings_dark',
        brightness: Brightness.dark,
      );
    });

    testWidgets('BackupPage renders in Light Mode', (tester) async {
      await testScreenGolden(
        tester: tester,
        child: const BackupPage(),
        goldenName: 'backup_page_light',
        brightness: Brightness.light,
      );
    });

    testWidgets('DashboardConfigSheet renders in Light Mode', (tester) async {
      await testScreenGolden(
        tester: tester,
        child: const Scaffold(
          body: DashboardConfigSheet(),
        ),
        goldenName: 'dashboard_config_sheet_light',
        brightness: Brightness.light,
      );
    });
  });
}
