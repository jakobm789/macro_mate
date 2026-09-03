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
  })  : _repository = healthRepository,
        _methodChannel =
            methodChannel ?? const MethodChannel('macro_mate/step_sensor'),
        _eventChannel =
            eventChannel ?? const EventChannel('macro_mate/step_sensor_events');

  final HealthRepository? _repository;
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  static const String prefEnabled = 'phone_step_sensor_enabled';
  static const String prefDate = 'phone_step_sensor_date';
  static const String prefBaseline = 'phone_step_sensor_baseline';
  static const String prefLastRaw = 'phone_step_sensor_last_raw';
  static const String prefRebootOffset = 'phone_step_sensor_reboot_offset';
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

    // Load initial today's steps from storage
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDay(DateTime.now());
    final savedDate = prefs.getString(prefDate);
    if (savedDate == today) {
      _currentTodaySteps = prefs.getInt(prefTodaySteps) ?? 0;
      _stepController.add(_currentTodaySteps);
    }

    // Try reading current raw boot step count immediately
    try {
      final raw = await _methodChannel.invokeMethod<int>('getRawStepCount');
      if (raw != null && raw > 0) {
        await processRawStepCount(raw);
      }
    } catch (_) {}

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
  }

  /// Stops listening to step sensor updates.
  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  /// Processes raw steps since device boot, calculates today's steps,
  /// handles device reboots and date boundaries, and persists the data.
  Future<int> processRawStepCount(int rawCount, {DateTime? now}) async {
    final currentTime = now ?? DateTime.now();
    final todayStr = _formatDay(currentTime);

    final prefs = await SharedPreferences.getInstance();
    String? savedDate = prefs.getString(prefDate);
    int baseline = prefs.getInt(prefBaseline) ?? rawCount;
    int lastRaw = prefs.getInt(prefLastRaw) ?? rawCount;
    int rebootOffset = prefs.getInt(prefRebootOffset) ?? 0;

    // Detect phone reboot: raw counter reset to near 0 while last raw was higher
    if (rawCount < lastRaw) {
      rebootOffset += lastRaw;
    }

    // Detect new day rollover (midnight)
    if (savedDate != todayStr) {
      savedDate = todayStr;
      baseline = rawCount + rebootOffset;
    }

    // Calculate steps taken today
    int todaySteps = (rawCount + rebootOffset) - baseline;
    if (todaySteps < 0) {
      todaySteps = 0;
      baseline = rawCount + rebootOffset;
    }

    _currentTodaySteps = todaySteps;
    _stepController.add(todaySteps);

    // Persist current state
    await prefs.setString(prefDate, todayStr);
    await prefs.setInt(prefBaseline, baseline);
    await prefs.setInt(prefLastRaw, rawCount);
    await prefs.setInt(prefRebootOffset, rebootOffset);
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

    return todaySteps;
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
