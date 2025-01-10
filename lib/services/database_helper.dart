// lib/services/database_helper.dart

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

  Future<Database> _initDatabase() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'food_database.db');

      return await openDatabase(
        path,
        version: 15, // <-- Version hochgesetzt (von 14 auf 15)
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw Exception("Fehler beim Initialisieren der Datenbank: $e");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // Goals
      await db.execute('''
        CREATE TABLE Goals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          daily_calories INTEGER NOT NULL,
          carb_percentage INTEGER NOT NULL,
          protein_percentage INTEGER NOT NULL,
          fat_percentage INTEGER NOT NULL,
          sugar_percentage INTEGER NOT NULL
        )
      ''');

      // ConsumedFoods
      await db.execute('''
        CREATE TABLE ConsumedFoods(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          meal_name TEXT NOT NULL,
          food_id INTEGER NOT NULL, 
          quantity INTEGER NOT NULL
        )
      ''');

      // Settings
      await db.execute('''
        CREATE TABLE Settings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dark_mode INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // NEU: WeightEntries
      await db.execute('''
        CREATE TABLE WeightEntries(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          weight REAL NOT NULL
        )
      ''');

      // Default-Eintrag in Settings
      List<Map<String, dynamic>> settings = await db.query('Settings');
      if (settings.isEmpty) {
        await db.insert('Settings', {'dark_mode': 0});
      }

      // Default-Eintrag in Goals
      List<Map<String, dynamic>> goals = await db.query('Goals');
      if (goals.isEmpty) {
        await db.insert('Goals', {
          'daily_calories': 2000,
          'carb_percentage': 50,
          'protein_percentage': 30,
          'fat_percentage': 20,
          'sugar_percentage': 20,
        });
      }
    } catch (e) {
      throw Exception("Fehler beim Erstellen der lokalen DB: $e");
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Keine lokale Users-Tabelle mehr notwendig.
    // Falls du vorher 'Users' in local hattest, hier droppen:
    if (oldVersion < 14) {
      try {
        await db.execute('DROP TABLE IF EXISTS Users');
      } catch (_) {}
    }

    // Falls du erst jetzt auf Version 15 upgradest, legen wir WeightEntries an:
    if (oldVersion < 15) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS WeightEntries(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          weight REAL NOT NULL
        )
      ''');
    }
  }

  // -------------------------
  // Reset
  // -------------------------
  Future<void> resetDatabase() async {
    try {
      final db = await database;
      await db.close();

      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'food_database.db');

      await deleteDatabase(path);
      _database = null;

      _database = await _initDatabase();
    } catch (e) {
      throw Exception("Fehler beim Zurücksetzen der Datenbank: $e");
    }
  }

  // -------------------------
  // Goals
  // -------------------------
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

  Future<Map<String, dynamic>?> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('Goals');
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // -------------------------
  // ConsumedFoods
  // -------------------------
  Future<int> insertConsumedFood(DateTime date, String mealName, int foodId, int quantity) async {
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

  Future<void> updateConsumedFood(int id, int newQuantity, {String? newMealName}) async {
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

  // -------------------------
  // Settings
  // -------------------------
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
    final List<Map<String, dynamic>> result = await db.query(
      'Settings',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (result.isNotEmpty) {
      return result.first['dark_mode'] == 1;
    }
    return false;
  }

  // -------------------------
  // Export / Merge
  // -------------------------
  Future<Map<String, dynamic>> exportData() async {
    final db = await database;

    // FoodItems lokal nicht mehr vorhanden => leere Liste
    final List<Map<String, dynamic>> foodItems = [];
    final consumedFoods = await db.query('ConsumedFoods');
    final goals = await db.query('Goals');
    final settings = await db.query('Settings');

    // NEU: WeightEntries
    final weightEntries = await db.query('WeightEntries');

    return {
      'food_items': foodItems,
      'consumed_foods': consumedFoods,
      'goals': goals,
      'settings': settings,
      'weight_entries': weightEntries, // <-- NEU
    };
  }

  Future<void> mergeData(String jsonData) async {
    final db = await database;
    Map<String, dynamic> data = jsonDecode(jsonData);

    // consumed_foods
    if (data['consumed_foods'] is List) {
      for (var c in data['consumed_foods']) {
        List<Map<String, dynamic>> existingConsumed = await db.query(
          'ConsumedFoods',
          where: 'date = ? AND meal_name = ? AND food_id = ?',
          whereArgs: [c['date'], c['meal_name'], c['food_id']],
        );
        if (existingConsumed.isEmpty) {
          await db.insert('ConsumedFoods', c, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }

    // goals
    final existingGoals = await db.query('Goals');
    if (existingGoals.isEmpty && data['goals'] is List && data['goals'].isNotEmpty) {
      await db.delete('Goals');
      for (var g in data['goals']) {
        await db.insert('Goals', g, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    // settings
    final existingSettings = await db.query('Settings');
    if (existingSettings.isEmpty && data['settings'] is List && data['settings'].isNotEmpty) {
      await db.delete('Settings');
      for (var s in data['settings']) {
        await db.insert('Settings', s, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    // NEU: weight_entries
    if (data['weight_entries'] is List) {
      for (var w in data['weight_entries']) {
        List<Map<String, dynamic>> existingW = await db.query(
          'WeightEntries',
          where: 'date = ? AND weight = ?',
          whereArgs: [w['date'], w['weight']],
        );
        if (existingW.isEmpty) {
          await db.insert('WeightEntries', w, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }
  }

  // ------------------------------------------------
  // NEU: Funktionen für Gewichtseinträge
  // ------------------------------------------------
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
