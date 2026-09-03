import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/gym_models.dart';
import '../domain/progression_engine.dart';
import 'gym_controller.dart';

class ExerciseLibraryPage extends StatefulWidget {
  const ExerciseLibraryPage({super.key});

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  String _searchQuery = '';
  GymMuscleGroup? _selectedMuscle;
  GymEquipment? _selectedEquipment;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GymController>();
    final theme = Theme.of(context);

    var filtered = controller.exercises.where((e) {
      if (_searchQuery.isNotEmpty &&
          !e.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedMuscle != null && e.primaryMuscle != _selectedMuscle) {
        return false;
      }
      if (_selectedEquipment != null && e.equipment != _selectedEquipment) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Übungskatalog'),
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Übung suchen...',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          // Filter Chips (Muscles & Equipment)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('Alle Muskeln'),
                  selected: _selectedMuscle == null,
                  onSelected: (_) => setState(() => _selectedMuscle = null),
                ),
                const SizedBox(width: 6),
                for (final m in GymMuscleGroup.values) ...[
                  if (m != GymMuscleGroup.fullBody) ...[
                    FilterChip(
                      label: Text(m.displayName),
                      selected: _selectedMuscle == m,
                      onSelected: (sel) => setState(() => _selectedMuscle = sel ? m : null),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('Jedes Equipment'),
                  selected: _selectedEquipment == null,
                  onSelected: (_) => setState(() => _selectedEquipment = null),
                ),
                const SizedBox(width: 6),
                for (final eq in GymEquipment.values) ...[
                  FilterChip(
                    label: Text(eq.displayName),
                    selected: _selectedEquipment == eq,
                    onSelected: (sel) => setState(() => _selectedEquipment = sel ? eq : null),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          const Divider(height: 12),
          // Exercise Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} Übungen gefunden',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
                if (_selectedMuscle != null || _selectedEquipment != null || _searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedMuscle = null;
                        _selectedEquipment = null;
                      });
                    },
                    child: const Text('Filter zurücksetzen'),
                  ),
              ],
            ),
          ),
          // List
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Keine Übungen mit diesen Kriterien gefunden.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ex = filtered[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: const Icon(Icons.fitness_center, size: 20),
                        ),
                        title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${ex.primaryMuscle.displayName} · ${ex.equipment.displayName}'
                          '${ex.secondaryMuscles.isNotEmpty ? ' (+${ex.secondaryMuscles.map((m) => m.displayName).join(', ')})' : ''}',
                        ),
                        trailing: ex.isTimed
                            ? const Chip(label: Text('Timer', style: TextStyle(fontSize: 10)))
                            : const Icon(Icons.chevron_right),
                        onTap: () => _showExerciseDetails(context, ex),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Eigene Übung'),
        onPressed: () => _showAddCustomExerciseDialog(context),
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, GymExercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _ExerciseDetailSheet(exercise: exercise),
    );
  }

  void _showAddCustomExerciseDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final instrCtrl = TextEditingController();
    var muscle = GymMuscleGroup.chest;
    var equipment = GymEquipment.barbell;
    var isTimed = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Eigene Übung hinzufügen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Übungsname *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                const Text('Haupt-Muskelgruppe:'),
                DropdownButton<GymMuscleGroup>(
                  value: muscle,
                  isExpanded: true,
                  items: GymMuscleGroup.values.where((m) => m != GymMuscleGroup.fullBody).map((m) {
                    return DropdownMenuItem(value: m, child: Text(m.displayName));
                  }).toList(),
                  onChanged: (v) => setDialogState(() => muscle = v!),
                ),
                const SizedBox(height: 12),
                const Text('Benötigtes Equipment:'),
                DropdownButton<GymEquipment>(
                  value: equipment,
                  isExpanded: true,
                  items: GymEquipment.values.map((eq) {
                    return DropdownMenuItem(value: eq, child: Text(eq.displayName));
                  }).toList(),
                  onChanged: (v) => setDialogState(() => equipment = v!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Statische Zeitübung (z.B. Plank)'),
                  value: isTimed,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setDialogState(() => isTimed = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: instrCtrl,
                  decoration: const InputDecoration(labelText: 'Anleitung / Ausführungshinweise', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final newEx = GymExercise(
                  id: 'custom_${const Uuid().v4()}',
                  name: name,
                  primaryMuscle: muscle,
                  equipment: equipment,
                  instructions: instrCtrl.text.trim(),
                  isCustom: true,
                  isTimed: isTimed,
                );

                await context.read<GymController>().upsertExercise(newEx);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Übung "$name" erfolgreich gespeichert.')),
                  );
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseDetailSheet extends StatefulWidget {
  const _ExerciseDetailSheet({required this.exercise});
  final GymExercise exercise;

  @override
  State<_ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<_ExerciseDetailSheet> {
  final weightCtrl = TextEditingController(text: '80');
  final repsCtrl = TextEditingController(text: '5');
  double? _calculated1Rm;

  @override
  void initState() {
    super.initState();
    _recalculate1Rm();
  }

  void _recalculate1Rm() {
    final w = double.tryParse(weightCtrl.text) ?? 0.0;
    final r = int.tryParse(repsCtrl.text) ?? 0;
    if (w > 0 && r > 0) {
      final est = const OneRepMaxCalculator().calculate(weightKg: w, reps: r);
      setState(() => _calculated1Rm = est.estimated1Rm);
    } else {
      setState(() => _calculated1Rm = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ex = widget.exercise;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Scaffold(
        appBar: AppBar(
          title: Text(ex.name),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
          ],
        ),
        body: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(16),
          children: [
            // Muscle & Equipment Tags
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  avatar: const Icon(Icons.fitness_center, size: 16),
                  label: Text('Ziel: ${ex.primaryMuscle.displayName}'),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
                Chip(
                  avatar: const Icon(Icons.handyman_outlined, size: 16),
                  label: Text(ex.equipment.displayName),
                ),
                if (ex.isTimed)
                  const Chip(
                    avatar: Icon(Icons.timer_outlined, size: 16),
                    label: Text('Zeitübung'),
                  ),
              ],
            ),
            if (ex.secondaryMuscles.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Unterstützende Muskeln: ${ex.secondaryMuscles.map((m) => m.displayName).join(', ')}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
            ],
            const SizedBox(height: 16),

            // Instructions
            if (ex.instructions != null && ex.instructions!.isNotEmpty) ...[
              Text('Ausführungshinweise', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(ex.instructions!, style: theme.textTheme.bodyMedium),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Interactive 1RM Calculator Card
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calculate_outlined, color: Colors.deepOrangeAccent),
                        const SizedBox(width: 8),
                        Text('1RM Rechner (One Rep Max)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Gewicht (kg)', border: OutlineInputBorder(), isDense: true),
                            onChanged: (_) => _recalculate1Rm(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: repsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Wiederholungen', border: OutlineInputBorder(), isDense: true),
                            onChanged: (_) => _recalculate1Rm(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_calculated1Rm != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepOrangeAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Geschätzte Maximalkraft (1RM):', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              '${_calculated1Rm!.toStringAsFixed(1)} kg',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
