import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../data/drift_gym_repository.dart';
import '../domain/ai_coach_engine.dart';
import '../domain/gym_models.dart';
import '../domain/progression_engine.dart';

class GymController extends ChangeNotifier {
  GymController({
    required DriftGymRepository repository,
    AiCoachEngine? aiCoachEngine,
    ProgressionEngine? progressionEngine,
  })  : _repository = repository,
        _aiCoach = aiCoachEngine ?? const AiCoachEngine(),
        _progressionEngine = progressionEngine ?? const ProgressionEngine();

  final DriftGymRepository _repository;
  final AiCoachEngine _aiCoach;
  final ProgressionEngine _progressionEngine;
  ProgressionEngine get progressionEngine => _progressionEngine;
  static const _uuid = Uuid();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  GymWorkoutPlanRow? _activePlan;
  GymWorkoutPlanRow? get activePlan => _activePlan;

  List<GymPlanRoutineRow> _routines = [];
  List<GymPlanRoutineRow> get routines => List.unmodifiable(_routines);

  Map<String, List<GymPlanRoutineExerciseRow>> _routineExercises = {};
  Map<String, List<GymPlanRoutineExerciseRow>> get routineExercises =>
      Map.unmodifiable(_routineExercises);

  List<GymExercise> _exercises = [];
  List<GymExercise> get exercises => List.unmodifiable(_exercises);

  Map<GymMuscleGroup, double> _muscleTonnage = {};
  Map<GymMuscleGroup, double> get muscleTonnage => Map.unmodifiable(_muscleTonnage);

  List<GymMuscleGroup> _neglectedMuscles = [];
  List<GymMuscleGroup> get neglectedMuscles => List.unmodifiable(_neglectedMuscles);

  List<GymWorkoutSessionRow> _recentSessions = [];
  List<GymWorkoutSessionRow> get recentSessions => List.unmodifiable(_recentSessions);

  List<PlanProposalAction> _aiProposals = [];
  List<PlanProposalAction> get aiProposals => List.unmodifiable(_aiProposals);

  // Active workout state
  String? _activeSessionId;
  String? get activeSessionId => _activeSessionId;
  bool get isWorkoutActive => _activeSessionId != null;

  GymPlanRoutineRow? _activeRoutine;
  GymPlanRoutineRow? get activeRoutine => _activeRoutine;

  DateTime? _workoutStartTime;
  DateTime? get workoutStartTime => _workoutStartTime;

  List<GymSetLog> _activeSets = [];
  List<GymSetLog> get activeSets => List.unmodifiable(_activeSets);

  // Rest timer
  int _restTimerSecondsRemaining = 0;
  int get restTimerSecondsRemaining => _restTimerSecondsRemaining;
  bool get isRestTimerRunning => _restTimerSecondsRemaining > 0;
  Timer? _restTimer;

  Future<void> initialize() async {
    await loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.ensureSeeded();
      _exercises = await _repository.getAllExercises();
      _activePlan = await _repository.getActivePlan();

      if (_activePlan != null) {
        _routines = await _repository.getRoutinesForPlan(_activePlan!.id);
        _routineExercises = {};
        for (final r in _routines) {
          _routineExercises[r.id] = await _repository.getExercisesForRoutine(r.id);
        }
      } else {
        _routines = [];
        _routineExercises = {};
      }

      _recentSessions = await _repository.getRecentSessions();
      _muscleTonnage = await _repository.getMuscleTonnage(days: 7);
      _neglectedMuscles = await _repository.getNeglectedMuscles(days: 14);

      // Check AI Coach proposals
      _evaluateProposals();
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Gym-Daten: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _evaluateProposals() {
    // Generate AI Coach review proposals
    _aiProposals = _aiCoach.evaluateTrainingLogs(
      consecutiveStallsByExercise: {},
      averageRpeByExercise: {},
      neglectedMuscles: _neglectedMuscles,
    );
  }

  // --- WORKOUT RUNNER FLOW ---

  Future<void> startWorkout({
    required GymPlanRoutineRow routine,
    required List<GymPlanRoutineExerciseRow> exercises,
  }) async {
    _activeSessionId = _uuid.v4();
    _activeRoutine = routine;
    _workoutStartTime = DateTime.now().toUtc();
    _activeSets = [];

    // Pre-fill sets based on planned targets and previous workout weights
    var globalSetIndex = 0;
    for (final plannedEx in exercises) {
      final prevSets = await _repository.getPreviousSetsForExercise(plannedEx.exerciseId);
      final defaultWeight = prevSets.isNotEmpty ? prevSets.first.weightKg : 20.0;

      for (var i = 1; i <= plannedEx.targetSets; i++) {
        final prevWeightForSet = (i <= prevSets.length)
            ? prevSets[i - 1].weightKg
            : defaultWeight;
        final prevRepsForSet = (i <= prevSets.length && prevSets[i - 1].reps != null)
            ? prevSets[i - 1].reps!
            : plannedEx.targetRepsMin;

        _activeSets.add(
          GymSetLog(
            id: _uuid.v4(),
            exerciseId: plannedEx.exerciseId,
            setIndex: ++globalSetIndex,
            setType: GymSetType.normal,
            weightKg: prevWeightForSet,
            reps: plannedEx.targetHoldSeconds != null ? null : prevRepsForSet,
            holdSeconds: plannedEx.targetHoldSeconds,
            completed: false,
          ),
        );
      }
    }

    notifyListeners();
  }

  void updateSet(
    int index, {
    double? weightKg,
    int? reps,
    int? holdSeconds,
    double? rpe,
    int? rir,
    GymSetType? setType,
  }) {
    if (index < 0 || index >= _activeSets.length) return;
    _activeSets[index] = _activeSets[index].copyWith(
      weightKg: weightKg,
      reps: reps,
      holdSeconds: holdSeconds,
      rpe: rpe,
      rir: rir,
      setType: setType,
    );
    notifyListeners();
  }

  void toggleSetCompleted(int index, bool completed, {int restSeconds = 90}) {
    if (index < 0 || index >= _activeSets.length) return;
    _activeSets[index] = _activeSets[index].copyWith(completed: completed);

    if (completed && restSeconds > 0) {
      startRestTimer(restSeconds);
    }
    notifyListeners();
  }

  void addSetToExercise(String exerciseId) {
    final existing = _activeSets.where((s) => s.exerciseId == exerciseId).toList();
    final lastWeight = existing.isNotEmpty ? existing.last.weightKg : 20.0;
    final lastReps = existing.isNotEmpty ? existing.last.reps : 8;

    _activeSets.add(
      GymSetLog(
        id: _uuid.v4(),
        exerciseId: exerciseId,
        setIndex: _activeSets.length + 1,
        setType: GymSetType.normal,
        weightKg: lastWeight,
        reps: lastReps,
        completed: false,
      ),
    );
    notifyListeners();
  }

  void startRestTimer(int seconds) {
    _restTimer?.cancel();
    _restTimerSecondsRemaining = seconds;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restTimerSecondsRemaining > 1) {
        _restTimerSecondsRemaining--;
        notifyListeners();
      } else {
        _restTimerSecondsRemaining = 0;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void stopRestTimer() {
    _restTimer?.cancel();
    _restTimerSecondsRemaining = 0;
    notifyListeners();
  }

  Future<WorkoutSessionSaveResult?> finishWorkout({String? notes}) async {
    if (_activeSessionId == null || _workoutStartTime == null) return null;

    final now = DateTime.now().toUtc();
    final duration = now.difference(_workoutStartTime!).inSeconds.toDouble();

    final completedSets = _activeSets.where((s) => s.completed).toList();
    final rpes = completedSets.map((s) => s.rpe).whereType<double>().toList();
    final avgRpe = rpes.isEmpty ? null : rpes.reduce((a, b) => a + b) / rpes.length;

    final result = await _repository.saveWorkoutSession(
      sessionId: _activeSessionId!,
      routineId: _activeRoutine?.id,
      routineName: _activeRoutine?.name ?? 'Freies Training',
      startUtc: _workoutStartTime!,
      endUtc: now,
      durationSeconds: duration,
      notes: notes,
      rpeAverage: avgRpe,
      sets: _activeSets,
    );

    _activeSessionId = null;
    _activeRoutine = null;
    _workoutStartTime = null;
    _activeSets = [];
    stopRestTimer();

    await loadData();
    return result;
  }

  void cancelWorkout() {
    _activeSessionId = null;
    _activeRoutine = null;
    _workoutStartTime = null;
    _activeSets = [];
    stopRestTimer();
    notifyListeners();
  }

  Future<void> upsertExercise(GymExercise exercise) async {
    await _repository.upsertExercise(exercise);
    await loadData();
  }

  Future<void> deleteExercise(String id) async {
    await _repository.deleteExercise(id);
    await loadData();
  }

  Future<void> applyProposal(PlanProposalAction proposal) async {
    if (_activePlan == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final routines = await _repository.getRoutinesForPlan(_activePlan!.id);
      final routinesData = <Map<String, dynamic>>[];

      for (final r in routines) {
        final exercises = await _repository.getExercisesForRoutine(r.id);
        final exercisesData = <Map<String, dynamic>>[];

        for (final e in exercises) {
          var targetSets = e.targetSets;
          if (e.exerciseId == proposal.exerciseId &&
              proposal.type == ProposalActionType.adjustVolume &&
              proposal.adjustmentValue != null) {
            targetSets = (targetSets + proposal.adjustmentValue!.toInt()).clamp(1, 10);
          }

          exercisesData.add({
            'exerciseId': e.exerciseId,
            'targetSets': targetSets,
            'targetRepsMin': e.targetRepsMin,
            'targetRepsMax': e.targetRepsMax,
            'targetHoldSeconds': e.targetHoldSeconds,
            'restSeconds': e.restSeconds,
            'supersetGroupId': e.supersetGroupId,
            'notes': e.notes,
          });
        }

        routinesData.add({
          'id': r.id,
          'name': r.name,
          'dayOfWeek': r.dayOfWeek,
          'progressionType': r.progressionType,
          'exercises': exercisesData,
        });
      }

      await _repository.saveWorkoutPlan(
        planId: _activePlan!.id,
        name: _activePlan!.name,
        description: _activePlan!.description,
        daysPerWeek: _activePlan!.daysPerWeek,
        isActive: true,
        routinesWithExercises: routinesData,
      );

      _aiProposals.removeWhere((p) => p.id == proposal.id);
      await loadData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- AI COACH PLAN CREATION ---

  Future<void> createPlanFromIntake(GymIntakeProfile profile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final planData = _aiCoach.generateDeterministicPlan(profile);
      final planId = _uuid.v4();

      final routinesList = (planData['routines'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      await _repository.saveWorkoutPlan(
        planId: planId,
        name: planData['name'] as String,
        description: planData['description'] as String?,
        daysPerWeek: planData['daysPerWeek'] as int? ?? profile.daysPerWeek,
        isActive: true,
        routinesWithExercises: routinesList,
      );

      await loadData();
    } catch (e) {
      _errorMessage = 'Fehler beim Erstellen des Plans: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }
}
