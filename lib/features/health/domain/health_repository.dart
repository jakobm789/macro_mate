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

  Future<void> recordSteps({
    required int steps,
    required DateTime date,
    String sourceId = 'phone_step_sensor',
    String sourceName = 'Interner Handy-Sensor',
  });

  Future<int> getPriorStepsToday(
    DateTime date, {
    String? excludeSourceId,
  });

  Future<int?> getTotalStepsInInterval(
    DateTime startTime,
    DateTime endTime,
  );
}

