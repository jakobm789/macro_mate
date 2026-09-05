import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/activity/domain/location_tracker_service.dart';
import 'package:macro_mate/features/activity/presentation/running_tracker_controller.dart';

class _TestLocationTrackerService extends LocationTrackerService {
  @override
  Future<bool> checkAndRequestPermission() async => true;

  @override
  Stream<LiveGpsPoint> startTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 2,
    SportType sport = SportType.running,
  }) {
    return const Stream.empty();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationTrackerService GPS Filtering & Outlier Tests', () {
    test('Rejects invalid accuracy (<= 0 or > 35m on subsequent points)',
        () async {
      final controller = StreamController<Position>();
      final service =
          LocationTrackerService(positionStreamOverride: controller.stream);

      final received = <LiveGpsPoint>[];
      final sub = service.startTracking().listen(received.add);

      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);

      // Point 1: Valid initial fix with 40m accuracy (allowed up to 45m on start)
      controller.add(Position(
        latitude: 52.5200,
        longitude: 13.4050,
        timestamp: t0,
        accuracy: 40.0,
        altitude: 35.0,
        heading: 0.0,
        speed: 2.5,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ));

      // Point 2: Invalid accuracy (<= 0)
      controller.add(Position(
        latitude: 52.5205,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(seconds: 2)),
        accuracy: 0.0,
        altitude: 35.0,
        heading: 0.0,
        speed: 2.5,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ));

      // Point 3: Poor accuracy (> 35m after initial)
      controller.add(Position(
        latitude: 52.5210,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(seconds: 4)),
        accuracy: 38.0,
        altitude: 35.0,
        heading: 0.0,
        speed: 2.5,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ));

      // Point 4: Valid clean point
      controller.add(Position(
        latitude: 52.5201,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(seconds: 6)),
        accuracy: 12.0,
        altitude: 35.0,
        heading: 0.0,
        speed: 2.5,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      await controller.close();

      // Only point 1 (initial lock <= 45m) and point 4 (accuracy 12m) should be emitted
      expect(received.length, 2);
      expect(received.first.accuracy, 40.0);
      expect(received.last.accuracy, 12.0);
    });

    test('Rejects impossible teleports/spikes (> 15 m/s for running)',
        () async {
      final controller = StreamController<Position>();
      final service =
          LocationTrackerService(positionStreamOverride: controller.stream);

      final received = <LiveGpsPoint>[];
      final sub =
          service.startTracking(sport: SportType.running).listen(received.add);

      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);

      // Point 1: Origin
      controller.add(Position(
        latitude: 52.5200,
        longitude: 13.4050,
        timestamp: t0,
        accuracy: 10.0,
        altitude: 35.0,
        heading: 0.0,
        speed: 3.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ));

      // Point 2: 1 second later, 100 meters away (~100 m/s = 360 km/h spike!)
      controller.add(Position(
        latitude: 52.5209,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(seconds: 1)),
        accuracy: 10.0,
        altitude: 35.0,
        heading: 0.0,
        speed: 3.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ));

      // Point 3: Normal progression 3 seconds after origin (~8 meters away)
      controller.add(Position(
        latitude: 52.52007,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(seconds: 3)),
        accuracy: 10.0,
        altitude: 35.0,
        heading: 0.0,
        speed: 2.7,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      await controller.close();

      // Point 2 must be rejected by outlier filter
      expect(received.length, 2);
      expect(received[0].latitude, 52.5200);
      expect(received[1].latitude, 52.52007);
    });

    test('Filters stationary micro-jitter (< 1.2m with near-zero speed)',
        () async {
      final controller = StreamController<Position>();
      final service =
          LocationTrackerService(positionStreamOverride: controller.stream);

      final received = <LiveGpsPoint>[];
      final sub = service.startTracking().listen(received.add);

      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);

      // Point 1: Stationary start
      controller.add(Position(
        latitude: 52.520000,
        longitude: 13.405000,
        timestamp: t0,
        accuracy: 8.0,
        altitude: 35.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ));

      // Point 2: GPS jitter 0.5 meters away, speed 0.0
      controller.add(Position(
        latitude: 52.520004,
        longitude: 13.405000,
        timestamp: t0.add(const Duration(seconds: 2)),
        accuracy: 8.0,
        altitude: 35.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ));

      // Point 3: Actual movement 8 meters away, speed 2.5 m/s
      controller.add(Position(
        latitude: 52.520070,
        longitude: 13.405000,
        timestamp: t0.add(const Duration(seconds: 5)),
        accuracy: 8.0,
        altitude: 35.0,
        heading: 0.0,
        speed: 2.5,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      await controller.close();

      // Jitter point 2 should be skipped
      expect(received.length, 2);
    });
  });

  group('RunningTrackerController Speed, Pace, and State Logic', () {
    late AppDatabase db;
    late RunningTrackerController controller;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      controller = RunningTrackerController(
        locationService: _TestLocationTrackerService(),
      );
    });

    tearDown(() async {
      controller.dispose();
      await db.close();
    });

    test(
        'Computes speed and pace from deltaDist/deltaSec when sensor speed is 0.0',
        () async {
      await controller.startWorkout(SportType.running);

      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);

      // Point 1: t0
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.5200,
        longitude: 13.4050,
        timestamp: t0,
        altitude: 40.0,
        speed: 0.0, // Hardware reports 0
      ));

      expect(controller.distanceMeters, 0.0);

      // Point 2: 2 seconds later, ~5.5 meters moved (~2.75 m/s = ~10 km/h = ~6:00 min/km)
      // 0.00005 deg latitude ~ 5.56m
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.52005,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(seconds: 2)),
        altitude: 40.0,
        speed: 0.0, // Hardware still reports 0
      ));

      expect(controller.distanceMeters, closeTo(5.5, 0.5));
      expect(controller.currentSpeedKmh, greaterThan(8.0));
      expect(controller.currentSpeedKmh, lessThan(12.0));
      expect(controller.currentPaceMinPerKm, isNotNull);
      // ~6 min/km pace
      expect(controller.currentPaceMinPerKm!, closeTo(6.0, 1.0));
    });

    test('Elevation damping ignores vertical noise under 1.5m', () async {
      await controller.startWorkout(SportType.running);
      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);

      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.5200,
        longitude: 13.4050,
        timestamp: t0,
        altitude: 50.0,
        speed: 3.0,
      ));

      // Jitter +0.6m
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.52005,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(seconds: 2)),
        altitude: 50.6,
        speed: 3.0,
      ));
      expect(controller.elevationGainMeters, 0.0);

      // Real climb +3.0m
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.52010,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(seconds: 4)),
        altitude: 53.6,
        speed: 3.0,
      ));
      expect(controller.elevationGainMeters, closeTo(3.0, 0.1));
    });

    test('Auto-pause does not trigger on a single low-speed point', () async {
      await controller.startWorkout(SportType.running);
      controller.toggleAutoPause(true);

      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);

      // Add points with elapsed time > 10s
      for (int i = 0; i <= 12; i++) {
        controller.onNewLocationPoint(LiveGpsPoint(
          latitude: 52.5200 + (i * 0.00003),
          longitude: 13.4050,
          timestamp: t0.add(Duration(seconds: i)),
          altitude: 40.0,
          speed: 3.0,
        ));
      }

      expect(controller.isRunning, isTrue);

      // Single momentary stop point
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.52036,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(seconds: 13)),
        altitude: 40.0,
        speed: 0.0,
      ));

      // Still running because it requires consecutive low fixes
      expect(controller.isRunning, isTrue);
    });

    test('Pause & Resume does not add distance jumped during pause', () async {
      await controller.startWorkout(SportType.running);
      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);

      // Point 1
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.5200,
        longitude: 13.4050,
        timestamp: t0,
        altitude: 40.0,
        speed: 3.0,
      ));

      // Point 2 (100m away)
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.5209,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(seconds: 30)),
        altitude: 40.0,
        speed: 3.0,
      ));

      final distBeforePause = controller.distanceMeters;
      expect(distBeforePause, greaterThan(90.0));

      // Pause workout
      controller.pauseWorkout();
      expect(controller.isPaused, isTrue);

      // Runner walks 500m while paused, then resumes
      controller.resumeWorkout();
      expect(controller.isRunning, isTrue);

      // First point after resume is 500m away
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.5254,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(minutes: 10)),
        altitude: 40.0,
        speed: 3.0,
      ));

      // The 500m gap should NOT be added to workout distance
      expect(controller.distanceMeters, closeTo(distBeforePause, 0.01));

      // Next running point continues normally
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.5256,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(minutes: 10, seconds: 5)),
        altitude: 40.0,
        speed: 3.0,
      ));

      expect(controller.distanceMeters, greaterThan(distBeforePause + 15.0));
    });
  });
}
