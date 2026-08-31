import 'package:flutter/foundation.dart';

import '../../../core/time/clock.dart';
import '../domain/cycle_engine.dart';
import '../domain/cycle_models.dart';
import '../domain/cycle_repository.dart';

class CycleController extends ChangeNotifier {
  CycleController({
    required CycleRepository repository,
    Clock clock = const SystemClock(),
  })  : _repository = repository,
        _clock = clock;

  final CycleRepository _repository;
  final Clock _clock;
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

  Future<void> addPeriod(DateTime startDay, {DateTime? endDay, BleedingLevel? flow, String source = 'local'}) async {
    await _run(() async {
      await _repository.addPeriod(startDay: startDay, endDay: endDay, flow: flow, source: source);
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

  Future<List<CycleConflictItem>> stageImportPreview(
    List<HealthMenstruationRecord> records,
  ) async {
    final conflicts = await _repository.detectImportConflicts(records);
    pendingImportConflicts = conflicts;
    notifyListeners();
    return conflicts;
  }

  void updateConflictResolution(int index, MenstruationConflictResolution resolution) {
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
