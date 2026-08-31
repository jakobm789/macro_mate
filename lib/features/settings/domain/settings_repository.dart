import 'settings_models.dart';

abstract interface class SettingsRepository {
  Future<UserSettings> getSettings();

  Future<void> updateSettings(UserSettings settings);

  Future<UserGoals> getGoals();

  Future<void> updateGoals(UserGoals goals);

  Future<void> resetGoals();

  Future<void> resetDatabase();

  Future<String?> getSecureCredential(String key);

  Future<void> setSecureCredential(String key, String value);

  Future<void> deleteSecureCredential(String key);

  Future<void> migrateCredentialsFromPreferences();

  Future<List<String>?> getDashboardCardOrder();

  Future<void> setDashboardCardOrder(List<String> order);

  Future<Map<String, bool>?> getDashboardCardVisibility();

  Future<void> setDashboardCardVisibility(Map<String, bool> visibility);

  Future<void> resetDashboardConfig();
}
