import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../models/consumed_food_item.dart';
import '../../../models/food_item.dart';
import '../../../models/saved_meal.dart';
import '../domain/nutrition_repository.dart';

class DriftNutritionRepository implements NutritionRepository {
  DriftNutritionRepository({required AppDatabase database})
      : _database = database;

  final AppDatabase _database;
  static const _uuid = Uuid();

  @override
  Future<Map<String, List<ConsumedFoodItem>>> getDailyFoods(String date) async {
    final query = _database.select(_database.consumedFoods).join([
      innerJoin(
        _database.localFoods,
        _database.localFoods.id.equalsExp(_database.consumedFoods.foodId),
      ),
    ])..where(_database.consumedFoods.date.equals(date));

    final rows = await query.get();

    final result = <String, List<ConsumedFoodItem>>{
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snacks': [],
    };

    for (final row in rows) {
      final consumedRow = row.readTable(_database.consumedFoods);
      final foodRow = row.readTable(_database.localFoods);

      final food = _mapFood(foodRow);
      final item = ConsumedFoodItem(
        id: consumedRow.id,
        food: food,
        quantity: consumedRow.quantity,
        date: DateTime.parse(consumedRow.date),
        mealName: consumedRow.mealName,
      );

      final mealKey = consumedRow.mealName.toLowerCase();
      if (result.containsKey(mealKey)) {
        result[mealKey]!.add(item);
      } else {
        result['snacks']!.add(item);
      }
    }

    return result;
  }

  @override
  Future<int> addConsumedFood({
    required String date,
    required String mealName,
    required int foodId,
    required int quantity,
  }) async {
    return await _database.into(_database.consumedFoods).insert(
          ConsumedFoodsCompanion.insert(
            date: date,
            mealName: mealName,
            foodId: foodId,
            quantity: quantity,
            uuid: Value(_uuid.v4()),
          ),
        );
  }

  @override
  Future<void> updateConsumedFoodQuantity({
    required int id,
    required int quantity,
  }) async {
    await (_database.update(_database.consumedFoods)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      ConsumedFoodsCompanion(
        quantity: Value(quantity),
      ),
    );
  }

  @override
  Future<void> deleteConsumedFood(int id) async {
    await (_database.delete(_database.consumedFoods)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  @override
  Future<void> clearDay(String date) async {
    await (_database.delete(_database.consumedFoods)
          ..where((tbl) => tbl.date.equals(date)))
        .go();
  }

  @override
  Future<void> copyMeal({
    required String fromDate,
    required String toDate,
    required String mealName,
  }) async {
    final items = await (_database.select(_database.consumedFoods)
          ..where((tbl) =>
              tbl.date.equals(fromDate) & tbl.mealName.equals(mealName)))
        .get();

    for (final item in items) {
      await addConsumedFood(
        date: toDate,
        mealName: mealName,
        foodId: item.foodId,
        quantity: item.quantity,
      );
    }
  }

  @override
  Future<List<FoodItem>> searchFoods(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final rows = await (_database.select(_database.localFoods)
          ..where((tbl) =>
              tbl.name.contains(trimmed) |
              tbl.brand.contains(trimmed) |
              tbl.barcode.equals(trimmed.toLowerCase()))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.name, mode: OrderingMode.asc)
          ])
          ..limit(50))
        .get();

    return rows.map(_mapFood).toList();
  }

  @override
  Future<FoodItem?> getFoodByBarcode(String barcode) async {
    final row = await (_database.select(_database.localFoods)
          ..where((tbl) => tbl.barcode.equals(barcode.toLowerCase()))
          ..limit(1))
        .getSingleOrNull();

    return row != null ? _mapFood(row) : null;
  }

  @override
  Future<FoodItem?> getFoodById(int id) async {
    final row = await (_database.select(_database.localFoods)
          ..where((tbl) => tbl.id.equals(id))
          ..limit(1))
        .getSingleOrNull();

    return row != null ? _mapFood(row) : null;
  }

  @override
  Future<FoodItem> saveFood(FoodItem food) async {
    final id = await _database.into(_database.localFoods).insert(
          LocalFoodsCompanion.insert(
            name: food.name,
            brand: food.brand,
            barcode: Value(food.barcode?.toLowerCase()),
            caloriesPer100g: food.caloriesPer100g,
            fatPer100g: food.fatPer100g,
            carbsPer100g: food.carbsPer100g,
            sugarPer100g: food.sugarPer100g,
            proteinPer100g: food.proteinPer100g,
            createdAt: food.createdAt.toIso8601String(),
            lastUsedQuantity: Value(food.lastUsedQuantity),
            source: Value(food.source),
            isVerified: Value(food.isVerified ? 1 : 0),
            uuid: Value(_uuid.v4()),
          ),
        );
    return food.copyWith(id: id);
  }

  @override
  Future<void> updateFood(FoodItem food) async {
    if (food.id == null) return;
    await (_database.update(_database.localFoods)
          ..where((tbl) => tbl.id.equals(food.id!)))
        .write(
      LocalFoodsCompanion(
        name: Value(food.name),
        brand: Value(food.brand),
        barcode: Value(food.barcode?.toLowerCase()),
        caloriesPer100g: Value(food.caloriesPer100g),
        fatPer100g: Value(food.fatPer100g),
        carbsPer100g: Value(food.carbsPer100g),
        sugarPer100g: Value(food.sugarPer100g),
        proteinPer100g: Value(food.proteinPer100g),
        lastUsedQuantity: Value(food.lastUsedQuantity),
        source: Value(food.source),
        isVerified: Value(food.isVerified ? 1 : 0),
      ),
    );
  }

  @override
  Future<void> deleteFood(int id) async {
    await (_database.delete(_database.localFoods)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
    await (_database.delete(_database.favoriteFoods)
          ..where((tbl) => tbl.foodId.equals(id)))
        .go();
    await (_database.delete(_database.foodUsage)
          ..where((tbl) => tbl.foodId.equals(id)))
        .go();
  }

  @override
  Future<List<FoodItem>> getFavoriteFoods() async {
    final query = _database.select(_database.favoriteFoods).join([
      innerJoin(
        _database.localFoods,
        _database.localFoods.id.equalsExp(_database.favoriteFoods.foodId),
      ),
    ])..orderBy([
        OrderingTerm(
          expression: _database.favoriteFoods.createdAt,
          mode: OrderingMode.desc,
        )
      ]);

    final rows = await query.get();
    return rows
        .map((row) => _mapFood(row.readTable(_database.localFoods)))
        .toList();
  }

  @override
  Future<bool> isFavorite(int foodId) async {
    final row = await (_database.select(_database.favoriteFoods)
          ..where((tbl) => tbl.foodId.equals(foodId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  @override
  Future<bool> toggleFavorite(int foodId) async {
    final exists = await isFavorite(foodId);
    if (exists) {
      await (_database.delete(_database.favoriteFoods)
            ..where((tbl) => tbl.foodId.equals(foodId)))
          .go();
      return false;
    } else {
      await _database.into(_database.favoriteFoods).insert(
            FavoriteFoodsCompanion.insert(
              foodId: Value(foodId),
              createdAt: DateTime.now().toIso8601String(),
            ),
          );
      return true;
    }
  }

  @override
  Future<List<FoodItem>> getFrequentFoods({int limit = 20}) async {
    final query = _database.select(_database.foodUsage).join([
      innerJoin(
        _database.localFoods,
        _database.localFoods.id.equalsExp(_database.foodUsage.foodId),
      ),
    ])
      ..orderBy([
        OrderingTerm(
          expression: _database.foodUsage.useCount,
          mode: OrderingMode.desc,
        ),
        OrderingTerm(
          expression: _database.foodUsage.lastUsedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows
        .map((row) => _mapFood(row.readTable(_database.localFoods)))
        .toList();
  }

  @override
  Future<void> recordFoodUsage(int foodId, int quantity) async {
    final existing = await (_database.select(_database.foodUsage)
          ..where((tbl) => tbl.foodId.equals(foodId))
          ..limit(1))
        .getSingleOrNull();

    final now = DateTime.now().toIso8601String();
    if (existing != null) {
      await (_database.update(_database.foodUsage)
            ..where((tbl) => tbl.foodId.equals(foodId)))
          .write(
        FoodUsageCompanion(
          lastUsedQuantity: Value(quantity),
          lastUsedAt: Value(now),
          useCount: Value(existing.useCount + 1),
        ),
      );
    } else {
      await _database.into(_database.foodUsage).insert(
            FoodUsageCompanion.insert(
              foodId: Value(foodId),
              lastUsedQuantity: quantity,
              lastUsedAt: now,
              useCount: const Value(1),
            ),
          );
    }
  }

  @override
  Future<List<SavedMeal>> getSavedMeals() async {
    final mealRows = await _database.select(_database.savedMeals).get();
    final result = <SavedMeal>[];

    for (final mealRow in mealRows) {
      final ingredientQuery =
          _database.select(_database.savedMealIngredients).join([
        innerJoin(
          _database.localFoods,
          _database.localFoods.id
              .equalsExp(_database.savedMealIngredients.foodId),
        ),
      ])..where(_database.savedMealIngredients.savedMealId.equals(mealRow.id));

      final ingredientRows = await ingredientQuery.get();
      final ingredients = ingredientRows.map((row) {
        final ingRow = row.readTable(_database.savedMealIngredients);
        final foodRow = row.readTable(_database.localFoods);
        return SavedMealIngredient(
          id: ingRow.id,
          savedMealId: ingRow.savedMealId,
          food: _mapFood(foodRow),
          quantity: ingRow.quantity,
        );
      }).toList();

      result.add(
        SavedMeal(
          id: mealRow.id,
          name: mealRow.name,
          defaultMealName: mealRow.defaultMealName,
          createdAt: DateTime.parse(mealRow.createdAt),
          ingredients: ingredients,
          recipeTotalWeight: mealRow.recipeTotalWeight,
        ),
      );
    }

    return result;
  }

  @override
  Future<SavedMeal> saveMeal({
    required String name,
    required String defaultMealName,
    required List<Map<String, dynamic>> ingredients,
    int? recipeTotalWeight,
  }) async {
    return await _database.transaction(() async {
      final now = DateTime.now();
      final mealId = await _database.into(_database.savedMeals).insert(
            SavedMealsCompanion.insert(
              name: name,
              defaultMealName: defaultMealName,
              createdAt: now.toIso8601String(),
              recipeTotalWeight: Value(recipeTotalWeight),
              uuid: Value(_uuid.v4()),
            ),
          );

      final savedIngredients = <SavedMealIngredient>[];

      for (final ing in ingredients) {
        final foodId = ing['food_id'] as int;
        final quantity = ing['quantity'] as int;

        final food = await getFoodById(foodId);
        if (food == null) continue;

        final ingId =
            await _database.into(_database.savedMealIngredients).insert(
                  SavedMealIngredientsCompanion.insert(
                    savedMealId: mealId,
                    foodId: foodId,
                    quantity: quantity,
                  ),
                );

        savedIngredients.add(
          SavedMealIngredient(
            id: ingId,
            savedMealId: mealId,
            food: food,
            quantity: quantity,
          ),
        );
      }

      return SavedMeal(
        id: mealId,
        name: name,
        defaultMealName: defaultMealName,
        createdAt: now,
        ingredients: savedIngredients,
        recipeTotalWeight: recipeTotalWeight,
      );
    });
  }

  @override
  Future<void> deleteSavedMeal(int id) async {
    await (_database.delete(_database.savedMealIngredients)
          ..where((tbl) => tbl.savedMealId.equals(id)))
        .go();
    await (_database.delete(_database.savedMeals)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  @override
  Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    final rows = await _database.select(_database.offlineQueue).get();
    return rows
        .map((row) => {
              'id': row.id,
              'action_type': row.actionType,
              'payload': row.payload,
              'created_at': row.createdAt,
              'last_error': row.lastError,
            })
        .toList();
  }

  @override
  Future<int> addToOfflineQueue(String actionType, String payload) async {
    return await _database.into(_database.offlineQueue).insert(
          OfflineQueueCompanion.insert(
            actionType: actionType,
            payload: payload,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
  }

  @override
  Future<void> removeFromOfflineQueue(int id) async {
    await (_database.delete(_database.offlineQueue)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  @override
  Future<void> clearOfflineQueue() async {
    await _database.delete(_database.offlineQueue).go();
  }

  FoodItem _mapFood(LocalFoodRow row) {
    return FoodItem(
      id: row.id,
      name: row.name,
      brand: row.brand,
      barcode: row.barcode,
      caloriesPer100g: row.caloriesPer100g,
      fatPer100g: row.fatPer100g,
      carbsPer100g: row.carbsPer100g,
      sugarPer100g: row.sugarPer100g,
      proteinPer100g: row.proteinPer100g,
      createdAt: DateTime.tryParse(row.createdAt) ?? DateTime.now(),
      lastUsedQuantity: row.lastUsedQuantity,
      source: row.source,
      isVerified: row.isVerified == 1,
    );
  }
}
