import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/weight/data/drift_weight_repository.dart';

void main() {
  late AppDatabase database;
  late DriftWeightRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftWeightRepository(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test('persists, updates and deletes weight records', () async {
    final id = await repository.add(
      day: DateTime(2026, 8, 31),
      kilograms: 82.4,
    );
    var records = await repository.list();
    expect(records, hasLength(1));
    expect(records.single.id, id);
    expect(records.single.day, DateTime(2026, 8, 31));
    expect(records.single.kilograms, 82.4);

    await repository.update(
      id: id,
      day: DateTime(2026, 9, 1),
      kilograms: 81.9,
    );
    records = await repository.list();
    expect(records.single.day, DateTime(2026, 9, 1));
    expect(records.single.kilograms, 81.9);

    await repository.delete(id);
    expect(await repository.list(), isEmpty);
  });
}
