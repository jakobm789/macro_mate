import '../../../models/consumed_food_item.dart';
import '../../../models/food_item.dart';
import '../../../models/saved_meal.dart';

abstract interface class NutritionRepository {
  Future<Map<String, List<ConsumedFoodItem>>> getDailyFoods(String date);

  Future<int> addConsumedFood({
    required String date,
    required String mealName,
    required int foodId,
    required int quantity,
  });

  Future<void> updateConsumedFoodQuantity({
    required int id,
    required int quantity,
  });

  Future<void> deleteConsumedFood(int id);

  Future<void> clearDay(String date);

  Future<void> copyMeal({
    required String fromDate,
    required String toDate,
    required String mealName,
  });

  Future<List<FoodItem>> searchFoods(String query);

  Future<FoodItem?> getFoodByBarcode(String barcode);

  Future<FoodItem?> getFoodById(int id);

  Future<FoodItem> saveFood(FoodItem food);

  Future<void> updateFood(FoodItem food);

  Future<void> deleteFood(int id);

  Future<List<FoodItem>> getFavoriteFoods();

  Future<bool> isFavorite(int foodId);

  Future<bool> toggleFavorite(int foodId);

  Future<List<FoodItem>> getFrequentFoods({int limit = 20});

  Future<void> recordFoodUsage(int foodId, int quantity);

  Future<List<SavedMeal>> getSavedMeals();

  Future<SavedMeal> saveMeal({
    required String name,
    required String defaultMealName,
    required List<Map<String, dynamic>> ingredients,
    int? recipeTotalWeight,
  });

  Future<void> deleteSavedMeal(int id);

  Future<List<Map<String, dynamic>>> getOfflineQueue();

  Future<int> addToOfflineQueue(String actionType, String payload);

  Future<void> removeFromOfflineQueue(int id);

  Future<void> clearOfflineQueue();
}
