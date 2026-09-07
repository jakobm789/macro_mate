import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/app_database.dart';
import '../domain/gym_models.dart';
import 'gym_controller.dart';

class CompletedWorkoutEditorPage extends StatefulWidget {
  const CompletedWorkoutEditorPage({super.key, required this.session});

  final GymWorkoutSessionRow session;

  @override
  State<CompletedWorkoutEditorPage> createState() =>
      _CompletedWorkoutEditorPageState();
}

class _CompletedWorkoutEditorPageState
    extends State<CompletedWorkoutEditorPage> {
  List<GymSetLog>? _sets;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    final sets =
        await context.read<GymController>().getWorkoutSets(widget.session.id);
    if (mounted) setState(() => _sets = sets);
  }

  void _update(int index, GymSetLog set) {
    setState(() => _sets![index] = set);
  }

  Future<void> _save() async {
    final sets = _sets;
    if (sets == null) return;
    setState(() => _saving = true);
    await context.read<GymController>().updateCompletedWorkout(
      widget.session,
      sets,
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout wurde aktualisiert.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sets = _sets;
    if (sets == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final controller = context.watch<GymController>();
    final exercises = {
      for (final exercise in controller.exercises) exercise.id: exercise,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout bearbeiten'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Speichern'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sets.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final set = sets[index];
          final exercise = exercises[set.exerciseId];
          final isTimed = exercise?.isTimed ?? false;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise?.name ?? set.exerciseId,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: set.weightKg.toString(),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Gewicht (kg)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final weight = double.tryParse(value);
                            if (weight != null) {
                              _update(index, set.copyWith(weightKg: weight));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue:
                              (isTimed ? set.holdSeconds : set.reps)?.toString() ??
                                  '',
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: isTimed ? 'Zeit (Sek.)' : 'Wiederholungen',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final count = int.tryParse(value);
                            if (count == null) return;
                            _update(
                              index,
                              isTimed
                                  ? set.copyWith(holdSeconds: count)
                                  : set.copyWith(reps: count),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: TextFormField(
                          initialValue: set.rpe?.toString() ?? '',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'RPE',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _update(
                              index,
                              set.copyWith(rpe: double.tryParse(value)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Absolviert'),
                          value: set.completed,
                          onChanged: (value) => _update(
                            index,
                            set.copyWith(completed: value ?? false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
