import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../core/logging/app_logger.dart';
import '../../activity/presentation/activity_controller.dart';
import '../../cycle/presentation/cycle_controller.dart';
import '../../health/domain/health_models.dart';
import '../../health/presentation/health_controller.dart';
import '../../nutrition/presentation/nutrition_controller.dart';
import '../../settings/domain/settings_models.dart';
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
    AppLogger logger = const AppLogger(),
  })  : _nutrition = nutritionController,
        _weight = weightController,
        _health = healthController,
        _activity = activityController,
        _cycle = cycleController,
        _settings = settingsController,
        _logger = logger {
    _initDefaults();
  }

  final NutritionController _nutrition;
  final WeightController _weight;
  final HealthController _health;
  final ActivityController _activity;
  final CycleController _cycle;
  final SettingsController _settings;
  final AppLogger _logger;

  static const List<String> defaultCardOrder = [
    'calories',
    'steps',
    'active_energy',
    'weight',
    'health_sync',
    'cycle',
    'impulses',
  ];

  static const Map<String, String> cardTitles = {
    'calories': 'Kalorien & Makro-Ziele',
    'steps': 'Schritte & Distanz',
    'active_energy': 'Aktivitätskalorien',
    'weight': 'Gewicht & Trend',
    'health_sync': 'Health Connect Status',
    'cycle': 'Zyklus & Wohlbefinden (diskret)',
    'impulses': 'Handlungsimpulse',
  };

  List<String> _cardOrder = List.from(defaultCardOrder);
  List<String> get cardOrder => List.unmodifiable(_cardOrder);

  Map<String, bool> _cardVisibility = {
    'calories': true,
    'steps': true,
    'active_energy': true,
    'weight': true,
    'health_sync': true,
    'cycle': false,
    'impulses': true,
  };
  Map<String, bool> get cardVisibility => Map.unmodifiable(_cardVisibility);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, bool> _getDefaultVisibility() {
    final cycleOptedIn = _cycle.periodsState.isNotEmpty ||
        _cycle.logsState.isNotEmpty ||
        _settings.goals.gender == Gender.female;
    return {
      'calories': true,
      'steps': true,
      'active_energy': true,
      'weight': true,
      'health_sync': true,
      'cycle': cycleOptedIn,
      'impulses': true,
    };
  }

  void _initDefaults() {
    _cardVisibility = _getDefaultVisibility();
  }

  Future<void> initialize() async {
    await loadCardConfiguration();
  }

  Future<void> loadCardConfiguration() async {
    try {
      final savedOrder = await _settings.getDashboardCardOrder();
      if (savedOrder != null && savedOrder.isNotEmpty) {
        final validSaved =
            savedOrder.where((id) => defaultCardOrder.contains(id)).toList();
        for (final defaultId in defaultCardOrder) {
          if (!validSaved.contains(defaultId)) {
            validSaved.add(defaultId);
          }
        }
        _cardOrder = validSaved;
      } else {
        _cardOrder = List.from(defaultCardOrder);
      }

      final savedVis = await _settings.getDashboardCardVisibility();
      final defaults = _getDefaultVisibility();
      if (savedVis != null && savedVis.isNotEmpty) {
        final merged = <String, bool>{};
        for (final id in defaultCardOrder) {
          merged[id] = savedVis[id] ?? defaults[id] ?? true;
        }
        _cardVisibility = merged;
      } else {
        _cardVisibility = defaults;
      }
    } catch (e) {
      _logger.warning(
        'Fehler beim Laden der Dashboard-Konfiguration, Standardwerte werden verwendet: $e',
      );
      _cardOrder = List.from(defaultCardOrder);
      _cardVisibility = _getDefaultVisibility();
    }
    notifyListeners();
  }

  bool isCardVisible(String cardId) => _cardVisibility[cardId] ?? true;

  Future<void> toggleCardVisibility(String cardId, bool visible) async {
    _cardVisibility[cardId] = visible;
    notifyListeners();
    await _persistConfiguration();
  }

  Future<void> reorderCards(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _cardOrder.removeAt(oldIndex);
    _cardOrder.insert(newIndex, item);
    notifyListeners();
    await _persistConfiguration();
  }

  Future<void> resetToDefaults() async {
    _cardOrder = List.from(defaultCardOrder);
    _cardVisibility = _getDefaultVisibility();
    try {
      await _settings.resetDashboardConfig();
    } catch (e) {
      _logger.error('resetDashboardConfig', e);
    }
    notifyListeners();
  }

  Future<void> _persistConfiguration() async {
    try {
      await _settings.saveDashboardCardOrder(_cardOrder);
      await _settings.saveDashboardCardVisibility(_cardVisibility);
    } catch (e) {
      _logger.error('persistDashboardConfiguration', e);
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait<dynamic>([
        _nutrition.loadDailyFoods(),
        _weight.loadWeights(),
        _health.load(),
        _activity.loadActivityData(),
        _cycle.load(),
      ]);
    } catch (e) {
      _logger.error('dashboardRefresh', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
  double get distanceKm =>
      (_activity.todaySummary?.distanceMeters ?? 0.0) / 1000.0;
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

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final weightLoggedToday = _weight.records.any(
      (r) => DateFormat('yyyy-MM-dd').format(r.day) == todayStr,
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

    if (!isHealthConnected) {
      impulses.add(
        const ActionImpulse(
          title: 'Health Connect verbinden',
          description:
              'Synchronisiere Schritte, Aktivenergie und Schlafphasen automatisch.',
          iconName: 'sync_alt',
          targetRoute: '/health',
          priority: 2,
        ),
      );
    }

    if (consumedCalories == 0) {
      impulses.add(
        const ActionImpulse(
          title: 'Mahlzeit erfassen',
          description:
              'Beginne mit deinem Frühstück oder schnellen KI-Food-Check-in.',
          iconName: 'restaurant',
          targetRoute: '/nutrition',
          priority: 3,
        ),
      );
    }

    return impulses;
  }

  String _formatDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date);
}
