import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:macro_mate/models/food_item.dart';

void main() {
  late AppDatabase db;
  late DriftNutritionRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftNutritionRepository(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('saves and searches foods', () async {
    final food1 = FoodItem(
      name: 'Haferflocken',
      brand: 'Kölln',
      barcode: '4000521001004',
      caloriesPer100g: 370,
      fatPer100g: 7.0,
      carbsPer100g: 58.7,
      sugarPer100g: 1.0,
      proteinPer100g: 13.5,
    );

    final saved = await repo.saveFood(food1);
    expect(saved.id, isNotNull);

    final searchByName = await repo.searchFoods('hafer');
    expect(searchByName.length, 1);
    expect(searchByName.first.name, 'Haferflocken');

    final searchByBarcode = await repo.getFoodByBarcode('4000521001004');
    expect(searchByBarcode, isNotNull);
    expect(searchByBarcode!.name, 'Haferflocken');
  });

  test('adds, groups, updates, and deletes consumed foods', () async {
    final food = await repo.saveFood(
      FoodItem(
        name: 'Banane',
        brand: 'Chiquita',
        caloriesPer100g: 89,
        fatPer100g: 0.3,
        carbsPer100g: 22.8,
        sugarPer100g: 12.2,
        proteinPer100g: 1.1,
      ),
    );

    const date = '2026-08-31';

    final id = await repo.addConsumedFood(
      date: date,
      mealName: 'breakfast',
      foodId: food.id!,
      quantity: 120,
    );

    var daily = await repo.getDailyFoods(date);
    expect(daily['breakfast']!.length, 1);
    expect(daily['breakfast']!.first.quantity, 120);
    expect(daily['breakfast']!.first.food.name, 'Banane');

    await repo.updateConsumedFoodQuantity(id: id, quantity: 150);
    daily = await repo.getDailyFoods(date);
    expect(daily['breakfast']!.first.quantity, 150);

    await repo.deleteConsumedFood(id);
    daily = await repo.getDailyFoods(date);
    expect(daily['breakfast']!, isEmpty);
  });

  test('toggles favorite foods and manages frequent food usage', () async {
    final food = await repo.saveFood(
      FoodItem(
        name: 'Magerquark',
        brand: 'Gut&Günstig',
        caloriesPer100g: 68,
        fatPer100g: 0.2,
        carbsPer100g: 4.0,
        sugarPer100g: 4.0,
        proteinPer100g: 12.0,
      ),
    );

    expect(await repo.isFavorite(food.id!), isFalse);
    final favAdded = await repo.toggleFavorite(food.id!);
    expect(favAdded, isTrue);
    expect(await repo.isFavorite(food.id!), isTrue);

    final favs = await repo.getFavoriteFoods();
    expect(favs.length, 1);
    expect(favs.first.name, 'Magerquark');

    await repo.recordFoodUsage(food.id!, 250);
    final frequent = await repo.getFrequentFoods();
    expect(frequent.length, 1);
    expect(frequent.first.name, 'Magerquark');
  });

  test('saves and deletes saved meals / recipes', () async {
    final food1 = await repo.saveFood(
      FoodItem(
        name: 'Reis',
        brand: 'Uncle Ben',
        caloriesPer100g: 130,
        fatPer100g: 0.3,
        carbsPer100g: 28.0,
        sugarPer100g: 0.1,
        proteinPer100g: 2.7,
      ),
    );

    final food2 = await repo.saveFood(
      FoodItem(
        name: 'Hähnchenbrust',
        brand: 'Frisch',
        caloriesPer100g: 120,
        fatPer100g: 1.5,
        carbsPer100g: 0.0,
        sugarPer100g: 0.0,
        proteinPer100g: 26.0,
      ),
    );

    final savedMeal = await repo.saveMeal(
      name: 'Reis mit Hähnchen',
      defaultMealName: 'lunch',
      ingredients: [
        {'food_id': food1.id!, 'quantity': 200},
        {'food_id': food2.id!, 'quantity': 150},
      ],
      recipeTotalWeight: 350,
    );

    expect(savedMeal.id, isNotNull);
    expect(savedMeal.ingredients.length, 2);
    expect(savedMeal.isRecipe, isTrue);

    final meals = await repo.getSavedMeals();
    expect(meals.length, 1);
    expect(meals.first.name, 'Reis mit Hähnchen');

    await repo.deleteSavedMeal(savedMeal.id!);
    final remainingMeals = await repo.getSavedMeals();
    expect(remainingMeals, isEmpty);
  });
}
