import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/remote_database_service.dart';
import '../services/database_helper.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:http/http.dart' as http;
import '../services/shared_preferences_helper.dart';
import '../main.dart';

const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org';
const String brevoApiKey = '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';
const String senderEmail = 'moehlenkamp100@gmail.com';

class WeightEntry {
  final int? id;
  final DateTime date;
  final double weight;
  WeightEntry({this.id, required this.date, required this.weight});
  WeightEntry copyWith({int? id, DateTime? date, double? weight}) {
    return WeightEntry(id: id ?? this.id, date: date ?? this.date, weight: weight ?? this.weight);
  }
}

enum AutoCalorieMode { off, diet, bulk, custom }

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

  AppState();

  Future<void> initializeCompletely() async {
    tz.initializeTimeZones();
    await loadGoals();
    await loadDarkMode();
    await loadLast20FoodItems();
    await loadConsumedFoods();
    await loadWeightEntries();
    await _tryAutoLogin();
    _autoAdjustCaloriesIfNeeded();
    notifyListeners();
  }

  Future<void> scheduleAllNotifications() async {
    if (reminderWeighEnabled) {
      scheduleDailyNotification(10000, reminderWeighTime, 'Wiegen', 'Zeit zum Wiegen', true, reminderWeighTimeSecond, 10001);
    }
    if (reminderSupplementEnabled) {
      scheduleDailyNotification(20000, reminderSupplementTime, 'Supplement', 'Zeit für Supplements', true, reminderSupplementTimeSecond, 20001);
    }
    if (reminderMealsEnabled) {
      scheduleDailyNotification(30000, reminderBreakfast, 'Frühstück', 'Zeit für das Frühstück', false, null, null);
      scheduleDailyNotification(30001, reminderLunch, 'Mittagessen', 'Zeit für das Mittagessen', false, null, null);
      scheduleDailyNotification(30002, reminderDinner, 'Abendessen', 'Zeit für das Abendessen', false, null, null);
    }
  }

  void scheduleDailyNotification(int id, TimeOfDay time, String title, String body, bool showSecond, TimeOfDay? secondTime, int? secondId) {
    tz.initializeTimeZones();
    final now = DateTime.now();
    final location = tz.getLocation(tz.local.name);
    final firstScheduled = _nextInstanceOfTime(time, now);
    notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(firstScheduled, location),
      NotificationDetails(
        android: AndroidNotificationDetails('daily_notif_channel', 'Tägliche Erinnerung', channelDescription: 'Tägliche Benachrichtigung'),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'erledigt',
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
    );
    if (showSecond && secondTime != null && secondId != null) {
      final secondScheduled = _nextInstanceOfTime(secondTime, now);
      notificationsPlugin.zonedSchedule(
        secondId,
        title,
        body,
        tz.TZDateTime.from(secondScheduled, location),
        NotificationDetails(
          android: AndroidNotificationDetails('daily_notif_channel', 'Tägliche Erinnerung', channelDescription: 'Tägliche Benachrichtigung'),
          iOS: DarwinNotificationDetails(),
        ),
        payload: 'erledigt',
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
      );
    }
  }

  DateTime _nextInstanceOfTime(TimeOfDay t, DateTime base) {
    final scheduled = DateTime(base.year, base.month, base.day, t.hour, t.minute);
    if (scheduled.isBefore(base)) {
      return scheduled.add(const Duration(days: 1));
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
      } catch (e) {}
    }
  }

  Future<bool> login(String email, String password, {bool storeCredentials = true}) async {
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
      await _remoteService.insertUserWithVerification(email, hashed, verificationCode);
      await sendVerificationEmail(email, verificationCode);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendVerificationEmail(String recipientEmail, String code) async {
    const endpoint = 'https://api.brevo.com/v3/smtp/email';
    final body = {
      'to': [{'email': recipientEmail}],
      'sender': {'email': senderEmail},
      'subject': 'Dein Bestätigungscode',
      'htmlContent': '<h3>Hallo!</h3><p>Dein Code lautet: <b>$code</b>.</p><p>Gib diesen Code in der App ein, um dein Konto zu aktivieren.</p>',
    };
    try {
      await http.post(Uri.parse(endpoint), headers: {'accept': 'application/json', 'api-key': brevoApiKey, 'content-type': 'application/json'}, body: jsonEncode(body));
    } catch (e) {}
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
    try {
      last20FoodItems = await _remoteService.getLastAddedFoodItems(20);
    } catch (e) {}
  }

  Future<void> loadConsumedFoods() async {
    try {
      final dbHelper = DatabaseHelper();
      List<ConsumedFoodItem> consumedFoods = await dbHelper.getConsumedFoods(currentDate);
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
      breakfast = consumedFoods.where((f) => f.mealName == 'Frühstück').toList();
      lunch = consumedFoods.where((f) => f.mealName == 'Mittagessen').toList();
      dinner = consumedFoods.where((f) => f.mealName == 'Abendessen').toList();
      snacks = consumedFoods.where((f) => f.mealName == 'Snacks').toList();
      _calculateConsumedMacros();
    } catch (e) {}
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
        autoMode = AutoCalorieMode.values[goals['auto_calorie_mode'] ?? 0];
        customPercentPerMonth = (goals['custom_percent_per_month'] ?? 1.0) * 1.0;
        useCustomStartCalories = (goals['use_custom_start_calories'] ?? 0) == 1;
        userStartCalories = goals['user_start_calories'] ?? 2000;
        userAge = goals['user_age'] ?? 30;
        userActivityLevel = (goals['user_activity_level'] ?? 1.3).toDouble();
        lastMondayCheck = goals['last_monday_check'];
        dailyCarbGoal = (dailyCalorieGoal * carbPerc / 100) / 4.0;
        dailyProteinGoal = (dailyCalorieGoal * proteinPerc / 100) / 4.0;
        dailyFatGoal = (dailyCalorieGoal * fatPerc / 100) / 9.0;
        dailySugarGoalPercentage = sugarPerc;
      }
    } catch (e) {}
  }

  Future<void> updateGoals(int newCalorieGoal, int carbPerc, int proteinPerc, int fatPerc, int sugarPerc) async {
    try {
      dailyCalorieGoal = newCalorieGoal;
      dailyCarbGoal = (dailyCalorieGoal * carbPerc / 100) / 4.0;
      dailyProteinGoal = (dailyCalorieGoal * proteinPerc / 100) / 4.0;
      dailyFatGoal = (dailyCalorieGoal * fatPerc / 100) / 9.0;
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
      );
      _autoAdjustCaloriesIfNeeded();
      notifyListeners();
    } catch (e) {}
  }

  Future<void> loadDarkMode() async {
    try {
      isDarkMode = await DatabaseHelper().getDarkMode();
    } catch (e) {}
  }

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode = value;
    await DatabaseHelper().saveDarkMode(isDarkMode);
    notifyListeners();
  }

  void _autoAdjustCaloriesIfNeeded() {
    if (autoMode == AutoCalorieMode.off) {
      return;
    }
    double currentWeight = 80.0;
    if (_weightEntries.isNotEmpty) {
      currentWeight = _weightEntries.last.weight;
    }
    double bmr = 66 + (13.7 * currentWeight) + (5 * 170) - (6.8 * userAge);
    double baseCalDouble = bmr * userActivityLevel;
    int baseCal = baseCalDouble.round();
    if (useCustomStartCalories) {
      baseCal = userStartCalories;
    }
    if (autoMode == AutoCalorieMode.diet) {
      int dietCal = (baseCal * 0.80).round();
      double newProtein = 2.2 * currentWeight;
      double newFat = 1.0 * currentWeight;
      double calProtein = newProtein * 4;
      double calFat = newFat * 9;
      double restForCarbs = dietCal - calProtein - calFat;
      if (restForCarbs < 0) {
        restForCarbs = 0;
      }
      double newCarbs = restForCarbs / 4;
      dailyCalorieGoal = dietCal;
      dailyProteinGoal = newProtein;
      dailyFatGoal = newFat;
      dailyCarbGoal = newCarbs;
      _adjustCaloriesInStepsIfWeightNotInRange();
      notifyListeners();
    } else if (autoMode == AutoCalorieMode.bulk) {
      int surplusCals = (baseCal * 1.15).round();
      double newProtein = 2.0 * currentWeight;
      double newFat = 1.0 * currentWeight;
      double calProtein = newProtein * 4;
      double calFat = newFat * 9;
      double restForCarbs = surplusCals - calProtein - calFat;
      if (restForCarbs < 0) {
        restForCarbs = 0;
      }
      double newCarbs = restForCarbs / 4;
      dailyCalorieGoal = surplusCals;
      dailyProteinGoal = newProtein;
      dailyFatGoal = newFat;
      dailyCarbGoal = newCarbs;
      _adjustCaloriesInStepsIfWeightNotInRange();
      notifyListeners();
    } else if (autoMode == AutoCalorieMode.custom) {
      double factor = 1.0 + (customPercentPerMonth / 100.0);
      int adjusted = (baseCal * factor).round();
      double calsCarb = adjusted * 0.50;
      double calsProt = adjusted * 0.25;
      double calsFat = adjusted * 0.25;
      dailyCalorieGoal = adjusted;
      dailyCarbGoal = calsCarb / 4.0;
      dailyProteinGoal = calsProt / 4.0;
      dailyFatGoal = calsFat / 9.0;
      _adjustCaloriesInStepsIfWeightNotInRange();
      notifyListeners();
    }
  }

  void _adjustCaloriesInStepsIfWeightNotInRange() {
    if (_weightEntries.length < 2) {
      return;
    }
    double lastWeight = _weightEntries[_weightEntries.length - 1].weight;
    double secondLastWeight = _weightEntries[_weightEntries.length - 2].weight;
    double diff = (lastWeight - secondLastWeight).abs();
    if (autoMode == AutoCalorieMode.diet) {
      if (diff < 0.2) {
        dailyCalorieGoal -= 100;
      } else if (diff > 1.5) {
        dailyCalorieGoal += 100;
      }
    } else if (autoMode == AutoCalorieMode.bulk) {
      if (diff < 0.1) {
        dailyCalorieGoal += 100;
      } else if (diff > 1.0) {
        dailyCalorieGoal -= 100;
      }
    }
    notifyListeners();
  }

  Future<void> _checkMondayAndAutoAdjustIfNeeded() async {
    if (autoMode == AutoCalorieMode.off) return;
    final now = DateTime.now();
    if (now.weekday == DateTime.monday) {
      final todayString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      if (lastMondayCheck != todayString) {
        _autoAdjustCaloriesIfNeeded();
        lastMondayCheck = todayString;
        await DatabaseHelper().saveGoalsExtended(
          dailyCalories: dailyCalorieGoal,
          carbPercentage: ((dailyCarbGoal * 4) / dailyCalorieGoal * 100).round(),
          proteinPercentage: ((dailyProteinGoal * 4) / dailyCalorieGoal * 100).round(),
          fatPercentage: ((dailyFatGoal * 9) / dailyCalorieGoal * 100).round(),
          sugarPercentage: dailySugarGoalPercentage,
          autoCalorieModeIndex: autoMode.index,
          customPercentPerMonth: customPercentPerMonth,
          useCustomStartCaloriesInt: useCustomStartCalories ? 1 : 0,
          userStartCalories: userStartCalories,
          userAge: userAge,
          userActivityLevel: userActivityLevel,
          lastMondayCheck: lastMondayCheck,
        );
        notifyListeners();
      }
    }
  }

  Future<void> addOrUpdateFood(String mealName, FoodItem food, int quantity, DateTime date) async {
    try {
      final newRemoteId = await _remoteService.insertOrUpdateFoodItem(food);
      FoodItem foodWithId = food.copyWith(id: newRemoteId);
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
        ConsumedFoodItem newConsumedFood = ConsumedFoodItem(id: consumedFoodId, food: foodWithId, quantity: quantity, date: date, mealName: mealName);
        mealList.add(newConsumedFood);
      }
      _calculateConsumedMacros();
      await loadLast20FoodItems();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateConsumedFoodItem(ConsumedFoodItem consumedFood, {int? newQuantity, String? newMealName}) async {
    try {
      int updatedQuantity = newQuantity ?? consumedFood.quantity;
      String updatedMealName = newMealName ?? consumedFood.mealName;
      await DatabaseHelper().updateConsumedFood(consumedFood.id!, updatedQuantity, newMealName: updatedMealName);
      List<ConsumedFoodItem> oldMealList = _getMealList(consumedFood.mealName);
      oldMealList.removeWhere((item) => item.id == consumedFood.id);
      List<ConsumedFoodItem> newMealList = _getMealList(updatedMealName);
      ConsumedFoodItem updatedConsumedFood = consumedFood.copyWith(quantity: updatedQuantity, mealName: updatedMealName);
      newMealList.add(updatedConsumedFood);
      _calculateConsumedMacros();
      await loadLast20FoodItems();
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

  Future<void> updateBarcodeForFood(FoodItem food, String barcode) async {
    if (food.id == null) {
      final newId = await _remoteService.insertOrUpdateFoodItem(food.copyWith(barcode: barcode));
      food = food.copyWith(id: newId, barcode: barcode);
    } else {
      await _remoteService.updateBarcode(food.id!, barcode);
    }
  }

  Future<List<FoodItem>> searchFoodItemsRemote(String query) async {
    try {
      return await _remoteService.searchFoodItems(query);
    } catch (e) {
      return [];
    }
  }

  Future<FoodItem?> searchOpenFoodFactsByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$openFoodFactsBaseUrl/api/v0/product/$barcode.json');
      final response = await http.get(url, headers: {'User-Agent': 'MacroMate/1.0 (Barcodesuche)'});
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
          return FoodItem(
            name: product['product_name'] ?? 'Unbekannt',
            brand: product['brands'] ?? 'Unbekannt',
            barcode: barcode,
            caloriesPer100g: calories.round(),
            fatPer100g: fat,
            carbsPer100g: carbs,
            sugarPer100g: sugar,
            proteinPer100g: protein,
          );
        }
      } else if (response.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 2));
        final retryResponse = await http.get(url, headers: {'User-Agent': 'MacroMate/1.0 (Barcodesuche)'});
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
            return FoodItem(
              name: product['product_name'] ?? 'Unbekannt',
              brand: product['brands'] ?? 'Unbekannt',
              barcode: barcode,
              caloriesPer100g: calories.round(),
              fatPer100g: fat,
              carbsPer100g: carbs,
              sugarPer100g: sugar,
              proteinPer100g: protein,
            );
          }
        }
      }
    } catch (e) {}
    return null;
  }

  Future<List<FoodItem>> searchOpenFoodFacts(String query) async {
    try {
      final encodedQuery = Uri.encodeQueryComponent(query);
      final url = Uri.parse('$openFoodFactsBaseUrl/cgi/search.pl?search_terms=$encodedQuery&search_simple=1&action=process&json=1&page_size=10');
      var response = await http.get(url, headers: {'User-Agent': 'MacroMate/1.0 (String-Suche)'});
      if (response.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 2));
        response = await http.get(url, headers: {'User-Agent': 'MacroMate/1.0 (String-Suche)'});
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data['products'] as List<dynamic>?;
        if (products != null && products.isNotEmpty) {
          List<FoodItem> results = [];
          for (var p in products) {
            final nutriments = p['nutriments'] ?? {};
            final calories = (nutriments['energy-kcal_100g'] ?? 0).toDouble().round();
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
            );
            results.add(item);
          }
          return results;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> loadWeightEntries() async {
    try {
      final dbHelper = DatabaseHelper();
      final entries = await dbHelper.getWeightEntries();
      _weightEntries = entries.map((row) => WeightEntry(id: row['id'], date: DateTime.parse(row['date']), weight: row['weight'] as double)).toList();
      _weightEntries.sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {}
  }

  Future<void> addWeightEntry(DateTime date, double weight) async {
    try {
      final dbHelper = DatabaseHelper();
      final insertedId = await dbHelper.insertWeightEntry(date, weight);
      final newEntry = WeightEntry(id: insertedId, date: date, weight: weight);
      _weightEntries.add(newEntry);
      _weightEntries.sort((a, b) => a.date.compareTo(b.date));
      _autoAdjustCaloriesIfNeeded();
      notifyListeners();
    } catch (e) {}
  }
}
