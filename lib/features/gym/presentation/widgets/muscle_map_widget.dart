import 'package:flutter/material.dart';
import '../../domain/gym_models.dart';

class MuscleMapWidget extends StatelessWidget {
  const MuscleMapWidget({
    super.key,
    required this.muscleTonnage,
    required this.neglectedMuscles,
  });

  final Map<GymMuscleGroup, double> muscleTonnage;
  final List<GymMuscleGroup> neglectedMuscles;

  Color _colorForMuscle(BuildContext context, GymMuscleGroup muscle, double maxTonnage) {
    final tonnage = muscleTonnage[muscle] ?? 0.0;
    if (tonnage <= 0.0) {
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade300;
    }

    final ratio = (tonnage / (maxTonnage > 0 ? maxTonnage : 1.0)).clamp(0.2, 1.0);
    return Color.lerp(Colors.orange.shade300, Colors.deepOrangeAccent.shade700, ratio)!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxTonnage = muscleTonnage.values.fold<double>(
      0.0,
      (max, val) => val > max ? val : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Muscle Map (Wochenbelastung)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.accessibility_new, color: Colors.deepOrangeAccent),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Farbcodierte Auslastung deiner Muskelgruppen basierend auf absolviertem Volumen (Tonnage).',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 16),
            // Front & Back Silhouette Grid
            Row(
              children: [
                Expanded(
                  child: _BodyViewColumn(
                    title: 'Vorderseite',
                    muscles: const [
                      GymMuscleGroup.shoulders,
                      GymMuscleGroup.chest,
                      GymMuscleGroup.biceps,
                      GymMuscleGroup.abs,
                      GymMuscleGroup.quadriceps,
                      GymMuscleGroup.calves,
                    ],
                    muscleTonnage: muscleTonnage,
                    getColor: (m) => _colorForMuscle(context, m, maxTonnage),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BodyViewColumn(
                    title: 'Rückseite',
                    muscles: const [
                      GymMuscleGroup.trapezius,
                      GymMuscleGroup.back,
                      GymMuscleGroup.triceps,
                      GymMuscleGroup.glutes,
                      GymMuscleGroup.hamstrings,
                      GymMuscleGroup.calves,
                    ],
                    muscleTonnage: muscleTonnage,
                    getColor: (m) => _colorForMuscle(context, m, maxTonnage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (neglectedMuscles.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    'Vernachlässigte Muskeln (letzte 14 Tage):',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: neglectedMuscles.map((m) {
                  return Chip(
                    label: Text(m.displayName),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BodyViewColumn extends StatelessWidget {
  const _BodyViewColumn({
    required this.title,
    required this.muscles,
    required this.muscleTonnage,
    required this.getColor,
  });

  final String title;
  final List<GymMuscleGroup> muscles;
  final Map<GymMuscleGroup, double> muscleTonnage;
  final Color Function(GymMuscleGroup) getColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(title, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        for (final m in muscles) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: getColor(m),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    m.displayName,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  muscleTonnage[m] != null && muscleTonnage[m]! > 0
                      ? '${(muscleTonnage[m]! / 1000).toStringAsFixed(1)}t'
                      : '0t',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
