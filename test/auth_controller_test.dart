import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/auth/presentation/auth_controller.dart';
import 'package:macro_mate/features/settings/data/drift_settings_repository.dart';
import 'package:macro_mate/features/settings/presentation/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftSettingsRepository settingsRepo;
  late SettingsController settingsController;
  late AuthController authController;
  final Map<String, String> secureStorageMock = {};

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    secureStorageMock.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'read') {
          return secureStorageMock[methodCall.arguments['key']];
        } else if (methodCall.method == 'write') {
          secureStorageMock[methodCall.arguments['key'] as String] =
              methodCall.arguments['value'] as String;
          return null;
        } else if (methodCall.method == 'delete') {
          secureStorageMock.remove(methodCall.arguments['key']);
          return null;
        } else if (methodCall.method == 'deleteAll') {
          secureStorageMock.clear();
          return null;
        }
        return null;
      },
    );

    db = AppDatabase.forTesting(NativeDatabase.memory());
    settingsRepo = DriftSettingsRepository(database: db);
    settingsController = SettingsController(repository: settingsRepo);
    await settingsController.initialize();

    authController = AuthController(
      settingsController: settingsController,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('AuthController', () {
    test('initial state is logged out when no credentials saved', () async {
      await authController.initialize();
      expect(authController.isLoggedIn, isFalse);
      expect(authController.currentUserEmail, isNull);
    });

    test('logout clears credentials and sets isLoggedIn to false', () async {
      await settingsController.saveCredentials('test@example.com', 'password123');
      await authController.initialize();

      expect(authController.isLoggedIn, isTrue);
      expect(authController.currentUserEmail, 'test@example.com');

      await authController.logout();
      expect(authController.isLoggedIn, isFalse);
      expect(authController.currentUserEmail, isNull);

      final savedEmail = await settingsController.getSavedEmail();
      expect(savedEmail, isNull);
    });

    test('deleteAccount invokes onLocalReset and clears session', () async {
      await settingsController.saveCredentials('user@test.com', 'secret123');
      await authController.initialize();

      var resetCalled = false;
      final result = await authController.deleteAccount(
        onLocalReset: () async {
          resetCalled = true;
        },
      );

      expect(result, isTrue);
      expect(resetCalled, isTrue);
      expect(authController.isLoggedIn, isFalse);
      expect(authController.currentUserEmail, isNull);
    });
  });
}
