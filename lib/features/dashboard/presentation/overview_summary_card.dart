import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A comprehensive, all-in-one summary card presenting calories, macros,
/// steps, energy expenditure, weight, and cycle status in a single unified view.
class OverviewSummaryCard extends StatelessWidget {
  const OverviewSummaryCard({
    super.key,
    required this.consumedCal,
    required this.targetCal,
    required this.consumedCarbs,
    required this.targetCarbs,
    required this.consumedProt,
    required this.targetProt,
    required this.consumedFat,
    required this.targetFat,
    required this.steps,
    this.stepGoal = 10000,
    required this.distanceKm,
    required this.activeKcal,
    required this.totalKcal,
    required this.weight,
    required this.weightTrend,
    required this.cycleDay,
    required this.cyclePhase,
    this.onNavigateToTab,
  });

  final double consumedCal;
  final int targetCal;
  final double consumedCarbs;
  final double targetCarbs;
  final double consumedProt;
  final double targetProt;
  final double consumedFat;
  final double targetFat;

  final int steps;
  final int stepGoal;
  final double distanceKm;
  final double activeKcal;
  final double totalKcal;

  final double? weight;
  final double? weightTrend;
  final int? cycleDay;
  final String? cyclePhase;

  final ValueChanged<int>? onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final remainingCal = (targetCal - consumedCal.round()).clamp(0, targetCal);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.dashboard_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Große Tagesübersicht',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Alle Kernbereiche auf einen Blick',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Heute',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section 1: Ernährung (Calories & Macros)
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onNavigateToTab?.call(1),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.deepPurple.shade900.withValues(alpha: 0.2)
                      : Colors.deepPurple.shade50.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.deepPurple.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.restaurant_menu,
                                size: 16, color: Colors.deepPurple),
                            const SizedBox(width: 6),
                            Text(
                              'Ernährung & Kalorien',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Noch $remainingCal kcal',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${consumedCal.round()}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / $targetCal kcal',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        _buildMacroBadge(
                          label: 'K',
                          value: '${consumedCarbs.round()}g',
                          color: Colors.deepPurpleAccent,
                        ),
                        const SizedBox(width: 6),
                        _buildMacroBadge(
                          label: 'P',
                          value: '${consumedProt.round()}g',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        _buildMacroBadge(
                          label: 'F',
                          value: '${consumedFat.round()}g',
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Section 2: Aktivität & Energie
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onNavigateToTab?.call(2),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.teal.shade900.withValues(alpha: 0.2)
                      : Colors.teal.shade50.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.teal.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_walk,
                                size: 16, color: Colors.teal),
                            const SizedBox(width: 6),
                            Text(
                              'Aktivität & Energie',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${distanceKm.toStringAsFixed(1)} km',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$steps',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / ${NumberFormat.decimalPattern('de_DE').format(stepGoal)} Schritte',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '🔥 ${activeKcal.round()} kcal aktiv',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            Text(
                              '⚡ ${totalKcal.round()} kcal Gesamt',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Section 3: Körper & Wohlbefinden
            Row(
              children: [
                // Weight
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.pushNamed(context, '/weight'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.blueGrey.shade900.withValues(alpha: 0.3)
                            : Colors.blueGrey.shade50.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.blueGrey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.scale,
                                  size: 14, color: Colors.blueGrey),
                              const SizedBox(width: 4),
                              Text(
                                'Gewicht',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weight != null
                                ? '${weight!.toStringAsFixed(1)} kg'
                                : '-- kg',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            weightTrend != null
                                ? '${weightTrend! > 0 ? "+" : ""}${weightTrend!.toStringAsFixed(1)} kg/Wo.'
                                : 'Kein Trend',
                            style: TextStyle(
                              fontSize: 10,
                              color: (weightTrend ?? 0) < 0
                                  ? Colors.green
                                  : (weightTrend ?? 0) > 0
                                      ? Colors.amber.shade800
                                      : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Cycle
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onNavigateToTab?.call(3),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.pink.shade900.withValues(alpha: 0.2)
                            : Colors.pink.shade50.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.pink.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.spa,
                                  size: 14, color: Colors.pinkAccent),
                              const SizedBox(width: 4),
                              Text(
                                'Zyklus',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cycleDay != null && cycleDay! > 0
                                ? 'Tag $cycleDay'
                                : 'Keine Daten',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            cyclePhase?.isNotEmpty == true
                                ? cyclePhase!
                                : 'Tippen zum Öffnen',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
