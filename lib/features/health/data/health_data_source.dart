import '../../cycle/domain/cycle_models.dart';
import '../domain/health_models.dart';

abstract interface class HealthDataSource {
  Future<HealthAvailability> getAvailability();

  Future<HealthPermissionState> requestPermissions({
    bool includeHistory = false,
    bool includeBackground = false,
  });

  Future<HealthPermissionState> currentPermissions();

  Future<void> revokePermissions();

  Future<List<HealthRecord>> read(DateTime startUtc, DateTime endUtc);

  Future<bool> hasMenstruationPermission();

  Future<bool> requestMenstruationPermission();

  Future<List<HealthMenstruationRecord>> readMenstruation(
    DateTime startUtc,
    DateTime endUtc,
  );

  Future<int?> getTotalStepsInInterval(
    DateTime startTime,
    DateTime endTime,
  );
}
