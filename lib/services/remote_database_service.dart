import 'dart:async';
import 'dart:io';
import 'package:postgres/postgres.dart';
import '../models/food_item.dart';

class RemoteDatabaseService {
  final String _host = Platform.environment['DB_HOST'] ?? '';
  final int _port =
      int.tryParse(Platform.environment['DB_PORT'] ?? '') ?? 0;
  final String _database = Platform.environment['DB_NAME'] ?? '';
  final String _username = Platform.environment['DB_USER'] ?? '';
  final String _password = Platform.environment['DB_PASSWORD'] ?? '';

  late PostgreSQLConnection _connection = PostgreSQLConnection(
    _host,
    _port,
    _database,
    username: _username,
    password: _password,
    useSSL: true,
  );

  Future<void> _init() async {
    if (_connection.isClosed) {
      _connection = PostgreSQLConnection(
        _host,
        _port,
        _database,
        username: _username,
        password: _password,
        useSSL: true,
      );
      await _connection.open();
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    await _init();
    final results = await _connection.query('''
      SELECT id, email, password_hash, verification_code, is_verified
      FROM users
      WHERE LOWER(email) = LOWER(@em)
      LIMIT 1
    ''', substitutionValues: {
      'em': email,
    });

    if (results.isEmpty) {
      return null;
    }
    final row = results.first;
    return {
      'id': row[0],
      'email': row[1],
      'password_hash': row[2],
      'verification_code': row[3],
      'is_verified': row[4],
    };
  }

  Future<void> insertUserWithVerification(
      String email, String passwordHash, String verificationCode) async {
    await _init();
    final result = await _connection.query('''
      INSERT INTO users (email, password_hash, verification_code, is_verified)
      VALUES (@em, @pwHash, @vCode, false)
      RETURNING id
    ''', substitutionValues: {
      'em': email,
      'pwHash': passwordHash,
      'vCode': verificationCode,
    });

    if (result.isEmpty) {
      throw Exception(
          'Fehler beim INSERT in users (Kein Datensatz zurückgegeben).');
    }
  }

  Future<void> insertUser(String email, String passwordHash) async {
    await _init();
    final result = await _connection.query('''
      INSERT INTO users (email, password_hash)
      VALUES (@em, @pwHash)
      RETURNING id
    ''', substitutionValues: {
      'em': email,
      'pwHash': passwordHash,
    });

    if (result.isEmpty) {
      throw Exception('Fehler beim INSERT in users (Kein Datensatz zurückgegeben).');
    }
  }

  Future<void> verifyUser(String email) async {
    await _init();
    await _connection.query('''
      UPDATE users
      SET is_verified = true
      WHERE LOWER(email) = LOWER(@em)
    ''', substitutionValues: {
      'em': email,
    });
  }

  Future<void> deleteUserByEmail(String email) async {
    await _init();
    await _connection.query('''
      DELETE FROM users
      WHERE LOWER(email) = LOWER(@em)
    ''', substitutionValues: {
      'em': email,
    });
  }

  Map<String, dynamic> _rowToMap(List<dynamic> row) {
    final dynamic cals = row[4];
    int calsInt = 0;
    if (cals is int) {
      calsInt = cals;
    } else if (cals is String) {
      calsInt = int.tryParse(cals) ?? 0;
    }

    final dynamic fat = row[5];
    double fatDouble = 0.0;
    if (fat is double) {
      fatDouble = fat;
    } else if (fat is String) {
      fatDouble = double.tryParse(fat) ?? 0.0;
    }

    final dynamic carbs = row[6];
    double carbsDouble = 0.0;
    if (carbs is double) {
      carbsDouble = carbs;
    } else if (carbs is String) {
      carbsDouble = double.tryParse(carbs) ?? 0.0;
    }

    final dynamic sugar = row[7];
    double sugarDouble = 0.0;
    if (sugar is double) {
      sugarDouble = sugar;
    } else if (sugar is String) {
      sugarDouble = double.tryParse(sugar) ?? 0.0;
    }

    final dynamic protein = row[8];
    double proteinDouble = 0.0;
    if (protein is double) {
      proteinDouble = protein;
    } else if (protein is String) {
      proteinDouble = double.tryParse(protein) ?? 0.0;
    }

    final dynamic createdAtVal = row[9];
    String createdAtString =
        createdAtVal is DateTime ? createdAtVal.toIso8601String() : '';

    final dynamic lastUsed = row[10];
    int lastUsedInt = 100;
    if (lastUsed is int) {
      lastUsedInt = lastUsed;
    } else if (lastUsed is String) {
      lastUsedInt = int.tryParse(lastUsed) ?? 100;
    }

    return {
      'id': row[0],
      'name': row[1] ?? '',
      'brand': row[2] ?? '',
      'barcode': (row[3] as String?)?.toLowerCase(),
      'calories_per_100g': calsInt,
      'fat_per_100g': fatDouble,
      'carbs_per_100g': carbsDouble,
      'sugar_per_100g': sugarDouble,
      'protein_per_100g': proteinDouble,
      'created_at': createdAtString,
      'last_used_quantity': lastUsedInt,
    };
  }

  Future<FoodItem?> getFoodItemById(int foodId) async {
    await _init();
    final results = await _connection.query('''
      SELECT
        id,
        name,
        brand,
        barcode,
        calories_per_100g,
        fat_per_100g,
        carbs_per_100g,
        sugar_per_100g,
        protein_per_100g,
        created_at,
        last_used_quantity
      FROM fooditems
      WHERE id = @id
      LIMIT 1
    ''', substitutionValues: {
      'id': foodId,
    });
    if (results.isEmpty) {
      return null;
    }
    final row = results.first;
    return FoodItem.fromMap(_rowToMap(row));
  }

  Future<List<FoodItem>> getAllFoodItems() async {
    await _init();
    final results = await _connection.query('''
      SELECT 
        id,
        name,
        brand,
        barcode,
        calories_per_100g,
        fat_per_100g,
        carbs_per_100g,
        sugar_per_100g,
        protein_per_100g,
        created_at,
        last_used_quantity
      FROM fooditems
      ORDER BY created_at DESC
    ''');
    return results.map((row) => FoodItem.fromMap(_rowToMap(row))).toList();
  }

  Future<List<FoodItem>> getLastAddedFoodItems(int limit) async {
    await _init();
    final results = await _connection.query('''
      SELECT 
        id,
        name,
        brand,
        barcode,
        calories_per_100g,
        fat_per_100g,
        carbs_per_100g,
        sugar_per_100g,
        protein_per_100g,
        created_at,
        last_used_quantity
      FROM fooditems
      ORDER BY created_at DESC
      LIMIT @limit
    ''', substitutionValues: {
      'limit': limit,
    });
    return results.map((row) => FoodItem.fromMap(_rowToMap(row))).toList();
  }

  Future<List<FoodItem>> searchFoodItems(String query) async {
    await _init();
    final results = await _connection.query('''
      SELECT 
        id,
        name,
        brand,
        barcode,
        calories_per_100g,
        fat_per_100g,
        carbs_per_100g,
        sugar_per_100g,
        protein_per_100g,
        created_at,
        last_used_quantity
      FROM fooditems
      WHERE LOWER(name) LIKE @pattern
         OR LOWER(barcode) LIKE @pattern
      ORDER BY created_at DESC
    ''', substitutionValues: {
      'pattern': '%${query.toLowerCase()}%',
    });
    return results.map((row) => FoodItem.fromMap(_rowToMap(row))).toList();
  }

  Future<FoodItem?> getFoodItemByBarcode(String barcode) async {
    await _init();
    final results = await _connection.query('''
      SELECT
        id,
        name,
        brand,
        barcode,
        calories_per_100g,
        fat_per_100g,
        carbs_per_100g,
        sugar_per_100g,
        protein_per_100g,
        created_at,
        last_used_quantity
      FROM fooditems
      WHERE LOWER(barcode) = @bc
      LIMIT 1
    ''', substitutionValues: {
      'bc': barcode.toLowerCase(),
    });

    if (results.isEmpty) {
      return null;
    }
    final row = results.first;
    return FoodItem.fromMap(_rowToMap(row));
  }

  Future<int> insertOrUpdateFoodItem(FoodItem foodItem) async {
    await _init();

    if (foodItem.id == null) {
      final result = await _connection.query('''
        INSERT INTO fooditems (
          name,
          brand,
          barcode,
          calories_per_100g,
          fat_per_100g,
          carbs_per_100g,
          sugar_per_100g,
          protein_per_100g,
          created_at,
          last_used_quantity
        )
        VALUES (
          @name,
          @brand,
          @barcode,
          @calories,
          @fat,
          @carbs,
          @sugar,
          @protein,
          @createdAt,
          @lastUsed
        )
        RETURNING id
      ''', substitutionValues: {
        'name': foodItem.name,
        'brand': foodItem.brand,
        'barcode': foodItem.barcode,
        'calories': foodItem.caloriesPer100g,
        'fat': foodItem.fatPer100g,
        'carbs': foodItem.carbsPer100g,
        'sugar': foodItem.sugarPer100g,
        'protein': foodItem.proteinPer100g,
        'createdAt': foodItem.createdAt.toUtc(),
        'lastUsed': foodItem.lastUsedQuantity,
      });

      if (result.isEmpty) {
        throw Exception('Fehler beim INSERT in fooditems');
      }
      return result.first[0] as int;
    } else {
      await _init();
      await _connection.query('''
        UPDATE fooditems
        SET
          name = @name,
          brand = @brand,
          barcode = @barcode,
          calories_per_100g = @calories,
          fat_per_100g = @fat,
          carbs_per_100g = @carbs,
          sugar_per_100g = @sugar,
          protein_per_100g = @protein,
          last_used_quantity = @lastUsed
        WHERE id = @id
      ''', substitutionValues: {
        'id': foodItem.id,
        'name': foodItem.name,
        'brand': foodItem.brand,
        'barcode': foodItem.barcode,
        'calories': foodItem.caloriesPer100g,
        'fat': foodItem.fatPer100g,
        'carbs': foodItem.carbsPer100g,
        'sugar': foodItem.sugarPer100g,
        'protein': foodItem.proteinPer100g,
        'lastUsed': foodItem.lastUsedQuantity,
      });
      return foodItem.id!;
    }
  }

  Future<void> updateBarcode(int foodId, String? barcode) async {
    await _init();
    await _connection.query('''
      UPDATE fooditems
      SET barcode = @barcode
      WHERE id = @id
    ''', substitutionValues: {
      'id': foodId,
      'barcode': barcode ?? '',
    });
  }

  Future<void> deleteFoodItem(int id) async {
    await _init();
    await _connection.query('''
      DELETE FROM fooditems
      WHERE id = @id
    ''', substitutionValues: {
      'id': id,
    });
  }
}
