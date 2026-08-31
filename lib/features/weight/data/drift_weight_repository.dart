import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/weight_models.dart';
import '../domain/weight_repository.dart';

class DriftWeightRepository implements WeightRepository {
  DriftWeightRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;
  static const _uuid = Uuid();

  @override
  Future<List<WeightRecord>> list() async {
    final rows = await (_database.select(_database.weightEntries)
          ..orderBy([(row) => OrderingTerm(expression: row.date)]))
        .get();
    return [
      for (final row in rows)
        WeightRecord(
          id: row.id,
          day: DateTime.parse(row.date),
          kilograms: row.weight,
        ),
    ];
  }

  @override
  Future<int> add({required DateTime day, required double kilograms}) =>
      _database.into(_database.weightEntries).insert(
            WeightEntriesCompanion.insert(
              date: _formatDay(day),
              weight: kilograms,
              uuid: Value(_uuid.v4()),
            ),
          );

  @override
  Future<void> update({
    required int id,
    required DateTime day,
    required double kilograms,
  }) async {
    await (_database.update(_database.weightEntries)
          ..where((row) => row.id.equals(id)))
        .write(
      WeightEntriesCompanion(
        date: Value(_formatDay(day)),
        weight: Value(kilograms),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_database.delete(_database.weightEntries)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  String _formatDay(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
