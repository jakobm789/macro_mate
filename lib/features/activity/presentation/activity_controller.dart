import 'package:flutter/foundation.dart';

import '../../health/domain/health_models.dart';
import '../../health/domain/health_repository.dart';

class ActivityController extends ChangeNotifier {
  ActivityController({required HealthRepository repository})
      : _repository = repository;

  final HealthRepository _repository;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  DailyHealthSummary? _todaySummary;
  DailyHealthSummary? get todaySummary => _todaySummary;

  List<DailyHealthSummary> _weeklySummaries = [];
  List<DailyHealthSummary> get weeklySummaries =>
      List.unmodifiable(_weeklySummaries);

  List<WorkoutDetail> _workouts = [];
  List<WorkoutDetail> get workouts => List.unmodifiable(_workouts);

  WorkoutDetail? _selectedWorkout;
  WorkoutDetail? get selectedWorkout => _selectedWorkout;

  List<SleepSessionDetail> _sleepSessions = [];
  List<SleepSessionDetail> get sleepSessions =>
      List.unmodifiable(_sleepSessions);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await loadActivityData();
  }

  Future<void> loadActivityData([DateTime? date]) async {
    if (date != null) {
      _selectedDate = date;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = _selectedDate;
      final startWeek = now.subtract(const Duration(days: 7));
      final summaries = await _repository.summaries(
        startDay: startWeek,
        endDay: now,
      );

      _weeklySummaries = summaries;

      final todayStr = _formatDay(now);
      _todaySummary = summaries.where((s) => _formatDay(s.day) == todayStr).firstOrNull ??
          DailyHealthSummary(
            day: now,
            steps: 0,
            activeCalories: 0,
            distanceMeters: 0,
          );

      _workouts = await _repository.workouts();
      _sleepSessions = await _repository.sleepSessions();
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Aktivitätsdaten: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectWorkout(String workoutId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedWorkout = await _repository.workoutById(workoutId);
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Workout-Details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedWorkout() {
    _selectedWorkout = null;
    notifyListeners();
  }

  /// Calculates km splits for a workout based on route points or uniform pace
  List<Map<String, dynamic>> calculateSplits(WorkoutDetail workout) {
    if (workout.distanceMeters == null ||
        workout.distanceMeters! <= 0 ||
        workout.durationSeconds <= 0) {
      return [];
    }

    final totalKm = workout.distanceMeters! / 1000.0;
    final totalSeconds = workout.durationSeconds;
    final avgSecondsPerKm = totalSeconds / totalKm;

    final splits = <Map<String, dynamic>>[];
    final fullKm = totalKm.floor();

    for (int km = 1; km <= fullKm; km++) {
      splits.add({
        'km': km,
        'durationSeconds': avgSecondsPerKm,
        'paceMinPerKm': avgSecondsPerKm / 60.0,
      });
    }

    final remainingKm = totalKm - fullKm;
    if (remainingKm > 0.05) {
      final remainingSeconds = avgSecondsPerKm * remainingKm;
      splits.add({
        'km': fullKm + 1,
        'distanceKm': remainingKm,
        'durationSeconds': remainingSeconds,
        'paceMinPerKm': avgSecondsPerKm / 60.0,
      });
    }

    return splits;
  }

  String _formatDay(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
