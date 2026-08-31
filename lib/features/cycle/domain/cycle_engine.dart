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
    final intervals = <int>[];
    for (var index = 1; index < starts.length; index++) {
      final days = starts[index].difference(starts[index - 1]).inDays;
      if (days >= 14 && days <= 90) intervals.add(days);
    }
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

  static int _clamp(int value, int min, int max) =>
      value.clamp(min, max).toInt();
}
