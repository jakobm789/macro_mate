import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/ai_coach_engine.dart';
import '../domain/gym_models.dart';
import 'gym_controller.dart';

class AiCoachSheet extends StatefulWidget {
  const AiCoachSheet({super.key});

  @override
  State<AiCoachSheet> createState() => _AiCoachSheetState();
}

class _AiCoachSheetState extends State<AiCoachSheet> {
  int _daysPerWeek = 3;
  String _goal = 'hypertrophy';
  final String _experience = 'intermediate';
  final Set<GymEquipment> _equipment = {
    GymEquipment.barbell,
    GymEquipment.dumbbell,
    GymEquipment.cable,
    GymEquipment.bodyweight,
  };

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GymController>();
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.smart_toy_outlined, color: Colors.deepOrangeAccent),
                SizedBox(width: 8),
                Text('AI Coach'),
              ],
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Active Proposals
              if (controller.aiProposals.isNotEmpty) ...[
                Text(
                  'Empfehlungen & Plan-Reviews',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                for (final p in controller.aiProposals)
                  Card(
                    color: theme.colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  p.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(p.explanation),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Empfehlung zur Kenntnis genommen.')),
                                  );
                                },
                                child: const Text('Später'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await controller.applyProposal(p);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Vorschlag "${p.title}" wurde auf deinen Plan angewendet!')),
                                    );
                                  }
                                },
                                child: const Text('Anwenden'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
              ],

              // Intake generator
              Text(
                'Neuen Trainingsplan generieren (Intake)',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Lass dir einen maßgeschneiderten Plan mit evidenzbasierter Progression erstellen.',
                style:
                    theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 16),

              // Goal
              Text('Trainingsziel', style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'hypertrophy', label: Text('Muskelaufbau')),
                  ButtonSegment(value: 'strength', label: Text('Kraft')),
                  ButtonSegment(
                      value: 'general_fitness', label: Text('Fitness')),
                ],
                selected: {_goal},
                onSelectionChanged: (val) => setState(() => _goal = val.first),
              ),
              const SizedBox(height: 16),

              // Days per week
              Text('Trainingstage pro Woche: $_daysPerWeek Tage',
                  style: theme.textTheme.labelLarge),
              Slider(
                value: _daysPerWeek.toDouble(),
                min: 2,
                max: 5,
                divisions: 3,
                label: '$_daysPerWeek Tage',
                onChanged: (v) => setState(() => _daysPerWeek = v.round()),
              ),
              const SizedBox(height: 12),

              // Equipment
              Text('Verfügbares Equipment', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  GymEquipment.barbell,
                  GymEquipment.dumbbell,
                  GymEquipment.cable,
                  GymEquipment.machine,
                  GymEquipment.bodyweight,
                ].map((eq) {
                  final isSelected = _equipment.contains(eq);
                  return FilterChip(
                    label: Text(eq.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _equipment.add(eq);
                        } else {
                          _equipment.remove(eq);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.bolt),
                label: const Text('Trainingsplan jetzt erstellen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final profile = GymIntakeProfile(
                    goal: _goal,
                    experience: _experience,
                    daysPerWeek: _daysPerWeek,
                    equipment: _equipment.toList(),
                  );
                  await controller.createPlanFromIntake(profile);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Plan "${controller.activePlan?.name}" erfolgreich erstellt!')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
