import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/time/clock.dart';
import '../../cycle/domain/cycle_models.dart';
import '../domain/health_models.dart';
import '../domain/health_repository.dart';
import 'health_data_source.dart';

class DriftHealthRepository implements HealthRepository {
  DriftHealthRepository(
      {required AppDatabase database,
      required HealthDataSource source,
      Clock clock = const SystemClock(),
      this.overlap = const Duration(hours: 6)})
      : _database = database,
        _source = source,
        _clock = clock;

  final AppDatabase _database;
  final HealthDataSource _source;
  final Clock _clock;
  final Duration overlap;

  static const _syncPrefix = 'health_connect:';

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
    final states = await syncStates();
    final cursors = <HealthMetric, DateTime?>{
      for (final metric in HealthMetric.values)
        metric: _cursorFor(states, metric),
    };
    final persistedStart = cursors.values
        .whereType<DateTime>()
        .map((value) => value.subtract(overlap))
        .fold<DateTime?>(null, (oldest, value) {
      if (oldest == null || value.isBefore(oldest)) return value;
      return oldest;
    });
    final readStart =
        persistedStart == null || persistedStart.isBefore(startUtc)
            ? startUtc
            : persistedStart;
    final keys = HealthMetric.values.map(_keyForMetric).toList(growable: false);
    await _setSyncStatus(keys, HealthSyncStatus.running);
    try {
      // Health Connect can return overlapping samples when a range is re-read.
      // The provider UUID is the stable id, so deduplicate before aggregating.
      final recordsById = <String, HealthRecord>{};
      for (final record in await _source.read(readStart, endUtc)) {
        recordsById[record.id] = record;
      }
      final records = recordsById.values.toList(growable: false);
      final affectedDays = <String>{};
      await _database.transaction(() async {
        for (final record in records) {
          affectedDays.add(record.localDay);
          await _database.into(_database.healthSources).insertOnConflictUpdate(
                HealthSourcesCompanion.insert(
                  id: record.sourceId,
                  sourceName: record.sourceName,
                  sourceDeviceId: const Value.absent(),
                  platform: 'health_connect',
                  priority: Value(_sourcePriority(record.sourceName)),
                  enabled: const Value(true),
                  discoveredAtUtc: _clock.nowUtc().toIso8601String(),
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
          await _upsertDetail(record);
        }
        for (final day in affectedDays) {
          await _rebuildAggregate(day);
        }
      });
      final now = _clock.nowUtc();
      for (final metric in HealthMetric.values) {
        final metricRecords = records.where((r) => r.metric == metric);
        final cursor = metricRecords.isEmpty
            ? endUtc
            : metricRecords
                .map((record) => record.endUtc)
                .reduce((a, b) => a.isAfter(b) ? a : b);
        await _writeSyncState(
          _keyForMetric(metric),
          metric,
          status: HealthSyncStatus.success,
          cursorUtc: cursor,
          lastSuccessUtc: now,
        );
      }
    } catch (error) {
      for (final metric in HealthMetric.values) {
        await _writeSyncState(
          _keyForMetric(metric),
          metric,
          status: HealthSyncStatus.failed,
          lastError: _safeError(error),
        );
      }
      rethrow;
    }
    return summaries(startDay: startUtc, endDay: endUtc);
  }

  Future<void> _rebuildAggregate(String day) async {
    final sourceRows = await _database.select(_database.healthSources).get();
    final sourceNames = <String, String>{
      for (final source in sourceRows) source.id: source.sourceName,
    };
    final rows = await (_database.select(_database.healthRecords)
          ..where((row) => row.localDay.equals(day)))
        .get();
    final records = rows
        .map(
          (row) => HealthRecord(
            id: row.id,
            metric: HealthMetric.values.firstWhere(
              (metric) => metric.name == row.type,
              orElse: () => HealthMetric.steps,
            ),
            sourceId: row.sourceId,
            sourceName: sourceNames[row.sourceId] ?? row.sourceId,
            startUtc: DateTime.parse(row.startUtc),
            endUtc: DateTime.parse(row.endUtc),
            value: row.value,
            unit: row.unit,
            localDay: row.localDay,
            payloadJson: row.payloadJson,
          ),
        )
        .toList(growable: false);
    await _writeAggregate(day, records);
  }

  Future<void> _writeAggregate(String day, List<HealthRecord> records) async {
    List<HealthRecord> preferred(HealthMetric metric) {
      final values = records.where((r) => r.metric == metric).toList();
      if (values.isEmpty) return values;
      final priorities = <String, int>{};
      for (final value in values) {
        priorities[value.sourceId] = _sourcePriority(
            value.sourceName.isEmpty ? value.sourceId : value.sourceName);
      }
      final maxPriority = priorities.values.reduce((a, b) => a > b ? a : b);
      final sourceIds = priorities.entries
          .where((entry) => entry.value == maxPriority)
          .map((entry) => entry.key)
          .toSet();
      return values
          .where((value) => sourceIds.contains(value.sourceId))
          .toList();
    }

    double? average(List<HealthRecord> values) {
      if (values.isEmpty) return null;
      return values.map((record) => record.value).reduce((a, b) => a + b) /
          values.length;
    }

    final steps = preferred(HealthMetric.steps)
        .fold<double>(0, (sum, record) => sum + record.value)
        .round();
    final activeCalories = preferred(HealthMetric.activeCalories)
        .fold<double>(0, (sum, record) => sum + record.value);
    final basalCalories = preferred(HealthMetric.basalCalories)
        .fold<double>(0, (sum, record) => sum + record.value);
    final distance = preferred(HealthMetric.distance)
        .fold<double>(0, (sum, record) => sum + record.value);
    final heartRates = preferred(HealthMetric.heartRate);
    final restingRates = preferred(HealthMetric.restingHeartRate);
    final sleepMinutes = preferred(HealthMetric.sleep)
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
            updatedAtUtc: _clock.nowUtc().toIso8601String(),
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

  @override
  Future<List<HealthSyncState>> syncStates() async {
    final rows = await _database.select(_database.healthSyncStates).get();
    return [
      for (final row in rows)
        HealthSyncState(
          key: row.sourceId,
          metric: _metricFromKey(row.sourceId),
          status: _statusFromName(row.status),
          cursorUtc: _parseUtc(row.cursorUtc),
          lastSuccessUtc: _parseUtc(row.lastSuccessUtc),
          lastError: row.lastError,
        ),
    ];
  }

  @override
  Future<List<WorkoutDetail>> workouts({int limit = 50}) async {
    final rows = await (_database.select(_database.workoutSessions)
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.startUtc,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(limit))
        .get();

    return [
      for (final row in rows)
        WorkoutDetail(
          id: row.id,
          type: row.type,
          startUtc: DateTime.parse(row.startUtc),
          endUtc: DateTime.parse(row.endUtc),
          durationSeconds: row.durationSeconds,
          distanceMeters: row.distanceM,
          energyKcal: row.energyKcal,
          sourceId: row.sourceId,
          routeStatus: row.routeStatus,
        ),
    ];
  }

  @override
  Future<WorkoutDetail?> workoutById(String id) async {
    final row = await (_database.select(_database.workoutSessions)
          ..where((tbl) => tbl.id.equals(id))
          ..limit(1))
        .getSingleOrNull();

    if (row == null) return null;

    final routeRows = await (_database.select(_database.workoutRoutePoints)
          ..where((tbl) => tbl.workoutId.equals(id))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.sequence)]))
        .get();

    final routePoints = routeRows
        .map((p) => WorkoutRoutePointModel(
              latitude: p.latitude,
              longitude: p.longitude,
              timestampUtc: DateTime.parse(p.timestampUtc),
            ))
        .toList();

    return WorkoutDetail(
      id: row.id,
      type: row.type,
      startUtc: DateTime.parse(row.startUtc),
      endUtc: DateTime.parse(row.endUtc),
      durationSeconds: row.durationSeconds,
      distanceMeters: row.distanceM,
      energyKcal: row.energyKcal,
      sourceId: row.sourceId,
      routeStatus: row.routeStatus,
      routePoints: routePoints,
    );
  }

  @override
  Future<List<SleepSessionDetail>> sleepSessions({int limit = 30}) async {
    final rows = await (_database.select(_database.sleepSessions)
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.startUtc,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(limit))
        .get();

    return [
      for (final row in rows)
        SleepSessionDetail(
          id: row.id,
          startUtc: DateTime.parse(row.startUtc),
          endUtc: DateTime.parse(row.endUtc),
          durationMinutes: row.durationMinutes,
          sourceId: row.sourceId,
          stagesJson: row.stagesJson,
        ),
    ];
  }

  @override
  Future<List<HealthSourceSummary>> sources() async {
    final sourceRows = await _database.select(_database.healthSources).get();
    final recordRows = await _database.select(_database.healthRecords).get();
    return [
      for (final source in sourceRows)
        HealthSourceSummary(
          id: source.id,
          name: source.sourceName,
          platform: source.platform,
          priority: source.priority,
          recordCount:
              recordRows.where((record) => record.sourceId == source.id).length,
        ),
    ];
  }

  Future<void> _setSyncStatus(
    Iterable<String> keys,
    HealthSyncStatus status,
  ) async {
    for (final key in keys) {
      final metric = _metricFromKey(key);
      await _writeSyncState(key, metric, status: status);
    }
  }

  Future<void> _writeSyncState(
    String key,
    HealthMetric metric, {
    required HealthSyncStatus status,
    DateTime? cursorUtc,
    DateTime? lastSuccessUtc,
    String? lastError,
  }) async {
    final old = await (_database.select(_database.healthSyncStates)
          ..where((row) => row.sourceId.equals(key)))
        .getSingleOrNull();
    await _database.into(_database.healthSyncStates).insertOnConflictUpdate(
          HealthSyncStatesCompanion.insert(
            sourceId: key,
            cursorUtc: Value(cursorUtc?.toIso8601String() ?? old?.cursorUtc),
            lastSuccessUtc:
                Value(lastSuccessUtc?.toIso8601String() ?? old?.lastSuccessUtc),
            lastError: Value(lastError),
            status: Value(status.name),
          ),
        );
  }

  DateTime? _cursorFor(List<HealthSyncState> states, HealthMetric metric) =>
      states
          .where((state) => state.metric == metric)
          .map((state) => state.cursorUtc)
          .whereType<DateTime>()
          .fold<DateTime?>(null, (oldest, value) {
        if (oldest == null || value.isBefore(oldest)) return value;
        return oldest;
      });

  Future<void> _upsertDetail(HealthRecord record) async {
    if (record.metric == HealthMetric.sleep) {
      await _database.into(_database.sleepSessions).insertOnConflictUpdate(
            SleepSessionsCompanion.insert(
              id: record.id,
              startUtc: record.startUtc.toIso8601String(),
              endUtc: record.endUtc.toIso8601String(),
              durationMinutes:
                  record.endUtc.difference(record.startUtc).inMinutes,
              sourceId: record.sourceId,
              stagesJson: Value(record.payloadJson),
            ),
          );
    } else if (record.metric == HealthMetric.workout) {
      final payload = _decodePayload(record.payloadJson);
      final route = _payloadRoute(payload, record);
      await _database.into(_database.workoutSessions).insertOnConflictUpdate(
            WorkoutSessionsCompanion.insert(
              id: record.id,
              type: _payloadString(payload, const [
                    'workoutType',
                    'exerciseType',
                    'type',
                  ]) ??
                  'Workout',
              startUtc: record.startUtc.toIso8601String(),
              endUtc: record.endUtc.toIso8601String(),
              durationSeconds: record.endUtc
                  .difference(record.startUtc)
                  .inSeconds
                  .toDouble(),
              distanceM: Value(_payloadNumber(payload, const [
                'totalDistance',
                'distanceMeters',
                'distance_meters',
                'distance',
              ])),
              energyKcal: Value(record.value),
              sourceId: record.sourceId,
              routeStatus: Value(route.isEmpty ? 'unavailable' : 'available'),
            ),
          );
      await (_database.delete(_database.workoutRoutePoints)
            ..where((row) => row.workoutId.equals(record.id)))
          .go();
      for (var index = 0; index < route.length; index++) {
        final point = route[index];
        await _database.into(_database.workoutRoutePoints).insert(
              WorkoutRoutePointsCompanion.insert(
                workoutId: record.id,
                sequence: index,
                latitude: point.latitude,
                longitude: point.longitude,
                timestampUtc: point.timestampUtc,
              ),
            );
      }
    }
  }

  Map<String, dynamic> _decodePayload(String? value) {
    if (value == null || value.isEmpty) return const {};
    try {
      final decoded = jsonDecode(value);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }

  String? _payloadString(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  double? _payloadNumber(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is num) return value.toDouble();
      if (value is Map<String, dynamic>) {
        final nested = value['numericValue'];
        if (nested is num) return nested.toDouble();
      }
    }
    return null;
  }

  List<_RoutePoint> _payloadRoute(
    Map<String, dynamic> payload,
    HealthRecord record,
  ) {
    final raw = payload['routePoints'] ?? payload['route'];
    if (raw is! List) return const [];
    final points = <_RoutePoint>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final lat = item['latitude'];
      final lon = item['longitude'];
      if (lat is! num || lon is! num) continue;
      final timestamp = item['timestampUtc'] ?? item['timestamp'];
      final time =
          timestamp is String ? DateTime.tryParse(timestamp)?.toUtc() : null;
      points.add(
        _RoutePoint(
          latitude: lat.toDouble(),
          longitude: lon.toDouble(),
          timestampUtc: (time ?? record.startUtc).toIso8601String(),
        ),
      );
    }
    return points;
  }

  static int _sourcePriority(String sourceName) {
    final name = sourceName.toLowerCase();
    if (name.contains('samsung')) return 30;
    if (name.contains('garmin') || name.contains('fitbit')) return 25;
    if (name.contains('watch') || name.contains('wear')) return 20;
    if (name.contains('google') || name.contains('phone')) return 10;
    return 0;
  }

  static String _keyForMetric(HealthMetric metric) =>
      '$_syncPrefix${metric.name}';

  static HealthMetric _metricFromKey(String key) {
    final name =
        key.startsWith(_syncPrefix) ? key.substring(_syncPrefix.length) : key;
    return HealthMetric.values.firstWhere(
      (metric) => metric.name == name,
      orElse: () => HealthMetric.steps,
    );
  }

  static HealthSyncStatus _statusFromName(String name) =>
      HealthSyncStatus.values.firstWhere(
        (status) => status.name == name,
        orElse: () => HealthSyncStatus.never,
      );

  static DateTime? _parseUtc(String? value) =>
      value == null ? null : DateTime.tryParse(value)?.toUtc();

  static String _safeError(Object error) {
    final text = error.toString().split('\n').first;
    final redacted = text.replaceAll(
      RegExp(
        r'(password|token|secret|api[_-]?key)\s*[:=]\s*[^,; ]+',
        caseSensitive: false,
      ),
      '[redacted]',
    );
    return redacted.length > 240 ? '${redacted.substring(0, 240)}…' : redacted;
  }

  @override
  Future<bool> hasMenstruationPermission() {
    return _source.hasMenstruationPermission();
  }

  @override
  Future<bool> requestMenstruationPermission() {
    return _source.requestMenstruationPermission();
  }

  @override
  Future<List<HealthMenstruationRecord>> readMenstruation({
    required DateTime startUtc,
    required DateTime endUtc,
  }) {
    return _source.readMenstruation(startUtc, endUtc);
  }
}

class _RoutePoint {
  const _RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.timestampUtc,
  });

  final double latitude;
  final double longitude;
  final String timestampUtc;
}
