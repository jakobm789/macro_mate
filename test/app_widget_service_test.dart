import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/core/widgets/app_widget_service.dart';
import 'package:macro_mate/features/activity/presentation/activity_controller.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_controller.dart';
import 'package:macro_mate/features/dashboard/presentation/dashboard_controller.dart';
import 'package:macro_mate/features/dashboard/presentation/overview_summary_card.dart';
import 'package:macro_mate/features/health/data/drift_health_repository.dart';
import 'package:macro_mate/features/health/data/health_connect_source.dart';
import 'package:macro_mate/features/health/presentation/health_controller.dart';
import 'package:macro_mate/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:macro_mate/features/nutrition/presentation/nutrition_controller.dart';
import 'package:macro_mate/features/settings/data/drift_settings_repository.dart';
import 'package:macro_mate/features/settings/presentation/settings_controller.dart';
import 'package:macro_mate/features/weight/data/drift_weight_repository.dart';
import 'package:macro_mate/features/weight/presentation/weight_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppWidgetService & Home Screen Widgets', () {
    late List<MethodCall> channelCalls;

    setUp(() {
      channelCalls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('macro_mate/widget'), (
        MethodCall call,
      ) async {
        channelCalls.add(call);
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('macro_mate/widget'),
        null,
      );
    });

    test('updateAllWidgets sends complete payload via MethodChannel', () async {
      // Simulate Android platform
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await AppWidgetService.updateAllWidgets(
          consumedCalories: 1850.0,
          dailyCalorieGoal: 2200,
          consumedCarbs: 210.0,
          consumedProtein: 140.0,
          consumedFat: 55.0,
          steps: 8500,
          stepGoal: 10000,
          distanceKm: 6.2,
          activeCalories: 450.0,
          totalCalories: 2200.0,
          currentWeight: 78.5,
          weightTrend: -0.4,
          targetWeight: 75.0,
          cycleDay: 14,
          cyclePhase: 'Follikelphase',
          daysUntilNext: 14,
        );

        expect(channelCalls, hasLength(1));
        final call = channelCalls.first;
        expect(call.method, equals('updateAllWidgets'));
        expect(call.arguments['consumedCalories'], equals(1850.0));
        expect(call.arguments['dailyCalorieGoal'], equals(2200));
        expect(call.arguments['steps'], equals(8500));
        expect(call.arguments['distanceKm'], equals(6.2));
        expect(call.arguments['activeCalories'], equals(450.0));
        expect(call.arguments['totalCalories'], equals(2200.0));
        expect(call.arguments['currentWeight'], equals(78.5));
        expect(call.arguments['weightTrend'], equals(-0.4));
        expect(call.arguments['cycleDay'], equals(14));
        expect(call.arguments['cyclePhase'], equals('Follikelphase'));
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test(
      'updateFromDashboard serializes dashboard metrics into widget channel',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        try {
          SharedPreferences.setMockInitialValues({});
          final db = AppDatabase.forTesting(NativeDatabase.memory());
          addTearDown(db.close);

          final nutritionRepo = DriftNutritionRepository(database: db);
          final weightRepo = DriftWeightRepository(database: db);
          final settingsRepo = DriftSettingsRepository(database: db);
          final cycleRepo = DriftCycleRepository(database: db);
          final healthRepo = DriftHealthRepository(
            database: db,
            source: HealthConnectSource(),
          );

          final nutritionCtrl = NutritionController(repository: nutritionRepo);
          final weightCtrl = WeightController(repository: weightRepo);
          final healthCtrl = HealthController(repository: healthRepo);
          final activityCtrl = ActivityController(repository: healthRepo);
          final cycleCtrl = CycleController(
            repository: cycleRepo,
            healthRepository: healthRepo,
          );
          final settingsCtrl = SettingsController(repository: settingsRepo);

          final dashboardCtrl = DashboardController(
            nutritionController: nutritionCtrl,
            weightController: weightCtrl,
            healthController: healthCtrl,
            activityController: activityCtrl,
            cycleController: cycleCtrl,
            settingsController: settingsCtrl,
          );

          await dashboardCtrl.initialize();
          await weightCtrl.addWeight(DateTime.now(), 82.0);
          await dashboardCtrl.refresh();

          // Channel call should have been dispatched during refresh
          expect(channelCalls, isNotEmpty);
          final lastCall = channelCalls.last;
          expect(lastCall.method, equals('updateAllWidgets'));
          expect(lastCall.arguments['currentWeight'], equals(82.0));
          expect(
            lastCall.arguments['dailyCalorieGoal'],
            equals(settingsCtrl.goals.dailyCalories),
          );
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );

    testWidgets(
      'OverviewSummaryCard renders all metrics and handles navigation',
      (tester) async {
        int? navigatedTab;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: OverviewSummaryCard(
                  consumedCal: 1650,
                  targetCal: 2200,
                  consumedCarbs: 180,
                  targetCarbs: 250,
                  consumedProt: 130,
                  targetProt: 160,
                  consumedFat: 52,
                  targetFat: 70,
                  steps: 8420,
                  stepGoal: 10000,
                  distanceKm: 5.8,
                  activeKcal: 480,
                  totalKcal: 2230,
                  weight: 78.4,
                  weightTrend: -0.3,
                  cycleDay: 14,
                  cyclePhase: 'Follikelphase',
                  onNavigateToTab: (index) => navigatedTab = index,
                ),
              ),
            ),
          ),
        );

        // Verify header and titles
        expect(find.text('Große Tagesübersicht'), findsOneWidget);
        expect(find.text('Ernährung & Kalorien'), findsOneWidget);
        expect(find.text('Aktivität & Energie'), findsOneWidget);
        expect(find.text('Gewicht'), findsOneWidget);
        expect(find.text('Zyklus'), findsOneWidget);

        // Verify values
        expect(find.text('1650'), findsOneWidget);
        expect(find.text(' / 2200 kcal'), findsOneWidget);
        expect(find.text('8420'), findsOneWidget);
        expect(find.text(' / 10000 Schritte'), findsOneWidget);
        expect(find.text('78.4 kg'), findsOneWidget);
        expect(find.text('Tag 14'), findsOneWidget);
        expect(find.textContaining('Follikelphase'), findsOneWidget);

        // Verify tap on Nutrition navigates to tab 1
        await tester.tap(find.text('Ernährung & Kalorien'));
        expect(navigatedTab, equals(1));

        // Verify tap on Activity navigates to tab 2
        await tester.tap(find.text('Aktivität & Energie'));
        expect(navigatedTab, equals(2));

        // Verify tap on Cycle navigates to tab 3
        await tester.tap(find.text('Zyklus'));
        expect(navigatedTab, equals(3));
      },
    );
  });
}
