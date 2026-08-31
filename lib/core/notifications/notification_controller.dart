import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_models.dart';
import 'notification_repository.dart';

class NotificationController extends ChangeNotifier {
  NotificationController({
    required NotificationRepository repository,
    FlutterLocalNotificationsPlugin? plugin,
  })  : _repository = repository,
        _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final NotificationRepository _repository;
  final FlutterLocalNotificationsPlugin _plugin;
  static const _policy = NotificationPolicy();

  List<NotificationPreference> _preferences = [];
  List<NotificationPreference> get preferences =>
      List.unmodifiable(_preferences);

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    await loadPreferences();
    _isInitialized = true;
  }

  Future<void> loadPreferences() async {
    _preferences = await _repository.list();
    if (_preferences.isEmpty) {
      // Initialize defaults
      for (final cat in NotificationCategory.values) {
        final defaultPref = NotificationPreference(
          category: cat,
          enabled: cat == NotificationCategory.nutrition ||
              cat == NotificationCategory.weight,
          discreteLockScreen: true,
        );
        await _repository.save(defaultPref);
      }
      _preferences = await _repository.list();
    }
    notifyListeners();
  }

  Future<void> updatePreference(NotificationPreference preference) async {
    await _repository.save(preference);
    await loadPreferences();
    await rescheduleAll();
  }

  NotificationPreference? getPreference(NotificationCategory category) {
    return _preferences.where((p) => p.category == category).firstOrNull;
  }

  Future<void> cancelCategory(NotificationCategory category) async {
    // Android notification IDs based on category index
    final baseId = category.index * 100;
    for (int i = 0; i < 20; i++) {
      await _plugin.cancel(baseId + i);
    }
  }

  Future<void> rescheduleAll({
    TimeOfDay? breakfastTime,
    TimeOfDay? lunchTime,
    TimeOfDay? dinnerTime,
    TimeOfDay? weighTime,
    DateTime? nextPeriodDate,
    String? personalizedInsight,
  }) async {
    await _plugin.cancelAll();

    final now = DateTime.now();

    // 1. Nutrition / Meals
    final nutritionPref = getPreference(NotificationCategory.nutrition);
    if (nutritionPref != null && nutritionPref.enabled) {
      if (breakfastTime != null) {
        await _scheduleDailyTimeNotification(
          id: NotificationCategory.nutrition.index * 100 + 1,
          time: breakfastTime,
          preference: nutritionPref,
          title: 'Frühstück erfassen',
          body: 'Vergiss nicht, dein Frühstück einzutragen.',
          discreteTitle: 'Ernährungstracking',
          discreteBody: 'Zeit für deinen nächsten Eintrag.',
        );
      }
      if (lunchTime != null) {
        await _scheduleDailyTimeNotification(
          id: NotificationCategory.nutrition.index * 100 + 2,
          time: lunchTime,
          preference: nutritionPref,
          title: 'Mittagessen erfassen',
          body: 'Trage dein Mittagessen ein, um deine Makros im Blick zu behalten.',
          discreteTitle: 'Ernährungstracking',
          discreteBody: 'Zeit für deinen nächsten Eintrag.',
        );
      }
      if (dinnerTime != null) {
        await _scheduleDailyTimeNotification(
          id: NotificationCategory.nutrition.index * 100 + 3,
          time: dinnerTime,
          preference: nutritionPref,
          title: 'Abendessen erfassen',
          body: 'Trage dein Abendessen ein und schließe deinen Tag ab.',
          discreteTitle: 'Ernährungstracking',
          discreteBody: 'Zeit für deinen nächsten Eintrag.',
        );
      }
    }

    // 2. Weight
    final weightPref = getPreference(NotificationCategory.weight);
    if (weightPref != null && weightPref.enabled && weighTime != null) {
      await _scheduleDailyTimeNotification(
        id: NotificationCategory.weight.index * 100 + 1,
        time: weighTime,
        preference: weightPref,
        title: 'Gewicht wiegen',
        body: 'Zeit für dein morgendliches Wiegen.',
        discreteTitle: 'MacroMate Erinnerung',
        discreteBody: 'Tageseintrag empfohlen.',
      );
    }

    // 3. Cycle Window (advance notice)
    final cycleWindowPref = getPreference(NotificationCategory.cycleWindow);
    if (cycleWindowPref != null &&
        cycleWindowPref.enabled &&
        nextPeriodDate != null) {
      final leadDays = (cycleWindowPref.leadMinutes / (24 * 60)).round().clamp(1, 7);
      final reminderDate = nextPeriodDate.subtract(Duration(days: leadDays));
      if (reminderDate.isAfter(now)) {
        await _scheduleOneShotNotification(
          id: NotificationCategory.cycleWindow.index * 100 + 1,
          scheduledDate: reminderDate,
          preference: cycleWindowPref,
          title: 'Bevorstehendes Periodenfenster',
          body: 'Deine nächste Periode wird in etwa $leadDays Tagen erwartet.',
          discreteTitle: 'MacroMate Zyklus',
          discreteBody: 'Dein Zyklusfenster steht bevor.',
        );
      }
    }

    // 4. Personalized symptom/energy insight
    final insightPref = getPreference(NotificationCategory.cycleInsight);
    if (insightPref != null &&
        insightPref.enabled &&
        personalizedInsight != null) {
      await _scheduleOneShotNotification(
        id: NotificationCategory.cycleInsight.index * 100 + 1,
        scheduledDate: now.add(const Duration(hours: 4)),
        preference: insightPref,
        title: 'Persönlicher Zyklus-Hinweis',
        body: personalizedInsight,
        discreteTitle: 'MacroMate Hinweis',
        discreteBody: 'Ein persönlicher Hinweis liegt für dich vor.',
      );
    }
  }

  Future<void> _scheduleDailyTimeNotification({
    required int id,
    required TimeOfDay time,
    required NotificationPreference preference,
    required String title,
    required String body,
    required String discreteTitle,
    required String discreteBody,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (preference.leadMinutes > 0) {
      scheduled = scheduled.subtract(Duration(minutes: preference.leadMinutes));
    }

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    if (!_policy.isAllowed(preference, scheduled)) return;

    final displayTitle =
        preference.discreteLockScreen ? discreteTitle : title;
    final displayBody =
        preference.discreteLockScreen ? discreteBody : body;

    const androidDetails = AndroidNotificationDetails(
      'macromate_reminders',
      'MacroMate Erinnerungen',
      channelDescription: 'Benachrichtigungen für Ernährung, Gewicht und Zyklus',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      displayTitle,
      displayBody,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleOneShotNotification({
    required int id,
    required DateTime scheduledDate,
    required NotificationPreference preference,
    required String title,
    required String body,
    required String discreteTitle,
    required String discreteBody,
  }) async {
    final scheduled = tz.TZDateTime.from(scheduledDate, tz.local);
    if (!_policy.isAllowed(preference, scheduled)) return;

    final displayTitle =
        preference.discreteLockScreen ? discreteTitle : title;
    final displayBody =
        preference.discreteLockScreen ? discreteBody : body;

    const androidDetails = AndroidNotificationDetails(
      'macromate_insights',
      'MacroMate Hinweise',
      channelDescription: 'Diskrete Hinweise und Zyklusfenster',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      displayTitle,
      displayBody,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
