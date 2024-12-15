// lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:convert';

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
        version: 12,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw Exception("Fehler beim Initialisieren der Datenbank: $e");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE FoodItems(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          brand TEXT NOT NULL,
          barcode TEXT UNIQUE,
          calories_per_100g INTEGER NOT NULL,
          fat_per_100g REAL NOT NULL,
          carbs_per_100g REAL NOT NULL,
          sugar_per_100g REAL NOT NULL,
          protein_per_100g REAL NOT NULL,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          last_used_quantity INTEGER DEFAULT 100
        )
      ''');

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

      await db.execute('''
        CREATE UNIQUE INDEX IF NOT EXISTS idx_fooditems_name
        ON FoodItems(LOWER(name))
      ''');

      await db.execute('''
        CREATE TABLE ConsumedFoods(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          meal_name TEXT NOT NULL,
          food_id INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          FOREIGN KEY (food_id) REFERENCES FoodItems(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE Settings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dark_mode INTEGER NOT NULL DEFAULT 0
        )
      ''');

      List<Map<String, dynamic>> settings = await db.query('Settings');
      if (settings.isEmpty) {
        await db.insert('Settings', {'dark_mode': 0});
      }

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
      throw Exception("Fehler beim Erstellen der Datenbank: $e");
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Hier könnten zukünftige Upgrades stattfinden
  }

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

  Future<List<FoodItem>> getAllFoodItems() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'FoodItems',
        orderBy: 'datetime(created_at) DESC',
      );
      return result.map((item) => FoodItem.fromMap(item)).toList();
    } catch (e) {
      throw Exception("Fehler beim Abrufen der FoodItems: $e");
    }
  }

  Future<List<FoodItem>> getLastAddedFoodItems(int limit) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'FoodItems',
        orderBy: 'datetime(created_at) DESC',
        limit: limit,
      );
      return result.map((item) => FoodItem.fromMap(item)).toList();
    } catch (e) {
      throw Exception("Fehler beim Abrufen der letzten hinzugefügten FoodItems: $e");
    }
  }

  Future<int> insertOrUpdateFoodItem(FoodItem foodItem) async {
    try {
      final db = await database;
      return await db.insert(
        'FoodItems',
        foodItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Fehler beim Hinzufügen/Aktualisieren eines Lebensmittels: $e");
    }
  }

  Future<int> insertFoodItem(FoodItem foodItem) async {
    try {
      final db = await database;
      return await db.insert(
        'FoodItems',
        foodItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      throw Exception("Fehler beim Hinzufügen eines Lebensmittels: $e");
    }
  }

  Future<int> updateFoodItem(FoodItem foodItem) async {
    try {
      final db = await database;
      if (foodItem.barcode != null && foodItem.barcode!.isNotEmpty) {
        List<Map<String, dynamic>> existing = await db.query(
          'FoodItems',
          where: 'LOWER(barcode) = ? AND id != ?',
          whereArgs: [foodItem.barcode!.toLowerCase(), foodItem.id],
        );

        if (existing.isNotEmpty) {
          // Barcode existiert bereits bei einem anderen Item, entferne dort den Barcode
          FoodItem existingFood = FoodItem.fromMap(existing.first);
          FoodItem updatedExistingFood = existingFood.copyWith(barcode: null);
          await updateFoodItem(updatedExistingFood);
        }
      }

      return await db.update(
        'FoodItems',
        foodItem.toMap(),
        where: 'id = ?',
        whereArgs: [foodItem.id],
      );
    } catch (e) {
      throw Exception("Fehler beim Aktualisieren eines Lebensmittels: $e");
    }
  }

  Future<void> deleteFoodItem(int id) async {
    try {
      final db = await database;
      await db.delete(
        'FoodItems',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Fehler beim Löschen eines Lebensmittels: $e");
    }
  }

  Future<List<FoodItem>> searchFoodItems(String query) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'FoodItems',
        where: 'LOWER(name) LIKE ? OR LOWER(barcode) LIKE ?',
        whereArgs: ['%${query.toLowerCase()}%', '%${query.toLowerCase()}%'],
        orderBy: 'datetime(created_at) DESC',
      );
      return result.map((map) => FoodItem.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Fehler bei der Suche nach FoodItems: $e");
    }
  }

  Future<FoodItem?> getFoodItemByName(String name) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'FoodItems',
        where: 'LOWER(name) = ?',
        whereArgs: [name.toLowerCase()],
      );
      if (result.isNotEmpty) {
        return FoodItem.fromMap(result.first);
      }
      return null;
    } catch (e) {
      throw Exception("Fehler beim Abrufen eines spezifischen FoodItems: $e");
    }
  }

  Future<FoodItem?> getFoodItemByBarcode(String barcode) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'FoodItems',
        where: 'LOWER(barcode) = ?',
        whereArgs: [barcode.toLowerCase()],
      );
      if (result.isNotEmpty) {
        return FoodItem.fromMap(result.first);
      }
      return null;
    } catch (e) {
      throw Exception("Fehler beim Abrufen des FoodItems durch Barcode: $e");
    }
  }

  Future<FoodItem?> getFoodItemById(int id) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'FoodItems',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return FoodItem.fromMap(result.first);
      }
      return null;
    } catch (e) {
      throw Exception("Fehler beim Abrufen des FoodItems durch ID: $e");
    }
  }

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
      FoodItem? food = await getFoodItemById(map['food_id']);
      if (food != null) {
        consumedFoods.add(
          ConsumedFoodItem(
            id: map['id'],
            food: food,
            quantity: map['quantity'],
            date: DateTime.parse(map['date']),
            mealName: map['meal_name'],
          ),
        );
      }
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
    final List<Map<String, dynamic>> result = await db.query('Settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return result.first['dark_mode'] == 1;
    }
    return false;
  }

  Future<Map<String, dynamic>> exportData() async {
    final db = await database;

    final foodItems = await db.query('FoodItems');
    final consumedFoods = await db.query('ConsumedFoods');
    final goals = await db.query('Goals');
    final settings = await db.query('Settings');

    return {
      'food_items': foodItems,
      'consumed_foods': consumedFoods,
      'goals': goals,
      'settings': settings,
    };
  }

  // Neue Merge-Funktion: bestehende Daten bleiben unangetastet, neue werden ergänzt
  Future<void> mergeData(String jsonData) async {
    final db = await database;
    Map<String, dynamic> data = jsonDecode(jsonData);

    // Merge FoodItems:
    if (data['food_items'] is List) {
      for (var f in data['food_items']) {
        // Prüfe, ob bereits ein FoodItem mit gleichem Namen und Marke existiert
        List<Map<String, dynamic>> existing = await db.query(
          'FoodItems',
          where: 'LOWER(name) = ? AND LOWER(brand) = ?',
          whereArgs: [f['name'].toString().toLowerCase(), f['brand'].toString().toLowerCase()],
        );
        if (existing.isEmpty) {
          // Einfügen, falls nicht vorhanden
          await db.insert('FoodItems', f, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }

    // Merge ConsumedFoods:
    if (data['consumed_foods'] is List) {
      for (var c in data['consumed_foods']) {
        // Prüfe, ob diese Kombination bereits existiert: Gleicher Tag, gleiche Mahlzeit, gleicher food_id
        List<Map<String, dynamic>> existingConsumed = await db.query(
          'ConsumedFoods',
          where: 'date = ? AND meal_name = ? AND food_id = ?',
          whereArgs: [c['date'], c['meal_name'], c['food_id']],
        );
        if (existingConsumed.isEmpty) {
          // Einfügen, falls nicht vorhanden
          await db.insert('ConsumedFoods', c, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }

    // Merge Goals:
    // Falls bereits Goals existieren, nichts tun. Nur wenn noch keine Goals da sind, übernehmen.
    final existingGoals = await db.query('Goals');
    if (existingGoals.isEmpty && data['goals'] is List && data['goals'].isNotEmpty) {
      await db.delete('Goals');
      for (var g in data['goals']) {
        // Einfügen
        await db.insert('Goals', g, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    // Merge Settings:
    // Falls bereits Settings existieren, nichts tun. Nur wenn noch keine Settings da sind, übernehmen.
    final existingSettings = await db.query('Settings');
    if (existingSettings.isEmpty && data['settings'] is List && data['settings'].isNotEmpty) {
      await db.delete('Settings');
      for (var s in data['settings']) {
        await db.insert('Settings', s, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
  }
}
