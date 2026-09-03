import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/cardio_metrics_calculator.dart';
import '../domain/location_tracker_service.dart';

enum TrackingStatus { idle, running, paused, finished }

class RunningTrackerController extends ChangeNotifier {
  RunningTrackerController({
    LocationTrackerService? locationService,
    double userWeightKg = 75.0,
  })  : _locationService = locationService ?? LocationTrackerService(),
        _userWeightKg = userWeightKg;

  final LocationTrackerService _locationService;
  final double _userWeightKg;
  static const _uuid = Uuid();

  SportType _sport = SportType.running;
  SportType get sport => _sport;

  TrackingStatus _status = TrackingStatus.idle;
  TrackingStatus get status => _status;

  bool get isRunning => _status == TrackingStatus.running;
  bool get isPaused => _status == TrackingStatus.paused;
  bool get isTrackingActive => isRunning || isPaused;

  int _elapsedSeconds = 0;
  int get elapsedSeconds => _elapsedSeconds;

  double _distanceMeters = 0.0;
  double get distanceMeters => _distanceMeters;
  double get distanceKm => _distanceMeters / 1000.0;

  double _currentSpeedKmh = 0.0;
  double get currentSpeedKmh => _currentSpeedKmh;

  double? _currentPaceMinPerKm;
  double? get currentPaceMinPerKm => _currentPaceMinPerKm;

  double? _averagePaceMinPerKm;
  double? get averagePaceMinPerKm => _averagePaceMinPerKm;

  double _activeCaloriesBurned = 0.0;
  double get activeCaloriesBurned => _activeCaloriesBurned;

  double _currentElevationMeters = 0.0;
  double get currentElevationMeters => _currentElevationMeters;

  double _elevationGainMeters = 0.0;
  double get elevationGainMeters => _elevationGainMeters;

  final List<LiveGpsPoint> _routePoints = [];
  List<LiveGpsPoint> get routePoints => List.unmodifiable(_routePoints);

  final List<KmSplit> _splits = [];
  List<KmSplit> get splits => List.unmodifiable(_splits);

  String? _lastSplitNotification;
  String? get lastSplitNotification => _lastSplitNotification;

  bool _autoPauseEnabled = false;
  bool get autoPauseEnabled => _autoPauseEnabled;

  Timer? _timer;
  StreamSubscription<LiveGpsPoint>? _gpsSub;
  DateTime? _workoutStartTimeUtc;
  int _lastSplitSeconds = 0;
  double _lastSplitDistanceMeters = 0.0;

  void setSport(SportType sport) {
    if (isTrackingActive) return;
    _sport = sport;
    notifyListeners();
  }

  void toggleAutoPause(bool enabled) {
    _autoPauseEnabled = enabled;
    notifyListeners();
  }

  void clearSplitNotification() {
    _lastSplitNotification = null;
    notifyListeners();
  }

  Future<bool> startWorkout([SportType? sport]) async {
    if (sport != null) _sport = sport;

    final hasPermission = await _locationService.checkAndRequestPermission();
    if (!hasPermission) {
      return false;
    }

    _status = TrackingStatus.running;
    _elapsedSeconds = 0;
    _distanceMeters = 0.0;
    _currentSpeedKmh = 0.0;
    _currentPaceMinPerKm = null;
    _averagePaceMinPerKm = null;
    _activeCaloriesBurned = 0.0;
    _currentElevationMeters = 0.0;
    _elevationGainMeters = 0.0;
    _routePoints.clear();
    _splits.clear();
    _lastSplitNotification = null;
    _lastSplitSeconds = 0;
    _lastSplitDistanceMeters = 0.0;
    _workoutStartTimeUtc = DateTime.now().toUtc();

    _startTimer();
    _startGps();
    notifyListeners();
    return true;
  }

  void pauseWorkout() {
    if (_status != TrackingStatus.running) return;
    _status = TrackingStatus.paused;
    _currentSpeedKmh = 0.0;
    _currentPaceMinPerKm = null;
    _stopTimer();
    notifyListeners();
  }

  void resumeWorkout() {
    if (_status != TrackingStatus.paused) return;
    _status = TrackingStatus.running;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      _activeCaloriesBurned = LocationTrackerService.estimateCalories(
        sport: _sport,
        durationSeconds: _elapsedSeconds.toDouble(),
        userWeightKg: _userWeightKg,
      );

      if (_distanceMeters >= 50) {
        _averagePaceMinPerKm = (_elapsedSeconds / 60.0) / (_distanceMeters / 1000.0);
      }
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startGps() {
    _gpsSub?.cancel();
    _gpsSub = _locationService.startTracking().listen(
      (point) => onNewLocationPoint(point),
      onError: (e) {
        debugPrint('[RunningTracker] GPS Error: $e');
      },
    );
  }

  @visibleForTesting
  void onNewLocationPoint(LiveGpsPoint point) {
    if (_status != TrackingStatus.running) return;

    _currentElevationMeters = point.altitude;

    if (_routePoints.isNotEmpty) {
      final prev = _routePoints.last;
      final deltaDist = LocationTrackerService.calculateDistanceMeters(
        prev.latitude,
        prev.longitude,
        point.latitude,
        point.longitude,
      );

      _distanceMeters += deltaDist;

      if (point.altitude > prev.altitude) {
        _elevationGainMeters += (point.altitude - prev.altitude);
      }

      // Check for kilometer split boundary
      final currentKm = _distanceMeters ~/ 1000;
      if (currentKm > _splits.length) {
        final splitDuration = (_elapsedSeconds - _lastSplitSeconds).toDouble();
        final splitDistance = _distanceMeters - _lastSplitDistanceMeters;
        final splitPace = (splitDistance > 0 && splitDuration > 0)
            ? (splitDuration / 60.0) / (splitDistance / 1000.0)
            : 0.0;

        final newSplit = KmSplit(
          km: currentKm,
          distanceMeters: splitDistance,
          durationSeconds: splitDuration,
          paceMinPerKm: splitPace,
          speedKmh: (splitDistance / 1000.0) / (splitDuration / 3600.0),
        );
        _splits.add(newSplit);

        _lastSplitNotification = _sport == SportType.cycling
            ? 'Km $currentKm geschafft! Schnitt: ${newSplit.formattedSpeed}'
            : 'Km $currentKm geschafft! Pace: ${newSplit.formattedPace}';

        _lastSplitSeconds = _elapsedSeconds;
        _lastSplitDistanceMeters = _distanceMeters;
      }
    }

    _routePoints.add(point);

    // Speed & Pace calculation
    final speedKmh = point.speed * 3.6;
    _currentSpeedKmh = speedKmh;

    if (speedKmh >= 0.8) {
      _currentPaceMinPerKm = 60.0 / speedKmh;
    } else {
      _currentPaceMinPerKm = null;
    }

    // Auto-pause check
    if (_autoPauseEnabled && speedKmh < 0.8 && _elapsedSeconds > 10) {
      pauseWorkout();
      return;
    }

    notifyListeners();
  }

  Future<WorkoutSessionRow?> finishAndSaveWorkout(AppDatabase db) async {
    _stopTimer();
    _gpsSub?.cancel();
    _gpsSub = null;
    _status = TrackingStatus.finished;

    final startUtc = _workoutStartTimeUtc ?? DateTime.now().toUtc();
    final endUtc = DateTime.now().toUtc();
    final workoutId = _uuid.v4();
    final sportName = _sport.displayName;

    try {
      // 1. Insert WorkoutSession
      final session = WorkoutSessionRow(
        id: workoutId,
        type: sportName,
        startUtc: startUtc.toIso8601String(),
        endUtc: endUtc.toIso8601String(),
        durationSeconds: _elapsedSeconds.toDouble(),
        distanceM: _distanceMeters,
        energyKcal: _activeCaloriesBurned,
        sourceId: 'macromate_gps',
        routeStatus: _routePoints.isNotEmpty ? 'available' : 'unavailable',
      );

      await db.into(db.workoutSessions).insert(session);

      // 2. Insert Route Points if any
      if (_routePoints.isNotEmpty) {
        final pointRows = <WorkoutRoutePointRow>[];
        for (int i = 0; i < _routePoints.length; i++) {
          final pt = _routePoints[i];
          pointRows.add(
            WorkoutRoutePointRow(
              workoutId: workoutId,
              sequence: i,
              latitude: pt.latitude,
              longitude: pt.longitude,
              timestampUtc: pt.timestamp.toIso8601String(),
            ),
          );
        }
        await db.batch((b) {
          b.insertAll(db.workoutRoutePoints, pointRows);
        });
      }

      notifyListeners();
      return session;
    } catch (e) {
      debugPrint('[RunningTracker] Error saving workout session: $e');
      notifyListeners();
      return null;
    }
  }

  void discardWorkout() {
    _stopTimer();
    _gpsSub?.cancel();
    _gpsSub = null;
    _status = TrackingStatus.idle;
    _elapsedSeconds = 0;
    _distanceMeters = 0.0;
    _routePoints.clear();
    _splits.clear();
    _lastSplitNotification = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    _gpsSub?.cancel();
    super.dispose();
  }

  static String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
