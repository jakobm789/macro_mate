import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/health_models.dart';
import '../domain/health_repository.dart';
import 'health_data_source.dart';

class DriftHealthRepository implements HealthRepository {
  DriftHealthRepository(
      {required AppDatabase database, required HealthDataSource source})
      : _database = database,
        _source = source;

  final AppDatabase _database;
  final HealthDataSource _source;

  @override
  Future<HealthAvailability> availability() => _source.getAvailability();

  @override
  Future<HealthPermissionState> permissions() => _source.currentPermissions();

  @override
  Future<HealthPermissionState> requestPermissions({
    bool includeHistory = false,
    bool includeBackground = false,
  }) =>
      _source.requestPermissions(
        includeHistory: includeHistory,
        includeBackground: includeBackground,
      );

  @override
  Future<void> revokePermissions() => _source.revokePermissions();

  @override
  Future<List<DailyHealthSummary>> sync({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    // Health Connect can return overlapping samples when a range is re-read.
    // The provider UUID is the stable id, so deduplicate before aggregating.
    final recordsById = <String, HealthRecord>{};
    for (final record in await _source.read(startUtc, endUtc)) {
      recordsById[record.id] = record;
    }
    final records = recordsById.values.toList(growable: false);
    await _database.transaction(() async {
      final grouped = <String, List<HealthRecord>>{};
      for (final record in records) {
        await _database.into(_database.healthSources).insertOnConflictUpdate(
              HealthSourcesCompanion.insert(
                id: record.sourceId,
                sourceName: record.sourceName,
                sourceDeviceId: const Value.absent(),
                platform: 'health_connect',
                priority: const Value(0),
                enabled: const Value(true),
                discoveredAtUtc: DateTime.now().toUtc().toIso8601String(),
              ),
            );
        await _database.into(_database.healthRecords).insertOnConflictUpdate(
              HealthRecordsCompanion.insert(
                id: record.id,
                type: record.metric.name,
                sourceId: record.sourceId,
                startUtc: record.startUtc.toIso8601String(),
                endUtc: record.endUtc.toIso8601String(),
                value: record.value,
                unit: record.unit,
                localDay: record.localDay,
                payloadJson: Value(record.payloadJson),
              ),
            );
        grouped.putIfAbsent(record.localDay, () => []).add(record);
      }
      for (final entry in grouped.entries) {
        await _writeAggregate(entry.key, entry.value);
      }
    });
    return summaries(startDay: startUtc, endDay: endUtc);
  }

  Future<void> _writeAggregate(String day, List<HealthRecord> records) async {
    double? average(List<HealthRecord> values) {
      if (values.isEmpty) return null;
      return values.map((record) => record.value).reduce((a, b) => a + b) /
          values.length;
    }

    final steps = records
        .where((record) => record.metric == HealthMetric.steps)
        .fold<double>(0, (sum, record) => sum + record.value)
        .round();
    final activeCalories = records
        .where((record) => record.metric == HealthMetric.activeCalories)
        .fold<double>(0, (sum, record) => sum + record.value);
    final basalCalories = records
        .where((record) => record.metric == HealthMetric.basalCalories)
        .fold<double>(0, (sum, record) => sum + record.value);
    final distance = records
        .where((record) => record.metric == HealthMetric.distance)
        .fold<double>(0, (sum, record) => sum + record.value);
    final heartRates = records
        .where((record) => record.metric == HealthMetric.heartRate)
        .toList();
    final restingRates = records
        .where((record) => record.metric == HealthMetric.restingHeartRate)
        .toList();
    final sleepMinutes = records
        .where((record) => record.metric == HealthMetric.sleep)
        .fold<double>(0, (sum, record) => sum + record.value);
    await _database
        .into(_database.dailyHealthAggregates)
        .insertOnConflictUpdate(
          DailyHealthAggregatesCompanion.insert(
            day: day,
            steps: Value(steps),
            activeKcal: Value(activeCalories),
            totalKcal: Value(basalCalories + activeCalories),
            distanceM: Value(distance),
            heartRateAvg: Value(average(heartRates)),
            restingHr: Value(average(restingRates)),
            sleepMinutes: Value(sleepMinutes),
            sourceIds: Value(
                jsonEncode(records.map((r) => r.sourceId).toSet().toList())),
            updatedAtUtc: DateTime.now().toUtc().toIso8601String(),
          ),
        );
  }

  @override
  Future<List<DailyHealthSummary>> summaries({
    required DateTime startDay,
    required DateTime endDay,
  }) async {
    final rows = await (_database.select(_database.dailyHealthAggregates)
          ..where(
              (row) => row.day.isBetweenValues(_day(startDay), _day(endDay)))
          ..orderBy([(row) => OrderingTerm(expression: row.day)]))
        .get();
    return [
      for (final row in rows)
        DailyHealthSummary(
          day: DateTime.parse(row.day),
          steps: row.steps,
          activeCalories: row.activeKcal,
          distanceMeters: row.distanceM,
          totalCalories: row.totalKcal,
          averageHeartRate: row.heartRateAvg,
          restingHeartRate: row.restingHr,
          sleepMinutes: row.sleepMinutes,
          sourceIds: (jsonDecode(row.sourceIds) as List).cast<String>(),
        ),
    ];
  }

  String _day(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
