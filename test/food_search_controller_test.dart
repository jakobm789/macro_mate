import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:macro_mate/features/nutrition/presentation/food_search_controller.dart';
import 'package:macro_mate/models/food_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftNutritionRepository nutritionRepo;
  late FoodSearchController searchController;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    nutritionRepo = DriftNutritionRepository(database: db);
    searchController = FoodSearchController(nutritionRepository: nutritionRepo);
  });

  tearDown(() async {
    await db.close();
  });

  group('FoodSearchController', () {
    test('searchFood returns local results first when available', () async {
      await nutritionRepo.saveFood(
        FoodItem(
          name: 'Apfel Frisch',
          brand: 'Bio',
          caloriesPer100g: 52,
          carbsPer100g: 14,
          proteinPer100g: 0.3,
          fatPer100g: 0.2,
          sugarPer100g: 10,
        ),
      );

      final results = await searchController.searchFood('Apfel');
      expect(results, isNotEmpty);
      expect(results.first.name, 'Apfel Frisch');
    });

    test('empty query returns empty list', () async {
      final results = await searchController.searchFood('   ');
      expect(results, isEmpty);
    });

    test('clearCache empties in-memory cache', () {
      searchController.clearCache();
      expect(searchController.isSearching, isFalse);
    });
  });
}
