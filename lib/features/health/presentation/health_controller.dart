import 'package:flutter/foundation.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/health_models.dart';
import '../domain/health_repository.dart';
import '../../../core/time/clock.dart';

class HealthController extends ChangeNotifier {
  HealthController({
    required HealthRepository repository,
    Clock clock = const SystemClock(),
    this.minimumSyncInterval = const Duration(minutes: 5),
    this.maxRetries = 3,
  })  : _repository = repository,
        _clock = clock;

  final HealthRepository _repository;
  final Clock _clock;
  final Duration minimumSyncInterval;
  final int maxRetries;
  final AppLogger _logger = const AppLogger();
  HealthAvailability? availabilityState;
  HealthPermissionState? permissionState;
  List<DailyHealthSummary> summariesState = const [];
  List<HealthSyncState> syncStatesState = const [];
  List<HealthSourceSummary> sourcesState = const [];
  DateTime? lastSuccessfulSyncUtc;
  bool isLoading = false;
  String? errorMessage;

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
      if (permissionState?.readGranted == true) {
        await _loadSummaries();
      }
    });
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
}
