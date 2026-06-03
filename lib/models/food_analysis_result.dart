// lib/models/food_analysis_result.dart
import 'food_item.dart';

/// Ergebnis einer AI-gestützten Lebensmittelanalyse.
///
/// Enthält Nährwerte pro 100g (passend zu [FoodItem]) sowie eine
/// geschätzte Portionsgröße und Konfidenz-Score.
class FoodAnalysisResult {
  final String name;
  final String brand;
  final int estimatedWeightGrams;
  final int caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double sugarPer100g;
  final double confidence;
  final String? notes;

  const FoodAnalysisResult({
    required this.name,
    required this.brand,
    required this.estimatedWeightGrams,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.sugarPer100g,
    required this.confidence,
    this.notes,
  });

  /// Confidence unter 0.7 gilt als unsichere Schätzung → Fallback-UI.
  bool get isLowConfidence => confidence < 0.7;

  /// Konvertiert zu [FoodItem] ohne ID (wird beim Remote-Insert zugewiesen).
  FoodItem toFoodItem() => FoodItem(
        name: name,
        brand: brand.isEmpty ? 'Unbekannt' : brand,
        caloriesPer100g: caloriesPer100g,
        proteinPer100g: proteinPer100g,
        carbsPer100g: carbsPer100g,
        fatPer100g: fatPer100g,
        sugarPer100g: sugarPer100g,
        source: 'ai',
      );

  /// Erstellt ein [FoodAnalysisResult] aus der JSON-Antwort von GPT.
  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      name: json['name'] as String? ?? 'Unbekanntes Lebensmittel',
      brand: json['brand'] as String? ?? 'Unbekannt',
      estimatedWeightGrams:
          _parseIntSafe(json['estimated_weight_grams'], fallback: 100),
      caloriesPer100g:
          _parseIntSafe(json['calories_per_100g'], fallback: 0),
      proteinPer100g:
          _parseDoubleSafe(json['protein_per_100g'], fallback: 0.0),
      carbsPer100g:
          _parseDoubleSafe(json['carbs_per_100g'], fallback: 0.0),
      fatPer100g:
          _parseDoubleSafe(json['fat_per_100g'], fallback: 0.0),
      sugarPer100g:
          _parseDoubleSafe(json['sugar_per_100g'], fallback: 0.0),
      confidence:
          _parseDoubleSafe(json['confidence'], fallback: 0.5).clamp(0.0, 1.0),
      notes: json['notes'] as String?,
    );
  }

  FoodAnalysisResult copyWith({
    String? name,
    String? brand,
    int? estimatedWeightGrams,
    int? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    double? sugarPer100g,
    double? confidence,
    String? notes,
  }) {
    return FoodAnalysisResult(
      name: name ?? this.name,
      brand: brand ?? this.brand,
      estimatedWeightGrams: estimatedWeightGrams ?? this.estimatedWeightGrams,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      sugarPer100g: sugarPer100g ?? this.sugarPer100g,
      confidence: confidence ?? this.confidence,
      notes: notes ?? this.notes,
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
