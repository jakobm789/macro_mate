import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/activity/presentation/activity_controller.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_controller.dart';
import 'package:macro_mate/features/dashboard/presentation/dashboard_controller.dart';
import 'package:macro_mate/features/dashboard/presentation/step_goal_sheet.dart';
import 'package:macro_mate/features/dashboard/presentation/today_page.dart';
import 'package:macro_mate/features/health/data/drift_health_repository.dart';
import 'package:macro_mate/features/health/data/health_connect_source.dart';
import 'package:macro_mate/features/health/presentation/health_controller.dart';
import 'package:macro_mate/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:macro_mate/features/nutrition/presentation/nutrition_controller.dart';
import 'package:macro_mate/features/settings/data/drift_settings_repository.dart';
import 'package:macro_mate/features/settings/presentation/settings_controller.dart';
import 'package:macro_mate/features/weight/data/drift_weight_repository.dart';
import 'package:macro_mate/features/weight/presentation/weight_controller.dart';
import 'package:macro_mate/models/app_state.dart';
import 'package:macro_mate/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftSettingsRepository settingsRepo;
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
    settingsRepo = DriftSettingsRepository(database: db);
    final cycleRepo = DriftCycleRepository(database: db);
    final healthRepo = DriftHealthRepository(
      database: db,
      source: HealthConnectSource(),
    );

    nutritionController = NutritionController(repository: nutritionRepo);
    weightController = WeightController(repository: weightRepo);
    healthController = HealthController(repository: healthRepo);
    activityController = ActivityController(repository: healthRepo);
    cycleController = CycleController(repository: cycleRepo);
    settingsController = SettingsController(repository: settingsRepo);
    await settingsController.initialize();

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

  Widget createTodayTestWidget() {
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
      ],
      child: const MaterialApp(home: TodayPage()),
    );
  }

  Widget createSettingsTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
        ),
      ],
      child: const MaterialApp(home: SettingsPage()),
    );
  }

  group('Step Goal Model & Persistence', () {
    test('UserGoals defaults stepGoal to 10000', () {
      const goals = UserGoals();
      expect(goals.stepGoal, 10000);
    });

    test('UserGoals copyWith and serialization retain stepGoal', () {
      const goals = UserGoals(stepGoal: 8500);
      final updated = goals.copyWith(stepGoal: 12000);
      expect(updated.stepGoal, 12000);

      final map = updated.toMap();
      expect(map['stepGoal'], 12000);

      final restored = UserGoals.fromMap(map);
      expect(restored.stepGoal, 12000);
    });

    test('DriftSettingsRepository saves and restores stepGoal', () async {
      final initial = await settingsRepo.getGoals();
      expect(initial.stepGoal, 10000);

      await settingsRepo.updateGoals(initial.copyWith(stepGoal: 15000));
      final reloaded = await settingsRepo.getGoals();
      expect(reloaded.stepGoal, 15000);
    });
  });

  group('DashboardController Step Goal Management', () {
    test('Defaults to 10000 and can be updated via updateStepGoal', () async {
      expect(dashboardController.stepGoal, 10000);

      bool notified = false;
      dashboardController.addListener(() {
        notified = true;
      });

      await dashboardController.updateStepGoal(7500);
      expect(dashboardController.stepGoal, 7500);
      expect(settingsController.goals.stepGoal, 7500);
      expect(appState.dailyStepGoal, 7500);
      expect(notified, isTrue);

      // Non-positive goals are ignored
      await dashboardController.updateStepGoal(0);
      expect(dashboardController.stepGoal, 7500);
      await dashboardController.updateStepGoal(-500);
      expect(dashboardController.stepGoal, 7500);
    });
  });

  group('TodayPage Step Goal UI & StepGoalSheet', () {
    testWidgets('Displays current step goal in subtitle and opens bottom sheet',
        (tester) async {
      await tester.pumpWidget(createTodayTestWidget());
      await tester.pumpAndSettle();

      // Card should be present with default Ziel: 10.000
      expect(find.text('Schritte & Distanz'), findsOneWidget);
      expect(
        find.textContaining('Ziel: 10.000'),
        findsOneWidget,
      );

      // Tap on steps card to open bottom sheet
      await tester.tap(find.text('Schritte & Distanz'));
      await tester.pumpAndSettle();

      // Verify StepGoalSheet is displayed
      expect(find.byType(StepGoalSheet), findsOneWidget);
      expect(find.text('Tägliches Schritteziel'), findsOneWidget);
      expect(find.text('Schnellwahl'), findsOneWidget);

      // Presets chips should exist
      expect(find.text('6.000'), findsOneWidget);
      expect(find.text('8.000'), findsOneWidget);
      expect(find.text('10.000'), findsOneWidget);
      expect(find.text('12.000'), findsOneWidget);
      expect(find.text('15.000'), findsOneWidget);

      // Select preset chip 8.000
      await tester.tap(find.text('8.000'));
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Ziel speichern'));
      await tester.pumpAndSettle();

      // Bottom sheet should be dismissed and controller updated
      expect(find.byType(StepGoalSheet), findsNothing);
      expect(dashboardController.stepGoal, 8000);

      // TodayPage subtitle should now display Ziel: 8.000
      expect(
        find.textContaining('Ziel: 8.000'),
        findsOneWidget,
      );
    });

    testWidgets('Allows custom step goal input in StepGoalSheet',
        (tester) async {
      await tester.pumpWidget(createTodayTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Schritte & Distanz'));
      await tester.pumpAndSettle();

      // Find TextFormField and enter custom goal
      final inputFinder = find.widgetWithText(
        TextFormField,
        'Individuelles Schritteziel',
      );
      expect(inputFinder, findsOneWidget);

      await tester.enterText(inputFinder, '13500');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ziel speichern'));
      await tester.pumpAndSettle();

      expect(dashboardController.stepGoal, 13500);
      expect(find.textContaining('Ziel: 13.500'), findsOneWidget);
    });
  });

  group('SettingsPage Step Goal Input', () {
    testWidgets('Loads step goal in manual goals and saves updates',
        (tester) async {
      await tester.pumpWidget(createSettingsTestWidget());
      await tester.pumpAndSettle();

      // Find "Ziele einstellen (manuell)" ExpansionTile or Section
      final manualGoalsFinder = find.text('Ziele einstellen (manuell)');
      expect(manualGoalsFinder, findsOneWidget);
      await tester.tap(manualGoalsFinder);
      await tester.pumpAndSettle();

      // Check step goal field
      final stepFieldFinder =
          find.widgetWithText(TextField, 'Tägliches Schritteziel');
      expect(stepFieldFinder, findsOneWidget);

      // Should have initial value 10000
      final textField = tester.widget<TextField>(stepFieldFinder);
      expect(textField.controller?.text, '10000');

      // Change text to 9000
      await tester.enterText(stepFieldFinder, '9000');
      await tester.pumpAndSettle();

      // Tap "Speichern" in manual goals section
      final saveBtnFinder = find.widgetWithText(ElevatedButton, 'Speichern');
      await tester.ensureVisible(saveBtnFinder);
      await tester.tap(saveBtnFinder);
      await tester.pumpAndSettle();

      // Verify setting was saved
      expect(settingsController.goals.stepGoal, 9000);
    });
  });
}
