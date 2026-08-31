import '../../cycle/domain/cycle_models.dart';
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

  Future<List<HealthSyncState>> syncStates();

  Future<List<HealthSourceSummary>> sources();

  Future<List<WorkoutDetail>> workouts({int limit = 50});

  Future<WorkoutDetail?> workoutById(String id);

  Future<List<SleepSessionDetail>> sleepSessions({int limit = 30});

  Future<bool> hasMenstruationPermission();

  Future<bool> requestMenstruationPermission();

  Future<List<HealthMenstruationRecord>> readMenstruation({
    required DateTime startUtc,
    required DateTime endUtc,
  });
}
