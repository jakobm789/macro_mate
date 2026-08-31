import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:macro_mate/app/navigation/app_shell.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/core/notifications/drift_notification_repository.dart';
import 'package:macro_mate/core/notifications/notification_controller.dart';
import 'package:macro_mate/features/activity/presentation/activity_controller.dart';
import 'package:macro_mate/features/activity/presentation/activity_page.dart';
import 'package:macro_mate/features/auth/presentation/auth_controller.dart';
import 'package:macro_mate/features/backup/presentation/backup_controller.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/domain/cycle_models.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_controller.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_page.dart';
import 'package:macro_mate/features/dashboard/presentation/dashboard_controller.dart';
import 'package:macro_mate/features/dashboard/presentation/today_page.dart';
import 'package:macro_mate/features/health/data/drift_health_repository.dart';
import 'package:macro_mate/features/health/domain/health_models.dart';
import 'package:macro_mate/features/health/presentation/health_controller.dart';
import 'package:macro_mate/features/local_llm/presentation/local_model_controller.dart';
import 'package:macro_mate/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:macro_mate/features/nutrition/presentation/food_search_controller.dart';
import 'package:macro_mate/features/nutrition/presentation/import_export_controller.dart';
import 'package:macro_mate/features/nutrition/presentation/nutrition_controller.dart';
import 'package:macro_mate/features/settings/data/drift_settings_repository.dart';
import 'package:macro_mate/features/settings/presentation/settings_controller.dart';
import 'package:macro_mate/features/weight/data/drift_weight_repository.dart';
import 'package:macro_mate/features/weight/presentation/weight_controller.dart';
import 'package:macro_mate/models/app_state.dart';

import 'fake_health_connect_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeHealthConnectSource fakeHealthSource;
  late DriftHealthRepository healthRepo;
  late DriftCycleRepository cycleRepo;
  late DriftNutritionRepository nutritionRepo;
  late DriftWeightRepository weightRepo;
  late DriftSettingsRepository settingsRepo;
  late DriftNotificationRepository notificationRepo;

  late NutritionController nutritionController;
  late WeightController weightController;
  late HealthController healthController;
  late ActivityController activityController;
  late CycleController cycleController;
  late SettingsController settingsController;
  late DashboardController dashboardController;
  late NotificationController notificationController;
  late AuthController authController;
  late BackupController backupController;
  late FoodSearchController foodSearchController;
  late ImportExportController importExportController;
  late LocalModelController localModelController;

  late AppState appState;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fakeHealthSource = FakeHealthConnectSource(
      menstruationPermissionGranted: false,
    );
    healthRepo = DriftHealthRepository(database: db, source: fakeHealthSource);
    cycleRepo = DriftCycleRepository(database: db);
    nutritionRepo = DriftNutritionRepository(database: db);
    weightRepo = DriftWeightRepository(database: db);
    settingsRepo = DriftSettingsRepository(database: db);
    notificationRepo = DriftNotificationRepository(database: db);

    nutritionController = NutritionController(repository: nutritionRepo);
    weightController = WeightController(repository: weightRepo);
    healthController = HealthController(repository: healthRepo);
    activityController = ActivityController(repository: healthRepo);
    cycleController = CycleController(
      repository: cycleRepo,
      healthRepository: healthRepo,
    );
    settingsController = SettingsController(repository: settingsRepo);
    dashboardController = DashboardController(
      nutritionController: nutritionController,
      weightController: weightController,
      healthController: healthController,
      activityController: activityController,
      cycleController: cycleController,
      settingsController: settingsController,
    );
    notificationController =
        NotificationController(repository: notificationRepo);
    authController = AuthController(settingsController: settingsController);
    backupController = BackupController(
      database: db,
      nutritionRepository: nutritionRepo,
      weightRepository: weightRepo,
      settingsRepository: settingsRepo,
      cycleRepository: cycleRepo,
      healthRepository: healthRepo,
    );
    foodSearchController = FoodSearchController(
      nutritionRepository: nutritionRepo,
    );
    importExportController = ImportExportController();
    localModelController = LocalModelController();

    appState = AppState(
      database: db,
      nutritionRepository: nutritionRepo,
      weightRepository: weightRepo,
      settingsRepository: settingsRepo,
      healthRepository: healthRepo,
      cycleRepository: cycleRepo,
      notificationRepository: notificationRepo,
      nutritionCtrl: nutritionController,
      weightCtrl: weightController,
      healthCtrl: healthController,
      activityCtrl: activityController,
      cycleCtrl: cycleController,
      settingsCtrl: settingsController,
      dashboardCtrl: dashboardController,
      notificationCtrl: notificationController,
      authCtrl: authController,
      backupCtrl: backupController,
      foodSearchCtrl: foodSearchController,
      importExportCtrl: importExportController,
      localModelCtrl: localModelController,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget createProductionApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<NutritionController>.value(
          value: nutritionController,
        ),
        ChangeNotifierProvider<WeightController>.value(
          value: weightController,
        ),
        ChangeNotifierProvider<HealthController>.value(
          value: healthController,
        ),
        ChangeNotifierProvider<ActivityController>.value(
          value: activityController,
        ),
        ChangeNotifierProvider<CycleController>.value(
          value: cycleController,
        ),
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
        ),
        ChangeNotifierProvider<DashboardController>.value(
          value: dashboardController,
        ),
        ChangeNotifierProvider<NotificationController>.value(
          value: notificationController,
        ),
        ChangeNotifierProvider<AuthController>.value(
          value: authController,
        ),
        ChangeNotifierProvider<BackupController>.value(
          value: backupController,
        ),
        ChangeNotifierProvider<FoodSearchController>.value(
          value: foodSearchController,
        ),
        ChangeNotifierProvider<ImportExportController>.value(
          value: importExportController,
        ),
        ChangeNotifierProvider<LocalModelController>.value(
          value: localModelController,
        ),
      ],
      child: const MaterialApp(
        home: AppShell(),
      ),
    );
  }

  group('Production Wiring Verification', () {
    testWidgets('AppShell uses registered Provider-controllers on tabs',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createProductionApp());
      await tester.pumpAndSettle();

      // 1. Today Page is initial tab
      expect(find.byType(TodayPage), findsOneWidget);

      // 2. Switch to Activity tab (index 2)
      await tester.tap(find.byIcon(Icons.directions_run_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityPage), findsOneWidget);

      // 3. Switch to Cycle tab (index 3)
      await tester.tap(find.byIcon(Icons.water_drop_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(CyclePage), findsOneWidget);

      // Verify CyclePage is rendered and has the sync action
      expect(find.text('Zyklus & Wohlbefinden'), findsOneWidget);
      expect(find.byIcon(Icons.sync_alt), findsOneWidget);
    });
  });

  group('Strict Menstruation Opt-in & Health Permissions', () {
    test('normal health permissions request does NOT include MENSTRUATION_FLOW',
        () async {
      final perm = await healthRepo.requestPermissions();
      expect(perm.readGranted, isTrue);

      // Menstruation permission remains ungranted
      final hasMenstruation = await healthRepo.hasMenstruationPermission();
      expect(hasMenstruation, isFalse);
    });

    test('normal health sync succeeds when menstruation permission is false',
        () async {
      fakeHealthSource.menstruationPermissionGranted = false;
      fakeHealthSource.addRecord(
        HealthRecord(
          id: 'step_test_1',
          metric: HealthMetric.steps,
          sourceId: 'fit',
          sourceName: 'Fit',
          startUtc: DateTime.utc(2026, 8, 25, 10),
          endUtc: DateTime.utc(2026, 8, 25, 11),
          value: 3000,
          unit: 'count',
          localDay: '2026-08-25',
        ),
      );

      final summaries = await healthRepo.sync(
        startUtc: DateTime.utc(2026, 8, 20),
        endUtc: DateTime.utc(2026, 8, 30),
      );

      expect(summaries, isNotEmpty);
      expect(summaries.first.steps, 3000);
    });

    test(
        'menstruation reading throws HealthPermissionException without opt-in permission',
        () async {
      fakeHealthSource.menstruationPermissionGranted = false;
      fakeHealthSource.addMenstruationRecord(
        HealthMenstruationRecord(
          id: 'm1',
          startDay: DateTime.utc(2026, 8, 1),
          endDay: DateTime.utc(2026, 8, 5),
          sourceName: 'Garmin',
        ),
      );

      expect(
        () => healthRepo.readMenstruation(
          startUtc: DateTime.utc(2026, 7, 1),
          endUtc: DateTime.utc(2026, 8, 31),
        ),
        throwsA(isA<HealthPermissionException>()),
      );
    });

    test(
        'revoking general permissions does not compromise independent menstruation opt-in state',
        () async {
      await healthRepo.requestMenstruationPermission();
      expect(await healthRepo.hasMenstruationPermission(), isTrue);

      await healthRepo.revokePermissions();
      final current = await healthRepo.permissions();
      expect(current.readGranted, isFalse);
      expect(await healthRepo.hasMenstruationPermission(), isTrue);
    });
  });

  group('Full Production Navigation Path Menstruation Import', () {
    testWidgets(
        'rejection in opt-in dialog cancels import without requesting permission or crashing',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      fakeHealthSource.menstruationPermissionGranted = false;

      await tester.pumpWidget(createProductionApp());
      await tester.pumpAndSettle();

      // Navigate to Cycle tab
      await tester.tap(find.byIcon(Icons.water_drop_outlined));
      await tester.pumpAndSettle();

      // Tap sync icon
      await tester.tap(find.byIcon(Icons.sync_alt));
      await tester.pumpAndSettle();

      // Explanatory dialog must appear
      expect(find.text('Menstruationsdaten importieren'), findsOneWidget);
      expect(find.text('Abbrechen'), findsOneWidget);

      // Tap Abbrechen
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      // Permission should not be granted and no sheet shown
      expect(await fakeHealthSource.hasMenstruationPermission(), isFalse);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
        'full production flow: Opt-in -> Preview -> Resolution -> Persisted in DriftCycleRepository',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      fakeHealthSource.menstruationPermissionGranted = false;
      fakeHealthSource.addMenstruationRecord(
        HealthMenstruationRecord(
          id: 'prod_period_1',
          startDay: DateTime.utc(2026, 8, 10),
          endDay: DateTime.utc(2026, 8, 14),
          flow: BleedingLevel.medium,
          sourceName: 'Health Connect App',
        ),
      );

      await tester.pumpWidget(createProductionApp());
      await tester.pumpAndSettle();

      // 1. Navigate to Cycle tab in AppShell
      await tester.tap(find.byIcon(Icons.water_drop_outlined));
      await tester.pumpAndSettle();

      // 2. Tap Health Connect Menstruation sync button
      await tester.tap(find.byIcon(Icons.sync_alt));
      await tester.pumpAndSettle();

      // 3. Opt-in Dialog appears
      expect(find.text('Menstruationsdaten importieren'), findsOneWidget);

      // 4. Confirm permission
      await tester.tap(find.text('Berechtigung anfordern'));
      await tester.pumpAndSettle();

      // 5. Preview Sheet should be open with the record
      expect(find.text('Health Connect Periodenimport'), findsOneWidget);
      expect(find.textContaining('Health Connect App'), findsOneWidget);

      // 6. Tap "Import ausführen"
      await tester.tap(find.text('Import ausführen'));
      await tester.pumpAndSettle();

      // 7. Verify period entry exists in DriftCycleRepository
      final periods = await cycleRepo.periods();
      expect(periods.length, 1);
      expect(periods.first.startDay.month, 8);
      expect(periods.first.startDay.day, 10);
      expect(periods.first.endDay?.day, 14);
      expect(periods.first.source, 'Health Connect App');
    });
  });
}
