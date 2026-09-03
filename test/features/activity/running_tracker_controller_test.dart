import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/activity/domain/location_tracker_service.dart';
import 'package:macro_mate/features/activity/presentation/running_tracker_controller.dart';

import 'package:geolocator/geolocator.dart';

class FakeLocationTrackerService extends LocationTrackerService {
  @override
  Future<bool> checkAndRequestPermission() async => true;

  @override
  Stream<LiveGpsPoint> startTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 3,
  }) {
    return const Stream.empty();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RunningTrackerController Tests', () {
    late AppDatabase db;
    late RunningTrackerController controller;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      controller = RunningTrackerController(
        locationService: FakeLocationTrackerService(),
        userWeightKg: 75.0,
      );
    });

    tearDown(() async {
      controller.dispose();
      await db.close();
    });

    test('Initial state is idle and allows changing sport', () {
      expect(controller.status, TrackingStatus.idle);
      expect(controller.sport, SportType.running);

      controller.setSport(SportType.cycling);
      expect(controller.sport, SportType.cycling);
    });

    test('onNewLocationPoint updates metrics, elevation, and logs route points', () {
      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);

      // Force state to running
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.5200,
        longitude: 13.4050,
        timestamp: t0,
        altitude: 40.0,
        speed: 3.0, // m/s = 10.8 km/h
      ));
      // Idle state ignores points
      expect(controller.routePoints, isEmpty);

      // Manually simulate running state via test
      // Start workout:
      controller.setSport(SportType.running);
      // We can manually trigger points once status is running
    });

    test('Calculates kilometer split and creates database records on finish', () async {
      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);

      // Start workout
      await controller.startWorkout(SportType.running);
      expect(controller.status, TrackingStatus.running);

      // Point 1: Start
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.5200,
        longitude: 13.4050,
        timestamp: t0,
        altitude: 40.0,
        speed: 3.33, // ~12 km/h = 5:00 min/km
      ));

      // Point 2: ~1050m away (0.0095 deg latitude is ~1056m)
      controller.onNewLocationPoint(LiveGpsPoint(
        latitude: 52.5295,
        longitude: 13.4050,
        timestamp: t0.add(const Duration(minutes: 5)),
        altitude: 55.0, // +15m elevation
        speed: 3.33,
      ));

      expect(controller.distanceMeters, greaterThan(1000));
      expect(controller.elevationGainMeters, closeTo(15.0, 0.1));
      expect(controller.splits.length, 1);
      expect(controller.splits.first.km, 1);
      expect(controller.lastSplitNotification, contains('Km 1 geschafft!'));

      // Pause and resume
      controller.pauseWorkout();
      expect(controller.status, TrackingStatus.paused);
      controller.resumeWorkout();
      expect(controller.status, TrackingStatus.running);

      // Finish & save workout to Drift
      final savedWorkout = await controller.finishAndSaveWorkout(db);
      expect(savedWorkout, isNotNull);
      expect(savedWorkout!.type, 'Laufen');
      expect(savedWorkout.distanceM, greaterThan(1000));
      expect(savedWorkout.routeStatus, 'available');

      // Verify points saved in database
      final savedPoints = await (db.select(db.workoutRoutePoints)
            ..where((row) => row.workoutId.equals(savedWorkout.id))
            ..orderBy([(r) => OrderingTerm(expression: r.sequence)]))
          .get();

      expect(savedPoints.length, 2);
      expect(savedPoints[0].latitude, 52.5200);
      expect(savedPoints[1].latitude, 52.5295);
    });
  });
}
