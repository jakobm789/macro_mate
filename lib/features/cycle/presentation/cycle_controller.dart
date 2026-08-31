import 'package:flutter/foundation.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/time/clock.dart';
import '../../health/domain/health_models.dart';
import '../../health/domain/health_repository.dart';
import '../domain/cycle_engine.dart';
import '../domain/cycle_models.dart';
import '../domain/cycle_repository.dart';

sealed class MenstruationImportResult {
  const MenstruationImportResult();
}

class MenstruationImportSuccess extends MenstruationImportResult {
  final List<CycleConflictItem> conflicts;
  const MenstruationImportSuccess(this.conflicts);
}

class MenstruationImportPermissionDenied extends MenstruationImportResult {
  final String message;
  const MenstruationImportPermissionDenied([
    this.message =
        'Health Connect Menstruationsberechtigung wurde nicht erteilt.',
  ]);
}

class MenstruationImportUnavailable extends MenstruationImportResult {
  final String message;
  const MenstruationImportUnavailable([
    this.message = 'Health Connect ist auf diesem Gerät nicht verfügbar.',
  ]);
}

class MenstruationImportError extends MenstruationImportResult {
  final String message;
  const MenstruationImportError(this.message);
}

class CycleController extends ChangeNotifier {
  CycleController({
    required CycleRepository repository,
    HealthRepository? healthRepository,
    Clock clock = const SystemClock(),
    AppLogger logger = const AppLogger(),
  })  : _repository = repository,
        _healthRepository = healthRepository,
        _clock = clock,
        _logger = logger;

  final CycleRepository _repository;
  final HealthRepository? _healthRepository;
  final Clock _clock;
  final AppLogger _logger;
  CycleProfile profileState = const CycleProfile();
  List<PeriodEntry> periodsState = const [];
  List<CycleDailyLog> logsState = const [];
  CycleForecast? forecastState;
  List<CycleConflictItem> pendingImportConflicts = [];
  bool isLoading = false;
  String? errorMessage;

  bool get predictionsEnabled => profileState.predictionsEnabled;
  int? get currentCycleDay => forecastState?.cycleDay;
  List<CyclePrediction> get predictions =>
      forecastState?.predictions ?? const [];

  String? get currentPhaseName {
    if (forecastState == null) return null;
    final day = forecastState!.cycleDay;
    final pLen = forecastState!.periodLength;
    if (day <= pLen) return 'Menstruation';
    if (day <= 13) return 'Follikelphase';
    if (day <= 16) return 'Ovulation';
    return 'Lutealphase';
  }

  Future<void> initialize() => load();

  Future<void> load() async {
    await _run(() async {
      profileState = await _repository.profile();
      await _loadData();
    });
  }

  Future<void> addPeriod(DateTime startDay,
      {DateTime? endDay, BleedingLevel? flow, String source = 'local'}) async {
    await _run(() async {
      await _repository.addPeriod(
          startDay: startDay, endDay: endDay, flow: flow, source: source);
      await _loadData();
    });
  }

  Future<void> updatePeriod({
    required String id,
    required DateTime startDay,
    DateTime? endDay,
    BleedingLevel? flow,
    String? source,
  }) async {
    await _run(() async {
      await _repository.updatePeriod(
        id: id,
        startDay: startDay,
        endDay: endDay,
        flow: flow,
        source: source,
      );
      await _loadData();
    });
  }

  Future<void> deletePeriod(String id) async {
    await _run(() async {
      await _repository.deletePeriod(id);
      await _loadData();
    });
  }

  Future<void> saveLog(CycleDailyLog log) async {
    await _run(() async {
      await _repository.saveDailyLog(log);
      await _loadData();
    });
  }

  Future<void> deleteLog(DateTime day) async {
    await _run(() async {
      await _repository.deleteDailyLog(day);
      await _loadData();
    });
  }

  Future<bool> hasMenstruationPermission() async {
    if (_healthRepository == null) return false;
    try {
      return await _healthRepository.hasMenstruationPermission();
    } catch (e) {
      _logger.error('hasMenstruationPermission', e);
      return false;
    }
  }

  Future<bool> requestMenstruationPermission() async {
    if (_healthRepository == null) return false;
    try {
      return await _healthRepository.requestMenstruationPermission();
    } catch (e) {
      _logger.error('requestMenstruationPermission', e);
      return false;
    }
  }

  Future<MenstruationImportResult> previewHealthConnectImport({
    DateTime? startUtc,
    DateTime? endUtc,
  }) async {
    if (_healthRepository == null) {
      return const MenstruationImportUnavailable(
        'Kein Health-Repository konfiguriert.',
      );
    }

    try {
      final availability = await _healthRepository.availability();
      if (availability != HealthAvailability.available) {
        return const MenstruationImportUnavailable(
          'Health Connect ist nicht verfügbar oder benötigt ein Update.',
        );
      }

      final hasPermission = await _healthRepository.hasMenstruationPermission();
      if (!hasPermission) {
        final granted = await _healthRepository.requestMenstruationPermission();
        if (!granted) {
          errorMessage =
              'Health Connect Menstruationsberechtigung wurde nicht erteilt.';
          notifyListeners();
          return const MenstruationImportPermissionDenied();
        }
      }

      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final now = _clock.now();
      final start = startUtc ?? now.subtract(const Duration(days: 180));
      final end = endUtc ?? now;
      final records = await _healthRepository.readMenstruation(
        startUtc: start.toUtc(),
        endUtc: end.toUtc(),
      );
      final conflicts = await stageImportPreview(records);
      return MenstruationImportSuccess(conflicts);
    } on HealthPermissionException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return MenstruationImportPermissionDenied(e.message);
    } catch (e) {
      _logger.error('previewHealthConnectImport', e);
      final msg = 'Fehler beim Lesen der Menstruationsdaten: $e';
      errorMessage = msg;
      notifyListeners();
      return MenstruationImportError(msg);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<CycleConflictItem>> stageImportPreview(
    List<HealthMenstruationRecord> records,
  ) async {
    final conflicts = await _repository.detectImportConflicts(records);
    pendingImportConflicts = conflicts;
    notifyListeners();
    return conflicts;
  }

  void updateConflictResolution(
      int index, MenstruationConflictResolution resolution) {
    if (index >= 0 && index < pendingImportConflicts.length) {
      pendingImportConflicts[index].chosenResolution = resolution;
      notifyListeners();
    }
  }

  Future<int> applyStagedImport() async {
    if (pendingImportConflicts.isEmpty) return 0;
    var count = 0;
    await _run(() async {
      count = await _repository.applyMenstruationImport(pendingImportConflicts);
      pendingImportConflicts = [];
      await _loadData();
    });
    return count;
  }

  CycleHistoryStats getHistoryStats() {
    return CycleEngine.historyStats(periodsState);
  }

  List<CycleSymptomInsight> getSymptomInsights() {
    return CycleEngine.detectSymptomPatterns(
      periods: periodsState,
      logs: logsState,
    );
  }

  Future<void> _loadData() async {
    final now = _clock.now();
    periodsState = await _repository.periods();
    logsState = await _repository.dailyLogs(
      from: now.subtract(const Duration(days: 90)),
    );
    forecastState = await _repository.recalculate(today: now);
  }

  Future<void> _run(Future<void> Function() action) async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
