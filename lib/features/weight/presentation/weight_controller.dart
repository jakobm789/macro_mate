import 'package:flutter/foundation.dart';

import '../domain/weight_models.dart';
import '../domain/weight_repository.dart';

class WeightController extends ChangeNotifier {
  WeightController({required WeightRepository repository})
      : _repository = repository;

  final WeightRepository _repository;

  List<WeightRecord> _records = [];
  List<WeightRecord> get records => List.unmodifiable(_records);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  WeightRecord? get latestRecord => _records.isNotEmpty ? _records.last : null;
  double? get currentWeight => latestRecord?.kilograms;

  /// 7-day trend in kg (positive = gain, negative = loss)
  double? get sevenDayTrend {
    if (_records.length < 2) return null;
    final latest = _records.last;
    final sevenDaysAgo = latest.day.subtract(const Duration(days: 7));
    final priorRecords =
        _records.where((r) => r.day.isBefore(sevenDaysAgo) || r.day.isAtSameMomentAs(sevenDaysAgo)).toList();
    if (priorRecords.isEmpty) {
      return latest.kilograms - _records.first.kilograms;
    }
    return latest.kilograms - priorRecords.last.kilograms;
  }

  Future<void> initialize() async {
    await loadWeights();
  }

  Future<void> loadWeights() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _records = await _repository.list();
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Gewichtsdaten: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWeight(DateTime day, double kilograms) async {
    await _repository.add(day: day, kilograms: kilograms);
    await loadWeights();
  }

  Future<void> updateWeight(int id, DateTime day, double kilograms) async {
    await _repository.update(id: id, day: day, kilograms: kilograms);
    await loadWeights();
  }

  Future<void> deleteWeight(int id) async {
    await _repository.delete(id);
    await loadWeights();
  }
}
