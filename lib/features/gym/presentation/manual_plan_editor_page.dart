import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/app_database.dart';
import '../domain/gym_models.dart';
import 'gym_controller.dart';

class ManualPlanEditorPage extends StatefulWidget {
  const ManualPlanEditorPage({
    super.key,
    this.plan,
    this.routines = const [],
    this.routineExercises = const {},
  });

  final GymWorkoutPlanRow? plan;
  final List<GymPlanRoutineRow> routines;
  final Map<String, List<GymPlanRoutineExerciseRow>> routineExercises;

  bool get isEditing => plan != null;

  @override
  State<ManualPlanEditorPage> createState() => _ManualPlanEditorPageState();
}

class _DraftExercise {
  _DraftExercise({
    required this.exercise,
    this.targetSets = 4,
    this.targetRepsMin = 8,
    this.targetRepsMax = 12,
    this.restSeconds = 180,
  });

  final GymExercise exercise;
  int targetSets;
  int targetRepsMin;
  int targetRepsMax;
  int restSeconds;

  Map<String, dynamic> toMap() => {
        'exerciseId': exercise.id,
        'targetSets': targetSets,
        'targetRepsMin': targetRepsMin,
        'targetRepsMax': targetRepsMax,
        'restSeconds': restSeconds,
      };
}

class _DraftRoutine {
  _DraftRoutine({
    this.id,
    required this.name,
    required this.dayOfWeek,
    List<_DraftExercise>? exercises,
  }) : exercises = exercises ?? [];

  final String? id;
  String name;
  int dayOfWeek;
  final List<_DraftExercise> exercises;

  int get totalSets => exercises.fold<int>(0, (sum, ex) => sum + ex.targetSets);

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'name': name,
      'dayOfWeek': dayOfWeek,
      'progressionType': 'linear',
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
    if (id != null) data['id'] = id;
    return data;
  }
}

class _ManualPlanEditorPageState extends State<ManualPlanEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late int _daysPerWeek;
  final List<_DraftRoutine> _routines = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.plan?.name ?? 'Mein Trainingsplan',
    );
    _descriptionController = TextEditingController(
      text: widget.plan?.description ?? '',
    );
    _daysPerWeek = widget.plan?.daysPerWeek ?? 3;

    if (widget.isEditing) {
      final exercisesById = {
        for (final exercise in context.read<GymController>().exercises)
          exercise.id: exercise,
      };
      for (final routine in widget.routines) {
        final plannedExercises =
            widget.routineExercises[routine.id] ??
            const <GymPlanRoutineExerciseRow>[];
        _routines.add(
          _DraftRoutine(
            id: routine.id,
            name: routine.name,
            dayOfWeek: routine.dayOfWeek,
            exercises: [
              for (final planned in plannedExercises)
                if (exercisesById[planned.exerciseId] case final exercise?)
                  _DraftExercise(
                    exercise: exercise,
                    targetSets: planned.targetSets,
                    targetRepsMin: planned.targetRepsMin,
                    targetRepsMax: planned.targetRepsMax,
                    restSeconds: planned.restSeconds,
                  ),
            ],
          ),
        );
      }
    } else {
      _routines.addAll([
        _DraftRoutine(name: 'Tag 1: Push / Brust & Schultern', dayOfWeek: 1),
        _DraftRoutine(name: 'Tag 2: Pull / Rücken & Bizeps', dayOfWeek: 3),
        _DraftRoutine(name: 'Tag 3: Beine & Bauch', dayOfWeek: 5),
      ]);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addRoutine() {
    setState(() {
      final nextIndex = _routines.length + 1;
      _routines.add(
        _DraftRoutine(
          name: 'Einheit $nextIndex',
          dayOfWeek: ((nextIndex - 1) % 7) + 1,
        ),
      );
      if (_routines.length > _daysPerWeek) {
        _daysPerWeek = _routines.length.clamp(1, 7);
      }
    });
  }

  void _removeRoutine(int index) {
    if (_routines.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ein Plan muss mindestens eine Einheit enthalten.'),
        ),
      );
      return;
    }
    setState(() {
      _routines.removeAt(index);
    });
  }

  Future<void> _pickExerciseForRoutine(
    BuildContext context,
    _DraftRoutine routine,
    GymController controller,
  ) async {
    final selected = await showModalBottomSheet<GymExercise>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ExercisePickerSheet(exercises: controller.exercises),
    );

    if (selected != null) {
      setState(() {
        routine.exercises.add(_DraftExercise(exercise: selected));
      });
    }
  }

  Future<void> _savePlan(GymController controller) async {
    if (!_formKey.currentState!.validate()) return;

    if (_routines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Füge mindestens eine Routine hinzu.')),
      );
      return;
    }

    final emptyRoutine = _routines.firstWhere(
      (r) => r.exercises.isEmpty,
      orElse: () => _DraftRoutine(name: '', dayOfWeek: 0),
    );

    if (emptyRoutine.name.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Die Routine "${emptyRoutine.name}" hat noch keine Übungen.',
          ),
        ),
      );
      return;
    }

    final routinesPayload = _routines.map((r) => r.toMap()).toList();

    if (widget.isEditing) {
      await controller.updateManualPlan(
        planId: widget.plan!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        daysPerWeek: _daysPerWeek,
        routinesWithExercises: routinesPayload,
      );
    } else {
      await controller.saveManualPlan(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        daysPerWeek: _daysPerWeek,
        routinesWithExercises: routinesPayload,
        isActive: true,
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Plan "' + _nameController.text.trim() + '" wurde aktualisiert.'
                : 'Plan "' + _nameController.text.trim() + '" erfolgreich erstellt und aktiviert!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GymController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Trainingsplan bearbeiten' : 'Neuer Trainingsplan',
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, color: Colors.green),
            label: const Text(
              'Speichern',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => _savePlan(controller),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Plan Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan-Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name des Plans *',
                        hintText: 'z.B. Mein 4er-Split',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Bitte gib einen Namen ein'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Beschreibung (optional)',
                        hintText: 'z.B. Fokus auf Hypertrophie und Beine',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tage pro Woche: $_daysPerWeek',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<int>(
                          value: _daysPerWeek,
                          items: [1, 2, 3, 4, 5, 6, 7]
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text('$d Tage'),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _daysPerWeek = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Routines Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Einheiten / Tage (${_routines.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Einheit hinzufügen'),
                  onPressed: _addRoutine,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Routines List
            for (var rIdx = 0; rIdx < _routines.length; rIdx++) ...[
              _buildRoutineCard(context, rIdx, _routines[rIdx], controller),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                widget.isEditing
                    ? 'Änderungen speichern'
                    : 'Trainingsplan speichern & aktivieren',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _savePlan(controller),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(
    BuildContext context,
    int index,
    _DraftRoutine routine,
    GymController controller,
  ) {
    final theme = Theme.of(context);

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
                  child: TextFormField(
                    initialValue: routine.name,
                    decoration: const InputDecoration(
                      labelText: 'Name der Einheit',
                      isDense: true,
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (val) => routine.name = val.trim(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Einheit entfernen',
                  onPressed: () => _removeRoutine(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${routine.exercises.length} Übungen · ${routine.totalSets} Sätze gesamt',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: routine.totalSets == 16
                        ? Colors.green
                        : Colors.deepOrange,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Übung hinzufügen'),
                  onPressed: () =>
                      _pickExerciseForRoutine(context, routine, controller),
                ),
              ],
            ),
            if (routine.exercises.isNotEmpty) const Divider(),
            for (var eIdx = 0; eIdx < routine.exercises.length; eIdx++) ...[
              _buildExerciseRow(routine, eIdx, routine.exercises[eIdx]),
              if (eIdx < routine.exercises.length - 1)
                const Divider(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseRow(
    _DraftRoutine routine,
    int index,
    _DraftExercise draftEx,
  ) {
    final theme = Theme.of(context);
    final restMinutes =
        (draftEx.restSeconds / 60).toStringAsFixed(1).replaceAll('.0', '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                      draftEx.exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${draftEx.exercise.primaryMuscle.displayName} · ${draftEx.exercise.equipment.displayName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                tooltip: 'Entfernen',
                onPressed: () {
                  setState(() {
                    routine.exercises.removeAt(index);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Sets stepper
              const Text('Sätze: '),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: draftEx.targetSets > 1
                    ? () => setState(() => draftEx.targetSets--)
                    : null,
              ),
              Text(
                '${draftEx.targetSets}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => setState(() => draftEx.targetSets++),
              ),
              const Spacer(),
              // Rest time selector (Standard 180s / 3 min)
              PopupMenuButton<int>(
                initialValue: draftEx.restSeconds,
                tooltip: 'Pausenzeit einstellen',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pause: $restMinutes min',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 16),
                    ],
                  ),
                ),
                onSelected: (sec) {
                  setState(() => draftEx.restSeconds = sec);
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
            ],
          ),
        ],
      ),
    );
  }
}

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet({required this.exercises});

  final List<GymExercise> exercises;

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  String _searchQuery = '';
  GymMuscleGroup? _selectedGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filtered = widget.exercises.where((e) {
      if (_selectedGroup != null && e.primaryMuscle != _selectedGroup) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !e.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Übung auswählen',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Übung suchen (z.B. Bankdrücken, Kniebeugen)...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Alle'),
                        selected: _selectedGroup == null,
                        onSelected: (_) =>
                            setState(() => _selectedGroup = null),
                      ),
                      const SizedBox(width: 6),
                      for (final group in GymMuscleGroup.values) ...[
                        FilterChip(
                          label: Text(group.displayName),
                          selected: _selectedGroup == group,
                          onSelected: (sel) => setState(
                            () => _selectedGroup = sel ? group : null,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Keine Übungen gefunden.'))
                : ListView.builder(
                    controller: scrollCtrl,
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final ex = filtered[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepOrangeAccent.shade100,
                          foregroundColor: Colors.deepOrange,
                          child: const Icon(Icons.fitness_center, size: 20),
                        ),
                        title: Text(ex.name),
                        subtitle: Text(
                          '${ex.primaryMuscle.displayName} · ${ex.equipment.displayName}',
                        ),
                        trailing: const Icon(Icons.add),
                        onTap: () => Navigator.pop(context, ex),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
