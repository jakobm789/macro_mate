// lib/models/food_analysis_result.dart
import 'food_item.dart';

/// Ergebnis einer AI-gestützten Lebensmittelanalyse.
///
/// Enthält Gesamt-Nährwerte für die geschätzte Portion sowie Konfidenz-Score.
class FoodAnalysisResult {
  final String name;
  final String brand;
  final int estimatedWeightGrams;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalSugar;
  final double confidence;
  final String? notes;
  final String? reasoning;
  final List<FoodAnalysisIngredient> ingredients;
  final bool totalsCorrectedFromIngredients;

  const FoodAnalysisResult({
    required this.name,
    required this.brand,
    required this.estimatedWeightGrams,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalSugar,
    required this.confidence,
    this.notes,
    this.reasoning,
    this.ingredients = const [],
    this.totalsCorrectedFromIngredients = false,
  });

  /// Confidence unter 0.7 gilt als unsichere Schätzung → Fallback-UI.
  bool get isLowConfidence => confidence < 0.7;

  /// Konvertiert Gesamtwerte für die Portion in das appweite pro-100g-Format.
  FoodItem toFoodItem() {
    final grams = estimatedWeightGrams <= 0 ? 100 : estimatedWeightGrams;
    final factor = 100.0 / grams;
    return FoodItem(
      name: name,
      brand: brand.isEmpty ? 'Unbekannt' : brand,
      caloriesPer100g: (totalCalories * factor).round(),
      proteinPer100g: totalProtein * factor,
      carbsPer100g: totalCarbs * factor,
      fatPer100g: totalFat * factor,
      sugarPer100g: totalSugar * factor,
      source: 'ai',
    );
  }

  /// Erstellt ein [FoodAnalysisResult] aus der JSON-Antwort des lokalen Modells.
  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    final ingredients = _parseIngredients(json['ingredients']);
    final totalCalories = _parseIntSafe(json['total_calories'], fallback: 0);
    final totalProtein = _parseDoubleSafe(json['total_protein'], fallback: 0.0);
    final totalCarbs = _parseDoubleSafe(json['total_carbs'], fallback: 0.0);
    final totalFat = _parseDoubleSafe(json['total_fat'], fallback: 0.0);
    final totalSugar = _parseDoubleSafe(json['total_sugar'], fallback: 0.0);
    final ingredientCalories = ingredients.fold<int>(
      0,
      (sum, ingredient) => sum + ingredient.calories,
    );
    final ingredientProtein = ingredients.fold<double>(
      0,
      (sum, ingredient) => sum + ingredient.protein,
    );
    final ingredientCarbs = ingredients.fold<double>(
      0,
      (sum, ingredient) => sum + ingredient.carbs,
    );
    final ingredientFat = ingredients.fold<double>(
      0,
      (sum, ingredient) => sum + ingredient.fat,
    );
    final ingredientSugar = ingredients.fold<double>(
      0,
      (sum, ingredient) => sum + ingredient.sugar,
    );
    final shouldUseIngredientTotals = _shouldUseIngredientTotals(
      reportedCalories: totalCalories,
      ingredientCalories: ingredientCalories,
      ingredientCount: ingredients.length,
    );

    return FoodAnalysisResult(
      name: json['name'] as String? ?? 'Unbekanntes Lebensmittel',
      brand: json['brand'] as String? ?? 'Unbekannt',
      estimatedWeightGrams:
          _parseIntSafe(json['estimated_weight_grams'], fallback: 100),
      totalCalories:
          shouldUseIngredientTotals ? ingredientCalories : totalCalories,
      totalProtein:
          shouldUseIngredientTotals ? ingredientProtein : totalProtein,
      totalCarbs: shouldUseIngredientTotals ? ingredientCarbs : totalCarbs,
      totalFat: shouldUseIngredientTotals ? ingredientFat : totalFat,
      totalSugar: shouldUseIngredientTotals ? ingredientSugar : totalSugar,
      confidence:
          _parseDoubleSafe(json['confidence'], fallback: 0.5).clamp(0.0, 1.0),
      notes: json['notes'] as String?,
      reasoning: json['reasoning'] as String?,
      ingredients: ingredients,
      totalsCorrectedFromIngredients: shouldUseIngredientTotals,
    );
  }

  FoodAnalysisResult copyWith({
    String? name,
    String? brand,
    int? estimatedWeightGrams,
    int? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    double? totalSugar,
    double? confidence,
    String? notes,
    String? reasoning,
    List<FoodAnalysisIngredient>? ingredients,
    bool? totalsCorrectedFromIngredients,
  }) {
    return FoodAnalysisResult(
      name: name ?? this.name,
      brand: brand ?? this.brand,
      estimatedWeightGrams: estimatedWeightGrams ?? this.estimatedWeightGrams,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalSugar: totalSugar ?? this.totalSugar,
      confidence: confidence ?? this.confidence,
      notes: notes ?? this.notes,
      reasoning: reasoning ?? this.reasoning,
      ingredients: ingredients ?? this.ingredients,
      totalsCorrectedFromIngredients:
          totalsCorrectedFromIngredients ?? this.totalsCorrectedFromIngredients,
    );
  }

  /// Sichere int-Konvertierung: akzeptiert int, double und String.
  static int _parseIntSafe(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  /// Sichere double-Konvertierung: akzeptiert int, double und String.
  static double _parseDoubleSafe(dynamic value, {required double fallback}) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static List<FoodAnalysisIngredient> _parseIngredients(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((entry) => FoodAnalysisIngredient.fromJson(
              Map<String, dynamic>.from(entry),
            ))
        .where((ingredient) => ingredient.name.trim().isNotEmpty)
        .toList(growable: false);
  }

  static bool _shouldUseIngredientTotals({
    required int reportedCalories,
    required int ingredientCalories,
    required int ingredientCount,
  }) {
    if (ingredientCount < 2 || ingredientCalories <= 0) return false;
    if (reportedCalories <= 0) return true;
    final difference = (ingredientCalories - reportedCalories).abs();
    final relativeDifference = difference / reportedCalories;
    return difference >= 150 && relativeDifference >= 0.20;
  }
}

class FoodAnalysisIngredient {
  final String name;
  final int grams;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;

  const FoodAnalysisIngredient({
    required this.name,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
  });

  factory FoodAnalysisIngredient.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisIngredient(
      name: json['name'] as String? ?? '',
      grams: FoodAnalysisResult._parseIntSafe(json['grams'], fallback: 0),
      calories: FoodAnalysisResult._parseIntSafe(json['calories'], fallback: 0),
      protein:
          FoodAnalysisResult._parseDoubleSafe(json['protein'], fallback: 0.0),
      carbs: FoodAnalysisResult._parseDoubleSafe(json['carbs'], fallback: 0.0),
      fat: FoodAnalysisResult._parseDoubleSafe(json['fat'], fallback: 0.0),
      sugar: FoodAnalysisResult._parseDoubleSafe(json['sugar'], fallback: 0.0),
    );
  }
}
