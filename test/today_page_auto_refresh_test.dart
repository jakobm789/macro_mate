import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:macro_mate/app/navigation/app_route_observer.dart';
import 'package:macro_mate/app/navigation/app_shell.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/core/time/clock.dart';
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

class CountingDashboardController extends DashboardController {
  CountingDashboardController({
    required super.nutritionController,
    required super.weightController,
    required super.healthController,
    required super.activityController,
    required super.cycleController,
    required super.settingsController,
  });

  int refreshCount = 0;

  @override
  Future<void> refresh() async {
    refreshCount++;
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CountingDashboardController dashboardController;
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

    final nutritionController = NutritionController(repository: nutritionRepo);
    final weightController = WeightController(repository: weightRepo);
    final healthController = HealthController(repository: healthRepo);
    final activityController = ActivityController(repository: healthRepo);
    final cycleController = CycleController(repository: cycleRepo);
    final settingsController = SettingsController(repository: settingsRepo);

    dashboardController = CountingDashboardController(
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

  Widget buildTestApp({
    required Widget child,
    GlobalKey<NavigatorState>? navigatorKey,
    Map<String, WidgetBuilder>? routes,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<DashboardController>.value(
          value: dashboardController,
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [appRouteObserver],
        routes: routes ?? const {},
        home: child,
      ),
    );
  }

  group('TodayPage Auto-Refresh & 30-second interval', () {
    testWidgets(
        'reloads immediately on initial visit and every 30 seconds while open',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const TodayPage(
            isSelectedTab: true,
            enableAutoRefresh: true,
            autoRefreshInterval: Duration(seconds: 30),
          ),
        ),
      );

      // Initially, after frame callback executes
      await tester.pump();
      expect(dashboardController.refreshCount, 1);

      // Advance by 29 seconds -> no new refresh yet
      await tester.pump(const Duration(seconds: 29));
      expect(dashboardController.refreshCount, 1);

      // Advance by 1 more second -> 30 seconds reached, refresh triggered!
      await tester.pump(const Duration(seconds: 1));
      expect(dashboardController.refreshCount, 2);

      // Advance by another 30 seconds -> 60 seconds reached, refresh triggered!
      await tester.pump(const Duration(seconds: 30));
      expect(dashboardController.refreshCount, 3);
    });

    testWidgets(
        'pauses timer when tab is switched away and reloads immediately when returning',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const TodayPage(
            isSelectedTab: true,
            enableAutoRefresh: true,
            autoRefreshInterval: Duration(seconds: 30),
          ),
        ),
      );

      await tester.pump();
      expect(dashboardController.refreshCount, 1);

      // Switch away: isSelectedTab = false
      await tester.pumpWidget(
        buildTestApp(
          child: const TodayPage(
            isSelectedTab: false,
            enableAutoRefresh: true,
            autoRefreshInterval: Duration(seconds: 30),
          ),
        ),
      );
      await tester.pump();

      // Advance 60 seconds while not active -> no refreshes should occur
      await tester.pump(const Duration(seconds: 60));
      expect(dashboardController.refreshCount, 1);

      // Switch back to tab: isSelectedTab = true
      await tester.pumpWidget(
        buildTestApp(
          child: const TodayPage(
            isSelectedTab: true,
            enableAutoRefresh: true,
            autoRefreshInterval: Duration(seconds: 30),
          ),
        ),
      );
      await tester.pump();

      // Immediate reload upon returning!
      expect(dashboardController.refreshCount, 2);

      // Timer restarted -> after 30 seconds, reloads again
      await tester.pump(const Duration(seconds: 30));
      expect(dashboardController.refreshCount, 3);
    });

    testWidgets(
        'pauses timer when route is pushed and reloads immediately when route is popped',
        (tester) async {
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        buildTestApp(
          navigatorKey: navKey,
          routes: {
            '/subpage': (_) => const Scaffold(body: Text('Subpage')),
          },
          child: const TodayPage(
            isSelectedTab: true,
            enableAutoRefresh: true,
            autoRefreshInterval: Duration(seconds: 30),
          ),
        ),
      );

      await tester.pump();
      expect(dashboardController.refreshCount, 1);

      // Push subpage on top
      navKey.currentState!.pushNamed('/subpage');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Subpage'), findsOneWidget);

      // Advance 60 seconds while subpage is obscuring TodayPage -> no refreshes!
      await tester.pump(const Duration(seconds: 60));
      expect(dashboardController.refreshCount, 1);

      // Pop subpage (going back to TodayPage)
      navKey.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Immediate reload upon returning from popped route!
      expect(dashboardController.refreshCount, 2);

      // Periodic timer active again after 30 seconds
      await tester.pump(const Duration(seconds: 30));
      expect(dashboardController.refreshCount, 3);
    });

    testWidgets('re-tapping Heute tab in AppShell refreshes the dashboard',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: AppShell(
            database: db,
            enablePeriodicSync: true,
          ),
        ),
      );

      await tester.pump();
      expect(dashboardController.refreshCount, 1);

      // Re-tap tab 0 (Heute) in NavigationBar
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Heute'),
        ),
      );
      await tester.pump();

      expect(dashboardController.refreshCount, 2);
    });

    test('proportionalBmr factors in BMR based on day progress', () {
      final noonClock = FixedClock(DateTime(2026, 9, 5, 12, 0, 0));
      final noonController = DashboardController(
        nutritionController: appState.nutritionController,
        weightController: appState.weightController,
        healthController: appState.healthController,
        activityController: appState.activityController,
        cycleController: appState.cycleController,
        settingsController: appState.settingsController,
        clock: noonClock,
      );

      // At 12:00:00, exactly 50% of the day has elapsed (12 / 24 = 0.5)
      expect(noonController.dayProgress, closeTo(0.5, 0.0001));
      expect(noonController.proportionalBmr, closeTo(1750.0 * 0.5, 0.001));
      expect(
        noonController.totalEnergyExpenditure,
        closeTo(noonController.activeCalories + (1750.0 * 0.5), 0.001),
      );

      // At 06:00:00 (25% of day)
      final morningClock = FixedClock(DateTime(2026, 9, 5, 6, 0, 0));
      final morningController = DashboardController(
        nutritionController: appState.nutritionController,
        weightController: appState.weightController,
        healthController: appState.healthController,
        activityController: appState.activityController,
        cycleController: appState.cycleController,
        settingsController: appState.settingsController,
        clock: morningClock,
      );
      expect(morningController.dayProgress, closeTo(0.25, 0.0001));
      expect(morningController.proportionalBmr, closeTo(1750.0 * 0.25, 0.001));
    });
  });
}
