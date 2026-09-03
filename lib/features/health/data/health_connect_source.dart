import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:health/health.dart';

import '../../../core/logging/app_logger.dart';
import '../../cycle/domain/cycle_models.dart';
import '../domain/health_models.dart';
import 'health_data_source.dart';

class HealthConnectSource implements HealthDataSource {
  HealthConnectSource({
    Health? client,
    AppLogger logger = const AppLogger(),
  })  : _client = client ?? Health(),
        _logger = logger;

  final Health _client;
  final AppLogger _logger;
  bool _configured = false;

  List<HealthDataType> get _generalTypes {
    final types = <HealthDataType>[
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.BASAL_ENERGY_BURNED,
      if (!kIsWeb && Platform.isAndroid)
        HealthDataType.DISTANCE_DELTA
      else
        HealthDataType.DISTANCE_WALKING_RUNNING,
      HealthDataType.HEART_RATE,
      HealthDataType.RESTING_HEART_RATE,
      HealthDataType.SLEEP_SESSION,
      HealthDataType.WORKOUT,
    ];
    return types.where((t) {
      try {
        return _client.isDataTypeAvailable(t);
      } catch (_) {
        return true;
      }
    }).toList();
  }

  static const _menstruationTypes = <HealthDataType>[
    HealthDataType.MENSTRUATION_FLOW,
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
    final read = await _client.hasPermissions(_generalTypes) ?? false;
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
    await _client.requestAuthorization(_generalTypes);
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
  Future<bool> hasMenstruationPermission() async {
    await _configure();
    return (await _client.hasPermissions(_menstruationTypes)) ?? false;
  }

  @override
  Future<bool> requestMenstruationPermission() async {
    await _configure();
    final requested = await _client.requestAuthorization(_menstruationTypes);
    return requested &&
        ((await _client.hasPermissions(_menstruationTypes)) ?? false);
  }

  @override
  Future<void> revokePermissions() async {
    await _configure();
    await _client.revokePermissions();
  }

  @override
  Future<List<HealthRecord>> read(DateTime startUtc, DateTime endUtc) async {
    await _configure();
    final types = _generalTypes;
    final points = <HealthDataPoint>[];

    try {
      final batchPoints = await _client.getHealthDataFromTypes(
        types: types,
        startTime: startUtc.toUtc(),
        endTime: endUtc.toUtc(),
      );
      points.addAll(batchPoints);
    } catch (e) {
      _logger.warning(
          'HealthConnect read batch failed: $e, falling back to individual types');
      for (final type in types) {
        try {
          final singlePoints = await _client.getHealthDataFromTypes(
            types: [type],
            startTime: startUtc.toUtc(),
            endTime: endUtc.toUtc(),
          );
          points.addAll(singlePoints);
        } catch (singleError) {
          _logger.warning('Skipping health type $type: $singleError');
        }
      }
    }

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

  @override
  Future<List<HealthMenstruationRecord>> readMenstruation(
    DateTime startUtc,
    DateTime endUtc,
  ) async {
    await _configure();
    final hasPerm = await hasMenstruationPermission();
    if (!hasPerm) {
      throw const HealthPermissionException(
        'Health Connect Menstruationsberechtigung wurde nicht erteilt.',
      );
    }

    try {
      final points = await _client.getHealthDataFromTypes(
        types: _menstruationTypes,
        startTime: startUtc.toUtc(),
        endTime: endUtc.toUtc(),
      );

      final records = <HealthMenstruationRecord>[];
      for (final point in points) {
        final val = point.value;
        BleedingLevel? flow;
        if (val is MenstruationFlowHealthValue) {
          flow = switch (val.flow) {
            MenstrualFlow.light => BleedingLevel.light,
            MenstrualFlow.medium => BleedingLevel.medium,
            MenstrualFlow.heavy => BleedingLevel.heavy,
            MenstrualFlow.spotting => BleedingLevel.spotting,
            MenstrualFlow.none => BleedingLevel.none,
            _ => BleedingLevel.medium,
          };
        }

        records.add(
          HealthMenstruationRecord(
            id: point.uuid,
            startDay: point.dateFrom,
            endDay: point.dateTo == point.dateFrom ? null : point.dateTo,
            flow: flow,
            sourceName: point.sourceName.isNotEmpty
                ? point.sourceName
                : (point.sourceId.isNotEmpty
                    ? point.sourceId
                    : 'Health Connect'),
            isImported: false,
          ),
        );
      }
      return records;
    } catch (e) {
      _logger.error('readMenstruation', e);
      rethrow;
    }
  }

  HealthMetric? _metricFor(HealthDataType type) => switch (type) {
        HealthDataType.STEPS => HealthMetric.steps,
        HealthDataType.ACTIVE_ENERGY_BURNED => HealthMetric.activeCalories,
        HealthDataType.BASAL_ENERGY_BURNED => HealthMetric.basalCalories,
        HealthDataType.DISTANCE_WALKING_RUNNING => HealthMetric.distance,
        HealthDataType.DISTANCE_DELTA => HealthMetric.distance,
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

  @override
  Future<int?> getTotalStepsInInterval(
    DateTime startTime,
    DateTime endTime,
  ) async {
    await _configure();
    try {
      return await _client.getTotalStepsInInterval(startTime, endTime);
    } catch (e) {
      _logger.error('getTotalStepsInInterval', e);
      return null;
    }
  }
}
