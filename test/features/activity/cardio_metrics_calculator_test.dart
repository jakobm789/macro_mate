import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/features/activity/domain/cardio_metrics_calculator.dart';
import 'package:macro_mate/features/health/domain/health_models.dart';

void main() {
  group('CardioMetricsCalculator Tests', () {
    const calc = CardioMetricsCalculator();

    test('Heart Rate Zones: calculates 5 distinct zones from Max HR', () {
      final zones = calc.calculateHeartRateZones(190);
      expect(zones.length, 5);

      expect(zones[0].zone, 1);
      expect(zones[0].minBpm, 95); // 50% of 190
      expect(zones[0].maxBpm, 114); // 60% of 190

      expect(zones[4].zone, 5);
      expect(zones[4].minBpm, 171); // 90% of 190
      expect(zones[4].maxBpm, 190);
    });

    test('getZoneForBpm maps BPM to correct zone', () {
      expect(calc.getZoneForBpm(100, 190), 1);
      expect(calc.getZoneForBpm(120, 190), 2);
      expect(calc.getZoneForBpm(140, 190), 3);
      expect(calc.getZoneForBpm(160, 190), 4);
      expect(calc.getZoneForBpm(180, 190), 5);
    });

    test('Sport metric: cycling displays speed in km/h, running displays pace in min/km', () {
      // 10 km in 30 minutes (1800s) = 20 km/h or 3:00 min/km
      final bikingMetric = CardioMetricsCalculator.formatSportMetric('Biking', 10000, 1800);
      expect(bikingMetric, '20.0 km/h');

      final runningMetric = CardioMetricsCalculator.formatSportMetric('Running', 10000, 1800);
      expect(runningMetric, '3:00 min/km');
    });

    test('Splits fallback calculates uniform splits accurately', () {
      final workout = WorkoutDetail(
        id: 'w1',
        type: 'Running',
        startUtc: DateTime.utc(2026, 9, 3, 10, 0),
        endUtc: DateTime.utc(2026, 9, 3, 10, 25),
        durationSeconds: 1500, // 25 min for 5 km = 5:00 min/km
        distanceMeters: 5000,
        sourceId: 'health_connect',
        routeStatus: 'unavailable',
      );

      final splits = calc.calculateSplits(workout);
      expect(splits.length, 5);
      expect(splits[0].km, 1);
      expect(splits[0].formattedPace, '5:00 min/km');
      expect(splits[4].km, 5);
      expect(splits[4].formattedPace, '5:00 min/km');
    });

    test('Splits with GPS route points detects real km boundaries', () {
      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);
      // Construct points ~1 km apart
      // 1 deg lat is approx 111 km, so 0.009 deg is approx 1000m
      final points = [
        WorkoutRoutePointModel(latitude: 52.5200, longitude: 13.4050, timestampUtc: t0),
        WorkoutRoutePointModel(latitude: 52.5290, longitude: 13.4050, timestampUtc: t0.add(const Duration(minutes: 5))), // ~1km in 5 min
        WorkoutRoutePointModel(latitude: 52.5380, longitude: 13.4050, timestampUtc: t0.add(const Duration(minutes: 11))), // ~2km in 6 min
      ];

      final workout = WorkoutDetail(
        id: 'w2',
        type: 'Running',
        startUtc: t0,
        endUtc: t0.add(const Duration(minutes: 11)),
        durationSeconds: 660,
        distanceMeters: 2000,
        sourceId: 'health_connect',
        routeStatus: 'available',
        routePoints: points,
      );

      final splits = calc.calculateSplits(workout);
      expect(splits.isNotEmpty, true);
      expect(splits[0].km, 1);
      expect(splits[0].durationSeconds, 300); // 5 min
      expect(splits[0].formattedPace, '5:00 min/km');
    });

    test('generateGpxString creates valid XML GPX 1.1 document', () {
      final t0 = DateTime.utc(2026, 9, 3, 10, 0, 0);
      final points = [
        WorkoutRoutePointModel(latitude: 52.5200, longitude: 13.4050, timestampUtc: t0),
        WorkoutRoutePointModel(latitude: 52.5290, longitude: 13.4050, timestampUtc: t0.add(const Duration(minutes: 5))),
      ];

      final gpx = CardioMetricsCalculator.generateGpxString(
        workoutName: 'Laufrunde Berlin',
        points: points,
      );

      expect(gpx, contains('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(gpx, contains('<gpx version="1.1"'));
      expect(gpx, contains('<name>Laufrunde Berlin</name>'));
      expect(gpx, contains('<trkpt lat="52.52" lon="13.405">'));
    });
  });
}
