// lib/models/food_item.dart
class FoodItem {
  final int? id;
  final String name;
  final String brand;
  final String? barcode;
  final int caloriesPer100g;
  final double fatPer100g;
  final double carbsPer100g;
  final double sugarPer100g;
  final double proteinPer100g;
  final DateTime createdAt;
  final int lastUsedQuantity;

  FoodItem({
    this.id,
    required this.name,
    required this.brand,
    this.barcode,
    required this.caloriesPer100g,
    required this.fatPer100g,
    required this.carbsPer100g,
    required this.sugarPer100g,
    required this.proteinPer100g,
    DateTime? createdAt,
    this.lastUsedQuantity = 100,
  }) : createdAt = createdAt ?? DateTime.now();

  FoodItem copyWith({
    int? id,
    String? name,
    String? brand,
    String? barcode,
    int? caloriesPer100g,
    double? fatPer100g,
    double? carbsPer100g,
    double? sugarPer100g,
    double? proteinPer100g,
    DateTime? createdAt,
    int? lastUsedQuantity,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode?.toLowerCase(),
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      sugarPer100g: sugarPer100g ?? this.sugarPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      createdAt: createdAt ?? this.createdAt,
      lastUsedQuantity: lastUsedQuantity ?? this.lastUsedQuantity,
    );
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      barcode: json['barcode']?.toLowerCase(),
      caloriesPer100g: json['calories_per_100g'],
      fatPer100g: json['fat_per_100g'].toDouble(),
      carbsPer100g: json['carbs_per_100g'].toDouble(),
      sugarPer100g: json['sugar_per_100g'].toDouble(),
      proteinPer100g: json['protein_per_100g'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      lastUsedQuantity: json['last_used_quantity'] ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'barcode': barcode?.toLowerCase(),
      'calories_per_100g': caloriesPer100g,
      'fat_per_100g': fatPer100g,
      'carbs_per_100g': carbsPer100g,
      'sugar_per_100g': sugarPer100g,
      'protein_per_100g': proteinPer100g,
      'created_at': createdAt.toIso8601String(),
      'last_used_quantity': lastUsedQuantity,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      barcode: map['barcode']?.toLowerCase(),
      caloriesPer100g: map['calories_per_100g'],
      fatPer100g: map['fat_per_100g'].toDouble(),
      carbsPer100g: map['carbs_per_100g'].toDouble(),
      sugarPer100g: map['sugar_per_100g'].toDouble(),
      proteinPer100g: map['protein_per_100g'].toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      lastUsedQuantity: map['last_used_quantity'] ?? 100,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'barcode': barcode?.toLowerCase(),
      'calories_per_100g': caloriesPer100g,
      'fat_per_100g': fatPer100g,
      'carbs_per_100g': carbsPer100g,
      'sugar_per_100g': sugarPer100g,
      'protein_per_100g': proteinPer100g,
      'created_at': createdAt.toIso8601String(),
      'last_used_quantity': lastUsedQuantity,
    };
  }
}
