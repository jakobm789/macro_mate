import 'dart:math';
import 'package:flutter/foundation.dart';

import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({required SettingsRepository repository})
      : _repository = repository;

  final SettingsRepository _repository;

  UserSettings _settings = const UserSettings();
  UserGoals _goals = const UserGoals();

  UserSettings get settings => _settings;
  UserGoals get goals => _goals;

  bool get isDarkMode => _settings.darkMode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Calculated daily macro goals in grams
  double get dailyCarbGoal =>
      (_goals.dailyCalories * (_goals.carbPercentage / 100)) / 4.0;

  double get dailyProteinGoal {
    if (_goals.useProteinPerKg) {
      // Handled dynamically if weight available, fallback to %
      return (_goals.dailyCalories * (_goals.proteinPercentage / 100)) / 4.0;
    }
    return (_goals.dailyCalories * (_goals.proteinPercentage / 100)) / 4.0;
  }

  double get dailyFatGoal =>
      (_goals.dailyCalories * (_goals.fatPercentage / 100)) / 9.0;

  double get dailySugarGoal =>
      (_goals.dailyCalories * (_goals.sugarPercentage / 100)) / 4.0;

  Future<void> initialize() async {
    await loadSettingsAndGoals();
  }

  Future<void> loadSettingsAndGoals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _repository.getSettings();
      _goals = await _repository.getGoals();
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Einstellungen: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    _settings = _settings.copyWith(darkMode: value);
    notifyListeners();
    await _repository.updateSettings(_settings);
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await _repository.updateSettings(_settings);
  }

  Future<void> updateGoals(UserGoals newGoals) async {
    _goals = newGoals;
    notifyListeners();
    await _repository.updateGoals(_goals);
  }

  /// Calculates BMR using Mifflin-St Jeor or Harris-Benedict formula
  double calculateBmr({required double weightKg}) {
    if (_goals.bmrFormula == BmrFormula.harris) {
      if (_goals.gender == Gender.male) {
        return 66.5 +
            (13.75 * weightKg) +
            (5.003 * _goals.userHeight) -
            (6.75 * _goals.userAge);
      } else {
        return 655.1 +
            (9.563 * weightKg) +
            (1.850 * _goals.userHeight) -
            (4.676 * _goals.userAge);
      }
    } else {
      // Mifflin-St Jeor
      if (_goals.gender == Gender.male) {
        return (10 * weightKg) +
            (6.25 * _goals.userHeight) -
            (5 * _goals.userAge) +
            5;
      } else {
        return (10 * weightKg) +
            (6.25 * _goals.userHeight) -
            (5 * _goals.userAge) -
            161;
      }
    }
  }

  /// Calculates TDEE (Total Daily Energy Expenditure) based on activity level
  double calculateTdee({required double weightKg}) {
    final bmr = calculateBmr(weightKg: weightKg);
    return bmr * _goals.userActivityLevel;
  }

  /// Calculates target calories based on auto calorie mode
  int calculateAutoCalorieGoal({required double currentWeightKg}) {
    if (_goals.autoCalorieMode == AutoCalorieMode.off) {
      return _goals.dailyCalories;
    }

    final tdee = calculateTdee(weightKg: currentWeightKg);

    switch (_goals.autoCalorieMode) {
      case AutoCalorieMode.maintain:
        return tdee.round();
      case AutoCalorieMode.diet:
        // ~1% body weight loss per week = 7700 kcal per kg
        final weeklyLossKg = currentWeightKg * 0.01;
        final dailyDeficit = (weeklyLossKg * 7700) / 7;
        final target = (tdee - dailyDeficit).round();
        return max(1200, target);
      case AutoCalorieMode.bulk:
        // Surplus of ~300-500 kcal
        return (tdee + 350).round();
      case AutoCalorieMode.custom:
        final monthlyChange = _goals.customPercentPerMonth / 100.0;
        final weeklyChangeKg = (currentWeightKg * monthlyChange) / 4.0;
        final dailyCalorieDelta = (weeklyChangeKg * 7700) / 7;
        final target = (tdee + dailyCalorieDelta).round();
        return max(1200, target);
      case AutoCalorieMode.off:
        return _goals.dailyCalories;
    }
  }

  Future<void> resetGoals() async {
    await _repository.resetGoals();
    await loadSettingsAndGoals();
  }

  Future<void> resetDatabase() async {
    await _repository.resetDatabase();
    await loadSettingsAndGoals();
  }

  Future<String?> getSavedEmail() =>
      _repository.getSecureCredential('credential_email');

  Future<String?> getSavedPassword() =>
      _repository.getSecureCredential('credential_password');

  Future<void> saveCredentials(String email, String password) async {
    await _repository.setSecureCredential('credential_email', email);
    await _repository.setSecureCredential('credential_password', password);
  }

  Future<void> clearCredentials() async {
    await _repository.deleteSecureCredential('credential_email');
    await _repository.deleteSecureCredential('credential_password');
  }

  Future<List<String>?> getDashboardCardOrder() =>
      _repository.getDashboardCardOrder();

  Future<void> saveDashboardCardOrder(List<String> order) =>
      _repository.setDashboardCardOrder(order);

  Future<Map<String, bool>?> getDashboardCardVisibility() =>
      _repository.getDashboardCardVisibility();

  Future<void> saveDashboardCardVisibility(Map<String, bool> visibility) =>
      _repository.setDashboardCardVisibility(visibility);

  Future<void> resetDashboardConfig() => _repository.resetDashboardConfig();
}
