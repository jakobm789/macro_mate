import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/features/activity/presentation/activity_controller.dart';
import 'package:macro_mate/features/cycle/domain/cycle_models.dart';
import 'package:macro_mate/features/health/domain/health_models.dart';
import 'package:macro_mate/features/health/domain/health_repository.dart';

class _FakeHealthRepository implements HealthRepository {
  @override
  Future<HealthAvailability> availability() async =>
      HealthAvailability.available;

  @override
  Future<HealthPermissionState> permissions() async =>
      const HealthPermissionState(
        readGranted: true,
        historyGranted: true,
        backgroundGranted: true,
      );

  @override
  Future<HealthPermissionState> requestPermissions({
    bool includeHistory = false,
    bool includeBackground = false,
  }) async =>
      const HealthPermissionState(
        readGranted: true,
        historyGranted: true,
        backgroundGranted: true,
      );

  @override
  Future<void> revokePermissions() async {}

  @override
  Future<List<DailyHealthSummary>> sync({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async =>
      [];

  @override
  Future<List<DailyHealthSummary>> summaries({
    required DateTime startDay,
    required DateTime endDay,
  }) async =>
      [
        DailyHealthSummary(
          day: DateTime.now(),
          steps: 8500,
          activeCalories: 340,
          distanceMeters: 6200,
          averageHeartRate: 72,
          restingHeartRate: 58,
          sleepMinutes: 450,
        ),
      ];

  @override
  Future<List<HealthSyncState>> syncStates() async => [];

  @override
  Future<List<HealthSourceSummary>> sources() async => [];

  @override
  Future<List<WorkoutDetail>> workouts({int limit = 50}) async => [
        WorkoutDetail(
          id: 'w1',
          type: 'Laufen',
          startUtc: DateTime.utc(2026, 8, 31, 7, 0),
          endUtc: DateTime.utc(2026, 8, 31, 7, 30),
          durationSeconds: 1800,
          distanceMeters: 5000,
          energyKcal: 400,
          sourceId: 'garmin',
          routeStatus: 'available',
        ),
      ];

  @override
  Future<WorkoutDetail?> workoutById(String id) async => WorkoutDetail(
        id: id,
        type: 'Laufen',
        startUtc: DateTime.utc(2026, 8, 31, 7, 0),
        endUtc: DateTime.utc(2026, 8, 31, 7, 30),
        durationSeconds: 1800,
        distanceMeters: 5000,
        energyKcal: 400,
        sourceId: 'garmin',
        routeStatus: 'available',
        routePoints: [
          WorkoutRoutePointModel(
            latitude: 48.137,
            longitude: 11.576,
            timestampUtc: DateTime.utc(2026, 8, 31, 7, 0),
          ),
          WorkoutRoutePointModel(
            latitude: 48.139,
            longitude: 11.579,
            timestampUtc: DateTime.utc(2026, 8, 31, 7, 30),
          ),
        ],
      );

  @override
  Future<List<SleepSessionDetail>> sleepSessions({int limit = 30}) async => [
        SleepSessionDetail(
          id: 's1',
          startUtc: DateTime.utc(2026, 8, 30, 23, 0),
          endUtc: DateTime.utc(2026, 8, 31, 6, 30),
          durationMinutes: 450,
          sourceId: 'garmin',
        ),
      ];

  @override
  Future<bool> hasMenstruationPermission() async => true;

  @override
  Future<bool> requestMenstruationPermission() async => true;

  @override
  Future<List<HealthMenstruationRecord>> readMenstruation({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async =>
      [];

  @override
  Future<void> recordSteps({
    required int steps,
    required DateTime date,
    String sourceId = 'phone_step_sensor',
    String sourceName = 'Interner Handy-Sensor',
  }) async {}

  @override
  Future<int> getPriorStepsToday(
    DateTime date, {
    String? excludeSourceId,
  }) async =>
      0;

  @override
  Future<int?> getTotalStepsInInterval(
    DateTime startTime,
    DateTime endTime,
  ) async =>
      null;
}

void main() {
  late ActivityController controller;
  late _FakeHealthRepository repo;

  setUp(() {
    repo = _FakeHealthRepository();
    controller = ActivityController(repository: repo);
  });

  test('calculates pace and splits for workouts correctly', () {
    final workout = WorkoutDetail(
      id: 'test',
      type: 'Laufen',
      startUtc: DateTime.utc(2026, 8, 31, 7, 0),
      endUtc: DateTime.utc(2026, 8, 31, 7, 30),
      durationSeconds: 1800, // 30 min
      distanceMeters: 5000, // 5 km
      sourceId: 'test',
      routeStatus: 'none',
    );

    // Pace = 30 min / 5 km = 6.0 min/km
    expect(workout.paceMinPerKm, 6.0);

    final splits = controller.calculateSplits(workout);
    expect(splits.length, 5);
    expect(splits.first['km'], 1);
    expect(splits.first['paceMinPerKm'], 6.0);
    expect(splits.last['km'], 5);
  });

  test('loads activity data, workouts, and sleep', () async {
    await controller.loadActivityData();

    expect(controller.todaySummary, isNotNull);
    expect(controller.todaySummary!.steps, 8500);
    expect(controller.workouts.length, 1);
    expect(controller.sleepSessions.length, 1);

    await controller.selectWorkout('w1');
    expect(controller.selectedWorkout, isNotNull);
    expect(controller.selectedWorkout!.routePoints.length, 2);
  });
}
