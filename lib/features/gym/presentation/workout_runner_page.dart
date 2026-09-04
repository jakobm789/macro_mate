import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/gym_models.dart';
import 'gym_controller.dart';

class WorkoutRunnerPage extends StatelessWidget {
  const WorkoutRunnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GymController>();
    final theme = Theme.of(context);

    if (!controller.isWorkoutActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout beendet')),
        body: const Center(child: Text('Keine aktive Trainingseinheit.')),
      );
    }

    final setsByExercise = <String, List<MapEntry<int, GymSetLog>>>{};
    for (var i = 0; i < controller.activeSets.length; i++) {
      final s = controller.activeSets[i];
      setsByExercise.putIfAbsent(s.exerciseId, () => []).add(MapEntry(i, s));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmCancel(context, controller);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Training abbrechen',
            onPressed: () => _confirmCancel(context, controller),
          ),
          title: Text(controller.activeRoutine?.name ?? 'Training'),
          actions: [
            PopupMenuButton<int>(
              tooltip: 'Standard-Pause anpassen',
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: Colors.deepOrangeAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(controller.defaultRestSeconds / 60).toStringAsFixed(1).replaceAll('.0', '')} min',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              onSelected: (sec) {
                controller.setDefaultRestSeconds(sec);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(
                      'Standard-Pausenzeit auf ${(sec / 60).toStringAsFixed(1).replaceAll('.0', '')} Minuten gesetzt.',
                    ),
                  ),
                );
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 60, child: Text('1:00 min (60s)')),
                PopupMenuItem(value: 90, child: Text('1:30 min (90s)')),
                PopupMenuItem(value: 120, child: Text('2:00 min (120s)')),
                PopupMenuItem(value: 150, child: Text('2:30 min (150s)')),
                PopupMenuItem(
                  value: 180,
                  child: Text('3:00 min (180s - Standard)'),
                ),
                PopupMenuItem(value: 240, child: Text('4:00 min (240s)')),
                PopupMenuItem(value: 300, child: Text('5:00 min (300s)')),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
              label: const Text(
                'Abbrechen',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => _confirmCancel(context, controller),
            ),
            TextButton.icon(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              label: const Text(
                'Abschließen',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => _confirmFinish(context, controller),
            ),
          ],
        ),
        body: Column(
          children: [
            // Rest Timer Banner
            if (controller.isRestTimerRunning)
              Container(
                color: theme.colorScheme.primaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Text(
                      'Pause: ${(controller.restTimerSecondsRemaining ~/ 60)}:${(controller.restTimerSecondsRemaining % 60).toString().padLeft(2, '0')} min',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const Spacer(),
                    if (controller.restTimerSecondsRemaining > 30)
                      TextButton(
                        onPressed: () => controller.startRestTimer(
                          controller.restTimerSecondsRemaining - 30,
                        ),
                        child: const Text('-30s'),
                      ),
                    TextButton(
                      onPressed: () => controller.startRestTimer(
                        controller.restTimerSecondsRemaining + 30,
                      ),
                      child: const Text('+30s'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Pause überspringen',
                      onPressed: controller.stopRestTimer,
                    ),
                  ],
                ),
              ),
            // Sets list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final entry in setsByExercise.entries) ...[
                    _ExerciseSectionCard(
                      exerciseId: entry.key,
                      setEntries: entry.value,
                      controller: controller,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    GymController controller,
  ) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Training abbrechen?'),
        content: const Text(
          'Möchtest du dieses Training wirklich ohne Speichern abbrechen? Alle nicht gespeicherten Sätze werden verworfen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Weiter trainieren'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ja, abbrechen'),
          ),
        ],
      ),
    );

    if (discard == true) {
      controller.cancelWorkout();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _confirmFinish(BuildContext context, GymController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Workout abschließen?'),
        content: const Text(
          'Möchtest du dieses Workout speichern und deine Trainingsstatistiken aktualisieren?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await controller.finishWorkout();
              if (context.mounted) {
                Navigator.pop(context); // Exit runner page
                _showSummaryModal(context, result);
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _showSummaryModal(BuildContext context, dynamic result) {
    if (result == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final tonnage = result.totalTonnageKg as double;
        final minutes = ((result.durationSeconds as double) / 60).round();
        final prs = (result.newPrs as List<dynamic>);

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 56, color: Colors.amber),
              const SizedBox(height: 12),
              Text(
                'Klasse Leistung!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dein Workout wurde erfolgreich protokolliert.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SummaryStat(
                    title: 'Dauer',
                    value: '$minutes min',
                    icon: Icons.timer_outlined,
                  ),
                  _SummaryStat(
                    title: 'Tonnage',
                    value: tonnage >= 1000
                        ? '${(tonnage / 1000).toStringAsFixed(1)} t'
                        : '${tonnage.round()} kg',
                    icon: Icons.fitness_center,
                  ),
                ],
              ),
              if (prs.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.deepOrange,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Neuer persönlicher Rekord (PR)!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      for (final pr in prs)
                        Text(
                          '${pr.weightKg} kg × ${pr.reps} Wdh (1RM: ${pr.estimated1Rm} kg)',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Fertig'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.title,
    required this.value,
    required this.icon,
  });
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.deepOrangeAccent),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          title,
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
        ),
      ],
    );
  }
}

class _ExerciseSectionCard extends StatelessWidget {
  const _ExerciseSectionCard({
    required this.exerciseId,
    required this.setEntries,
    required this.controller,
  });

  final String exerciseId;
  final List<MapEntry<int, GymSetLog>> setEntries;
  final GymController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = controller.exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => GymExercise(
        id: exerciseId,
        name: exerciseId,
        primaryMuscle: GymMuscleGroup.fullBody,
        equipment: GymEquipment.other,
      ),
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${exercise.primaryMuscle.displayName} · ${exercise.equipment.displayName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Übung wechseln',
                  onPressed: controller.hasIncompleteSetsForExercise(exerciseId)
                      ? () => _showExerciseSwitchSheet(context, exercise)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Satz hinzufügen',
                  onPressed: () => controller.addSetToExercise(exerciseId),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: const [
                SizedBox(
                  width: 42,
                  child: Text(
                    'Typ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Gewicht (kg)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Wdh / Zeit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    'RPE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                SizedBox(width: 40, child: Icon(Icons.check, size: 16)),
              ],
            ),
            const SizedBox(height: 6),
            for (var i = 0; i < setEntries.length; i++) ...[
              _SetRowItem(
                setIndexInExercise: i + 1,
                globalIndex: setEntries[i].key,
                setLog: setEntries[i].value,
                isTimed: exercise.isTimed,
                controller: controller,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showExerciseSwitchSheet(
    BuildContext context,
    GymExercise currentExercise,
  ) {
    final candidates = controller.exercises
        .where((exercise) => exercise.id != currentExercise.id)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.7,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'Übung wechseln',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Offene Sätze von ${currentExercise.name} werden ersetzt. '
                  'Bereits abgeschlossene Sätze bleiben erhalten.',
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: candidates.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final candidate = candidates[index];
                    return ListTile(
                      leading: Icon(
                        candidate.primaryMuscle == currentExercise.primaryMuscle
                            ? Icons.recommend
                            : Icons.fitness_center,
                      ),
                      title: Text(candidate.name),
                      subtitle: Text(
                        '${candidate.primaryMuscle.displayName} · '
                        '${candidate.equipment.displayName}',
                      ),
                      onTap: () {
                        final changed = controller.switchExerciseInActiveWorkout(
                          exerciseId,
                          candidate.id,
                        );
                        Navigator.pop(sheetContext);
                        if (changed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${currentExercise.name} wurde für die offenen '
                                'Sätze durch ${candidate.name} ersetzt.',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetRowItem extends StatelessWidget {
  const _SetRowItem({
    required this.setIndexInExercise,
    required this.globalIndex,
    required this.setLog,
    required this.isTimed,
    required this.controller,
  });

  final int setIndexInExercise;
  final int globalIndex;
  final GymSetLog setLog;
  final bool isTimed;
  final GymController controller;

  Color _typeBadgeColor(GymSetType type) {
    return switch (type) {
      GymSetType.warmup => Colors.amber.shade700,
      GymSetType.drop => Colors.purple,
      GymSetType.failure => Colors.red,
      _ => Colors.blueGrey,
    };
  }

  String _typeBadgeLabel(GymSetType type, int index) {
    return switch (type) {
      GymSetType.warmup => 'W',
      GymSetType.drop => 'D',
      GymSetType.failure => 'F',
      _ => '$index',
    };
  }

  void _cycleSetType() {
    final nextType = switch (setLog.setType) {
      GymSetType.normal => GymSetType.warmup,
      GymSetType.warmup => GymSetType.drop,
      GymSetType.drop => GymSetType.failure,
      GymSetType.failure => GymSetType.normal,
    };
    controller.updateSet(globalIndex, setType: nextType);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Set Type Badge
          InkWell(
            onTap: _cycleSetType,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _typeBadgeColor(setLog.setType).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _typeBadgeColor(setLog.setType)),
              ),
              child: Text(
                _typeBadgeLabel(setLog.setType, setIndexInExercise),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _typeBadgeColor(setLog.setType),
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              initialValue: setLog.weightKg > 0 ? '${setLog.weightKg}' : '0',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                final d = double.tryParse(val);
                if (d != null) {
                  controller.updateSet(globalIndex, weightKg: d);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: isTimed
                  ? '${setLog.holdSeconds ?? 60}'
                  : '${setLog.reps ?? 8}',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: const OutlineInputBorder(),
                suffixText: isTimed ? 's' : null,
              ),
              onChanged: (val) {
                final num = int.tryParse(val);
                if (num != null) {
                  if (isTimed) {
                    controller.updateSet(globalIndex, holdSeconds: num);
                  } else {
                    controller.updateSet(globalIndex, reps: num);
                  }
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: TextFormField(
              initialValue: setLog.rpe != null ? '${setLog.rpe}' : '',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: '8',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 8,
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                final rpe = double.tryParse(val);
                controller.updateSet(globalIndex, rpe: rpe);
              },
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 40,
            child: Checkbox(
              value: setLog.completed,
              activeColor: Colors.green,
              onChanged: (checked) {
                controller.toggleSetCompleted(globalIndex, checked ?? false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
