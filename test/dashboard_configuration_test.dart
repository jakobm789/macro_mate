import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/activity/presentation/activity_controller.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_controller.dart';
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

    testWidgets('resetToDefaults restores all original card visibility', (
      tester,
    ) async {
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

    test('full persistence roundtrip across controller recreation', () async {
      final settingsRepo = DriftSettingsRepository(database: db);
      final initialSettingsCtrl = SettingsController(repository: settingsRepo);
      final initialDashCtrl = DashboardController(
        nutritionController: nutritionController,
        weightController: weightController,
        healthController: healthController,
        activityController: activityController,
        cycleController: cycleController,
        settingsController: initialSettingsCtrl,
      );

      // 1. Initial load
      await initialDashCtrl.initialize();
      expect(initialDashCtrl.cardOrder.first, 'calories');
      expect(initialDashCtrl.isCardVisible('calories'), isTrue);

      // 2. Modify order (move steps to first) and visibility (hide weight)
      await initialDashCtrl.reorderCards(0, 2); // calories moved after steps
      await initialDashCtrl.toggleCardVisibility('weight', false);

      final modifiedOrder = List<String>.from(initialDashCtrl.cardOrder);
      expect(initialDashCtrl.isCardVisible('weight'), isFalse);
      expect(modifiedOrder.first, 'steps');

      // 3. Destroy controller / simulate app restart
      initialDashCtrl.dispose();
      initialSettingsCtrl.dispose();

      // 4. Create brand new controllers backed by the exact same persistent repository
      final newSettingsCtrl = SettingsController(repository: settingsRepo);
      final newDashCtrl = DashboardController(
        nutritionController: nutritionController,
        weightController: weightController,
        healthController: healthController,
        activityController: activityController,
        cycleController: cycleController,
        settingsController: newSettingsCtrl,
      );

      // 5. Initialize from storage
      await newDashCtrl.initialize();

      // 6. Verify exact persisted state is restored
      expect(newDashCtrl.cardOrder, equals(modifiedOrder));
      expect(newDashCtrl.isCardVisible('weight'), isFalse);
      expect(newDashCtrl.isCardVisible('calories'), isTrue);

      // 7. Test resetToDefaults persists reset state
      await newDashCtrl.resetToDefaults();
      expect(
        newDashCtrl.cardOrder,
        equals(DashboardController.defaultCardOrder),
      );
      expect(newDashCtrl.isCardVisible('weight'), isTrue);

      // Verify reset persisted by recreating again
      newDashCtrl.dispose();
      newSettingsCtrl.dispose();

      final thirdSettingsCtrl = SettingsController(repository: settingsRepo);
      final thirdDashCtrl = DashboardController(
        nutritionController: nutritionController,
        weightController: weightController,
        healthController: healthController,
        activityController: activityController,
        cycleController: cycleController,
        settingsController: thirdSettingsCtrl,
      );
      await thirdDashCtrl.initialize();
      expect(
        thirdDashCtrl.cardOrder,
        equals(DashboardController.defaultCardOrder),
      );
      expect(thirdDashCtrl.isCardVisible('weight'), isTrue);

      thirdDashCtrl.dispose();
      thirdSettingsCtrl.dispose();
    });

    test('recovers gracefully from corrupted persisted JSON', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dashboard_card_order', '{not a valid list json}');
      await prefs.setString('dashboard_card_visibility', '[not a map]');

      final settingsRepo = DriftSettingsRepository(database: db);
      final settingsCtrl = SettingsController(repository: settingsRepo);
      final dashCtrl = DashboardController(
        nutritionController: nutritionController,
        weightController: weightController,
        healthController: healthController,
        activityController: activityController,
        cycleController: cycleController,
        settingsController: settingsCtrl,
      );

      await dashCtrl.initialize();
      // Should fallback to default order and visibility without crashing
      expect(dashCtrl.cardOrder, equals(DashboardController.defaultCardOrder));
      expect(dashCtrl.isCardVisible('calories'), isTrue);

      dashCtrl.dispose();
      settingsCtrl.dispose();
    });

    test('health_sync is directly under cycle in defaultCardOrder', () {
      final cycleIdx = DashboardController.defaultCardOrder.indexOf('cycle');
      final syncIdx = DashboardController.defaultCardOrder.indexOf(
        'health_sync',
      );
      expect(cycleIdx, isNonNegative);
      expect(syncIdx, equals(cycleIdx + 1));
    });

    testWidgets('tapping Aktivenergie opens ActiveCaloriesBreakdownSheet', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Aktivenergie'), findsOneWidget);
      await tester.tap(find.text('Aktivenergie'));
      await tester.pumpAndSettle();

      expect(find.text('Kalorienverbrauch heute'), findsOneWidget);
      expect(find.text('Aufschlüsselung der Herkunft'), findsOneWidget);
      expect(find.text('Alltagsbewegung & Schritte (NEAT)'), findsOneWidget);
      expect(find.text('Grundumsatz (BMR / Ruheenergie)'), findsOneWidget);
    });

    test(
        'DashboardController calculates Gesamtumsatz with proportional BMR and detects missing parameters',
        () async {
      await dashboardController.initialize();

      // Initially no weight entry -> Körpergewicht is missing
      expect(
        dashboardController.missingBmrParameters,
        contains('Körpergewicht'),
      );
      expect(dashboardController.isBmrCalculationComplete, isFalse);
      expect(dashboardController.bmr, equals(1750.0));
      expect(
        dashboardController.totalCalories,
        closeTo(
          dashboardController.activeCalories +
              dashboardController.proportionalBmr,
          0.001,
        ),
      );
      expect(
        dashboardController.estimatedFullDayEnergyExpenditure,
        equals(dashboardController.activeCalories + 1750.0),
      );

      // Add weight entry
      await weightController.addWeight(DateTime.now(), 80.0);
      await dashboardController.refresh();

      expect(dashboardController.missingBmrParameters, isEmpty);
      expect(dashboardController.isBmrCalculationComplete, isTrue);
      final expectedBmr = settingsController.calculateBmr(weightKg: 80.0);
      expect(dashboardController.bmr, equals(expectedBmr));
      expect(
        dashboardController.totalCalories,
        closeTo(
          dashboardController.activeCalories +
              dashboardController.proportionalBmr,
          0.001,
        ),
      );
      expect(
        dashboardController.estimatedFullDayEnergyExpenditure,
        equals(dashboardController.activeCalories + expectedBmr),
      );
    });

    testWidgets(
      'TodayPage and breakdown sheet display missing BMR parameters when weight is missing',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // TodayPage shows missing parameter in subtitle
        expect(
          find.textContaining('Fehlend für Grundumsatz: Körpergewicht'),
          findsOneWidget,
        );

        // Open breakdown sheet
        await tester.tap(find.text('Aktivenergie'));
        await tester.pumpAndSettle();

        // Breakdown sheet informs user about missing parameter
        expect(
          find.textContaining(
            'Für die genaue Grundumsatz-Berechnung fehlen: Körpergewicht',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
