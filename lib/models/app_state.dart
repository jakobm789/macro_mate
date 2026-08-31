import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../core/database/app_database.dart';
import '../core/logging/app_logger.dart';
import '../core/notifications/drift_notification_repository.dart';
import '../core/notifications/notification_controller.dart';
import '../core/notifications/notification_models.dart';
import '../core/notifications/notification_repository.dart';
import '../features/activity/presentation/activity_controller.dart';
import '../features/cycle/data/drift_cycle_repository.dart';
import '../features/cycle/domain/cycle_repository.dart';
import '../features/cycle/presentation/cycle_controller.dart';
import '../features/dashboard/presentation/dashboard_controller.dart';
import '../features/health/data/drift_health_repository.dart';
import '../features/health/data/health_connect_source.dart';
import '../features/health/domain/health_repository.dart';
import '../features/health/presentation/health_controller.dart';
import '../features/local_llm/presentation/local_model_controller.dart';
import '../features/nutrition/data/drift_nutrition_repository.dart';
import '../features/nutrition/domain/nutrition_repository.dart';
import '../features/nutrition/presentation/nutrition_controller.dart';
import '../features/settings/data/drift_settings_repository.dart';
import '../features/settings/domain/settings_models.dart';
import '../features/settings/domain/settings_repository.dart';
import '../features/settings/presentation/settings_controller.dart';
import '../features/weight/data/drift_weight_repository.dart';
import '../features/weight/domain/weight_repository.dart';
import '../features/weight/presentation/weight_controller.dart';
import '../models/consumed_food_item.dart';
import '../models/food_item.dart';
import '../models/local_llm_model.dart';
import '../models/saved_meal.dart';
import '../services/encrypted_backup_service.dart';
import '../services/remote_database_service.dart';
import '../services/shared_preferences_helper.dart';

export '../features/settings/domain/settings_models.dart';
export '../models/local_llm_model.dart';
export '../models/saved_meal.dart';


const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org';


class WeightEntry {
  final int? id;
  final DateTime date;
  final double weight;
  WeightEntry({this.id, required this.date, required this.weight});
  WeightEntry copyWith({int? id, DateTime? date, double? weight}) {
    return WeightEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
    );
  }
}

class WeeklyNutritionSummary {
  final double averageCalories;
  final double remainingCalories;
  final double macroAdherence;
  final double weightTrend;

  WeeklyNutritionSummary({
    required this.averageCalories,
    required this.remainingCalories,
    required this.macroAdherence,
    required this.weightTrend,
  });
}

class WeeklyDaySummary {
  final DateTime date;
  final String dayName;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;

  WeeklyDaySummary({
    required this.date,
    required this.dayName,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}

/// AppState serves as a lightweight compatibility facade coordinating
/// dedicated feature controllers and Drift repositories.
class AppState extends ChangeNotifier {
  AppState({
    AppDatabase? database,
    NutritionRepository? nutritionRepository,
    WeightRepository? weightRepository,
    SettingsRepository? settingsRepository,
    HealthRepository? healthRepository,
    CycleRepository? cycleRepository,
    NotificationRepository? notificationRepository,
  }) {
    _database = database ?? AppDatabase();
    _nutritionRepository = nutritionRepository ??
        DriftNutritionRepository(database: _database);
    _weightRepository =
        weightRepository ?? DriftWeightRepository(database: _database);
    _settingsRepository =
        settingsRepository ?? DriftSettingsRepository(database: _database);
    _healthRepository = healthRepository ??
        DriftHealthRepository(
          database: _database,
          source: HealthConnectSource(),
        );
    _cycleRepository =
        cycleRepository ?? DriftCycleRepository(database: _database);
    _notificationRepository = notificationRepository ??
        DriftNotificationRepository(database: _database);

    nutritionController =
        NutritionController(repository: _nutritionRepository);
    weightController = WeightController(repository: _weightRepository);
    healthController = HealthController(repository: _healthRepository);
    activityController = ActivityController(repository: _healthRepository);
    cycleController = CycleController(repository: _cycleRepository);
    settingsController = SettingsController(repository: _settingsRepository);
    localModelController = LocalModelController();
    notificationController =
        NotificationController(repository: _notificationRepository);

    dashboardController = DashboardController(
      nutritionController: nutritionController,
      weightController: weightController,
      healthController: healthController,
      activityController: activityController,
      cycleController: cycleController,
      settingsController: settingsController,
    );

    // Forward notifications from child controllers
    nutritionController.addListener(notifyListeners);
    weightController.addListener(notifyListeners);
    healthController.addListener(notifyListeners);
    activityController.addListener(notifyListeners);
    cycleController.addListener(notifyListeners);
    settingsController.addListener(notifyListeners);
    localModelController.addListener(notifyListeners);
    notificationController.addListener(notifyListeners);
    dashboardController.addListener(notifyListeners);
  }

  late final AppDatabase _database;
  late final NutritionRepository _nutritionRepository;
  late final WeightRepository _weightRepository;
  late final SettingsRepository _settingsRepository;
  late final HealthRepository _healthRepository;
  late final CycleRepository _cycleRepository;
  late final NotificationRepository _notificationRepository;

  late final NutritionController nutritionController;
  late final WeightController weightController;
  late final HealthController healthController;
  late final ActivityController activityController;
  late final CycleController cycleController;
  late final SettingsController settingsController;
  late final LocalModelController localModelController;
  late final DashboardController dashboardController;
  late final NotificationController notificationController;

  final EncryptedBackupService _backupService = EncryptedBackupService();
  final RemoteDatabaseService _remoteService = RemoteDatabaseService();
  final AppLogger _logger = const AppLogger();

  final Map<String, List<FoodItem>> _offSearchCache = {};
  final Map<String, FoodItem?> _offBarcodeCache = {};

  bool isInitialized = false;
  bool isLoggedIn = false;
  String? lastUiError;
  String? mondayPopupMessage;
  int recentFoodLimit = 20;

  // Delegated Nutrition Getters
  List<ConsumedFoodItem> get breakfast => nutritionController.breakfast;
  List<ConsumedFoodItem> get lunch => nutritionController.lunch;
  List<ConsumedFoodItem> get dinner => nutritionController.dinner;
  List<ConsumedFoodItem> get snacks => nutritionController.snacks;
  double get consumedCalories => nutritionController.consumedCalories;
  double get consumedCarbs => nutritionController.consumedCarbs;
  double get consumedProtein => nutritionController.consumedProtein;
  double get consumedFat => nutritionController.consumedFat;
  double get consumedSugar => nutritionController.consumedSugar;
  DateTime get currentDate => nutritionController.currentDate;
  List<FoodItem> get favoriteFoodItems => nutritionController.favoriteFoods;
  List<FoodItem> get last20FoodItems => nutritionController.frequentFoods;
  List<SavedMeal> get savedMeals => nutritionController.savedMeals;
  Set<int> get favoriteFoodIds =>
      nutritionController.favoriteFoods.map((f) => f.id).whereType<int>().toSet();

  // Delegated Settings & Goals Getters & Setters
  int get dailyCalorieGoal => settingsController.goals.dailyCalories;
  set dailyCalorieGoal(int val) => settingsController.updateGoals(
      settingsController.goals.copyWith(dailyCalories: val));
  double get dailyCarbGoal => settingsController.dailyCarbGoal;
  double get dailyProteinGoal => settingsController.dailyProteinGoal;
  double get dailyFatGoal => settingsController.dailyFatGoal;
  int get dailySugarGoalPercentage => settingsController.goals.sugarPercentage;
  double get dailySugarGoalGrams =>
      (dailyCalorieGoal * (dailySugarGoalPercentage / 100.0)) / 4.0;
  bool get isDarkMode => settingsController.isDarkMode;
  Gender get userGender => settingsController.goals.gender;
  set userGender(Gender val) => settingsController.updateGoals(
      settingsController.goals.copyWith(gender: val));
  BmrFormula get bmrFormula => settingsController.goals.bmrFormula;
  set bmrFormula(BmrFormula val) => settingsController.updateGoals(
      settingsController.goals.copyWith(bmrFormula: val));
  AutoCalorieMode get autoMode => settingsController.goals.autoCalorieMode;
  set autoMode(AutoCalorieMode val) => settingsController.updateGoals(
      settingsController.goals.copyWith(autoCalorieMode: val));
  double get customPercentPerMonth =>
      settingsController.goals.customPercentPerMonth;
  set customPercentPerMonth(double val) => settingsController.updateGoals(
      settingsController.goals.copyWith(customPercentPerMonth: val));
  bool get useCustomStartCalories =>
      settingsController.goals.useCustomStartCalories;
  set useCustomStartCalories(bool val) => settingsController.updateGoals(
      settingsController.goals.copyWith(useCustomStartCalories: val));
  int get userStartCalories => settingsController.goals.userStartCalories;
  set userStartCalories(int val) => settingsController.updateGoals(
      settingsController.goals.copyWith(userStartCalories: val));
  int get userAge => settingsController.goals.userAge;
  set userAge(int val) => settingsController.updateGoals(
      settingsController.goals.copyWith(userAge: val));
  double get userActivityLevel => settingsController.goals.userActivityLevel;
  set userActivityLevel(double val) => settingsController.updateGoals(
      settingsController.goals.copyWith(userActivityLevel: val));
  double get userHeight => settingsController.goals.userHeight;
  set userHeight(double val) => settingsController.updateGoals(
      settingsController.goals.copyWith(userHeight: val));
  bool get useProteinPerKg => settingsController.goals.useProteinPerKg;
  set useProteinPerKg(bool val) => settingsController.updateGoals(
      settingsController.goals.copyWith(useProteinPerKg: val));
  double get proteinPerKg => settingsController.goals.proteinPerKg;
  set proteinPerKg(double val) => settingsController.updateGoals(
      settingsController.goals.copyWith(proteinPerKg: val));
  double? get targetWeight => settingsController.goals.targetWeight;
  set targetWeight(double? val) => settingsController.updateGoals(
      settingsController.goals.copyWith(targetWeight: val));
  DateTime? get targetDate => settingsController.goals.targetDate != null
      ? DateTime.tryParse(settingsController.goals.targetDate!)
      : null;
  set targetDate(DateTime? val) => settingsController.updateGoals(
      settingsController.goals.copyWith(
          targetDate:
              val != null ? DateFormat('yyyy-MM-dd').format(val) : null));
  double? get targetWeeklyChange =>
      settingsController.goals.targetWeeklyChange;
  set targetWeeklyChange(double? val) => settingsController.updateGoals(
      settingsController.goals.copyWith(targetWeeklyChange: val));
  bool firstWeekInitialized = true;

  bool get reminderWeighEnabled =>
      settingsController.settings.reminderWeighEnabled;
  TimeOfDay get reminderWeighTime => _parseTimeOfDay(
        settingsController.settings.reminderWeighTime,
        const TimeOfDay(hour: 8, minute: 0),
      );
  TimeOfDay get reminderWeighTimeSecond => _parseTimeOfDay(
        settingsController.settings.reminderWeighTime2,
        const TimeOfDay(hour: 9, minute: 0),
      );
  bool get reminderSupplementEnabled =>
      settingsController.settings.reminderSupplementEnabled;
  TimeOfDay get reminderSupplementTime => _parseTimeOfDay(
        settingsController.settings.reminderSupplementTime,
        const TimeOfDay(hour: 10, minute: 0),
      );
  TimeOfDay get reminderSupplementTimeSecond => _parseTimeOfDay(
        settingsController.settings.reminderSupplementTime2,
        const TimeOfDay(hour: 11, minute: 0),
      );
  bool get reminderMealsEnabled =>
      settingsController.settings.reminderMealsEnabled;
  TimeOfDay get reminderBreakfast => _parseTimeOfDay(
        settingsController.settings.reminderBreakfast,
        const TimeOfDay(hour: 7, minute: 0),
      );
  TimeOfDay get reminderLunch => _parseTimeOfDay(
        settingsController.settings.reminderLunch,
        const TimeOfDay(hour: 12, minute: 30),
      );
  TimeOfDay get reminderDinner => _parseTimeOfDay(
        settingsController.settings.reminderDinner,
        const TimeOfDay(hour: 19, minute: 0),
      );

  set reminderWeighEnabled(bool value) => settingsController.updateSettings(
      settingsController.settings.copyWith(reminderWeighEnabled: value));
  set reminderWeighTime(TimeOfDay value) => settingsController.updateSettings(
      settingsController.settings.copyWith(reminderWeighTime: _formatTimeOfDay(value)));
  set reminderWeighTimeSecond(TimeOfDay value) => settingsController.updateSettings(
      settingsController.settings.copyWith(reminderWeighTime2: _formatTimeOfDay(value)));
  set reminderSupplementEnabled(bool value) => settingsController.updateSettings(
      settingsController.settings.copyWith(reminderSupplementEnabled: value));
  set reminderSupplementTime(TimeOfDay value) => settingsController.updateSettings(
      settingsController.settings.copyWith(reminderSupplementTime: _formatTimeOfDay(value)));
  set reminderSupplementTimeSecond(TimeOfDay value) => settingsController.updateSettings(
      settingsController.settings.copyWith(reminderSupplementTime2: _formatTimeOfDay(value)));
  set reminderMealsEnabled(bool value) => settingsController.updateSettings(
      settingsController.settings.copyWith(reminderMealsEnabled: value));
  set reminderBreakfast(TimeOfDay value) => settingsController.updateSettings(
      settingsController.settings.copyWith(reminderBreakfast: _formatTimeOfDay(value)));
  set reminderLunch(TimeOfDay value) => settingsController.updateSettings(
      settingsController.settings.copyWith(reminderLunch: _formatTimeOfDay(value)));
  set reminderDinner(TimeOfDay value) => settingsController.updateSettings(
      settingsController.settings.copyWith(reminderDinner: _formatTimeOfDay(value)));

  Future<void> saveNotificationSettings({
    bool? reminderWeighEnabled,
    TimeOfDay? reminderWeighTime,
    TimeOfDay? reminderWeighTimeSecond,
    bool? reminderSupplementEnabled,
    TimeOfDay? reminderSupplementTime,
    TimeOfDay? reminderSupplementTimeSecond,
    bool? reminderMealsEnabled,
    TimeOfDay? reminderBreakfast,
    TimeOfDay? reminderLunch,
    TimeOfDay? reminderDinner,
  }) async {
    final updated = settingsController.settings.copyWith(
      reminderWeighEnabled: reminderWeighEnabled,
      reminderWeighTime: reminderWeighTime != null ? _formatTimeOfDay(reminderWeighTime) : null,
      reminderWeighTime2: reminderWeighTimeSecond != null ? _formatTimeOfDay(reminderWeighTimeSecond) : null,
      reminderSupplementEnabled: reminderSupplementEnabled,
      reminderSupplementTime: reminderSupplementTime != null ? _formatTimeOfDay(reminderSupplementTime) : null,
      reminderSupplementTime2: reminderSupplementTimeSecond != null ? _formatTimeOfDay(reminderSupplementTimeSecond) : null,
      reminderMealsEnabled: reminderMealsEnabled,
      reminderBreakfast: reminderBreakfast != null ? _formatTimeOfDay(reminderBreakfast) : null,
      reminderLunch: reminderLunch != null ? _formatTimeOfDay(reminderLunch) : null,
      reminderDinner: reminderDinner != null ? _formatTimeOfDay(reminderDinner) : null,
    );
    await settingsController.updateSettings(updated);
    await scheduleAllNotifications();
  }

  // Delegated Weight Getters
  List<WeightEntry> get weightEntries => weightController.records
      .map((r) => WeightEntry(id: r.id, date: r.day, weight: r.kilograms))
      .toList();

  // Delegated Local Model Getters & Setters
  LocalLlmModel get selectedLocalLlmModel => localModelController.selectedModel;
  set selectedLocalLlmModel(LocalLlmModel model) =>
      localModelController.selectModel(model);
  Future<void> setSelectedLocalLlmModel(LocalLlmModel model) =>
      localModelController.selectModel(model);
  LocalLlmModel? get downloadingLocalLlmModel =>
      isLocalModelDownloadRunning ? selectedLocalLlmModel : null;
  Set<String> installedLocalModelFiles = {};
  bool get isLocalModelDownloadRunning => localModelController.isDownloading;
  int? get localModelDownloadProgress =>
      localModelController.isDownloading ? localModelController.downloadProgress : null;
  String? get localModelDownloadMessage => localModelController.statusMessage;



  @override
  void dispose() {
    nutritionController.removeListener(notifyListeners);
    weightController.removeListener(notifyListeners);
    healthController.removeListener(notifyListeners);
    activityController.removeListener(notifyListeners);
    cycleController.removeListener(notifyListeners);
    settingsController.removeListener(notifyListeners);
    localModelController.removeListener(notifyListeners);
    notificationController.removeListener(notifyListeners);
    dashboardController.removeListener(notifyListeners);

    nutritionController.dispose();
    weightController.dispose();
    healthController.dispose();
    activityController.dispose();
    cycleController.dispose();
    settingsController.dispose();
    localModelController.dispose();
    dashboardController.dispose();
    notificationController.dispose();
    _database.close();
    super.dispose();
  }

  void markInitialized() {
    isInitialized = true;
    notifyListeners();
  }

  void reportUiError(String context, Object error, [StackTrace? stackTrace]) {
    lastUiError = '$context fehlgeschlagen.';
    _logger.error(context, error);
    notifyListeners();
  }

  void clearUiError() {
    lastUiError = null;
    notifyListeners();
  }

  Future<void> initializeCompletely() async {
    await SharedPreferencesHelper.migrateLegacyCredentials();
    await Future.wait([
      nutritionController.initialize(),
      weightController.initialize(),
      settingsController.initialize(),
      healthController.load(),
      activityController.initialize(),
      cycleController.load(),
      notificationController.initialize(),
      localModelController.initialize(),
    ]);

    // Check login credentials
    final email = await settingsController.getSavedEmail();
    isLoggedIn = email != null && email.isNotEmpty;

    // Check auto calorie mode goal updates
    if (weightController.currentWeight != null) {
      final autoCal = settingsController.calculateAutoCalorieGoal(
        currentWeightKg: weightController.currentWeight!,
      );
      if (autoCal != settingsController.goals.dailyCalories &&
          settingsController.goals.autoCalorieMode != AutoCalorieMode.off) {
        await settingsController.updateGoals(
          settingsController.goals.copyWith(dailyCalories: autoCal),
        );
      }
    }

    markInitialized();
  }

  // Nutrition Methods
  Future<void> loadDailyFoods() => nutritionController.loadDailyFoods();
  void goToPreviousDay() => nutritionController.goToPreviousDay();
  void goToNextDay() => nutritionController.goToNextDay();
  void setDate(DateTime date) => nutritionController.setDate(date);

  Future<void> addConsumedFood(ConsumedFoodItem item) =>
      nutritionController.addConsumedFood(
        mealName: item.mealName,
        food: item.food,
        quantity: item.quantity,
        date: item.date,
      );

  Future<void> addFood(
    String mealName,
    FoodItem food,
    int quantity, {
    DateTime? date,
  }) =>
      nutritionController.addConsumedFood(
        mealName: mealName,
        food: food,
        quantity: quantity,
        date: date,
      );

  Future<void> updateFood(ConsumedFoodItem item, int newQuantity) =>
      nutritionController.updateConsumedFoodQuantity(item.id!, newQuantity);

  Future<void> updateConsumedFoodItem(
    ConsumedFoodItem item, {
    int? newQuantity,
    String? newMealName,
    FoodItem? updatedFood,
  }) async {
    final foodId = item.id;
    if (foodId == null) return;
    if (newQuantity != null && (newMealName == null || newMealName == item.mealName)) {
      await nutritionController.updateConsumedFoodQuantity(foodId, newQuantity);
    } else if (newMealName != null && newMealName != item.mealName) {
      await nutritionController.deleteConsumedFood(foodId);
      await nutritionController.addConsumedFood(
        mealName: newMealName,
        food: updatedFood ?? item.food,
        quantity: newQuantity ?? item.quantity,
        date: item.date,
      );
    }
  }

  Future<void> deleteFood(ConsumedFoodItem item) =>
      nutritionController.deleteConsumedFood(item.id!);

  Future<void> removeFood(String mealName, ConsumedFoodItem item) =>
      nutritionController.deleteConsumedFood(item.id!);

  Future<void> clearDay() => nutritionController.clearCurrentDay();

  Future<void> copyMeal(String mealName, DateTime targetDate) =>
      nutritionController.copyMealToDate(
        mealName: mealName,
        targetDate: targetDate,
      );

  Future<void> copyMealToToday(String mealName) =>
      nutritionController.copyMealToDate(
        mealName: mealName,
        targetDate: DateTime.now(),
      );

  Future<FoodItem> saveCustomFood(FoodItem food) =>
      nutritionController.saveCustomFood(food);

  Future<void> loadFavoriteFoods() => nutritionController.loadFavorites();

  bool isFavoriteFood(dynamic foodOrId) {
    if (foodOrId is FoodItem) return favoriteFoodIds.contains(foodOrId.id);
    if (foodOrId is int) return favoriteFoodIds.contains(foodOrId);
    return false;
  }

  Future<bool> toggleFavoriteFood(dynamic foodOrId) {
    final int? id =
        foodOrId is FoodItem ? foodOrId.id : (foodOrId is int ? foodOrId : null);
    if (id == null) return Future.value(false);
    return nutritionController.toggleFavorite(id);
  }

  Future<void> loadFrequentFoods() => nutritionController.loadFrequentFoods();


  Future<void> loadSavedMeals() => nutritionController.loadSavedMeals();
  Future<SavedMeal> saveMeal(
    String name,
    String defaultMealName,
    List<Map<String, dynamic>> ingredients, {
    int? recipeTotalWeight,
  }) =>
      nutritionController.saveMeal(
        name: name,
        defaultMealName: defaultMealName,
        ingredients: ingredients,
        recipeTotalWeight: recipeTotalWeight,
      );
  Future<void> deleteSavedMeal(int id) =>
      nutritionController.deleteSavedMeal(id);

  // Weight Methods
  Future<void> loadWeightEntries() => weightController.loadWeights();
  Future<void> addWeightEntry(DateTime date, double weight) =>
      weightController.addWeight(date, weight);
  Future<void> updateWeightEntry(int id, DateTime date, double weight) =>
      weightController.updateWeight(id, date, weight);
  Future<void> deleteWeightEntry(int id) => weightController.deleteWeight(id);

  // Settings & Goals Methods
  Future<void> toggleDarkMode(bool value) =>
      settingsController.toggleDarkMode(value);

  Future<void> saveSettings({
    required int dailyCalories,
    required int carbPercentage,
    required int proteinPercentage,
    required int fatPercentage,
    required int sugarPercentage,
    required AutoCalorieMode autoMode,
    required double customPercentPerMonth,
    required bool useCustomStartCalories,
    required int userStartCalories,
    required int userAge,
    required double userActivityLevel,
    required double userHeight,
    required bool useProteinPerKg,
    required double proteinPerKg,
    double? targetWeight,
    DateTime? targetDate,
    double? targetWeeklyChange,
    Gender? gender,
    BmrFormula? bmrFormula,
    bool? reminderWeighEnabled,
    TimeOfDay? reminderWeighTime,
    TimeOfDay? reminderWeighTimeSecond,
    bool? reminderSupplementEnabled,
    TimeOfDay? reminderSupplementTime,
    TimeOfDay? reminderSupplementTimeSecond,
    bool? reminderMealsEnabled,
    TimeOfDay? reminderBreakfast,
    TimeOfDay? reminderLunch,
    TimeOfDay? reminderDinner,
  }) async {
    final updatedGoals = settingsController.goals.copyWith(
      dailyCalories: dailyCalories,
      carbPercentage: carbPercentage,
      proteinPercentage: proteinPercentage,
      fatPercentage: fatPercentage,
      sugarPercentage: sugarPercentage,
      autoCalorieMode: autoMode,
      customPercentPerMonth: customPercentPerMonth,
      useCustomStartCalories: useCustomStartCalories,
      userStartCalories: userStartCalories,
      userAge: userAge,
      userActivityLevel: userActivityLevel,
      userHeight: userHeight,
      useProteinPerKg: useProteinPerKg,
      proteinPerKg: proteinPerKg,
      targetWeight: targetWeight,
      targetDate: targetDate != null ? DateFormat('yyyy-MM-dd').format(targetDate) : null,
      targetWeeklyChange: targetWeeklyChange,
      gender: gender,
      bmrFormula: bmrFormula,
    );

    final updatedSettings = settingsController.settings.copyWith(
      reminderWeighEnabled: reminderWeighEnabled,
      reminderWeighTime: reminderWeighTime != null ? _formatTimeOfDay(reminderWeighTime) : null,
      reminderWeighTime2: reminderWeighTimeSecond != null ? _formatTimeOfDay(reminderWeighTimeSecond) : null,
      reminderSupplementEnabled: reminderSupplementEnabled,
      reminderSupplementTime: reminderSupplementTime != null ? _formatTimeOfDay(reminderSupplementTime) : null,
      reminderSupplementTime2: reminderSupplementTimeSecond != null ? _formatTimeOfDay(reminderSupplementTimeSecond) : null,
      reminderMealsEnabled: reminderMealsEnabled,
      reminderBreakfast: reminderBreakfast != null ? _formatTimeOfDay(reminderBreakfast) : null,
      reminderLunch: reminderLunch != null ? _formatTimeOfDay(reminderLunch) : null,
      reminderDinner: reminderDinner != null ? _formatTimeOfDay(reminderDinner) : null,
    );

    await settingsController.updateGoals(updatedGoals);
    await settingsController.updateSettings(updatedSettings);
    await scheduleAllNotifications();
  }

  Future<void> saveBodyProfileSettings({
    Gender? gender,
    BmrFormula? formula,
    double? customPercentPerMonth,
    bool? useCustomStartCalories,
    int? userStartCalories,
    AutoCalorieMode? autoMode,
    int? dailyCalories,
    int? userAge,
    double? userActivityLevel,
    double? userHeight,
    bool? useProteinPerKg,
    double? proteinPerKg,
    double? targetWeight,
    double? targetWeeklyChange,
    DateTime? targetDate,
  }) async {
    final updated = settingsController.goals.copyWith(
      gender: gender,
      bmrFormula: formula,
      customPercentPerMonth: customPercentPerMonth,
      useCustomStartCalories: useCustomStartCalories,
      userStartCalories: userStartCalories,
      autoCalorieMode: autoMode,
      dailyCalories: dailyCalories,
      userAge: userAge,
      userActivityLevel: userActivityLevel,
      userHeight: userHeight,
      useProteinPerKg: useProteinPerKg,
      proteinPerKg: proteinPerKg,
      targetWeight: targetWeight,
      targetWeeklyChange: targetWeeklyChange,
      targetDate: targetDate != null ? DateFormat('yyyy-MM-dd').format(targetDate) : null,
    );
    await settingsController.updateGoals(updated);
  }

  Future<void> updateGoals(
    dynamic goalsOrCalories, [
    int? carbPercentage,
    int? proteinPercentage,
    int? fatPercentage,
    int? sugarPercentage,
  ]) async {
    if (goalsOrCalories is UserGoals) {
      await settingsController.updateGoals(goalsOrCalories);
    } else if (goalsOrCalories is int) {
      final current = settingsController.goals;
      final updated = current.copyWith(
        dailyCalories: goalsOrCalories,
        carbPercentage: carbPercentage ?? current.carbPercentage,
        proteinPercentage: proteinPercentage ?? current.proteinPercentage,
        fatPercentage: fatPercentage ?? current.fatPercentage,
        sugarPercentage: sugarPercentage ?? current.sugarPercentage,
      );
      await settingsController.updateGoals(updated);
    } else {
      await settingsController.updateGoals(settingsController.goals);
    }
  }

  Future<void> recalculateGoals({bool fromBmr = false}) async {
    if (weightController.currentWeight != null) {
      final cal = settingsController.calculateAutoCalorieGoal(
        currentWeightKg: weightController.currentWeight!,
      );
      await settingsController.updateGoals(
        settingsController.goals.copyWith(dailyCalories: cal),
      );
    }
  }

  Future<List<FoodItem>> loadAllFoodItems() =>
      _nutritionRepository.searchFoods('');

  Future<void> addSavedMealToDay(
    SavedMeal meal,
    String mealName, {
    double factor = 1.0,
    DateTime? date,
  }) async {
    for (final ingredient in meal.ingredients) {
      final portion = (ingredient.quantity * factor).round();
      if (portion > 0) {
        await addConsumedFood(
          ConsumedFoodItem(
            mealName: mealName,
            food: ingredient.food,
            quantity: portion,
            date: date ?? currentDate,
          ),
        );
      }
    }
  }

  Future<void> addRecipePortionToDay(
    SavedMeal recipe,
    String mealName,
    int eatenWeightGrams, [
    DateTime? date,
  ]) async {
    final totalWeight = recipe.recipeTotalWeight ??
        recipe.ingredients.fold<int>(0, (sum, i) => sum + i.quantity);
    final factor = totalWeight > 0 ? (eatenWeightGrams / totalWeight) : 1.0;
    for (final ingredient in recipe.ingredients) {
      final portion = (ingredient.quantity * factor).round();
      if (portion > 0) {
        await addConsumedFood(
          ConsumedFoodItem(
            mealName: mealName,
            food: ingredient.food,
            quantity: portion,
            date: date ?? currentDate,
          ),
        );
      }
    }
  }

  Future<void> saveMealTemplate(
    String name,
    String defaultMealName,
    List<ConsumedFoodItem> items, [
    int? recipeTotalWeight,
  ]) async {
    final ingredients = items
        .map((item) => {
              'food_id': item.food.id ?? 0,
              'quantity': item.quantity,
            })
        .toList();
    await saveMeal(
      name,
      defaultMealName,
      ingredients,
      recipeTotalWeight: recipeTotalWeight,
    );
  }

  List<ConsumedFoodItem> getCurrentDaySnapshot() =>
      [...breakfast, ...lunch, ...dinner, ...snacks];

  Future<void> restoreCurrentDaySnapshot(List<ConsumedFoodItem> snapshot) async {
    await clearDay();
    for (final item in snapshot) {
      await addConsumedFood(item);
    }
  }

  Future<int> copyMealFromYesterday(String mealName) async {
    final yesterday = currentDate.subtract(const Duration(days: 1));
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(yesterday);
    final daily = await _nutritionRepository.getDailyFoods(yesterdayStr);
    final items = daily[mealName] ?? [];
    for (final item in items) {
      await addConsumedFood(item.copyWith(date: currentDate));
    }
    return items.length;
  }

  Future<int> copyDayFromYesterday() async {
    final yesterday = currentDate.subtract(const Duration(days: 1));
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(yesterday);
    final daily = await _nutritionRepository.getDailyFoods(yesterdayStr);
    var count = 0;
    for (final entry in daily.entries) {
      for (final item in entry.value) {
        await addConsumedFood(item.copyWith(date: currentDate));
        count++;
      }
    }
    return count;
  }

  String buildMealSharePayload(String mealName, [List<ConsumedFoodItem>? items]) {
    final list = items ??
        (mealName == 'breakfast'
            ? breakfast
            : mealName == 'lunch'
                ? lunch
                : mealName == 'dinner'
                    ? dinner
                    : snacks);
    return jsonEncode({
      'type': 'macromate_meal_share',
      'version': 1,
      'mealName': mealName,
      'createdAt': DateTime.now().toIso8601String(),
      'items': list
          .map((i) => {
                'food': i.food.toMap(),
                'quantity': i.quantity,
              })
          .toList(),
    });
  }

  Future<int> importMealSharePayload(
    String payload, [
    String? targetMealName,
    DateTime? targetDate,
  ]) async {
    try {
      final data = jsonDecode(payload);
      if (data is! Map || data['items'] is! List) return 0;
      final meal = targetMealName ?? (data['mealName'] as String? ?? 'snacks');
      final items = data['items'] as List;
      var count = 0;
      for (final item in items) {
        if (item is Map) {
          final foodMap = Map<String, dynamic>.from(item['food'] ?? {});
          final food = FoodItem.fromMap(foodMap);
          final qty = (item['quantity'] as num?)?.toInt() ?? 100;
          await addConsumedFood(
            ConsumedFoodItem(
              mealName: meal,
              food: food,
              quantity: qty,
              date: targetDate ?? currentDate,
            ),
          );
          count++;
        }
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  void previousDay() => goToPreviousDay();
  void nextDay() => goToNextDay();




  Future<void> resetGoals() => settingsController.resetGoals();
  Future<void> resetDatabase() async {
    await settingsController.resetDatabase();
    await initializeCompletely();
  }

  // Notifications
  Future<void> scheduleAllNotifications() async {
    final nextPeriod = cycleController.forecastState?.nextPeriod;
    final tip = dashboardController.discreteCycleTip;

    await notificationController.rescheduleAll(
      breakfastTime: reminderBreakfast,
      lunchTime: reminderLunch,
      dinnerTime: reminderDinner,
      weighTime: reminderWeighTime,
      nextPeriodDate: nextPeriod,
      personalizedInsight: tip,
    );
  }

  // Backup & Restore
  Future<String> exportDatabase({
    required String password,
    Set<String> categories = const {
      'nutrition',
      'goals',
      'settings',
      'weight',
      'health',
      'cycle',
      'notifications',
    },
  }) async {
    final payload = <String, dynamic>{
      'version': 27,
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (categories.contains('nutrition')) {
      final foods = await _nutritionRepository.searchFoods('');
      payload['foods'] = foods.map((f) => f.toMap()).toList();
      final saved = await _nutritionRepository.getSavedMeals();
      payload['saved_meals'] = saved.map((s) => {
        'id': s.id,
        'name': s.name,
        'default_meal_name': s.defaultMealName,
        'created_at': s.createdAt.toIso8601String(),
        'recipe_total_weight': s.recipeTotalWeight,
        'ingredients': s.ingredients.map((i) => {
          'id': i.id,
          'saved_meal_id': i.savedMealId,
          'food_id': i.food.id,
          'quantity': i.quantity,
        }).toList(),
      }).toList();
    }

    if (categories.contains('weight')) {
      final weights = await _weightRepository.list();
      payload['weights'] = weights.map((w) => {
        'id': w.id,
        'date': '${w.day.year}-${w.day.month.toString().padLeft(2, '0')}-${w.day.day.toString().padLeft(2, '0')}',
        'weight': w.kilograms,
      }).toList();
    }

    if (categories.contains('settings') || categories.contains('goals')) {
      final goals = await _settingsRepository.getGoals();
      final settings = await _settingsRepository.getSettings();
      payload['goals'] = {
        'daily_calories': goals.dailyCalories,
        'carb_percentage': goals.carbPercentage,
        'protein_percentage': goals.proteinPercentage,
        'fat_percentage': goals.fatPercentage,
        'sugar_percentage': goals.sugarPercentage,
        'auto_calorie_mode': goals.autoCalorieMode.index,
        'custom_percent_per_month': goals.customPercentPerMonth,
        'use_custom_start_calories': goals.useCustomStartCalories ? 1 : 0,
        'user_start_calories': goals.userStartCalories,
        'user_age': goals.userAge,
        'user_activity_level': goals.userActivityLevel,
        'user_height': goals.userHeight,
        'use_protein_per_kg': goals.useProteinPerKg ? 1 : 0,
        'protein_per_kg': goals.proteinPerKg,
      };
      payload['settings'] = {
        'dark_mode': settings.darkMode ? 1 : 0,
        'reminder_weigh_enabled': settings.reminderWeighEnabled ? 1 : 0,
        'reminder_weigh_time': settings.reminderWeighTime,
        'reminder_weigh_time2': settings.reminderWeighTime2,
        'reminder_supplement_enabled': settings.reminderSupplementEnabled ? 1 : 0,
        'reminder_supplement_time': settings.reminderSupplementTime,
        'reminder_supplement_time2': settings.reminderSupplementTime2,
        'reminder_meals_enabled': settings.reminderMealsEnabled ? 1 : 0,
        'reminder_breakfast': settings.reminderBreakfast,
        'reminder_lunch': settings.reminderLunch,
        'reminder_dinner': settings.reminderDinner,
      };
    }

    if (categories.contains('cycle')) {
      final periods = await _cycleRepository.periods();
      final logs = await _cycleRepository.dailyLogs(from: DateTime.now().subtract(const Duration(days: 365)));
      payload['periods'] = periods.map((p) => {
        'id': p.id,
        'start_day': '${p.startDay.year}-${p.startDay.month.toString().padLeft(2, '0')}-${p.startDay.day.toString().padLeft(2, '0')}',
        'end_day': p.endDay != null ? '${p.endDay!.year}-${p.endDay!.month.toString().padLeft(2, '0')}-${p.endDay!.day.toString().padLeft(2, '0')}' : null,
        'flow': p.flow?.name,
        'source': p.source,
      }).toList();
      payload['cycle_logs'] = logs.map((l) => {
        'day': '${l.day.year}-${l.day.month.toString().padLeft(2, '0')}-${l.day.day.toString().padLeft(2, '0')}',
        'bleeding': l.bleeding?.name,
        'mood': l.mood,
        'pain': l.pain,
        'energy': l.energy,
        'sleep_quality': l.sleepQuality,
        'notes': l.notes,
        'tags': l.tags,
      }).toList();
    }

    return await _backupService.encrypt(
      payload,
      password: password,
    );
  }

  Future<void> importDatabase(String encryptedJson, {String password = ''}) async {
    Map<String, dynamic> data;
    try {
      data = await _backupService.decrypt(encryptedJson, password: password);
    } catch (_) {
      try {
        final decoded = jsonDecode(encryptedJson);
        data = decoded is Map<String, dynamic> ? decoded : {};
      } catch (_) {
        data = {};
      }
    }

    if (data.containsKey('foods') && data['foods'] is List) {
      for (final f in data['foods']) {
        final item = FoodItem.fromMap(Map<String, dynamic>.from(f));
        await _nutritionRepository.saveFood(item);
      }
    }

    if (data.containsKey('weights') && data['weights'] is List) {
      for (final w in data['weights']) {
        final date = DateTime.parse(w['date']);
        final weight = (w['weight'] as num).toDouble();
        await _weightRepository.add(day: date, kilograms: weight);
      }
    }

    await initializeCompletely();
  }

  // Food Search Methods
  Future<List<FoodItem>> searchFood(String query) async {
    final local = await _nutritionRepository.searchFoods(query);
    if (local.isNotEmpty) return local;
    return await searchOpenFoodFacts(query);
  }

  Future<List<FoodItem>> searchOpenFoodFacts(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    if (_offSearchCache.containsKey(trimmed)) {
      return _offSearchCache[trimmed]!;
    }

    try {
      final url = Uri.parse(
        '$openFoodFactsBaseUrl/cgi/search.pl?search_terms=$trimmed&search_simple=1&action=process&json=1&page_size=20',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data['products'] as List? ?? [];
        final results = <FoodItem>[];
        for (final p in products) {
          final nutriments = p['nutriments'] ?? {};
          final name = p['product_name'] ?? p['generic_name'] ?? 'Unbekannt';
          final brand = p['brands'] ?? 'Unbekannt';
          final cal = nutriments['energy-kcal_100g'] ??
              nutriments['energy-kcal'] ??
              0;
          final fat = (nutriments['fat_100g'] ?? 0).toDouble();
          final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
          final sugar = (nutriments['sugars_100g'] ?? 0).toDouble();
          final prot = (nutriments['proteins_100g'] ?? 0).toDouble();

          if (name != 'Unbekannt' && cal > 0) {
            results.add(
              FoodItem(
                name: name,
                brand: brand,
                barcode: p['code'],
                caloriesPer100g: (cal as num).round(),
                fatPer100g: fat,
                carbsPer100g: carbs,
                sugarPer100g: sugar,
                proteinPer100g: prot,
                source: 'openfoodfacts',
                isVerified: false,
              ),
            );
          }
        }
        _offSearchCache[trimmed] = results;
        return results;
      }
    } catch (_) {
      // Fallback to empty list on network failure
    }
    return [];
  }

  Future<FoodItem?> searchOpenFoodFactsByBarcode(String barcode) async {
    final code = barcode.trim().toLowerCase();
    if (code.isEmpty) return null;

    final local = await _nutritionRepository.getFoodByBarcode(code);
    if (local != null) return local;

    if (_offBarcodeCache.containsKey(code)) {
      return _offBarcodeCache[code];
    }

    try {
      final url = Uri.parse('$openFoodFactsBaseUrl/api/v2/product/$code.json');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final p = data['product'];
          final nutriments = p['nutriments'] ?? {};
          final name = p['product_name'] ?? p['generic_name'] ?? 'Unbekannt';
          final brand = p['brands'] ?? 'Unbekannt';
          final cal = nutriments['energy-kcal_100g'] ??
              nutriments['energy-kcal'] ??
              0;
          final fat = (nutriments['fat_100g'] ?? 0).toDouble();
          final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
          final sugar = (nutriments['sugars_100g'] ?? 0).toDouble();
          final prot = (nutriments['proteins_100g'] ?? 0).toDouble();

          final item = FoodItem(
            name: name,
            brand: brand,
            barcode: code,
            caloriesPer100g: (cal as num).round(),
            fatPer100g: fat,
            carbsPer100g: carbs,
            sugarPer100g: sugar,
            proteinPer100g: prot,
            source: 'openfoodfacts',
            isVerified: false,
          );
          _offBarcodeCache[code] = item;
          return item;
        }
      }
    } catch (_) {
      // Offline fallback
    }
    return null;
  }

  // Weekly Summaries
  Future<WeeklyNutritionSummary> getWeeklyNutritionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 6));

    var totalCal = 0.0;
    var dayCount = 0;

    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      final dateStr = DateFormat('yyyy-MM-dd').format(d);
      final foods = await _nutritionRepository.getDailyFoods(dateStr);
      final all = [
        ...foods['breakfast'] ?? [],
        ...foods['lunch'] ?? [],
        ...foods['dinner'] ?? [],
        ...foods['snacks'] ?? [],
      ];
      for (final item in all) {
        totalCal += item.food.caloriesPer100g * (item.quantity / 100.0);
      }
      dayCount++;
    }

    final avgCal = dayCount > 0 ? totalCal / dayCount : 0.0;
    final remaining = dailyCalorieGoal - avgCal;
    final adherence = dailyCalorieGoal > 0 ? (avgCal / dailyCalorieGoal) : 1.0;
    final trend = weightController.sevenDayTrend ?? 0.0;

    return WeeklyNutritionSummary(
      averageCalories: avgCal,
      remainingCalories: remaining,
      macroAdherence: adherence,
      weightTrend: trend,
    );
  }

  Future<List<WeeklyDaySummary>> getWeeklyDaySummaries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 6));
    final summaries = <WeeklyDaySummary>[];

    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      final dateStr = DateFormat('yyyy-MM-dd').format(d);
      final foods = await _nutritionRepository.getDailyFoods(dateStr);
      final all = [
        ...foods['breakfast'] ?? [],
        ...foods['lunch'] ?? [],
        ...foods['dinner'] ?? [],
        ...foods['snacks'] ?? [],
      ];

      var cal = 0.0;
      var carbs = 0.0;
      var prot = 0.0;
      var fat = 0.0;

      for (final item in all) {
        final factor = item.quantity / 100.0;
        cal += item.food.caloriesPer100g * factor;
        carbs += item.food.carbsPer100g * factor;
        prot += item.food.proteinPer100g * factor;
        fat += item.food.fatPer100g * factor;
      }

      final dayName = DateFormat('E', 'de_DE').format(d);
      summaries.add(
        WeeklyDaySummary(
          date: d,
          dayName: dayName,
          calories: cal,
          carbs: carbs,
          protein: prot,
          fat: fat,
        ),
      );
    }

    return summaries;
  }

  Future<WeeklyNutritionSummary> calculateWeeklySummary({
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      getWeeklyNutritionSummary(startDate: startDate, endDate: endDate);

  Future<List<WeeklyDaySummary>> calculateWeeklyDayBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      getWeeklyDaySummaries(startDate: startDate, endDate: endDate);

  Future<List<FoodItem>> searchFoodItemsRemote(String query) =>
      searchOpenFoodFacts(query);

  Future<void> loadRecentFoodItems({int limit = 20}) =>
      nutritionController.loadFrequentFoods(limit: limit);

  Future<FoodItem?> loadFoodItemByBarcode(String barcode) =>
      searchOpenFoodFactsByBarcode(barcode);

  Future<FoodItem> updateBarcodeForFood(dynamic foodOrId, String barcode) async {
    if (foodOrId is FoodItem) {
      final updated = foodOrId.copyWith(barcode: barcode);
      if (foodOrId.id != null) {
        await _nutritionRepository.saveFood(updated);
      }
      return updated;
    } else if (foodOrId is int) {
      final food = await _nutritionRepository.getFoodById(foodOrId);
      if (food != null) {
        final updated = food.copyWith(barcode: barcode);
        await _nutritionRepository.saveFood(updated);
        return updated;
      }
    }
    return FoodItem(
      name: 'Unbekannt',
      brand: '',
      caloriesPer100g: 0,
      carbsPer100g: 0,
      proteinPer100g: 0,
      fatPer100g: 0,
      sugarPer100g: 0,
      barcode: barcode,
    );
  }

  Future<void> addOrUpdateFood(
    String mealName,
    FoodItem food,
    int quantity, [
    DateTime? date,
  ]) =>
      addConsumedFood(
        ConsumedFoodItem(
          mealName: mealName,
          food: food,
          quantity: quantity,
          date: date ?? currentDate,
        ),
      );

  // Account & Authentication
  Future<bool> registerUser(String email, String password) async {
    try {
      final existing = await _remoteService.getUserByEmail(email);
      if (existing != null) return false;
      final salt = BCrypt.gensalt();
      final hash = BCrypt.hashpw(password, salt);
      final code = (100000 + Random().nextInt(900000)).toString();
      await _remoteService.insertUserWithVerification(email, hash, code);
      return true;
    } catch (e, st) {
      reportUiError('registerUser', e, st);
      return false;
    }
  }

  Future<bool> verifyAccount(String email, String code) async {
    try {
      final user = await _remoteService.getUserByEmail(email);
      if (user == null) return false;
      if (user['verification_code'] == code) {
        await _remoteService.verifyUser(email);
        return true;
      }
    } catch (e, st) {
      reportUiError('verifyAccount', e, st);
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    try {
      final user = await _remoteService.getUserByEmail(email);
      if (user != null) {
        final isVerified = user['is_verified'] == true;
        final hash = user['password_hash'] as String?;
        if (isVerified && hash != null && BCrypt.checkpw(password, hash)) {
          await settingsController.saveCredentials(email, password);
          isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }
    } catch (e, st) {
      reportUiError('login', e, st);
    }
    return false;
  }

  Future<void> logout() async {
    await settingsController.clearCredentials();
    isLoggedIn = false;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    try {
      final email = await settingsController.getSavedEmail();
      if (email != null) {
        await _remoteService.deleteUserByEmail(email);
      }
    } catch (_) {}
    await settingsController.clearCredentials();
    await resetDatabase();
    isLoggedIn = false;
    notifyListeners();
    return true;
  }



  Future<void> addLocalAiFood(
    String mealName,
    FoodItem food,
    int quantity,
    DateTime date,
  ) async {
    await nutritionController.addConsumedFood(
      mealName: mealName,
      food: food,
      quantity: quantity,
      date: date,
    );
  }

  bool isLocalLlmModelMarkedInstalled(LocalLlmModel model) {
    return installedLocalModelFiles.contains(model.fileName) ||
        localModelController.isInstalled;
  }

  Future<void> refreshInstalledLocalLlmModels() async {
    await localModelController.checkModelStatus();
    if (localModelController.isInstalled) {
      installedLocalModelFiles.add(selectedLocalLlmModel.fileName);
    }
    notifyListeners();
  }

  Future<void> downloadSelectedLocalLlmModel() async {
    await localModelController.downloadSelectedModel();
    if (localModelController.isInstalled) {
      installedLocalModelFiles.add(selectedLocalLlmModel.fileName);
    }
  }

  Future<void> startLocalModelDownload(LocalLlmModel model) =>
      localModelController.downloadSelectedModel();


  TimeOfDay _parseTimeOfDay(String timeStr, TimeOfDay fallback) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return fallback;
  }

  String _formatTimeOfDay(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
