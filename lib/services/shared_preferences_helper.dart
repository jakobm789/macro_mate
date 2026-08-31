import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPreferencesHelper {
  static const String darkModeKey = 'dark_mode';
  static const String userEmailKey = 'user_email';
  static const String userPasswordKey = 'user_password';
  static const String _secureEmailKey = 'credential_email';
  static const String _securePasswordKey = 'credential_password';
  static const String _migrationMarkerKey = 'credentials_secure_migration_v1';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> saveDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, isDarkMode);
  }

  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(darkModeKey) ?? false;
  }

  static Future<void> saveUserEmail(String email) async {
    await _secureStorage.write(key: _secureEmailKey, value: email);
  }

  static Future<void> saveUserPassword(String password) async {
    await _secureStorage.write(key: _securePasswordKey, value: password);
  }

  static Future<String?> loadUserEmail() async {
    await migrateLegacyCredentials();
    return _secureStorage.read(key: _secureEmailKey);
  }

  static Future<String?> loadUserPassword() async {
    await migrateLegacyCredentials();
    return _secureStorage.read(key: _securePasswordKey);
  }

  static Future<void> clearUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userEmailKey);
    await prefs.remove(userPasswordKey);
    await _secureStorage.delete(key: _secureEmailKey);
    await _secureStorage.delete(key: _securePasswordKey);
    await prefs.remove(_migrationMarkerKey);
  }

  /// Moves credentials written by older releases out of SharedPreferences.
  ///
  /// The legacy values are removed only after both secure writes complete. A
  /// failed write therefore leaves the old login usable for a later retry.
  static Future<void> migrateLegacyCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationMarkerKey) == true) return;

    final legacyEmail = prefs.getString(userEmailKey);
    final legacyPassword = prefs.getString(userPasswordKey);
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
      await prefs.remove(userEmailKey);
      await prefs.remove(userPasswordKey);
      await prefs.setBool(_migrationMarkerKey, true);
    }
  }
}
