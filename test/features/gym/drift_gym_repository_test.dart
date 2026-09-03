import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/gym/data/drift_gym_repository.dart';
import 'package:macro_mate/features/gym/domain/gym_models.dart';

void main() {
  group('DriftGymRepository Tests', () {
    late AppDatabase database;
    late DriftGymRepository repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftGymRepository(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('Seeds starter exercises and supports querying', () async {
      final exercises = await repository.getAllExercises();
      expect(exercises.length, greaterThanOrEqualTo(15));

      final chestExercises = await repository.searchExercises(
        muscle: GymMuscleGroup.chest,
      );
      expect(chestExercises, isNotEmpty);
      expect(chestExercises.any((e) => e.name.contains('Bankdrücken')), true);

      final searchResults = await repository.searchExercises(query: 'kniebeug');
      expect(searchResults.length, greaterThanOrEqualTo(1));
      expect(searchResults.any((e) => e.id == 'ex_squat'), true);
    });

    test('Saves workout plan and retrieves routines and exercises', () async {
      await repository.ensureSeeded();

      await repository.saveWorkoutPlan(
        planId: 'plan_ppl',
        name: 'Push Pull Legs 3-Day',
        daysPerWeek: 3,
        isActive: true,
        routinesWithExercises: [
          {
            'id': 'routine_push',
            'name': 'Push Tag',
            'dayOfWeek': 1,
            'progressionType': 'linear',
            'exercises': [
              {
                'exerciseId': 'ex_bench_press',
                'targetSets': 3,
                'targetRepsMin': 5,
                'targetRepsMax': 5,
                'restSeconds': 120,
              },
              {
                'exerciseId': 'ex_overhead_press',
                'targetSets': 3,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 90,
              },
            ],
          },
        ],
      );

      final activePlan = await repository.getActivePlan();
      expect(activePlan, isNotNull);
      expect(activePlan!.name, 'Push Pull Legs 3-Day');

      final routines = await repository.getRoutinesForPlan(activePlan.id);
      expect(routines.length, 1);
      expect(routines.first.name, 'Push Tag');

      final exercises = await repository.getExercisesForRoutine(routines.first.id);
      expect(exercises.length, 2);
      expect(exercises.first.exerciseId, 'ex_bench_press');
      expect(exercises.first.restSeconds, 120);
    });

    test('Logs workout session and calculates muscle tonnage & neglected muscles', () async {
      await repository.ensureSeeded();

      final now = DateTime.now().toUtc();
      const sessionId = 'session_test_1';

      await repository.saveWorkoutSession(
        sessionId: sessionId,
        routineName: 'Push Tag',
        startUtc: now.subtract(const Duration(minutes: 50)),
        endUtc: now,
        durationSeconds: 3000,
        sets: [
          const GymSetLog(
            id: 'set_1',
            exerciseId: 'ex_bench_press',
            setIndex: 1,
            weightKg: 80.0,
            reps: 5,
            completed: true,
          ),
          const GymSetLog(
            id: 'set_2',
            exerciseId: 'ex_bench_press',
            setIndex: 2,
            weightKg: 80.0,
            reps: 5,
            completed: true,
          ),
        ],
      );

      final sessions = await repository.getRecentSessions();
      expect(sessions.length, 1);
      expect(sessions.first.totalTonnageKg, 800.0); // 80kg * 5 * 2 = 800kg

      final sets = await repository.getSetsForSession(sessionId);
      expect(sets.length, 2);

      // Verify pre-fill for next workout
      final previous = await repository.getPreviousSetsForExercise('ex_bench_press');
      expect(previous.length, 2);
      expect(previous.first.weightKg, 80.0);

      // Verify muscle map tonnage
      final tonnage = await repository.getMuscleTonnage(days: 7);
      expect(tonnage[GymMuscleGroup.chest], greaterThanOrEqualTo(800.0));
      expect(tonnage[GymMuscleGroup.triceps], greaterThan(0.0)); // Secondary muscle gets credit

      // Neglected muscles should include legs, back, etc.
      final neglected = await repository.getNeglectedMuscles(days: 7);
      expect(neglected, contains(GymMuscleGroup.quadriceps));
      expect(neglected, contains(GymMuscleGroup.back));
      expect(neglected, isNot(contains(GymMuscleGroup.chest)));

      // Verify 1RM history was automatically recorded
      final oneRmHistory = await repository.get1RmHistory('ex_bench_press');
      expect(oneRmHistory, isNotEmpty);
      expect(oneRmHistory.first.weightKg, 80.0);
      expect(oneRmHistory.first.calculated1Rm, greaterThan(80.0));
    });
  });
}
