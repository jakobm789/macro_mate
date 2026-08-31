import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/activity/presentation/activity_controller.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_controller.dart';
import 'package:macro_mate/features/dashboard/presentation/dashboard_config_sheet.dart';
import 'package:macro_mate/features/dashboard/presentation/dashboard_controller.dart';
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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final healthRepo = DriftHealthRepository(database: db, source: HealthConnectSource());

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

  Widget createTestWidget() {
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
      child: const MaterialApp(
        home: TodayPage(),
      ),
    );
  }

  group('Today Dashboard Configuration', () {
    testWidgets('renders default dashboard cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Kalorien & Makros'), findsOneWidget);
      expect(find.text('Schritte & Distanz'), findsOneWidget);
      expect(find.text('Aktivenergie'), findsOneWidget);
      expect(find.text('Gewicht'), findsOneWidget);
    });

    testWidgets('hides card when toggled off in config sheet', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open config sheet
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard anpassen'), findsOneWidget);

      // Find switch for 'Kalorien & Makro-Ziele' and toggle off
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);
      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // Close config sheet
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Calories card should now be hidden
      expect(find.text('Kalorien & Makros'), findsNothing);
    });

    testWidgets('resetToDefaults restores all original card visibility', (tester) async {
      await dashboardController.toggleCardVisibility('calories', false);
      expect(dashboardController.isCardVisible('calories'), isFalse);

      await dashboardController.resetToDefaults();
      expect(dashboardController.isCardVisible('calories'), isTrue);
      expect(dashboardController.cardOrder.first, 'calories');
    });

    testWidgets('reordering cards alters the display order', (tester) async {
      final initialFirst = dashboardController.cardOrder.first;
      expect(initialFirst, 'calories');

      await dashboardController.reorderCards(0, 2);
      expect(dashboardController.cardOrder.first, isNot('calories'));
    });
  });
}
