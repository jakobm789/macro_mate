import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/backup/presentation/backup_controller.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/health/data/drift_health_repository.dart';
import 'package:macro_mate/features/health/data/health_connect_source.dart';
import 'package:macro_mate/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:macro_mate/features/settings/data/drift_settings_repository.dart';
import 'package:macro_mate/features/settings/presentation/settings_controller.dart';
import 'package:macro_mate/features/weight/data/drift_weight_repository.dart';
import 'package:macro_mate/models/food_item.dart';
import 'package:macro_mate/services/encrypted_backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftNutritionRepository nutritionRepo;
  late DriftWeightRepository weightRepo;
  late DriftSettingsRepository settingsRepo;
  late DriftCycleRepository cycleRepo;
  late DriftHealthRepository healthRepo;
  late BackupController backupController;
  final Map<String, String> secureStorageMock = {};

  const testPassword = 'StrongTestPassword123!';

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
    nutritionRepo = DriftNutritionRepository(database: db);
    weightRepo = DriftWeightRepository(database: db);
    settingsRepo = DriftSettingsRepository(database: db);
    cycleRepo = DriftCycleRepository(database: db);
    healthRepo = DriftHealthRepository(database: db, source: HealthConnectSource());

    backupController = BackupController(
      database: db,
      nutritionRepository: nutritionRepo,
      weightRepository: weightRepo,
      settingsRepository: settingsRepo,
      cycleRepository: cycleRepo,
      healthRepository: healthRepo,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Backup End-to-End & Tamper-Proofing', () {
    test('selective category export and restore does not overwrite unselected tables', () async {
      // Seed data in DB 1
      await nutritionRepo.saveFood(
        FoodItem(
          name: 'Haferflocken',
          brand: 'Kölln',
          caloriesPer100g: 370,
          carbsPer100g: 59,
          proteinPer100g: 13,
          fatPer100g: 7,
          sugarPer100g: 1,
        ),
      );
      await weightRepo.add(day: DateTime(2026, 8, 1), kilograms: 75.0);

      // Export only weights
      final backupWeightsOnly = await backupController.exportBackup(
        password: testPassword,
        categories: {'weights'},
      );

      // DB 2 has existing nutrition item and old weight
      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      final nutritionRepo2 = DriftNutritionRepository(database: db2);
      final weightRepo2 = DriftWeightRepository(database: db2);
      final settingsRepo2 = DriftSettingsRepository(database: db2);
      final cycleRepo2 = DriftCycleRepository(database: db2);
      final healthRepo2 = DriftHealthRepository(database: db2, source: HealthConnectSource());

      await nutritionRepo2.saveFood(
        FoodItem(
          name: 'Apfel',
          brand: 'Bio',
          caloriesPer100g: 52,
          carbsPer100g: 14,
          proteinPer100g: 0.3,
          fatPer100g: 0.2,
          sugarPer100g: 10,
        ),
      );

      final backupController2 = BackupController(
        database: db2,
        nutritionRepository: nutritionRepo2,
        weightRepository: weightRepo2,
        settingsRepository: settingsRepo2,
        cycleRepository: cycleRepo2,
        healthRepository: healthRepo2,
      );

      // Restore weights only
      final success = await backupController2.restoreBackup(
        encryptedJson: backupWeightsOnly,
        password: testPassword,
      );
      expect(success, isTrue);

      // Verify nutrition in DB 2 was NOT wiped or replaced
      final foodsInDb2 = await nutritionRepo2.searchFoods('');
      expect(foodsInDb2.length, 1);
      expect(foodsInDb2.first.name, 'Apfel');

      // Verify weights were restored
      final weightsInDb2 = await weightRepo2.list();
      expect(weightsInDb2.length, 1);
      expect(weightsInDb2.first.kilograms, 75.0);

      await db2.close();
    });

    test('tampered ciphertext fails authentication without modifying database', () async {
      await weightRepo.add(day: DateTime(2026, 8, 10), kilograms: 82.0);

      final backup = await backupController.exportBackup(password: testPassword);
      final envelope = jsonDecode(backup) as Map<String, dynamic>;

      // Tamper ciphertext
      final rawCipher = envelope['ciphertext'] as String;
      envelope['ciphertext'] = '${rawCipher.substring(0, rawCipher.length - 4)}ffff';
      final tamperedJson = jsonEncode(envelope);

      expect(
        () => backupController.inspectBackup(
          encryptedJson: tamperedJson,
          password: testPassword,
        ),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('rejects future schema version cleanly', () async {
      final backup = await backupController.exportBackup(password: testPassword);
      final envelope = jsonDecode(backup) as Map<String, dynamic>;
      envelope['schema_version'] = 9999;
      final futureVersionJson = jsonEncode(envelope);

      expect(
        () => backupController.inspectBackup(
          encryptedJson: futureVersionJson,
          password: testPassword,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('SharedPreferences to SecureStorage migration', () {
    test('migrates legacy credentials from SharedPreferences to FlutterSecureStorage', () async {
      // Seed legacy plain SharedPreferences
      SharedPreferences.setMockInitialValues({
        'user_email': 'legacy_user@macromate.app',
        'user_password': 'legacy_secret_password',
      });

      final controller = SettingsController(repository: settingsRepo);
      await controller.initialize();

      // Verify credentials accessible through secure controller
      final email = await controller.getSavedEmail();
      final pass = await controller.getSavedPassword();

      expect(email, 'legacy_user@macromate.app');
      expect(pass, 'legacy_secret_password');

      // Verify saved in secure storage mock
      expect(secureStorageMock['credential_email'], 'legacy_user@macromate.app');
      expect(secureStorageMock['credential_password'], 'legacy_secret_password');

      // Verify cleared from plain SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('user_password'), isFalse);
    });
  });
}
