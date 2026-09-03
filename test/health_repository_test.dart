import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/cycle/domain/cycle_models.dart';
import 'package:macro_mate/features/health/data/drift_health_repository.dart';
import 'package:macro_mate/features/health/data/health_data_source.dart';
import 'package:macro_mate/features/health/domain/health_models.dart';

class _FakeHealthSource implements HealthDataSource {
  _FakeHealthSource(this.records);

  final List<HealthRecord> records;
  final reads = <({DateTime start, DateTime end})>[];

  @override
  Future<HealthAvailability> getAvailability() async =>
      HealthAvailability.available;

  @override
  Future<HealthPermissionState> currentPermissions() async =>
      const HealthPermissionState(
        readGranted: true,
        historyGranted: false,
        backgroundGranted: false,
      );

  @override
  Future<HealthPermissionState> requestPermissions({
    bool includeHistory = false,
    bool includeBackground = false,
  }) async =>
      currentPermissions();

  @override
  Future<void> revokePermissions() async {}

  @override
  Future<List<HealthRecord>> read(DateTime startUtc, DateTime endUtc) async {
    reads.add((start: startUtc, end: endUtc));
    return records;
  }

  @override
  Future<bool> hasMenstruationPermission() async => true;

  @override
  Future<bool> requestMenstruationPermission() async => true;

  @override
  Future<List<HealthMenstruationRecord>> readMenstruation(
    DateTime startUtc,
    DateTime endUtc,
  ) async =>
      [];

  @override
  Future<int?> getTotalStepsInInterval(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final stepRecords = records.where((r) =>
        r.metric == HealthMetric.steps &&
        !r.startUtc.isBefore(startTime) &&
        !r.startUtc.isAfter(endTime));
    if (stepRecords.isEmpty) return null;
    return stepRecords.fold<int>(0, (sum, r) => sum + r.value.round());
  }
}


HealthRecord _record({
  required String id,
  required HealthMetric metric,
  required double value,
}) {
  final start = DateTime.utc(2026, 8, 30, 8);
  return HealthRecord(
    id: id,
    metric: metric,
    sourceId: 'watch-1',
    sourceName: 'Test Watch',
    startUtc: start,
    endUtc: start.add(const Duration(minutes: 30)),
    value: value,
    unit: metric == HealthMetric.steps ? 'count' : 'kcal',
    localDay: '2026-08-30',
  );
}

void main() {
  test('sync deduplicates provider records and writes daily aggregate',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final source = _FakeHealthSource([
      _record(id: 'steps-1', metric: HealthMetric.steps, value: 1200),
      _record(id: 'steps-1', metric: HealthMetric.steps, value: 1200),
      _record(id: 'active-1', metric: HealthMetric.activeCalories, value: 350),
      _record(id: 'hr-1', metric: HealthMetric.heartRate, value: 70),
      _record(id: 'hr-2', metric: HealthMetric.heartRate, value: 80),
      _record(id: 'sleep-1', metric: HealthMetric.sleep, value: 420),
    ]);
    final repository =
        DriftHealthRepository(database: database, source: source);

    final summaries = await repository.sync(
      startUtc: DateTime.utc(2026, 8, 1),
      endUtc: DateTime.utc(2026, 8, 31),
    );

    final stored = await database.select(database.healthRecords).get();
    expect(stored, hasLength(5));
    expect(summaries, hasLength(1));
    expect(summaries.single.steps, 1200);
    expect(summaries.single.activeCalories, 350);
    expect(summaries.single.averageHeartRate, 75);
    expect(summaries.single.sleepMinutes, 420);

    final syncStates = await repository.syncStates();
    expect(syncStates, hasLength(HealthMetric.values.length));
    expect(
        syncStates.every((state) => state.status == HealthSyncStatus.success),
        isTrue);
    final sources = await repository.sources();
    expect(sources.single.recordCount, 5);
    final sleepRows = await database.select(database.sleepSessions).get();
    expect(sleepRows, hasLength(1));

    await repository.sync(
      startUtc: DateTime.utc(2026, 8, 1),
      endUtc: DateTime.utc(2026, 8, 31),
    );
    expect(source.reads, hasLength(2));
    expect(
      source.reads.last.start,
      DateTime.utc(2026, 8, 30, 2, 30),
    );
  });
}
