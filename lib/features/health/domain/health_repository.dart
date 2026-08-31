import 'health_models.dart';

abstract interface class HealthRepository {
  Future<HealthAvailability> availability();

  Future<HealthPermissionState> permissions();

  Future<HealthPermissionState> requestPermissions({
    bool includeHistory = false,
    bool includeBackground = false,
  });

  Future<void> revokePermissions();

  Future<List<DailyHealthSummary>> sync({
    required DateTime startUtc,
    required DateTime endUtc,
  });

  Future<List<DailyHealthSummary>> summaries({
    required DateTime startDay,
    required DateTime endDay,
  });
}
