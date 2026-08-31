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

  Map<String, dynamic> toMap() => {
        'typicalCycleLength': typicalCycleLength,
        'typicalPeriodLength': typicalPeriodLength,
        'predictionsEnabled': predictionsEnabled,
        'healthImportEnabled': healthImportEnabled,
        'timezone': timezone,
      };

  factory CycleProfile.fromMap(Map<String, dynamic> map) => CycleProfile(
        typicalCycleLength:
            (map['typicalCycleLength'] as num?)?.toInt() ?? 28,
        typicalPeriodLength:
            (map['typicalPeriodLength'] as num?)?.toInt() ?? 5,
        predictionsEnabled: map['predictionsEnabled'] != false,
        healthImportEnabled: map['healthImportEnabled'] == true,
        timezone: map['timezone'] as String? ?? 'UTC',
      );
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'startDay': startDay.toIso8601String(),
        'endDay': endDay?.toIso8601String(),
        'flow': flow?.name,
        'source': source,
      };

  factory PeriodEntry.fromMap(Map<String, dynamic> map) => PeriodEntry(
        id: map['id'] as String,
        startDay: DateTime.parse(map['startDay'] as String),
        endDay: map['endDay'] != null
            ? DateTime.tryParse(map['endDay'] as String)
            : null,
        flow: map['flow'] != null
            ? BleedingLevel.values.firstWhere(
                (b) => b.name == map['flow'],
                orElse: () => BleedingLevel.medium,
              )
            : null,
        source: map['source'] as String? ?? 'local',
      );
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

  Map<String, dynamic> toMap() => {
        'day': day.toIso8601String(),
        'bleeding': bleeding?.name,
        'mood': mood,
        'pain': pain,
        'energy': energy,
        'sleepQuality': sleepQuality,
        'notes': notes,
        'tags': tags,
      };

  factory CycleDailyLog.fromMap(Map<String, dynamic> map) => CycleDailyLog(
        day: DateTime.parse(map['day'] as String),
        bleeding: map['bleeding'] != null
            ? BleedingLevel.values.firstWhere(
                (b) => b.name == map['bleeding'],
                orElse: () => BleedingLevel.none,
              )
            : null,
        mood: map['mood'] as String?,
        pain: (map['pain'] as num?)?.toInt(),
        energy: (map['energy'] as num?)?.toInt(),
        sleepQuality: (map['sleepQuality'] as num?)?.toInt(),
        notes: map['notes'] as String?,
        tags: (map['tags'] as List?)?.map((t) => t.toString()).toList() ??
            const [],
      );
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

class CycleHistoryStats {
  const CycleHistoryStats({
    required this.cycleLengths,
    required this.periodLengths,
    required this.medianCycleLength,
    required this.medianPeriodLength,
    required this.cycleStandardDeviation,
  });

  final List<int> cycleLengths;
  final List<int> periodLengths;
  final int? medianCycleLength;
  final int? medianPeriodLength;
  final double? cycleStandardDeviation;

  bool get hasEnoughData => cycleLengths.length >= 2;
}

class CycleSymptomInsight {
  const CycleSymptomInsight({
    required this.phaseName,
    required this.symptomName,
    required this.occurrenceCount,
    required this.explanation,
  });

  final String phaseName;
  final String symptomName;
  final int occurrenceCount;
  final String explanation;
}

class HealthMenstruationRecord {
  const HealthMenstruationRecord({
    required this.id,
    required this.startDay,
    this.endDay,
    this.flow,
    this.sourceName = 'Health Connect',
    this.isImported = false,
  });

  final String id;
  final DateTime startDay;
  final DateTime? endDay;
  final BleedingLevel? flow;
  final String sourceName;
  final bool isImported;

  Map<String, dynamic> toMap() => {
        'id': id,
        'startDay': startDay.toIso8601String(),
        'endDay': endDay?.toIso8601String(),
        'flow': flow?.name,
        'sourceName': sourceName,
        'isImported': isImported,
      };

  factory HealthMenstruationRecord.fromMap(Map<String, dynamic> map) =>
      HealthMenstruationRecord(
        id: map['id'] as String,
        startDay: DateTime.parse(map['startDay'] as String),
        endDay: map['endDay'] != null
            ? DateTime.tryParse(map['endDay'] as String)
            : null,
        flow: map['flow'] != null
            ? BleedingLevel.values.firstWhere(
                (b) => b.name == map['flow'],
                orElse: () => BleedingLevel.medium,
              )
            : null,
        sourceName: map['sourceName'] as String? ?? 'Health Connect',
        isImported: map['isImported'] == true,
      );
}

enum MenstruationConflictType {
  none,
  exactDuplicate,
  overlap,
  contains,
}

enum MenstruationConflictResolution {
  keepLocal,
  acceptImported,
  merge,
  skip,
}

class CycleConflictItem {
  CycleConflictItem({
    required this.importedRecord,
    this.conflictingLocalPeriod,
    this.conflictType = MenstruationConflictType.none,
    this.chosenResolution = MenstruationConflictResolution.acceptImported,
  });

  final HealthMenstruationRecord importedRecord;
  final PeriodEntry? conflictingLocalPeriod;
  final MenstruationConflictType conflictType;
  MenstruationConflictResolution chosenResolution;
}

