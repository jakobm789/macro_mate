import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/models/consumed_food_item.dart';
import 'package:macro_mate/models/food_item.dart';
import 'package:macro_mate/models/saved_meal.dart';

void main() {
  final createdAt = DateTime.parse('2026-08-31T10:15:30.000Z');
  final food = FoodItem(
    id: 42,
    name: 'Haferflocken',
    brand: 'MacroMate Test',
    barcode: 'ABC-123',
    caloriesPer100g: 370,
    fatPer100g: 7.0,
    carbsPer100g: 60.0,
    sugarPer100g: 1.2,
    proteinPer100g: 13.0,
    createdAt: createdAt,
    lastUsedQuantity: 80,
    source: 'ai',
    isVerified: true,
  );

  test('legacy FoodItem map contract round-trips every persisted field', () {
    final map = food.toMap();
    final restored = FoodItem.fromMap(map);

    expect(map.keys, {
      'id',
      'name',
      'brand',
      'barcode',
      'calories_per_100g',
      'fat_per_100g',
      'carbs_per_100g',
      'sugar_per_100g',
      'protein_per_100g',
      'created_at',
      'last_used_quantity',
      'source',
      'is_verified',
    });
    expect(restored.id, 42);
    expect(restored.barcode, 'abc-123');
    expect(restored.createdAt, createdAt);
    expect(restored.lastUsedQuantity, 80);
    expect(restored.source, 'ai');
    expect(restored.isVerified, isTrue);
  });

  test('legacy consumed-food JSON keeps embedded food and local date', () {
    final entry = ConsumedFoodItem(
      id: 7,
      food: food,
      quantity: 125,
      date: DateTime(2026, 8, 31),
      mealName: 'Frühstück',
    );

    final restored = ConsumedFoodItem.fromJson(entry.toJson());

    expect(restored.id, 7);
    expect(restored.food.id, 42);
    expect(restored.quantity, 125);
    expect(restored.date, DateTime(2026, 8, 31));
    expect(restored.mealName, 'Frühstück');
  });

  test('saved meal totals retain the existing quantity and calorie rules', () {
    final meal = SavedMeal(
      id: 3,
      name: 'Porridge',
      defaultMealName: 'Frühstück',
      recipeTotalWeight: 250,
      ingredients: [
        SavedMealIngredient(
          id: 4,
          savedMealId: 3,
          food: food,
          quantity: 125,
        ),
      ],
    );

    expect(meal.totalQuantity, 125);
    expect(meal.calories, 462.5);
    expect(meal.isRecipe, isTrue);
  });
}
