import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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

  /// Obtains the current initial position with fallback to last known
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;
      final lastKnown = await Geolocator.getLastKnownPosition();
      try {
        final current = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 4),
          ),
        );
        return current;
      } catch (_) {
        return lastKnown;
      }
    } catch (_) {
      return null;
    }
  }

  /// Starts listening to position updates and delivers filtered points
  Stream<LiveGpsPoint> startTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 2,
    SportType sport = SportType.running,
  }) {
    late final StreamController<LiveGpsPoint> controller;

    controller = StreamController<LiveGpsPoint>(
      onListen: () {
        LocationSettings locationSettings;
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          locationSettings = AndroidSettings(
            accuracy: accuracy,
            distanceFilter: distanceFilterMeters,
            intervalDuration: const Duration(seconds: 1),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'MacroMate Aktivitätstracking',
              notificationText: 'GPS-Aufzeichnung läuft...',
              notificationChannelName: 'Aktivitätstracking',
              notificationIcon: AndroidResource(
                name: 'launcher_icon',
                defType: 'mipmap',
              ),
              enableWakeLock: true,
              setOngoing: true,
            ),
          );
        } else {
          locationSettings = LocationSettings(
            accuracy: accuracy,
            distanceFilter: distanceFilterMeters,
          );
        }

        final stream = _positionStreamOverride ??
            Geolocator.getPositionStream(
              locationSettings: locationSettings,
            );

        Position? previousPosition;

        _subscription = stream.listen(
          (pos) {
            // Filter invalid accuracy
            if (pos.accuracy <= 0.0) return;

            // Accuracy gate: allow up to 45m on the first point for fast lock,
            // then require <= 35m for clean tracking without dropout under tree cover
            final maxAccuracy = previousPosition == null ? 45.0 : 35.0;
            if (pos.accuracy > maxAccuracy) return;

            if (previousPosition != null) {
              final dtSeconds = pos.timestamp
                      .difference(previousPosition!.timestamp)
                      .inMilliseconds /
                  1000.0;
              // Discard duplicate or backwards timestamps
              if (dtSeconds <= 0) return;

              final d = calculateDistanceMeters(
                previousPosition!.latitude,
                previousPosition!.longitude,
                pos.latitude,
                pos.longitude,
              );

              final impliedSpeed = d / dtSeconds; // in m/s

              // Outlier filter (GPS teleports / glitch jumps)
              // Running/Walking/Hiking max ~15 m/s (54 km/h), Cycling max ~35 m/s (126 km/h)
              final maxAllowedSpeed =
                  sport == SportType.cycling ? 35.0 : 15.0;
              if (impliedSpeed > maxAllowedSpeed) {
                return;
              }

              // Micro-jitter filter when stationary (e.g. traffic lights)
              final reportedSpeed = math.max(0.0, pos.speed);
              if (d < 1.2 && reportedSpeed < 0.4 && impliedSpeed < 0.4) {
                return;
              }
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
