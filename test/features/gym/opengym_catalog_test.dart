import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/gym/data/drift_gym_repository.dart';
import 'package:macro_mate/features/gym/data/opengym_exercises.dart';
import 'package:macro_mate/features/gym/domain/gym_models.dart';

void main() {
  test('OpenGym catalog includes every source ID, instructions and no media',
      () {
    expect(openGymExercises, hasLength(1324));
    expect(openGymExercises.map((e) => e.id).toSet(), hasLength(1324));
    for (final exercise in openGymExercises) {
      expect(exercise.id, startsWith('opengym_'));
      expect(exercise.name.trim(), isNotEmpty);
      expect(exercise.instructions, isNotEmpty);
      expect(exercise.gifUrl, isNull);
      expect(exercise.isCustom, isFalse);
      expect(
          exercise.secondaryMuscles, isNot(contains(exercise.primaryMuscle)));
    }
  });

  test('Fresh install contains starter and full OpenGym catalog', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftGymRepository(database: db);
    final exercises = await repo.getAllExercises();
    expect(
        exercises.where((e) => e.id.startsWith('opengym_')), hasLength(1324));
    expect(exercises.any((e) => e.id == 'ex_bench_press'), isTrue);
    expect(await repo.searchExercises(query: '3/4 sit-up'), isNotEmpty);
  });

  test('Upgrade is idempotent and preserves custom and edited exercises',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final oldRepo = DriftGymRepository(database: db);
    await oldRepo.seedDefaultExercises();
    const custom = GymExercise(
      id: 'custom_keep',
      name: 'Meine Übung',
      primaryMuscle: GymMuscleGroup.chest,
      equipment: GymEquipment.other,
      isCustom: true,
    );
    await oldRepo.upsertExercise(custom);
    final repo = DriftGymRepository(database: db);
    await Future.wait([repo.ensureSeeded(), repo.ensureSeeded()]);
    final firstId = openGymExercises.first.id;
    await repo.upsertExercise(GymExercise(
      id: firstId,
      name: 'Meine angepasste Anleitung',
      primaryMuscle: GymMuscleGroup.abs,
      equipment: GymEquipment.bodyweight,
      instructions: 'Unverändert behalten',
    ));
    final reopened = DriftGymRepository(database: db);
    final exercises = await reopened.getAllExercises();
    expect(
        exercises.where((e) => e.id.startsWith('opengym_')), hasLength(1324));
    expect((await reopened.getExerciseById('custom_keep'))!.isCustom, isTrue);
    expect((await reopened.getExerciseById(firstId))!.instructions,
        'Unverändert behalten');
    expect(exercises.any((e) => e.id == 'ex_bench_press'), isTrue);
  });
}
