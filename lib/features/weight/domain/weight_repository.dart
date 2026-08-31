import 'weight_models.dart';

abstract interface class WeightRepository {
  Future<List<WeightRecord>> list();

  Future<int> add({required DateTime day, required double kilograms});

  Future<void> update({
    required int id,
    required DateTime day,
    required double kilograms,
  });

  Future<void> delete(int id);
}
