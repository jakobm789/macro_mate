import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/gym_models.dart';
import '../domain/progression_engine.dart';

class WorkoutSessionSaveResult {
  const WorkoutSessionSaveResult({
    required this.sessionId,
    required this.totalTonnageKg,
    required this.durationSeconds,
    required this.newPrs,
  });

  final String sessionId;
  final double totalTonnageKg;
  final double durationSeconds;
  final List<OneRepMaxEstimate> newPrs;
}

class DriftGymRepository {
  DriftGymRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;
  static const _uuid = Uuid();
  static const _oneRepMaxCalc = OneRepMaxCalculator();

  /// Ensures starter exercises are seeded if table is empty
  Future<void> ensureSeeded() async {
    final count = await _db.gymExercises.count().getSingle();
    if (count == 0) {
      await seedDefaultExercises();
    }
  }

  Future<List<GymExercise>> getAllExercises() async {
    await ensureSeeded();
    final rows = await (_db.select(_db.gymExercises)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(_mapExerciseRowToDomain).toList();
  }

  Future<List<GymExercise>> searchExercises({
    String? query,
    GymMuscleGroup? muscle,
    GymEquipment? equipment,
  }) async {
    await ensureSeeded();
    var select = _db.select(_db.gymExercises);

    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim().toLowerCase()}%';
      select = select..where((t) => t.name.lower().like(q));
    }
    if (muscle != null) {
      select = select..where((t) => t.primaryMuscle.equals(muscle.name));
    }
    if (equipment != null) {
      select = select..where((t) => t.equipment.equals(equipment.name));
    }

    select = select..orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await select.get();
    return rows.map(_mapExerciseRowToDomain).toList();
  }

  Future<GymExercise?> getExerciseById(String id) async {
    final row = await (_db.select(_db.gymExercises)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapExerciseRowToDomain(row);
  }

  Future<void> upsertExercise(GymExercise exercise) async {
    await _db.into(_db.gymExercises).insertOnConflictUpdate(
          GymExercisesCompanion.insert(
            id: exercise.id,
            name: exercise.name,
            primaryMuscle: exercise.primaryMuscle.name,
            secondaryMusclesJson: Value(
              jsonEncode(exercise.secondaryMuscles.map((m) => m.name).toList()),
            ),
            equipment: exercise.equipment.name,
            instructions: Value(exercise.instructions),
            gifUrl: Value(exercise.gifUrl),
            isCustom: Value(exercise.isCustom),
            isTimed: Value(exercise.isTimed),
          ),
        );
  }

  Future<void> deleteExercise(String id) async {
    await (_db.delete(_db.gymExercises)..where((t) => t.id.equals(id))).go();
  }

  /// Seed initial comprehensive exercise dataset (50+ exercises covering all muscles)
  Future<void> seedDefaultExercises() async {
    final starterExercises = [
      // --- BRUST / CHEST ---
      const GymExercise(
        id: 'ex_bench_press',
        name: 'Bankdrücken (Langhantel)',
        primaryMuscle: GymMuscleGroup.chest,
        secondaryMuscles: [GymMuscleGroup.triceps, GymMuscleGroup.shoulders],
        equipment: GymEquipment.barbell,
        instructions: 'Flach auf die Bank legen, Schulterblätter zusammenziehen, Stange schulterbreit greifen und kontrolliert zur Mitte der Brust führen, dann kraftvoll hochdrücken.',
      ),
      const GymExercise(
        id: 'ex_incline_db_press',
        name: 'Schrägbankdrücken (Kurzhanteln)',
        primaryMuscle: GymMuscleGroup.chest,
        secondaryMuscles: [GymMuscleGroup.shoulders, GymMuscleGroup.triceps],
        equipment: GymEquipment.dumbbell,
        instructions: 'Bank auf 30° einstellen. Hanteln auf Brusthöhe absenken, Dehnung der oberen Brust spüren und explosiv nach oben führen.',
      ),
      const GymExercise(
        id: 'ex_incline_barbell_press',
        name: 'Schrägbankdrücken (Langhantel)',
        primaryMuscle: GymMuscleGroup.chest,
        secondaryMuscles: [GymMuscleGroup.shoulders, GymMuscleGroup.triceps],
        equipment: GymEquipment.barbell,
        instructions: 'Auf die 30°-Schrägbank legen. Stange knapp unterhalb des Schlüsselbeins kontrolliert absenken.',
      ),
      const GymExercise(
        id: 'ex_chest_dips',
        name: 'Dips (Brust-Fokus)',
        primaryMuscle: GymMuscleGroup.chest,
        secondaryMuscles: [GymMuscleGroup.triceps, GymMuscleGroup.shoulders],
        equipment: GymEquipment.bodyweight,
        instructions: 'Oberkörper leicht nach vorne beugen, Ellbogen leicht nach außen zeigen lassen und kontrolliert absenken bis 90 Grad im Ellbogengelenk.',
      ),
      const GymExercise(
        id: 'ex_cable_flys',
        name: 'Kabelzug-Flys (Cable Crossover)',
        primaryMuscle: GymMuscleGroup.chest,
        secondaryMuscles: [GymMuscleGroup.shoulders],
        equipment: GymEquipment.cable,
        instructions: 'Aufrecht stehen, Kabel von oben nach unten oder mittig vor dem Körper zusammenführen und maximale Kontraktion halten.',
      ),
      const GymExercise(
        id: 'ex_db_flys',
        name: 'Kurzhantel Flys auf Flachbank',
        primaryMuscle: GymMuscleGroup.chest,
        secondaryMuscles: [GymMuscleGroup.shoulders],
        equipment: GymEquipment.dumbbell,
        instructions: 'Mit leicht gebeugten Armen die Kurzhanteln bogenförmig zur Seite senken, Brustdehnung spüren und wie bei einer Umarmung schließen.',
      ),
      const GymExercise(
        id: 'ex_pushups',
        name: 'Liegestütze',
        primaryMuscle: GymMuscleGroup.chest,
        secondaryMuscles: [GymMuscleGroup.triceps, GymMuscleGroup.abs],
        equipment: GymEquipment.bodyweight,
        instructions: 'Körper in einer stabilen Plank halten, Hände schulterbreit, Brust bis kurz vor den Boden senken.',
      ),

      // --- RÜCKEN / BACK & LATS ---
      const GymExercise(
        id: 'ex_deadlift',
        name: 'Kreuzheben (Klassisch)',
        primaryMuscle: GymMuscleGroup.back,
        secondaryMuscles: [GymMuscleGroup.hamstrings, GymMuscleGroup.glutes, GymMuscleGroup.forearms],
        equipment: GymEquipment.barbell,
        instructions: 'Füße hüftbreit unter der Hantelstange. Mit geradem Rücken, angespannter Bauch- und Latmuskulatur aus Beinen und Hüfte heben.',
      ),
      const GymExercise(
        id: 'ex_barbell_row',
        name: 'Langhantelrudern vorgebeugt',
        primaryMuscle: GymMuscleGroup.back,
        secondaryMuscles: [GymMuscleGroup.biceps, GymMuscleGroup.forearms],
        equipment: GymEquipment.barbell,
        instructions: 'Oberkörper ca. 45° nach vorne neigen, Rücken gerade, Hantelstange zur unteren Bauchregion ziehen.',
      ),
      const GymExercise(
        id: 'ex_pullup',
        name: 'Klimmzüge (Obergriff)',
        primaryMuscle: GymMuscleGroup.back,
        secondaryMuscles: [GymMuscleGroup.biceps, GymMuscleGroup.abs],
        equipment: GymEquipment.bodyweight,
        instructions: 'Etwas mehr als schulterbreit greifen. Den Körper kontrolliert nach oben ziehen, bis das Kinn über die Stange reicht.',
      ),
      const GymExercise(
        id: 'ex_chinup',
        name: 'Klimmzüge im Untergriff (Chinups)',
        primaryMuscle: GymMuscleGroup.back,
        secondaryMuscles: [GymMuscleGroup.biceps],
        equipment: GymEquipment.bodyweight,
        instructions: 'Hände im Untergriff schulterbreit. Starke Beanspruchung des Latissimus und Bizeps.',
      ),
      const GymExercise(
        id: 'ex_lat_pulldown',
        name: 'Latzug zur Brust',
        primaryMuscle: GymMuscleGroup.back,
        secondaryMuscles: [GymMuscleGroup.biceps],
        equipment: GymEquipment.cable,
        instructions: 'Breite Stange greifen, mit aufrechter Brust zur Schlüsselbeinlinie ziehen und Schulterblätter aktiv nach unten führen.',
      ),
      const GymExercise(
        id: 'ex_seated_cable_row',
        name: 'Kabelrudern sitzend',
        primaryMuscle: GymMuscleGroup.back,
        secondaryMuscles: [GymMuscleGroup.biceps],
        equipment: GymEquipment.cable,
        instructions: 'Aufrecht sitzen, V-Griff zum Bauchnabel ziehen, Brust rausdrücken und Schulterblätter am Endpunkt zusammenpressen.',
      ),
      const GymExercise(
        id: 'ex_one_arm_db_row',
        name: 'Einarmiges Kurzhantelrudern',
        primaryMuscle: GymMuscleGroup.back,
        secondaryMuscles: [GymMuscleGroup.biceps, GymMuscleGroup.forearms],
        equipment: GymEquipment.dumbbell,
        instructions: 'Ein Knie auf die Bank stützen, Hantel eng an den Rippen nach oben ziehen.',
      ),
      const GymExercise(
        id: 'ex_face_pulls',
        name: 'Face Pulls am Kabelzug',
        primaryMuscle: GymMuscleGroup.shoulders,
        secondaryMuscles: [GymMuscleGroup.trapezius, GymMuscleGroup.back],
        equipment: GymEquipment.cable,
        instructions: 'Seilgriff auf Augenhöhe ziehen, Ellbogen hoch und nach außen rotieren zur Stärkung der Rotatorenmanschette und hinteren Schulter.',
      ),

      // --- BEINE: QUADRIZEPS, HAMSTRINGS, GLUTES ---
      const GymExercise(
        id: 'ex_squat',
        name: 'Kniebeugen (Back Squat)',
        primaryMuscle: GymMuscleGroup.quadriceps,
        secondaryMuscles: [GymMuscleGroup.glutes, GymMuscleGroup.hamstrings, GymMuscleGroup.abs],
        equipment: GymEquipment.barbell,
        instructions: 'Stange auf Nacken/oberen Rücken legen. Hüfte nach hinten-unten führen bis Oberschenkel mindestens parallel zum Boden sind.',
      ),
      const GymExercise(
        id: 'ex_front_squat',
        name: 'Frontkniebeugen',
        primaryMuscle: GymMuscleGroup.quadriceps,
        secondaryMuscles: [GymMuscleGroup.abs, GymMuscleGroup.glutes],
        equipment: GymEquipment.barbell,
        instructions: 'Hantel auf den vorderen Schultern ablegen. Sehr aufrechter Oberkörper für maximalen Quadrizeps-Fokus.',
      ),
      const GymExercise(
        id: 'ex_leg_press',
        name: 'Beinpresse 45°',
        primaryMuscle: GymMuscleGroup.quadriceps,
        secondaryMuscles: [GymMuscleGroup.glutes],
        equipment: GymEquipment.machine,
        instructions: 'Füße hüftbreit auf der Plattform platzieren. Schlitten tief absenken, kontrolliert drücken ohne Knie durchzustrecken.',
      ),
      const GymExercise(
        id: 'ex_bulgarian_split_squat',
        name: 'Bulgarische Kniebeugen (Split Squat)',
        primaryMuscle: GymMuscleGroup.quadriceps,
        secondaryMuscles: [GymMuscleGroup.glutes, GymMuscleGroup.hamstrings],
        equipment: GymEquipment.dumbbell,
        instructions: 'Einen Fuß hinten auf eine Bank legen. Mit dem vorderen Bein tief einsinken und aus der Ferse hochdrücken.',
      ),
      const GymExercise(
        id: 'ex_walking_lunges',
        name: 'Ausfallschritte gehend (Lunges)',
        primaryMuscle: GymMuscleGroup.quadriceps,
        secondaryMuscles: [GymMuscleGroup.glutes],
        equipment: GymEquipment.dumbbell,
        instructions: 'Große Schritte nach vorne machen, hinteres Knie kurz über den Boden absenken.',
      ),
      const GymExercise(
        id: 'ex_leg_extension',
        name: 'Beinstrecker-Maschine',
        primaryMuscle: GymMuscleGroup.quadriceps,
        equipment: GymEquipment.machine,
        instructions: 'Im Sitzen die Beine kontrolliert strecken und oben den Quadrizeps eine Sekunde voll anspannen.',
      ),
      const GymExercise(
        id: 'ex_romanian_deadlift',
        name: 'Rumänisches Kreuzheben (RDL)',
        primaryMuscle: GymMuscleGroup.hamstrings,
        secondaryMuscles: [GymMuscleGroup.glutes, GymMuscleGroup.back],
        equipment: GymEquipment.barbell,
        instructions: 'Knie nur leicht gebeugt halten. Hüfte weit nach hinten schieben, Dehnung der hinteren Oberschenkel spüren und aus Glutes aufrichten.',
      ),
      const GymExercise(
        id: 'ex_leg_curl_lying',
        name: 'Beinbeuger liegend (Leg Curls)',
        primaryMuscle: GymMuscleGroup.hamstrings,
        equipment: GymEquipment.machine,
        instructions: 'Auf dem Bauch liegen, Fersen zum Gesäß heranziehen und Dehnungsphase kontrollieren.',
      ),
      const GymExercise(
        id: 'ex_leg_curl_seated',
        name: 'Beinbeuger sitzend',
        primaryMuscle: GymMuscleGroup.hamstrings,
        equipment: GymEquipment.machine,
        instructions: 'Im Sitzen die Unterschenkel nach unten-hinten beugen für optimale Dehnung des Beinbeugers.',
      ),
      const GymExercise(
        id: 'ex_hip_thrust',
        name: 'Hip Thrusts (Langhantel)',
        primaryMuscle: GymMuscleGroup.glutes,
        secondaryMuscles: [GymMuscleGroup.hamstrings],
        equipment: GymEquipment.barbell,
        instructions: 'Oberen Rücken an Bank anlehnen, Hantel auf Hüfte platzieren und Becken maximal zur Decke strecken.',
      ),
      const GymExercise(
        id: 'ex_calf_raise',
        name: 'Wadenheben stehend',
        primaryMuscle: GymMuscleGroup.calves,
        equipment: GymEquipment.machine,
        instructions: 'Volle Dehnung nach unten und maximale Spitzenkontraktion auf den Zehenspitzen.',
      ),
      const GymExercise(
        id: 'ex_seated_calf_raise',
        name: 'Wadenheben sitzend',
        primaryMuscle: GymMuscleGroup.calves,
        equipment: GymEquipment.machine,
        instructions: 'Fokussiert den Musculus soleus (Schollenmuskel) durch 90-Grad Kniewinkel.',
      ),

      // --- SCHULTERN / SHOULDERS & NACKEN ---
      const GymExercise(
        id: 'ex_overhead_press',
        name: 'Schulterdrücken (Military Press)',
        primaryMuscle: GymMuscleGroup.shoulders,
        secondaryMuscles: [GymMuscleGroup.triceps, GymMuscleGroup.abs],
        equipment: GymEquipment.barbell,
        instructions: 'Im aufrechten Stand Langhantel vom Schlüsselbein über den Kopf nach oben drücken.',
      ),
      const GymExercise(
        id: 'ex_db_shoulder_press',
        name: 'Kurzhantel-Schulterdrücken sitzend',
        primaryMuscle: GymMuscleGroup.shoulders,
        secondaryMuscles: [GymMuscleGroup.triceps],
        equipment: GymEquipment.dumbbell,
        instructions: 'Aufrecht auf Bank sitzen, Kurzhanteln auf Schulterhöhe starten und kontrolliert nach oben drücken.',
      ),
      const GymExercise(
        id: 'ex_lateral_raise',
        name: 'Seitheben mit Kurzhanteln',
        primaryMuscle: GymMuscleGroup.shoulders,
        equipment: GymEquipment.dumbbell,
        instructions: 'Arme seitlich bis zur Schulterhöhe heben, kleine Finger leicht anheben für seitliche Deltamuskeln.',
      ),
      const GymExercise(
        id: 'ex_cable_lateral_raise',
        name: 'Kabel-Seitheben hinter dem Körper',
        primaryMuscle: GymMuscleGroup.shoulders,
        equipment: GymEquipment.cable,
        instructions: 'Kabel von unten hinter dem Rücken greifen für konstante Spannung im gesamten Bewegungsradius.',
      ),
      const GymExercise(
        id: 'ex_reverse_flys',
        name: 'Butterfly Reverse (Hintere Schulter)',
        primaryMuscle: GymMuscleGroup.shoulders,
        secondaryMuscles: [GymMuscleGroup.trapezius],
        equipment: GymEquipment.machine,
        instructions: 'Brust an das Polster drücken und Griffe weit nach außen-hinten führen.',
      ),
      const GymExercise(
        id: 'ex_shrugs',
        name: 'Shrugs (Langhantel/Kurzhantel)',
        primaryMuscle: GymMuscleGroup.trapezius,
        equipment: GymEquipment.barbell,
        instructions: 'Schultern ohne Drehung geradlinig zu den Ohren ziehen und Spitzenkontraktion 1 Sekunde halten.',
      ),

      // --- ARME: BIZEPS, TRIZEPS, UNTERARME ---
      const GymExercise(
        id: 'ex_bicep_curl_db',
        name: 'Kurzhantel Bizeps Curls',
        primaryMuscle: GymMuscleGroup.biceps,
        secondaryMuscles: [GymMuscleGroup.forearms],
        equipment: GymEquipment.dumbbell,
        instructions: 'Ellbogen an den Rippen fixieren, Hanteln kontrolliert nach oben drehen (Supination).',
      ),
      const GymExercise(
        id: 'ex_barbell_curl',
        name: 'Langhantel-Bizepscurls (SZ-Stange)',
        primaryMuscle: GymMuscleGroup.biceps,
        secondaryMuscles: [GymMuscleGroup.forearms],
        equipment: GymEquipment.barbell,
        instructions: 'Schulterbreiter Griff, Schwung vermeiden und reinen Bizepszug nutzen.',
      ),
      const GymExercise(
        id: 'ex_hammer_curls',
        name: 'Hammer Curls',
        primaryMuscle: GymMuscleGroup.biceps,
        secondaryMuscles: [GymMuscleGroup.forearms],
        equipment: GymEquipment.dumbbell,
        instructions: 'Handflächen zueinander gerichtet halten. Trainiert Brachialis und Unterarme für dickere Oberarme.',
      ),
      const GymExercise(
        id: 'ex_incline_db_curl',
        name: 'Schrägbank-Bizepscurls (Incline Curls)',
        primaryMuscle: GymMuscleGroup.biceps,
        equipment: GymEquipment.dumbbell,
        instructions: 'Auf 45°-Schrägbank sitzen für maximale Dehnung des langen Bizepskopfs.',
      ),
      const GymExercise(
        id: 'ex_tricep_pushdown',
        name: 'Trizepsdrücken am Kabelzug (Seil)',
        primaryMuscle: GymMuscleGroup.triceps,
        equipment: GymEquipment.cable,
        instructions: 'Ellbogen am Körper fixieren, Seil am tiefsten Punkt nach außen spreizen.',
      ),
      const GymExercise(
        id: 'ex_close_grip_bench_press',
        name: 'Enges Bankdrücken',
        primaryMuscle: GymMuscleGroup.triceps,
        secondaryMuscles: [GymMuscleGroup.chest, GymMuscleGroup.shoulders],
        equipment: GymEquipment.barbell,
        instructions: 'Schulterbreit greifen, Ellbogen nah am Oberkörper führen für maximale Trizepskraft.',
      ),
      const GymExercise(
        id: 'ex_skull_crushers',
        name: 'Skull Crushers (French Press)',
        primaryMuscle: GymMuscleGroup.triceps,
        equipment: GymEquipment.barbell,
        instructions: 'Auf Flachbank liegen, SZ-Stange zur Stirn absenken und nur die Unterarme beugen.',
      ),
      const GymExercise(
        id: 'ex_overhead_tricep_extension',
        name: 'Überkopf-Trizepsstrecken am Kabel',
        primaryMuscle: GymMuscleGroup.triceps,
        equipment: GymEquipment.cable,
        instructions: 'Seil über den Kopf nach vorne-oben strecken für den langen Trizepskopf.',
      ),

      // --- BAUCH & CORE ---
      const GymExercise(
        id: 'ex_plank',
        name: 'Unterarmstütz (Plank)',
        primaryMuscle: GymMuscleGroup.abs,
        secondaryMuscles: [GymMuscleGroup.shoulders, GymMuscleGroup.glutes],
        equipment: GymEquipment.bodyweight,
        instructions: 'Körper in einer geraden Linie stabilisieren. Bauch, Gesäß und Beine fest anspannen.',
        isTimed: true,
      ),
      const GymExercise(
        id: 'ex_hanging_leg_raise',
        name: 'Beinheben hängend',
        primaryMuscle: GymMuscleGroup.abs,
        equipment: GymEquipment.bodyweight,
        instructions: 'An Stange hängen und gestreckte Beine oder Knie kontrolliert zur Brust ziehen ohne zu schwingen.',
      ),
      const GymExercise(
        id: 'ex_cable_crunches',
        name: 'Kabel-Crunches kniend',
        primaryMuscle: GymMuscleGroup.abs,
        equipment: GymEquipment.cable,
        instructions: 'Vor dem Seilzug knien, Seil an die Schläfen halten und den Rumpf einrollen.',
      ),
      const GymExercise(
        id: 'ex_ab_wheel_rollout',
        name: 'Ab-Wheel Rollout',
        primaryMuscle: GymMuscleGroup.abs,
        secondaryMuscles: [GymMuscleGroup.back, GymMuscleGroup.shoulders],
        equipment: GymEquipment.other,
        instructions: 'Auf den Knien mit dem Rollrad so weit wie möglich nach vorne rollen und aus dem Bauch zurückziehen.',
      ),
    ];

    for (final ex in starterExercises) {
      await upsertExercise(ex);
    }
  }

  // --- PLANS & ROUTINES ---

  Future<GymWorkoutPlanRow?> getActivePlan() async {
    return (_db.select(_db.gymWorkoutPlans)
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<GymWorkoutPlanRow>> getAllPlans() async {
    return (_db.select(_db.gymWorkoutPlans)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtUtc)]))
        .get();
  }

  Future<List<GymPlanRoutineRow>> getRoutinesForPlan(String planId) async {
    return (_db.select(_db.gymPlanRoutines)
          ..where((t) => t.planId.equals(planId))
          ..orderBy([(t) => OrderingTerm.asc(t.dayOfWeek)]))
        .get();
  }

  Future<List<GymPlanRoutineExerciseRow>> getExercisesForRoutine(String routineId) async {
    return (_db.select(_db.gymPlanRoutineExercises)
          ..where((t) => t.routineId.equals(routineId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  Future<void> saveWorkoutPlan({
    required String planId,
    required String name,
    String? description,
    int daysPerWeek = 3,
    bool isActive = true,
    required List<Map<String, dynamic>> routinesWithExercises,
  }) async {
    await _db.transaction(() async {
      if (isActive) {
        await (_db.update(_db.gymWorkoutPlans)
              ..where((t) => t.isActive.equals(true)))
            .write(const GymWorkoutPlansCompanion(isActive: Value(false)));
      }

      await _db.into(_db.gymWorkoutPlans).insertOnConflictUpdate(
            GymWorkoutPlansCompanion.insert(
              id: planId,
              name: name,
              description: Value(description),
              daysPerWeek: Value(daysPerWeek),
              isActive: Value(isActive),
              createdAtUtc: DateTime.now().toUtc().toIso8601String(),
            ),
          );

      await (_db.delete(_db.gymPlanRoutines)..where((t) => t.planId.equals(planId))).go();

      for (final r in routinesWithExercises) {
        final routineId = r['id'] as String? ?? _uuid.v4();
        await _db.into(_db.gymPlanRoutines).insert(
              GymPlanRoutinesCompanion.insert(
                id: routineId,
                planId: planId,
                dayOfWeek: r['dayOfWeek'] as int? ?? 1,
                name: r['name'] as String,
                progressionType: Value(r['progressionType'] as String? ?? 'linear'),
              ),
            );

        final exercises = (r['exercises'] as List<dynamic>?) ?? [];
        for (var i = 0; i < exercises.length; i++) {
          final e = exercises[i] as Map<String, dynamic>;
          await _db.into(_db.gymPlanRoutineExercises).insert(
                GymPlanRoutineExercisesCompanion.insert(
                  id: _uuid.v4(),
                  routineId: routineId,
                  exerciseId: e['exerciseId'] as String,
                  orderIndex: i,
                  targetSets: Value(e['targetSets'] as int? ?? 3),
                  targetRepsMin: Value(e['targetRepsMin'] as int? ?? 8),
                  targetRepsMax: Value(e['targetRepsMax'] as int? ?? 12),
                  targetHoldSeconds: Value(e['targetHoldSeconds'] as int?),
                  restSeconds: Value(e['restSeconds'] as int? ?? 90),
                  supersetGroupId: Value(e['supersetGroupId'] as String?),
                  notes: Value(e['notes'] as String?),
                ),
              );
        }
      }
    });
  }

  // --- SESSIONS, 1RM TRACKING & LOGGING ---

  Future<WorkoutSessionSaveResult> saveWorkoutSession({
    required String sessionId,
    String? routineId,
    required String routineName,
    required DateTime startUtc,
    DateTime? endUtc,
    required double durationSeconds,
    String? notes,
    double? rpeAverage,
    required List<GymSetLog> sets,
  }) async {
    final newPrs = <OneRepMaxEstimate>[];

    await _db.transaction(() async {
      double totalTonnage = 0.0;
      for (final s in sets) {
        if (s.completed && s.setType != GymSetType.warmup && s.reps != null && s.reps! > 0) {
          totalTonnage += s.weightKg * s.reps!;
        }
      }

      await _db.into(_db.gymWorkoutSessions).insertOnConflictUpdate(
            GymWorkoutSessionsCompanion.insert(
              id: sessionId,
              routineId: Value(routineId),
              routineName: routineName,
              startUtc: startUtc.toIso8601String(),
              endUtc: Value(endUtc?.toIso8601String()),
              durationSeconds: Value(durationSeconds),
              totalTonnageKg: Value(totalTonnage),
              notes: Value(notes),
              rpeAverage: Value(rpeAverage),
            ),
          );

      await (_db.delete(_db.gymSetLogs)..where((t) => t.sessionId.equals(sessionId))).go();

      final nowIso = DateTime.now().toUtc().toIso8601String();
      for (final s in sets) {
        await _db.into(_db.gymSetLogs).insert(
              GymSetLogsCompanion.insert(
                id: s.id.isEmpty ? _uuid.v4() : s.id,
                sessionId: sessionId,
                exerciseId: s.exerciseId,
                setIndex: s.setIndex,
                setType: Value(s.setType.name),
                weightKg: Value(s.weightKg),
                reps: Value(s.reps),
                holdSeconds: Value(s.holdSeconds),
                rpe: Value(s.rpe),
                rir: Value(s.rir),
                completed: Value(s.completed),
                loggedAtUtc: nowIso,
              ),
            );
      }

      // Check 1RM records for all exercises in this workout
      final exercisesDone = sets.map((s) => s.exerciseId).toSet();
      for (final exId in exercisesDone) {
        final exSets = sets.where((s) => s.exerciseId == exId).toList();
        final bestToday = _oneRepMaxCalc.findBest1Rm(exSets);

        if (bestToday != null) {
          final previousBest = await (_db.select(_db.gym1RmHistories)
                ..where((t) => t.exerciseId.equals(exId))
                ..orderBy([(t) => OrderingTerm.desc(t.calculated1Rm)])
                ..limit(1))
              .getSingleOrNull();

          if (previousBest == null || bestToday.estimated1Rm > previousBest.calculated1Rm) {
            newPrs.add(bestToday);
            await _db.into(_db.gym1RmHistories).insert(
                  Gym1RmHistoriesCompanion.insert(
                    id: _uuid.v4(),
                    exerciseId: exId,
                    calculated1Rm: bestToday.estimated1Rm,
                    weightKg: bestToday.weightKg,
                    reps: bestToday.reps,
                    date: nowIso,
                  ),
                );
          }
        }
      }
    });

    return WorkoutSessionSaveResult(
      sessionId: sessionId,
      totalTonnageKg: sets.where((s) => s.completed && s.reps != null).fold(
            0.0,
            (sum, s) => sum + (s.weightKg * (s.reps ?? 1)),
          ),
      durationSeconds: durationSeconds,
      newPrs: newPrs,
    );
  }

  Future<List<GymWorkoutSessionRow>> getRecentSessions({int limit = 30}) async {
    return (_db.select(_db.gymWorkoutSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.startUtc)])
          ..limit(limit))
        .get();
  }

  Future<List<GymSetLogRow>> getSetsForSession(String sessionId) async {
    return (_db.select(_db.gymSetLogs)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.setIndex)]))
        .get();
  }

  Future<List<GymSetLog>> getPreviousSetsForExercise(String exerciseId) async {
    final latestSet = await (_db.select(_db.gymSetLogs)
          ..where((t) => t.exerciseId.equals(exerciseId))
          ..where((t) => t.completed.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAtUtc)])
          ..limit(1))
        .getSingleOrNull();

    if (latestSet == null) return const [];

    final rows = await (_db.select(_db.gymSetLogs)
          ..where((t) => t.sessionId.equals(latestSet.sessionId))
          ..where((t) => t.exerciseId.equals(exerciseId))
          ..orderBy([(t) => OrderingTerm.asc(t.setIndex)]))
        .get();

    return rows
        .map((r) => GymSetLog(
              id: r.id,
              exerciseId: r.exerciseId,
              setIndex: r.setIndex,
              setType: GymSetType.values.byName(r.setType),
              weightKg: r.weightKg,
              reps: r.reps,
              holdSeconds: r.holdSeconds,
              rpe: r.rpe,
              rir: r.rir,
              completed: r.completed,
            ))
        .toList();
  }

  Future<List<Gym1RmHistoryRow>> get1RmHistory(String exerciseId) async {
    return (_db.select(_db.gym1RmHistories)
          ..where((t) => t.exerciseId.equals(exerciseId))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  // --- MUSCLE MAP & TONNAGE ANALYTICS ---

  Future<Map<GymMuscleGroup, double>> getMuscleTonnage({int days = 7}) async {
    final cutoff = DateTime.now().toUtc().subtract(Duration(days: days)).toIso8601String();

    final query = _db.select(_db.gymSetLogs).join([
      innerJoin(_db.gymExercises, _db.gymExercises.id.equalsExp(_db.gymSetLogs.exerciseId)),
    ])
      ..where(_db.gymSetLogs.completed.equals(true))
      ..where(_db.gymSetLogs.loggedAtUtc.isBiggerOrEqualValue(cutoff));

    final results = await query.get();
    final tonnageMap = <GymMuscleGroup, double>{};

    for (final r in results) {
      final setRow = r.readTable(_db.gymSetLogs);
      final exRow = r.readTable(_db.gymExercises);

      final reps = setRow.reps ?? 1;
      final setTonnage = setRow.weightKg > 0 ? (setRow.weightKg * reps) : 10.0 * reps;

      final primary = GymMuscleGroup.values.byName(exRow.primaryMuscle);
      tonnageMap[primary] = (tonnageMap[primary] ?? 0.0) + setTonnage;

      try {
        final secondaryNames = jsonDecode(exRow.secondaryMusclesJson) as List<dynamic>;
        for (final secName in secondaryNames) {
          final sec = GymMuscleGroup.values.byName(secName as String);
          tonnageMap[sec] = (tonnageMap[sec] ?? 0.0) + (setTonnage * 0.4);
        }
      } catch (_) {}
    }

    return tonnageMap;
  }

  Future<List<GymMuscleGroup>> getNeglectedMuscles({int days = 14}) async {
    final tonnage = await getMuscleTonnage(days: days);
    final allMuscles = GymMuscleGroup.values.where((m) => m != GymMuscleGroup.fullBody);
    return allMuscles.where((m) => (tonnage[m] ?? 0.0) <= 0.0).toList();
  }

  GymExercise _mapExerciseRowToDomain(GymExerciseRow row) {
    List<GymMuscleGroup> secondaries = const [];
    try {
      final list = jsonDecode(row.secondaryMusclesJson) as List<dynamic>;
      secondaries = list.map((e) => GymMuscleGroup.values.byName(e as String)).toList();
    } catch (_) {}

    return GymExercise(
      id: row.id,
      name: row.name,
      primaryMuscle: GymMuscleGroup.values.byName(row.primaryMuscle),
      secondaryMuscles: secondaries,
      equipment: GymEquipment.values.byName(row.equipment),
      instructions: row.instructions,
      gifUrl: row.gifUrl,
      isCustom: row.isCustom,
      isTimed: row.isTimed,
    );
  }
}
