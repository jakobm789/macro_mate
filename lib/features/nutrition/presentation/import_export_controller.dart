import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/logging/app_logger.dart';
import '../../../models/consumed_food_item.dart';
import '../../../models/food_item.dart';
import 'nutrition_controller.dart';

class ImportExportController extends ChangeNotifier {
  ImportExportController({AppLogger logger = const AppLogger()})
      : _logger = logger;

  final AppLogger _logger;

  String buildMealSharePayload({
    required String mealName,
    required List<ConsumedFoodItem> items,
  }) {
    final payload = {
      'type': 'macromate_meal_share',
      'version': 1,
      'mealName': mealName,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'items': items
          .map((i) => {
                'food': i.food.toMap(),
                'quantity': i.quantity,
              })
          .toList(),
    };
    return jsonEncode(payload);
  }

  Future<int> importMealSharePayload({
    required String payloadJson,
    required NutritionController nutritionController,
    String? targetMealName,
    DateTime? targetDate,
  }) async {
    try {
      final dynamic data = jsonDecode(payloadJson);
      if (data is! Map || data['items'] is! List) {
        throw const FormatException('Ungültiges Mahlzeiten-Payload-Format.');
      }

      final mealName =
          targetMealName ?? (data['mealName'] as String? ?? 'snacks');
      final date = targetDate ?? nutritionController.currentDate;
      final items = data['items'] as List;
      var count = 0;

      for (final item in items) {
        if (item is Map) {
          final foodMap = Map<String, dynamic>.from(item['food'] ?? {});
          final food = FoodItem.fromMap(foodMap);
          final savedFood = await nutritionController.saveCustomFood(food);
          final qty = (item['quantity'] as num?)?.toInt() ?? 100;

          await nutritionController.addConsumedFood(
            mealName: mealName,
            food: savedFood,
            quantity: qty,
            date: date,
          );
          count++;
        }
      }
      return count;
    } catch (e) {
      _logger.error('import_meal_share_payload', e);
      return 0;
    }
  }
}
