import 'dart:convert';

import 'package:health/health.dart';

import '../domain/health_models.dart';
import 'health_data_source.dart';

class HealthConnectSource implements HealthDataSource {
  HealthConnectSource({Health? client}) : _client = client ?? Health();

  final Health _client;
  bool _configured = false;

  static const _types = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.WORKOUT,
  ];

  Future<void> _configure() async {
    if (_configured) return;
    await _client.configure();
    _configured = true;
  }

  @override
  Future<HealthAvailability> getAvailability() async {
    await _configure();
    if (!await _client.isHealthConnectAvailable()) {
      final status = await _client.getHealthConnectSdkStatus();
      return status ==
              HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired
          ? HealthAvailability.installRequired
          : HealthAvailability.unavailable;
    }
    return HealthAvailability.available;
  }

  @override
  Future<HealthPermissionState> currentPermissions() async {
    await _configure();
    final read = await _client.hasPermissions(_types) ?? false;
    final history = await _client.isHealthDataHistoryAuthorized();
    final background = await _client.isHealthDataInBackgroundAuthorized();
    return HealthPermissionState(
      readGranted: read,
      historyGranted: history,
      backgroundGranted: background,
    );
  }

  @override
  Future<HealthPermissionState> requestPermissions({
    bool includeHistory = false,
    bool includeBackground = false,
  }) async {
    await _configure();
    await _client.requestAuthorization(_types);
    if (includeHistory &&
        await _client.isHealthDataHistoryAuthorized() == false) {
      await _client.requestHealthDataHistoryAuthorization();
    }
    if (includeBackground &&
        await _client.isHealthDataInBackgroundAvailable() &&
        !await _client.isHealthDataInBackgroundAuthorized()) {
      await _client.requestHealthDataInBackgroundAuthorization();
    }
    return currentPermissions();
  }

  @override
  Future<void> revokePermissions() async {
    await _configure();
    await _client.revokePermissions();
  }

  @override
  Future<List<HealthRecord>> read(DateTime startUtc, DateTime endUtc) async {
    await _configure();
    final points = await _client.getHealthDataFromTypes(
      types: _types,
      startTime: startUtc.toUtc(),
      endTime: endUtc.toUtc(),
    );
    return [
      for (final point in points)
        if (_metricFor(point.type) case final metric?)
          if (_valueFor(point) case final value?)
            HealthRecord(
              id: point.uuid,
              metric: metric,
              sourceId:
                  point.sourceId.isEmpty ? point.sourceName : point.sourceId,
              sourceName: point.sourceName,
              startUtc: point.dateFrom.toUtc(),
              endUtc: point.dateTo.toUtc(),
              value: value,
              unit: point.unitString,
              localDay: _localDay(point.dateFrom),
              payloadJson: jsonEncode(point.toJson()),
            ),
    ];
  }

  HealthMetric? _metricFor(HealthDataType type) => switch (type) {
        HealthDataType.STEPS => HealthMetric.steps,
        HealthDataType.ACTIVE_ENERGY_BURNED => HealthMetric.activeCalories,
        HealthDataType.BASAL_ENERGY_BURNED => HealthMetric.basalCalories,
        HealthDataType.DISTANCE_WALKING_RUNNING => HealthMetric.distance,
        HealthDataType.HEART_RATE => HealthMetric.heartRate,
        HealthDataType.RESTING_HEART_RATE => HealthMetric.restingHeartRate,
        HealthDataType.SLEEP_SESSION => HealthMetric.sleep,
        HealthDataType.WORKOUT => HealthMetric.workout,
        _ => null,
      };

  double? _valueFor(HealthDataPoint point) {
    final value = point.value;
    if (value is NumericHealthValue) return value.numericValue.toDouble();
    final summary = point.workoutSummary;
    if (summary != null) return summary.totalEnergyBurned.toDouble();
    return null;
  }

  String _localDay(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
