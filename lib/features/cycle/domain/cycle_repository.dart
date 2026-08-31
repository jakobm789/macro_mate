import 'cycle_models.dart';

abstract interface class CycleRepository {
  Future<CycleProfile> profile();

  Future<void> saveProfile(CycleProfile profile);

  Future<List<PeriodEntry>> periods();

  Future<void> addPeriod({
    required DateTime startDay,
    DateTime? endDay,
    BleedingLevel? flow,
    String? id,
    String source = 'local',
  });

  Future<void> updatePeriod({
    required String id,
    required DateTime startDay,
    DateTime? endDay,
    BleedingLevel? flow,
    String? source,
  });

  Future<void> deletePeriod(String id);

  Future<void> saveDailyLog(CycleDailyLog log);

  Future<void> deleteDailyLog(DateTime day);

  Future<List<CycleDailyLog>> dailyLogs({DateTime? from, DateTime? to});

  Future<CycleForecast?> recalculate({DateTime? today});

  Future<List<CyclePrediction>> predictions();

  Future<List<CycleConflictItem>> detectImportConflicts(
      List<HealthMenstruationRecord> importedRecords);

  Future<int> applyMenstruationImport(List<CycleConflictItem> resolvedItems);
}
