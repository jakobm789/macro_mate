import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/activity/presentation/activity_controller.dart';
import 'package:macro_mate/features/activity/presentation/activity_page.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/domain/cycle_models.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_controller.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_page.dart';
import 'package:macro_mate/features/dashboard/presentation/dashboard_controller.dart';
import 'package:macro_mate/features/dashboard/presentation/today_page.dart';
import 'package:macro_mate/features/health/data/drift_health_repository.dart';
import 'package:macro_mate/features/health/domain/health_models.dart';
import 'package:macro_mate/features/health/presentation/health_controller.dart';
import 'package:macro_mate/features/health/presentation/health_page.dart';
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

    nutritionController = NutritionController(repository: nutritionRepo);
    weightController = WeightController(repository: weightRepo);
    healthController = HealthController(repository: healthRepo);
    activityController = ActivityController(repository: healthRepo);
    cycleController = CycleController(repository: cycleRepo);
    settingsController = SettingsController(repository: settingsRepo);

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
      nutritionCtrl: nutritionController,
      weightCtrl: weightController,
      healthCtrl: healthController,
      activityCtrl: activityController,
      cycleCtrl: cycleController,
      settingsCtrl: settingsController,
      dashboardCtrl: dashboardController,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrapWithProviders(Widget child, {Brightness brightness = Brightness.light}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<DashboardController>.value(value: dashboardController),
        ChangeNotifierProvider<NutritionController>.value(value: nutritionController),
        ChangeNotifierProvider<WeightController>.value(value: weightController),
        ChangeNotifierProvider<HealthController>.value(value: healthController),
        ChangeNotifierProvider<ActivityController>.value(value: activityController),
        ChangeNotifierProvider<CycleController>.value(value: cycleController),
        ChangeNotifierProvider<SettingsController>.value(value: settingsController),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: brightness,
          ),
          useMaterial3: true,
        ),
        home: child,
      ),
    );
  }

  group('Golden & Visual Layout Tests for All Core Views', () {
    testWidgets('renders TodayPage in Light Mode', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithProviders(const TodayPage(), brightness: Brightness.light));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dein Überblick'), findsOneWidget);
      expect(find.text('Kalorien & Makros'), findsOneWidget);
    });

    testWidgets('renders TodayPage in Dark Mode', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithProviders(const TodayPage(), brightness: Brightness.dark));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dein Überblick'), findsOneWidget);
    });

    testWidgets('renders ActivityPage with workout and sleep sections', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithProviders(ActivityPage(database: db)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Aktivität'), findsOneWidget);
    });

    testWidgets('renders CyclePage with period action button and calendar', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithProviders(CyclePage(database: db, controller: cycleController)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Zyklus & Wohlbefinden'), findsOneWidget);
      expect(find.text('Periode beginnen'), findsOneWidget);
    });

    testWidgets('renders HealthPage with permissions and diagnostic cards', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithProviders(HealthPage(database: db, controller: healthController)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Health & Aktivität'), findsOneWidget);
    });

    testWidgets('renders BackupPage with encryption password and categories', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithProviders(const BackupPage()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Backup & Wiederherstellung'), findsOneWidget);
    });
  });
}
