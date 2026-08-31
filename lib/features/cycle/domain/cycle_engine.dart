import 'dart:math' as math;

import 'cycle_models.dart';

class CycleEngine {
  const CycleEngine._();

  static CycleForecast? forecast({
    required List<PeriodEntry> periods,
    required DateTime today,
    CycleProfile profile = const CycleProfile(),
  }) {
    if (periods.isEmpty) return null;
    final starts = periods
        .map((entry) => dateOnly(entry.startDay))
        .toSet()
        .toList()
      ..sort();
    final latest = starts.last;
    final rawIntervals = <int>[];
    for (var index = 1; index < starts.length; index++) {
      final days = starts[index].difference(starts[index - 1]).inDays;
      if (days >= 14 && days <= 90) rawIntervals.add(days);
    }
    final intervals = _removeOutliers(rawIntervals);
    final cycleLength = _clamp(
      intervals.isEmpty ? profile.typicalCycleLength : _median(intervals),
      21,
      45,
    );
    final periodLength = _periodLength(periods, profile);
    final nextPeriod = dateOnly(latest).add(Duration(days: cycleLength));
    final ovulation = nextPeriod.subtract(const Duration(days: 14));
    final fertileStart = ovulation.subtract(const Duration(days: 5));
    final fertileEnd = ovulation.add(const Duration(days: 1));
    final cycleDay = dateOnly(today).difference(latest).inDays + 1;
    final confidence = _confidence(intervals);
    final rationale = intervals.isEmpty
        ? 'Schätzung auf Basis deines hinterlegten Zyklus von $cycleLength Tagen.'
        : 'Schätzung aus ${intervals.length + 1} erfassten Perioden; Median $cycleLength Tage.';
    return CycleForecast(
      cycleDay: _clamp(cycleDay, 1, 90),
      cycleLength: cycleLength,
      periodLength: periodLength,
      nextPeriod: nextPeriod,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
      confidence: confidence,
      rationale: rationale,
    );
  }

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static int _periodLength(List<PeriodEntry> periods, CycleProfile profile) {
    final lengths = <int>[];
    for (final period in periods) {
      final end = period.endDay;
      if (end == null) continue;
      final length =
          dateOnly(end).difference(dateOnly(period.startDay)).inDays + 1;
      if (length >= 1 && length <= 14) lengths.add(length);
    }
    return _clamp(
        lengths.isEmpty ? profile.typicalPeriodLength : _median(lengths),
        1,
        14);
  }

  static int _median(List<int> values) {
    final sorted = [...values]..sort();
    return sorted[sorted.length ~/ 2];
  }

  static double _confidence(List<int> intervals) {
    if (intervals.isEmpty) return .35;
    if (intervals.length == 1) return .55;
    final mean = intervals.reduce((a, b) => a + b) / intervals.length;
    final variance = intervals
            .map((value) => (value - mean) * (value - mean))
            .reduce((a, b) => a + b) /
        intervals.length;
    final stability = (1 - (math.sqrt(variance) / 14)).clamp(0.0, 1.0);
    return (.55 + intervals.length * .08 + stability * .2).clamp(.35, .95);
  }

  static CycleHistoryStats historyStats(List<PeriodEntry> periods) {
    final starts = periods
        .map((entry) => dateOnly(entry.startDay))
        .toSet()
        .toList()
      ..sort();
    final cycleLengths = _removeOutliers([
      for (var index = 1; index < starts.length; index++)
        starts[index].difference(starts[index - 1]).inDays,
    ].where((value) => value >= 14 && value <= 90).toList());
    final periodLengths = <int>[];
    for (final period in periods) {
      if (period.endDay == null) continue;
      final length = dateOnly(period.endDay!)
              .difference(dateOnly(period.startDay))
              .inDays +
          1;
      if (length >= 1 && length <= 14) periodLengths.add(length);
    }
    final deviation = cycleLengths.isEmpty
        ? null
        : math.sqrt(
            cycleLengths
                    .map((value) =>
                        (value -
                            cycleLengths.reduce((a, b) => a + b) /
                                cycleLengths.length) *
                        (value -
                            cycleLengths.reduce((a, b) => a + b) /
                                cycleLengths.length))
                    .reduce((a, b) => a + b) /
                cycleLengths.length,
          );
    return CycleHistoryStats(
      cycleLengths: List.unmodifiable(cycleLengths),
      periodLengths: List.unmodifiable(periodLengths),
      medianCycleLength: cycleLengths.isEmpty ? null : _median(cycleLengths),
      medianPeriodLength: periodLengths.isEmpty ? null : _median(periodLengths),
      cycleStandardDeviation: deviation,
    );
  }

  static List<CycleSymptomInsight> detectSymptomPatterns({
    required List<PeriodEntry> periods,
    required List<CycleDailyLog> logs,
    int typicalCycleLength = 28,
  }) {
    if (periods.isEmpty || logs.length < 2) return const [];

    final sortedStarts = periods.map((p) => dateOnly(p.startDay)).toSet().toList()..sort();
    if (sortedStarts.isEmpty) return const [];

    // Map each log day to a cycle phase
    final phaseCounts = <String, Map<String, int>>{};

    for (final log in logs) {
      final logDay = dateOnly(log.day);
      // Find the last period start on or before logDay
      final priorStarts = sortedStarts.where((s) => s.isBefore(logDay) || s.isAtSameMomentAs(logDay)).toList();
      if (priorStarts.isEmpty) continue;
      final cycleStart = priorStarts.last;
      final dayInCycle = logDay.difference(cycleStart).inDays + 1;
      if (dayInCycle > 45) continue; // Out of normal cycle

      final String phase;
      if (dayInCycle <= 5) {
        phase = 'Menstruationsphase';
      } else if (dayInCycle <= 13) {
        phase = 'Follikelphase';
      } else if (dayInCycle <= 16) {
        phase = 'Ovulationsphase';
      } else {
        phase = 'Lutealphase';
      }

      phaseCounts.putIfAbsent(phase, () => {});

      if (log.pain != null && log.pain! >= 4) {
        phaseCounts[phase]!['Schmerzen'] = (phaseCounts[phase]!['Schmerzen'] ?? 0) + 1;
      }
      if (log.mood != null && (log.mood == 'angespannt' || log.mood == 'traurig')) {
        phaseCounts[phase]![log.mood!] = (phaseCounts[phase]![log.mood!] ?? 0) + 1;
      }
      if (log.energy != null && log.energy! <= 2) {
        phaseCounts[phase]!['Niedrige Energie'] = (phaseCounts[phase]!['Niedrige Energie'] ?? 0) + 1;
      }
      if (log.sleepQuality != null && log.sleepQuality! <= 2) {
        phaseCounts[phase]!['Schlechter Schlaf'] = (phaseCounts[phase]!['Schlechter Schlaf'] ?? 0) + 1;
      }
      for (final tag in log.tags) {
        phaseCounts[phase]![tag] = (phaseCounts[phase]![tag] ?? 0) + 1;
      }
    }

    final insights = <CycleSymptomInsight>[];
    for (final entry in phaseCounts.entries) {
      final phase = entry.key;
      for (final symptom in entry.value.entries) {
        if (symptom.value >= 2) {
          insights.add(
            CycleSymptomInsight(
              phaseName: phase,
              symptomName: symptom.key,
              occurrenceCount: symptom.value,
              explanation:
                  'Für die $phase ist markiert, dass du in früheren Zyklen häufiger ${symptom.key} protokolliert hast (basierend auf ${symptom.value} Einträgen).',
            ),
          );
        }
      }
    }

    return insights;
  }

  static List<int> _removeOutliers(List<int> values) {
    if (values.length < 3) return values;
    final median = _median(values);
    final deviations = values.map((value) => (value - median).abs()).toList();
    final mad = _median(deviations);
    final threshold = math.max(10, mad * 3);
    final filtered =
        values.where((value) => (value - median).abs() <= threshold).toList();
    return filtered.isEmpty ? values : filtered;
  }

  static int _clamp(int value, int min, int max) =>
      value.clamp(min, max).toInt();
}
