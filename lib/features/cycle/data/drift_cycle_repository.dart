import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/time/clock.dart';
import '../domain/cycle_engine.dart';
import '../domain/cycle_models.dart';
import '../domain/cycle_repository.dart';

class DriftCycleRepository implements CycleRepository {
  DriftCycleRepository({
    required AppDatabase database,
    Clock clock = const SystemClock(),
  })  : _database = database,
        _clock = clock;

  final AppDatabase _database;
  final Clock _clock;
  static const _uuid = Uuid();

  @override
  Future<CycleProfile> profile() async {
    final row = await (_database.select(_database.cycleProfiles)
          ..where((table) => table.id.equals(1)))
        .getSingleOrNull();
    if (row == null) return const CycleProfile();
    return CycleProfile(
      typicalCycleLength: row.typicalCycleLength,
      typicalPeriodLength: row.typicalPeriodLength,
      predictionsEnabled: row.predictionsEnabled,
      healthImportEnabled: row.healthImportEnabled,
      timezone: row.timezone,
    );
  }

  @override
  Future<void> saveProfile(CycleProfile profile) =>
      _database.into(_database.cycleProfiles).insertOnConflictUpdate(
            CycleProfilesCompanion.insert(
              id: const Value(1),
              typicalCycleLength: Value(profile.typicalCycleLength),
              typicalPeriodLength: Value(profile.typicalPeriodLength),
              predictionsEnabled: Value(profile.predictionsEnabled),
              healthImportEnabled: Value(profile.healthImportEnabled),
              timezone: Value(profile.timezone),
            ),
          );

  @override
  Future<List<PeriodEntry>> periods() async {
    final rows = await (_database.select(_database.periodEntries)
          ..orderBy([(table) => OrderingTerm(expression: table.startDay)]))
        .get();
    return rows
        .map(
          (row) => PeriodEntry(
            id: row.id,
            startDay: DateTime.parse(row.startDay),
            endDay: row.endDay == null ? null : DateTime.parse(row.endDay!),
            flow: _flowFromJson(row.flowJson),
            source: row.source,
          ),
        )
        .toList();
  }

  @override
  Future<void> addPeriod({
    required DateTime startDay,
    DateTime? endDay,
    BleedingLevel? flow,
    String? id,
    String source = 'local',
  }) async {
    final day = CycleEngine.dateOnly(startDay);
    final end = endDay == null ? null : CycleEngine.dateOnly(endDay);
    if (end != null && end.isBefore(day)) {
      throw ArgumentError('Das Periodenende darf nicht vor dem Beginn liegen.');
    }
    await _database.into(_database.periodEntries).insert(
          PeriodEntriesCompanion.insert(
            id: id ?? _uuid.v4(),
            startDay: _formatDay(day),
            endDay: end == null ? const Value.absent() : Value(_formatDay(end)),
            flowJson: flow == null ? const Value.absent() : Value(flow.name),
            source: Value(source),
            createdAtUtc: _clock.nowUtc().toIso8601String(),
          ),
        );
    await recalculate(today: _clock.now());
  }

  @override
  Future<void> updatePeriod({
    required String id,
    required DateTime startDay,
    DateTime? endDay,
    BleedingLevel? flow,
    String? source,
  }) async {
    final start = CycleEngine.dateOnly(startDay);
    final end = endDay == null ? null : CycleEngine.dateOnly(endDay);
    if (end != null && end.isBefore(start)) {
      throw ArgumentError('Das Periodenende darf nicht vor dem Beginn liegen.');
    }
    await (_database.update(_database.periodEntries)
          ..where((table) => table.id.equals(id)))
        .write(
      PeriodEntriesCompanion(
        startDay: Value(_formatDay(start)),
        endDay: Value(end == null ? null : _formatDay(end)),
        flowJson: Value(flow?.name),
        source: source != null ? Value(source) : const Value.absent(),
      ),
    );
    await recalculate(today: _clock.now());
  }

  @override
  Future<void> deletePeriod(String id) async {
    await (_database.delete(_database.periodEntries)
          ..where((table) => table.id.equals(id)))
        .go();
    await recalculate(today: _clock.now());
  }

  @override
  Future<void> saveDailyLog(CycleDailyLog log) async {
    if (log.pain != null && (log.pain! < 0 || log.pain! > 10)) {
      throw ArgumentError('Schmerz muss zwischen 0 und 10 liegen.');
    }
    if (log.energy != null && (log.energy! < 0 || log.energy! > 10)) {
      throw ArgumentError('Energie muss zwischen 0 und 10 liegen.');
    }
    if (log.sleepQuality != null &&
        (log.sleepQuality! < 0 || log.sleepQuality! > 10)) {
      throw ArgumentError('Schlafqualität muss zwischen 0 und 10 liegen.');
    }
    final day = CycleEngine.dateOnly(log.day);
    await _database.into(_database.cycleDailyLogs).insertOnConflictUpdate(
          CycleDailyLogsCompanion.insert(
            day: _formatDay(day),
            bleeding: log.bleeding == null
                ? const Value.absent()
                : Value(log.bleeding!.name),
            mood: Value(log.mood),
            pain: Value(log.pain),
            energy: Value(log.energy),
            sleepQuality: Value(log.sleepQuality),
            notes: Value(log.notes),
            tagsJson: Value(jsonEncode(log.tags)),
            updatedAtUtc: _clock.nowUtc().toIso8601String(),
          ),
        );
    await recalculate(today: _clock.now());
  }

  @override
  Future<void> deleteDailyLog(DateTime day) async {
    final d = CycleEngine.dateOnly(day);
    await (_database.delete(_database.cycleDailyLogs)
          ..where((table) => table.day.equals(_formatDay(d))))
        .go();
    await recalculate(today: _clock.now());
  }

  @override
  Future<List<CycleDailyLog>> dailyLogs({DateTime? from, DateTime? to}) async {
    var query = _database.select(_database.cycleDailyLogs);
    if (from != null) {
      query = query
        ..where((table) => table.day.isBiggerOrEqualValue(_formatDay(from)));
    }
    if (to != null) {
      query = query
        ..where((table) => table.day.isSmallerOrEqualValue(_formatDay(to)));
    }
    final rows = await (query
          ..orderBy([(table) => OrderingTerm(expression: table.day)]))
        .get();
    return rows
        .map(
          (row) => CycleDailyLog(
            day: DateTime.parse(row.day),
            bleeding: _flowFromJson(row.bleeding),
            mood: row.mood,
            pain: row.pain,
            energy: row.energy,
            sleepQuality: row.sleepQuality,
            notes: row.notes,
            tags: row.tagsJson.isEmpty
                ? const []
                : List<String>.from(jsonDecode(row.tagsJson)),
          ),
        )
        .toList();
  }

  @override
  Future<CycleForecast?> recalculate({DateTime? today}) async {
    final profileData = await profile();
    final periodList = await periods();
    final result = CycleEngine.forecast(
      profile: profileData,
      periods: periodList,
      today: today ?? _clock.now(),
    );
    await _database.transaction(() async {
      await _database.delete(_database.cyclePredictions).go();
      if (result == null) return;
      final calculatedAt = _clock.nowUtc().toIso8601String();
      for (final prediction in result.predictions) {
        await _database.into(_database.cyclePredictions).insert(
              CyclePredictionsCompanion.insert(
                id: _uuid.v4(),
                kind: prediction.kind,
                windowStart: _formatDay(prediction.windowStart),
                windowEnd: _formatDay(prediction.windowEnd),
                confidence: prediction.confidence,
                rationale: prediction.rationale,
                calculatedAtUtc: calculatedAt,
              ),
            );
      }
    });
    return result;
  }

  @override
  Future<List<CyclePrediction>> predictions() async {
    final rows = await (_database.select(_database.cyclePredictions)
          ..orderBy([(table) => OrderingTerm(expression: table.windowStart)]))
        .get();
    return rows
        .map(
          (row) => CyclePrediction(
            kind: row.kind,
            windowStart: DateTime.parse(row.windowStart),
            windowEnd: DateTime.parse(row.windowEnd),
            confidence: row.confidence,
            rationale: row.rationale,
          ),
        )
        .toList();
  }

  @override
  Future<List<CycleConflictItem>> detectImportConflicts(
    List<HealthMenstruationRecord> importedRecords,
  ) async {
    final localPeriods = await periods();
    final result = <CycleConflictItem>[];

    for (final record in importedRecords) {
      final importStart = CycleEngine.dateOnly(record.startDay);
      final importEnd = record.endDay != null
          ? CycleEngine.dateOnly(record.endDay!)
          : importStart.add(const Duration(days: 4));

      PeriodEntry? conflicting;
      var conflictType = MenstruationConflictType.none;

      for (final local in localPeriods) {
        final localStart = CycleEngine.dateOnly(local.startDay);
        final localEnd = local.endDay != null
            ? CycleEngine.dateOnly(local.endDay!)
            : localStart.add(const Duration(days: 4));

        // Exact match
        if (localStart.isAtSameMomentAs(importStart) &&
            localEnd.isAtSameMomentAs(importEnd)) {
          conflicting = local;
          conflictType = MenstruationConflictType.exactDuplicate;
          break;
        }

        // Overlap: localStart <= importEnd && importStart <= localEnd
        if (!localStart.isAfter(importEnd) && !importStart.isAfter(localEnd)) {
          conflicting = local;
          if (!localStart.isAfter(importStart) &&
              !localEnd.isBefore(importEnd)) {
            conflictType = MenstruationConflictType.contains;
          } else {
            conflictType = MenstruationConflictType.overlap;
          }
          break;
        }
      }

      final defaultResolution =
          conflictType == MenstruationConflictType.exactDuplicate
              ? MenstruationConflictResolution.skip
              : conflictType == MenstruationConflictType.none
                  ? MenstruationConflictResolution.acceptImported
                  : MenstruationConflictResolution.merge;

      result.add(
        CycleConflictItem(
          importedRecord: record,
          conflictingLocalPeriod: conflicting,
          conflictType: conflictType,
          chosenResolution: defaultResolution,
        ),
      );
    }

    return result;
  }

  @override
  Future<int> applyMenstruationImport(
      List<CycleConflictItem> resolvedItems) async {
    var importedCount = 0;

    await _database.transaction(() async {
      for (final item in resolvedItems) {
        final record = item.importedRecord;
        final importStart = CycleEngine.dateOnly(record.startDay);
        final importEnd =
            record.endDay != null ? CycleEngine.dateOnly(record.endDay!) : null;

        switch (item.chosenResolution) {
          case MenstruationConflictResolution.skip:
          case MenstruationConflictResolution.keepLocal:
            // Do not modify anything
            break;

          case MenstruationConflictResolution.acceptImported:
            if (item.conflictingLocalPeriod != null) {
              await deletePeriod(item.conflictingLocalPeriod!.id);
            }
            await addPeriod(
              startDay: importStart,
              endDay: importEnd,
              flow: record.flow,
              id: 'hc_${record.id}',
              source: record.sourceName,
            );
            importedCount++;
            break;

          case MenstruationConflictResolution.merge:
            if (item.conflictingLocalPeriod != null) {
              final local = item.conflictingLocalPeriod!;
              final localStart = CycleEngine.dateOnly(local.startDay);
              final localEnd = local.endDay != null
                  ? CycleEngine.dateOnly(local.endDay!)
                  : localStart;
              final impEnd = importEnd ?? importStart;

              final mergedStart =
                  localStart.isBefore(importStart) ? localStart : importStart;
              final mergedEnd = localEnd.isAfter(impEnd) ? localEnd : impEnd;

              await updatePeriod(
                id: local.id,
                startDay: mergedStart,
                endDay: mergedEnd,
                flow: record.flow ?? local.flow,
                source: 'merged (${record.sourceName})',
              );
              importedCount++;
            } else {
              await addPeriod(
                startDay: importStart,
                endDay: importEnd,
                flow: record.flow,
                id: 'hc_${record.id}',
                source: record.sourceName,
              );
              importedCount++;
            }
            break;
        }
      }
    });

    await recalculate(today: _clock.now());
    return importedCount;
  }

  static BleedingLevel? _flowFromJson(String? value) => _flowFromName(value);

  static BleedingLevel? _flowFromName(String? value) {
    if (value == null) return null;
    for (final item in BleedingLevel.values) {
      if (item.name == value) return item;
    }
    return null;
  }

  static String _formatDay(DateTime value) {
    final day = CycleEngine.dateOnly(value);
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }
}
