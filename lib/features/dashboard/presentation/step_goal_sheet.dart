import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class StepGoalSheet extends StatefulWidget {
  const StepGoalSheet({
    super.key,
    required this.currentGoal,
    required this.currentSteps,
    required this.distanceKm,
    required this.onSaveGoal,
    this.onNavigateToActivity,
  });

  final int currentGoal;
  final int currentSteps;
  final double distanceKm;
  final Future<void> Function(int newGoal) onSaveGoal;
  final VoidCallback? onNavigateToActivity;

  static Future<void> show(
    BuildContext context, {
    required int currentGoal,
    required int currentSteps,
    required double distanceKm,
    required Future<void> Function(int newGoal) onSaveGoal,
    VoidCallback? onNavigateToActivity,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StepGoalSheet(
        currentGoal: currentGoal,
        currentSteps: currentSteps,
        distanceKm: distanceKm,
        onSaveGoal: onSaveGoal,
        onNavigateToActivity: onNavigateToActivity,
      ),
    );
  }

  @override
  State<StepGoalSheet> createState() => _StepGoalSheetState();
}

class _StepGoalSheetState extends State<StepGoalSheet> {
  late final TextEditingController _controller;
  bool _isSaving = false;
  String? _errorMessage;

  static const List<int> _presetGoals = [6000, 8000, 10000, 12000, 15000];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentGoal.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final text = _controller.text.trim();
    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0) {
      setState(() {
        _errorMessage = 'Bitte gib eine gültige Schrittzahl ein (z. B. 10000).';
      });
      return;
    }

    if (parsed > 100000) {
      setState(() {
        _errorMessage = 'Das Ziel darf maximal 100.000 Schritte betragen.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.onSaveGoal(parsed);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Schritteziel auf ${NumberFormat.decimalPattern('de_DE').format(parsed)} Schritte aktualisiert.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Fehler beim Speichern des Schritteziels.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final currentInput =
        int.tryParse(_controller.text.trim()) ?? widget.currentGoal;
    final progress = currentInput > 0
        ? (widget.currentSteps / currentInput.toDouble()).clamp(0.0, 1.0)
        : 0.0;
    final percentage = (progress * 100).round();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: bottomInset + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_walk,
                        color: Colors.teal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tägliches Schritteziel',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Heute bisher',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${NumberFormat.decimalPattern('de_DE').format(widget.currentSteps)} Schritte',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Distanz',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.distanceKm.toStringAsFixed(1)} km',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.teal.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$percentage% erreicht',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                      Text(
                        'Ziel: ${NumberFormat.decimalPattern('de_DE').format(currentInput)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Schnellwahl Presets
            Text(
              'Schnellwahl',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetGoals.map((preset) {
                final isSelected = currentInput == preset;
                return ChoiceChip(
                  label:
                      Text(NumberFormat.decimalPattern('de_DE').format(preset)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _controller.text = preset.toString();
                        _errorMessage = null;
                      });
                    }
                  },
                  selectedColor: Colors.teal.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color:
                        isSelected ? Colors.teal : theme.colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom Input
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Individuelles Schritteziel',
                hintText: 'z. B. 10000',
                suffixText: 'Schritte',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.flag_outlined),
                errorText: _errorMessage,
                helperText: 'Empfehlung: 8.000 bis 12.000 Schritte täglich',
              ),
              onChanged: (_) {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),
            const SizedBox(height: 20),

            // Save Button
            FilledButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSaving ? 'Wird gespeichert...' : 'Ziel speichern'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Button to Activity Page
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onNavigateToActivity?.call();
              },
              icon: const Icon(Icons.directions_run),
              label: const Text('Zu Aktivitäten & Workouts'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
