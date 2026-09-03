import 'dart:math' as math;
import '../../health/domain/health_models.dart';

class KmSplit {
  const KmSplit({
    required this.km,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.paceMinPerKm,
    this.speedKmh,
    this.elevationGainMeters,
  });

  final int km;
  final double distanceMeters;
  final double durationSeconds;
  final double paceMinPerKm;
  final double? speedKmh;
  final double? elevationGainMeters;

  String get formattedPace {
    final minutes = paceMinPerKm.floor();
    final seconds = ((paceMinPerKm - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')} min/km';
  }

  String get formattedSpeed {
    final speed = speedKmh ?? (distanceMeters / 1000.0) / (durationSeconds / 3600.0);
    return '${speed.toStringAsFixed(1)} km/h';
  }
}

class HeartRateZone {
  const HeartRateZone({
    required this.zone,
    required this.name,
    required this.minBpm,
    required this.maxBpm,
    this.description,
  });

  final int zone;
  final String name;
  final int minBpm;
  final int maxBpm;
  final String? description;
}

class CardioMetricsCalculator {
  const CardioMetricsCalculator();

  /// Estimates Maximum Heart Rate using Gellish formula: 207 - (0.7 * age)
  static int estimateMaxHeartRate(int age) {
    if (age <= 0) return 190;
    return (207 - (0.7 * age)).round();
  }

  /// Calculates the 5 classic heart rate zones based on Max Heart Rate
  List<HeartRateZone> calculateHeartRateZones(int maxHr) {
    return [
      HeartRateZone(
        zone: 1,
        name: 'Aktive Erholung',
        minBpm: (maxHr * 0.50).round(),
        maxBpm: (maxHr * 0.60).round(),
        description: 'Fettstoffwechsel & Regeneration',
      ),
      HeartRateZone(
        zone: 2,
        name: 'Grundlagenausdauer 1',
        minBpm: (maxHr * 0.60).round(),
        maxBpm: (maxHr * 0.70).round(),
        description: 'Aerobe Basis & Fettverbrennung',
      ),
      HeartRateZone(
        zone: 3,
        name: 'Tempo / Aerob',
        minBpm: (maxHr * 0.70).round(),
        maxBpm: (maxHr * 0.80).round(),
        description: 'Herz-Kreislauf-Kapazität & Ausdauertempo',
      ),
      HeartRateZone(
        zone: 4,
        name: 'Laktatschwelle',
        minBpm: (maxHr * 0.80).round(),
        maxBpm: (maxHr * 0.90).round(),
        description: 'Schwellentraining & Laktattoleranz',
      ),
      HeartRateZone(
        zone: 5,
        name: 'VO2max / Maximal',
        minBpm: (maxHr * 0.90).round(),
        maxBpm: maxHr,
        description: 'Maximale anaerobe Leistungsfähigkeit',
      ),
    ];
  }

  /// Determines which zone a given BPM falls into
  int getZoneForBpm(int bpm, int maxHr) {
    if (bpm < (maxHr * 0.50).round()) return 1;
    if (bpm < (maxHr * 0.60).round()) return 1;
    if (bpm < (maxHr * 0.70).round()) return 2;
    if (bpm < (maxHr * 0.80).round()) return 3;
    if (bpm < (maxHr * 0.90).round()) return 4;
    return 5;
  }

  /// Calculates real kilometer splits from GPS route points if available,
  /// or falls back to uniform average pace splits.
  List<KmSplit> calculateSplits(WorkoutDetail workout) {
    if (workout.distanceMeters == null ||
        workout.distanceMeters! <= 0 ||
        workout.durationSeconds <= 0) {
      return const [];
    }

    final points = workout.routePoints;
    if (points.length >= 2) {
      final gpsSplits = _calculateGpsSplits(points);
      if (gpsSplits.isNotEmpty) {
        return gpsSplits;
      }
    }

    // Fallback: Uniform average pace splits
    return _calculateUniformSplits(workout.distanceMeters!, workout.durationSeconds);
  }

  List<KmSplit> _calculateGpsSplits(List<WorkoutRoutePointModel> points) {
    final splits = <KmSplit>[];
    double accumulatedMeters = 0.0;
    var currentKmIndex = 1;
    var kmStartTime = points.first.timestampUtc;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final distBetween = _haversineMeters(
        p1.latitude,
        p1.longitude,
        p2.latitude,
        p2.longitude,
      );

      accumulatedMeters += distBetween;

      if (accumulatedMeters >= currentKmIndex * 1000.0) {
        final duration = p2.timestampUtc.difference(kmStartTime).inMilliseconds / 1000.0;
        final paceMin = duration > 0 ? (duration / 60.0) : 0.0;
        final speed = duration > 0 ? (1.0 / (duration / 3600.0)) : 0.0;

        splits.add(KmSplit(
          km: currentKmIndex,
          distanceMeters: 1000.0,
          durationSeconds: duration,
          paceMinPerKm: paceMin,
          speedKmh: speed,
        ));

        currentKmIndex++;
        kmStartTime = p2.timestampUtc;
      }
    }

    // Remaining partial km
    final targetFullMeters = (currentKmIndex - 1) * 1000.0;
    final remainingMeters = accumulatedMeters - targetFullMeters;
    if (remainingMeters > 50.0) {
      final duration = points.last.timestampUtc.difference(kmStartTime).inMilliseconds / 1000.0;
      final kmFraction = remainingMeters / 1000.0;
      final paceMin = (kmFraction > 0 && duration > 0)
          ? (duration / 60.0) / kmFraction
          : 0.0;
      final speed = duration > 0 ? (kmFraction / (duration / 3600.0)) : 0.0;

      splits.add(KmSplit(
        km: currentKmIndex,
        distanceMeters: remainingMeters,
        durationSeconds: duration,
        paceMinPerKm: paceMin,
        speedKmh: speed,
      ));
    }

    return splits;
  }

  List<KmSplit> _calculateUniformSplits(double totalDistanceMeters, double totalDurationSeconds) {
    final splits = <KmSplit>[];
    final totalKm = totalDistanceMeters / 1000.0;
    final avgSecondsPerKm = totalDurationSeconds / totalKm;
    final paceMin = avgSecondsPerKm / 60.0;
    final speed = (totalDistanceMeters / 1000.0) / (totalDurationSeconds / 3600.0);

    final fullKm = totalKm.floor();
    for (int km = 1; km <= fullKm; km++) {
      splits.add(KmSplit(
        km: km,
        distanceMeters: 1000.0,
        durationSeconds: avgSecondsPerKm,
        paceMinPerKm: paceMin,
        speedKmh: speed,
      ));
    }

    final remainingKm = totalKm - fullKm;
    if (remainingKm > 0.05) {
      splits.add(KmSplit(
        km: fullKm + 1,
        distanceMeters: remainingKm * 1000.0,
        durationSeconds: avgSecondsPerKm * remainingKm,
        paceMinPerKm: paceMin,
        speedKmh: speed,
      ));
    }

    return splits;
  }

  /// Calculates speed in km/h for biking / cycling
  static double calculateSpeedKmh(double distanceMeters, double durationSeconds) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return 0.0;
    final km = distanceMeters / 1000.0;
    final hours = durationSeconds / 3600.0;
    return km / hours;
  }

  /// Calculates pace in min/km for running / walking
  static double? calculatePaceMinPerKm(double distanceMeters, double durationSeconds) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return null;
    final km = distanceMeters / 1000.0;
    final minutes = durationSeconds / 60.0;
    return minutes / km;
  }

  /// Formats workout metric based on sport type (speed for cycling, pace for running)
  static String formatSportMetric(String workoutType, double distanceMeters, double durationSeconds) {
    final lower = workoutType.toLowerCase();
    final isCycling = lower.contains('biking') ||
        lower.contains('cycling') ||
        lower.contains('rad') ||
        lower.contains('bike');

    if (isCycling) {
      final speed = calculateSpeedKmh(distanceMeters, durationSeconds);
      return '${speed.toStringAsFixed(1)} km/h';
    } else {
      final pace = calculatePaceMinPerKm(distanceMeters, durationSeconds);
      if (pace == null) return '–';
      final minutes = pace.floor();
      final seconds = ((pace - minutes) * 60).round();
      return '$minutes:${seconds.toString().padLeft(2, '0')} min/km';
    }
  }

  /// Great-circle distance between two GPS coordinates using Haversine formula
  static double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
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

  static double _degToRad(double degree) => degree * (math.pi / 180.0);

  /// Generates a standard GPX 1.1 XML string from route points
  static String generateGpxString({
    required String workoutName,
    required List<WorkoutRoutePointModel> points,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="MacroMate" xmlns="http://www.topografix.com/GPX/1/1">');
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>$workoutName</name>');
    buffer.writeln('    <trkseg>');
    for (final pt in points) {
      buffer.writeln('      <trkpt lat="${pt.latitude}" lon="${pt.longitude}">');
      buffer.writeln('        <time>${pt.timestampUtc.toIso8601String()}</time>');
      buffer.writeln('      </trkpt>');
    }
    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');
    return buffer.toString();
  }
}
