import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/app/navigation/app_shell.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/activity/presentation/activity_controller.dart';
import 'package:macro_mate/features/activity/presentation/activity_page.dart';
import 'package:macro_mate/features/activity/presentation/live_running_tracker_page.dart';
import 'package:macro_mate/features/activity/presentation/running_tracker_controller.dart';
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
import 'package:macro_mate/pages/home_page.dart';
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
        ChangeNotifierProvider<DashboardController>.value(
            value: dashboardController),
        ChangeNotifierProvider<NutritionController>.value(
            value: nutritionController),
        ChangeNotifierProvider<WeightController>.value(value: weightController),
        ChangeNotifierProvider<HealthController>.value(value: healthController),
        ChangeNotifierProvider<ActivityController>.value(
            value: activityController),
        ChangeNotifierProvider<CycleController>.value(value: cycleController),
        ChangeNotifierProvider<SettingsController>.value(
            value: settingsController),
        Provider<AppDatabase>.value(value: db),
        ChangeNotifierProvider<RunningTrackerController>.value(
            value: appState.runningTrackerController),
      ],
      child: MaterialApp(
        home: AppShell(database: db),
      ),
    );
  }

  group('Main App Navigation & Tabs Widget Tests', () {
    testWidgets('switches between all 5 main bottom navigation tabs',
        (tester) async {
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

    testWidgets(
        'tapping dashboard cards smoothly switches AppShell bottom tabs',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createShellWidget());
      await tester.pump(const Duration(milliseconds: 200));

      // Initially on Tab 0: Heute
      expect(find.text('Dein Überblick'), findsOneWidget);

      // Tap Kalorien & Makros hero card -> switches to Tab 1: Ernährung
      await tester.tap(find.text('Kalorien & Makros'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byIcon(Icons.restaurant), findsWidgets);
      // Bottom navigation bar must remain visible!
      expect(find.byType(NavigationBar), findsOneWidget);

      // Return to Tab 0: Heute
      await tester.tap(find.byIcon(Icons.today_outlined));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Dein Überblick'), findsOneWidget);

      // Tap Schritte & Distanz card -> opens StepGoalSheet, then tap to switch to Tab 2: Aktivität
      await tester.tap(find.text('Schritte & Distanz'));
      await tester.pumpAndSettle();
      expect(find.text('Tägliches Schritteziel'), findsOneWidget);
      await tester.tap(find.text('Zu Aktivitäten & Workouts'));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityPage), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets(
        'tapping Outdoor-Aktivität starten opens LiveRunningTrackerPage smoothly without gray screen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createShellWidget());
      await tester.pump(const Duration(milliseconds: 200));

      // Switch to Activity Tab
      await tester.tap(find.byIcon(Icons.directions_run_outlined));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ActivityPage), findsOneWidget);

      // Tap on 'Outdoor-Aktivität starten (GPS)' card
      final startCard = find.text('Outdoor-Aktivität starten (GPS)');
      expect(startCard, findsOneWidget);
      await tester.tap(startCard);
      await tester.pumpAndSettle();

      // Modal bottom sheet should appear with sport options
      expect(find.text('Aktivität aufzeichnen'), findsOneWidget);
      expect(find.text('Laufen'), findsOneWidget);

      // Tap 'Laufen'
      await tester.tap(find.text('Laufen'));
      await tester.pumpAndSettle();

      // Should open LiveRunningTrackerPage without crashing or gray screen
      expect(tester.takeException(), isNull);
      expect(find.byType(LiveRunningTrackerPage), findsOneWidget);
      expect(find.text('Laufen · Tracker'), findsOneWidget);
      expect(find.text('START (Laufen)'), findsOneWidget);
    });

    testWidgets(
        'pressing back in any tab redirects back to the main page (Heute)',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createShellWidget());
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Tab 1: Ernährung -> Press Back -> Should go to Tab 0 (Heute)
      await tester.tap(find.byIcon(Icons.restaurant_outlined));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(MyHomePage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 200));
      final navBar1 = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar1.selectedIndex, 0);

      // 2. Tab 2: Aktivität -> Press Back -> Should go to Tab 0 (Heute)
      await tester.tap(find.byIcon(Icons.directions_run_outlined));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ActivityPage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 200));
      final navBar2 = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar2.selectedIndex, 0);

      // 3. Tab 3: Zyklus -> Press Back -> Should go to Tab 0 (Heute)
      await tester.tap(find.byIcon(Icons.water_drop_outlined));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(CyclePage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 200));
      final navBar3 = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar3.selectedIndex, 0);

      // 4. Tab 4: Mehr -> Press Back -> Should go to Tab 0 (Heute)
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(MorePage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 200));
      final navBar4 = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar4.selectedIndex, 0);
    });

    testWidgets(
        'tapping AppBar back button in tabs redirects to main page (Heute)',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createShellWidget());
      await tester.pump(const Duration(milliseconds: 200));

      // Tab 4: Mehr -> Tap AppBar back button -> Tab 0
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(MorePage), findsOneWidget);

      final backButton = find.byTooltip('Zurück zur Hauptseite');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pump(const Duration(milliseconds: 200));

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 0);
    });
  });
}
