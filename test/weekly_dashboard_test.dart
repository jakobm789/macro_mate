import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/health/data/drift_health_repository.dart';
import 'package:macro_mate/features/health/data/health_connect_source.dart';
import 'package:macro_mate/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:macro_mate/features/settings/data/drift_settings_repository.dart';
import 'package:macro_mate/features/weight/data/drift_weight_repository.dart';
import 'package:macro_mate/models/app_state.dart';
import 'package:macro_mate/pages/weekly_dashboard_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WeeklyDashboardPage & calculateWeeklyDayBreakdown', () {
    late AppDatabase db;
    late AppState appState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());

      final nutritionRepo = DriftNutritionRepository(database: db);
      final weightRepo = DriftWeightRepository(database: db);
      final settingsRepo = DriftSettingsRepository(database: db);
      final cycleRepo = DriftCycleRepository(database: db);
      final healthRepo =
          DriftHealthRepository(database: db, source: HealthConnectSource());

      appState = AppState(
        database: db,
        nutritionRepository: nutritionRepo,
        weightRepository: weightRepo,
        settingsRepository: settingsRepo,
        healthRepository: healthRepo,
        cycleRepository: cycleRepo,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test(
        'calculateWeeklyDayBreakdown formats day names without LocaleDataException',
        () async {
      final breakdown = await appState.calculateWeeklyDayBreakdown();
      expect(breakdown, isNotEmpty);
      expect(breakdown.length, equals(7));

      for (final day in breakdown) {
        expect(day.dayName, isNotEmpty);
        expect(
          ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'].contains(day.dayName),
          isTrue,
        );
      }
    });

    testWidgets(
        'WeeklyDashboardPage loads without LocaleDataException error message',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: WeeklyDashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Wochen-Dashboard'), findsOneWidget);
      expect(find.text('Wochenübersicht'), findsOneWidget);
      expect(
        find.textContaining('Fehler beim Laden des Dashboards'),
        findsNothing,
      );
      expect(find.text('Durchschnitt'), findsOneWidget);
      expect(find.text('Verbleibend'), findsOneWidget);
    });
  });
}
