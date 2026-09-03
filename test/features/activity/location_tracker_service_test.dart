import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:macro_mate/features/activity/domain/location_tracker_service.dart';

void main() {
  group('LocationTrackerService Tests', () {
    test('calculateDistanceMeters calculates accurate distance using Haversine', () {
      // Distance between Berlin Brandenburger Tor (52.5163, 13.3777) and Alexanderplatz (52.5219, 13.4132) ~ 2.48 km
      final dist = LocationTrackerService.calculateDistanceMeters(
        52.5163,
        13.3777,
        52.5219,
        13.4132,
      );

      expect(dist, greaterThan(2400));
      expect(dist, lessThan(2550));
    });

    test('estimateCalories calculates MET calories based on sport and duration', () {
      // 1 hour (3600s) of Running for 75kg person with 9.8 MET = 9.8 * 75 * 1.0 = 735 kcal
      final runCalories = LocationTrackerService.estimateCalories(
        sport: SportType.running,
        durationSeconds: 3600,
        userWeightKg: 75,
      );
      expect(runCalories, closeTo(735.0, 0.1));

      // 1 hour of Cycling for 80kg person with 7.5 MET = 7.5 * 80 * 1.0 = 600 kcal
      final cycleCalories = LocationTrackerService.estimateCalories(
        sport: SportType.cycling,
        durationSeconds: 3600,
        userWeightKg: 80,
      );
      expect(cycleCalories, closeTo(600.0, 0.1));
    });

    test('startTracking filters out inaccurate GPS positions (> 25m accuracy)', () async {
      final controller = StreamController<Position>();
      final service = LocationTrackerService(positionStreamOverride: controller.stream);

      final stream = service.startTracking();
      final received = <LiveGpsPoint>[];
      final sub = stream.listen(received.add);

      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);

      // 1. Good point
      controller.add(Position(
        latitude: 52.5200,
        longitude: 13.4050,
        timestamp: t0,
        altitude: 40.0,
        accuracy: 8.0, // accurate
        heading: 0,
        speed: 3.5,
        speedAccuracy: 0.5,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      ));

      // 2. Inaccurate point (accuracy = 35m, should be dropped)
      controller.add(Position(
        latitude: 52.5210,
        longitude: 13.4060,
        timestamp: t0.add(const Duration(seconds: 5)),
        altitude: 40.0,
        accuracy: 35.0, // inaccurate
        heading: 0,
        speed: 3.5,
        speedAccuracy: 0.5,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      ));

      // 3. Good point
      controller.add(Position(
        latitude: 52.5220,
        longitude: 13.4070,
        timestamp: t0.add(const Duration(seconds: 10)),
        altitude: 42.0,
        accuracy: 5.0,
        heading: 0,
        speed: 3.6,
        speedAccuracy: 0.5,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      ));

      await pumpEventQueue();

      expect(received.length, 2);
      expect(received[0].latitude, 52.5200);
      expect(received[1].latitude, 52.5220);

      await sub.cancel();
      await controller.close();
    });
  });
}
