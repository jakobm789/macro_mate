import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/features/gym/domain/ai_coach_engine.dart';
import 'package:macro_mate/features/gym/domain/gym_models.dart';

void main() {
  group('AiCoachEngine Tests', () {
    const coach = AiCoachEngine();

    test('Generates deterministic 3-day Push/Pull/Legs plan', () {
      const profile = GymIntakeProfile(
        goal: 'hypertrophy',
        experience: 'intermediate',
        daysPerWeek: 3,
        equipment: [GymEquipment.barbell, GymEquipment.dumbbell, GymEquipment.cable],
      );

      final plan = coach.generateDeterministicPlan(profile);
      expect(plan['name'], contains('Push Pull Legs'));
      expect(plan['daysPerWeek'], 3);

      final routines = plan['routines'] as List<dynamic>;
      expect(routines.length, 3);
      expect(routines[0]['name'], contains('Push'));
      expect(routines[1]['name'], contains('Pull'));
      expect(routines[2]['name'], contains('Legs'));
    });

    test('Generates deterministic 4-day Upper/Lower plan', () {
      const profile = GymIntakeProfile(
        goal: 'hypertrophy',
        experience: 'advanced',
        daysPerWeek: 4,
        equipment: [GymEquipment.barbell, GymEquipment.dumbbell],
      );

      final plan = coach.generateDeterministicPlan(profile);
      expect(plan['name'], contains('Oberkörper / Unterkörper'));
      expect(plan['daysPerWeek'], 4);

      final routines = plan['routines'] as List<dynamic>;
      expect(routines.length, 4);
    });

    test('Parses model JSON response with Markdown wrappers cleanly', () {
      const rawResponse = '''
Hier ist dein empfohlener Trainingsplan:
```json
{
  "name": "Custom AI Plan",
  "daysPerWeek": 3,
  "routines": [
    {
      "name": "Full Body Day",
      "dayOfWeek": 1,
      "progressionType": "linear",
      "exercises": []
    }
  ]
}
```
Viel Erfolg beim Training!
''';

      final parsed = coach.parsePlanResponse(rawResponse);
      expect(parsed['name'], 'Custom AI Plan');
      expect(parsed['daysPerWeek'], 3);
    });

    test('Evaluates stalls and triggers discrete Deload proposals', () {
      final proposals = coach.evaluateTrainingLogs(
        consecutiveStallsByExercise: {
          'ex_squat': 3,
          'ex_bench': 1,
        },
        averageRpeByExercise: {
          'ex_deadlift': 10.0,
        },
        neglectedMuscles: [GymMuscleGroup.calves],
      );

      expect(proposals.length, 2);

      final deload = proposals.firstWhere((p) => p.type == ProposalActionType.deload);
      expect(deload.exerciseId, 'ex_squat');
      expect(deload.adjustmentValue, -10.0);

      final volume = proposals.firstWhere((p) => p.type == ProposalActionType.adjustVolume);
      expect(volume.exerciseId, 'ex_deadlift');
      expect(volume.adjustmentValue, -1.0);
    });
  });
}
