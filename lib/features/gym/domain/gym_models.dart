enum GymMuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  quadriceps,
  hamstrings,
  glutes,
  calves,
  abs,
  forearms,
  trapezius,
  fullBody,
}

extension GymMuscleGroupX on GymMuscleGroup {
  String get displayName => switch (this) {
        GymMuscleGroup.chest => 'Brust',
        GymMuscleGroup.back => 'Rücken',
        GymMuscleGroup.shoulders => 'Schultern',
        GymMuscleGroup.biceps => 'Bizeps',
        GymMuscleGroup.triceps => 'Trizeps',
        GymMuscleGroup.quadriceps => 'Quadrizeps',
        GymMuscleGroup.hamstrings => 'Beinbeuger',
        GymMuscleGroup.glutes => 'Gesäß',
        GymMuscleGroup.calves => 'Waden',
        GymMuscleGroup.abs => 'Bauch',
        GymMuscleGroup.forearms => 'Unterarme',
        GymMuscleGroup.trapezius => 'Nacken',
        GymMuscleGroup.fullBody => 'Ganzkörper',
      };
}

enum GymEquipment {
  barbell,
  dumbbell,
  cable,
  machine,
  bodyweight,
  kettlebell,
  resistanceBand,
  other,
}

extension GymEquipmentX on GymEquipment {
  String get displayName => switch (this) {
        GymEquipment.barbell => 'Langhantel',
        GymEquipment.dumbbell => 'Kurzhantel',
        GymEquipment.cable => 'Kabelzug',
        GymEquipment.machine => 'Maschine',
        GymEquipment.bodyweight => 'Körpergewicht',
        GymEquipment.kettlebell => 'Kettlebell',
        GymEquipment.resistanceBand => 'Widerstandsband',
        GymEquipment.other => 'Sonstiges',
      };
}

enum GymSetType {
  warmup,
  normal,
  drop,
  failure,
}

extension GymSetTypeX on GymSetType {
  String get shortLabel => switch (this) {
        GymSetType.warmup => 'W',
        GymSetType.normal => '',
        GymSetType.drop => 'D',
        GymSetType.failure => 'F',
      };
}

class GymExercise {
  const GymExercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.equipment,
    this.instructions,
    this.gifUrl,
    this.isCustom = false,
    this.isTimed = false,
  });

  final String id;
  final String name;
  final GymMuscleGroup primaryMuscle;
  final List<GymMuscleGroup> secondaryMuscles;
  final GymEquipment equipment;
  final String? instructions;
  final String? gifUrl;
  final bool isCustom;
  final bool isTimed;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'primaryMuscle': primaryMuscle.name,
        'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
        'equipment': equipment.name,
        'instructions': instructions,
        'gifUrl': gifUrl,
        'isCustom': isCustom,
        'isTimed': isTimed,
      };

  factory GymExercise.fromJson(Map<String, dynamic> json) => GymExercise(
        id: json['id'] as String,
        name: json['name'] as String,
        primaryMuscle: GymMuscleGroup.values.byName(
          json['primaryMuscle'] as String? ?? 'fullBody',
        ),
        secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
                ?.map((e) => GymMuscleGroup.values.byName(e as String))
                .toList() ??
            const [],
        equipment: GymEquipment.values.byName(
          json['equipment'] as String? ?? 'other',
        ),
        instructions: json['instructions'] as String?,
        gifUrl: json['gifUrl'] as String?,
        isCustom: json['isCustom'] as bool? ?? false,
        isTimed: json['isTimed'] as bool? ?? false,
      );
}

class GymSetLog {
  const GymSetLog({
    required this.id,
    required this.exerciseId,
    required this.setIndex,
    this.setType = GymSetType.normal,
    this.weightKg = 0.0,
    this.reps,
    this.holdSeconds,
    this.rpe,
    this.rir,
    this.completed = false,
  });

  final String id;
  final String exerciseId;
  final int setIndex;
  final GymSetType setType;
  final double weightKg;
  final int? reps;
  final int? holdSeconds;
  final double? rpe;
  final int? rir;
  final bool completed;

  GymSetLog copyWith({
    String? id,
    String? exerciseId,
    int? setIndex,
    GymSetType? setType,
    double? weightKg,
    int? reps,
    int? holdSeconds,
    double? rpe,
    int? rir,
    bool? completed,
  }) =>
      GymSetLog(
        id: id ?? this.id,
        exerciseId: exerciseId ?? this.exerciseId,
        setIndex: setIndex ?? this.setIndex,
        setType: setType ?? this.setType,
        weightKg: weightKg ?? this.weightKg,
        reps: reps ?? this.reps,
        holdSeconds: holdSeconds ?? this.holdSeconds,
        rpe: rpe ?? this.rpe,
        rir: rir ?? this.rir,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseId': exerciseId,
        'setIndex': setIndex,
        'setType': setType.name,
        'weightKg': weightKg,
        'reps': reps,
        'holdSeconds': holdSeconds,
        'rpe': rpe,
        'rir': rir,
        'completed': completed,
      };

  factory GymSetLog.fromJson(Map<String, dynamic> json) => GymSetLog(
        id: json['id'] as String,
        exerciseId: json['exerciseId'] as String,
        setIndex: json['setIndex'] as int,
        setType: GymSetType.values.byName(
          json['setType'] as String? ?? 'normal',
        ),
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
        reps: json['reps'] as int?,
        holdSeconds: json['holdSeconds'] as int?,
        rpe: (json['rpe'] as num?)?.toDouble(),
        rir: json['rir'] as int?,
        completed: json['completed'] as bool? ?? false,
      );
}

enum ProgressionType {
  linear,
  greyskull,
  doubleProgression,
  timed,
}

class ProgressionRule {
  const ProgressionRule({
    this.type = ProgressionType.linear,
    this.weightIncrementKg = 2.5,
    this.targetSets = 3,
    this.targetReps = 5,
    this.targetRepsMax = 8,
    this.targetHoldSeconds = 60,
    this.consecutiveStalls = 0,
    this.deloadPercentage = 10.0,
  });

  final ProgressionType type;
  final double weightIncrementKg;
  final int targetSets;
  final int targetReps;
  final int targetRepsMax;
  final int targetHoldSeconds;
  final int consecutiveStalls;
  final double deloadPercentage;

  ProgressionRule copyWith({
    ProgressionType? type,
    double? weightIncrementKg,
    int? targetSets,
    int? targetReps,
    int? targetRepsMax,
    int? targetHoldSeconds,
    int? consecutiveStalls,
    double? deloadPercentage,
  }) =>
      ProgressionRule(
        type: type ?? this.type,
        weightIncrementKg: weightIncrementKg ?? this.weightIncrementKg,
        targetSets: targetSets ?? this.targetSets,
        targetReps: targetReps ?? this.targetReps,
        targetRepsMax: targetRepsMax ?? this.targetRepsMax,
        targetHoldSeconds: targetHoldSeconds ?? this.targetHoldSeconds,
        consecutiveStalls: consecutiveStalls ?? this.consecutiveStalls,
        deloadPercentage: deloadPercentage ?? this.deloadPercentage,
      );
}

class ProgressionResult {
  const ProgressionResult({
    required this.nextWeightKg,
    required this.nextTargetReps,
    this.nextTargetHoldSeconds,
    required this.nextConsecutiveStalls,
    required this.reason,
    this.isDeload = false,
  });

  final double nextWeightKg;
  final int nextTargetReps;
  final int? nextTargetHoldSeconds;
  final int nextConsecutiveStalls;
  final String reason;
  final bool isDeload;
}

enum OneRepMaxFormula {
  brzycki,
  epley,
  average,
}

class OneRepMaxEstimate {
  const OneRepMaxEstimate({
    required this.weightKg,
    required this.reps,
    required this.estimated1Rm,
    required this.formula,
    required this.eligible,
  });

  final double weightKg;
  final int reps;
  final double estimated1Rm;
  final OneRepMaxFormula formula;
  final bool eligible;
}
