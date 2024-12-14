// lib/models/consumed_food_item.dart
import 'food_item.dart';

class ConsumedFoodItem {
  final int? id;
  final FoodItem food;
  final int quantity;
  final DateTime date;
  final String mealName;

  ConsumedFoodItem({
    this.id,
    required this.food,
    required this.quantity,
    required this.date,
    required this.mealName,
  });

  ConsumedFoodItem copyWith({
    int? id,
    FoodItem? food,
    int? quantity,
    DateTime? date,
    String? mealName,
  }) {
    return ConsumedFoodItem(
      id: id ?? this.id,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      mealName: mealName ?? this.mealName,
    );
  }

  factory ConsumedFoodItem.fromJson(Map<String, dynamic> json) {
    return ConsumedFoodItem(
      id: json['id'],
      food: FoodItem.fromJson(json['food']),
      quantity: json['quantity'],
      date: DateTime.parse(json['date']),
      mealName: json['meal_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food': food.toJson(),
      'quantity': quantity,
      'date': date.toIso8601String(),
      'meal_name': mealName,
    };
  }
}
