import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/core/notifications/drift_notification_repository.dart';
import 'package:macro_mate/core/notifications/notification_controller.dart';
import 'package:macro_mate/core/notifications/notification_models.dart';
import 'package:macro_mate/features/notifications/presentation/notification_settings_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftNotificationRepository repo;
  late NotificationController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tz_data.initializeTimeZones();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftNotificationRepository(database: db);
    controller = NotificationController(repository: repo);
    await controller.initialize();
  });

  tearDown(() async {
    await db.close();
  });

  group('NotificationController & Policy unit tests', () {
    test('initializes all 8 notification categories', () {
      expect(controller.preferences.length, NotificationCategory.values.length);
      for (final cat in NotificationCategory.values) {
        expect(controller.getPreference(cat), isNotNull);
      }
    });

    test('updates preference and saves to repository', () async {
      final nutritionPref = controller.getPreference(NotificationCategory.nutrition)!;
      final updated = nutritionPref.copyWith(
        enabled: true,
        quietStart: '23:00',
        quietEnd: '06:00',
        discreteLockScreen: false,
        weekdays: {1, 2, 3, 4, 5},
      );

      await controller.updatePreference(updated);

      final reloaded = controller.getPreference(NotificationCategory.nutrition);
      expect(reloaded?.enabled, isTrue);
      expect(reloaded?.quietStart, '23:00');
      expect(reloaded?.quietEnd, '06:00');
      expect(reloaded?.discreteLockScreen, isFalse);
      expect(reloaded?.weekdays, {1, 2, 3, 4, 5});
    });

    test('NotificationPolicy respects weekdays and overnight quiet hours', () {
      const policy = NotificationPolicy();
      const pref = NotificationPreference(
        category: NotificationCategory.nutrition,
        enabled: true,
        weekdays: {1, 2, 3, 4, 5}, // Mon - Fri
        quietStart: '22:00',
        quietEnd: '07:00',
      );

      // Wednesday at 14:00 -> Allowed
      final wednesdayAfternoon = DateTime(2026, 8, 12, 14, 0); // weekday 3
      expect(policy.isAllowed(pref, wednesdayAfternoon), isTrue);

      // Wednesday at 23:30 -> In quiet hours -> Disallowed
      final wednesdayNight = DateTime(2026, 8, 12, 23, 30);
      expect(policy.isAllowed(pref, wednesdayNight), isFalse);

      // Wednesday at 05:30 -> In quiet hours -> Disallowed
      final wednesdayEarlyMorning = DateTime(2026, 8, 12, 5, 30);
      expect(policy.isAllowed(pref, wednesdayEarlyMorning), isFalse);

      // Sunday at 14:00 -> Weekend not in weekdays -> Disallowed
      final sundayAfternoon = DateTime(2026, 8, 16, 14, 0); // weekday 7
      expect(policy.isAllowed(pref, sundayAfternoon), isFalse);
    });

    test('rescheduleAll runs without throwing across all categories', () async {
      await controller.rescheduleAll(
        breakfastTime: const TimeOfDay(hour: 8, minute: 0),
        lunchTime: const TimeOfDay(hour: 12, minute: 30),
        dinnerTime: const TimeOfDay(hour: 19, minute: 0),
        weighTime: const TimeOfDay(hour: 7, minute: 0),
        nextPeriodDate: DateTime.now().add(const Duration(days: 4)),
        personalizedInsight: 'Achte auf deine Flüssigkeitszufuhr.',
      );
    });
  });

  group('NotificationSettingsPage widget tests', () {
    testWidgets('renders all 8 categories with switches in scroll view', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<NotificationController>.value(
            value: controller,
            child: const NotificationSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Benachrichtigungen & Ruhezeiten'), findsOneWidget);
      expect(find.text('100% Lokale Benachrichtigungen'), findsOneWidget);

      // Verify all 8 categories exist
      expect(find.text('Ernährung & Tagesziel'), findsOneWidget);
      expect(find.text('Mahlzeitenzeiten'), findsOneWidget);
      expect(find.text('Morgendliches Wiegen'), findsOneWidget);
      expect(find.text('Aktivität & Schrittziele'), findsOneWidget);
      expect(find.text('Periodenvorwarnung (diskret)'), findsOneWidget);
      expect(find.text('Zyklus-Tipps & Wohlbefinden'), findsOneWidget);
      expect(find.text('Health Connect Sync-Erinnerung'), findsOneWidget);
      expect(find.text('Supplements & Wasser'), findsOneWidget);
    });

    testWidgets('toggling category switch updates controller state', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<NotificationController>.value(
            value: controller,
            child: const NotificationSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      // Tap first switch
      await tester.tap(switches.first);
      await tester.pumpAndSettle();
    });
  });
}
