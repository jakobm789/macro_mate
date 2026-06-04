import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/models/food_analysis_result.dart';

void main() {
  test('parses total portion values and normalizes to per-100g food item', () {
    final result = FoodAnalysisResult.fromJson({
      'name': 'Pasta',
      'brand': 'Unbekannt',
      'estimated_weight_grams': 250,
      'total_calories': 500,
      'total_protein': 20.0,
      'total_carbs': 75.0,
      'total_fat': 12.5,
      'total_sugar': 5.0,
      'confidence': 0.8,
    });

    expect(result.totalCalories, 500);
    expect(result.totalProtein, 20.0);

    final food = result.toFoodItem();
    expect(food.caloriesPer100g, 200);
    expect(food.proteinPer100g, 8.0);
    expect(food.carbsPer100g, 30.0);
    expect(food.fatPer100g, 5.0);
    expect(food.sugarPer100g, 2.0);
  });

  test('corrects contradictory totals from ingredient sum', () {
    final result = FoodAnalysisResult.fromJson({
      'name': 'Haferflocken-Porridge mit Banane und Proteinpulver',
      'brand': 'Unbekannt',
      'estimated_weight_grams': 420,
      'total_calories': 650,
      'total_protein': 55.0,
      'total_carbs': 95.0,
      'total_fat': 8.0,
      'total_sugar': 35.0,
      'confidence': 0.8,
      'ingredients': [
        {
          'name': 'Haferflocken',
          'grams': 200,
          'calories': 760,
          'protein': 27.0,
          'carbs': 120.0,
          'fat': 14.0,
          'sugar': 2.0,
        },
        {
          'name': 'Banane',
          'grams': 120,
          'calories': 110,
          'protein': 1.3,
          'carbs': 27.0,
          'fat': 0.4,
          'sugar': 14.0,
        },
        {
          'name': 'Proteinpulver',
          'grams': 70,
          'calories': 260,
          'protein': 55.0,
          'carbs': 6.0,
          'fat': 3.0,
          'sugar': 3.0,
        },
        {
          'name': 'Milch',
          'grams': 30,
          'calories': 20,
          'protein': 1.0,
          'carbs': 1.5,
          'fat': 1.0,
          'sugar': 1.5,
        },
      ],
    });

    expect(result.totalsCorrectedFromIngredients, isTrue);
    expect(result.totalCalories, 1150);
    expect(result.totalProtein, closeTo(84.3, 0.01));
    expect(result.totalCarbs, closeTo(154.5, 0.01));
    expect(result.totalFat, closeTo(18.4, 0.01));
    expect(result.totalSugar, closeTo(20.5, 0.01));
  });

  test('keeps reported totals when ingredient sum is close', () {
    final result = FoodAnalysisResult.fromJson({
      'name': 'Pasta',
      'estimated_weight_grams': 250,
      'total_calories': 500,
      'total_protein': 20.0,
      'total_carbs': 75.0,
      'total_fat': 12.5,
      'total_sugar': 5.0,
      'confidence': 0.8,
      'ingredients': [
        {
          'name': 'Nudeln',
          'grams': 220,
          'calories': 430,
          'protein': 16.0,
          'carbs': 70.0,
          'fat': 6.0,
          'sugar': 3.0,
        },
        {
          'name': 'Sauce',
          'grams': 30,
          'calories': 55,
          'protein': 2.0,
          'carbs': 4.0,
          'fat': 4.0,
          'sugar': 2.0,
        },
      ],
    });

    expect(result.totalsCorrectedFromIngredients, isFalse);
    expect(result.totalCalories, 500);
  });
}
