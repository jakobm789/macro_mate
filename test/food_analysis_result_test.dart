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
}
