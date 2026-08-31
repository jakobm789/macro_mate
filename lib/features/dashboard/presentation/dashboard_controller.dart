import 'package:flutter/foundation.dart';

import '../../activity/presentation/activity_controller.dart';
import '../../cycle/presentation/cycle_controller.dart';
import '../../health/domain/health_models.dart';
import '../../health/presentation/health_controller.dart';
import '../../nutrition/presentation/nutrition_controller.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../weight/presentation/weight_controller.dart';

class ActionImpulse {
  const ActionImpulse({
    required this.title,
    required this.description,
    required this.iconName,
    required this.targetRoute,
    this.priority = 1,
  });

  final String title;
  final String description;
  final String iconName;
  final String targetRoute;
  final int priority;
}

class DashboardController extends ChangeNotifier {
  DashboardController({
    required NutritionController nutritionController,
    required WeightController weightController,
    required HealthController healthController,
    required ActivityController activityController,
    required CycleController cycleController,
    required SettingsController settingsController,
  })  : _nutrition = nutritionController,
        _weight = weightController,
        _health = healthController,
        _activity = activityController,
        _cycle = cycleController,
        _settings = settingsController;

  final NutritionController _nutrition;
  final WeightController _weight;
  final HealthController _health;
  final ActivityController _activity;
  final CycleController _cycle;
  final SettingsController _settings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {}

  // Nutrition getters
  double get consumedCalories => _nutrition.consumedCalories;
  int get dailyCalorieGoal => _settings.goals.dailyCalories;
  double get consumedCarbs => _nutrition.consumedCarbs;
  double get dailyCarbGoal => _settings.dailyCarbGoal;
  double get consumedProtein => _nutrition.consumedProtein;
  double get dailyProteinGoal => _settings.dailyProteinGoal;
  double get consumedFat => _nutrition.consumedFat;
  double get dailyFatGoal => _settings.dailyFatGoal;

  // Activity getters
  int get steps => _activity.todaySummary?.steps ?? 0;
  double get activeCalories => _activity.todaySummary?.activeCalories ?? 0.0;
  double get distanceKm => (_activity.todaySummary?.distanceMeters ?? 0.0) / 1000.0;
  double? get totalCalories => _activity.todaySummary?.totalCalories;
  double? get averageHeartRate => _activity.todaySummary?.averageHeartRate;
  double? get restingHeartRate => _activity.todaySummary?.restingHeartRate;
  double? get sleepMinutes => _activity.todaySummary?.sleepMinutes;

  // Weight getters
  double? get latestWeight => _weight.currentWeight;
  double? get weightTrend => _weight.sevenDayTrend;

  // Health sync
  HealthSyncStatus get syncStatus => _health.syncStatus;
  DateTime? get lastSyncTime => _health.lastSyncTime;
  String? get healthErrorMessage => _health.errorMessage;
  bool get isHealthConnected => _health.permissionState?.readGranted == true;

  // Cycle status
  bool get predictionsEnabled => _cycle.predictionsEnabled;
  int? get cycleDay => _cycle.currentCycleDay;
  String? get cyclePhase => _cycle.currentPhaseName;
  String? get discreteCycleTip {
    if (!predictionsEnabled || _cycle.predictions.isEmpty) return null;
    final first = _cycle.predictions.first;
    if (first.kind == 'period') {
      return 'Nächste Periode erwartet ab ${_formatDate(first.windowStart)}';
    }
    return first.rationale;
  }


  // Prioritized action impulses
  List<ActionImpulse> get actionImpulses {
    final impulses = <ActionImpulse>[];

    // Check weight logged today
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final weightLoggedToday = _weight.records.any(
      (r) => '${r.day.year}-${r.day.month.toString().padLeft(2, '0')}-${r.day.day.toString().padLeft(2, '0')}' == todayStr,
    );

    if (!weightLoggedToday) {
      impulses.add(
        const ActionImpulse(
          title: 'Gewicht eintragen',
          description: 'Wiege dich morgens nüchtern für genaue Trendwerte.',
          iconName: 'monitor_weight_outlined',
          targetRoute: '/weight',
          priority: 1,
        ),
      );
    }

    // Check health connection
    if (_health.permissionState?.needsOnboarding ?? true) {
      impulses.add(
        const ActionImpulse(
          title: 'Health Connect verbinden',
          description: 'Synchronisiere Schritte, Schlaf und Workouts automatisch.',
          iconName: 'health_and_safety_outlined',
          targetRoute: '/health',
          priority: 2,
        ),
      );
    }

    // Check nutrition logging
    if (_nutrition.breakfast.isEmpty && _nutrition.lunch.isEmpty && _nutrition.dinner.isEmpty) {
      impulses.add(
        const ActionImpulse(
          title: 'Ernährung erfassen',
          description: 'Tracke deine Mahlzeiten, um deine Makroziele im Blick zu behalten.',
          iconName: 'restaurant_outlined',
          targetRoute: '/nutrition',
          priority: 3,
        ),
      );
    }

    impulses.sort((a, b) => a.priority.compareTo(b.priority));
    return impulses;
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _nutrition.loadDailyFoods(),
      _weight.loadWeights(),
      _activity.loadActivityData(),
      _health.load(),
      _cycle.load(),
      _settings.loadSettingsAndGoals(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
}
