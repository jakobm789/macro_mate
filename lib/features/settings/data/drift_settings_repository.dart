import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository({
    required AppDatabase database,
    FlutterSecureStorage? secureStorage,
    AppLogger logger = const AppLogger(),
  })  : _database = database,
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _logger = logger;

  final AppDatabase _database;
  final FlutterSecureStorage _secureStorage;
  final AppLogger _logger;

  static const String _secureEmailKey = 'credential_email';
  static const String _securePasswordKey = 'credential_password';
  static const String _migrationMarkerKey = 'credentials_secure_migration_v1';
  static const String _userEmailKey = 'user_email';
  static const String _userPasswordKey = 'user_password';
  static const String _genderKey = 'user_gender';
  static const String _bmrKey = 'bmr_formula';
  static const String _dashboardCardOrderKey = 'dashboard_card_order';
  static const String _dashboardCardVisibilityKey = 'dashboard_card_visibility';

  @override
  Future<UserSettings> getSettings() async {
    final rows = await _database.select(_database.appSettings).get();
    if (rows.isEmpty) {
      await _database.into(_database.appSettings).insert(
            const AppSettingsCompanion(
              darkMode: Value(0),
              reminderWeighEnabled: Value(0),
              reminderWeighTime: Value('08:00'),
              reminderWeighTime2: Value('09:00'),
              reminderSupplementEnabled: Value(0),
              reminderSupplementTime: Value('10:00'),
              reminderSupplementTime2: Value('11:00'),
              reminderMealsEnabled: Value(0),
              reminderBreakfast: Value('07:00'),
              reminderLunch: Value('12:30'),
              reminderDinner: Value('19:00'),
            ),
          );
      return const UserSettings();
    }

    final row = rows.first;
    return UserSettings(
      darkMode: row.darkMode == 1,
      reminderWeighEnabled: row.reminderWeighEnabled == 1,
      reminderWeighTime: row.reminderWeighTime,
      reminderWeighTime2: row.reminderWeighTime2,
      reminderSupplementEnabled: row.reminderSupplementEnabled == 1,
      reminderSupplementTime: row.reminderSupplementTime,
      reminderSupplementTime2: row.reminderSupplementTime2,
      reminderMealsEnabled: row.reminderMealsEnabled == 1,
      reminderBreakfast: row.reminderBreakfast,
      reminderLunch: row.reminderLunch,
      reminderDinner: row.reminderDinner,
    );
  }

  @override
  Future<void> updateSettings(UserSettings settings) async {
    final rows = await _database.select(_database.appSettings).get();
    final companion = AppSettingsCompanion(
      darkMode: Value(settings.darkMode ? 1 : 0),
      reminderWeighEnabled: Value(settings.reminderWeighEnabled ? 1 : 0),
      reminderWeighTime: Value(settings.reminderWeighTime),
      reminderWeighTime2: Value(settings.reminderWeighTime2),
      reminderSupplementEnabled:
          Value(settings.reminderSupplementEnabled ? 1 : 0),
      reminderSupplementTime: Value(settings.reminderSupplementTime),
      reminderSupplementTime2: Value(settings.reminderSupplementTime2),
      reminderMealsEnabled: Value(settings.reminderMealsEnabled ? 1 : 0),
      reminderBreakfast: Value(settings.reminderBreakfast),
      reminderLunch: Value(settings.reminderLunch),
      reminderDinner: Value(settings.reminderDinner),
    );

    if (rows.isEmpty) {
      await _database.into(_database.appSettings).insert(companion);
    } else {
      await (_database.update(_database.appSettings)
            ..where((tbl) => tbl.id.equals(rows.first.id)))
          .write(companion);
    }
  }

  @override
  Future<UserGoals> getGoals() async {
    final rows = await _database.select(_database.goals).get();
    final prefs = await SharedPreferences.getInstance();
    final genderStr = prefs.getString(_genderKey);
    final bmrStr = prefs.getString(_bmrKey);

    final gender = genderStr == 'female' ? Gender.female : Gender.male;
    final bmrFormula =
        bmrStr == 'harris' ? BmrFormula.harris : BmrFormula.mifflin;

    if (rows.isEmpty) {
      return UserGoals(gender: gender, bmrFormula: bmrFormula);
    }

    final row = rows.first;
    return UserGoals(
      dailyCalories: row.dailyCalories,
      carbPercentage: row.carbPercentage,
      proteinPercentage: row.proteinPercentage,
      fatPercentage: row.fatPercentage,
      sugarPercentage: row.sugarPercentage,
      autoCalorieMode: AutoCalorieMode.values.firstWhere(
        (e) => e.index == row.autoCalorieMode,
        orElse: () => AutoCalorieMode.off,
      ),
      customPercentPerMonth: row.customPercentPerMonth,
      useCustomStartCalories: row.useCustomStartCalories == 1,
      userStartCalories: row.userStartCalories,
      userAge: row.userAge,
      userActivityLevel: row.userActivityLevel,
      userHeight: row.userHeight,
      useProteinPerKg: row.useProteinPerKg == 1,
      proteinPerKg: row.proteinPerKg,
      targetWeight: row.targetWeight,
      targetDate: row.targetDate,
      targetWeeklyChange: row.targetWeeklyChange,
      gender: gender,
      bmrFormula: bmrFormula,
    );
  }

  @override
  Future<void> updateGoals(UserGoals goals) async {
    final rows = await _database.select(_database.goals).get();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _genderKey, goals.gender == Gender.female ? 'female' : 'male');
    await prefs.setString(
        _bmrKey, goals.bmrFormula == BmrFormula.harris ? 'harris' : 'mifflin');

    final companion = GoalsCompanion(
      dailyCalories: Value(goals.dailyCalories),
      carbPercentage: Value(goals.carbPercentage),
      proteinPercentage: Value(goals.proteinPercentage),
      fatPercentage: Value(goals.fatPercentage),
      sugarPercentage: Value(goals.sugarPercentage),
      autoCalorieMode: Value(goals.autoCalorieMode.index),
      customPercentPerMonth: Value(goals.customPercentPerMonth),
      useCustomStartCalories: Value(goals.useCustomStartCalories ? 1 : 0),
      userStartCalories: Value(goals.userStartCalories),
      userAge: Value(goals.userAge),
      userActivityLevel: Value(goals.userActivityLevel),
      userHeight: Value(goals.userHeight),
      useProteinPerKg: Value(goals.useProteinPerKg ? 1 : 0),
      proteinPerKg: Value(goals.proteinPerKg),
      targetWeight: Value(goals.targetWeight),
      targetDate: Value(goals.targetDate),
      targetWeeklyChange: Value(goals.targetWeeklyChange),
    );

    if (rows.isEmpty) {
      await _database.into(_database.goals).insert(companion);
    } else {
      await (_database.update(_database.goals)
            ..where((tbl) => tbl.id.equals(rows.first.id)))
          .write(companion);
    }
  }

  @override
  Future<void> resetGoals() async {
    const defaultGoals = UserGoals();
    await updateGoals(defaultGoals);
  }

  @override
  Future<void> resetDatabase() async {
    await _database.delete(_database.consumedFoods).go();
    await _database.delete(_database.savedMealIngredients).go();
    await _database.delete(_database.savedMeals).go();
    await _database.delete(_database.localFoods).go();
    await _database.delete(_database.favoriteFoods).go();
    await _database.delete(_database.foodUsage).go();
    await _database.delete(_database.offlineQueue).go();
    await _database.delete(_database.weightEntries).go();
    await _database.delete(_database.healthRecords).go();
    await _database.delete(_database.dailyHealthAggregates).go();
    await _database.delete(_database.sleepSessions).go();
    await _database.delete(_database.workoutRoutePoints).go();
    await _database.delete(_database.workoutSessions).go();
    await _database.delete(_database.cycleDailyLogs).go();
    await _database.delete(_database.periodEntries).go();
    await _database.delete(_database.symptomLogs).go();
    await _database.delete(_database.cyclePredictions).go();
  }

  @override
  Future<String?> getSecureCredential(String key) async {
    await migrateCredentialsFromPreferences();
    return _secureStorage.read(key: key);
  }

  @override
  Future<void> setSecureCredential(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<void> deleteSecureCredential(String key) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> migrateCredentialsFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationMarkerKey) == true) return;

    final legacyEmail = prefs.getString(_userEmailKey);
    final legacyPassword = prefs.getString(_userPasswordKey);
    final secureEmail = await _secureStorage.read(key: _secureEmailKey);
    final securePassword = await _secureStorage.read(key: _securePasswordKey);

    if (secureEmail == null && legacyEmail != null && legacyEmail.isNotEmpty) {
      await _secureStorage.write(key: _secureEmailKey, value: legacyEmail);
    }
    if (securePassword == null &&
        legacyPassword != null &&
        legacyPassword.isNotEmpty) {
      await _secureStorage.write(
        key: _securePasswordKey,
        value: legacyPassword,
      );
    }

    final migratedEmail = await _secureStorage.read(key: _secureEmailKey);
    final migratedPassword = await _secureStorage.read(key: _securePasswordKey);
    final hasCredentials = migratedEmail != null || migratedPassword != null;
    if (hasCredentials || (legacyEmail == null && legacyPassword == null)) {
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userPasswordKey);
      await prefs.setBool(_migrationMarkerKey, true);
    }
  }

  @override
  Future<List<String>?> getDashboardCardOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_dashboardCardOrderKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      _logger.warning('Fehler beim Dekodieren der Dashboard-Reihenfolge: $e');
    }
    return null;
  }

  @override
  Future<void> setDashboardCardOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dashboardCardOrderKey, jsonEncode(order));
  }

  @override
  Future<Map<String, bool>?> getDashboardCardVisibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_dashboardCardVisibilityKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value == true),
        );
      }
    } catch (e) {
      _logger.warning(
        'Fehler beim Dekodieren der Dashboard-Sichtbarkeiten: $e',
      );
    }
    return null;
  }

  @override
  Future<void> setDashboardCardVisibility(Map<String, bool> visibility) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dashboardCardVisibilityKey, jsonEncode(visibility));
  }

  @override
  Future<void> resetDashboardConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dashboardCardOrderKey);
    await prefs.remove(_dashboardCardVisibilityKey);
  }
}
