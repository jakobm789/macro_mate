import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/gym/data/drift_gym_repository.dart';
import 'package:macro_mate/features/gym/domain/ai_coach_engine.dart';
import 'package:macro_mate/features/gym/domain/gym_models.dart';
import 'package:macro_mate/features/gym/presentation/gym_controller.dart';

void main() {
  group('AiCoachEngine 16-Sets & Lower-Body Tests', () {
    const engine = AiCoachEngine();

    for (final days in [2, 3, 4, 5]) {
      test('Split for $days days generates exactly 16 sets per routine with leg exercises', () {
        final profile = GymIntakeProfile(
          goal: 'hypertrophy',
          experience: 'intermediate',
          daysPerWeek: days,
          equipment: [
            GymEquipment.barbell,
            GymEquipment.dumbbell,
            GymEquipment.machine,
            GymEquipment.cable,
          ],
        );

        final plan = engine.generateDeterministicPlan(profile);
        expect(plan['daysPerWeek'], equals(days));

        final routines = (plan['routines'] as List<dynamic>).cast<Map<String, dynamic>>();
        expect(routines.length, equals(days));

        var foundLegExercises = false;

        for (final routine in routines) {
          final exercises = (routine['exercises'] as List<dynamic>).cast<Map<String, dynamic>>();
          final totalSets = exercises.fold<int>(0, (sum, e) => sum + (e['targetSets'] as int));

          // Every routine strictly has 16 sets
          expect(totalSets, equals(16),
              reason: 'Routine "${routine['name']}" in $days-day split must have exactly 16 sets');

          for (final ex in exercises) {
            final id = ex['exerciseId'] as String;
            if (id == 'ex_squat' ||
                id == 'ex_front_squat' ||
                id == 'ex_deadlift' ||
                id == 'ex_romanian_deadlift' ||
                id == 'ex_leg_press' ||
                id == 'ex_leg_curl_lying' ||
                id == 'ex_leg_curl_seated') {
              foundLegExercises = true;
            }
            // Check default rest time for main compounds
            if (id == 'ex_squat' || id == 'ex_bench_press' || id == 'ex_deadlift') {
              expect(ex['restSeconds'], equals(180),
                  reason: 'Compound exercise $id must have 180s (3 min) rest time');
            }
          }
        }

        expect(foundLegExercises, isTrue,
            reason: 'Plan for $days days must include leg exercises');
      });
    }

    test('buildIntakePrompt includes 16 sets, leg balance, and 180s rest instructions', () {
      final profile = GymIntakeProfile(
        goal: 'hypertrophy',
        experience: 'intermediate',
        daysPerWeek: 4,
        equipment: [GymEquipment.barbell, GymEquipment.dumbbell],
      );

      final prompt = engine.buildIntakePrompt(profile, []);
      expect(prompt.contains('16 Arbeitssätze'), isTrue);
      expect(prompt.contains('Beintraining'), isTrue);
      expect(prompt.contains('180 Sekunden (3 Minuten)'), isTrue);
    });
  });

  group('GymController Rest-Time & Manual Plan Creation Tests', () {
    late AppDatabase database;
    late DriftGymRepository repository;
    late GymController controller;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftGymRepository(database: database);
      controller = GymController(repository: repository);
      await controller.initialize();
    });

    tearDown(() async {
      controller.dispose();
      await database.close();
    });

    test('default rest time is 180 seconds (3 minutes) and can be adjusted', () {
      expect(controller.defaultRestSeconds, equals(180));

      controller.setDefaultRestSeconds(120);
      expect(controller.defaultRestSeconds, equals(120));

      controller.setDefaultRestSeconds(240);
      expect(controller.defaultRestSeconds, equals(240));
    });

    test('saveManualPlan creates and activates custom plan in database', () async {
      await controller.saveManualPlan(
        name: 'Mein Custom 3er-Split',
        description: 'Selbst erstellter Plan',
        daysPerWeek: 3,
        routinesWithExercises: [
          {
            'name': 'Tag 1: Beine & Waden',
            'dayOfWeek': 1,
            'exercises': [
              {
                'exerciseId': 'ex_squat',
                'targetSets': 4,
                'targetRepsMin': 6,
                'targetRepsMax': 8,
                'restSeconds': 180,
              },
              {
                'exerciseId': 'ex_leg_press',
                'targetSets': 4,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 180,
              },
              {
                'exerciseId': 'ex_romanian_deadlift',
                'targetSets': 4,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180,
              },
              {
                'exerciseId': 'ex_calf_raise',
                'targetSets': 4,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120,
              },
            ],
          },
        ],
        isActive: true,
      );

      expect(controller.activePlan, isNotNull);
      expect(controller.activePlan!.name, equals('Mein Custom 3er-Split'));
      expect(controller.routines.length, equals(1));
      expect(controller.routines.first.name, equals('Tag 1: Beine & Waden'));

      final exercises = controller.routineExercises[controller.routines.first.id];
      expect(exercises, isNotNull);
      expect(exercises!.length, equals(4));

      final totalSets = exercises.fold<int>(0, (sum, e) => sum + e.targetSets);
      expect(totalSets, equals(16));
    });

    test('cancelWorkout discards active workout and clears sets without saving', () async {
      await controller.startWorkout(
        routine: GymPlanRoutineRow(
          id: 'r_test',
          planId: 'p_test',
          name: 'Test Routine',
          dayOfWeek: 1,
          progressionType: 'linear',
        ),
        exercises: [],
      );

      expect(controller.isWorkoutActive, isTrue);
      controller.startRestTimer(180);
      expect(controller.isRestTimerRunning, isTrue);

      // Cancel workout without saving
      controller.cancelWorkout();

      expect(controller.isWorkoutActive, isFalse);
      expect(controller.activeSets.isEmpty, isTrue);
      expect(controller.isRestTimerRunning, isFalse);
      expect(controller.recentSessions.isEmpty, isTrue);
    });

    test('deleteWorkoutSession deletes completed workout from database', () async {
      // 1. Finish a workout
      await controller.startWorkout(
        routine: GymPlanRoutineRow(
          id: 'r_test',
          planId: 'p_test',
          name: 'Test Beine',
          dayOfWeek: 1,
          progressionType: 'linear',
        ),
        exercises: [],
      );
      final result = await controller.finishWorkout();
      expect(result, isNotNull);
      expect(controller.recentSessions.length, equals(1));

      final sessionId = controller.recentSessions.first.id;

      // 2. Delete it
      await controller.deleteWorkoutSession(sessionId);

      // 3. Verify it's gone
      expect(controller.recentSessions.isEmpty, isTrue);
      final sessionsInDb = await repository.getRecentSessions();
      expect(sessionsInDb.isEmpty, isTrue);
    });
  });
}
