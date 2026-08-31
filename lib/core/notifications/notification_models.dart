import 'dart:convert';

enum NotificationCategory {
  nutrition,
  meals,
  weight,
  activity,
  cycle,
  cycleWindow,
  cycleInsight,
  healthSync,
  supplements,
}

class NotificationMessage {
  const NotificationMessage({
    required this.category,
    required this.title,
    required this.body,
    required this.discreteTitle,
    required this.discreteBody,
  });

  final NotificationCategory category;
  final String title;
  final String body;
  final String discreteTitle;
  final String discreteBody;
}


class NotificationPreference {
  const NotificationPreference({
    required this.category,
    this.enabled = false,
    this.leadMinutes = 0,
    this.quietStart,
    this.quietEnd,
    this.weekdays = const {1, 2, 3, 4, 5, 6, 7},
    this.discreteLockScreen = true,
  });

  final NotificationCategory category;
  final bool enabled;
  final int leadMinutes;
  final String? quietStart;
  final String? quietEnd;
  final Set<int> weekdays;
  final bool discreteLockScreen;

  String get id => category.name;

  NotificationPreference copyWith({
    bool? enabled,
    int? leadMinutes,
    String? quietStart,
    String? quietEnd,
    Set<int>? weekdays,
    bool? discreteLockScreen,
  }) =>
      NotificationPreference(
        category: category,
        enabled: enabled ?? this.enabled,
        leadMinutes: leadMinutes ?? this.leadMinutes,
        quietStart: quietStart ?? this.quietStart,
        quietEnd: quietEnd ?? this.quietEnd,
        weekdays: weekdays ?? this.weekdays,
        discreteLockScreen: discreteLockScreen ?? this.discreteLockScreen,
      );

  static Set<int> weekdaysFromJson(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.whereType<num>().map((item) => item.toInt()).where(
              (item) => item >= 1 && item <= 7,
            ).toSet();
      }
    } catch (_) {
      // Fall through to all days for a legacy/corrupt preference.
    }
    return {1, 2, 3, 4, 5, 6, 7};
  }
}

class NotificationPolicy {
  const NotificationPolicy();

  bool isAllowed(NotificationPreference preference, DateTime localTime) {
    if (!preference.enabled || !preference.weekdays.contains(localTime.weekday)) {
      return false;
    }
    final start = _minutes(preference.quietStart);
    final end = _minutes(preference.quietEnd);
    if (start == null || end == null || start == end) return true;
    final current = localTime.hour * 60 + localTime.minute;
    final inQuiet = start < end
        ? current >= start && current < end
        : current >= start || current < end;
    return !inQuiet;
  }

  int? _minutes(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }
}
