import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/features/gym/domain/gym_models.dart';
import 'package:macro_mate/features/gym/domain/progression_engine.dart';

void main() {
  group('ProgressionEngine Tests', () {
    const engine = ProgressionEngine();

    test('Linear Progression: advances weight when all target reps met', () {
      const rule = ProgressionRule(
        type: ProgressionType.linear,
        weightIncrementKg: 2.5,
        targetSets: 3,
        targetReps: 5,
      );

      final sets = [
        const GymSetLog(id: '1', exerciseId: 'squat', setIndex: 1, weightKg: 100, reps: 5, completed: true),
        const GymSetLog(id: '2', exerciseId: 'squat', setIndex: 2, weightKg: 100, reps: 5, completed: true),
        const GymSetLog(id: '3', exerciseId: 'squat', setIndex: 3, weightKg: 100, reps: 5, completed: true),
      ];

      final result = engine.calculateNextSession(
        rule: rule,
        currentWeightKg: 100,
        completedSets: sets,
      );

      expect(result.nextWeightKg, 102.5);
      expect(result.nextConsecutiveStalls, 0);
      expect(result.isDeload, false);
      expect(result.reason, contains('+2.5 kg'));
    });

    test('Linear Progression: increments stall count when reps are missed', () {
      const rule = ProgressionRule(
        type: ProgressionType.linear,
        weightIncrementKg: 2.5,
        targetSets: 3,
        targetReps: 5,
        consecutiveStalls: 1,
      );

      final sets = [
        const GymSetLog(id: '1', exerciseId: 'squat', setIndex: 1, weightKg: 100, reps: 5, completed: true),
        const GymSetLog(id: '2', exerciseId: 'squat', setIndex: 2, weightKg: 100, reps: 4, completed: true),
        const GymSetLog(id: '3', exerciseId: 'squat', setIndex: 3, weightKg: 100, reps: 3, completed: true),
      ];

      final result = engine.calculateNextSession(
        rule: rule,
        currentWeightKg: 100,
        completedSets: sets,
      );

      expect(result.nextWeightKg, 100.0);
      expect(result.nextConsecutiveStalls, 2);
      expect(result.isDeload, false);
      expect(result.reason, contains('Fehlversuch 2/3'));
    });

    test('Linear Progression: triggers 10% deload after 3 consecutive stalls', () {
      const rule = ProgressionRule(
        type: ProgressionType.linear,
        weightIncrementKg: 2.5,
        targetSets: 3,
        targetReps: 5,
        consecutiveStalls: 2,
        deloadPercentage: 10.0,
      );

      final sets = [
        const GymSetLog(id: '1', exerciseId: 'squat', setIndex: 1, weightKg: 100, reps: 4, completed: true),
        const GymSetLog(id: '2', exerciseId: 'squat', setIndex: 2, weightKg: 100, reps: 4, completed: true),
        const GymSetLog(id: '3', exerciseId: 'squat', setIndex: 3, weightKg: 100, reps: 3, completed: true),
      ];

      final result = engine.calculateNextSession(
        rule: rule,
        currentWeightKg: 100,
        completedSets: sets,
      );

      expect(result.nextWeightKg, 90.0); // 10% deload from 100
      expect(result.nextConsecutiveStalls, 0);
      expect(result.isDeload, true);
      expect(result.reason, contains('Deload um 10%'));
    });

    test('Greyskull LP: double jump (+5.0kg) when AMRAP final set >= 10 reps', () {
      const rule = ProgressionRule(
        type: ProgressionType.greyskull,
        weightIncrementKg: 2.5,
        targetSets: 3,
        targetReps: 5,
      );

      final sets = [
        const GymSetLog(id: '1', exerciseId: 'bench', setIndex: 1, weightKg: 80, reps: 5, completed: true),
        const GymSetLog(id: '2', exerciseId: 'bench', setIndex: 2, weightKg: 80, reps: 5, completed: true),
        const GymSetLog(id: '3', exerciseId: 'bench', setIndex: 3, weightKg: 80, reps: 11, completed: true),
      ];

      final result = engine.calculateNextSession(
        rule: rule,
        currentWeightKg: 80,
        completedSets: sets,
      );

      expect(result.nextWeightKg, 85.0); // double jump: +5kg
      expect(result.nextConsecutiveStalls, 0);
      expect(result.reason, contains('Doppelter Sprung'));
    });

    test('Double Progression: increases weight only after top rep limit reached in all sets', () {
      const rule = ProgressionRule(
        type: ProgressionType.doubleProgression,
        weightIncrementKg: 2.5,
        targetSets: 3,
        targetReps: 8,
        targetRepsMax: 12,
      );

      // Scenario 1: Not all sets hit 12 reps yet
      final partialSets = [
        const GymSetLog(id: '1', exerciseId: 'curls', setIndex: 1, weightKg: 20, reps: 12, completed: true),
        const GymSetLog(id: '2', exerciseId: 'curls', setIndex: 2, weightKg: 20, reps: 11, completed: true),
        const GymSetLog(id: '3', exerciseId: 'curls', setIndex: 3, weightKg: 20, reps: 10, completed: true),
      ];

      final partialResult = engine.calculateNextSession(
        rule: rule,
        currentWeightKg: 20,
        completedSets: partialSets,
      );
      expect(partialResult.nextWeightKg, 20.0);
      expect(partialResult.nextTargetReps, 12);

      // Scenario 2: All sets hit 12 reps -> jump weight, reset to 8 reps
      final maxSets = [
        const GymSetLog(id: '1', exerciseId: 'curls', setIndex: 1, weightKg: 20, reps: 12, completed: true),
        const GymSetLog(id: '2', exerciseId: 'curls', setIndex: 2, weightKg: 20, reps: 12, completed: true),
        const GymSetLog(id: '3', exerciseId: 'curls', setIndex: 3, weightKg: 20, reps: 12, completed: true),
      ];

      final maxResult = engine.calculateNextSession(
        rule: rule,
        currentWeightKg: 20,
        completedSets: maxSets,
      );
      expect(maxResult.nextWeightKg, 22.5);
      expect(maxResult.nextTargetReps, 8);
    });

    test('Timed Progression: increases hold target by 10s upon completion', () {
      const rule = ProgressionRule(
        type: ProgressionType.timed,
        targetSets: 3,
        targetHoldSeconds: 60,
      );

      final sets = [
        const GymSetLog(id: '1', exerciseId: 'plank', setIndex: 1, holdSeconds: 60, completed: true),
        const GymSetLog(id: '2', exerciseId: 'plank', setIndex: 2, holdSeconds: 60, completed: true),
        const GymSetLog(id: '3', exerciseId: 'plank', setIndex: 3, holdSeconds: 65, completed: true),
      ];

      final result = engine.calculateNextSession(
        rule: rule,
        currentWeightKg: 0,
        completedSets: sets,
      );

      expect(result.nextTargetHoldSeconds, 70);
    });
  });

  group('OneRepMaxCalculator Tests', () {
    const calc = OneRepMaxCalculator();

    test('1 Rep returns exact weight as 1RM', () {
      final estimate = calc.calculate(weightKg: 100, reps: 1);
      expect(estimate.estimated1Rm, 100.0);
      expect(estimate.eligible, true);
    });

    test('Brzycki formula calculates accurate 1RM for moderate reps', () {
      final estimate = calc.calculate(
        weightKg: 100,
        reps: 5,
        formula: OneRepMaxFormula.brzycki,
      );
      // Brzycki: 100 * (36 / (37 - 5)) = 100 * (36/32) = 112.5
      expect(estimate.estimated1Rm, 112.5);
      expect(estimate.eligible, true);
    });

    test('Marks sets > 12 reps as ineligible for max strength estimation', () {
      final estimate = calc.calculate(weightKg: 50, reps: 15);
      expect(estimate.eligible, false);
    });

    test('findBest1Rm picks the highest estimated 1RM among eligible sets', () {
      final sets = [
        const GymSetLog(id: '1', exerciseId: 'bench', setIndex: 1, weightKg: 80, reps: 10, completed: true), // ~106.7 kg
        const GymSetLog(id: '2', exerciseId: 'bench', setIndex: 2, weightKg: 100, reps: 5, completed: true), // 112.5 kg
        const GymSetLog(id: '3', exerciseId: 'bench', setIndex: 3, weightKg: 90, reps: 6, completed: true),  // ~104.5 kg
      ];

      final best = calc.findBest1Rm(sets);
      expect(best, isNotNull);
      expect(best!.weightKg, 100.0);
      expect(best.reps, 5);
      expect(best.estimated1Rm, 112.5);
    });
  });
}
