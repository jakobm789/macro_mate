enum BleedingLevel { none, spotting, light, medium, heavy }

class CycleProfile {
  const CycleProfile({
    this.typicalCycleLength = 28,
    this.typicalPeriodLength = 5,
    this.predictionsEnabled = true,
    this.healthImportEnabled = false,
    this.timezone = 'UTC',
  });

  final int typicalCycleLength;
  final int typicalPeriodLength;
  final bool predictionsEnabled;
  final bool healthImportEnabled;
  final String timezone;
}

class PeriodEntry {
  const PeriodEntry({
    required this.id,
    required this.startDay,
    this.endDay,
    this.flow,
    this.source = 'local',
  });

  final String id;
  final DateTime startDay;
  final DateTime? endDay;
  final BleedingLevel? flow;
  final String source;
}

class CycleDailyLog {
  const CycleDailyLog({
    required this.day,
    this.bleeding,
    this.mood,
    this.pain,
    this.energy,
    this.sleepQuality,
    this.notes,
    this.tags = const [],
  });

  final DateTime day;
  final BleedingLevel? bleeding;
  final String? mood;
  final int? pain;
  final int? energy;
  final int? sleepQuality;
  final String? notes;
  final List<String> tags;
}

class CyclePrediction {
  const CyclePrediction({
    required this.kind,
    required this.windowStart,
    required this.windowEnd,
    required this.confidence,
    required this.rationale,
  });

  final String kind;
  final DateTime windowStart;
  final DateTime windowEnd;
  final double confidence;
  final String rationale;
}

class CycleForecast {
  const CycleForecast({
    required this.cycleDay,
    required this.cycleLength,
    required this.periodLength,
    required this.nextPeriod,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.confidence,
    required this.rationale,
  });

  final int cycleDay;
  final int cycleLength;
  final int periodLength;
  final DateTime nextPeriod;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final double confidence;
  final String rationale;

  List<CyclePrediction> get predictions => [
        CyclePrediction(
          kind: 'period',
          windowStart: nextPeriod,
          windowEnd: nextPeriod.add(Duration(days: periodLength - 1)),
          confidence: confidence,
          rationale: rationale,
        ),
        CyclePrediction(
          kind: 'fertile_window',
          windowStart: fertileWindowStart,
          windowEnd: fertileWindowEnd,
          confidence: confidence * .85,
          rationale:
              'Ovulation rechnerisch ca. 14 Tage vor der nächsten Periode.',
        ),
      ];
}
