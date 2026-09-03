import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/gym/data/drift_gym_repository.dart';
import 'package:macro_mate/features/gym/presentation/exercise_library_page.dart';
import 'package:macro_mate/features/gym/presentation/gym_controller.dart';
import 'package:provider/provider.dart';

void main() {
  group('ExerciseLibraryPage Tests', () {
    late AppDatabase db;
    late DriftGymRepository repo;
    late GymController controller;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = DriftGymRepository(database: db);
      await repo.ensureSeeded();
      controller = GymController(repository: repo);
      await controller.loadData();
    });

    tearDown(() async {
      controller.dispose();
      await db.close();
    });

    testWidgets('Renders exercises, filters by search, and shows details modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GymController>.value(
            value: controller,
            child: const ExerciseLibraryPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check exercise items exist
      expect(find.text('Bankdrücken (Langhantel)'), findsOneWidget);

      // Filter by search
      await tester.enterText(find.byType(TextField).first, 'Back Squat');
      await tester.pumpAndSettle();

      expect(find.text('Kniebeugen (Back Squat)'), findsOneWidget);
      expect(find.text('Bankdrücken (Langhantel)'), findsNothing);

      // Tap on exercise to open details sheet
      await tester.tap(find.text('Kniebeugen (Back Squat)'));
      await tester.pumpAndSettle();

      expect(find.text('1RM Rechner (One Rep Max)'), findsOneWidget);
      expect(find.text('Ausführungshinweise'), findsOneWidget);
    });
  });
}
