import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/domain/cycle_models.dart';
import 'package:macro_mate/features/cycle/presentation/cycle_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftCycleRepository repository;
  late CycleController controller;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftCycleRepository(database: db);
    controller = CycleController(repository: repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('Cycle Import & Conflict Resolution', () {
    test('detects non-conflicting, exact duplicate, and overlapping periods', () async {
      // Local period: 2026-07-01 to 2026-07-05
      await repository.addPeriod(
        startDay: DateTime(2026, 7, 1),
        endDay: DateTime(2026, 7, 5),
      );

      final imported = [
        // 1. Non-conflicting (August)
        HealthMenstruationRecord(
          id: 'rec_august',
          startDay: DateTime(2026, 8, 1),
          endDay: DateTime(2026, 8, 5),
          sourceName: 'Samsung Health',
        ),
        // 2. Exact Duplicate (July 1-5)
        HealthMenstruationRecord(
          id: 'rec_july_dup',
          startDay: DateTime(2026, 7, 1),
          endDay: DateTime(2026, 7, 5),
          sourceName: 'Google Fit',
        ),
        // 3. Overlap (July 4-8)
        HealthMenstruationRecord(
          id: 'rec_july_overlap',
          startDay: DateTime(2026, 7, 4),
          endDay: DateTime(2026, 7, 8),
          sourceName: 'Health Connect',
        ),
      ];

      final conflicts = await repository.detectImportConflicts(imported);

      expect(conflicts.length, 3);
      expect(conflicts[0].conflictType, MenstruationConflictType.none);
      expect(conflicts[0].chosenResolution, MenstruationConflictResolution.acceptImported);

      expect(conflicts[1].conflictType, MenstruationConflictType.exactDuplicate);
      expect(conflicts[1].chosenResolution, MenstruationConflictResolution.skip);

      expect(conflicts[2].conflictType, MenstruationConflictType.overlap);
      expect(conflicts[2].chosenResolution, MenstruationConflictResolution.merge);
    });

    test('merge resolution combines timeframes accurately', () async {
      // Local period: July 2 to July 6
      await repository.addPeriod(
        startDay: DateTime(2026, 7, 2),
        endDay: DateTime(2026, 7, 6),
      );

      final imported = [
        HealthMenstruationRecord(
          id: 'rec_merge_1',
          startDay: DateTime(2026, 7, 1),
          endDay: DateTime(2026, 7, 5),
          flow: BleedingLevel.heavy,
          sourceName: 'Garmin Connect',
        ),
      ];

      final conflicts = await repository.detectImportConflicts(imported);
      expect(conflicts.first.conflictType, MenstruationConflictType.overlap);
      conflicts.first.chosenResolution = MenstruationConflictResolution.merge;

      final count = await repository.applyMenstruationImport(conflicts);
      expect(count, 1);

      final periods = await repository.periods();
      expect(periods.length, 1);
      expect(periods.first.startDay, DateTime(2026, 7, 1));
      expect(periods.first.endDay, DateTime(2026, 7, 6));
      expect(periods.first.flow, BleedingLevel.heavy);
      expect(periods.first.source, contains('Garmin Connect'));
    });

    test('acceptImported replaces local period with imported record', () async {
      await repository.addPeriod(
        startDay: DateTime(2026, 6, 1),
        endDay: DateTime(2026, 6, 3),
      );

      final imported = [
        HealthMenstruationRecord(
          id: 'rec_replace',
          startDay: DateTime(2026, 6, 1),
          endDay: DateTime(2026, 6, 6),
          flow: BleedingLevel.medium,
          sourceName: 'Health Connect',
        ),
      ];

      final conflicts = await repository.detectImportConflicts(imported);
      conflicts.first.chosenResolution = MenstruationConflictResolution.acceptImported;

      final count = await repository.applyMenstruationImport(conflicts);
      expect(count, 1);

      final periods = await repository.periods();
      expect(periods.length, 1);
      expect(periods.first.startDay, DateTime(2026, 6, 1));
      expect(periods.first.endDay, DateTime(2026, 6, 6));
      expect(periods.first.source, 'Health Connect');
    });

    test('keepLocal and skip preserve local period without modifications', () async {
      await repository.addPeriod(
        startDay: DateTime(2026, 5, 1),
        endDay: DateTime(2026, 5, 5),
      );

      final imported = [
        HealthMenstruationRecord(
          id: 'rec_skip',
          startDay: DateTime(2026, 5, 2),
          endDay: DateTime(2026, 5, 6),
          sourceName: 'External Source',
        ),
      ];

      final conflicts = await repository.detectImportConflicts(imported);
      conflicts.first.chosenResolution = MenstruationConflictResolution.keepLocal;

      final count = await repository.applyMenstruationImport(conflicts);
      expect(count, 0);

      final periods = await repository.periods();
      expect(periods.length, 1);
      expect(periods.first.startDay, DateTime(2026, 5, 1));
      expect(periods.first.endDay, DateTime(2026, 5, 5));
    });

    test('imported period can subsequently be edited or deleted by user', () async {
      final imported = [
        HealthMenstruationRecord(
          id: 'rec_edit_del',
          startDay: DateTime(2026, 4, 1),
          endDay: DateTime(2026, 4, 5),
          sourceName: 'Health Connect',
        ),
      ];

      final conflicts = await repository.detectImportConflicts(imported);
      await repository.applyMenstruationImport(conflicts);

      var periods = await repository.periods();
      expect(periods.length, 1);
      final importedId = periods.first.id;

      // Edit
      await repository.updatePeriod(
        id: importedId,
        startDay: DateTime(2026, 4, 2),
        endDay: DateTime(2026, 4, 6),
        flow: BleedingLevel.light,
      );

      periods = await repository.periods();
      expect(periods.first.startDay, DateTime(2026, 4, 2));
      expect(periods.first.endDay, DateTime(2026, 4, 6));

      // Delete
      await repository.deletePeriod(importedId);
      periods = await repository.periods();
      expect(periods, isEmpty);
    });

    test('CycleController handles staging and applying import flow', () async {
      final records = [
        HealthMenstruationRecord(
          id: 'rec_ctrl_1',
          startDay: DateTime(2026, 3, 1),
          endDay: DateTime(2026, 3, 5),
          sourceName: 'Samsung Health',
        ),
      ];

      final conflicts = await controller.stageImportPreview(records);
      expect(conflicts.length, 1);
      expect(controller.pendingImportConflicts.length, 1);

      controller.updateConflictResolution(0, MenstruationConflictResolution.acceptImported);
      final count = await controller.applyStagedImport();

      expect(count, 1);
      expect(controller.pendingImportConflicts, isEmpty);
      expect(controller.periodsState.length, 1);
      expect(controller.periodsState.first.startDay, DateTime(2026, 3, 1));
    });
  });
}
