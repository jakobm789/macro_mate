import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';

void main() {
  test('v25 fixture migrates to v27 without losing legacy rows', () async {
    final fixture =
        File('test/fixtures/legacy_v25_schema.sql').readAsStringSync();
    final database = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (sqlite) {
          for (final statement in fixture.split(';')) {
            final sql = statement.trim();
            if (sql.isNotEmpty) sqlite.execute(sql);
          }
        },
      ),
    );
    addTearDown(database.close);

    final foods = await database.select(database.localFoods).get();
    final consumed = await database.select(database.consumedFoods).get();
    final weights = await database.select(database.weightEntries).get();
    final meals = await database.select(database.savedMeals).get();
    final metadata = await database.select(database.appDatabaseMetadata).get();

    expect(foods, hasLength(1));
    expect(foods.single.id, 42);
    expect(foods.single.uuid, isNotNull);
    expect(consumed.single.uuid, isNotNull);
    expect(weights.single.uuid, isNotNull);
    expect(meals.single.uuid, isNotNull);
    expect(metadata.single.schemaVersion, 27);

    final healthTables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE 'health_%'",
        )
        .get();
    expect(
      healthTables.map((row) => row.read<String>('name')),
      containsAll(['health_sources', 'health_records', 'health_sync_states']),
    );

    final indexes = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'",
        )
        .get();
    expect(indexes.map((row) => row.read<String>('name')),
        contains('idx_consumed_foods_date_meal'));
    expect(indexes.map((row) => row.read<String>('name')),
        contains('idx_weight_entries_date'));
  });
}
