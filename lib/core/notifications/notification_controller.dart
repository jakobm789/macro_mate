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

  static const Map<NotificationCategory, String> categoryLabels = {
    NotificationCategory.nutrition: 'Ernährung & Tagesziel',
    NotificationCategory.meals: 'Mahlzeitenzeiten',
    NotificationCategory.weight: 'Morgendliches Wiegen',
    NotificationCategory.activity: 'Aktivität & Schrittziele',
    NotificationCategory.cycleWindow: 'Periodenvorwarnung (diskret)',
    NotificationCategory.cycleInsight: 'Zyklus-Tipps & Wohlbefinden',
    NotificationCategory.healthSync: 'Health Connect Sync-Erinnerung',
    NotificationCategory.supplements: 'Supplements & Wasser',
  };

  static const Map<NotificationCategory, String> categoryDescriptions = {
    NotificationCategory.nutrition:
        'Tägliche Zusammenfassung und Erinnerung an offene Kalorien- und Makroziele.',
    NotificationCategory.meals:
        'Erinnerungen zu Frühstück, Mittag- und Abendessen.',
    NotificationCategory.weight:
        'Erinnerung an das nüchterne Wiegen am Morgen.',
    NotificationCategory.activity:
        'Motivation für deine täglichen Schritt- und Aktivitätsziele.',
    NotificationCategory.cycleWindow:
        'Diskrete Vorwarnung vor dem errechneten Beginn des nächsten Periodenfensters.',
    NotificationCategory.cycleInsight:
        'Personalisierte Tipps und Check-in-Erinnerungen für deine aktuelle Zyklusphase.',
    NotificationCategory.healthSync:
        'Hinweis, wenn Health Connect länger nicht synchronisiert wurde.',
    NotificationCategory.supplements:
        'Tägliche Erinnerung an Vitamine, Mineralstoffe oder Flüssigkeitszufuhr.',
  };

  Future<void> initialize() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _plugin.initialize(initSettings);
    } catch (_) {}

    await loadPreferences();
    _isInitialized = true;
  }

  Future<void> loadPreferences() async {
    _preferences = await _repository.list();
    if (_preferences.isEmpty) {
      // Initialize defaults for all 8 categories
      for (final cat in NotificationCategory.values) {
        final defaultPref = NotificationPreference(
          category: cat,
          enabled: cat == NotificationCategory.nutrition ||
              cat == NotificationCategory.meals ||
              cat == NotificationCategory.weight,
          discreteLockScreen: true,
          weekdays: const {1, 2, 3, 4, 5, 6, 7},
          quietStart: '22:00',
          quietEnd: '07:00',
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
    try {
      final baseId = category.index * 100;
      for (int i = 0; i < 20; i++) {
        await _plugin.cancel(baseId + i);
      }
    } catch (_) {}
  }

  Future<void> rescheduleAll({
    TimeOfDay? breakfastTime,
    TimeOfDay? lunchTime,
    TimeOfDay? dinnerTime,
    TimeOfDay? weighTime,
    DateTime? nextPeriodDate,
    String? personalizedInsight,
  }) async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}

    final now = DateTime.now();

    // 1. Nutrition daily recap
    final nutritionPref = getPreference(NotificationCategory.nutrition);
    if (nutritionPref != null && nutritionPref.enabled) {
      await _scheduleDailyTimeNotification(
        id: NotificationCategory.nutrition.index * 100 + 1,
        time: const TimeOfDay(hour: 20, minute: 30),
        preference: nutritionPref,
        title: 'Tagesabschluss Ernährung',
        body: 'Hast du heute alle Mahlzeiten und Makros eingetragen?',
        discreteTitle: 'MacroMate Tagescheck',
        discreteBody: 'Zeit für deinen täglichen Check-in.',
      );
    }

    // 2. Meal reminders
    final mealsPref = getPreference(NotificationCategory.meals);
    if (mealsPref != null && mealsPref.enabled) {
      if (breakfastTime != null) {
        await _scheduleDailyTimeNotification(
          id: NotificationCategory.meals.index * 100 + 1,
          time: breakfastTime,
          preference: mealsPref,
          title: 'Frühstück erfassen',
          body: 'Vergiss nicht, dein Frühstück einzutragen.',
          discreteTitle: 'Ernährungstracking',
          discreteBody: 'Zeit für deinen nächsten Eintrag.',
        );
      }
      if (lunchTime != null) {
        await _scheduleDailyTimeNotification(
          id: NotificationCategory.meals.index * 100 + 2,
          time: lunchTime,
          preference: mealsPref,
          title: 'Mittagessen erfassen',
          body:
              'Trage dein Mittagessen ein, um deine Makros im Blick zu behalten.',
          discreteTitle: 'Ernährungstracking',
          discreteBody: 'Zeit für deinen nächsten Eintrag.',
        );
      }
      if (dinnerTime != null) {
        await _scheduleDailyTimeNotification(
          id: NotificationCategory.meals.index * 100 + 3,
          time: dinnerTime,
          preference: mealsPref,
          title: 'Abendessen erfassen',
          body: 'Trage dein Abendessen ein und schließe deinen Tag ab.',
          discreteTitle: 'Ernährungstracking',
          discreteBody: 'Zeit für deinen nächsten Eintrag.',
        );
      }
    }

    // 3. Weight morning reminder
    final weightPref = getPreference(NotificationCategory.weight);
    if (weightPref != null && weightPref.enabled) {
      final time = weighTime ?? const TimeOfDay(hour: 7, minute: 30);
      await _scheduleDailyTimeNotification(
        id: NotificationCategory.weight.index * 100 + 1,
        time: time,
        preference: weightPref,
        title: 'Gewicht wiegen',
        body: 'Zeit für dein morgendliches Wiegen.',
        discreteTitle: 'MacroMate Erinnerung',
        discreteBody: 'Tageseintrag empfohlen.',
      );
    }

    // 4. Activity reminder
    final activityPref = getPreference(NotificationCategory.activity);
    if (activityPref != null && activityPref.enabled) {
      await _scheduleDailyTimeNotification(
        id: NotificationCategory.activity.index * 100 + 1,
        time: const TimeOfDay(hour: 17, minute: 0),
        preference: activityPref,
        title: 'Aktivitätsziel überprüfen',
        body: 'Wie viele Schritte fehlen dir heute noch zum Ziel?',
        discreteTitle: 'Aktivitätstracking',
        discreteBody: 'Tagesziel überprüfen.',
      );
    }

    // 5. Cycle Window (advance notice)
    final cycleWindowPref = getPreference(NotificationCategory.cycleWindow);
    if (cycleWindowPref != null &&
        cycleWindowPref.enabled &&
        nextPeriodDate != null) {
      final leadDays =
          (cycleWindowPref.leadMinutes / (24 * 60)).round().clamp(1, 7);
      final reminderDate = nextPeriodDate.subtract(Duration(days: leadDays));
      if (reminderDate.isAfter(now)) {
        await _scheduleOneShotNotification(
          id: NotificationCategory.cycleWindow.index * 100 + 1,
          scheduledDate: reminderDate,
          preference: cycleWindowPref,
          title: 'Bevorstehendes Periodenfenster',
          body: 'Deine nächste Periode wird in etwa $leadDays Tagen erwartet.',
          discreteTitle: 'MacroMate Hinweis',
          discreteBody: 'Dein Zyklusfenster steht bevor.',
        );
      }
    }

    // 6. Personalized symptom/energy insight
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

    // 7. Health Sync reminder
    final syncPref = getPreference(NotificationCategory.healthSync);
    if (syncPref != null && syncPref.enabled) {
      await _scheduleDailyTimeNotification(
        id: NotificationCategory.healthSync.index * 100 + 1,
        time: const TimeOfDay(hour: 21, minute: 0),
        preference: syncPref,
        title: 'Health Connect Synchronisation',
        body:
            'Synchronisiere deine Schritte und Workouts für genaue Tageswerte.',
        discreteTitle: 'Sync-Erinnerung',
        discreteBody: 'Daten synchronisieren.',
      );
    }

    // 8. Supplements & Water reminder
    final supplementsPref = getPreference(NotificationCategory.supplements);
    if (supplementsPref != null && supplementsPref.enabled) {
      await _scheduleDailyTimeNotification(
        id: NotificationCategory.supplements.index * 100 + 1,
        time: const TimeOfDay(hour: 9, minute: 0),
        preference: supplementsPref,
        title: 'Supplements & Wasser',
        body:
            'Vergiss nicht deine täglichen Nahrungsergänzungsmittel und ausreichend Wasser.',
        discreteTitle: 'MacroMate Erinnerung',
        discreteBody: 'Tagesroutine ausführen.',
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
    try {
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
        scheduled =
            scheduled.subtract(Duration(minutes: preference.leadMinutes));
      }

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      if (!_policy.isAllowed(preference, scheduled)) return;

      final displayTitle =
          preference.discreteLockScreen ? discreteTitle : title;
      final displayBody = preference.discreteLockScreen ? discreteBody : body;

      const androidDetails = AndroidNotificationDetails(
        'macromate_reminders',
        'MacroMate Erinnerungen',
        channelDescription:
            'Benachrichtigungen für Ernährung, Gewicht und Zyklus',
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
    } catch (_) {}
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

    final displayTitle = preference.discreteLockScreen ? discreteTitle : title;
    final displayBody = preference.discreteLockScreen ? discreteBody : body;

    const androidDetails = AndroidNotificationDetails(
      'macromate_insights',
      'MacroMate Hinweise',
      channelDescription: 'Diskrete Hinweise und Zyklusfenster',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    try {
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
    } catch (_) {}
  }
}
