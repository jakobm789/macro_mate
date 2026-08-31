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
  }) async {
    final day = CycleEngine.dateOnly(startDay);
    final end = endDay == null ? null : CycleEngine.dateOnly(endDay);
    if (end != null && end.isBefore(day)) {
      throw ArgumentError('Das Periodenende darf nicht vor dem Beginn liegen.');
    }
    await _database.into(_database.periodEntries).insert(
          PeriodEntriesCompanion.insert(
            id: _uuid.v4(),
            startDay: _formatDay(day),
            endDay: end == null ? const Value.absent() : Value(_formatDay(end)),
            flowJson: flow == null ? const Value.absent() : Value(flow.name),
            source: const Value('local'),
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
    await _database.into(_database.cycleDailyLogs).insertOnConflictUpdate(
          CycleDailyLogsCompanion.insert(
            day: _formatDay(log.day),
            bleeding: Value(log.bleeding?.name),
            mood: Value(log.mood),
            pain: Value(log.pain),
            energy: Value(log.energy),
            sleepQuality: Value(log.sleepQuality),
            notes: Value(log.notes),
            tagsJson: Value(jsonEncode(log.tags)),
            source: const Value('local'),
            updatedAtUtc: _clock.nowUtc().toIso8601String(),
          ),
        );
  }

  @override
  Future<void> deleteDailyLog(DateTime day) async {
    await (_database.delete(_database.cycleDailyLogs)
          ..where((table) => table.day.equals(_formatDay(day))))
        .go();
  }

  @override
  Future<List<CycleDailyLog>> dailyLogs({DateTime? from, DateTime? to}) async {
    final query = _database.select(_database.cycleDailyLogs)
      ..orderBy([(table) => OrderingTerm(expression: table.day)]);
    if (from != null) {
      query.where((table) => table.day.isBiggerOrEqualValue(_formatDay(from)));
    }
    if (to != null) {
      query.where((table) => table.day.isSmallerOrEqualValue(_formatDay(to)));
    }
    final rows = await query.get();
    return rows
        .map(
          (row) => CycleDailyLog(
            day: DateTime.parse(row.day),
            bleeding: _flowFromName(row.bleeding),
            mood: row.mood,
            pain: row.pain,
            energy: row.energy,
            sleepQuality: row.sleepQuality,
            notes: row.notes,
            tags: (jsonDecode(row.tagsJson) as List).cast<String>(),
          ),
        )
        .toList();
  }

  @override
  Future<CycleForecast?> recalculate({DateTime? today}) async {
    final currentProfile = await profile();
    final result = CycleEngine.forecast(
      periods: await periods(),
      today: today ?? _clock.now(),
      profile: currentProfile,
    );
    await _database.transaction(() async {
      await _database.delete(_database.cyclePredictions).go();
      if (result == null || !currentProfile.predictionsEnabled) return;
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
