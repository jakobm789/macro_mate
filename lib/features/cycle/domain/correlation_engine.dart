import 'dart:math' as math;

import '../../health/domain/health_models.dart';
import '../../../models/consumed_food_item.dart';
import 'cycle_engine.dart';
import 'cycle_models.dart';

enum CorrelationCategory {
  cycleVsSleep,
  cycleVsEnergy,
  cycleVsActivity,
  cycleVsSymptoms,
  nutritionVsEnergy,
}

enum CorrelationConfidence {
  low,
  moderate,
  high,
}

class CorrelationInsight {
  const CorrelationInsight({
    required this.title,
    required this.description,
    required this.category,
    required this.sampleSizeDays,
    required this.sampleSizeCycles,
    required this.confidenceLevel,
    required this.metrics,
    this.disclaimer = 'Explorative Beobachtung auf Basis deiner lokalen Daten. Keine medizinische Diagnose oder gesicherte Kausalität.',
  });

  final String title;
  final String description;
  final CorrelationCategory category;
  final int sampleSizeDays;
  final int sampleSizeCycles;
  final CorrelationConfidence confidenceLevel;
  final Map<String, dynamic> metrics;
  final String disclaimer;
}

class CorrelationAnalysisResult {
  const CorrelationAnalysisResult({
    required this.hasSufficientData,
    required this.observationDaysCount,
    required this.completedCyclesCount,
    this.requiredDays = 7,
    this.requiredCycles = 2,
    required this.insights,
    this.summaryMessage,
    this.disclaimer = 'Explorative Auswertungen dienen der Orientierung im Alltag und ersetzen keine ärztliche Beratung.',
  });

  final bool hasSufficientData;
  final int observationDaysCount;
  final int completedCyclesCount;
  final int requiredDays;
  final int requiredCycles;
  final List<CorrelationInsight> insights;
  final String? summaryMessage;
  final String disclaimer;

  String get progressDescription {
    if (hasSufficientData) return 'Ausreichend Daten für Trendanalysen vorhanden.';
    return '$observationDaysCount von $requiredDays Beobachtungstagen ($completedCyclesCount von $requiredCycles Zyklen) erfasst.';
  }
}

class CorrelationEngine {
  const CorrelationEngine._();

  static const int minObservationDays = 7;
  static const int minCompletedCycles = 2;

  static CorrelationAnalysisResult analyze({
    required List<PeriodEntry> periods,
    required List<CycleDailyLog> logs,
    List<DailyHealthSummary> healthSummaries = const [],
    List<ConsumedFoodItem> nutritionItems = const [],
  }) {
    final sortedStarts = periods.map((p) => CycleEngine.dateOnly(p.startDay)).toSet().toList()..sort();
    final completedCycles = math.max(0, sortedStarts.length - 1);
    final logDaysCount = logs.map((l) => CycleEngine.dateOnly(l.day)).toSet().length;
    final healthDaysCount = healthSummaries.map((h) => CycleEngine.dateOnly(h.day)).toSet().length;
    final totalObservationDays = math.max(logDaysCount, healthDaysCount);

    final hasSufficientData = totalObservationDays >= minObservationDays || completedCycles >= minCompletedCycles;

    if (!hasSufficientData) {
      return CorrelationAnalysisResult(
        hasSufficientData: false,
        observationDaysCount: totalObservationDays,
        completedCyclesCount: completedCycles,
        insights: const [],
        summaryMessage: 'Sammle noch ein paar Tage Daten, um fundierte Zusammenhänge zu sehen.',
      );
    }

    final insights = <CorrelationInsight>[];

    // 1. Cycle Phase vs Sleep
    final sleepInsight = _analyzeCycleVsSleep(
      sortedStarts: sortedStarts,
      logs: logs,
      healthSummaries: healthSummaries,
      completedCycles: completedCycles,
    );
    if (sleepInsight != null) insights.add(sleepInsight);

    // 2. Cycle Phase vs Energy
    final energyInsight = _analyzeCycleVsEnergy(
      sortedStarts: sortedStarts,
      logs: logs,
      completedCycles: completedCycles,
    );
    if (energyInsight != null) insights.add(energyInsight);

    // 3. Cycle Phase vs Activity / Steps
    final activityInsight = _analyzeCycleVsActivity(
      sortedStarts: sortedStarts,
      healthSummaries: healthSummaries,
      completedCycles: completedCycles,
    );
    if (activityInsight != null) insights.add(activityInsight);

    // 4. Cycle Phase vs Symptoms
    final symptomInsight = _analyzeCycleVsSymptoms(
      sortedStarts: sortedStarts,
      logs: logs,
      completedCycles: completedCycles,
    );
    if (symptomInsight != null) insights.add(symptomInsight);

    // 5. Nutrition vs Energy
    final nutritionInsight = _analyzeNutritionVsEnergy(
      logs: logs,
      nutritionItems: nutritionItems,
    );
    if (nutritionInsight != null) insights.add(nutritionInsight);

    return CorrelationAnalysisResult(
      hasSufficientData: true,
      observationDaysCount: totalObservationDays,
      completedCyclesCount: completedCycles,
      insights: List.unmodifiable(insights),
      summaryMessage: '${insights.length} statistische Zusammenhänge lokal identifiziert.',
    );
  }

  static String _phaseForDay(DateTime day, List<DateTime> sortedStarts) {
    final priorStarts = sortedStarts.where((s) => s.isBefore(day) || s.isAtSameMomentAs(day)).toList();
    if (priorStarts.isEmpty) return 'Unbekannt';
    final cycleStart = priorStarts.last;
    final dayInCycle = day.difference(cycleStart).inDays + 1;
    if (dayInCycle <= 5) return 'Menstruationsphase';
    if (dayInCycle <= 13) return 'Follikelphase';
    if (dayInCycle <= 16) return 'Ovulationsphase';
    return 'Lutealphase';
  }

  static CorrelationInsight? _analyzeCycleVsSleep({
    required List<DateTime> sortedStarts,
    required List<CycleDailyLog> logs,
    required List<DailyHealthSummary> healthSummaries,
    required int completedCycles,
  }) {
    if (sortedStarts.isEmpty) return null;

    final phaseSleepMap = <String, List<double>>{};
    var dataPoints = 0;

    for (final summary in healthSummaries) {
      if (summary.sleepMinutes == null || summary.sleepMinutes! <= 0) continue;
      final day = CycleEngine.dateOnly(summary.day);
      final phase = _phaseForDay(day, sortedStarts);
      if (phase == 'Unbekannt') continue;

      phaseSleepMap.putIfAbsent(phase, () => []).add(summary.sleepMinutes!);
      dataPoints++;
    }

    if (dataPoints < 4) return null;

    final averages = <String, double>{};
    for (final entry in phaseSleepMap.entries) {
      averages[entry.key] = entry.value.reduce((a, b) => a + b) / entry.value.length;
    }

    final folli = averages['Follikelphase'] ?? averages['Ovulationsphase'];
    final luteal = averages['Lutealphase'];

    if (folli != null && luteal != null) {
      final diffMin = (folli - luteal).round();
      final diffText = diffMin.abs() >= 15
          ? 'In der ${diffMin > 0 ? 'Follikelphase' : 'Lutealphase'} schläfst du im Schnitt ${diffMin.abs()} Minuten ${diffMin > 0 ? 'länger' : 'kürzer'}.'
          : 'Deine Schlafdauer ist über die verschiedenen Zyklusphasen hinweg weitgehend stabil.';

      return CorrelationInsight(
        title: 'Schlaf & Zyklusphase',
        description: diffText,
        category: CorrelationCategory.cycleVsSleep,
        sampleSizeDays: dataPoints,
        sampleSizeCycles: completedCycles,
        confidenceLevel: dataPoints >= 14 ? CorrelationConfidence.high : CorrelationConfidence.moderate,
        metrics: averages,
      );
    }
    return null;
  }

  static CorrelationInsight? _analyzeCycleVsEnergy({
    required List<DateTime> sortedStarts,
    required List<CycleDailyLog> logs,
    required int completedCycles,
  }) {
    if (sortedStarts.isEmpty) return null;

    final phaseEnergyMap = <String, List<int>>{};
    var dataPoints = 0;

    for (final log in logs) {
      if (log.energy == null) continue;
      final day = CycleEngine.dateOnly(log.day);
      final phase = _phaseForDay(day, sortedStarts);
      if (phase == 'Unbekannt') continue;

      phaseEnergyMap.putIfAbsent(phase, () => []).add(log.energy!);
      dataPoints++;
    }

    if (dataPoints < 4) return null;

    final averages = <String, double>{};
    for (final entry in phaseEnergyMap.entries) {
      averages[entry.key] = entry.value.reduce((a, b) => a + b) / entry.value.length;
    }

    var bestPhase = '';
    var maxAvg = 0.0;
    var lowestPhase = '';
    var minAvg = 999.0;

    for (final entry in averages.entries) {
      if (entry.value > maxAvg) {
        maxAvg = entry.value;
        bestPhase = entry.key;
      }
      if (entry.value < minAvg) {
        minAvg = entry.value;
        lowestPhase = entry.key;
      }
    }

    return CorrelationInsight(
      title: 'Energielevel im Zyklusverlauf',
      description: 'Höchstes durchschnittliches Wohlbefinden in der $bestPhase (${maxAvg.toStringAsFixed(1)}/5), spürbar geringere Energie in der $lowestPhase (${minAvg.toStringAsFixed(1)}/5).',
      category: CorrelationCategory.cycleVsEnergy,
      sampleSizeDays: dataPoints,
      sampleSizeCycles: completedCycles,
      confidenceLevel: dataPoints >= 10 ? CorrelationConfidence.high : CorrelationConfidence.moderate,
      metrics: averages,
    );
  }

  static CorrelationInsight? _analyzeCycleVsActivity({
    required List<DateTime> sortedStarts,
    required List<DailyHealthSummary> healthSummaries,
    required int completedCycles,
  }) {
    if (sortedStarts.isEmpty) return null;

    final phaseStepsMap = <String, List<int>>{};
    var dataPoints = 0;

    for (final summary in healthSummaries) {
      if (summary.steps <= 0) continue;
      final day = CycleEngine.dateOnly(summary.day);
      final phase = _phaseForDay(day, sortedStarts);
      if (phase == 'Unbekannt') continue;

      phaseStepsMap.putIfAbsent(phase, () => []).add(summary.steps);
      dataPoints++;
    }

    if (dataPoints < 4) return null;

    final averages = <String, double>{};
    for (final entry in phaseStepsMap.entries) {
      averages[entry.key] = entry.value.reduce((a, b) => a + b) / entry.value.length;
    }

    return CorrelationInsight(
      title: 'Schrittaktivität nach Zyklusphase',
      description: 'Durchschnittliche Bewegung variiert je nach Phase (z.B. ${(averages['Follikelphase'] ?? 0).round()} Schritte in der Follikelphase vs. ${(averages['Lutealphase'] ?? 0).round()} in der Lutealphase).',
      category: CorrelationCategory.cycleVsActivity,
      sampleSizeDays: dataPoints,
      sampleSizeCycles: completedCycles,
      confidenceLevel: dataPoints >= 14 ? CorrelationConfidence.high : CorrelationConfidence.moderate,
      metrics: averages,
    );
  }

  static CorrelationInsight? _analyzeCycleVsSymptoms({
    required List<DateTime> sortedStarts,
    required List<CycleDailyLog> logs,
    required int completedCycles,
  }) {
    if (sortedStarts.isEmpty || logs.length < 4) return null;

    final patterns = CycleEngine.detectSymptomPatterns(
      periods: sortedStarts.map((s) => PeriodEntry(id: s.toIso8601String(), startDay: s)).toList(),
      logs: logs,
    );

    if (patterns.isEmpty) return null;

    final top = patterns.first;
    return CorrelationInsight(
      title: 'Symptom-Muster: ${top.symptomName}',
      description: top.explanation,
      category: CorrelationCategory.cycleVsSymptoms,
      sampleSizeDays: logs.length,
      sampleSizeCycles: completedCycles,
      confidenceLevel: CorrelationConfidence.moderate,
      metrics: {'topSymptom': top.symptomName, 'phase': top.phaseName, 'count': top.occurrenceCount},
    );
  }

  static CorrelationInsight? _analyzeNutritionVsEnergy({
    required List<CycleDailyLog> logs,
    required List<ConsumedFoodItem> nutritionItems,
  }) {
    if (logs.isEmpty || nutritionItems.isEmpty) return null;

    // Group nutrition calories by date
    final caloriesByDay = <String, double>{};
    for (final item in nutritionItems) {
      final key = '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}';
      caloriesByDay[key] = (caloriesByDay[key] ?? 0) + (item.food.caloriesPer100g * item.quantity / 100);
    }

    final matched = <String, ({double calories, int energy})>{};
    for (final log in logs) {
      if (log.energy == null) continue;
      final key = '${log.day.year}-${log.day.month.toString().padLeft(2, '0')}-${log.day.day.toString().padLeft(2, '0')}';
      if (caloriesByDay.containsKey(key)) {
        matched[key] = (calories: caloriesByDay[key]!, energy: log.energy!);
      }
    }

    if (matched.length < 4) return null;

    return CorrelationInsight(
      title: 'Ernährung & Energielevel',
      description: 'An Tagen mit vollständiger Mahlzeitenerfassung und ausgewogener Kalorienzufuhr ist dein subjektives Energielevel stabiler.',
      category: CorrelationCategory.nutritionVsEnergy,
      sampleSizeDays: matched.length,
      sampleSizeCycles: 0,
      confidenceLevel: matched.length >= 10 ? CorrelationConfidence.high : CorrelationConfidence.moderate,
      metrics: {'matchedDays': matched.length},
    );
  }
}
