import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../features/dashboard/presentation/dashboard_controller.dart';
import '../../models/app_state.dart';

/// Service to keep Android home screen widgets in sync with the app's state.
class AppWidgetService {
  static const MethodChannel _channel = MethodChannel('macro_mate/widget');

  static bool _isAndroid() {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  /// Updates all widgets (Macro, Activity, Weight, Cycle, Overview) in a single atomic call.
  static Future<void> updateAllWidgets({
    required double consumedCalories,
    required int dailyCalorieGoal,
    required double consumedCarbs,
    required double consumedProtein,
    required double consumedFat,
    required int steps,
    int stepGoal = 10000,
    required double distanceKm,
    required double activeCalories,
    required double totalCalories,
    required double currentWeight,
    required double weightTrend,
    double targetWeight = 0.0,
    int cycleDay = -1,
    String cyclePhase = '',
    int daysUntilNext = -1,
  }) async {
    if (!_isAndroid()) return;

    try {
      await _channel.invokeMethod('updateAllWidgets', {
        'consumedCalories': consumedCalories,
        'dailyCalorieGoal': dailyCalorieGoal,
        'consumedCarbs': consumedCarbs,
        'consumedProtein': consumedProtein,
        'consumedFat': consumedFat,
        'steps': steps,
        'stepGoal': stepGoal,
        'distanceKm': distanceKm,
        'activeCalories': activeCalories,
        'totalCalories': totalCalories,
        'currentWeight': currentWeight,
        'weightTrend': weightTrend,
        'targetWeight': targetWeight,
        'cycleDay': cycleDay,
        'cyclePhase': cyclePhase,
        'daysUntilNext': daysUntilNext,
      });
    } catch (e) {
      developer.log('AppWidgetService: Error updating all widgets: $e',
          name: 'AppWidgetService');
    }
  }

  /// Convenience method to synchronize all home screen widgets using [DashboardController].
  static Future<void> updateFromDashboard(DashboardController dashboard) async {
    if (!_isAndroid()) return;

    final totalConsumedKcal = dashboard.consumedCalories;
    final carbs = dashboard.consumedCarbs;
    final protein = dashboard.consumedProtein;
    final fat = dashboard.consumedFat;

    final targetKcal = dashboard.dailyCalorieGoal;
    final steps = dashboard.steps;
    final stepGoal = dashboard.stepGoal;
    final distanceKm = dashboard.distanceKm;
    final activeKcal = dashboard.activeCalories;
    final totalKcal = dashboard.totalEnergyExpenditure;

    final weight = dashboard.latestWeight ?? 0.0;
    final trend = dashboard.weightTrend ?? 0.0;
    final targetWeight = dashboard.targetWeight ?? 0.0;

    final cycleDay = dashboard.cycleDay ?? -1;
    final cyclePhase = dashboard.cyclePhase ?? '';

    await updateAllWidgets(
      consumedCalories: totalConsumedKcal,
      dailyCalorieGoal: targetKcal,
      consumedCarbs: carbs,
      consumedProtein: protein,
      consumedFat: fat,
      steps: steps,
      stepGoal: stepGoal,
      distanceKm: distanceKm,
      activeCalories: activeKcal,
      totalCalories: totalKcal,
      currentWeight: weight,
      weightTrend: trend,
      targetWeight: targetWeight,
      cycleDay: cycleDay,
      cyclePhase: cyclePhase,
    );
  }

  /// Convenience method to synchronize widgets from [AppState].
  static Future<void> updateFromAppState(AppState appState) async {
    if (!_isAndroid()) return;
    await updateFromDashboard(appState.dashboardController);
  }
}
