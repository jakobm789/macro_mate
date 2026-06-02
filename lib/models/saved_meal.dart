import 'food_item.dart';

class SavedMealIngredient {
  final int? id;
  final int savedMealId;
  final FoodItem food;
  final int quantity;

  SavedMealIngredient({
    this.id,
    required this.savedMealId,
    required this.food,
    required this.quantity,
  });

  SavedMealIngredient copyWith({
    int? id,
    int? savedMealId,
    FoodItem? food,
    int? quantity,
  }) {
    return SavedMealIngredient(
      id: id ?? this.id,
      savedMealId: savedMealId ?? this.savedMealId,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
    );
  }
}

class SavedMeal {
  final int? id;
  final String name;
  final String defaultMealName;
  final DateTime createdAt;
  final List<SavedMealIngredient> ingredients;
  final int? recipeTotalWeight;

  SavedMeal({
    this.id,
    required this.name,
    required this.defaultMealName,
    DateTime? createdAt,
    this.ingredients = const [],
    this.recipeTotalWeight,
  }) : createdAt = createdAt ?? DateTime.now();

  int get totalQuantity =>
      ingredients.fold(0, (sum, ingredient) => sum + ingredient.quantity);

  double get calories => ingredients.fold(
    0.0,
    (sum, ingredient) =>
        sum + (ingredient.food.caloriesPer100g * ingredient.quantity) / 100.0,
  );

  bool get isRecipe => recipeTotalWeight != null && recipeTotalWeight! > 0;
}
