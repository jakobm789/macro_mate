import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:macro_mate/features/nutrition/presentation/import_export_controller.dart';
import 'package:macro_mate/features/nutrition/presentation/nutrition_controller.dart';
import 'package:macro_mate/models/consumed_food_item.dart';
import 'package:macro_mate/models/food_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftNutritionRepository nutritionRepo;
  late NutritionController nutritionController;
  late ImportExportController importExportController;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    nutritionRepo = DriftNutritionRepository(database: db);
    nutritionController = NutritionController(repository: nutritionRepo);
    await nutritionController.initialize();
    importExportController = ImportExportController();
  });

  tearDown(() async {
    await db.close();
  });

  group('ImportExportController', () {
    test('builds and imports meal share payload roundtrip', () async {
      final food = FoodItem(
        id: 1,
        name: 'Reis gekocht',
        brand: 'Basmati',
        caloriesPer100g: 130,
        carbsPer100g: 28,
        proteinPer100g: 2.7,
        fatPer100g: 0.3,
        sugarPer100g: 0.1,
      );

      final items = [
        ConsumedFoodItem(
          id: 1,
          date: DateTime.now(),
          mealName: 'lunch',
          food: food,
          quantity: 200,
        ),
      ];

      final payload = importExportController.buildMealSharePayload(
        mealName: 'lunch',
        items: items,
      );

      expect(payload, contains('macromate_meal_share'));
      expect(payload, contains('Reis gekocht'));

      final importedCount = await importExportController.importMealSharePayload(
        payloadJson: payload,
        nutritionController: nutritionController,
        targetMealName: 'lunch',
      );

      expect(importedCount, 1);
      expect(nutritionController.lunch.length, 1);
      expect(nutritionController.lunch.first.food.name, 'Reis gekocht');
      expect(nutritionController.lunch.first.quantity, 200);
    });

    test('handles invalid JSON gracefully', () async {
      final count = await importExportController.importMealSharePayload(
        payloadJson: 'invalid-json-text',
        nutritionController: nutritionController,
      );
      expect(count, 0);
    });
  });
}
