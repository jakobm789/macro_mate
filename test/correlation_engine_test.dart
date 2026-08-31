import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/domain/correlation_engine.dart';
import 'package:macro_mate/features/cycle/domain/cycle_models.dart';
import 'package:macro_mate/features/cycle/presentation/correlations_page.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_controller.dart';
import 'package:macro_mate/features/health/domain/health_models.dart';
import 'package:macro_mate/models/consumed_food_item.dart';
import 'package:macro_mate/models/food_item.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CorrelationEngine unit tests', () {
    test(
        'returns hasSufficientData: false when under 7 days and under 2 cycles',
        () {
      final periods = [
        PeriodEntry(
          id: 'p1',
          startDay: DateTime(2026, 8, 1),
          endDay: DateTime(2026, 8, 5),
        ),
      ];
      final logs = [
        CycleDailyLog(day: DateTime(2026, 8, 1), energy: 3),
        CycleDailyLog(day: DateTime(2026, 8, 2), energy: 4),
        CycleDailyLog(day: DateTime(2026, 8, 3), energy: 3),
      ];

      final result = CorrelationEngine.analyze(
        periods: periods,
        logs: logs,
      );

      expect(result.hasSufficientData, isFalse);
      expect(result.observationDaysCount, 3);
      expect(result.completedCyclesCount, 0);
      expect(result.progressDescription, contains('3 von 7 Beobachtungstagen'));
      expect(result.insights, isEmpty);
    });

    test(
        'identifies cycle vs sleep and cycle vs energy when sufficient data present',
        () {
      // 3 completed cycle starts (2 full cycles)
      final periods = [
        PeriodEntry(
            id: 'p1',
            startDay: DateTime(2026, 6, 1),
            endDay: DateTime(2026, 6, 5)),
        PeriodEntry(
            id: 'p2',
            startDay: DateTime(2026, 6, 29),
            endDay: DateTime(2026, 7, 3)),
        PeriodEntry(
            id: 'p3',
            startDay: DateTime(2026, 7, 27),
            endDay: DateTime(2026, 7, 31)),
      ];

      final logs = <CycleDailyLog>[];
      final health = <DailyHealthSummary>[];

      // Seed 28 days of logs and sleep across complete cycle
      for (var i = 0; i < 28; i++) {
        final day = DateTime(2026, 6, 1).add(Duration(days: i));
        final inLuteal = i > 16;
        logs.add(
          CycleDailyLog(
            day: day,
            energy: inLuteal ? 2 : 4,
            sleepQuality: inLuteal ? 2 : 4,
          ),
        );
        health.add(
          DailyHealthSummary(
            day: day,
            steps: inLuteal ? 6000 : 9500,
            activeCalories: inLuteal ? 300 : 500,
            distanceMeters: inLuteal ? 4500 : 7000,
            sleepMinutes: inLuteal ? 390 : 460, // 6.5h vs 7.6h
          ),
        );
      }

      final result = CorrelationEngine.analyze(
        periods: periods,
        logs: logs,
        healthSummaries: health,
      );

      expect(result.hasSufficientData, isTrue);
      expect(result.insights, isNotEmpty);

      // Verify sleep correlation
      final sleepInsight = result.insights.firstWhere(
        (i) => i.category == CorrelationCategory.cycleVsSleep,
      );
      expect(sleepInsight.sampleSizeDays, greaterThanOrEqualTo(10));
      expect(sleepInsight.disclaimer, contains('Explorative Beobachtung'));

      // Verify energy correlation
      final energyInsight = result.insights.firstWhere(
        (i) => i.category == CorrelationCategory.cycleVsEnergy,
      );
      expect(energyInsight.metrics.containsKey('Menstruationsphase'), isTrue);
    });

    test('analyzes nutrition vs energy correlation', () {
      final periods = [
        PeriodEntry(
            id: 'p1',
            startDay: DateTime(2026, 8, 1),
            endDay: DateTime(2026, 8, 5)),
      ];
      final logs = <CycleDailyLog>[];
      final foods = <ConsumedFoodItem>[];

      for (var i = 0; i < 8; i++) {
        final day = DateTime(2026, 8, 1).add(Duration(days: i));
        logs.add(CycleDailyLog(day: day, energy: 4));
        foods.add(
          ConsumedFoodItem(
            id: i + 1,
            date: day,
            mealName: 'lunch',
            food: FoodItem(
              name: 'Vollkornbrot',
              brand: 'Bäcker',
              caloriesPer100g: 220,
              carbsPer100g: 40,
              proteinPer100g: 8,
              fatPer100g: 2,
              sugarPer100g: 1,
            ),
            quantity: 150,
          ),
        );
      }

      final result = CorrelationEngine.analyze(
        periods: periods,
        logs: logs,
        nutritionItems: foods,
      );

      expect(result.hasSufficientData, isTrue);
      final nutInsight = result.insights.firstWhere(
        (i) => i.category == CorrelationCategory.nutritionVsEnergy,
      );
      expect(nutInsight.sampleSizeDays, 8);
    });
  });

  group('CorrelationsPage widget tests', () {
    late AppDatabase db;
    late DriftCycleRepository cycleRepo;
    late CycleController cycleController;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      cycleRepo = DriftCycleRepository(database: db);
      cycleController = CycleController(repository: cycleRepo);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('renders insufficient data card when no data present',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<CycleController>.value(
            value: cycleController,
            child: const CorrelationsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Explorative Zusammenhänge'), findsOneWidget);
      expect(find.text('Noch nicht genügend Daten'), findsOneWidget);
      expect(find.textContaining('Hinweis zu explorativen Trends'),
          findsOneWidget);
    });
  });
}
