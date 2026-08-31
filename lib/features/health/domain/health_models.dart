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

enum HealthSyncStatus { never, running, success, failed }

class HealthSyncState {
  const HealthSyncState({
    required this.key,
    required this.metric,
    required this.status,
    this.cursorUtc,
    this.lastSuccessUtc,
    this.lastError,
  });

  final String key;
  final HealthMetric metric;
  final HealthSyncStatus status;
  final DateTime? cursorUtc;
  final DateTime? lastSuccessUtc;
  final String? lastError;
}

class HealthSourceSummary {
  const HealthSourceSummary({
    required this.id,
    required this.name,
    required this.platform,
    required this.priority,
    required this.recordCount,
  });

  final String id;
  final String name;
  final String platform;
  final int priority;
  final int recordCount;
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

class WorkoutRoutePointModel {
  const WorkoutRoutePointModel({
    required this.latitude,
    required this.longitude,
    required this.timestampUtc,
  });

  final double latitude;
  final double longitude;
  final DateTime timestampUtc;
}

class WorkoutDetail {
  const WorkoutDetail({
    required this.id,
    required this.type,
    required this.startUtc,
    required this.endUtc,
    required this.durationSeconds,
    this.distanceMeters,
    this.energyKcal,
    required this.sourceId,
    required this.routeStatus,
    this.routePoints = const [],
  });

  final String id;
  final String type;
  final DateTime startUtc;
  final DateTime endUtc;
  final double durationSeconds;
  final double? distanceMeters;
  final double? energyKcal;
  final String sourceId;
  final String routeStatus;
  final List<WorkoutRoutePointModel> routePoints;

  /// Pace in min/km if distance > 0
  double? get paceMinPerKm {
    if (distanceMeters == null || distanceMeters! <= 0 || durationSeconds <= 0) {
      return null;
    }
    final km = distanceMeters! / 1000.0;
    return (durationSeconds / 60.0) / km;
  }
}

class SleepSessionDetail {
  const SleepSessionDetail({
    required this.id,
    required this.startUtc,
    required this.endUtc,
    required this.durationMinutes,
    required this.sourceId,
    this.stagesJson,
  });

  final String id;
  final DateTime startUtc;
  final DateTime endUtc;
  final int durationMinutes;
  final String sourceId;
  final String? stagesJson;
}

