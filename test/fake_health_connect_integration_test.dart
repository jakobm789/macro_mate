import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/activity/presentation/activity_controller.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/domain/cycle_models.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_controller.dart';
import 'package:macro_mate/features/health/data/drift_health_repository.dart';
import 'package:macro_mate/features/health/domain/health_models.dart';
import 'package:macro_mate/features/health/presentation/health_controller.dart';

import 'fake_health_connect_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeHealthConnectSource fakeSource;
  late DriftHealthRepository healthRepo;
  late HealthController healthController;
  late ActivityController activityController;

  final testDay = DateTime.utc(2026, 8, 25, 12, 0);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fakeSource = FakeHealthConnectSource();
    healthRepo = DriftHealthRepository(database: db, source: fakeSource);
    healthController = HealthController(repository: healthRepo);
    activityController = ActivityController(repository: healthRepo);

    await healthController.initialize();
  });

  tearDown(() async {
    await db.close();
  });

  group('Fake Health Connect Integration Tests', () {
    test(
        'syncs steps, active calories, sleep, and heart rate and aggregates correctly',
        () async {
      fakeSource.addRecord(
        HealthRecord(
          id: 'step_1',
          metric: HealthMetric.steps,
          sourceId: 'com.google.android.apps.fitness',
          sourceName: 'Google Fit',
          startUtc: testDay,
          endUtc: testDay.add(const Duration(hours: 1)),
          value: 4500,
          unit: 'count',
          localDay: '2026-08-25',
        ),
      );

      fakeSource.addRecord(
        HealthRecord(
          id: 'step_2',
          metric: HealthMetric.steps,
          sourceId: 'com.google.android.apps.fitness',
          sourceName: 'Google Fit',
          startUtc: testDay.add(const Duration(hours: 2)),
          endUtc: testDay.add(const Duration(hours: 3)),
          value: 3500,
          unit: 'count',
          localDay: '2026-08-25',
        ),
      );

      fakeSource.addRecord(
        HealthRecord(
          id: 'active_cal_1',
          metric: HealthMetric.activeCalories,
          sourceId: 'com.google.android.apps.fitness',
          sourceName: 'Google Fit',
          startUtc: testDay,
          endUtc: testDay.add(const Duration(hours: 1)),
          value: 320.0,
          unit: 'kcal',
          localDay: '2026-08-25',
        ),
      );

      fakeSource.addRecord(
        HealthRecord(
          id: 'sleep_1',
          metric: HealthMetric.sleep,
          sourceId: 'com.sec.android.app.shealth',
          sourceName: 'Samsung Health',
          startUtc: testDay.subtract(const Duration(hours: 8)),
          endUtc: testDay,
          value: 480.0,
          unit: 'minutes',
          localDay: '2026-08-25',
        ),
      );

      final summaries = await healthRepo.sync(
        startUtc: testDay.subtract(const Duration(days: 1)),
        endUtc: testDay.add(const Duration(days: 1)),
      );
      expect(summaries, isNotEmpty);

      final summary = summaries.firstWhere(
        (s) => s.day.year == 2026 && s.day.month == 8 && s.day.day == 25,
      );
      expect(summary.steps, 8000); // 4500 + 3500
      expect(summary.activeCalories, 320.0);
      expect(summary.sleepMinutes, 480.0);

      // Verify activity controller loads updated daily summary
      await activityController.loadActivityData(testDay);
      expect(activityController.todaySummary?.steps, 8000);
      expect(activityController.todaySummary?.activeCalories, 320.0);
    });

    test('deduplicates existing records on repeated sync runs', () async {
      fakeSource.addRecord(
        HealthRecord(
          id: 'step_unique_1',
          metric: HealthMetric.steps,
          sourceId: 'com.google.android.apps.fitness',
          sourceName: 'Google Fit',
          startUtc: testDay,
          endUtc: testDay.add(const Duration(minutes: 30)),
          value: 2000,
          unit: 'count',
          localDay: '2026-08-25',
        ),
      );

      // First sync
      final summaries1 = await healthRepo.sync(
        startUtc: testDay.subtract(const Duration(days: 1)),
        endUtc: testDay.add(const Duration(days: 1)),
      );
      expect(summaries1.single.steps, 2000);

      // Second sync with same records
      final summaries2 = await healthRepo.sync(
        startUtc: testDay.subtract(const Duration(days: 1)),
        endUtc: testDay.add(const Duration(days: 1)),
      );
      expect(summaries2.single.steps, 2000); // Not doubled to 4000
    });

    test(
        'recovers gracefully from sync failures and updates controller error state',
        () async {
      fakeSource.shouldThrowOnRead = true;

      await healthController.syncLast30Days();
      expect(healthController.syncStatus, HealthSyncStatus.failed);
      expect(
        healthController.errorMessage,
        contains('Health-Connect-Synchronisierung fehlgeschlagen'),
      );

      // Error clears on successful retry
      fakeSource.shouldThrowOnRead = false;
      await healthController.syncLast30Days();
      expect(healthController.syncStatus, HealthSyncStatus.success);
      expect(healthController.errorMessage, isNull);
    });

    test('syncs workouts with metadata correctly', () async {
      fakeSource.addRecord(
        HealthRecord(
          id: 'workout_run_1',
          metric: HealthMetric.workout,
          sourceId: 'com.strava',
          sourceName: 'Strava',
          startUtc: testDay,
          endUtc: testDay.add(const Duration(minutes: 45)),
          value: 45.0,
          unit: 'minutes',
          localDay: '2026-08-25',
          payloadJson:
              '{"type":"running","distanceMeters":6500.0,"activeCalories":480.0}',
        ),
      );

      await healthRepo.sync(
        startUtc: testDay.subtract(const Duration(days: 1)),
        endUtc: testDay.add(const Duration(days: 1)),
      );

      final workouts = await healthRepo.workouts();
      expect(workouts.length, 1);
      expect(workouts.first.type, 'running');
      expect(workouts.first.durationSeconds, 2700.0);
      expect(workouts.first.distanceMeters, 6500.0);
      expect(workouts.first.energyKcal, 45.0);
    });

    test(
      'full end-to-end Health Connect menstruation import pipeline',
      () async {
        final cycleRepo = DriftCycleRepository(database: db);
        final cycleController = CycleController(
          repository: cycleRepo,
          healthRepository: healthRepo,
        );

        // 1. Initial local period: 2026-07-01 to 2026-07-05
        await cycleRepo.addPeriod(
          startDay: DateTime.utc(2026, 7, 1),
          endDay: DateTime.utc(2026, 7, 5),
          flow: BleedingLevel.medium,
          source: 'local',
        );

        // 2. Health Connect fake source has 2 menstruation records:
        // Record A: 2026-07-03 to 2026-07-07 (Overlaps with local period)
        // Record B: 2026-08-01 to 2026-08-05 (New, non-conflicting)
        fakeSource.addMenstruationRecord(
          HealthMenstruationRecord(
            id: 'hc_menstruation_overlap',
            startDay: DateTime.utc(2026, 7, 3),
            endDay: DateTime.utc(2026, 7, 7),
            flow: BleedingLevel.heavy,
            sourceName: 'Garmin Connect',
          ),
        );
        fakeSource.addMenstruationRecord(
          HealthMenstruationRecord(
            id: 'hc_menstruation_new',
            startDay: DateTime.utc(2026, 8, 1),
            endDay: DateTime.utc(2026, 8, 5),
            flow: BleedingLevel.medium,
            sourceName: 'Garmin Connect',
          ),
        );

        // 3. Trigger preview import via CycleController
        final result = await cycleController.previewHealthConnectImport(
          startUtc: DateTime.utc(2026, 6, 1),
          endUtc: DateTime.utc(2026, 8, 31),
        );

        expect(result, isA<MenstruationImportSuccess>());
        final staged = (result as MenstruationImportSuccess).conflicts;
        expect(staged.length, 2);

        // Verify conflict detected for overlapping record
        final conflictItem = staged.firstWhere(
          (i) => i.importedRecord.id == 'hc_menstruation_overlap',
        );
        expect(conflictItem.conflictType, MenstruationConflictType.overlap);
        expect(conflictItem.conflictingLocalPeriod, isNotNull);

        // Verify non-conflicting record
        final newItem = staged.firstWhere(
          (i) => i.importedRecord.id == 'hc_menstruation_new',
        );
        expect(newItem.conflictType, MenstruationConflictType.none);

        // 4. Resolve conflict with 'merge' strategy
        final overlapIndex = staged.indexOf(conflictItem);
        cycleController.updateConflictResolution(
          overlapIndex,
          MenstruationConflictResolution.merge,
        );

        // 5. Apply import atomically
        final importedCount = await cycleController.applyStagedImport();
        expect(importedCount, 2);

        // 6. Verify persisted database state in DriftCycleRepository
        final allPeriods = await cycleRepo.periods();
        expect(allPeriods.length, 2);

        // Merged period should span from 2026-07-01 to 2026-07-07
        final mergedPeriod = allPeriods.firstWhere(
          (p) => p.startDay.month == 7,
        );
        expect(mergedPeriod.startDay.day, 1);
        expect(mergedPeriod.endDay?.day, 7);
        expect(mergedPeriod.source, contains('merged'));

        // New period should be persisted cleanly
        final newPeriod = allPeriods.firstWhere((p) => p.startDay.month == 8);
        expect(newPeriod.startDay.day, 1);
        expect(newPeriod.endDay?.day, 5);
        expect(newPeriod.source, 'Garmin Connect');
      },
    );

    test(
      'foreground sync runs periodically and respects lifecycle changes',
      () async {
        await healthController.requestPermissions();
        expect(healthController.permissionState?.readGranted, isTrue);

        // Start periodic foreground sync
        healthController.startPeriodicForegroundSync(
          interval: const Duration(seconds: 30),
        );
        expect(healthController.isForegroundSyncActive, isTrue);

        final nowUtc = DateTime.now().toUtc();
        final todayStr = nowUtc.toIso8601String().substring(0, 10);

        // Add a record to fake source
        fakeSource.addRecord(
          HealthRecord(
            id: 'step_fg_1',
            metric: HealthMetric.steps,
            sourceId: 'com.google.android.apps.fitness',
            sourceName: 'Google Fit',
            startUtc: nowUtc.subtract(const Duration(minutes: 10)),
            endUtc: nowUtc.subtract(const Duration(minutes: 5)),
            localDay: todayStr,
            value: 750,
            unit: 'count',
          ),
        );

        // Trigger foreground periodic sync
        await healthController.triggerForegroundPeriodicSync();
        expect(
          healthController.summariesState.any((s) => s.steps == 750),
          isTrue,
        );

        // Pause lifecycle -> pauses active timer
        healthController.handleLifecycleChange(AppLifecycleState.paused);

        // Resume lifecycle -> resumes and triggers sync
        fakeSource.addRecord(
          HealthRecord(
            id: 'step_fg_2',
            metric: HealthMetric.steps,
            sourceId: 'com.google.android.apps.fitness',
            sourceName: 'Google Fit',
            startUtc: nowUtc.subtract(const Duration(minutes: 4)),
            endUtc: nowUtc.subtract(const Duration(minutes: 1)),
            localDay: todayStr,
            value: 250,
            unit: 'count',
          ),
        );
        await healthController.handleLifecycleChange(AppLifecycleState.resumed);
        expect(
          healthController.summariesState.any((s) => s.steps == 1000),
          isTrue,
        );

        // Cleanup
        healthController.stopPeriodicForegroundSync();
        expect(healthController.isForegroundSyncActive, isFalse);
      },
    );
  });
}
