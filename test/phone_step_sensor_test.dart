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
  int mockPriorSteps = 0;

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
  Future<int> getPriorStepsToday(
    DateTime date, {
    String? excludeSourceId,
  }) async =>
      mockPriorSteps;

  @override
  Future<int?> getTotalStepsInInterval(
    DateTime startTime,
    DateTime endTime,
  ) async =>
      mockPriorSteps > 0 ? mockPriorSteps : null;

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
    test('calculates today steps starting from zero when no prior steps exist',
        () async {
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

    test(
        'takes over prior steps from HealthRepository and adds new steps on top',
        () async {
      final now = DateTime(2026, 9, 3, 14, 30);
      mockRepo.mockPriorSteps = 4200; // User had 4,200 steps before connecting

      // First reading when connecting (e.g. phone has 20,000 raw steps since boot)
      final steps1 = await service.processRawStepCount(20000, now: now);
      expect(steps1, equals(4200));
      expect(mockRepo.recordedSteps, equals(4200));

      // User walks 150 steps
      final steps2 = await service.processRawStepCount(20150, now: now);
      expect(steps2, equals(4350));
      expect(mockRepo.recordedSteps, equals(4350));

      // User walks another 650 steps
      final steps3 = await service.processRawStepCount(20800, now: now);
      expect(steps3, equals(5000));
      expect(mockRepo.recordedSteps, equals(5000));
    });

    test('takes over prior steps from Health Connect via callback', () async {
      final now = DateTime(2026, 9, 3, 11, 0);
      final serviceWithCallback = PhoneStepSensorService(
        healthRepository: mockRepo,
        getStepsInInterval: (start, end) async => 3500,
      );

      final steps1 =
          await serviceWithCallback.processRawStepCount(15000, now: now);
      expect(steps1, equals(3500));

      // User walks 300 steps
      final steps2 =
          await serviceWithCallback.processRawStepCount(15300, now: now);
      expect(steps2, equals(3800));

      serviceWithCallback.dispose();
    });

    test('recovers correctly when phone is rebooted mid-day with prior steps',
        () async {
      final now = DateTime(2026, 9, 3, 14, 0);
      mockRepo.mockPriorSteps = 1000;

      // Day starts at raw 50,000 with 1,000 prior steps
      final initial = await service.processRawStepCount(50000, now: now);
      expect(initial, equals(1000));

      // User walks 1,200 steps -> raw 51,200 -> total 2,200
      final stepsBeforeReboot =
          await service.processRawStepCount(51200, now: now);
      expect(stepsBeforeReboot, equals(2200));

      // Phone is rebooted! Hardware counter resets to 0, user takes 100 steps -> raw 100
      final stepsAfterReboot = await service.processRawStepCount(100, now: now);
      // Expected: 1000 (prior) + 1200 (pre-reboot) + 100 (post-reboot) = 2300!
      expect(stepsAfterReboot, equals(2300));
      expect(mockRepo.recordedSteps, equals(2300));

      // User walks another 200 steps -> raw 300
      final stepsLater = await service.processRawStepCount(300, now: now);
      expect(stepsLater, equals(2500));
    });

    test(
        'elevates prior steps if external source syncs higher step count mid-day',
        () async {
      final now = DateTime(2026, 9, 3, 15, 0);

      // User starts with 500 steps, walks 200 steps -> 700 steps
      mockRepo.mockPriorSteps = 500;
      await service.processRawStepCount(10000, now: now);
      final steps1 = await service.processRawStepCount(10200, now: now);
      expect(steps1, equals(700));

      // External sync (e.g. from fitness watch) arrives in repo with 3,000 steps
      mockRepo.mockPriorSteps = 3000;

      // Next sensor event arrives: user walked 50 more steps (raw 10250)
      final steps2 = await service.processRawStepCount(10250, now: now);
      // Expected: stepped up to 3,000 + 50 = 3,050 steps!
      expect(steps2, equals(3050));
      expect(mockRepo.recordedSteps, equals(3050));
    });

    test(
        'reconciles a freshly synced full-day total without losing new sensor steps',
        () async {
      final now = DateTime(2026, 9, 3, 15, 0);

      await service.processRawStepCount(10000, now: now);
      expect(
        await service.processRawStepCount(10200, now: now),
        equals(200),
      );

      // Health Connect catches up after MacroMate had started listening.
      final reconciled = await service.processRawStepCount(
        10250,
        now: now,
        initialPriorSteps: 3000,
      );

      expect(reconciled, equals(3050));
      expect(service.currentTodaySteps, equals(3050));
      expect(mockRepo.recordedSteps, equals(3050));
    });

    test('refreshPriorSteps updates current steps when called', () async {
      final now = DateTime(2026, 9, 3, 16, 0);

      // Starts with 0
      await service.processRawStepCount(10000, now: now);
      expect(service.currentTodaySteps, equals(0));

      // Health Connect is connected and now has 5,500 steps
      mockRepo.mockPriorSteps = 5500;
      await service.refreshPriorSteps();

      expect(service.currentTodaySteps, equals(5500));
      expect(mockRepo.recordedSteps, equals(5500));
    });

    test('resets baseline when date rolls over to midnight next day', () async {
      final day1 = DateTime(2026, 9, 3, 23, 50);
      final day2 = DateTime(2026, 9, 4, 8, 30);

      // End of day 1: raw is 60,000, walked 5,000 steps today
      await service.processRawStepCount(55000, now: day1);
      final day1Final = await service.processRawStepCount(60000, now: day1);
      expect(day1Final, equals(5000));

      // Next morning (day 2): raw is 60,200 (200 steps overnight/morning)
      mockRepo.mockPriorSteps = 0;
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
