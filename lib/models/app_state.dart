// lib/models/app_state.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';

import '../services/remote_database_service.dart';
import '../services/database_helper.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';

// Bcrypt-Package (für Passwort-Hashing)
import 'package:bcrypt/bcrypt.dart';

// NEU: HTTP-Client + Brevo (Sendinblue) E-Mail-Versand
import 'package:http/http.dart' as http;

// NEU: SharedPreferencesHelper für Auto-Login
import '../services/shared_preferences_helper.dart';

// NEU: Für Open Food Facts
const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org';

/// Hier konfigurierst du deinen Brevo-API-Key und Absender
const String brevoApiKey =
    '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'; // <--- ANPASSEN
const String senderEmail = 'moehlenkamp100@gmail.com'; // <--- ANPASSEN

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

  // Login-Status
  bool isLoggedIn = false;

  AppState();

  Future<void> initializeCompletely() async {
    // 1) Versuche Dark Mode, Goals etc. zu laden
    await loadGoals();
    await loadDarkMode();
    await loadLast20FoodItems();
    await loadConsumedFoods();

    // 2) Versuche Auto-Login
    await _tryAutoLogin();

    notifyListeners();
  }

  // ---------------------------------------------------
  // AUTO-LOGIN: Wenn Email/Passwort lokal gespeichert
  // ---------------------------------------------------
  Future<void> _tryAutoLogin() async {
    final savedEmail = await SharedPreferencesHelper.loadUserEmail();
    final savedPass = await SharedPreferencesHelper.loadUserPassword();

    if (savedEmail != null && savedPass != null) {
      try {
        final ok = await login(savedEmail, savedPass, storeCredentials: false);
        if (ok) {
          print('Auto-Login erfolgreich für $savedEmail');
        } else {
          print('Auto-Login fehlgeschlagen.');
        }
      } catch (e) {
        print('Auto-Login Exception: $e');
      }
    }
  }

  // ---------------------------------------------------
  // Login / Registrierung
  // ---------------------------------------------------
  /// Optionaler Parameter [storeCredentials]: Ob wir nach Erfolg
  /// E-Mail/Passwort in SharedPrefs speichern sollen.
  Future<bool> login(String email, String password,
      {bool storeCredentials = true}) async {
    try {
      final userRow = await _remoteService.getUserByEmail(email);
      if (userRow == null) {
        return false; // Kein User gefunden
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
        return false; // E-Mail bereits vergeben
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
      print('Fehler bei registerUser: $e');
      return false;
    }
  }

  Future<void> sendVerificationEmail(String recipientEmail, String code) async {
    const endpoint = 'https://api.brevo.com/v3/smtp/email';

    final body = {
      'to': [
        {'email': recipientEmail}
      ],
      'sender': {
        'email': senderEmail,
      },
      'subject': 'Dein Bestätigungscode',
      'htmlContent': '<h3>Hallo!</h3>'
          '<p>Dein Code lautet: <b>$code</b>.</p>'
          '<p>Gib diesen Code in der App ein, um dein Konto zu aktivieren.</p>',
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'accept': 'application/json',
          'api-key': brevoApiKey,
          'content-type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Verifizierungs-Mail erfolgreich gesendet an $recipientEmail');
      } else {
        print('Fehler beim Senden der Mail: ${response.body}');
      }
    } catch (e) {
      print('sendVerificationEmail EXCEPTION: $e');
    }
  }

  String _generateVerificationCode() {
    final rnd = Random();
    final code = rnd.nextInt(900000) + 100000; // 6-stellig
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
      print('verifyAccount EXCEPTION: $e');
      return false;
    }
  }

  // ---------------------------------------------------
  // Logout-Funktion
  // ---------------------------------------------------
  Future<void> logout() async {
    // Lokale Credentials löschen und Zustand zurücksetzen
    await SharedPreferencesHelper.clearUserCredentials();
    isLoggedIn = false;
    notifyListeners();
  }

  // ---------------------------------------------------
  // ACCOUNT LÖSCHEN
  // ---------------------------------------------------
  Future<bool> deleteAccount() async {
    try {
      // Hole gespeicherte E-Mail aus SharedPrefs
      final email = await SharedPreferencesHelper.loadUserEmail();
      if (email == null) {
        print('deleteAccount: Keine E-Mail gefunden.');
        return false;
      }

      // Auf dem Server löschen
      await _remoteService.deleteUserByEmail(email);

      // Danach logout
      await logout();

      return true;
    } catch (e) {
      print('Fehler beim Löschen des Accounts: $e');
      return false;
    }
  }

  // ---------------------------------------------------
  // Normaler App-Flow
  // ---------------------------------------------------
  Future<void> loadLast20FoodItems() async {
    try {
      // Wir laden nur die Foods (READ-Operation)
      last20FoodItems = await _remoteService.getLastAddedFoodItems(20);
    } catch (e) {
      print('Fehler beim Laden der letzten 20 FoodItems aus Remote: $e');
    }
  }

  Future<void> loadConsumedFoods() async {
    try {
      final dbHelper = DatabaseHelper();
      List<ConsumedFoodItem> consumedFoods =
          await dbHelper.getConsumedFoods(currentDate);

      // Wir ziehen uns die passenden (bereits existierenden) Remote-Foods per ID,
      // aber keinerlei Remote-Löschungen oder -Bearbeitungen mehr.
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

    for (var cItem in breakfast + lunch + dinner + snacks) {
      consumedCalories += (cItem.food.caloriesPer100g * cItem.quantity) / 100;
      consumedCarbs += (cItem.food.carbsPer100g * cItem.quantity) / 100;
      consumedProtein += (cItem.food.proteinPer100g * cItem.quantity) / 100;
      consumedFat += (cItem.food.fatPer100g * cItem.quantity) / 100;
      consumedSugar += (cItem.food.sugarPer100g * cItem.quantity) / 100;
    }
  }

  double get dailySugarGoalGrams =>
      dailyCarbGoal * dailySugarGoalPercentage / 100;

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

  Future<void> updateGoals(
    int newCalorieGoal,
    int carbPerc,
    int proteinPerc,
    int fatPerc,
    int sugarPerc,
  ) async {
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

  // ------------------------------------------------------------
  // AB HIER KEINE Remote-Bearbeitung oder -Löschung mehr
  // ------------------------------------------------------------
  Future<void> addOrUpdateFood(
    String mealName,
    FoodItem food,
    int quantity,
    DateTime date,
  ) async {
    try {
      final newRemoteId = await _remoteService.insertOrUpdateFoodItem(food);
      FoodItem foodWithId = food.copyWith(id: newRemoteId);

      // Lokal in ConsumedFood aktualisieren/einfügen
      List<ConsumedFoodItem> mealList = _getMealList(mealName);
      int index = mealList.indexWhere((item) => item.food.id == foodWithId.id);

      if (index != -1) {
        // Bereits vorhandenes Food -> Menge addieren
        ConsumedFoodItem existingItem = mealList[index];
        if (existingItem.id == null) {
          throw Exception("ConsumedFoodItem hat keine ID.");
        }
        int newQuantity = existingItem.quantity + quantity;

        await DatabaseHelper().updateConsumedFood(
          existingItem.id!,
          newQuantity,
        );

        ConsumedFoodItem updatedItem =
            existingItem.copyWith(quantity: newQuantity);
        mealList[index] = updatedItem;
      } else {
        // Ganz neu
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
      await loadLast20FoodItems(); // Nur read
      notifyListeners();
    } catch (e) {
      print('Fehler beim Hinzufügen/Aktualisieren (remote) des Lebensmittels: $e');
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

      // Nur lokales Update in DB
      await DatabaseHelper().updateConsumedFood(
        consumedFood.id!,
        updatedQuantity,
        newMealName: updatedMealName,
      );

      // Move in-memory
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
      rethrow;
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
      print('Fehler beim Entfernen (lokal) des Lebensmittels: $e');
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
      print('Fehler beim Zurücksetzen der local DB: $e');
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
      print('Fehler beim Exportieren der local DB: $e');
      rethrow;
    }
  }

  Future<void> importDatabase(String jsonData) async {
    try {
      await DatabaseHelper().mergeData(jsonData);
      await initializeCompletely();
      notifyListeners();
    } catch (e) {
      print('Fehler beim Importieren der local DB (Merge): $e');
      rethrow;
    }
  }

  Future<FoodItem?> loadFoodItemByBarcode(String barcode) async {
    try {
      return await _remoteService.getFoodItemByBarcode(barcode);
    } catch (e) {
      print("Fehler beim Laden via Barcode: $e");
      return null;
    }
  }

  Future<List<FoodItem>> loadAllFoodItems() async {
    try {
      return await _remoteService.getAllFoodItems();
    } catch (e) {
      print("Fehler beim Laden aller FoodItems: $e");
      return [];
    }
  }

  Future<void> updateBarcodeForFood(FoodItem food, String barcode) async {
    if (food.id == null) {
      final newId = await _remoteService.insertOrUpdateFoodItem(
        food.copyWith(barcode: barcode),
      );
      food = food.copyWith(id: newId, barcode: barcode);
    } else {
      await _remoteService.updateBarcode(food.id!, barcode);
    }
  }

  Future<List<FoodItem>> searchFoodItemsRemote(String query) async {
    try {
      return await _remoteService.searchFoodItems(query);
    } catch (e) {
      print("Fehler bei Remote-Suche: $e");
      return [];
    }
  }

  // ----------------------------------------------------------------
  // ANPASSUNG FÜR OPENFOODFACTS-SUCHE + RETRY BEI 429
  // ----------------------------------------------------------------
  Future<FoodItem?> searchOpenFoodFactsByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$openFoodFactsBaseUrl/api/v0/product/$barcode.json');
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'MacroMate/1.0 (Barcodesuche)',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];

          // Nährwerte
          final nutriments = product['nutriments'] ?? {};
          final calories = (nutriments['energy-kcal_100g'] ?? 0).toDouble();
          final fat = (nutriments['fat_100g'] ?? 0).toDouble();
          final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
          final sugar = (nutriments['sugars_100g'] ?? 0).toDouble();
          final protein = (nutriments['proteins_100g'] ?? 0).toDouble();

          final foundItem = FoodItem(
            name: product['product_name'] ?? 'Unbekannt',
            brand: product['brands'] ?? 'Unbekannt',
            barcode: barcode,
            caloriesPer100g: calories.round(), // gerundet auf int
            fatPer100g: fat,
            carbsPer100g: carbs,
            sugarPer100g: sugar,
            proteinPer100g: protein,
          );
          return foundItem;
        }
      } else if (response.statusCode == 429) {
        // Retry nach kurzer Wartezeit
        print('OpenFoodFacts-Barcode: Status 429 -> Warte 2 Sekunden & retry...');
        await Future.delayed(const Duration(seconds: 2));
        // Erneuter Versuch
        final retryResponse = await http.get(
          url,
          headers: {
            'User-Agent': 'MacroMate/1.0 (Barcodesuche)',
          },
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
    } catch (e) {
      print("Fehler bei der OpenFoodFacts-Barcode-Suche: $e");
    }
    return null;
  }

  /// Einfache Suche nach Produkten (Name) über die Open Food Facts Search-API.
  /// Falls 429 kommt, wird einmal nach kurzer Wartezeit erneut versucht.
  Future<List<FoodItem>> searchOpenFoodFacts(String query) async {
    try {
      // Wichtig: Encode Query, um Probleme mit Sonderzeichen zu vermeiden
      final encodedQuery = Uri.encodeQueryComponent(query);
      final url = Uri.parse(
        '$openFoodFactsBaseUrl/cgi/search.pl?search_terms=$encodedQuery&search_simple=1&action=process&json=1&page_size=10',
      );

      // Mit User-Agent-Header
      http.Response response = await http.get(
        url,
        headers: {
          'User-Agent': 'MacroMate/1.0 (String-Suche)',
        },
      );

      // Falls 429 -> Retry
      if (response.statusCode == 429) {
        print('OpenFoodFacts-Suche: HTTP-Status 429 - Warte 2 Sekunden & retry...');
        await Future.delayed(const Duration(seconds: 2));
        response = await http.get(
          url,
          headers: {
            'User-Agent': 'MacroMate/1.0 (String-Suche)',
          },
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
            );
            results.add(item);
          }
          return results;
        }
      } else {
        print('OpenFoodFacts-Suche: HTTP-Status ${response.statusCode}');
      }
    } catch (e) {
      print("Fehler bei der OpenFoodFacts-Suche: $e");
    }
    return [];
  }
}
