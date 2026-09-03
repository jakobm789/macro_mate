import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

enum SportType {
  running('Laufen', 9.8, 'min/km'),
  cycling('Radfahren', 7.5, 'km/h'),
  hiking('Wandern', 6.0, 'min/km'),
  walking('Gehen', 3.5, 'min/km');

  const SportType(this.displayName, this.met, this.primaryMetricUnit);
  final String displayName;
  final double met;
  final String primaryMetricUnit;
}

class LiveGpsPoint {
  const LiveGpsPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude = 0.0,
    this.speed = 0.0,
    this.accuracy = 0.0,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double altitude;
  final double speed; // in m/s
  final double accuracy; // in meters
}

class LocationTrackerService {
  LocationTrackerService({
    Stream<Position>? positionStreamOverride,
  }) : _positionStreamOverride = positionStreamOverride;

  final Stream<Position>? _positionStreamOverride;
  StreamSubscription<Position>? _subscription;

  /// Checks if location services are enabled and permissions are granted
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Obtains the current initial position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Starts listening to position updates and delivers filtered points
  Stream<LiveGpsPoint> startTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 3,
  }) {
    late final StreamController<LiveGpsPoint> controller;

    controller = StreamController<LiveGpsPoint>(
      onListen: () {
        final stream = _positionStreamOverride ??
            Geolocator.getPositionStream(
              locationSettings: LocationSettings(
                accuracy: accuracy,
                distanceFilter: distanceFilterMeters,
              ),
            );

        Position? previousPosition;

        _subscription = stream.listen(
          (pos) {
            // Filter inaccurate positions (> 25m horizontal accuracy)
            if (pos.accuracy > 25.0) return;

            // Filter micro-jitter when stationary
            if (previousPosition != null) {
              final d = calculateDistanceMeters(
                previousPosition!.latitude,
                previousPosition!.longitude,
                pos.latitude,
                pos.longitude,
              );
              if (d < 1.5 && pos.speed < 0.5) return;
            }

            previousPosition = pos;

            final point = LiveGpsPoint(
              latitude: pos.latitude,
              longitude: pos.longitude,
              timestamp: pos.timestamp,
              altitude: pos.altitude,
              speed: math.max(0.0, pos.speed),
              accuracy: pos.accuracy,
            );

            controller.add(point);
          },
          onError: (e) => controller.addError(e),
          onDone: () => controller.close(),
        );
      },
      onCancel: () {
        _subscription?.cancel();
        _subscription = null;
      },
    );

    return controller.stream;
  }

  void stopTracking() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Haversine formula distance between two coordinates in meters
  static double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// Estimates calories burned using MET (Compendium of Physical Activities)
  static double estimateCalories({
    required SportType sport,
    required double durationSeconds,
    double userWeightKg = 75.0,
  }) {
    final hours = durationSeconds / 3600.0;
    return sport.met * userWeightKg * hours;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
}
