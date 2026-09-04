import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/health_repository.dart';

class PhoneStepSensorService {
  PhoneStepSensorService({
    HealthRepository? healthRepository,
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
    Future<int?> Function(DateTime start, DateTime end)? getStepsInInterval,
  })  : _repository = healthRepository,
        _methodChannel =
            methodChannel ?? const MethodChannel('macro_mate/step_sensor'),
        _eventChannel =
            eventChannel ?? const EventChannel('macro_mate/step_sensor_events'),
        _getStepsInInterval = getStepsInInterval;

  final HealthRepository? _repository;
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  final Future<int?> Function(DateTime start, DateTime end)?
      _getStepsInInterval;

  static const String prefEnabled = 'phone_step_sensor_enabled';
  static const String prefDate = 'phone_step_sensor_date';
  static const String prefBaseline = 'phone_step_sensor_baseline';
  static const String prefLastRaw = 'phone_step_sensor_last_raw';
  static const String prefRebootOffset = 'phone_step_sensor_reboot_offset';
  static const String prefPriorSteps = 'phone_step_sensor_prior_steps';
  static const String prefTodaySteps = 'phone_step_sensor_today_steps';

  StreamSubscription<dynamic>? _subscription;
  final _stepController = StreamController<int>.broadcast();
  Stream<int> get stepStream => _stepController.stream;

  int _currentTodaySteps = 0;
  int get currentTodaySteps => _currentTodaySteps;

  bool _isListening = false;
  bool get isListening => _isListening;

  /// Checks if the device has a hardware step counter sensor.
  Future<bool> isSensorAvailable() async {
    if (!kIsWeb && !Platform.isAndroid) return false;
    try {
      final available =
          await _methodChannel.invokeMethod<bool>('isSensorAvailable');
      return available ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Checks whether ACTIVITY_RECOGNITION permission is granted.
  Future<bool> hasPermission() async {
    if (!kIsWeb && !Platform.isAndroid) return false;
    try {
      final status = await Permission.activityRecognition.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Requests the ACTIVITY_RECOGNITION runtime permission.
  Future<bool> requestPermission() async {
    if (!kIsWeb && !Platform.isAndroid) return false;
    try {
      final status = await Permission.activityRecognition.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Checks if the user enabled the direct hardware step counter in settings.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefEnabled) ?? false;
  }

  /// Sets whether the internal hardware step sensor should be used.
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefEnabled, enabled);
    if (enabled) {
      await startListening();
    } else {
      await stopListening();
    }
  }

  /// Queries steps taken earlier today before sensor initialization
  /// from HealthRepository, Health Connect, or SharedPreferences.
  Future<int> queryInitialStepsForToday(DateTime currentTime) async {
    int maxSteps = 0;

    // 1. Query HealthRepository (other sources like Health Connect, Wear OS, etc.)
    if (_repository != null) {
      try {
        final repoSteps = await _repository.getPriorStepsToday(
          currentTime,
          excludeSourceId: 'phone_step_sensor',
        );
        if (repoSteps > maxSteps) {
          maxSteps = repoSteps;
        }
      } catch (_) {}
    }

    // 2. Query custom step callback or Health Connect directly
    if (_getStepsInInterval != null) {
      try {
        final midnight =
            DateTime(currentTime.year, currentTime.month, currentTime.day);
        final externalSteps = await _getStepsInInterval(midnight, currentTime);
        if (externalSteps != null && externalSteps > maxSteps) {
          maxSteps = externalSteps;
        }
      } catch (_) {}
    }

    // 3. Query SharedPreferences for steps recorded earlier today
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = _formatDay(currentTime);
      final savedDate = prefs.getString(prefDate);
      if (savedDate == todayStr) {
        final savedSteps = prefs.getInt(prefTodaySteps) ?? 0;
        final savedPrior = prefs.getInt(prefPriorSteps) ?? 0;
        if (savedSteps > maxSteps) maxSteps = savedSteps;
        if (savedPrior > maxSteps) maxSteps = savedPrior;
      }
    } catch (_) {}

    return maxSteps;
  }

  /// Starts listening to step updates from the hardware sensor.
  Future<void> startListening() async {
    if (_isListening) return;
    if (!kIsWeb && !Platform.isAndroid) return;

    final available = await isSensorAvailable();
    if (!available) return;

    final granted = await hasPermission();
    if (!granted) {
      final requested = await requestPermission();
      if (!requested) return;
    }

    _isListening = true;

    // Load initial today's steps from storage or query initial steps
    final now = DateTime.now();
    final today = _formatDay(now);
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(prefDate);
    if (savedDate == today) {
      _currentTodaySteps = prefs.getInt(prefTodaySteps) ?? 0;
      _stepController.add(_currentTodaySteps);
    } else {
      final prior = await queryInitialStepsForToday(now);
      if (prior > 0) {
        _currentTodaySteps = prior;
        _stepController.add(prior);
      }
    }

    // Listen to live hardware step events
    _subscription?.cancel();
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is int) {
          processRawStepCount(event);
        } else if (event is num) {
          processRawStepCount(event.toInt());
        }
      },
      onError: (dynamic error) {
        // Sensor error handling
      },
    );

    // Try reading current raw boot step count immediately
    try {
      final raw = await _methodChannel.invokeMethod<int>('getRawStepCount');
      if (raw != null && raw > 0) {
        await processRawStepCount(raw);
      }
    } catch (_) {}
  }

  /// Stops listening to step sensor updates.
  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  /// Processes raw steps since device boot, calculates today's steps,
  /// handles device reboots and date boundaries, and persists the data.
  Future<int> processRawStepCount(
    int rawCount, {
    DateTime? now,
    int? initialPriorSteps,
  }) async {
    final currentTime = now ?? DateTime.now();
    final todayStr = _formatDay(currentTime);

    final prefs = await SharedPreferences.getInstance();
    String? savedDate = prefs.getString(prefDate);
    int baseline = prefs.getInt(prefBaseline) ?? rawCount;
    int lastRaw = prefs.getInt(prefLastRaw) ?? rawCount;
    int rebootOffset = prefs.getInt(prefRebootOffset) ?? 0;
    int priorSteps = prefs.getInt(prefPriorSteps) ?? (initialPriorSteps ?? 0);

    // Detect phone reboot: raw counter reset to near 0 while last raw was higher
    if (rawCount < lastRaw) {
      rebootOffset += lastRaw;
    }

    // Detect new day rollover (midnight) or first run today
    if (savedDate != todayStr) {
      savedDate = todayStr;
      baseline = rawCount + rebootOffset;
      if (initialPriorSteps != null) {
        priorSteps = initialPriorSteps;
      } else {
        priorSteps = await queryInitialStepsForToday(currentTime);
      }
    }

    // Reconcile an explicit refresh before processing the next sensor sample.
    // This is needed when Health Connect finished importing the full day after
    // the hardware counter had already started from a mid-day baseline.
    var currentDelta = (rawCount + rebootOffset) - baseline;
    if (initialPriorSteps != null &&
        initialPriorSteps > priorSteps + (currentDelta > 0 ? currentDelta : 0)) {
      priorSteps = initialPriorSteps;
      baseline = lastRaw + rebootOffset;
      currentDelta = (rawCount + rebootOffset) - baseline;
    }

    // Check if external sources (e.g. Health Connect) have higher recorded
    // steps for today. The repository resolves Health Connect's complete
    // interval total before falling back to locally persisted samples.
    if (_repository != null) {
      try {
        final knownPrior = await _repository.getPriorStepsToday(
          currentTime,
          excludeSourceId: 'phone_step_sensor',
        );
        if (knownPrior > (priorSteps + (currentDelta > 0 ? currentDelta : 0))) {
          priorSteps = knownPrior;
          baseline = lastRaw + rebootOffset;
        }
      } catch (_) {}
    }

    // Calculate sensor delta since baseline
    int delta = (rawCount + rebootOffset) - baseline;
    if (delta < 0) {
      delta = 0;
      baseline = rawCount + rebootOffset;
    }

    // Today's total steps = steps before starting + steps counted by sensor
    int todaySteps = priorSteps + delta;

    _currentTodaySteps = todaySteps;

    // Persist current state
    await prefs.setString(prefDate, todayStr);
    await prefs.setInt(prefBaseline, baseline);
    await prefs.setInt(prefLastRaw, rawCount);
    await prefs.setInt(prefRebootOffset, rebootOffset);
    await prefs.setInt(prefPriorSteps, priorSteps);
    await prefs.setInt(prefTodaySteps, todaySteps);

    // Save to health repository
    if (_repository != null) {
      try {
        await _repository.recordSteps(
          steps: todaySteps,
          date: currentTime,
          sourceId: 'phone_step_sensor',
          sourceName: 'OnePlus Hardware-Sensor',
        );
      } catch (_) {}
    }

    // Notify after persistence so listeners that reload the aggregate always
    // observe the same number as the hardware-sensor card.
    _stepController.add(todaySteps);

    return todaySteps;
  }

  /// Manually refreshes prior steps from repository/external sources,
  /// e.g. after connecting Health Connect or performing a sync.
  Future<void> refreshPriorSteps() async {
    final now = DateTime.now();
    final prior = await queryInitialStepsForToday(now);
    if (prior > _currentTodaySteps) {
      final prefs = await SharedPreferences.getInstance();
      final lastRaw = prefs.getInt(prefLastRaw);
      if (lastRaw != null) {
        await processRawStepCount(
          lastRaw,
          now: now,
          initialPriorSteps: prior,
        );
      } else {
        _currentTodaySteps = prior;
        _stepController.add(prior);
        await prefs.setInt(prefPriorSteps, prior);
        await prefs.setInt(prefTodaySteps, prior);
        if (_repository != null) {
          try {
            await _repository.recordSteps(
              steps: prior,
              date: now,
              sourceId: 'phone_step_sensor',
              sourceName: 'OnePlus Hardware-Sensor',
            );
          } catch (_) {}
        }
      }
    }
  }

  String _formatDay(DateTime date) {
    final local = date.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _subscription?.cancel();
    _stepController.close();
  }
}
