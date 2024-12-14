// lib/models/app_state.dart
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';

class AppState extends ChangeNotifier {
  List<ConsumedFoodItem> breakfast = [];
  List<ConsumedFoodItem> lunch = [];
  List<ConsumedFoodItem> dinner = [];
  List<ConsumedFoodItem> snacks = [];

  double consumedCalories = 0.0;
  double consumedCarbs = 0.0;
  double consumedProtein = 0.0;
  double consumedFat = 0.0;
  double consumedSugar = 0.0;

  DateTime currentDate = DateTime.now();

  int dailyCalorieGoal = 2000;
  double dailyCarbGoal = 250.0;
  double dailyProteinGoal = 150.0;
  double dailyFatGoal = 70.0;
  int dailySugarGoalPercentage = 20;

  bool isDarkMode = false;

  List<FoodItem> last20FoodItems = [];

  AppState() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadGoals();
    await loadDarkMode();
    await loadLast20FoodItems();
    await loadConsumedFoods();
    notifyListeners();
  }

  Future<void> loadLast20FoodItems() async {
    try {
      last20FoodItems = await DatabaseHelper().getLastAddedFoodItems(20);
    } catch (e) {
      print('Fehler beim Laden der letzten 20 FoodItems: $e');
    }
  }

  Future<void> loadConsumedFoods() async {
    try {
      List<ConsumedFoodItem> consumedFoods = await DatabaseHelper().getConsumedFoods(currentDate);
      breakfast = consumedFoods.where((food) => food.mealName == 'Frühstück').toList();
      lunch = consumedFoods.where((food) => food.mealName == 'Mittagessen').toList();
      dinner = consumedFoods.where((food) => food.mealName == 'Abendessen').toList();
      snacks = consumedFoods.where((food) => food.mealName == 'Snacks').toList();

      _calculateConsumedMacros();
    } catch (e) {
      print('Fehler beim Laden der konsumierten Lebensmittel: $e');
    }
  }

  void _calculateConsumedMacros() {
    consumedCalories = 0.0;
    consumedCarbs = 0.0;
    consumedProtein = 0.0;
    consumedFat = 0.0;
    consumedSugar = 0.0;

    for (var food in breakfast + lunch + dinner + snacks) {
      consumedCalories += (food.food.caloriesPer100g * food.quantity) / 100;
      consumedCarbs += (food.food.carbsPer100g * food.quantity) / 100;
      consumedProtein += (food.food.proteinPer100g * food.quantity) / 100;
      consumedFat += (food.food.fatPer100g * food.quantity) / 100;
      consumedSugar += (food.food.sugarPer100g * food.quantity) / 100;
    }
  }

  double get dailySugarGoalGrams => dailyCarbGoal * dailySugarGoalPercentage / 100;

  Future<void> loadGoals() async {
    try {
      Map<String, dynamic>? goals = await DatabaseHelper().getGoals();
      if (goals != null) {
        dailyCalorieGoal = goals['daily_calories'];
        int carbPerc = goals['carb_percentage'];
        int proteinPerc = goals['protein_percentage'];
        int fatPerc = goals['fat_percentage'];
        int sugarPerc = goals['sugar_percentage'].toInt();

        dailyCarbGoal = (dailyCalorieGoal * carbPerc / 100) / 4.0;
        dailyProteinGoal = (dailyCalorieGoal * proteinPerc / 100) / 4.0;
        dailyFatGoal = (dailyCalorieGoal * fatPerc / 100) / 9.0;
        dailySugarGoalPercentage = sugarPerc;
      }
    } catch (e) {
      print('Fehler beim Laden der Ziele: $e');
    }
  }

  Future<void> updateGoals(int newCalorieGoal, int carbPerc, int proteinPerc, int fatPerc, int sugarPerc) async {
    try {
      dailyCalorieGoal = newCalorieGoal;
      dailyCarbGoal = (dailyCalorieGoal * carbPerc / 100) / 4.0;
      dailyProteinGoal = (dailyCalorieGoal * proteinPerc / 100) / 4.0;
      dailyFatGoal = (dailyCalorieGoal * fatPerc / 100) / 9.0;
      dailySugarGoalPercentage = sugarPerc;

      await DatabaseHelper().saveGoals(
        dailyCalories: dailyCalorieGoal,
        carbPercentage: carbPerc,
        proteinPercentage: proteinPerc,
        fatPercentage: fatPerc,
        sugarPercentage: sugarPerc,
      );

      notifyListeners();
    } catch (e) {
      print('Fehler beim Aktualisieren der Ziele: $e');
    }
  }

  Future<void> loadDarkMode() async {
    try {
      isDarkMode = await DatabaseHelper().getDarkMode();
    } catch (e) {
      print('Fehler beim Laden des Dark Mode Status: $e');
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode = value;
    await DatabaseHelper().saveDarkMode(isDarkMode);
    notifyListeners();
  }

  Future<void> addOrUpdateFood(String mealName, FoodItem food, int quantity, DateTime date) async {
    try {
      int foodId = food.id ?? await DatabaseHelper().insertOrUpdateFoodItem(food);
      FoodItem foodWithId = food.copyWith(id: foodId);

      List<ConsumedFoodItem> mealList = _getMealList(mealName);
      int index = mealList.indexWhere((item) => item.food.id == foodWithId.id);
      if (index != -1) {
        ConsumedFoodItem existingItem = mealList[index];
        if (existingItem.id == null) {
          throw Exception("ConsumedFoodItem hat keine ID.");
        }
        int newQuantity = existingItem.quantity + quantity;

        await DatabaseHelper().updateConsumedFood(existingItem.id!, newQuantity);

        ConsumedFoodItem updatedItem = existingItem.copyWith(quantity: newQuantity);
        mealList[index] = updatedItem;
      } else {
        int consumedFoodId = await DatabaseHelper().insertConsumedFood(date, mealName, foodWithId.id!, quantity);
        ConsumedFoodItem newConsumedFood = ConsumedFoodItem(
          id: consumedFoodId,
          food: foodWithId,
          quantity: quantity,
          date: date,
          mealName: mealName,
        );
        mealList.add(newConsumedFood);
      }

      _calculateConsumedMacros();

      await loadLast20FoodItems();

      notifyListeners();
    } catch (e) {
      print('Fehler beim Hinzufügen/Aktualisieren des Lebensmittels: $e');
      throw e;
    }
  }

  Future<void> updateConsumedFoodItem(ConsumedFoodItem consumedFood, {int? newQuantity, String? newMealName}) async {
    try {
      int updatedQuantity = newQuantity ?? consumedFood.quantity;
      String updatedMealName = newMealName ?? consumedFood.mealName;

      await DatabaseHelper().updateConsumedFood(
        consumedFood.id!,
        updatedQuantity,
        newMealName: updatedMealName,
      );

      List<ConsumedFoodItem> oldMealList = _getMealList(consumedFood.mealName);
      oldMealList.removeWhere((item) => item.id == consumedFood.id);

      List<ConsumedFoodItem> newMealList = _getMealList(updatedMealName);
      ConsumedFoodItem updatedConsumedFood = consumedFood.copyWith(
        quantity: updatedQuantity,
        mealName: updatedMealName,
      );
      newMealList.add(updatedConsumedFood);

      _calculateConsumedMacros();
      await loadLast20FoodItems();
      notifyListeners();
    } catch (e) {
      print('Fehler beim Aktualisieren des konsumierten Lebensmittels: $e');
      throw e;
    }
  }

  List<ConsumedFoodItem> _getMealList(String mealName) {
    switch (mealName) {
      case 'Frühstück':
        return breakfast;
      case 'Mittagessen':
        return lunch;
      case 'Abendessen':
        return dinner;
      case 'Snacks':
        return snacks;
      default:
        return [];
    }
  }

  Future<void> removeFood(String mealName, ConsumedFoodItem consumedFood) async {
    try {
      if (consumedFood.id == null) {
        throw Exception("ConsumedFoodItem hat keine ID.");
      }

      await DatabaseHelper().deleteConsumedFood(consumedFood.id!);

      List<ConsumedFoodItem> mealList = _getMealList(mealName);
      mealList.removeWhere((item) => item.id == consumedFood.id);

      _calculateConsumedMacros();

      notifyListeners();
    } catch (e) {
      print('Fehler beim Entfernen des Lebensmittels: $e');
      throw e;
    }
  }

  Future<void> editFood(FoodItem updatedFood) async {
    try {
      await DatabaseHelper().updateFoodItem(updatedFood);

      List<ConsumedFoodItem> allConsumed = [...breakfast, ...lunch, ...dinner, ...snacks];
      for (int i = 0; i < allConsumed.length; i++) {
        if (allConsumed[i].food.id == updatedFood.id) {
          allConsumed[i] = allConsumed[i].copyWith(food: updatedFood);
        }
      }

      _calculateConsumedMacros();

      await loadLast20FoodItems();

      notifyListeners();
    } catch (e) {
      print('Fehler beim Bearbeiten des Lebensmittels: $e');
      throw e;
    }
  }

  Future<void> deleteFood(FoodItem food) async {
    try {
      if (food.id == null) {
        throw Exception("FoodItem hat keine ID.");
      }

      List<ConsumedFoodItem> allConsumed = [...breakfast, ...lunch, ...dinner, ...snacks];
      for (var consumed in allConsumed) {
        if (consumed.food.id == food.id) {
          await DatabaseHelper().deleteConsumedFood(consumed.id!);
          _getMealList(consumed.mealName).removeWhere((item) => item.id == consumed.id);
        }
      }

      await DatabaseHelper().deleteFoodItem(food.id!);

      _calculateConsumedMacros();

      await loadLast20FoodItems();

      notifyListeners();
    } catch (e) {
      print('Fehler beim Löschen des Lebensmittels: $e');
      throw e;
    }
  }

  Future<void> resetDatabase() async {
    try {
      await DatabaseHelper().resetDatabase();
      breakfast.clear();
      lunch.clear();
      dinner.clear();
      snacks.clear();
      consumedCalories = 0.0;
      consumedCarbs = 0.0;
      consumedProtein = 0.0;
      consumedFat = 0.0;
      consumedSugar = 0.0;
      last20FoodItems.clear();
      currentDate = DateTime.now();
      await _initialize();
    } catch (e) {
      print('Fehler beim Zurücksetzen der Datenbank: $e');
      throw e;
    }
  }
  
  void previousDay() {
    currentDate = currentDate.subtract(Duration(days: 1));
    loadConsumedFoods();
    notifyListeners();
  }

  void nextDay() {
    currentDate = currentDate.add(Duration(days: 1));
    loadConsumedFoods();
    notifyListeners();
  }
}
