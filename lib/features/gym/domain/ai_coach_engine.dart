import 'dart:convert';
import 'gym_models.dart';

class GymIntakeProfile {
  const GymIntakeProfile({
    required this.goal,
    required this.experience,
    required this.daysPerWeek,
    this.sessionDurationMinutes = 60,
    required this.equipment,
    this.limitations = '',
    this.preferredProgression = ProgressionType.greyskull,
  });

  final String goal; // 'hypertrophy', 'strength', 'general_fitness'
  final String experience; // 'beginner', 'intermediate', 'advanced'
  final int daysPerWeek;
  final int sessionDurationMinutes;
  final List<GymEquipment> equipment;
  final String limitations;
  final ProgressionType preferredProgression;
}

enum ProposalActionType {
  deload,
  swapExercise,
  adjustVolume,
  changeRepRange,
}

class PlanProposalAction {
  const PlanProposalAction({
    required this.id,
    required this.type,
    required this.title,
    required this.explanation,
    required this.exerciseId,
    this.newExerciseId,
    this.adjustmentValue,
  });

  final String id;
  final ProposalActionType type;
  final String title;
  final String explanation;
  final String exerciseId;
  final String? newExerciseId;
  final double? adjustmentValue; // e.g. -10 for -10% deload, or +1 for set
}

class AiCoachEngine {
  const AiCoachEngine();

  /// Builds a structured prompt for local Gemma / LiteRT
  String buildIntakePrompt(
      GymIntakeProfile profile, List<GymExercise> availableExercises) {
    final equipmentNames =
        profile.equipment.map((e) => e.displayName).join(', ');

    // Pick balanced exercises across all muscle groups so legs and lower body are well represented
    final diverseExercises = <GymExercise>[];
    for (final group in GymMuscleGroup.values) {
      diverseExercises.addAll(
        availableExercises.where((e) => e.primaryMuscle == group).take(5),
      );
    }
    final exerciseListSnippet = (diverseExercises.isNotEmpty
            ? diverseExercises
            : availableExercises.take(45))
        .map((e) =>
            '${e.id}: ${e.name} (${e.primaryMuscle.displayName}, ${e.equipment.displayName})')
        .join('\n');

    return '''
Du bist ein erfahrener Kraftsport- und Hypertrophie-Coach.
Erstelle einen Trainingsplan im exakten JSON-Format basierend auf folgenden Vorgaben:
- Ziel: ${profile.goal}
- Trainingserfahrung: ${profile.experience}
- Tage pro Woche: ${profile.daysPerWeek}
- Dauer pro Session: ${profile.sessionDurationMinutes} Minuten
- Verfügbare Ausrüstung: $equipmentNames
- Einschränkungen / Verletzungen: ${profile.limitations.isEmpty ? 'Keine' : profile.limitations}

WICHTIGE VORGABEN:
1. Jede Trainingseinheit (Routine) MUSS insgesamt exakt 16 Arbeitssätze umfassen (z. B. 4 Übungen à 4 Sätze oder 5 Übungen à 4+4+3+3+2 Sätze).
2. Der Plan MUSS ausgewogen sein und Beintraining (Quadrizeps, Beinbeuger, Gluteus, Waden) gleichwertig zu Oberkörper/Push/Pull abdecken. Es darf keinesfalls nur Oberkörper generiert werden!
3. Die Standard-Pausenzeit beträgt 180 Sekunden (3 Minuten) für Grundübungen und 120-180 Sekunden für Nebenübungen.

Verfügbare Übungs-IDs:
$exerciseListSnippet

Antworte ausschließlich im folgenden validen JSON-Format:
{
  "name": "Trainingsplan-Name",
  "description": "Kurze Beschreibung des Split-Konzepts",
  "daysPerWeek": ${profile.daysPerWeek},
  "routines": [
    {
      "name": "z.B. Tag 1: Push",
      "dayOfWeek": 1,
      "progressionType": "${profile.preferredProgression.name}",
      "exercises": [
        {
          "exerciseId": "ex_bench_press",
          "targetSets": 4,
          "targetRepsMin": 6,
          "targetRepsMax": 8,
          "restSeconds": 180
        }
      ]
    }
  ]
}
''';
  }

  /// Parses JSON response from AI model, or falls back to smart deterministic generator
  Map<String, dynamic> parsePlanResponse(String jsonString) {
    try {
      final clean = _extractJson(jsonString);
      return jsonDecode(clean) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException(
          'Konnte Trainingsplan-JSON vom Modell nicht parsen.');
    }
  }

  /// Generates an expert evidence-based starter plan deterministically
  /// (used as offline-first fallback or instant template).
  /// Every routine strictly contains 16 working sets with a default 180s rest time.
  Map<String, dynamic> generateDeterministicPlan(GymIntakeProfile profile) {
    if (profile.daysPerWeek <= 2) {
      // 2-Day Full Body: exactly 16 sets per routine
      return {
        'name': 'Ganzkörper 2er-Split',
        'description':
            'Ausgewogener Ganzkörperplan mit exakt 16 Sätzen pro Einheit und 3 Min. Pause.',
        'daysPerWeek': 2,
        'routines': [
          {
            'name': 'Ganzkörper A (Kniebeugen & Brust)',
            'dayOfWeek': 1, // Montag
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_squat',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_bench_press',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_barbell_row',
                'targetSets': 3,
                'targetRepsMin': 6,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_bicep_curl_db',
                'targetSets': 3,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_plank',
                'targetSets': 2,
                'targetHoldSeconds': 60,
                'restSeconds': 90
              },
            ],
          },
          {
            'name': 'Ganzkörper B (Kreuzheben & Schultern)',
            'dayOfWeek': 4, // Donnerstag
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_deadlift',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 5,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_overhead_press',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_lat_pulldown',
                'targetSets': 3,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_tricep_pushdown',
                'targetSets': 3,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_hanging_leg_raise',
                'targetSets': 2,
                'targetRepsMin': 8,
                'targetRepsMax': 12,
                'restSeconds': 90
              },
            ],
          },
        ],
      };
    } else if (profile.daysPerWeek == 3) {
      // 3-Day Push / Pull / Legs: exactly 16 sets per routine
      return {
        'name': 'Push Pull Legs 3-Day',
        'description':
            'Klassischer 3-Tage-Split für maximale Hypertrophie (16 Sätze pro Einheit, 3 Min. Pause).',
        'daysPerWeek': 3,
        'routines': [
          {
            'name': 'Push (Brust, Schultern, Trizeps)',
            'dayOfWeek': 1,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_bench_press',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_incline_db_press',
                'targetSets': 3,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_overhead_press',
                'targetSets': 3,
                'targetRepsMin': 6,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_lateral_raise',
                'targetSets': 3,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_tricep_pushdown',
                'targetSets': 3,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 120
              },
            ],
          },
          {
            'name': 'Pull (Rücken, hintere Schulter, Bizeps)',
            'dayOfWeek': 3,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_deadlift',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 5,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_lat_pulldown',
                'targetSets': 4,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_barbell_row',
                'targetSets': 3,
                'targetRepsMin': 6,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_face_pulls',
                'targetSets': 2,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_bicep_curl_db',
                'targetSets': 3,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 120
              },
            ],
          },
          {
            'name': 'Legs (Quadrizeps, Beinbeuger, Waden, Bauch)',
            'dayOfWeek': 5,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_squat',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_romanian_deadlift',
                'targetSets': 4,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_leg_press',
                'targetSets': 3,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_calf_raise',
                'targetSets': 3,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_plank',
                'targetSets': 2,
                'targetHoldSeconds': 60,
                'restSeconds': 90
              },
            ],
          },
        ],
      };
    } else if (profile.daysPerWeek == 4) {
      // 4-Day Upper / Lower Split: exactly 16 sets per routine
      return {
        'name': 'Oberkörper / Unterkörper 4-Day',
        'description':
            'Ausgewogener 4-Tage-Split mit Fokus auf Beine & Oberkörper (16 Sätze pro Einheit, 3 Min. Pause).',
        'daysPerWeek': 4,
        'routines': [
          {
            'name': 'Oberkörper A',
            'dayOfWeek': 1,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_bench_press',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_barbell_row',
                'targetSets': 4,
                'targetRepsMin': 6,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_overhead_press',
                'targetSets': 3,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_lat_pulldown',
                'targetSets': 3,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_bicep_curl_db',
                'targetSets': 2,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 120
              },
            ],
          },
          {
            'name': 'Unterkörper A (Kniebeuge & Waden)',
            'dayOfWeek': 2,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_squat',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_romanian_deadlift',
                'targetSets': 4,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_leg_press',
                'targetSets': 3,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_calf_raise',
                'targetSets': 3,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_plank',
                'targetSets': 2,
                'targetHoldSeconds': 60,
                'restSeconds': 90
              },
            ],
          },
          {
            'name': 'Oberkörper B',
            'dayOfWeek': 4,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_incline_db_press',
                'targetSets': 4,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_lat_pulldown',
                'targetSets': 4,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_chest_dips',
                'targetSets': 3,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_lateral_raise',
                'targetSets': 3,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_tricep_pushdown',
                'targetSets': 2,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 120
              },
            ],
          },
          {
            'name': 'Unterkörper B (Kreuzheben & Beinbeuger)',
            'dayOfWeek': 5,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_deadlift',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 5,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_leg_press',
                'targetSets': 4,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_leg_curl_lying',
                'targetSets': 3,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_seated_calf_raise',
                'targetSets': 3,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_hanging_leg_raise',
                'targetSets': 2,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 90
              },
            ],
          },
        ],
      };
    } else {
      // 5-Day Split (Push / Pull / Legs / Oberkörper / Unterkörper - PPLUL): exactly 16 sets per routine
      return {
        'name': 'Push Pull Legs Upper Lower 5-Day',
        'description':
            'Voller 5-Tage-Split für maximalen Aufbau mit 2 Beintagen & 3 Oberkörpertagen (16 Sätze pro Einheit, 3 Min. Pause).',
        'daysPerWeek': 5,
        'routines': [
          {
            'name': 'Tag 1: Push (Brust, Schultern, Trizeps)',
            'dayOfWeek': 1,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_bench_press',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_incline_db_press',
                'targetSets': 3,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_overhead_press',
                'targetSets': 3,
                'targetRepsMin': 6,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_lateral_raise',
                'targetSets': 3,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_tricep_pushdown',
                'targetSets': 3,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 120
              },
            ],
          },
          {
            'name': 'Tag 2: Pull (Rücken, hintere Schulter, Bizeps)',
            'dayOfWeek': 2,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_deadlift',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 5,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_lat_pulldown',
                'targetSets': 4,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_barbell_row',
                'targetSets': 3,
                'targetRepsMin': 6,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_face_pulls',
                'targetSets': 2,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_bicep_curl_db',
                'targetSets': 3,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 120
              },
            ],
          },
          {
            'name': 'Tag 3: Legs (Kniebeugen, Beinpresse, Waden)',
            'dayOfWeek': 3,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_squat',
                'targetSets': 4,
                'targetRepsMin': 5,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_romanian_deadlift',
                'targetSets': 4,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_leg_press',
                'targetSets': 3,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_calf_raise',
                'targetSets': 3,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_plank',
                'targetSets': 2,
                'targetHoldSeconds': 60,
                'restSeconds': 90
              },
            ],
          },
          {
            'name': 'Tag 4: Oberkörper (Hypertrophie)',
            'dayOfWeek': 5,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_incline_barbell_press',
                'targetSets': 4,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_seated_cable_row',
                'targetSets': 4,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_chest_dips',
                'targetSets': 3,
                'targetRepsMin': 8,
                'targetRepsMax': 10,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_cable_lateral_raise',
                'targetSets': 3,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_hammer_curls',
                'targetSets': 2,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 120
              },
            ],
          },
          {
            'name': 'Tag 5: Unterkörper (Beinbeuger & Quadrizeps)',
            'dayOfWeek': 6,
            'progressionType': profile.preferredProgression.name,
            'exercises': [
              {
                'exerciseId': 'ex_front_squat',
                'targetSets': 4,
                'targetRepsMin': 6,
                'targetRepsMax': 8,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_leg_curl_seated',
                'targetSets': 4,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_walking_lunges',
                'targetSets': 3,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 180
              },
              {
                'exerciseId': 'ex_seated_calf_raise',
                'targetSets': 3,
                'targetRepsMin': 12,
                'targetRepsMax': 15,
                'restSeconds': 120
              },
              {
                'exerciseId': 'ex_hanging_leg_raise',
                'targetSets': 2,
                'targetRepsMin': 10,
                'targetRepsMax': 12,
                'restSeconds': 90
              },
            ],
          },
        ],
      };
    }
  }

  /// Analyzes training logs for stalls and fatigue to generate discrete proposals
  List<PlanProposalAction> evaluateTrainingLogs({
    required Map<String, int> consecutiveStallsByExercise,
    required Map<String, double> averageRpeByExercise,
    required List<GymMuscleGroup> neglectedMuscles,
  }) {
    final proposals = <PlanProposalAction>[];

    // Check for stalls >= 3
    consecutiveStallsByExercise.forEach((exerciseId, stalls) {
      if (stalls >= 3) {
        proposals.add(
          PlanProposalAction(
            id: 'deload_$exerciseId',
            type: ProposalActionType.deload,
            title: '10 % Deload empfohlen',
            explanation:
                'Du hast bei dieser Übung 3 Einheiten in Folge das Rep-Ziel verfehlt. Ein Deload um 10% durchbricht das Plateau und fördert die Erholung.',
            exerciseId: exerciseId,
            adjustmentValue: -10.0,
          ),
        );
      }
    });

    // Check for chronic excessive fatigue (RPE >= 9.8 across multiple sessions)
    averageRpeByExercise.forEach((exerciseId, avgRpe) {
      if (avgRpe >= 9.8 && !proposals.any((p) => p.exerciseId == exerciseId)) {
        proposals.add(
          PlanProposalAction(
            id: 'volume_$exerciseId',
            type: ProposalActionType.adjustVolume,
            title: 'Satz-Volumen reduzieren (-1 Satz)',
            explanation:
                'Der durchschnittliche RPE liegt bei ${avgRpe.toStringAsFixed(1)}. Reduziere um 1 Arbeitssatz, um Überlastung des ZNS zu vermeiden.',
            exerciseId: exerciseId,
            adjustmentValue: -1.0,
          ),
        );
      }
    });

    return proposals;
  }

  String _extractJson(String text) {
    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return text.substring(startIndex, endIndex + 1);
    }
    return text;
  }
}
