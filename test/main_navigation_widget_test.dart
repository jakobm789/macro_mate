import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/app/navigation/app_shell.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/activity/presentation/activity_controller.dart';
import 'package:macro_mate/features/activity/presentation/activity_page.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_controller.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_page.dart';
import 'package:macro_mate/features/dashboard/presentation/dashboard_controller.dart';
import 'package:macro_mate/features/health/data/drift_health_repository.dart';
import 'package:macro_mate/features/health/presentation/health_controller.dart';
import 'package:macro_mate/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:macro_mate/features/nutrition/presentation/nutrition_controller.dart';
import 'package:macro_mate/features/settings/data/drift_settings_repository.dart';
import 'package:macro_mate/features/settings/presentation/settings_controller.dart';
import 'package:macro_mate/features/weight/data/drift_weight_repository.dart';
import 'package:macro_mate/features/weight/presentation/weight_controller.dart';
import 'package:macro_mate/models/app_state.dart';
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

  Widget createShellWidget() {
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
        home: AppShell(database: db),
      ),
    );
  }

  group('Main App Navigation & Tabs Widget Tests', () {
    testWidgets('switches between all 5 main bottom navigation tabs', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createShellWidget());
      await tester.pump(const Duration(milliseconds: 200));

      // Tab 0: Heute
      expect(find.text('Dein Überblick'), findsOneWidget);

      // Tap Tab 1: Ernährung
      await tester.tap(find.byIcon(Icons.restaurant_outlined));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byIcon(Icons.restaurant), findsWidgets);

      // Tap Tab 2: Aktivität
      await tester.tap(find.byIcon(Icons.directions_run_outlined));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ActivityPage), findsOneWidget);

      // Tap Tab 3: Zyklus
      await tester.tap(find.byIcon(Icons.water_drop_outlined));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(CyclePage), findsOneWidget);
      expect(find.text('Zyklus & Wohlbefinden'), findsOneWidget);

      // Tap Tab 4: Mehr
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(MorePage), findsOneWidget);
      expect(find.text('Verwalten'), findsOneWidget);
      expect(find.text('Gewicht'), findsOneWidget);
      expect(find.text('Einstellungen'), findsOneWidget);
      expect(find.text('Health Connect & Diagnose'), findsOneWidget);
      expect(find.text('Backup & Wiederherstellung'), findsOneWidget);
    });
  });
}
