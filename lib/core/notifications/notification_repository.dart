import 'notification_models.dart';

abstract interface class NotificationRepository {
  Future<List<NotificationPreference>> list();

  Future<NotificationPreference?> get(NotificationCategory category);

  Future<void> save(NotificationPreference preference);
}
