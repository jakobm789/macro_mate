import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';
import '../models/saved_meal.dart';
import 'package:uuid/uuid.dart';

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

  static const int _dbVersion = 27;
  static const Uuid _uuid = Uuid();
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
    await db.execute(
      'CREATE TABLE Goals(id INTEGER PRIMARY KEY AUTOINCREMENT, daily_calories INTEGER NOT NULL, carb_percentage INTEGER NOT NULL, protein_percentage INTEGER NOT NULL, fat_percentage INTEGER NOT NULL, sugar_percentage INTEGER NOT NULL, auto_calorie_mode INTEGER NOT NULL DEFAULT 0, custom_percent_per_month REAL NOT NULL DEFAULT 1.0, use_custom_start_calories INTEGER NOT NULL DEFAULT 0, user_start_calories INTEGER NOT NULL DEFAULT 2000, user_age INTEGER NOT NULL DEFAULT 30, user_activity_level REAL NOT NULL DEFAULT 1.3, last_monday_check TEXT, first_week_initialized INTEGER NOT NULL DEFAULT 0, user_height REAL NOT NULL DEFAULT 170, use_protein_per_kg INTEGER NOT NULL DEFAULT 0, protein_per_kg REAL NOT NULL DEFAULT 2.0, target_weight REAL, target_date TEXT, target_weekly_change REAL)',
    );
    await db.execute(
      'CREATE TABLE ConsumedFoods(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, meal_name TEXT NOT NULL, food_id INTEGER NOT NULL, quantity INTEGER NOT NULL)',
    );
    await _createSavedMealTables(db);
    await _createLocalFoodsTable(db);
    await _createFavoriteTables(db);
    await _createFoodUsageTable(db);
    await _createOfflineQueueTable(db);
    await db.execute(
      'CREATE TABLE Settings(id INTEGER PRIMARY KEY AUTOINCREMENT, dark_mode INTEGER NOT NULL DEFAULT 0, reminder_weigh_enabled INTEGER NOT NULL DEFAULT 0, reminder_weigh_time TEXT NOT NULL DEFAULT \'08:00\', reminder_weigh_time2 TEXT NOT NULL DEFAULT \'09:00\', reminder_supplement_enabled INTEGER NOT NULL DEFAULT 0, reminder_supplement_time TEXT NOT NULL DEFAULT \'10:00\', reminder_supplement_time2 TEXT NOT NULL DEFAULT \'11:00\', reminder_meals_enabled INTEGER NOT NULL DEFAULT 0, reminder_breakfast TEXT NOT NULL DEFAULT \'07:00\', reminder_lunch TEXT NOT NULL DEFAULT \'12:30\', reminder_dinner TEXT NOT NULL DEFAULT \'19:00\')',
    );
    await db.execute(
      'CREATE TABLE WeightEntries(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, weight REAL NOT NULL)',
    );
    await _migrateToV26(db);
    await _createV27Tables(db);
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
        'reminder_dinner': '19:00',
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
        'first_week_initialized': 0,
        'user_height': 170,
        'use_protein_per_kg': 0,
        'protein_per_kg': 2.0,
        'target_weight': null,
        'target_date': null,
        'target_weekly_change': null,
      });
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 19) {
      try {
        await db.execute(
          "ALTER TABLE Goals ADD COLUMN user_height REAL NOT NULL DEFAULT 170",
        );
      } catch (_) {}
    }
    if (oldVersion < 20) {
      await _createSavedMealTables(db);
    }
    if (oldVersion < 21) {
      await _createFavoriteTables(db);
      await _createOfflineQueueTable(db);
      try {
        await db.execute(
          "ALTER TABLE SavedMeals ADD COLUMN recipe_total_weight INTEGER",
        );
      } catch (_) {}
    }
    if (oldVersion < 22) {
      try {
        await db.execute(
          "ALTER TABLE Goals ADD COLUMN use_protein_per_kg INTEGER NOT NULL DEFAULT 0",
        );
      } catch (_) {}
      try {
        await db.execute(
          "ALTER TABLE Goals ADD COLUMN protein_per_kg REAL NOT NULL DEFAULT 2.0",
        );
      } catch (_) {}
    }
    if (oldVersion < 23) {
      try {
        await db.execute("ALTER TABLE Goals ADD COLUMN target_weight REAL");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE Goals ADD COLUMN target_date TEXT");
      } catch (_) {}
      try {
        await db.execute(
          "ALTER TABLE Goals ADD COLUMN target_weekly_change REAL",
        );
      } catch (_) {}
    }
    if (oldVersion < 24) {
      await _createFoodUsageTable(db);
    }
    if (oldVersion < 25) {
      await _createLocalFoodsTable(db);
    }
    if (oldVersion < 26) {
      await _migrateToV26(db);
    }
    if (oldVersion < 27) {
      await _createV27Tables(db);
    }
  }

  Future<void> _createV27Tables(Database db) async {
    final statements = <String>[
      'CREATE TABLE IF NOT EXISTS health_sources(id TEXT PRIMARY KEY, source_name TEXT NOT NULL, source_device_id TEXT, platform TEXT NOT NULL, priority INTEGER NOT NULL DEFAULT 0, enabled INTEGER NOT NULL DEFAULT 1, discovered_at_utc TEXT NOT NULL)',
      'CREATE TABLE IF NOT EXISTS health_sync_states(source_id TEXT PRIMARY KEY, cursor_utc TEXT, last_success_utc TEXT, last_error TEXT, status TEXT NOT NULL DEFAULT "never")',
      'CREATE TABLE IF NOT EXISTS health_records(id TEXT PRIMARY KEY, type TEXT NOT NULL, source_id TEXT NOT NULL, start_utc TEXT NOT NULL, end_utc TEXT NOT NULL, value REAL NOT NULL, unit TEXT NOT NULL, local_day TEXT NOT NULL, payload_json TEXT)',
      'CREATE TABLE IF NOT EXISTS daily_health_aggregates(day TEXT PRIMARY KEY, steps INTEGER NOT NULL DEFAULT 0, active_kcal REAL NOT NULL DEFAULT 0, total_kcal REAL, distance_m REAL NOT NULL DEFAULT 0, heart_rate_avg REAL, resting_hr REAL, sleep_minutes REAL, source_ids TEXT NOT NULL DEFAULT "[]", updated_at_utc TEXT NOT NULL)',
      'CREATE TABLE IF NOT EXISTS sleep_sessions(id TEXT PRIMARY KEY, start_utc TEXT NOT NULL, end_utc TEXT NOT NULL, duration_minutes INTEGER NOT NULL, source_id TEXT NOT NULL, stages_json TEXT)',
      'CREATE TABLE IF NOT EXISTS workout_sessions(id TEXT PRIMARY KEY, type TEXT NOT NULL, start_utc TEXT NOT NULL, end_utc TEXT NOT NULL, duration_seconds REAL NOT NULL, distance_m REAL, energy_kcal REAL, source_id TEXT NOT NULL, route_status TEXT NOT NULL DEFAULT "unavailable")',
      'CREATE TABLE IF NOT EXISTS workout_route_points(workout_id TEXT NOT NULL, sequence INTEGER NOT NULL, latitude REAL NOT NULL, longitude REAL NOT NULL, timestamp_utc TEXT NOT NULL, PRIMARY KEY(workout_id, sequence))',
      'CREATE TABLE IF NOT EXISTS cycle_profiles(id INTEGER PRIMARY KEY, typical_cycle_length INTEGER NOT NULL DEFAULT 28, typical_period_length INTEGER NOT NULL DEFAULT 5, predictions_enabled INTEGER NOT NULL DEFAULT 1, health_import_enabled INTEGER NOT NULL DEFAULT 0, timezone TEXT NOT NULL DEFAULT "UTC")',
      'CREATE TABLE IF NOT EXISTS period_entries(id TEXT PRIMARY KEY, start_day TEXT NOT NULL, end_day TEXT, flow_json TEXT, source TEXT NOT NULL DEFAULT "local", created_at_utc TEXT NOT NULL)',
      'CREATE TABLE IF NOT EXISTS cycle_daily_logs(day TEXT PRIMARY KEY, bleeding TEXT, mood TEXT, pain INTEGER, energy INTEGER, sleep_quality INTEGER, notes TEXT, tags_json TEXT NOT NULL DEFAULT "[]", source TEXT NOT NULL DEFAULT "local", updated_at_utc TEXT NOT NULL)',
      'CREATE TABLE IF NOT EXISTS symptom_definitions(id TEXT PRIMARY KEY, name TEXT NOT NULL, enabled INTEGER NOT NULL DEFAULT 1)',
      'CREATE TABLE IF NOT EXISTS symptom_logs(id TEXT PRIMARY KEY, day TEXT NOT NULL, symptom_id TEXT NOT NULL, intensity INTEGER NOT NULL DEFAULT 1)',
      'CREATE TABLE IF NOT EXISTS cycle_predictions(id TEXT PRIMARY KEY, kind TEXT NOT NULL, window_start TEXT NOT NULL, window_end TEXT NOT NULL, confidence REAL NOT NULL, rationale TEXT NOT NULL, calculated_at_utc TEXT NOT NULL)',
      'CREATE TABLE IF NOT EXISTS notification_preferences(id TEXT PRIMARY KEY, enabled INTEGER NOT NULL DEFAULT 0, lead_minutes INTEGER NOT NULL DEFAULT 0, quiet_start TEXT, quiet_end TEXT, weekdays_json TEXT NOT NULL DEFAULT "[1,2,3,4,5,6,7]", discrete_lock_screen INTEGER NOT NULL DEFAULT 1)',
      'CREATE TABLE IF NOT EXISTS backup_manifests(id TEXT PRIMARY KEY, schema_version INTEGER NOT NULL, app_version TEXT NOT NULL, created_at_utc TEXT NOT NULL, categories_json TEXT NOT NULL, record_count INTEGER NOT NULL)',
      'CREATE INDEX IF NOT EXISTS idx_health_records_local_day ON health_records(local_day, type)',
      'CREATE INDEX IF NOT EXISTS idx_health_records_source ON health_records(source_id, start_utc)',
      'CREATE INDEX IF NOT EXISTS idx_sleep_sessions_start ON sleep_sessions(start_utc)',
      'CREATE INDEX IF NOT EXISTS idx_workout_sessions_start ON workout_sessions(start_utc)',
      'CREATE INDEX IF NOT EXISTS idx_cycle_daily_logs_day ON cycle_daily_logs(day)',
      'CREATE INDEX IF NOT EXISTS idx_symptom_logs_day ON symptom_logs(day)',
    ];
    for (final statement in statements) {
      await db.execute(statement);
    }
  }

  Future<void> _migrateToV26(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS app_database_metadata('
      'id INTEGER PRIMARY KEY, schema_version INTEGER NOT NULL, '
      'created_at_utc TEXT NOT NULL, migrated_at_utc TEXT NOT NULL)',
    );

    for (final table in const [
      'ConsumedFoods',
      'SavedMeals',
      'LocalFoods',
      'WeightEntries',
    ]) {
      final columns = await db.rawQuery('PRAGMA table_info($table)');
      final hasUuid = columns.any((column) => column['name'] == 'uuid');
      if (!hasUuid) {
        await db.execute('ALTER TABLE $table ADD COLUMN uuid TEXT');
      }

      final rows = await db.query(table, columns: ['id', 'uuid']);
      for (final row in rows) {
        final existingUuid = row['uuid'] as String?;
        if (existingUuid != null && existingUuid.isNotEmpty) continue;
        final legacyId = row['id'];
        await db.update(
          table,
          {'uuid': _legacyUuid(table, legacyId)},
          where: 'id = ?',
          whereArgs: [legacyId],
        );
      }
    }

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_consumed_foods_date_meal '
      'ON ConsumedFoods(date, meal_name)',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_consumed_foods_uuid '
      'ON ConsumedFoods(uuid) WHERE uuid IS NOT NULL',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_saved_meals_uuid '
      'ON SavedMeals(uuid) WHERE uuid IS NOT NULL',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_local_foods_uuid '
      'ON LocalFoods(uuid) WHERE uuid IS NOT NULL',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_food_usage_last_used '
      'ON FoodUsage(last_used_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_offline_queue_created '
      'ON OfflineQueue(created_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_weight_entries_date '
      'ON WeightEntries(date)',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_weight_entries_uuid '
      'ON WeightEntries(uuid) WHERE uuid IS NOT NULL',
    );

    final now = DateTime.now().toUtc().toIso8601String();
    await db.rawInsert(
      'INSERT INTO app_database_metadata '
      '(id, schema_version, created_at_utc, migrated_at_utc) '
      'VALUES (1, ?, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET '
      'schema_version = excluded.schema_version, '
      'migrated_at_utc = excluded.migrated_at_utc',
      [_dbVersion, now, now],
    );
  }

  static String _legacyUuid(String table, Object? id) {
    return _uuid.v5(Namespace.url.value, 'macromate://legacy/$table/$id');
  }

  static Map<String, dynamic> _withUuid(
    String table,
    Map<String, dynamic> values,
  ) {
    final result = Map<String, dynamic>.from(values);
    final current = result['uuid'];
    if (current is! String || current.isEmpty) {
      final legacyId = result['id'];
      result['uuid'] =
          legacyId == null ? _uuid.v4() : _legacyUuid(table, legacyId);
    }
    return result;
  }

  Future<void> _createSavedMealTables(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS SavedMeals(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, default_meal_name TEXT NOT NULL, created_at TEXT NOT NULL, recipe_total_weight INTEGER)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS SavedMealIngredients(id INTEGER PRIMARY KEY AUTOINCREMENT, saved_meal_id INTEGER NOT NULL, food_id INTEGER NOT NULL, quantity INTEGER NOT NULL, FOREIGN KEY(saved_meal_id) REFERENCES SavedMeals(id) ON DELETE CASCADE)',
    );
  }

  Future<void> _createFavoriteTables(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS FavoriteFoods(food_id INTEGER PRIMARY KEY, created_at TEXT NOT NULL)',
    );
  }

  Future<void> _createFoodUsageTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS FoodUsage(food_id INTEGER PRIMARY KEY, last_used_quantity INTEGER NOT NULL, last_used_at TEXT NOT NULL, use_count INTEGER NOT NULL DEFAULT 0)',
    );
  }

  Future<void> _createLocalFoodsTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS LocalFoods(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, brand TEXT NOT NULL, barcode TEXT, calories_per_100g INTEGER NOT NULL, fat_per_100g REAL NOT NULL, carbs_per_100g REAL NOT NULL, sugar_per_100g REAL NOT NULL, protein_per_100g REAL NOT NULL, created_at TEXT NOT NULL, last_used_quantity INTEGER NOT NULL DEFAULT 100, source TEXT NOT NULL DEFAULT "ai", is_verified INTEGER NOT NULL DEFAULT 0)',
    );
  }

  Future<void> _createOfflineQueueTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS OfflineQueue(id INTEGER PRIMARY KEY AUTOINCREMENT, action_type TEXT NOT NULL, payload TEXT NOT NULL, created_at TEXT NOT NULL, last_error TEXT)',
    );
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
    final existingRows = await db.query('Goals', limit: 1);
    final existing =
        existingRows.isNotEmpty ? existingRows.first : <String, dynamic>{};
    final values = {
      ...existing,
      'daily_calories': dailyCalories,
      'carb_percentage': carbPercentage,
      'protein_percentage': proteinPercentage,
      'fat_percentage': fatPercentage,
      'sugar_percentage': sugarPercentage,
    };
    if (existing['id'] != null) {
      await db.update(
        'Goals',
        values,
        where: 'id = ?',
        whereArgs: [existing['id']],
      );
      return existing['id'] as int;
    }
    return await db.insert(
      'Goals',
      values,
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
    required bool firstWeekInitializedVal,
    required double userHeightVal,
    int useProteinPerKgInt = 0,
    double proteinPerKg = 2.0,
    double? targetWeight,
    String? targetDate,
    double? targetWeeklyChange,
  }) async {
    final db = await database;
    final rows = await db.query('Goals');
    final existing = rows.isNotEmpty ? rows.first : <String, dynamic>{};
    final values = {
      ...existing,
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
      'first_week_initialized': firstWeekInitializedVal ? 1 : 0,
      'user_height': userHeightVal,
      'use_protein_per_kg': useProteinPerKgInt,
      'protein_per_kg': proteinPerKg,
      'target_weight': targetWeight,
      'target_date': targetDate,
      'target_weekly_change': targetWeeklyChange,
    };
    if (existing['id'] != null) {
      await db.update(
        'Goals',
        values,
        where: 'id = ?',
        whereArgs: [existing['id']],
      );
      return existing['id'] as int;
    }
    return await db.insert(
      'Goals',
      values,
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
    DateTime date,
    String mealName,
    int foodId,
    int quantity,
  ) async {
    final db = await database;
    return await db.insert(
        'ConsumedFoods',
        _withUuid('ConsumedFoods', {
          'date': DateFormat('yyyy-MM-dd').format(date),
          'meal_name': mealName,
          'food_id': foodId,
          'quantity': quantity,
        }),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ConsumedFoodItem>> getConsumedFoodsBetween(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final rows = await db.query(
      'ConsumedFoods',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        DateFormat('yyyy-MM-dd').format(start),
        DateFormat('yyyy-MM-dd').format(end),
      ],
      orderBy: 'date ASC, id ASC',
    );
    return rows
        .map(
          (map) => ConsumedFoodItem(
            id: map['id'] as int?,
            food: FoodItem(
              id: map['food_id'] as int?,
              name: '...',
              brand: '...',
              barcode: null,
              caloriesPer100g: 0,
              fatPer100g: 0.0,
              carbsPer100g: 0.0,
              sugarPer100g: 0.0,
              proteinPer100g: 0.0,
            ),
            quantity: map['quantity'] as int,
            date: DateTime.parse(map['date'] as String),
            mealName: map['meal_name'] as String,
          ),
        )
        .toList();
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

  Future<int> insertLocalFood(FoodItem food, int lastUsedQuantity) async {
    final db = await database;
    final id = await db.insert(
        'LocalFoods',
        _withUuid('LocalFoods', {
          'name': food.name,
          'brand': food.brand,
          'barcode': food.barcode,
          'calories_per_100g': food.caloriesPer100g,
          'fat_per_100g': food.fatPer100g,
          'carbs_per_100g': food.carbsPer100g,
          'sugar_per_100g': food.sugarPer100g,
          'protein_per_100g': food.proteinPer100g,
          'created_at': food.createdAt.toIso8601String(),
          'last_used_quantity': lastUsedQuantity,
          'source': food.source,
          'is_verified': food.isVerified ? 1 : 0,
        }));
    return -id;
  }

  Future<FoodItem?> getLocalFoodById(int localFoodId) async {
    final db = await database;
    final rows = await db.query(
      'LocalFoods',
      where: 'id = ?',
      whereArgs: [localFoodId.abs()],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return FoodItem.fromMap(rows.first).copyWith(id: -localFoodId.abs());
  }

  Future<void> updateConsumedFood(
    int id,
    int newQuantity, {
    String? newMealName,
  }) async {
    final db = await database;
    Map<String, dynamic> values = {'quantity': newQuantity};
    if (newMealName != null) {
      values['meal_name'] = newMealName;
    }
    await db.update('ConsumedFoods', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteConsumedFood(int id) async {
    final db = await database;
    await db.delete('ConsumedFoods', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> replaceConsumedFoodsForDate(
    DateTime date,
    List<ConsumedFoodItem> foods,
  ) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    await db.transaction((txn) async {
      await txn.delete(
        'ConsumedFoods',
        where: 'date = ?',
        whereArgs: [formattedDate],
      );
      for (final food in foods) {
        final foodId = food.food.id;
        if (foodId == null) continue;
        await txn.insert(
            'ConsumedFoods',
            _withUuid('ConsumedFoods', {
              'date': formattedDate,
              'meal_name': food.mealName,
              'food_id': foodId,
              'quantity': food.quantity,
            }));
      }
    });
  }

  Future<int> insertSavedMeal(
    String name,
    String defaultMealName,
    List<ConsumedFoodItem> ingredients,
    int? recipeTotalWeight,
  ) async {
    final db = await database;
    return await db.transaction((txn) async {
      final savedMealId = await txn.insert(
          'SavedMeals',
          _withUuid('SavedMeals', {
            'name': name,
            'default_meal_name': defaultMealName,
            'created_at': DateTime.now().toIso8601String(),
            'recipe_total_weight': recipeTotalWeight,
          }));
      for (final ingredient in ingredients) {
        final foodId = ingredient.food.id;
        if (foodId == null) {
          continue;
        }
        await txn.insert('SavedMealIngredients', {
          'saved_meal_id': savedMealId,
          'food_id': foodId,
          'quantity': ingredient.quantity,
        });
      }
      return savedMealId;
    });
  }

  Future<List<SavedMeal>> getSavedMeals(
    Future<FoodItem?> Function(int foodId) resolveFood,
  ) async {
    final db = await database;
    final mealRows = await db.query(
      'SavedMeals',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    final meals = <SavedMeal>[];
    for (final mealRow in mealRows) {
      final savedMealId = mealRow['id'] as int;
      final ingredientRows = await db.query(
        'SavedMealIngredients',
        where: 'saved_meal_id = ?',
        whereArgs: [savedMealId],
        orderBy: 'id ASC',
      );
      final ingredients = <SavedMealIngredient>[];
      for (final ingredientRow in ingredientRows) {
        final food = await resolveFood(ingredientRow['food_id'] as int);
        if (food == null) {
          continue;
        }
        ingredients.add(
          SavedMealIngredient(
            id: ingredientRow['id'] as int?,
            savedMealId: savedMealId,
            food: food,
            quantity: ingredientRow['quantity'] as int,
          ),
        );
      }
      meals.add(
        SavedMeal(
          id: savedMealId,
          name: mealRow['name'] as String,
          defaultMealName: mealRow['default_meal_name'] as String,
          createdAt: DateTime.parse(mealRow['created_at'] as String),
          ingredients: ingredients,
          recipeTotalWeight: mealRow['recipe_total_weight'] as int?,
        ),
      );
    }
    return meals;
  }

  Future<void> setFavoriteFood(int foodId, bool isFavorite) async {
    final db = await database;
    if (isFavorite) {
      await db.insert(
          'FavoriteFoods',
          {
            'food_id': foodId,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.delete(
        'FavoriteFoods',
        where: 'food_id = ?',
        whereArgs: [foodId],
      );
    }
  }

  Future<Set<int>> getFavoriteFoodIds() async {
    final db = await database;
    final rows = await db.query('FavoriteFoods', orderBy: 'created_at DESC');
    return rows.map((row) => row['food_id'] as int).toSet();
  }

  Future<void> upsertFoodUsage(int foodId, int quantity) async {
    final db = await database;
    final existing = await db.query(
      'FoodUsage',
      columns: ['use_count'],
      where: 'food_id = ?',
      whereArgs: [foodId],
      limit: 1,
    );
    final useCount =
        existing.isEmpty ? 1 : (existing.first['use_count'] as int? ?? 0) + 1;
    await db.insert(
        'FoodUsage',
        {
          'food_id': foodId,
          'last_used_quantity': quantity,
          'last_used_at': DateTime.now().toIso8601String(),
          'use_count': useCount,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<int, int>> getFoodUsageQuantities(Iterable<int> foodIds) async {
    final ids = foodIds.toSet().toList();
    if (ids.isEmpty) return {};
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.query(
      'FoodUsage',
      columns: ['food_id', 'last_used_quantity'],
      where: 'food_id IN ($placeholders)',
      whereArgs: ids,
    );
    return {
      for (final row in rows)
        row['food_id'] as int: row['last_used_quantity'] as int,
    };
  }

  Future<List<Map<String, dynamic>>> getRecentFoodUsage(int limit) async {
    final db = await database;
    return await db.query(
      'FoodUsage',
      orderBy: 'last_used_at DESC',
      limit: limit,
    );
  }

  Future<void> enqueueOfflineAction(
    String actionType,
    Map<String, dynamic> payload,
    String? error,
  ) async {
    final db = await database;
    await db.insert('OfflineQueue', {
      'action_type': actionType,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().toIso8601String(),
      'last_error': error,
    });
  }

  Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    final db = await database;
    return await db.query('OfflineQueue', orderBy: 'id ASC');
  }

  Future<void> deleteOfflineQueueEntry(int id) async {
    final db = await database;
    await db.delete('OfflineQueue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSavedMeal(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'SavedMealIngredients',
        where: 'saved_meal_id = ?',
        whereArgs: [id],
      );
      await txn.delete('SavedMeals', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> saveDarkMode(bool isDarkMode) async {
    final db = await database;
    await db.update(
        'Settings',
        {
          'dark_mode': isDarkMode ? 1 : 0,
        },
        where: 'id = 1');
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
        where: 'id = 1');
  }

  Future<Map<String, dynamic>?> getNotificationSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'Settings',
      where: 'id = ?',
      whereArgs: [1],
    );
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
    final savedMeals = await db.query('SavedMeals');
    final savedMealIngredients = await db.query('SavedMealIngredients');
    final favoriteFoods = await db.query('FavoriteFoods');
    final offlineQueue = await db.query('OfflineQueue');
    final localFoods = await db.query('LocalFoods');
    final healthSources = await db.query('health_sources');
    final healthSyncStates = await db.query('health_sync_states');
    final healthRecords = await db.query('health_records');
    final dailyHealthAggregates = await db.query('daily_health_aggregates');
    final sleepSessions = await db.query('sleep_sessions');
    final workoutSessions = await db.query('workout_sessions');
    final workoutRoutePoints = await db.query('workout_route_points');
    final cycleProfiles = await db.query('cycle_profiles');
    final periodEntries = await db.query('period_entries');
    final cycleDailyLogs = await db.query('cycle_daily_logs');
    final symptomDefinitions = await db.query('symptom_definitions');
    final symptomLogs = await db.query('symptom_logs');
    final cyclePredictions = await db.query('cycle_predictions');
    final notificationPreferences = await db.query('notification_preferences');
    final backupManifests = await db.query('backup_manifests');
    final List<Map<String, dynamic>> foodItems = [];
    return {
      'format': 'macromate-backup',
      'format_version': 2,
      'schema_version': _dbVersion,
      'app_version': '1.0.0',
      'created_at_utc': DateTime.now().toUtc().toIso8601String(),
      'categories': [
        'nutrition',
        'goals',
        'settings',
        'weight',
        'health',
        'cycle',
        'notifications',
      ],
      'food_items': foodItems,
      'local_foods': localFoods,
      'consumed_foods': consumedFoods,
      'goals': goals,
      'settings': settings,
      'weight_entries': weightEntries,
      'saved_meals': savedMeals,
      'saved_meal_ingredients': savedMealIngredients,
      'favorite_foods': favoriteFoods,
      'offline_queue': offlineQueue,
      'health_sources': healthSources,
      'health_sync_states': healthSyncStates,
      'health_records': healthRecords,
      'daily_health_aggregates': dailyHealthAggregates,
      'sleep_sessions': sleepSessions,
      'workout_sessions': workoutSessions,
      'workout_route_points': workoutRoutePoints,
      'cycle_profiles': cycleProfiles,
      'period_entries': periodEntries,
      'cycle_daily_logs': cycleDailyLogs,
      'symptom_definitions': symptomDefinitions,
      'symptom_logs': symptomLogs,
      'cycle_predictions': cyclePredictions,
      'notification_preferences': notificationPreferences,
      'backup_manifests': backupManifests,
    };
  }

  Future<void> mergeData(String jsonData) async {
    final database = await this.database;
    Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(jsonData));
    // Versioned backups keep the payload flat for backwards compatibility,
    // while accepting a future envelope with a nested payload as well.
    if (data['payload'] is Map) {
      data = Map<String, dynamic>.from(data['payload'] as Map);
    }
    await database.transaction((txn) => _mergeDataInto(txn, data));
  }

  Future<void> _mergeDataInto(
    DatabaseExecutor db,
    Map<String, dynamic> data,
  ) async {
    if (data['consumed_foods'] is List) {
      for (var c in data['consumed_foods']) {
        List<Map<String, dynamic>> existingConsumed = await db.query(
          'ConsumedFoods',
          where: 'date = ? AND meal_name = ? AND food_id = ?',
          whereArgs: [c['date'], c['meal_name'], c['food_id']],
        );
        if (existingConsumed.isEmpty) {
          await db.insert(
            'ConsumedFoods',
            _withUuid('ConsumedFoods', Map<String, dynamic>.from(c)),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }
    if (data['local_foods'] is List) {
      for (var food in data['local_foods']) {
        await db.insert(
          'LocalFoods',
          _withUuid('LocalFoods', Map<String, dynamic>.from(food)),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    if (data['goals'] is List && data['goals'].isNotEmpty) {
      final existingGoals = await db.query('Goals');
      if (existingGoals.isEmpty) {
        await db.delete('Goals');
        for (var g in data['goals']) {
          await db.insert(
            'Goals',
            g,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }
    if (data['settings'] is List && data['settings'].isNotEmpty) {
      final existingSettings = await db.query('Settings');
      if (existingSettings.isEmpty) {
        await db.delete('Settings');
        for (var s in data['settings']) {
          await db.insert(
            'Settings',
            s,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
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
          await db.insert(
            'WeightEntries',
            _withUuid('WeightEntries', Map<String, dynamic>.from(w)),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }
    if (data['saved_meals'] is List) {
      for (var meal in data['saved_meals']) {
        final existingMeal = await db.query(
          'SavedMeals',
          where: 'name = ?',
          whereArgs: [meal['name']],
        );
        if (existingMeal.isEmpty) {
          await db.insert(
            'SavedMeals',
            _withUuid('SavedMeals', Map<String, dynamic>.from(meal)),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }
    if (data['saved_meal_ingredients'] is List) {
      for (var ingredient in data['saved_meal_ingredients']) {
        final existingIngredient = await db.query(
          'SavedMealIngredients',
          where: 'saved_meal_id = ? AND food_id = ? AND quantity = ?',
          whereArgs: [
            ingredient['saved_meal_id'],
            ingredient['food_id'],
            ingredient['quantity'],
          ],
        );
        if (existingIngredient.isEmpty) {
          await db.insert(
            'SavedMealIngredients',
            ingredient,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }
    if (data['favorite_foods'] is List) {
      for (var favorite in data['favorite_foods']) {
        final foodId = favorite['food_id'];
        if (foodId == null) continue;
        await db.insert(
          'FavoriteFoods',
          favorite,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    if (data['offline_queue'] is List) {
      for (var entry in data['offline_queue']) {
        final existingEntry = await db.query(
          'OfflineQueue',
          where: 'action_type = ? AND payload = ? AND created_at = ?',
          whereArgs: [
            entry['action_type'],
            entry['payload'],
            entry['created_at'],
          ],
        );
        if (existingEntry.isEmpty) {
          await db.insert(
            'OfflineQueue',
            entry,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }
    const additionalTables = [
      'health_sources',
      'health_sync_states',
      'health_records',
      'daily_health_aggregates',
      'sleep_sessions',
      'workout_sessions',
      'workout_route_points',
      'cycle_profiles',
      'period_entries',
      'cycle_daily_logs',
      'symptom_definitions',
      'symptom_logs',
      'cycle_predictions',
      'notification_preferences',
      'backup_manifests',
    ];
    for (final table in additionalTables) {
      final rows = data[table];
      if (rows is! List) continue;
      for (final rawRow in rows) {
        if (rawRow is! Map) continue;
        await db.insert(
          table,
          Map<String, dynamic>.from(rawRow),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<int> insertWeightEntry(DateTime date, double weight) async {
    final db = await database;
    return await db.insert(
        'WeightEntries',
        _withUuid('WeightEntries', {
          'date': DateFormat('yyyy-MM-dd').format(date),
          'weight': weight,
        }),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateWeightEntry(int id, DateTime date, double weight) async {
    final db = await database;
    await db.update(
      'WeightEntries',
      {'date': DateFormat('yyyy-MM-dd').format(date), 'weight': weight},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getWeightEntries() async {
    final db = await database;
    return await db.query('WeightEntries', orderBy: 'date ASC');
  }

  Future<void> deleteWeightEntry(int id) async {
    final db = await database;
    await db.delete('WeightEntries', where: 'id = ?', whereArgs: [id]);
  }
}
