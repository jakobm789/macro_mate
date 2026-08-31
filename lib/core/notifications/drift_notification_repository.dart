import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import 'notification_models.dart';
import 'notification_repository.dart';

class DriftNotificationRepository implements NotificationRepository {
  DriftNotificationRepository({required AppDatabase database})
      : _database = database;

  final AppDatabase _database;

  @override
  Future<List<NotificationPreference>> list() async {
    final rows = await _database.select(_database.notificationPreferences).get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<NotificationPreference?> get(NotificationCategory category) async {
    final row = await (_database.select(_database.notificationPreferences)
          ..where((table) => table.id.equals(category.name)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> save(NotificationPreference preference) async {
    final weekdays = preference.weekdays
        .where((day) => day >= 1 && day <= 7)
        .toList()
      ..sort();
    await _database
        .into(_database.notificationPreferences)
        .insertOnConflictUpdate(
          NotificationPreferencesCompanion.insert(
            id: preference.id,
            enabled: Value(preference.enabled),
            leadMinutes: Value(preference.leadMinutes.clamp(0, 24 * 60)),
            quietStart: Value(preference.quietStart),
            quietEnd: Value(preference.quietEnd),
            weekdaysJson: Value(jsonEncode(weekdays)),
            discreteLockScreen: Value(preference.discreteLockScreen),
          ),
        );
  }

  NotificationPreference _fromRow(NotificationPreferenceRow row) {
    final category = NotificationCategory.values.firstWhere(
      (item) => item.name == row.id,
      orElse: () => NotificationCategory.nutrition,
    );
    return NotificationPreference(
      category: category,
      enabled: row.enabled,
      leadMinutes: row.leadMinutes,
      quietStart: row.quietStart,
      quietEnd: row.quietEnd,
      weekdays: NotificationPreference.weekdaysFromJson(row.weekdaysJson),
      discreteLockScreen: row.discreteLockScreen,
    );
  }
}
