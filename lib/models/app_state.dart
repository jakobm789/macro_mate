import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/remote_database_service.dart';
import '../services/database_helper.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';
import '../models/saved_meal.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:http/http.dart' as http;
import '../services/shared_preferences_helper.dart';
import '../main.dart';

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

enum Gender { male, female }

enum BmrFormula { mifflin, harris }

enum AutoCalorieMode { off, diet, bulk, custom, maintain }

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

class AppState extends ChangeNotifier {
  static const MethodChannel _widgetChannel = MethodChannel(
    'macro_mate/widget',
  );
  Gender userGender = Gender.male;
  BmrFormula bmrFormula = BmrFormula.mifflin;
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
  int recentFoodLimit = 20;
  List<SavedMeal> savedMeals = [];
  Set<int> favoriteFoodIds = {};
  List<FoodItem> favoriteFoodItems = [];
  String? lastUiError;
  final Map<String, List<FoodItem>> _offSearchCache = {};
  final Map<String, FoodItem?> _offBarcodeCache = {};
  final RemoteDatabaseService _remoteService = RemoteDatabaseService();
  bool isLoggedIn = false;
  List<WeightEntry> _weightEntries = [];
  List<WeightEntry> get weightEntries => _weightEntries;
  AutoCalorieMode autoMode = AutoCalorieMode.off;
  double customPercentPerMonth = 1.0;
  bool useCustomStartCalories = false;
  int userStartCalories = 2000;
  int userAge = 30;
  double userActivityLevel = 1.3;
  double userHeight = 170.0;
  String? lastMondayCheck;
  bool reminderWeighEnabled = false;
  TimeOfDay reminderWeighTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay reminderWeighTimeSecond = const TimeOfDay(hour: 9, minute: 0);
  bool reminderSupplementEnabled = false;
  TimeOfDay reminderSupplementTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay reminderSupplementTimeSecond = const TimeOfDay(hour: 11, minute: 0);
  bool reminderMealsEnabled = false;
  TimeOfDay reminderBreakfast = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay reminderLunch = const TimeOfDay(hour: 12, minute: 30);
  TimeOfDay reminderDinner = const TimeOfDay(hour: 19, minute: 0);
  bool firstWeekInitialized = false;
  bool useProteinPerKg = false;
  double proteinPerKg = 2.0;
  double? targetWeight;
  DateTime? targetDate;
  double? targetWeeklyChange;
  String? mondayPopupMessage;
  AppState();

  void _logError(String context, Object error, [StackTrace? stackTrace]) {
    lastUiError = '$context: $error';
    debugPrint('[MacroMate] $context failed: $error');
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
    notifyListeners();
  }

  void clearUiError() {
    lastUiError = null;
    notifyListeners();
  }

  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> initializeCompletely() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_gender')) {
      await prefs.setString('user_gender', 'male'); // Default
    }
    if (!prefs.containsKey('bmr_formula')) {
      await prefs.setInt('bmr_formula', BmrFormula.mifflin.index); // Default
    }

    userGender = (prefs.getString('user_gender') == 'male')
        ? Gender.male
        : Gender.female;
    bmrFormula = BmrFormula.values[prefs.getInt('bmr_formula')!];

    Timer.periodic(Duration(hours: 6), (timer) {
      _checkMondayAndAutoAdjustIfNeeded();
    });
    await _configureLocalTimezone();
    await loadWeightEntries();
    await loadGoals();
    await loadDarkMode();
    await loadNotificationSettings();
    await loadRecentFoodItems();
    await loadFavoriteFoods();
    await loadSavedMeals();
    await loadConsumedFoods();
    await syncOfflineQueue();
    await _tryAutoLogin();
    notifyListeners();
  }

  Future<void> syncOfflineQueue() async {
    try {
      final queue = await DatabaseHelper().getOfflineQueue();
      for (final entry in queue) {
        if (entry['action_type'] == 'food_upsert') {
          final payload = jsonDecode(entry['payload'] as String);
          await _remoteService.insertOrUpdateFoodItem(
            FoodItem.fromJson(payload),
          );
          await DatabaseHelper().deleteOfflineQueueEntry(entry['id'] as int);
        }
      }
    } catch (e, st) {
      _logError('syncOfflineQueue', e, st);
    }
  }

  Future<void> saveBodyProfileSettings({
    required Gender gender,
    required BmrFormula formula,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    userGender = gender;
    bmrFormula = formula;
    await prefs.setString(
      'user_gender',
      gender == Gender.male ? 'male' : 'female',
    );
    await prefs.setInt('bmr_formula', formula.index);
  }

  Future<void> loadNotificationSettings() async {
    try {
      final dbSettings = await DatabaseHelper().getNotificationSettings();
      if (dbSettings != null) {
        reminderWeighEnabled = dbSettings['reminder_weigh_enabled'] == 1;
        List<String> weighTimeParts = dbSettings['reminder_weigh_time'].split(
          ':',
        );
        reminderWeighTime = TimeOfDay(
          hour: int.parse(weighTimeParts[0]),
          minute: int.parse(weighTimeParts[1]),
        );
        List<String> weighTime2Parts = dbSettings['reminder_weigh_time2'].split(
          ':',
        );
        reminderWeighTimeSecond = TimeOfDay(
          hour: int.parse(weighTime2Parts[0]),
          minute: int.parse(weighTime2Parts[1]),
        );
        reminderSupplementEnabled =
            dbSettings['reminder_supplement_enabled'] == 1;
        List<String> suppTimeParts =
            dbSettings['reminder_supplement_time'].split(':');
        reminderSupplementTime = TimeOfDay(
          hour: int.parse(suppTimeParts[0]),
          minute: int.parse(suppTimeParts[1]),
        );
        List<String> suppTime2Parts =
            dbSettings['reminder_supplement_time2'].split(':');
        reminderSupplementTimeSecond = TimeOfDay(
          hour: int.parse(suppTime2Parts[0]),
          minute: int.parse(suppTime2Parts[1]),
        );
        reminderMealsEnabled = dbSettings['reminder_meals_enabled'] == 1;
        List<String> bParts = dbSettings['reminder_breakfast'].split(':');
        reminderBreakfast = TimeOfDay(
          hour: int.parse(bParts[0]),
          minute: int.parse(bParts[1]),
        );
        List<String> lParts = dbSettings['reminder_lunch'].split(':');
        reminderLunch = TimeOfDay(
          hour: int.parse(lParts[0]),
          minute: int.parse(lParts[1]),
        );
        List<String> dParts = dbSettings['reminder_dinner'].split(':');
        reminderDinner = TimeOfDay(
          hour: int.parse(dParts[0]),
          minute: int.parse(dParts[1]),
        );
      }
    } catch (e, st) {
      _logError('loadNotificationSettings', e, st);
    }
  }

  Future<void> saveNotificationSettings() async {
    try {
      await DatabaseHelper().saveNotificationSettings(
        reminderWeighEnabled: reminderWeighEnabled,
        reminderWeighTime:
            '${reminderWeighTime.hour.toString().padLeft(2, '0')}:${reminderWeighTime.minute.toString().padLeft(2, '0')}',
        reminderWeighTime2:
            '${reminderWeighTimeSecond.hour.toString().padLeft(2, '0')}:${reminderWeighTimeSecond.minute.toString().padLeft(2, '0')}',
        reminderSupplementEnabled: reminderSupplementEnabled,
        reminderSupplementTime:
            '${reminderSupplementTime.hour.toString().padLeft(2, '0')}:${reminderSupplementTime.minute.toString().padLeft(2, '0')}',
        reminderSupplementTime2:
            '${reminderSupplementTimeSecond.hour.toString().padLeft(2, '0')}:${reminderSupplementTimeSecond.minute.toString().padLeft(2, '0')}',
        reminderMealsEnabled: reminderMealsEnabled,
        reminderBreakfast:
            '${reminderBreakfast.hour.toString().padLeft(2, '0')}:${reminderBreakfast.minute.toString().padLeft(2, '0')}',
        reminderLunch:
            '${reminderLunch.hour.toString().padLeft(2, '0')}:${reminderLunch.minute.toString().padLeft(2, '0')}',
        reminderDinner:
            '${reminderDinner.hour.toString().padLeft(2, '0')}:${reminderDinner.minute.toString().padLeft(2, '0')}',
      );
    } catch (e, st) {
      _logError('saveNotificationSettings', e, st);
    }
  }

  Future<void> scheduleAllNotifications() async {
    await notificationsPlugin.cancelAll();
    if (reminderWeighEnabled) {
      await scheduleDailyNotification(
        10000,
        reminderWeighTime,
        'Wiegen',
        'Zeit zum Wiegen',
        true,
        reminderWeighTimeSecond,
        10001,
      );
    }
    if (reminderSupplementEnabled) {
      await scheduleDailyNotification(
        20000,
        reminderSupplementTime,
        'Supplement',
        'Zeit für Supplements',
        true,
        reminderSupplementTimeSecond,
        20001,
      );
    }
    if (reminderMealsEnabled) {
      await scheduleDailyNotification(
        30000,
        reminderBreakfast,
        'Frühstück',
        'Zeit für das Frühstück',
        false,
        null,
        null,
      );
      await scheduleDailyNotification(
        30001,
        reminderLunch,
        'Mittagessen',
        'Zeit für das Mittagessen',
        false,
        null,
        null,
      );
      await scheduleDailyNotification(
        30002,
        reminderDinner,
        'Abendessen',
        'Zeit für das Abendessen',
        false,
        null,
        null,
      );
    }
  }

  Future<void> scheduleDailyNotification(
    int id,
    TimeOfDay time,
    String title,
    String body,
    bool showSecond,
    TimeOfDay? secondTime,
    int? secondId,
  ) async {
    if ((id == 30000 && breakfast.isNotEmpty) ||
        (id == 30001 && lunch.isNotEmpty) ||
        (id == 30002 && dinner.isNotEmpty)) {
      return;
    }
    final now = DateTime.now();
    final location = tz.getLocation(tz.local.name);
    final firstScheduled = _nextInstanceOfTime(time, now);
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(firstScheduled, location),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notif_channel',
          'Tägliche Erinnerung',
          channelDescription: 'Tägliche Benachrichtigung',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'erledigt',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    if (showSecond && secondTime != null && secondId != null) {
      final secondScheduled = _nextInstanceOfTime(secondTime, now);
      await notificationsPlugin.zonedSchedule(
        secondId,
        title,
        body,
        tz.TZDateTime.from(secondScheduled, location),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_notif_channel',
            'Tägliche Erinnerung',
            channelDescription: 'Tägliche Benachrichtigung',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: 'erledigt',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  DateTime _nextInstanceOfTime(TimeOfDay t, DateTime base) {
    DateTime scheduled = DateTime(
      base.year,
      base.month,
      base.day,
      t.hour,
      t.minute,
    );
    if (scheduled.isBefore(base)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _tryAutoLogin() async {
    final savedEmail = await SharedPreferencesHelper.loadUserEmail();
    final savedPass = await SharedPreferencesHelper.loadUserPassword();
    if (savedEmail != null && savedPass != null) {
      try {
        final ok = await login(savedEmail, savedPass, storeCredentials: false);
        if (!ok) {}
      } catch (e, st) {
        _logError('autoLogin', e, st);
      }
    }
  }

  Future<bool> login(
    String email,
    String password, {
    bool storeCredentials = true,
  }) async {
    try {
      final userRow = await _remoteService.getUserByEmail(email);
      if (userRow == null) {
        return false;
      }
      final String storedHash = userRow['password_hash'];
      final bool isVerified = userRow['is_verified'] == true;
      if (!isVerified) {
        return false;
      }
      bool ok = BCrypt.checkpw(password, storedHash);
      if (ok) {
        isLoggedIn = true;
        notifyListeners();
        if (storeCredentials) {
          await SharedPreferencesHelper.saveUserEmail(email);
          await SharedPreferencesHelper.saveUserPassword(password);
        }
        await _checkMondayAndAutoAdjustIfNeeded();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> registerUser(String email, String password) async {
    try {
      final existingUser = await _remoteService.getUserByEmail(email);
      if (existingUser != null) {
        return false;
      }
      final hashed = BCrypt.hashpw(password, BCrypt.gensalt());
      final verificationCode = _generateVerificationCode();
      await _remoteService.insertUserWithVerification(
        email,
        hashed,
        verificationCode,
      );
      await sendVerificationEmail(email, verificationCode);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendVerificationEmail(String recipientEmail, String code) async {
    const endpoint = 'https://api.brevo.com/v3/smtp/email';
    final body = {
      'to': [
        {'email': recipientEmail},
      ],
      'sender': {'email': const String.fromEnvironment('SENDER_EMAIL')},
      'subject': 'Dein Bestätigungscode',
      'htmlContent':
          '<h3>Hallo!</h3><p>Dein Code lautet: <b>$code</b>.</p><p>Gib diesen Code in der App ein, um dein Konto zu aktivieren.</p>',
    };
    try {
      await http.post(
        Uri.parse(endpoint),
        headers: {
          'accept': 'application/json',
          'api-key': const String.fromEnvironment('BREVO_API_KEY'),
          'content-type': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (e, st) {
      _logError('sendVerificationEmail', e, st);
    }
  }

  String _generateVerificationCode() {
    final rnd = Random();
    final code = rnd.nextInt(900000) + 100000;
    return code.toString();
  }

  Future<bool> verifyAccount(String email, String code) async {
    try {
      final userRow = await _remoteService.getUserByEmail(email);
      if (userRow == null) return false;
      final dbCode = userRow['verification_code'];
      if (dbCode == code) {
        await _remoteService.verifyUser(email);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await SharedPreferencesHelper.clearUserCredentials();
    isLoggedIn = false;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    try {
      final email = await SharedPreferencesHelper.loadUserEmail();
      if (email == null) {
        return false;
      }
      await _remoteService.deleteUserByEmail(email);
      await logout();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadLast20FoodItems() async {
    await loadRecentFoodItems();
  }

  Future<void> loadRecentFoodItems({int? limit}) async {
    try {
      if (limit != null) {
        recentFoodLimit = limit;
      }
      last20FoodItems = await _remoteService.getRecentlyUsedFoodItems(
        recentFoodLimit,
      );
      await _updateMacroWidget();
      notifyListeners();
    } catch (e, st) {
      _logError('loadRecentFoodItems', e, st);
    }
  }

  Future<void> loadFavoriteFoods() async {
    try {
      favoriteFoodIds = await DatabaseHelper().getFavoriteFoodIds();
      final items = <FoodItem>[];
      for (final id in favoriteFoodIds) {
        final food = await _remoteService.getFoodItemById(id);
        if (food != null) items.add(food);
      }
      favoriteFoodItems = items;
      notifyListeners();
    } catch (e, st) {
      _logError('loadFavoriteFoods', e, st);
    }
  }

  bool isFavoriteFood(FoodItem food) =>
      food.id != null && favoriteFoodIds.contains(food.id);

  Future<void> toggleFavoriteFood(FoodItem food) async {
    final foodId = food.id;
    if (foodId == null) return;
    final nextValue = !favoriteFoodIds.contains(foodId);
    await DatabaseHelper().setFavoriteFood(foodId, nextValue);
    await loadFavoriteFoods();
  }

  Future<void> loadSavedMeals() async {
    try {
      savedMeals = await DatabaseHelper().getSavedMeals(
        (foodId) => _remoteService.getFoodItemById(foodId),
      );
      notifyListeners();
    } catch (e, st) {
      _logError('loadSavedMeals', e, st);
    }
  }

  Future<void> saveMealTemplate(
    String name,
    String defaultMealName,
    List<ConsumedFoodItem> ingredients,
    int? recipeTotalWeight,
  ) async {
    final persistableIngredients =
        ingredients.where((ingredient) => ingredient.food.id != null).toList();
    if (persistableIngredients.isEmpty) {
      throw Exception('Diese Mahlzeit enthält keine speicherbaren Zutaten.');
    }
    await DatabaseHelper().insertSavedMeal(
      name,
      defaultMealName,
      persistableIngredients,
      recipeTotalWeight,
    );
    await loadSavedMeals();
    notifyListeners();
  }

  Future<void> addSavedMealToDay(
    SavedMeal savedMeal,
    String mealName, {
    double factor = 1.0,
  }) async {
    for (final ingredient in savedMeal.ingredients) {
      await addOrUpdateFood(
        mealName,
        ingredient.food,
        max(1, (ingredient.quantity * factor).round()),
        currentDate,
      );
    }
    await loadRecentFoodItems();
    notifyListeners();
  }

  Future<void> addRecipePortionToDay(
    SavedMeal savedMeal,
    String mealName,
    int portionGrams,
  ) async {
    final totalWeight = savedMeal.recipeTotalWeight;
    if (totalWeight == null || totalWeight <= 0) {
      await addSavedMealToDay(savedMeal, mealName);
      return;
    }
    await addSavedMealToDay(
      savedMeal,
      mealName,
      factor: portionGrams / totalWeight,
    );
  }

  Future<List<ConsumedFoodItem>> getCurrentDaySnapshot() async {
    return await DatabaseHelper().getConsumedFoods(currentDate);
  }

  Future<void> restoreCurrentDaySnapshot(
    List<ConsumedFoodItem> snapshot,
  ) async {
    await DatabaseHelper().replaceConsumedFoodsForDate(currentDate, snapshot);
    await loadConsumedFoods();
    notifyListeners();
  }

  Future<int> copyMealFromYesterday(String mealName) async {
    final yesterday = currentDate.subtract(const Duration(days: 1));
    final consumedFoods = await DatabaseHelper().getConsumedFoods(yesterday);
    final yesterdayMeal =
        consumedFoods.where((food) => food.mealName == mealName).toList();

    var copiedCount = 0;
    for (final consumedFood in yesterdayMeal) {
      final foodId = consumedFood.food.id;
      if (foodId == null) {
        continue;
      }
      final remoteFood = await _remoteService.getFoodItemById(foodId);
      if (remoteFood == null) {
        continue;
      }
      await addOrUpdateFood(
        mealName,
        remoteFood,
        consumedFood.quantity,
        currentDate,
      );
      copiedCount++;
    }
    return copiedCount;
  }

  Future<int> copyDayFromYesterday() async {
    final yesterday = currentDate.subtract(const Duration(days: 1));
    final consumedFoods = await DatabaseHelper().getConsumedFoods(yesterday);
    var copiedCount = 0;
    for (final consumedFood in consumedFoods) {
      final foodId = consumedFood.food.id;
      if (foodId == null) continue;
      final remoteFood = await _remoteService.getFoodItemById(foodId);
      if (remoteFood == null) continue;
      await addOrUpdateFood(
        consumedFood.mealName,
        remoteFood,
        consumedFood.quantity,
        currentDate,
      );
      copiedCount++;
    }
    return copiedCount;
  }

  Future<void> deleteSavedMeal(int id) async {
    await DatabaseHelper().deleteSavedMeal(id);
    await loadSavedMeals();
    notifyListeners();
  }

  Future<void> loadConsumedFoods() async {
    try {
      final dbHelper = DatabaseHelper();
      List<ConsumedFoodItem> consumedFoods = await dbHelper.getConsumedFoods(
        currentDate,
      );
      for (int i = 0; i < consumedFoods.length; i++) {
        ConsumedFoodItem cItem = consumedFoods[i];
        final int? remoteId = cItem.food.id;
        if (remoteId != null) {
          final remoteFood = await _remoteService.getFoodItemById(remoteId);
          if (remoteFood != null) {
            consumedFoods[i] = cItem.copyWith(food: remoteFood);
          }
        }
      }
      breakfast =
          consumedFoods.where((f) => f.mealName == 'Frühstück').toList();
      lunch = consumedFoods.where((f) => f.mealName == 'Mittagessen').toList();
      dinner = consumedFoods.where((f) => f.mealName == 'Abendessen').toList();
      snacks = consumedFoods.where((f) => f.mealName == 'Snacks').toList();
      _calculateConsumedMacros();
    } catch (e, st) {
      _logError('loadConsumedFoods', e, st);
    }
  }

  void _calculateConsumedMacros() {
    consumedCalories = 0.0;
    consumedCarbs = 0.0;
    consumedProtein = 0.0;
    consumedFat = 0.0;
    consumedSugar = 0.0;
    for (var cItem in breakfast + lunch + dinner + snacks) {
      consumedCalories += (cItem.food.caloriesPer100g * cItem.quantity) / 100;
      consumedCarbs += (cItem.food.carbsPer100g * cItem.quantity) / 100;
      consumedProtein += (cItem.food.proteinPer100g * cItem.quantity) / 100;
      consumedFat += (cItem.food.fatPer100g * cItem.quantity) / 100;
      consumedSugar += (cItem.food.sugarPer100g * cItem.quantity) / 100;
    }
    _updateMacroWidget();
  }

  Future<void> _updateMacroWidget() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _widgetChannel.invokeMethod('updateMacroWidget', {
        'consumedCalories': consumedCalories,
        'dailyCalorieGoal': dailyCalorieGoal,
        'consumedCarbs': consumedCarbs,
        'consumedProtein': consumedProtein,
        'consumedFat': consumedFat,
      });
    } catch (e, st) {
      _logError('updateMacroWidget', e, st);
    }
  }

  double get dailySugarGoalGrams =>
      dailyCarbGoal * dailySugarGoalPercentage / 100;

  Future<WeeklyNutritionSummary> calculateWeeklySummary() async {
    final start = currentDate.subtract(Duration(days: currentDate.weekday - 1));
    final end = start.add(const Duration(days: 6));
    final entries = await DatabaseHelper().getConsumedFoodsBetween(start, end);
    var calories = 0.0;
    var carbs = 0.0;
    var protein = 0.0;
    var fat = 0.0;
    for (final entry in entries) {
      final foodId = entry.food.id;
      if (foodId == null) continue;
      final food = await _remoteService.getFoodItemById(foodId);
      if (food == null) continue;
      calories += food.caloriesPer100g * entry.quantity / 100.0;
      carbs += food.carbsPer100g * entry.quantity / 100.0;
      protein += food.proteinPer100g * entry.quantity / 100.0;
      fat += food.fatPer100g * entry.quantity / 100.0;
    }
    double adherence(double value, double goal) {
      if (goal <= 0) return 1.0;
      return (1 - ((value - goal).abs() / goal)).clamp(0.0, 1.0);
    }

    final weeklyCarbGoal = dailyCarbGoal * 7;
    final weeklyProteinGoal = dailyProteinGoal * 7;
    final weeklyFatGoal = dailyFatGoal * 7;
    final macroScore = (adherence(carbs, weeklyCarbGoal) +
            adherence(protein, weeklyProteinGoal) +
            adherence(fat, weeklyFatGoal)) /
        3;
    return WeeklyNutritionSummary(
      averageCalories: calories / 7,
      remainingCalories: dailyCalorieGoal * 7 - calories,
      macroAdherence: macroScore * 100,
      weightTrend: computeWeightChangeInLastWeek(),
    );
  }

  Future<void> loadGoals() async {
    try {
      Map<String, dynamic>? goals = await DatabaseHelper().getGoals();
      if (goals != null) {
        dailyCalorieGoal = goals['daily_calories'];
        int carbPerc = goals['carb_percentage'];
        int proteinPerc = goals['protein_percentage'];
        int fatPerc = goals['fat_percentage'];
        int sugarPerc = goals['sugar_percentage'].toInt();
        final autoModeIndex = goals['auto_calorie_mode'] ?? 0;
        autoMode = autoModeIndex is int &&
                autoModeIndex >= 0 &&
                autoModeIndex < AutoCalorieMode.values.length
            ? AutoCalorieMode.values[autoModeIndex]
            : AutoCalorieMode.off;
        customPercentPerMonth =
            (goals['custom_percent_per_month'] ?? 1.0) * 1.0;
        useCustomStartCalories = (goals['use_custom_start_calories'] ?? 0) == 1;
        userStartCalories = goals['user_start_calories'] ?? 2000;
        userAge = goals['user_age'] ?? 30;
        userActivityLevel = (goals['user_activity_level'] ?? 1.3).toDouble();
        double h = 170.0;
        if (goals.containsKey('user_height')) {
          h = (goals['user_height'] ?? 170).toDouble();
        }
        userHeight = h;
        lastMondayCheck = goals['last_monday_check'];
        firstWeekInitialized = (goals['first_week_initialized'] ?? 0) == 1;
        useProteinPerKg = (goals['use_protein_per_kg'] ?? 0) == 1;
        proteinPerKg = (goals['protein_per_kg'] ?? 2.0).toDouble();
        targetWeight = (goals['target_weight'] as num?)?.toDouble();
        targetDate = goals['target_date'] == null
            ? null
            : DateTime.tryParse(goals['target_date'] as String);
        targetWeeklyChange =
            (goals['target_weekly_change'] as num?)?.toDouble();
        dailyCarbGoal = (dailyCalorieGoal * carbPerc / 100) / 4.0;
        dailyProteinGoal = useProteinPerKg
            ? _proteinGoalFromWeight()
            : (dailyCalorieGoal * proteinPerc / 100) / 4.0;
        dailyFatGoal = (dailyCalorieGoal * fatPerc / 100) / 9.0;
        dailySugarGoalPercentage = sugarPerc;
      }
    } catch (e, st) {
      _logError('loadGoals', e, st);
    }
  }

  double _proteinGoalFromWeight() {
    final weight =
        _weightEntries.isNotEmpty ? _weightEntries.last.weight : 80.0;
    return (weight * proteinPerKg).clamp(0.0, 500.0);
  }

  void _refreshProteinGoalFromWeightIfNeeded() {
    if (useProteinPerKg) {
      dailyProteinGoal = _proteinGoalFromWeight();
    }
  }

  Future<void> updateGoals(
    int newCalorieGoal,
    int carbPerc,
    int proteinPerc,
    int fatPerc,
    int sugarPerc,
  ) async {
    try {
      final safeCalories = newCalorieGoal <= 0 ? 1 : newCalorieGoal;
      dailyCalorieGoal = newCalorieGoal;
      dailyCarbGoal = (safeCalories * carbPerc / 100) / 4.0;
      dailyProteinGoal = useProteinPerKg
          ? _proteinGoalFromWeight()
          : (safeCalories * proteinPerc / 100) / 4.0;
      dailyFatGoal = (safeCalories * fatPerc / 100) / 9.0;
      dailySugarGoalPercentage = sugarPerc;
      await DatabaseHelper().saveGoalsExtended(
        dailyCalories: dailyCalorieGoal,
        carbPercentage: carbPerc,
        proteinPercentage: proteinPerc,
        fatPercentage: fatPerc,
        sugarPercentage: sugarPerc,
        autoCalorieModeIndex: autoMode.index,
        customPercentPerMonth: customPercentPerMonth,
        useCustomStartCaloriesInt: useCustomStartCalories ? 1 : 0,
        userStartCalories: userStartCalories,
        userAge: userAge,
        userActivityLevel: userActivityLevel,
        lastMondayCheck: lastMondayCheck,
        firstWeekInitializedVal: firstWeekInitialized,
        userHeightVal: userHeight,
        useProteinPerKgInt: useProteinPerKg ? 1 : 0,
        proteinPerKg: proteinPerKg,
        targetWeight: targetWeight,
        targetDate: targetDate?.toIso8601String(),
        targetWeeklyChange: targetWeeklyChange,
      );
      notifyListeners();
    } catch (e, st) {
      _logError('updateGoals', e, st);
    }
  }

  Future<void> loadDarkMode() async {
    try {
      isDarkMode = await DatabaseHelper().getDarkMode();
    } catch (e, st) {
      _logError('loadDarkMode', e, st);
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode = value;
    await DatabaseHelper().saveDarkMode(isDarkMode);
    notifyListeners();
  }

  Future<void> autoAdjustCaloriesIfNeeded() async {
    if (autoMode == AutoCalorieMode.off) return;
    // erste Berechnung nur solange firstWeekInitialized == false
    await recalculateGoals(fromBmr: !firstWeekInitialized);
  }

  Future<void> _checkMondayAndAutoAdjustIfNeeded() async {
    if (autoMode == AutoCalorieMode.off) return;
    final now = DateTime.now();
    if (now.weekday == DateTime.monday &&
        lastMondayCheck !=
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}") {
      await recalculateGoals(fromBmr: false);
    }
  }

  double computeWeightChangeInLastWeek() {
    if (_weightEntries.length < 2) return 0.0;
    DateTime now = DateTime.now();
    DateTime oneWeekAgo = now.subtract(Duration(days: 7));
    List<WeightEntry> lastWeek =
        _weightEntries.where((e) => e.date.isAfter(oneWeekAgo)).toList();
    if (lastWeek.isEmpty) return 0.0;
    double avgNow =
        lastWeek.map((e) => e.weight).reduce((a, b) => a + b) / lastWeek.length;
    DateTime weekBefore = now.subtract(Duration(days: 14));
    List<WeightEntry> priorWeek = _weightEntries
        .where((e) => e.date.isAfter(weekBefore) && e.date.isBefore(oneWeekAgo))
        .toList();
    if (priorWeek.isEmpty) return 0.0;
    double avgPast = priorWeek.map((e) => e.weight).reduce((a, b) => a + b) /
        priorWeek.length;
    return avgNow - avgPast;
  }

  double computeWeightChangeInLastTwoWeeks() {
    if (_weightEntries.length < 2) return 0.0;
    DateTime now = DateTime.now();
    DateTime twoWeeksAgo = now.subtract(Duration(days: 14));
    List<WeightEntry> lastTwoWeeks = _weightEntries
        .where((entry) => entry.date.isAfter(twoWeeksAgo))
        .toList();
    if (lastTwoWeeks.isEmpty) {
      return 0.0;
    }
    double avgNow = lastTwoWeeks.map((e) => e.weight).reduce((a, b) => a + b) /
        lastTwoWeeks.length;
    DateTime twoWeeksBeforeThat = now.subtract(Duration(days: 28));
    List<WeightEntry> priorTwoWeeks = _weightEntries
        .where(
          (entry) =>
              entry.date.isAfter(twoWeeksBeforeThat) &&
              entry.date.isBefore(twoWeeksAgo),
        )
        .toList();
    if (priorTwoWeeks.isEmpty) {
      return 0.0;
    }
    double avgPast =
        priorTwoWeeks.map((e) => e.weight).reduce((a, b) => a + b) /
            priorTwoWeeks.length;
    return avgNow - avgPast;
  }

  Future<void> addOrUpdateFood(
    String mealName,
    FoodItem food,
    int quantity,
    DateTime date,
  ) async {
    try {
      final trackedFood = food.copyWith(lastUsedQuantity: quantity);
      int newRemoteId;
      try {
        newRemoteId = await _remoteService.insertOrUpdateFoodItem(trackedFood);
      } catch (e, st) {
        _logError('remote food upsert queued', e, st);
        if (trackedFood.id == null) rethrow;
        newRemoteId = trackedFood.id!;
        await DatabaseHelper().enqueueOfflineAction(
          'food_upsert',
          trackedFood.toJson(),
          e.toString(),
        );
      }
      FoodItem foodWithId = trackedFood.copyWith(id: newRemoteId);
      List<ConsumedFoodItem> mealList = _getMealList(mealName);
      int index = mealList.indexWhere((item) => item.food.id == foodWithId.id);
      if (index != -1) {
        ConsumedFoodItem existingItem = mealList[index];
        if (existingItem.id == null) {
          throw Exception("ConsumedFoodItem hat keine ID.");
        }
        int newQuantity = existingItem.quantity + quantity;
        await DatabaseHelper().updateConsumedFood(
          existingItem.id!,
          newQuantity,
        );
        ConsumedFoodItem updatedItem = existingItem.copyWith(
          food: foodWithId,
          quantity: newQuantity,
        );
        mealList[index] = updatedItem;
      } else {
        int consumedFoodId = await DatabaseHelper().insertConsumedFood(
          date,
          mealName,
          foodWithId.id!,
          quantity,
        );
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
      await loadRecentFoodItems();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateConsumedFoodItem(
    ConsumedFoodItem consumedFood, {
    int? newQuantity,
    String? newMealName,
  }) async {
    try {
      int updatedQuantity = newQuantity ?? consumedFood.quantity;
      String updatedMealName = newMealName ?? consumedFood.mealName;
      await DatabaseHelper().updateConsumedFood(
        consumedFood.id!,
        updatedQuantity,
        newMealName: updatedMealName,
      );
      final updatedFood = consumedFood.food.copyWith(
        lastUsedQuantity: updatedQuantity,
      );
      await _remoteService.insertOrUpdateFoodItem(updatedFood);
      List<ConsumedFoodItem> oldMealList = _getMealList(consumedFood.mealName);
      oldMealList.removeWhere((item) => item.id == consumedFood.id);
      List<ConsumedFoodItem> newMealList = _getMealList(updatedMealName);
      ConsumedFoodItem updatedConsumedFood = consumedFood.copyWith(
        food: updatedFood,
        quantity: updatedQuantity,
        mealName: updatedMealName,
      );
      newMealList.add(updatedConsumedFood);
      _calculateConsumedMacros();
      await loadRecentFoodItems();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  List<ConsumedFoodItem> _getMealList(String mealName) {
    if (mealName == 'Frühstück') return breakfast;
    if (mealName == 'Mittagessen') return lunch;
    if (mealName == 'Abendessen') return dinner;
    if (mealName == 'Snacks') return snacks;
    return [];
  }

  Future<void> removeFood(
    String mealName,
    ConsumedFoodItem consumedFood,
  ) async {
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
      rethrow;
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
      await initializeCompletely();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> previousDay() async {
    currentDate = currentDate.subtract(const Duration(days: 1));
    await loadConsumedFoods();
    notifyListeners();
  }

  Future<void> nextDay() async {
    currentDate = currentDate.add(const Duration(days: 1));
    await loadConsumedFoods();
    notifyListeners();
  }

  Future<String> exportDatabase() async {
    try {
      Map<String, dynamic> data = await DatabaseHelper().exportData();
      return jsonEncode(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> importDatabase(String jsonData) async {
    try {
      await DatabaseHelper().mergeData(jsonData);
      await initializeCompletely();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<FoodItem?> loadFoodItemByBarcode(String barcode) async {
    try {
      return await _remoteService.getFoodItemByBarcode(barcode);
    } catch (e) {
      return null;
    }
  }

  Future<List<FoodItem>> loadAllFoodItems() async {
    try {
      return await _remoteService.getAllFoodItems();
    } catch (e) {
      return [];
    }
  }

  Future<FoodItem> updateBarcodeForFood(FoodItem food, String barcode) async {
    if (food.id == null) {
      final newId = await _remoteService.insertOrUpdateFoodItem(
        food.copyWith(barcode: barcode),
      );
      return food.copyWith(id: newId, barcode: barcode);
    } else {
      await _remoteService.updateBarcode(food.id!, barcode);
      return food.copyWith(barcode: barcode);
    }
  }

  Future<List<FoodItem>> searchFoodItemsRemote(String query) async {
    try {
      List<FoodItem> results = await _remoteService.searchFoodItems(query);
      results = results
          .where(
            (f) => !(f.caloriesPer100g == 0 &&
                f.fatPer100g == 0 &&
                f.carbsPer100g == 0 &&
                f.sugarPer100g == 0 &&
                f.proteinPer100g == 0),
          )
          .toList();
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<FoodItem?> searchOpenFoodFactsByBarcode(String barcode) async {
    final cacheKey = barcode.trim().toLowerCase();
    if (_offBarcodeCache.containsKey(cacheKey)) {
      return _offBarcodeCache[cacheKey];
    }
    try {
      final url = Uri.parse(
        '$openFoodFactsBaseUrl/api/v0/product/$barcode.json',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'MacroMate/1.0 (Barcodesuche)'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          final nutriments = product['nutriments'] ?? {};
          final calories = (nutriments['energy-kcal_100g'] ?? 0).toDouble();
          final fat = (nutriments['fat_100g'] ?? 0).toDouble();
          final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
          final sugar = (nutriments['sugars_100g'] ?? 0).toDouble();
          final protein = (nutriments['proteins_100g'] ?? 0).toDouble();
          final item = FoodItem(
            name: product['product_name'] ?? 'Unbekannt',
            brand: product['brands'] ?? 'Unbekannt',
            barcode: barcode,
            caloriesPer100g: calories.round(),
            fatPer100g: fat,
            carbsPer100g: carbs,
            sugarPer100g: sugar,
            proteinPer100g: protein,
            source: 'openfoodfacts',
          );
          _offBarcodeCache[cacheKey] = item;
          return item;
        }
      } else if (response.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 2));
        final retryResponse = await http.get(
          url,
          headers: {'User-Agent': 'MacroMate/1.0 (Barcodesuche)'},
        );
        if (retryResponse.statusCode == 200) {
          final data = jsonDecode(retryResponse.body);
          if (data['status'] == 1 && data['product'] != null) {
            final product = data['product'];
            final nutriments = product['nutriments'] ?? {};
            final calories = (nutriments['energy-kcal_100g'] ?? 0).toDouble();
            final fat = (nutriments['fat_100g'] ?? 0).toDouble();
            final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
            final sugar = (nutriments['sugars_100g'] ?? 0).toDouble();
            final protein = (nutriments['proteins_100g'] ?? 0).toDouble();
            final item = FoodItem(
              name: product['product_name'] ?? 'Unbekannt',
              brand: product['brands'] ?? 'Unbekannt',
              barcode: barcode,
              caloriesPer100g: calories.round(),
              fatPer100g: fat,
              carbsPer100g: carbs,
              sugarPer100g: sugar,
              proteinPer100g: protein,
              source: 'openfoodfacts',
            );
            _offBarcodeCache[cacheKey] = item;
            return item;
          }
        }
      }
    } catch (e, st) {
      _logError('searchOpenFoodFactsByBarcode', e, st);
    }
    _offBarcodeCache[cacheKey] = null;
    return null;
  }

  Future<List<FoodItem>> searchOpenFoodFacts(String query) async {
    final cacheKey = query.trim().toLowerCase();
    if (_offSearchCache.containsKey(cacheKey)) {
      return _offSearchCache[cacheKey]!;
    }
    try {
      final encodedQuery = Uri.encodeQueryComponent(query);
      final url = Uri.parse(
        '$openFoodFactsBaseUrl/cgi/search.pl?search_terms=$encodedQuery&search_simple=1&action=process&json=1&page_size=10',
      );
      var response = await http.get(
        url,
        headers: {'User-Agent': 'MacroMate/1.0 (String-Suche)'},
      );
      if (response.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 2));
        response = await http.get(
          url,
          headers: {'User-Agent': 'MacroMate/1.0 (String-Suche)'},
        );
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data['products'] as List<dynamic>?;
        if (products != null && products.isNotEmpty) {
          List<FoodItem> results = [];
          for (var p in products) {
            final nutriments = p['nutriments'] ?? {};
            final calories =
                (nutriments['energy-kcal_100g'] ?? 0).toDouble().round();
            final fat = (nutriments['fat_100g'] ?? 0).toDouble();
            final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
            final sugar = (nutriments['sugars_100g'] ?? 0).toDouble();
            final protein = (nutriments['proteins_100g'] ?? 0).toDouble();
            final item = FoodItem(
              name: p['product_name'] ?? 'Unbekannt',
              brand: p['brands'] ?? 'Unbekannt',
              barcode: p['code'] ?? null,
              caloriesPer100g: calories,
              fatPer100g: fat,
              carbsPer100g: carbs,
              sugarPer100g: sugar,
              proteinPer100g: protein,
              source: 'openfoodfacts',
            );
            results.add(item);
          }
          _offSearchCache[cacheKey] = results;
          return results;
        }
      }
      _offSearchCache[cacheKey] = [];
      return [];
    } catch (e, st) {
      _logError('searchOpenFoodFacts', e, st);
      return [];
    }
  }

  Future<void> loadWeightEntries() async {
    try {
      final dbHelper = DatabaseHelper();
      final entries = await dbHelper.getWeightEntries();
      _weightEntries = entries
          .map(
            (row) => WeightEntry(
              id: row['id'],
              date: DateTime.parse(row['date']),
              weight: (row['weight'] as num).toDouble(),
            ),
          )
          .toList();
      _weightEntries.sort((a, b) => a.date.compareTo(b.date));
    } catch (e, st) {
      _logError('loadWeightEntries', e, st);
    }
  }

  Future<void> addWeightEntry(DateTime date, double weight) async {
    try {
      final dbHelper = DatabaseHelper();
      final insertedId = await dbHelper.insertWeightEntry(date, weight);
      final newEntry = WeightEntry(id: insertedId, date: date, weight: weight);
      _weightEntries.add(newEntry);
      _weightEntries.sort((a, b) => a.date.compareTo(b.date));
      _refreshProteinGoalFromWeightIfNeeded();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateWeightEntry(int id, DateTime date, double weight) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.updateWeightEntry(id, date, weight);
      final index = _weightEntries.indexWhere((entry) => entry.id == id);
      if (index == -1) {
        await loadWeightEntries();
      } else {
        _weightEntries[index] = _weightEntries[index].copyWith(
          date: date,
          weight: weight,
        );
      }
      _weightEntries.sort((a, b) => a.date.compareTo(b.date));
      _refreshProteinGoalFromWeightIfNeeded();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteWeightEntry(int id) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.deleteWeightEntry(id);
      _weightEntries.removeWhere((entry) => entry.id == id);
      _refreshProteinGoalFromWeightIfNeeded();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> recalculateGoals({required bool fromBmr}) async {
    // ───── 0) Hilfsfunktion  ───────────────────────────────────────────────
    bool _isCutMode() =>
        autoMode == AutoCalorieMode.diet ||
        (autoMode == AutoCalorieMode.custom && customPercentPerMonth < 0);
    double targetWeeklyChange(double currentWeight) {
      if (this.targetWeeklyChange != null) {
        return this.targetWeeklyChange!;
      }
      if (targetWeight != null && targetDate != null) {
        final days = targetDate!.difference(DateTime.now()).inDays;
        if (days > 0) {
          return ((targetWeight! - currentWeight) / days) * 7;
        }
      }
      switch (autoMode) {
        case AutoCalorieMode.diet:
          return -currentWeight * 0.01;
        case AutoCalorieMode.bulk:
          return currentWeight * 0.01 / 4;
        case AutoCalorieMode.custom:
          return currentWeight * customPercentPerMonth / 100 / 4;
        case AutoCalorieMode.maintain:
        case AutoCalorieMode.off:
          return 0.0;
      }
    }

    int calorieDeltaForWeeklyWeightChange(double weeklyKg) {
      return (weeklyKg * 7700 / 7).round();
    }

    // 1. Gemeinsame Hilfswerte
    double weight =
        _weightEntries.isNotEmpty ? _weightEntries.last.weight : 80.0;
    final safeCalories = dailyCalorieGoal <= 0 ? 1 : dailyCalorieGoal;
    double carbPerc = (dailyCarbGoal * 4) / safeCalories * 100;
    double proteinPerc = (dailyProteinGoal * 4) / safeCalories * 100;
    double fatPerc = (dailyFatGoal * 9) / safeCalories * 100;

    // ───── A) Initial-/Reset-Berechnung ────────────────────────────────────
    if (fromBmr) {
      if (useCustomStartCalories && !firstWeekInitialized) {
        dailyCalorieGoal = userStartCalories;
      } else {
        // ► BMR (Harris/Mifflin) – unverändert
        double bmr;
        switch (bmrFormula) {
          case BmrFormula.mifflin:
            bmr = 10 * weight +
                6.25 * userHeight -
                5 * userAge +
                (userGender == Gender.male ? 5 : -161);
            break;
          case BmrFormula.harris:
            bmr = (userGender == Gender.male)
                ? 66.47 + 13.7 * weight + 5.0 * userHeight - 6.8 * userAge
                : 655.1 + 9.6 * weight + 1.8 * userHeight - 4.7 * userAge;
            break;
        }
        int baseCal = (bmr * userActivityLevel).round();

        switch (autoMode) {
          case AutoCalorieMode.diet:
          case AutoCalorieMode.bulk:
          case AutoCalorieMode.custom:
            dailyCalorieGoal = (baseCal +
                    calorieDeltaForWeeklyWeightChange(
                      targetWeeklyChange(weight),
                    ))
                .clamp(1000, 6000)
                .toInt();
            break;
          case AutoCalorieMode.maintain:
            dailyCalorieGoal = baseCal;
            break;
          default:
            dailyCalorieGoal = baseCal;
        }
      }
      firstWeekInitialized = true;
    }
    // ───── B) Montag-Feintuning ────────────────────────────────────────────
    else {
      double weeklyChange = computeWeightChangeInLastWeek();
      double targetWeekly = targetWeeklyChange(weight);

      int delta = 0;
      if (_isCutMode()) {
        // Diet-Logik (-100/ +50)
        if (weeklyChange > targetWeekly)
          delta = -100; // zu langsam
        else if (weeklyChange < targetWeekly) delta = 50; // zu schnell
      } else if (autoMode == AutoCalorieMode.bulk ||
          (autoMode == AutoCalorieMode.custom && customPercentPerMonth > 0)) {
        // Bulk-Logik (+100/ -50)
        if (weeklyChange < targetWeekly)
          delta = 100; // zu langsam
        else if (weeklyChange > targetWeekly) delta = -50; // zu schnell
      } else if (autoMode == AutoCalorieMode.maintain) {
        const double tol = 0.15; // ±150 g Toleranz
        if (weeklyChange > tol) delta = -100;
        if (weeklyChange < -tol) delta = 100;
      }

      dailyCalorieGoal = (dailyCalorieGoal + delta).clamp(1000, 6000).toInt();
      mondayPopupMessage =
          "Gewichtsveränderung: ${weeklyChange.toStringAsFixed(1)} kg "
          "(Ziel ${targetWeekly.toStringAsFixed(1)} kg). "
          "Kalorien ${(delta >= 0) ? '+' : ''}$delta ⇒ $dailyCalorieGoal";
      lastMondayCheck = DateTime.now().toIso8601String().substring(
            0,
            10,
          ); // yyyy-MM-dd
    }

    // ───── C) Makroziele aus Kalorien ──────────────────────────────────────
    dailyCarbGoal = (dailyCalorieGoal * carbPerc) / 400;
    dailyProteinGoal = useProteinPerKg
        ? _proteinGoalFromWeight()
        : (dailyCalorieGoal * proteinPerc) / 400;
    dailyFatGoal = (dailyCalorieGoal * fatPerc) / 900;

    // ───── D) Persistenz & Notify ──────────────────────────────────────────
    await DatabaseHelper().saveGoalsExtended(
      dailyCalories: dailyCalorieGoal,
      carbPercentage: carbPerc.round(),
      proteinPercentage: proteinPerc.round(),
      fatPercentage: fatPerc.round(),
      sugarPercentage: dailySugarGoalPercentage,
      autoCalorieModeIndex: autoMode.index,
      customPercentPerMonth: customPercentPerMonth,
      useCustomStartCaloriesInt: useCustomStartCalories ? 1 : 0,
      userStartCalories: userStartCalories,
      userAge: userAge,
      userActivityLevel: userActivityLevel,
      lastMondayCheck: lastMondayCheck,
      firstWeekInitializedVal: firstWeekInitialized,
      userHeightVal: userHeight,
      useProteinPerKgInt: useProteinPerKg ? 1 : 0,
      proteinPerKg: proteinPerKg,
      targetWeight: targetWeight,
      targetDate: targetDate?.toIso8601String(),
      targetWeeklyChange: this.targetWeeklyChange,
    );
    await _updateMacroWidget();
    notifyListeners();
  }
}
