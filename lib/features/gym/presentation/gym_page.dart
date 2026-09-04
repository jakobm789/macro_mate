import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ui/design_system.dart';
import '../../../models/app_state.dart';
import '../data/drift_gym_repository.dart';
import '../data/open_gym_json_service.dart';
import 'ai_coach_sheet.dart';
import 'exercise_library_page.dart';
import 'gym_controller.dart';
import 'manual_plan_editor_page.dart';
import 'widgets/activity_heatmap_widget.dart';
import 'widgets/muscle_map_widget.dart';
import 'workout_runner_page.dart';

class GymPage extends StatefulWidget {
  const GymPage({super.key});

  @override
  State<GymPage> createState() => _GymPageState();
}

class _GymPageState extends State<GymPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GymController>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GymController>();
    final theme = Theme.of(context);

    if (controller.isLoading && controller.exercises.isEmpty) {
      return const Scaffold(body: LoadingState());
    }

    final activePlan = controller.activePlan;
    final todayWeekday = DateTime.now().weekday; // 1 (Mon) .. 7 (Sun)

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kraftsport & Gym'),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'AI Coach',
            onPressed: () => _openAiCoach(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'create_manual') {
                _openManualPlanEditor(context);
              } else if (val == 'export') {
                _exportActivePlan(context, controller);
              } else if (val == 'import') {
                _importPlanDialog(context, controller);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'create_manual',
                child: Row(
                  children: [
                    Icon(Icons.edit_note, size: 18),
                    SizedBox(width: 8),
                    Text('Plan manuell erstellen'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_upload_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Plan exportieren (JSON)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_download_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Plan importieren (JSON)'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aktualisieren',
            onPressed: controller.loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Active Workout Banner if one is running
            if (controller.isWorkoutActive) ...[
              Card(
                color: Colors.deepOrangeAccent.shade100.withValues(alpha: 0.3),
                child: ListTile(
                  leading: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.deepOrangeAccent,
                  ),
                  title: Text(
                    'Laufendes Training: ${controller.activeRoutine?.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Tippe hier, um zur aktiven Einheit zurückzukehren.',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        tooltip: 'Training abbrechen',
                        onPressed: () =>
                            _confirmCancelActiveWorkout(context, controller),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WorkoutRunnerPage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Active Plan Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activePlan?.name ??
                                    'Kein aktiver Trainingsplan',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (activePlan?.description != null)
                                Text(
                                  activePlan!.description!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.edit_note, size: 16),
                              label: const Text('Plan erstellen'),
                              onPressed: () => _openManualPlanEditor(context),
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.auto_awesome, size: 16),
                              label: const Text('AI Coach'),
                              onPressed: () => _openAiCoach(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (controller.routines.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Einheiten des Plans (${controller.routines.length})',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final routine in controller.routines) ...[
                        _buildRoutineCard(
                          context,
                          routine,
                          controller,
                          todayWeekday,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ] else if (activePlan == null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.edit_note),
                              label: const Text('Plan manuell erstellen'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrangeAccent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => _openManualPlanEditor(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Mit AI generieren'),
                              onPressed: () => _openAiCoach(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Muscle Map
            MuscleMapWidget(
              muscleTonnage: controller.muscleTonnage,
              neglectedMuscles: controller.neglectedMuscles,
            ),
            const SizedBox(height: 16),

            // Exercise Library Button
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Übungskatalog & 1RM-Rechner'),
                subtitle: Text(
                  '${controller.exercises.length} Übungen mit Muskelgruppen & Equipment',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExerciseLibraryPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Activity Heatmap (GitHub-Style)
            ActivityHeatmapWidget(
              workoutSessions: controller.recentSessions,
              weeksToShow: 18,
            ),
            const SizedBox(height: 16),

            // Recent Sessions
            const SectionHeader(title: 'Letzte Workouts'),
            const SizedBox(height: 8),
            if (controller.recentSessions.isEmpty)
              const EmptyState(
                title: 'Noch keine Gym-Einheiten',
                message:
                    'Starte dein erstes Workout oben, um deine Sätze und Gewichte zu tracken.',
              )
            else
              for (final session in controller.recentSessions) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(session.routineName),
                    subtitle: Text(
                      '${session.startUtc.split('T').first} · ${(session.durationSeconds / 60).round()} min'
                      '${session.totalTonnageKg > 0 ? ' · ${(session.totalTonnageKg / 1000).toStringAsFixed(1)}t Tonnage' : ''}'
                      '${session.rpeAverage != null ? ' · RPE ${session.rpeAverage!.toStringAsFixed(1)}' : ''}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                      ),
                      tooltip: 'Workout löschen',
                      onPressed: () => _confirmDeleteWorkoutSession(
                        context,
                        controller,
                        session,
                      ),
                    ),
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancelActiveWorkout(
    BuildContext context,
    GymController controller,
  ) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Training abbrechen?'),
        content: const Text(
          'Möchtest du das laufende Training wirklich ohne Speichern abbrechen? Alle nicht gespeicherten Sätze werden verworfen.',
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Training abgebrochen und verworfen.')),
        );
      }
    }
  }

  Future<void> _confirmDeleteWorkoutSession(
    BuildContext context,
    GymController controller,
    GymWorkoutSessionRow session,
  ) async {
    final dateStr = session.startUtc.split('T').first;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Workout löschen?'),
        content: Text(
          'Möchtest du dieses Workout ("${session.routineName}" vom $dateStr) wirklich unwiderruflich löschen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteWorkoutSession(session.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout erfolgreich gelöscht.')),
        );
      }
    }
  }

  void _openManualPlanEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<GymController>(),
          child: const ManualPlanEditorPage(),
        ),
      ),
    );
  }

  Widget _buildRoutineCard(
    BuildContext context,
    GymPlanRoutineRow routine,
    GymController controller,
    int todayWeekday,
  ) {
    final theme = Theme.of(context);
    final isToday = routine.dayOfWeek == todayWeekday;
    final exercises = controller.routineExercises[routine.id] ?? [];
    final totalSets = exercises.fold<int>(0, (sum, ex) => sum + ex.targetSets);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: Colors.deepOrangeAccent.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.fitness_center,
            color: isToday ? Colors.deepOrangeAccent : theme.hintColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        routine.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrangeAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HEUTE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${exercises.length} Übungen · $totalSets Sätze geplant',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isToday ? Colors.deepOrangeAccent : null,
              foregroundColor: isToday ? Colors.white : null,
            ),
            onPressed: () async {
              await controller.startWorkout(
                routine: routine,
                exercises: exercises,
              );
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutRunnerPage()),
                );
              }
            },
            child: const Text('Starten'),
          ),
        ],
      ),
    );
  }

  void _openAiCoach(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GymController>(),
        child: const AiCoachSheet(),
      ),
    );
  }

  AppDatabase _getDatabase(BuildContext context) {
    try {
      return context.read<AppDatabase>();
    } catch (_) {
      final appState = context.read<AppState?>();
      if (appState != null) return appState.database;
      return AppDatabase();
    }
  }

  Future<void> _exportActivePlan(
    BuildContext context,
    GymController controller,
  ) async {
    final activePlan = controller.activePlan;
    if (activePlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kein aktiver Trainingsplan zum Exportieren vorhanden.',
          ),
        ),
      );
      return;
    }

    try {
      final db = _getDatabase(context);
      final repo = DriftGymRepository(database: db);
      final jsonService = OpenGymJsonService(repository: repo);
      final jsonString = await jsonService.exportPlanToJson(activePlan.id);

      await Share.share(
        jsonString,
        subject: 'OpenGym Trainingsplan: ${activePlan.name}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export fehlgeschlagen: $e')));
      }
    }
  }

  void _importPlanDialog(BuildContext context, GymController controller) {
    final jsonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trainingsplan importieren'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Füge den Inhalt einer OpenGym-kompatiblen JSON-Datei ein:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: jsonCtrl,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '{\n  "name": "Mein Plan",\n  "routines": [...]\n}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = jsonCtrl.text.trim();
              if (text.isEmpty) return;

              try {
                final db = _getDatabase(context);
                final repo = DriftGymRepository(database: db);
                final jsonService = OpenGymJsonService(repository: repo);
                await jsonService.importPlanFromJson(text);
                await controller.loadData();
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Plan erfolgreich importiert und aktiviert!',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fehler beim Import: $e')),
                  );
                }
              }
            },
            child: const Text('Importieren'),
          ),
        ],
      ),
    );
  }
}
