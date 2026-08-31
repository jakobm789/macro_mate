import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../models/consumed_food_item.dart';
import '../../../models/food_item.dart';
import '../../../models/saved_meal.dart';
import '../domain/nutrition_repository.dart';

class NutritionController extends ChangeNotifier {
  NutritionController({required NutritionRepository repository})
      : _repository = repository;

  final NutritionRepository _repository;

  DateTime _currentDate = DateTime.now();
  DateTime get currentDate => _currentDate;

  List<ConsumedFoodItem> _breakfast = [];
  List<ConsumedFoodItem> _lunch = [];
  List<ConsumedFoodItem> _dinner = [];
  List<ConsumedFoodItem> _snacks = [];

  List<ConsumedFoodItem> get breakfast => List.unmodifiable(_breakfast);
  List<ConsumedFoodItem> get lunch => List.unmodifiable(_lunch);
  List<ConsumedFoodItem> get dinner => List.unmodifiable(_dinner);
  List<ConsumedFoodItem> get snacks => List.unmodifiable(_snacks);

  double _consumedCalories = 0;
  double _consumedCarbs = 0;
  double _consumedProtein = 0;
  double _consumedFat = 0;
  double _consumedSugar = 0;

  double get consumedCalories => _consumedCalories;
  double get consumedCarbs => _consumedCarbs;
  double get consumedProtein => _consumedProtein;
  double get consumedFat => _consumedFat;
  double get consumedSugar => _consumedSugar;

  List<FoodItem> _favoriteFoods = [];
  List<FoodItem> get favoriteFoods => List.unmodifiable(_favoriteFoods);

  List<FoodItem> _frequentFoods = [];
  List<FoodItem> get frequentFoods => List.unmodifiable(_frequentFoods);

  List<SavedMeal> _savedMeals = [];
  List<SavedMeal> get savedMeals => List.unmodifiable(_savedMeals);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String get formattedCurrentDate =>
      DateFormat('yyyy-MM-dd').format(_currentDate);

  Future<void> initialize() async {
    await loadDailyFoods();
    await loadFavorites();
    await loadFrequentFoods();
    await loadSavedMeals();
  }

  Future<void> loadDailyFoods([DateTime? date]) async {
    if (date != null) {
      _currentDate = date;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr = formattedCurrentDate;
      final foodsByMeal = await _repository.getDailyFoods(dateStr);

      _breakfast = foodsByMeal['breakfast'] ?? [];
      _lunch = foodsByMeal['lunch'] ?? [];
      _dinner = foodsByMeal['dinner'] ?? [];
      _snacks = foodsByMeal['snacks'] ?? [];

      _calculateTotals();
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Ernährungsdaten: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateTotals() {
    final all = [..._breakfast, ..._lunch, ..._dinner, ..._snacks];
    _consumedCalories = 0;
    _consumedCarbs = 0;
    _consumedProtein = 0;
    _consumedFat = 0;
    _consumedSugar = 0;

    for (final item in all) {
      final factor = item.quantity / 100.0;
      _consumedCalories += item.food.caloriesPer100g * factor;
      _consumedCarbs += item.food.carbsPer100g * factor;
      _consumedProtein += item.food.proteinPer100g * factor;
      _consumedFat += item.food.fatPer100g * factor;
      _consumedSugar += item.food.sugarPer100g * factor;
    }
  }

  Future<void> addConsumedFood({
    required String mealName,
    required FoodItem food,
    required int quantity,
    DateTime? date,
  }) async {
    final targetDate = date ?? _currentDate;
    final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);

    // Save food if not saved yet
    FoodItem savedFood = food;
    if (savedFood.id == null) {
      savedFood = await _repository.saveFood(savedFood);
    }

    await _repository.addConsumedFood(
      date: dateStr,
      mealName: mealName,
      foodId: savedFood.id!,
      quantity: quantity,
    );

    await _repository.recordFoodUsage(savedFood.id!, quantity);

    if (dateStr == formattedCurrentDate) {
      await loadDailyFoods();
      await loadFrequentFoods();
    }
  }

  Future<void> updateConsumedFoodQuantity(int id, int quantity) async {
    await _repository.updateConsumedFoodQuantity(id: id, quantity: quantity);
    await loadDailyFoods();
  }

  Future<void> deleteConsumedFood(int id) async {
    await _repository.deleteConsumedFood(id);
    await loadDailyFoods();
  }

  Future<void> clearCurrentDay() async {
    await _repository.clearDay(formattedCurrentDate);
    await loadDailyFoods();
  }

  Future<void> copyMealToDate({
    required String mealName,
    required DateTime targetDate,
  }) async {
    final toDateStr = DateFormat('yyyy-MM-dd').format(targetDate);
    await _repository.copyMeal(
      fromDate: formattedCurrentDate,
      toDate: toDateStr,
      mealName: mealName,
    );
    if (toDateStr == formattedCurrentDate) {
      await loadDailyFoods();
    }
  }

  void goToPreviousDay() {
    _currentDate = _currentDate.subtract(const Duration(days: 1));
    loadDailyFoods();
  }

  void goToNextDay() {
    _currentDate = _currentDate.add(const Duration(days: 1));
    loadDailyFoods();
  }

  void setDate(DateTime date) {
    _currentDate = date;
    loadDailyFoods();
  }

  Future<List<FoodItem>> searchFoods(String query) async {
    return await _repository.searchFoods(query);
  }

  Future<FoodItem?> getFoodByBarcode(String barcode) async {
    return await _repository.getFoodByBarcode(barcode);
  }

  Future<FoodItem> saveCustomFood(FoodItem food) async {
    final saved = await _repository.saveFood(food);
    await loadFavorites();
    await loadFrequentFoods();
    return saved;
  }

  Future<void> updateFood(FoodItem food) async {
    await _repository.updateFood(food);
    await loadDailyFoods();
    await loadFavorites();
    await loadFrequentFoods();
  }

  Future<void> deleteFood(int id) async {
    await _repository.deleteFood(id);
    await loadDailyFoods();
    await loadFavorites();
    await loadFrequentFoods();
  }

  Future<void> loadFavorites() async {
    _favoriteFoods = await _repository.getFavoriteFoods();
    notifyListeners();
  }

  Future<bool> toggleFavorite(int foodId) async {
    final result = await _repository.toggleFavorite(foodId);
    await loadFavorites();
    return result;
  }

  Future<void> loadFrequentFoods({int limit = 20}) async {
    _frequentFoods = await _repository.getFrequentFoods(limit: limit);
    notifyListeners();
  }

  Future<void> loadSavedMeals() async {
    _savedMeals = await _repository.getSavedMeals();
    notifyListeners();
  }

  Future<SavedMeal> saveMeal({
    required String name,
    required String defaultMealName,
    required List<Map<String, dynamic>> ingredients,
    int? recipeTotalWeight,
  }) async {
    final saved = await _repository.saveMeal(
      name: name,
      defaultMealName: defaultMealName,
      ingredients: ingredients,
      recipeTotalWeight: recipeTotalWeight,
    );
    await loadSavedMeals();
    return saved;
  }

  Future<void> deleteSavedMeal(int id) async {
    await _repository.deleteSavedMeal(id);
    await loadSavedMeals();
  }
}
