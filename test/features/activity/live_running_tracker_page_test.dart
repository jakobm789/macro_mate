import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/activity/domain/location_tracker_service.dart';
import 'package:macro_mate/features/activity/presentation/live_running_tracker_page.dart';
import 'package:macro_mate/features/activity/presentation/running_tracker_controller.dart';
import 'package:provider/provider.dart';

void main() {
  group('LiveRunningTrackerPage Widget Tests', () {
    late AppDatabase db;
    late RunningTrackerController controller;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      controller = RunningTrackerController();
    });

    tearDown(() async {
      controller.dispose();
      await db.close();
    });

    testWidgets('Renders cockpit, sport chips, and START button in idle state',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppDatabase>.value(value: db),
            ChangeNotifierProvider<RunningTrackerController>.value(
                value: controller),
          ],
          child: const MaterialApp(
            home: LiveRunningTrackerPage(initialSport: SportType.running),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and sport options
      expect(find.text('Laufen · Tracker'), findsOneWidget);
      expect(find.text('Radfahren'), findsOneWidget);
      expect(find.text('Wandern'), findsOneWidget);

      // Check cockpit labels
      expect(find.text('Distanz'), findsOneWidget);
      expect(find.text('Zeit'), findsOneWidget);
      expect(find.text('Kalorien'), findsOneWidget);
      expect(find.text('START (Laufen)'), findsOneWidget);

      // Tap on Radfahren chip
      await tester.tap(find.text('Radfahren'));
      await tester.pumpAndSettle();

      expect(find.text('Radfahren · Tracker'), findsOneWidget);
      expect(find.text('START (Radfahren)'), findsOneWidget);
    });
  });
}
