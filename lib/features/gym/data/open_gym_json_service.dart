import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../domain/gym_models.dart';
import 'drift_gym_repository.dart';

class OpenGymJsonService {
  const OpenGymJsonService({required DriftGymRepository repository})
      : _repository = repository;

  final DriftGymRepository _repository;
  static const _uuid = Uuid();

  /// Exports an existing plan to an OpenGym-compatible JSON string
  Future<String> exportPlanToJson(String planId) async {
    final plans = await _repository.getAllPlans();
    final plan = plans.where((p) => p.id == planId).firstOrNull;
    if (plan == null) {
      throw ArgumentError('Plan mit ID $planId wurde nicht gefunden.');
    }

    final routines = await _repository.getRoutinesForPlan(planId);
    final routinesData = <Map<String, dynamic>>[];

    for (final r in routines) {
      final exercises = await _repository.getExercisesForRoutine(r.id);
      final exercisesData = <Map<String, dynamic>>[];

      for (final e in exercises) {
        final exerciseEntity = await _repository.getExerciseById(e.exerciseId);
        exercisesData.add({
          'exerciseId': e.exerciseId,
          'exerciseName': exerciseEntity?.name ?? e.exerciseId,
          'targetSets': e.targetSets,
          'targetRepsMin': e.targetRepsMin,
          'targetRepsMax': e.targetRepsMax,
          'targetHoldSeconds': e.targetHoldSeconds,
          'restSeconds': e.restSeconds,
          'supersetGroupId': e.supersetGroupId,
          'notes': e.notes,
        });
      }

      routinesData.add({
        'id': r.id,
        'name': r.name,
        'dayOfWeek': r.dayOfWeek,
        'progressionType': r.progressionType,
        'exercises': exercisesData,
      });
    }

    final exportMap = {
      'format': 'opengym_plan_v1',
      'planId': plan.id,
      'name': plan.name,
      'description': plan.description,
      'daysPerWeek': plan.daysPerWeek,
      'exportedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'routines': routinesData,
    };

    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  /// Imports an OpenGym-compatible JSON string into the database
  Future<String> importPlanFromJson(String jsonContent) async {
    final dynamic parsed = jsonDecode(jsonContent);
    if (parsed is! Map<String, dynamic>) {
      throw const FormatException('Ungültiges OpenGym JSON-Format: Root ist keine Map.');
    }

    final name = parsed['name'] as String? ?? 'Importierter Trainingsplan';
    final description = parsed['description'] as String?;
    final daysPerWeek = (parsed['daysPerWeek'] as num?)?.toInt() ?? 3;
    final planId = (parsed['planId'] as String?)?.isNotEmpty == true
        ? parsed['planId'] as String
        : _uuid.v4();

    final routinesRaw = (parsed['routines'] as List<dynamic>?) ?? [];
    final routinesWithExercises = <Map<String, dynamic>>[];

    for (final rRaw in routinesRaw) {
      if (rRaw is! Map<String, dynamic>) continue;
      final routineId = (rRaw['id'] as String?)?.isNotEmpty == true
          ? rRaw['id'] as String
          : _uuid.v4();
      final routineName = rRaw['name'] as String? ?? 'Einheit';
      final dayOfWeek = (rRaw['dayOfWeek'] as num?)?.toInt() ?? 1;
      final progressionType = rRaw['progressionType'] as String? ?? 'linear';

      final exercisesRaw = (rRaw['exercises'] as List<dynamic>?) ?? [];
      final exercisesList = <Map<String, dynamic>>[];

      for (final eRaw in exercisesRaw) {
        if (eRaw is! Map<String, dynamic>) continue;
        final exId = eRaw['exerciseId'] as String? ?? '';
        if (exId.isEmpty) continue;

        // Ensure exercise exists or create custom placeholder
        final existing = await _repository.getExerciseById(exId);
        if (existing == null) {
          final exName = eRaw['exerciseName'] as String? ?? exId;
          await _repository.upsertExercise(
            GymExercise(
              id: exId,
              name: exName,
              primaryMuscle: GymMuscleGroup.fullBody,
              equipment: GymEquipment.other,
              isCustom: true,
            ),
          );
        }

        exercisesList.add({
          'exerciseId': exId,
          'targetSets': (eRaw['targetSets'] as num?)?.toInt() ?? 3,
          'targetRepsMin': (eRaw['targetRepsMin'] as num?)?.toInt() ?? 8,
          'targetRepsMax': (eRaw['targetRepsMax'] as num?)?.toInt() ?? 12,
          'targetHoldSeconds': (eRaw['targetHoldSeconds'] as num?)?.toInt(),
          'restSeconds': (eRaw['restSeconds'] as num?)?.toInt() ?? 90,
          'supersetGroupId': eRaw['supersetGroupId'] as String?,
          'notes': eRaw['notes'] as String?,
        });
      }

      routinesWithExercises.add({
        'id': routineId,
        'name': routineName,
        'dayOfWeek': dayOfWeek,
        'progressionType': progressionType,
        'exercises': exercisesList,
      });
    }

    await _repository.saveWorkoutPlan(
      planId: planId,
      name: name,
      description: description,
      daysPerWeek: daysPerWeek,
      isActive: true,
      routinesWithExercises: routinesWithExercises,
    );

    return planId;
  }
}
