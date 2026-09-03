import 'gym_models.dart';

class ProgressionEngine {
  const ProgressionEngine();

  ProgressionResult calculateNextSession({
    required ProgressionRule rule,
    required double currentWeightKg,
    required List<GymSetLog> completedSets,
  }) {
    // Only evaluate completed working sets (ignore warmup sets)
    final workingSets = completedSets
        .where((s) => s.completed && s.setType != GymSetType.warmup)
        .toList();

    if (workingSets.isEmpty) {
      final newStalls = rule.consecutiveStalls + 1;
      return _evaluateStall(rule, currentWeightKg, newStalls,
          'Keine abgeschlossenen Arbeitssätze protokolliert.');
    }

    switch (rule.type) {
      case ProgressionType.linear:
        return _calculateLinear(rule, currentWeightKg, workingSets);
      case ProgressionType.greyskull:
        return _calculateGreyskull(rule, currentWeightKg, workingSets);
      case ProgressionType.doubleProgression:
        return _calculateDoubleProgression(rule, currentWeightKg, workingSets);
      case ProgressionType.timed:
        return _calculateTimed(rule, currentWeightKg, workingSets);
    }
  }

  ProgressionResult _calculateLinear(
    ProgressionRule rule,
    double currentWeightKg,
    List<GymSetLog> sets,
  ) {
    final allPassed = sets.length >= rule.targetSets &&
        sets.every((s) => (s.reps ?? 0) >= rule.targetReps);

    if (allPassed) {
      final nextWeight = _roundWeight(currentWeightKg + rule.weightIncrementKg);
      return ProgressionResult(
        nextWeightKg: nextWeight,
        nextTargetReps: rule.targetReps,
        nextConsecutiveStalls: 0,
        reason:
            'Ziel erreicht (${rule.targetSets}×${rule.targetReps}): +${rule.weightIncrementKg} kg',
      );
    }

    final newStalls = rule.consecutiveStalls + 1;
    return _evaluateStall(rule, currentWeightKg, newStalls,
        'Ziel nicht erreicht (Vorgabe: ${rule.targetSets}×${rule.targetReps})');
  }

  ProgressionResult _calculateGreyskull(
    ProgressionRule rule,
    double currentWeightKg,
    List<GymSetLog> sets,
  ) {
    final setsMetTarget = sets.length >= rule.targetSets &&
        sets.take(rule.targetSets - 1).every((s) => (s.reps ?? 0) >= rule.targetReps);

    if (setsMetTarget) {
      final lastSetReps = sets.last.reps ?? 0;
      if (lastSetReps >= 10) {
        // Double jump in Greyskull LP when hitting 10+ reps on final AMRAP set
        final doubleJump = rule.weightIncrementKg * 2;
        final nextWeight = _roundWeight(currentWeightKg + doubleJump);
        return ProgressionResult(
          nextWeightKg: nextWeight,
          nextTargetReps: rule.targetReps,
          nextConsecutiveStalls: 0,
          reason:
              'AMRAP Topsatz mit $lastSetReps Reps geschafft! Doppelter Sprung: +$doubleJump kg',
        );
      } else if (lastSetReps >= rule.targetReps) {
        final nextWeight = _roundWeight(currentWeightKg + rule.weightIncrementKg);
        return ProgressionResult(
          nextWeightKg: nextWeight,
          nextTargetReps: rule.targetReps,
          nextConsecutiveStalls: 0,
          reason:
              'AMRAP Topsatz mit $lastSetReps Reps geschafft: +${rule.weightIncrementKg} kg',
        );
      }
    }

    final newStalls = rule.consecutiveStalls + 1;
    return _evaluateStall(rule, currentWeightKg, newStalls,
        'Greyskull Rep-Ziel nicht erreicht');
  }

  ProgressionResult _calculateDoubleProgression(
    ProgressionRule rule,
    double currentWeightKg,
    List<GymSetLog> sets,
  ) {
    final allHitMax = sets.length >= rule.targetSets &&
        sets.every((s) => (s.reps ?? 0) >= rule.targetRepsMax);

    if (allHitMax) {
      // Reached top of rep range in all sets -> increase weight, reset target reps to min
      final nextWeight = _roundWeight(currentWeightKg + rule.weightIncrementKg);
      return ProgressionResult(
        nextWeightKg: nextWeight,
        nextTargetReps: rule.targetReps,
        nextConsecutiveStalls: 0,
        reason:
            'Oberes Rep-Limit (${rule.targetRepsMax}) in allen Sätzen erreicht: +${rule.weightIncrementKg} kg, Neustart bei ${rule.targetReps} Wdh.',
      );
    }

    // Weight stays the same, user continues building reps within range
    return ProgressionResult(
      nextWeightKg: currentWeightKg,
      nextTargetReps: rule.targetRepsMax,
      nextConsecutiveStalls: 0,
      reason:
          'Gewicht halten ($currentWeightKg kg) und Wiederholungen in Richtung ${rule.targetRepsMax} steigern.',
    );
  }

  ProgressionResult _calculateTimed(
    ProgressionRule rule,
    double currentWeightKg,
    List<GymSetLog> sets,
  ) {
    final allPassed = sets.length >= rule.targetSets &&
        sets.every((s) => (s.holdSeconds ?? 0) >= rule.targetHoldSeconds);

    if (allPassed) {
      final nextHold = rule.targetHoldSeconds + 10;
      return ProgressionResult(
        nextWeightKg: currentWeightKg,
        nextTargetReps: 1,
        nextTargetHoldSeconds: nextHold,
        nextConsecutiveStalls: 0,
        reason:
            'Haltezeit (${rule.targetHoldSeconds}s) gemeistert: Neue Zielzeit ${nextHold}s.',
      );
    }

    return ProgressionResult(
      nextWeightKg: currentWeightKg,
      nextTargetReps: 1,
      nextTargetHoldSeconds: rule.targetHoldSeconds,
      nextConsecutiveStalls: rule.consecutiveStalls,
      reason: 'Haltezeit (${rule.targetHoldSeconds}s) beibehalten.',
    );
  }

  ProgressionResult _evaluateStall(
    ProgressionRule rule,
    double currentWeightKg,
    int consecutiveStalls,
    String failurePrefix,
  ) {
    if (consecutiveStalls >= 3) {
      // Trigger 10% deload
      final deloadMultiplier = 1.0 - (rule.deloadPercentage / 100.0);
      final deloadWeight = _roundWeight(currentWeightKg * deloadMultiplier);
      return ProgressionResult(
        nextWeightKg: deloadWeight,
        nextTargetReps: rule.targetReps,
        nextConsecutiveStalls: 0,
        isDeload: true,
        reason:
            '3x in Folge stagniert. Deload um ${rule.deloadPercentage.toStringAsFixed(0)}% auf $deloadWeight kg zur Regeneration.',
      );
    }

    return ProgressionResult(
      nextWeightKg: currentWeightKg,
      nextTargetReps: rule.targetReps,
      nextConsecutiveStalls: consecutiveStalls,
      reason:
          '$failurePrefix. Gewicht $currentWeightKg kg beibehalten (Fehlversuch $consecutiveStalls/3).',
    );
  }

  static double _roundWeight(double weight) {
    // Round to closest 0.5 kg
    return (weight * 2).roundToDouble() / 2;
  }
}

class OneRepMaxCalculator {
  const OneRepMaxCalculator();

  static const int maxEligibleReps = 12;

  OneRepMaxEstimate calculate({
    required double weightKg,
    required int reps,
    OneRepMaxFormula formula = OneRepMaxFormula.brzycki,
  }) {
    if (weightKg <= 0 || reps <= 0) {
      return OneRepMaxEstimate(
        weightKg: weightKg,
        reps: reps,
        estimated1Rm: 0.0,
        formula: formula,
        eligible: false,
      );
    }

    if (reps == 1) {
      return OneRepMaxEstimate(
        weightKg: weightKg,
        reps: 1,
        estimated1Rm: weightKg,
        formula: formula,
        eligible: true,
      );
    }

    final eligible = reps <= maxEligibleReps;

    final brzycki = weightKg * (36.0 / (37.0 - reps));
    final epley = weightKg * (1.0 + (reps / 30.0));

    final estimate = switch (formula) {
      OneRepMaxFormula.brzycki => brzycki,
      OneRepMaxFormula.epley => epley,
      OneRepMaxFormula.average => (brzycki + epley) / 2.0,
    };

    return OneRepMaxEstimate(
      weightKg: weightKg,
      reps: reps,
      estimated1Rm: double.parse(estimate.toStringAsFixed(1)),
      formula: formula,
      eligible: eligible,
    );
  }

  OneRepMaxEstimate? findBest1Rm(
    List<GymSetLog> sets, {
    OneRepMaxFormula formula = OneRepMaxFormula.brzycki,
  }) {
    final eligibleEstimates = sets
        .where((s) => s.completed && s.reps != null && s.reps! > 0 && s.weightKg > 0)
        .map((s) => calculate(
              weightKg: s.weightKg,
              reps: s.reps!,
              formula: formula,
            ))
        .where((e) => e.eligible)
        .toList();

    if (eligibleEstimates.isEmpty) return null;

    eligibleEstimates.sort((a, b) => b.estimated1Rm.compareTo(a.estimated1Rm));
    return eligibleEstimates.first;
  }
}
