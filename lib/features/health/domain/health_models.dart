enum HealthMetric {
  steps,
  activeCalories,
  basalCalories,
  distance,
  heartRate,
  restingHeartRate,
  sleep,
  workout,
}

enum HealthAvailability {
  available,
  installRequired,
  permissionRequired,
  unavailable,
}

class HealthPermissionState {
  const HealthPermissionState({
    required this.readGranted,
    required this.historyGranted,
    required this.backgroundGranted,
  });

  final bool readGranted;
  final bool historyGranted;
  final bool backgroundGranted;

  bool get needsOnboarding => !readGranted;
}

class HealthRecord {
  const HealthRecord({
    required this.id,
    required this.metric,
    required this.sourceId,
    required this.sourceName,
    required this.startUtc,
    required this.endUtc,
    required this.value,
    required this.unit,
    required this.localDay,
    this.payloadJson,
  });

  final String id;
  final HealthMetric metric;
  final String sourceId;
  final String sourceName;
  final DateTime startUtc;
  final DateTime endUtc;
  final double value;
  final String unit;
  final String localDay;
  final String? payloadJson;
}

class DailyHealthSummary {
  const DailyHealthSummary({
    required this.day,
    required this.steps,
    required this.activeCalories,
    required this.distanceMeters,
    this.totalCalories,
    this.averageHeartRate,
    this.restingHeartRate,
    this.sleepMinutes,
    this.sourceIds = const [],
  });

  final DateTime day;
  final int steps;
  final double activeCalories;
  final double distanceMeters;
  final double? totalCalories;
  final double? averageHeartRate;
  final double? restingHeartRate;
  final double? sleepMinutes;
  final List<String> sourceIds;
}
