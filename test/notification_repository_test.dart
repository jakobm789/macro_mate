import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/core/notifications/drift_notification_repository.dart';
import 'package:macro_mate/core/notifications/notification_models.dart';

void main() {
  late AppDatabase database;
  late DriftNotificationRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftNotificationRepository(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test('persists category, quiet window and weekday preferences', () async {
    await repository.save(
      const NotificationPreference(
        category: NotificationCategory.cycle,
        enabled: true,
        leadMinutes: 15,
        quietStart: '22:00',
        quietEnd: '07:00',
        weekdays: {1, 3, 5},
        discreteLockScreen: false,
      ),
    );
    final preference = await repository.get(NotificationCategory.cycle);
    expect(preference?.enabled, isTrue);
    expect(preference?.leadMinutes, 15);
    expect(preference?.weekdays, {1, 3, 5});
    expect(preference?.discreteLockScreen, isFalse);
  });

  test('policy handles overnight quiet windows and weekdays', () {
    const preference = NotificationPreference(
      category: NotificationCategory.meals,
      enabled: true,
      quietStart: '22:00',
      quietEnd: '07:00',
      weekdays: {1},
    );
    const policy = NotificationPolicy();
    expect(policy.isAllowed(preference, DateTime(2026, 8, 31, 23)), isFalse);
    expect(policy.isAllowed(preference, DateTime(2026, 8, 31, 6)), isFalse);
    expect(policy.isAllowed(preference, DateTime(2026, 8, 31, 12)), isTrue);
    expect(policy.isAllowed(preference, DateTime(2026, 9, 1, 12)), isFalse);
  });
}
