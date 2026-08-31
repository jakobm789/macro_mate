import 'package:flutter/foundation.dart';

import '../domain/cycle_models.dart';
import '../domain/cycle_repository.dart';

class CycleController extends ChangeNotifier {
  CycleController({required CycleRepository repository})
      : _repository = repository;

  final CycleRepository _repository;
  CycleProfile profileState = const CycleProfile();
  List<PeriodEntry> periodsState = const [];
  List<CycleDailyLog> logsState = const [];
  CycleForecast? forecastState;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    await _run(() async {
      profileState = await _repository.profile();
      periodsState = await _repository.periods();
      logsState = await _repository.dailyLogs(
        from: DateTime.now().subtract(const Duration(days: 30)),
      );
      forecastState = await _repository.recalculate(today: DateTime.now());
    });
  }

  Future<void> addPeriod(DateTime startDay) async {
    await _run(() async {
      await _repository.addPeriod(startDay: startDay);
      periodsState = await _repository.periods();
      forecastState = await _repository.recalculate(today: DateTime.now());
    });
  }

  Future<void> saveLog(CycleDailyLog log) async {
    await _run(() async {
      await _repository.saveDailyLog(log);
      logsState = await _repository.dailyLogs(
        from: DateTime.now().subtract(const Duration(days: 30)),
      );
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
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
