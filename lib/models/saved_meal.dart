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

  Map<String, dynamic> toMap() => {
        'id': id,
        'saved_meal_id': savedMealId,
        'food': food.toMap(),
        'quantity': quantity,
      };

  factory SavedMealIngredient.fromMap(Map<String, dynamic> map) =>
      SavedMealIngredient(
        id: map['id'] as int?,
        savedMealId: (map['saved_meal_id'] as num?)?.toInt() ?? 0,
        food: FoodItem.fromMap(Map<String, dynamic>.from(map['food'] ?? {})),
        quantity: (map['quantity'] as num?)?.toInt() ?? 100,
      );
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
            sum +
            (ingredient.food.caloriesPer100g * ingredient.quantity) / 100.0,
      );

  bool get isRecipe => recipeTotalWeight != null && recipeTotalWeight! > 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'defaultMealName': defaultMealName,
        'createdAt': createdAt.toIso8601String(),
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
        'recipeTotalWeight': recipeTotalWeight,
      };

  factory SavedMeal.fromMap(Map<String, dynamic> map) => SavedMeal(
        id: map['id'] as int?,
        name: map['name'] as String? ?? 'Mahlzeit',
        defaultMealName: map['defaultMealName'] as String? ?? 'snacks',
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'] as String)
            : null,
        ingredients: (map['ingredients'] as List?)
                ?.map((i) => SavedMealIngredient.fromMap(
                    Map<String, dynamic>.from(i as Map)))
                .toList() ??
            [],
        recipeTotalWeight: (map['recipeTotalWeight'] as num?)?.toInt(),
      );
}
