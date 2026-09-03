import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ui/design_system.dart';
import '../data/drift_gym_repository.dart';
import '../data/open_gym_json_service.dart';
import 'ai_coach_sheet.dart';
import 'exercise_library_page.dart';
import 'gym_controller.dart';
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
    final todayRoutine = controller.routines.where((r) => r.dayOfWeek == todayWeekday).firstOrNull ??
        controller.routines.firstOrNull;

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
              if (val == 'export') {
                _exportActivePlan(context, controller);
              } else if (val == 'import') {
                _importPlanDialog(context, controller);
              }
            },
            itemBuilder: (ctx) => [
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
                  leading: const Icon(Icons.play_circle_fill, color: Colors.deepOrangeAccent),
                  title: Text(
                    'Laufendes Training: ${controller.activeRoutine?.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Tippe hier, um zur aktiven Einheit zurückzukehren.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WorkoutRunnerPage()),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activePlan?.name ?? 'Kein aktiver Trainingsplan',
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
                        OutlinedButton.icon(
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('AI Coach'),
                          onPressed: () => _openAiCoach(context),
                        ),
                      ],
                    ),
                    if (todayRoutine != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.fitness_center, color: Colors.deepOrangeAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Heutige Einheit: ${todayRoutine.name}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${controller.routineExercises[todayRoutine.id]?.length ?? 0} Übungen geplant',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrangeAccent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final exercises =
                                    controller.routineExercises[todayRoutine.id] ?? [];
                                await controller.startWorkout(
                                  routine: todayRoutine,
                                  exercises: exercises,
                                );
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const WorkoutRunnerPage(),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Starten'),
                            ),
                          ],
                        ),
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
                subtitle: Text('${controller.exercises.length} Übungen mit Muskelgruppen & Equipment'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExerciseLibraryPage()),
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
                message: 'Starte dein erstes Workout oben, um deine Sätze und Gewichte zu tracken.',
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
                  ),
                ),
              ],
          ],
        ),
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

  Future<void> _exportActivePlan(BuildContext context, GymController controller) async {
    final activePlan = controller.activePlan;
    if (activePlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein aktiver Trainingsplan zum Exportieren vorhanden.')),
      );
      return;
    }

    try {
      final db = context.read<AppDatabase>();
      final repo = DriftGymRepository(database: db);
      final jsonService = OpenGymJsonService(repository: repo);
      final jsonString = await jsonService.exportPlanToJson(activePlan.id);

      await Share.share(jsonString, subject: 'OpenGym Trainingsplan: ${activePlan.name}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export fehlgeschlagen: $e')),
        );
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
            const Text('Füge den Inhalt einer OpenGym-kompatiblen JSON-Datei ein:'),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              final text = jsonCtrl.text.trim();
              if (text.isEmpty) return;

              try {
                final db = context.read<AppDatabase>();
                final repo = DriftGymRepository(database: db);
                final jsonService = OpenGymJsonService(repository: repo);
                await jsonService.importPlanFromJson(text);
                await controller.loadData();
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan erfolgreich importiert und aktiviert!')),
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
