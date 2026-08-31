import 'cycle_models.dart';

abstract interface class CycleRepository {
  Future<CycleProfile> profile();

  Future<void> saveProfile(CycleProfile profile);

  Future<List<PeriodEntry>> periods();

  Future<void> addPeriod({
    required DateTime startDay,
    DateTime? endDay,
    BleedingLevel? flow,
  });

  Future<void> saveDailyLog(CycleDailyLog log);

  Future<List<CycleDailyLog>> dailyLogs({DateTime? from, DateTime? to});

  Future<CycleForecast?> recalculate({DateTime? today});

  Future<List<CyclePrediction>> predictions();
}
