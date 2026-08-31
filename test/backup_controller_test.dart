import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/backup/presentation/backup_controller.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/health/data/drift_health_repository.dart';
import 'package:macro_mate/features/health/data/health_connect_source.dart';
import 'package:macro_mate/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:macro_mate/features/settings/data/drift_settings_repository.dart';
import 'package:macro_mate/features/weight/data/drift_weight_repository.dart';
import 'package:macro_mate/models/food_item.dart';
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

  const testPassword = 'StrongPassword123!';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
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

  group('BackupController', () {
    test('exports, inspects, and restores full backup successfully', () async {
      // Seed data
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
      await weightRepo.add(day: DateTime(2026, 8, 15), kilograms: 75.5);
      await cycleRepo.addPeriod(
        startDay: DateTime(2026, 8, 1),
        endDay: DateTime(2026, 8, 5),
      );

      // Export
      final encrypted = await backupController.exportBackup(
        password: testPassword,
      );
      expect(encrypted, isNotEmpty);
      expect(encrypted.contains('macromate-backup-encrypted'), isTrue);

      // Inspect
      final preview = await backupController.inspectBackup(
        encryptedJson: encrypted,
        password: testPassword,
      );
      expect(preview['valid'], isTrue);
      expect(preview['foods_count'], greaterThanOrEqualTo(1));
      expect(preview['weights_count'], 1);
      expect(preview['cycle_periods_count'], 1);

      // Wipe db and restore
      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      final nutritionRepo2 = DriftNutritionRepository(database: db2);
      final weightRepo2 = DriftWeightRepository(database: db2);
      final settingsRepo2 = DriftSettingsRepository(database: db2);
      final cycleRepo2 = DriftCycleRepository(database: db2);
      final healthRepo2 = DriftHealthRepository(database: db2, source: HealthConnectSource());

      final backupController2 = BackupController(
        database: db2,
        nutritionRepository: nutritionRepo2,
        weightRepository: weightRepo2,
        settingsRepository: settingsRepo2,
        cycleRepository: cycleRepo2,
        healthRepository: healthRepo2,
      );

      final success = await backupController2.restoreBackup(
        encryptedJson: encrypted,
        password: testPassword,
      );
      expect(success, isTrue);

      final foods2 = await nutritionRepo2.searchFoods('Haferflocken');
      expect(foods2, isNotEmpty);
      expect(foods2.first.name, 'Haferflocken');

      final weights2 = await weightRepo2.list();
      expect(weights2.length, 1);
      expect(weights2.first.kilograms, 75.5);

      final periods2 = await cycleRepo2.periods();
      expect(periods2.length, 1);
      expect(periods2.first.startDay.year, 2026);

      await db2.close();
    });

    test('rejects restore with wrong password', () async {
      final encrypted = await backupController.exportBackup(
        password: testPassword,
      );

      expect(
        () => backupController.inspectBackup(
          encryptedJson: encrypted,
          password: 'WrongPassword!',
        ),
        throwsA(anything),
      );
    });

    test('exports selective categories only', () async {
      await weightRepo.add(day: DateTime(2026, 8, 20), kilograms: 80.0);
      await cycleRepo.addPeriod(
        startDay: DateTime(2026, 8, 10),
        endDay: DateTime(2026, 8, 14),
      );

      final encrypted = await backupController.exportBackup(
        password: testPassword,
        categories: {'weights'},
      );

      final preview = await backupController.inspectBackup(
        encryptedJson: encrypted,
        password: testPassword,
      );
      expect(preview['weights_count'], 1);
      expect(preview['cycle_periods_count'], 0);
    });
  });
}
