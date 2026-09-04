import 'dart:async';
import 'package:flutter/widgets.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../data/phone_step_sensor_service.dart';
import '../domain/health_models.dart';
import '../domain/health_repository.dart';
import '../../../core/time/clock.dart';

class HealthController extends ChangeNotifier {
  HealthController({
    required HealthRepository repository,
    PhoneStepSensorService? phoneStepSensorService,
    Clock clock = const SystemClock(),
    this.minimumSyncInterval = const Duration(seconds: 25),
    this.foregroundSyncInterval = const Duration(seconds: 30),
    this.maxRetries = 3,
  })  : _repository = repository,
        _phoneStepSensorService = phoneStepSensorService,
        _clock = clock;

  final HealthRepository _repository;
  PhoneStepSensorService? _phoneStepSensorService;
  PhoneStepSensorService get phoneStepSensorService =>
      _phoneStepSensorService ??=
          PhoneStepSensorService(healthRepository: _repository);

  final Clock _clock;
  final Duration minimumSyncInterval;
  final Duration foregroundSyncInterval;
  final int maxRetries;
  final AppLogger _logger = const AppLogger();

  Timer? _foregroundSyncTimer;
  StreamSubscription<int>? _phoneStepSubscription;
  bool _isForegroundSyncActive = false;
  bool get isForegroundSyncActive => _isForegroundSyncActive;
  HealthAvailability? availabilityState;
  HealthPermissionState? permissionState;
  List<DailyHealthSummary> summariesState = const [];
  List<HealthSyncState> syncStatesState = const [];
  List<HealthSourceSummary> sourcesState = const [];
  DateTime? lastSuccessfulSyncUtc;
  bool isLoading = false;
  String? errorMessage;

  bool isPhoneSensorAvailable = false;
  bool isPhoneSensorEnabled = false;
  int phoneSensorTodaySteps = 0;

  HealthSyncStatus get syncStatus {
    if (isLoading) return HealthSyncStatus.running;
    if (errorMessage != null) return HealthSyncStatus.failed;
    if (lastSuccessfulSyncUtc != null) return HealthSyncStatus.success;
    return HealthSyncStatus.never;
  }

  DateTime? get lastSyncTime => lastSuccessfulSyncUtc;

  Future<void> initialize() => load();

  Future<void> load() async {
    await _run(() async {
      availabilityState = await _repository.availability();
      permissionState = await _repository.permissions();
      await _loadDiagnostics();
      await checkPhoneSensor();
      if (permissionState?.readGranted == true || isPhoneSensorEnabled) {
        await _loadSummaries();
      }
    });
  }

  Future<void> checkPhoneSensor() async {
    try {
      isPhoneSensorAvailable = await phoneStepSensorService.isSensorAvailable();
      isPhoneSensorEnabled = await phoneStepSensorService.isEnabled();
      phoneSensorTodaySteps = phoneStepSensorService.currentTodaySteps;
      if (isPhoneSensorEnabled) {
        _ensurePhoneStepSubscription();
        await phoneStepSensorService.startListening();
        await phoneStepSensorService.refreshPriorSteps();
        phoneSensorTodaySteps = phoneStepSensorService.currentTodaySteps;
      }
    } catch (_) {}
  }

  Future<void> togglePhoneSensor(bool enabled) async {
    try {
      if (enabled) _ensurePhoneStepSubscription();
      await phoneStepSensorService.setEnabled(enabled);
      isPhoneSensorEnabled = enabled;
      if (enabled) {
        await phoneStepSensorService.startListening();
        await phoneStepSensorService.refreshPriorSteps();
        phoneSensorTodaySteps = phoneStepSensorService.currentTodaySteps;
        await _loadSummaries();
      } else {
        await phoneStepSensorService.stopListening();
        await _phoneStepSubscription?.cancel();
        _phoneStepSubscription = null;
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Fehler beim Umschalten des Sensors: $e';
      notifyListeners();
    }
  }

  Future<void> requestPermissions({
    bool includeHistory = false,
    bool includeBackground = false,
  }) async {
    await _run(() async {
      permissionState = await _repository.requestPermissions(
        includeHistory: includeHistory,
        includeBackground: includeBackground,
      );
      if (permissionState?.readGranted == true) {
        await _syncLast30Days();
      }
    });
  }

  Future<void> syncLast30Days() async {
    await _run(_syncWithRetry);
  }

  Future<void> _syncWithRetry() async {
    final now = _clock.nowUtc();
    final lastAttempt = syncStatesState
        .map((state) => state.lastSuccessUtc)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (latest, value) {
      if (latest == null || value.isAfter(latest)) return value;
      return latest;
    });
    if (lastAttempt != null &&
        now.difference(lastAttempt) < minimumSyncInterval) {
      await _loadDiagnostics();
      return;
    }
    Object? lastError;
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await _syncLast30Days();
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        if (attempt + 1 >= maxRetries) rethrow;
        final delay = Duration(milliseconds: 250 * (1 << attempt));
        await Future<void>.delayed(delay);
      }
    }
    if (lastError != null) throw lastError;
  }

  Future<void> _syncLast30Days() async {
    final now = _clock.nowUtc();
    final start = now.subtract(const Duration(days: 30));
    summariesState = await _repository.sync(startUtc: start, endUtc: now);
    if (isPhoneSensorEnabled) {
      await phoneStepSensorService.refreshPriorSteps();
      phoneSensorTodaySteps = phoneStepSensorService.currentTodaySteps;
      await _loadSummaries();
    }
    await _loadDiagnostics();
  }

  Future<void> revokePermissions() async {
    await _run(() async {
      await _repository.revokePermissions();
      permissionState = await _repository.permissions();
      summariesState = const [];
      syncStatesState = const [];
      sourcesState = const [];
      lastSuccessfulSyncUtc = null;
    });
  }

  Future<void> _loadSummaries() async {
    final now = _clock.now();
    summariesState = await _repository.summaries(
      startDay: now.subtract(const Duration(days: 30)),
      endDay: now,
    );
  }

  Future<void> _loadDiagnostics() async {
    syncStatesState = await _repository.syncStates();
    sourcesState = await _repository.sources();
    lastSuccessfulSyncUtc = syncStatesState
        .map((state) => state.lastSuccessUtc)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (latest, value) {
      if (latest == null || value.isAfter(latest)) return value;
      return latest;
    });
  }

  void _ensurePhoneStepSubscription() {
    _phoneStepSubscription ??= phoneStepSensorService.stepStream.listen(
      (steps) {
        unawaited(_handlePhoneStepUpdate(steps));
      },
    );
  }

  Future<void> _handlePhoneStepUpdate(int steps) async {
    phoneSensorTodaySteps = steps;
    // The sensor service emits only after it has persisted the new daily
    // aggregate. Reloading here keeps the Activity page, dashboard and Android
    // widgets on the same number without waiting for the next 30-second sync.
    await _loadSummaries();
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _logger.error('health_controller', error);
      errorMessage = error is AppFailure
          ? error.userMessage
          : 'Health-Connect-Synchronisierung fehlgeschlagen.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void startPeriodicForegroundSync({Duration? interval}) {
    final syncInterval = interval ?? foregroundSyncInterval;
    _isForegroundSyncActive = true;
    _foregroundSyncTimer?.cancel();
    _foregroundSyncTimer = Timer.periodic(syncInterval, (_) {
      triggerForegroundPeriodicSync();
    });
  }

  void stopPeriodicForegroundSync() {
    _isForegroundSyncActive = false;
    _foregroundSyncTimer?.cancel();
    _foregroundSyncTimer = null;
  }

  Future<void> handleLifecycleChange(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (_isForegroundSyncActive) {
        _foregroundSyncTimer?.cancel();
        _foregroundSyncTimer = Timer.periodic(foregroundSyncInterval, (_) {
          triggerForegroundPeriodicSync();
        });
        await triggerForegroundPeriodicSync();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _foregroundSyncTimer?.cancel();
      _foregroundSyncTimer = null;
    }
  }

  Future<void> triggerForegroundPeriodicSync() async {
    if (!_isForegroundSyncActive) return;
    if (isLoading) return;
    if (permissionState?.readGranted != true && !isPhoneSensorEnabled) {
      return;
    }
    try {
      await _run(_syncLast30Days);
    } catch (e) {
      _logger.warning('Fehler beim periodischen Vordergrund-Sync: $e');
    }
  }

  @override
  void dispose() {
    stopPeriodicForegroundSync();
    _phoneStepSubscription?.cancel();
    phoneStepSensorService.dispose();
    super.dispose();
  }
}
