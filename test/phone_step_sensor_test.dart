import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/features/cycle/domain/cycle_models.dart';
import 'package:macro_mate/features/health/data/phone_step_sensor_service.dart';
import 'package:macro_mate/features/health/domain/health_models.dart';
import 'package:macro_mate/features/health/domain/health_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockHealthRepository implements HealthRepository {
  int recordedSteps = 0;
  DateTime? recordedDate;
  String? recordedSourceId;

  @override
  Future<void> recordSteps({
    required int steps,
    required DateTime date,
    String sourceId = 'phone_step_sensor',
    String sourceName = 'Interner Handy-Sensor',
  }) async {
    recordedSteps = steps;
    recordedDate = date;
    recordedSourceId = sourceId;
  }

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
  Future<List<DailyHealthSummary>> sync(
          {required DateTime startUtc, required DateTime endUtc}) async =>
      [];
  @override
  Future<List<DailyHealthSummary>> summaries(
          {required DateTime startDay, required DateTime endDay}) async =>
      [];
  @override
  Future<List<HealthSyncState>> syncStates() async => [];
  @override
  Future<List<HealthSourceSummary>> sources() async => [];
  @override
  Future<List<WorkoutDetail>> workouts({int limit = 50}) async => [];
  @override
  Future<WorkoutDetail?> workoutById(String id) async => null;
  @override
  Future<List<SleepSessionDetail>> sleepSessions({int limit = 30}) async => [];
  @override
  Future<bool> hasMenstruationPermission() async => true;
  @override
  Future<bool> requestMenstruationPermission() async => true;
  @override
  Future<List<HealthMenstruationRecord>> readMenstruation(
          {required DateTime startUtc, required DateTime endUtc}) async =>
      [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockHealthRepository mockRepo;
  late PhoneStepSensorService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepo = _MockHealthRepository();
    service = PhoneStepSensorService(healthRepository: mockRepo);
  });

  tearDown(() {
    service.dispose();
  });

  group('PhoneStepSensorService Tests', () {
    test('calculates today steps starting from first reading', () async {
      final now = DateTime(2026, 9, 3, 10, 0);

      // First reading of the day (e.g. phone booted days ago with 10,000 steps already)
      final steps1 = await service.processRawStepCount(10000, now: now);
      expect(steps1, equals(0));
      expect(mockRepo.recordedSteps, equals(0));

      // User walks 250 steps
      final steps2 = await service.processRawStepCount(10250, now: now);
      expect(steps2, equals(250));
      expect(mockRepo.recordedSteps, equals(250));

      // User walks another 500 steps (total 750)
      final steps3 = await service.processRawStepCount(10750, now: now);
      expect(steps3, equals(750));
      expect(mockRepo.recordedSteps, equals(750));
    });

    test('recovers correctly when phone is rebooted mid-day', () async {
      final now = DateTime(2026, 9, 3, 14, 0);

      // Day starts at raw 50,000
      await service.processRawStepCount(50000, now: now);

      // User walks 1,200 steps -> raw 51,200
      final stepsBeforeReboot =
          await service.processRawStepCount(51200, now: now);
      expect(stepsBeforeReboot, equals(1200));

      // Phone is rebooted! Hardware counter resets to 0, user takes 100 steps -> raw 100
      final stepsAfterReboot = await service.processRawStepCount(100, now: now);
      // Expected: 1200 + 100 = 1300 steps!
      expect(stepsAfterReboot, equals(1300));
      expect(mockRepo.recordedSteps, equals(1300));

      // User walks another 200 steps -> raw 300
      final stepsLater = await service.processRawStepCount(300, now: now);
      expect(stepsLater, equals(1500));
    });

    test('resets baseline when date rolls over to midnight next day', () async {
      final day1 = DateTime(2026, 9, 3, 23, 50);
      final day2 = DateTime(2026, 9, 4, 8, 30);

      // End of day 1: raw is 60,000, walked 5,000 steps today
      await service.processRawStepCount(55000, now: day1);
      final day1Final = await service.processRawStepCount(60000, now: day1);
      expect(day1Final, equals(5000));

      // Next morning (day 2): raw is 60,200 (200 steps overnight/morning)
      final day2Morning = await service.processRawStepCount(60200, now: day2);
      expect(day2Morning, equals(0));

      // Walks 800 steps on day 2 -> raw is 61,000
      final day2Walk = await service.processRawStepCount(61000, now: day2);
      expect(day2Walk, equals(800));
      expect(mockRepo.recordedSteps, equals(800));
    });

    test('enabling and disabling persists in SharedPreferences', () async {
      expect(await service.isEnabled(), isFalse);

      await service.setEnabled(true);
      expect(await service.isEnabled(), isTrue);

      await service.setEnabled(false);
      expect(await service.isEnabled(), isFalse);
    });
  });
}
