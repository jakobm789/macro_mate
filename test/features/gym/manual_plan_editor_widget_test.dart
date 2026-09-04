import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/gym/data/drift_gym_repository.dart';
import 'package:macro_mate/features/gym/presentation/gym_controller.dart';
import 'package:macro_mate/features/gym/presentation/gym_page.dart';
import 'package:macro_mate/features/gym/presentation/manual_plan_editor_page.dart';
import 'package:macro_mate/features/gym/presentation/workout_runner_page.dart';
import 'package:provider/provider.dart';

void main() {
  group('ManualPlanEditorPage Widget Tests', () {
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

    Widget createWidget(Widget child) {
      return MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: database),
          ChangeNotifierProvider<GymController>.value(value: controller),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('ManualPlanEditorPage renders form and default routines', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidget(const ManualPlanEditorPage()));
      await tester.pumpAndSettle();

      expect(find.text('Neuer Trainingsplan'), findsOneWidget);
      expect(find.text('Name des Plans *'), findsOneWidget);
      expect(find.text('Tage pro Woche: 3'), findsOneWidget);
      expect(find.text('Einheiten / Tage (3)'), findsOneWidget);
      expect(find.text('Einheit hinzufügen'), findsOneWidget);
      expect(find.text('Speichern'), findsOneWidget);

      // Tap 'Einheit hinzufügen'
      await tester.tap(find.text('Einheit hinzufügen'));
      await tester.pumpAndSettle();

      expect(find.text('Einheiten / Tage (4)'), findsOneWidget);
    });

    testWidgets(
      'GymPage displays all routines of active plan and Plan erstellen button',
      (tester) async {
        // Save an active plan with 3 routines
        await controller.saveManualPlan(
          name: 'Mein Testplan',
          daysPerWeek: 3,
          routinesWithExercises: [
            {
              'name': 'Tag 1: Push',
              'dayOfWeek': 1,
              'exercises': [
                {
                  'exerciseId': 'ex_bench_press',
                  'targetSets': 4,
                  'targetRepsMin': 8,
                  'targetRepsMax': 10,
                  'restSeconds': 180,
                },
              ],
            },
            {
              'name': 'Tag 2: Pull',
              'dayOfWeek': 3,
              'exercises': [
                {
                  'exerciseId': 'ex_deadlift',
                  'targetSets': 4,
                  'targetRepsMin': 5,
                  'targetRepsMax': 5,
                  'restSeconds': 180,
                },
              ],
            },
            {
              'name': 'Tag 3: Legs (Beine)',
              'dayOfWeek': 5,
              'exercises': [
                {
                  'exerciseId': 'ex_squat',
                  'targetSets': 4,
                  'targetRepsMin': 6,
                  'targetRepsMax': 8,
                  'restSeconds': 180,
                },
              ],
            },
          ],
          isActive: true,
        );

        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createWidget(const GymPage()));
        await tester.pumpAndSettle();

        expect(find.text('Mein Testplan'), findsOneWidget);
        expect(find.text('Plan erstellen'), findsOneWidget);
        expect(find.text('Einheiten des Plans (3)'), findsOneWidget);

        // All 3 routines must be visible, including Legs/Beine!
        expect(find.text('Tag 1: Push'), findsOneWidget);
        expect(find.text('Tag 2: Pull'), findsOneWidget);
        expect(find.text('Tag 3: Legs (Beine)'), findsOneWidget);

        // Tap 'Plan erstellen' opens ManualPlanEditorPage
        await tester.tap(find.text('Plan erstellen'));
        await tester.pumpAndSettle();

        expect(find.byType(ManualPlanEditorPage), findsOneWidget);
      },
    );

    testWidgets(
      'WorkoutRunnerPage allows canceling started workout without saving',
      (tester) async {
        await controller.startWorkout(
          routine: const GymPlanRoutineRow(
            id: 'r_push',
            planId: 'p_1',
            dayOfWeek: 1,
            name: 'Brust & Schultern',
            progressionType: 'linear',
          ),
          exercises: [],
        );

        await tester.pumpWidget(createWidget(const WorkoutRunnerPage()));
        await tester.pumpAndSettle();

        expect(find.text('Brust & Schultern'), findsOneWidget);
        expect(find.text('Abbrechen'), findsOneWidget);

        // Tap 'Abbrechen'
        await tester.tap(find.text('Abbrechen'));
        await tester.pumpAndSettle();

        expect(find.text('Training abbrechen?'), findsOneWidget);
        expect(find.text('Ja, abbrechen'), findsOneWidget);

        // Confirm cancel
        await tester.tap(find.text('Ja, abbrechen'));
        await tester.pumpAndSettle();

        expect(controller.isWorkoutActive, isFalse);
      },
    );

    testWidgets('GymPage allows deleting finished workouts', (tester) async {
      // Create and finish a workout
      await controller.startWorkout(
        routine: const GymPlanRoutineRow(
          id: 'r_push',
          planId: 'p_1',
          dayOfWeek: 1,
          name: 'Oberkörper Blast',
          progressionType: 'linear',
        ),
        exercises: [],
      );
      await controller.finishWorkout();
      expect(controller.recentSessions.length, equals(1));

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidget(const GymPage()));
      await tester.pumpAndSettle();

      expect(find.text('Oberkörper Blast'), findsOneWidget);
      final deleteBtn = find.byTooltip('Workout löschen');
      expect(deleteBtn, findsOneWidget);

      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.text('Workout löschen?'), findsOneWidget);
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();

      expect(controller.recentSessions.isEmpty, isTrue);
      expect(find.text('Oberkörper Blast'), findsNothing);
    });
  });
}
