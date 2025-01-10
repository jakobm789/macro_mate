import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../models/food_item.dart';
import '../models/consumed_food_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static const int _dbVersion = 17;

  Future<Database> _initDatabase() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'food_database.db');

      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw Exception("Fehler beim Initialisieren der Datenbank: $e");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_calories INTEGER NOT NULL,
        carb_percentage INTEGER NOT NULL,
        protein_percentage INTEGER NOT NULL,
        fat_percentage INTEGER NOT NULL,
        sugar_percentage INTEGER NOT NULL,
        auto_calorie_mode INTEGER NOT NULL DEFAULT 0,
        custom_percent_per_month REAL NOT NULL DEFAULT 1.0,
        use_custom_start_calories INTEGER NOT NULL DEFAULT 0,
        user_start_calories INTEGER NOT NULL DEFAULT 2000,
        user_age INTEGER NOT NULL DEFAULT 30,
        user_activity_level REAL NOT NULL DEFAULT 1.3,
        last_monday_check TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ConsumedFoods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        meal_name TEXT NOT NULL,
        food_id INTEGER NOT NULL, 
        quantity INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dark_mode INTEGER NOT NULL DEFAULT 0,
        reminder_weigh_enabled INTEGER NOT NULL DEFAULT 0,
        reminder_weigh_time TEXT NOT NULL DEFAULT '08:00',
        reminder_weigh_time2 TEXT NOT NULL DEFAULT '09:00',
        reminder_supplement_enabled INTEGER NOT NULL DEFAULT 0,
        reminder_supplement_time TEXT NOT NULL DEFAULT '10:00',
        reminder_supplement_time2 TEXT NOT NULL DEFAULT '11:00',
        reminder_meals_enabled INTEGER NOT NULL DEFAULT 0,
        reminder_breakfast TEXT NOT NULL DEFAULT '07:00',
        reminder_lunch TEXT NOT NULL DEFAULT '12:30',
        reminder_dinner TEXT NOT NULL DEFAULT '19:00'
      )
    ''');

    await db.execute('''
      CREATE TABLE WeightEntries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        weight REAL NOT NULL
      )
    ''');

    List<Map<String, dynamic>> settings = await db.query('Settings');
    if (settings.isEmpty) {
      await db.insert('Settings', {
        'dark_mode': 0,
        'reminder_weigh_enabled': 0,
        'reminder_weigh_time': '08:00',
        'reminder_weigh_time2': '09:00',
        'reminder_supplement_enabled': 0,
        'reminder_supplement_time': '10:00',
        'reminder_supplement_time2': '11:00',
        'reminder_meals_enabled': 0,
        'reminder_breakfast': '07:00',
        'reminder_lunch': '12:30',
        'reminder_dinner': '19:00'
      });
    }

    List<Map<String, dynamic>> goals = await db.query('Goals');
    if (goals.isEmpty) {
      await db.insert('Goals', {
        'daily_calories': 2000,
        'carb_percentage': 50,
        'protein_percentage': 30,
        'fat_percentage': 20,
        'sugar_percentage': 20,
        'auto_calorie_mode': 0,
        'custom_percent_per_month': 1.0,
        'use_custom_start_calories': 0,
        'user_start_calories': 2000,
        'user_age': 30,
        'user_activity_level': 1.3,
        'last_monday_check': null,
      });
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 14) {
      try {
        await db.execute('DROP TABLE IF EXISTS Users');
      } catch (_) {}
    }

    if (oldVersion < 15) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS WeightEntries(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          weight REAL NOT NULL
        )
      ''');
    }
    if (oldVersion < 16) {
      try {
        await db.execute("ALTER TABLE Goals ADD COLUMN auto_calorie_mode INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Goals ADD COLUMN custom_percent_per_month REAL NOT NULL DEFAULT 1.0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Goals ADD COLUMN use_custom_start_calories INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Goals ADD COLUMN user_start_calories INTEGER NOT NULL DEFAULT 2000");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Goals ADD COLUMN user_age INTEGER NOT NULL DEFAULT 30");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Goals ADD COLUMN user_activity_level REAL NOT NULL DEFAULT 1.3");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Goals ADD COLUMN last_monday_check TEXT");
      } catch (_) {}
    }
    if (oldVersion < 17) {
      try {
        await db.execute("ALTER TABLE Settings ADD COLUMN reminder_weigh_enabled INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Settings ADD COLUMN reminder_weigh_time TEXT NOT NULL DEFAULT '08:00'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Settings ADD COLUMN reminder_weigh_time2 TEXT NOT NULL DEFAULT '09:00'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Settings ADD COLUMN reminder_supplement_enabled INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Settings ADD COLUMN reminder_supplement_time TEXT NOT NULL DEFAULT '10:00'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Settings ADD COLUMN reminder_supplement_time2 TEXT NOT NULL DEFAULT '11:00'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Settings ADD COLUMN reminder_meals_enabled INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Settings ADD COLUMN reminder_breakfast TEXT NOT NULL DEFAULT '07:00'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Settings ADD COLUMN reminder_lunch TEXT NOT NULL DEFAULT '12:30'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Settings ADD COLUMN reminder_dinner TEXT NOT NULL DEFAULT '19:00'");
      } catch (_) {}
    }
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.close();

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'food_database.db');

    await deleteDatabase(path);
    _database = null;

    _database = await _initDatabase();
  }

  Future<int> saveGoals({
    required int dailyCalories,
    required int carbPercentage,
    required int proteinPercentage,
    required int fatPercentage,
    required int sugarPercentage,
  }) async {
    final db = await database;

    await db.delete('Goals');
    return await db.insert(
      'Goals',
      {
        'daily_calories': dailyCalories,
        'carb_percentage': carbPercentage,
        'protein_percentage': proteinPercentage,
        'fat_percentage': fatPercentage,
        'sugar_percentage': sugarPercentage,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> saveGoalsExtended({
    required int dailyCalories,
    required int carbPercentage,
    required int proteinPercentage,
    required int fatPercentage,
    required int sugarPercentage,
    required int autoCalorieModeIndex,
    required double customPercentPerMonth,
    required int useCustomStartCaloriesInt,
    required int userStartCalories,
    required int userAge,
    required double userActivityLevel,
    required String? lastMondayCheck,
  }) async {
    final db = await database;
    await db.delete('Goals');
    return await db.insert(
      'Goals',
      {
        'daily_calories': dailyCalories,
        'carb_percentage': carbPercentage,
        'protein_percentage': proteinPercentage,
        'fat_percentage': fatPercentage,
        'sugar_percentage': sugarPercentage,
        'auto_calorie_mode': autoCalorieModeIndex,
        'custom_percent_per_month': customPercentPerMonth,
        'use_custom_start_calories': useCustomStartCaloriesInt,
        'user_start_calories': userStartCalories,
        'user_age': userAge,
        'user_activity_level': userActivityLevel,
        'last_monday_check': lastMondayCheck,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('Goals');
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> insertConsumedFood(
      DateTime date, String mealName, int foodId, int quantity) async {
    final db = await database;
    return await db.insert(
      'ConsumedFoods',
      {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'meal_name': mealName,
        'food_id': foodId,
        'quantity': quantity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ConsumedFoodItem>> getConsumedFoods(DateTime date) async {
    final db = await database;
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final List<Map<String, dynamic>> result = await db.query(
      'ConsumedFoods',
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    List<ConsumedFoodItem> consumedFoods = [];
    for (var map in result) {
      final dummyFood = FoodItem(
        id: map['food_id'],
        name: '...',
        brand: '...',
        barcode: null,
        caloriesPer100g: 0,
        fatPer100g: 0.0,
        carbsPer100g: 0.0,
        sugarPer100g: 0.0,
        proteinPer100g: 0.0,
      );

      consumedFoods.add(
        ConsumedFoodItem(
          id: map['id'],
          food: dummyFood,
          quantity: map['quantity'],
          date: DateTime.parse(map['date']),
          mealName: map['meal_name'],
        ),
      );
    }

    return consumedFoods;
  }

  Future<void> updateConsumedFood(int id, int newQuantity,
      {String? newMealName}) async {
    final db = await database;

    Map<String, dynamic> values = {
      'quantity': newQuantity,
    };
    if (newMealName != null) {
      values['meal_name'] = newMealName;
    }

    await db.update(
      'ConsumedFoods',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteConsumedFood(int id) async {
    final db = await database;
    await db.delete(
      'ConsumedFoods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveDarkMode(bool isDarkMode) async {
    final db = await database;
    await db.update(
      'Settings',
      {'dark_mode': isDarkMode ? 1 : 0},
      where: 'id = 1',
    );
  }

  Future<bool> getDarkMode() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('Settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return result.first['dark_mode'] == 1;
    }
    return false;
  }

  Future<void> saveNotificationSettings({
    required bool reminderWeighEnabled,
    required String reminderWeighTime,
    required String reminderWeighTime2,
    required bool reminderSupplementEnabled,
    required String reminderSupplementTime,
    required String reminderSupplementTime2,
    required bool reminderMealsEnabled,
    required String reminderBreakfast,
    required String reminderLunch,
    required String reminderDinner,
  }) async {
    final db = await database;
    await db.update(
      'Settings',
      {
        'reminder_weigh_enabled': reminderWeighEnabled ? 1 : 0,
        'reminder_weigh_time': reminderWeighTime,
        'reminder_weigh_time2': reminderWeighTime2,
        'reminder_supplement_enabled': reminderSupplementEnabled ? 1 : 0,
        'reminder_supplement_time': reminderSupplementTime,
        'reminder_supplement_time2': reminderSupplementTime2,
        'reminder_meals_enabled': reminderMealsEnabled ? 1 : 0,
        'reminder_breakfast': reminderBreakfast,
        'reminder_lunch': reminderLunch,
        'reminder_dinner': reminderDinner,
      },
      where: 'id = 1',
    );
  }

  Future<Map<String, dynamic>?> getNotificationSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('Settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>> exportData() async {
    final db = await database;
    final consumedFoods = await db.query('ConsumedFoods');
    final goals = await db.query('Goals');
    final settings = await db.query('Settings');
    final weightEntries = await db.query('WeightEntries');

    final List<Map<String, dynamic>> foodItems = [];

    return {
      'food_items': foodItems,
      'consumed_foods': consumedFoods,
      'goals': goals,
      'settings': settings,
      'weight_entries': weightEntries,
    };
  }

  Future<void> mergeData(String jsonData) async {
    final db = await database;
    Map<String, dynamic> data = jsonDecode(jsonData);

    if (data['consumed_foods'] is List) {
      for (var c in data['consumed_foods']) {
        List<Map<String, dynamic>> existingConsumed = await db.query(
          'ConsumedFoods',
          where: 'date = ? AND meal_name = ? AND food_id = ?',
          whereArgs: [c['date'], c['meal_name'], c['food_id']],
        );
        if (existingConsumed.isEmpty) {
          await db.insert('ConsumedFoods', c,
              conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }

    if (data['goals'] is List && data['goals'].isNotEmpty) {
      final existingGoals = await db.query('Goals');
      if (existingGoals.isEmpty) {
        await db.delete('Goals');
        for (var g in data['goals']) {
          await db.insert('Goals', g, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }

    if (data['settings'] is List && data['settings'].isNotEmpty) {
      final existingSettings = await db.query('Settings');
      if (existingSettings.isEmpty) {
        await db.delete('Settings');
        for (var s in data['settings']) {
          await db.insert('Settings', s, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }

    if (data['weight_entries'] is List) {
      for (var w in data['weight_entries']) {
        List<Map<String, dynamic>> existingW = await db.query(
          'WeightEntries',
          where: 'date = ? AND weight = ?',
          whereArgs: [w['date'], w['weight']],
        );
        if (existingW.isEmpty) {
          await db.insert('WeightEntries', w,
              conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }
  }

  Future<int> insertWeightEntry(DateTime date, double weight) async {
    final db = await database;
    return await db.insert(
      'WeightEntries',
      {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'weight': weight,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getWeightEntries() async {
    final db = await database;
    return await db.query('WeightEntries', orderBy: 'date ASC');
  }
}
