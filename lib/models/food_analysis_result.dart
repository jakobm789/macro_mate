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
    return FoodAnalysisResult(
      name: json['name'] as String? ?? 'Unbekanntes Lebensmittel',
      brand: json['brand'] as String? ?? 'Unbekannt',
      estimatedWeightGrams:
          _parseIntSafe(json['estimated_weight_grams'], fallback: 100),
      totalCalories: _parseIntSafe(json['total_calories'], fallback: 0),
      totalProtein: _parseDoubleSafe(json['total_protein'], fallback: 0.0),
      totalCarbs: _parseDoubleSafe(json['total_carbs'], fallback: 0.0),
      totalFat: _parseDoubleSafe(json['total_fat'], fallback: 0.0),
      totalSugar: _parseDoubleSafe(json['total_sugar'], fallback: 0.0),
      confidence:
          _parseDoubleSafe(json['confidence'], fallback: 0.5).clamp(0.0, 1.0),
      notes: json['notes'] as String?,
      reasoning: json['reasoning'] as String?,
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
}
