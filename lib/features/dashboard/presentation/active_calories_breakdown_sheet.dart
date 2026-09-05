import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_state.dart';
import '../../activity/presentation/activity_controller.dart';
import '../../gym/presentation/gym_controller.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../weight/presentation/weight_controller.dart';

class ActiveCaloriesBreakdownSheet extends StatelessWidget {
  const ActiveCaloriesBreakdownSheet({
    super.key,
    required this.activeCalories,
    this.totalCalories,
    this.bmr,
    this.missingBmrParameters = const [],
    required this.steps,
    required this.distanceKm,
    this.onNavigateToActivity,
  });

  final double activeCalories;
  final double? totalCalories;
  final double? bmr;
  final List<String> missingBmrParameters;
  final int steps;
  final double distanceKm;
  final VoidCallback? onNavigateToActivity;

  static Future<void> show(
    BuildContext context, {
    required double activeCalories,
    double? totalCalories,
    double? bmr,
    List<String>? missingBmrParameters,
    required int steps,
    required double distanceKm,
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
      builder: (_) => ActiveCaloriesBreakdownSheet(
        activeCalories: activeCalories,
        totalCalories: totalCalories,
        bmr: bmr,
        missingBmrParameters: missingBmrParameters ?? const [],
        steps: steps,
        distanceKm: distanceKm,
        onNavigateToActivity: onNavigateToActivity,
      ),
    );
  }

  IconData _iconForWorkoutType(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('bike') ||
        lower.contains('cycl') ||
        lower.contains('rad')) {
      return Icons.directions_bike;
    }
    if (lower.contains('hike') || lower.contains('wander')) {
      return Icons.hiking;
    }
    if (lower.contains('gym') ||
        lower.contains('kraft') ||
        lower.contains('weight') ||
        lower.contains('strength')) {
      return Icons.fitness_center;
    }
    if (lower.contains('walk') ||
        lower.contains('spazier') ||
        lower.contains('gehen')) {
      return Icons.directions_walk;
    }
    return Icons.directions_run;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ActivityController? activityCtrl;
    GymController? gymCtrl;
    SettingsController? settingsCtrl;
    WeightController? weightCtrl;
    try {
      activityCtrl = context.watch<ActivityController>();
    } catch (_) {
      try {
        activityCtrl = context.watch<AppState>().activityController;
      } catch (_) {}
    }
    try {
      gymCtrl = context.watch<GymController>();
    } catch (_) {
      try {
        gymCtrl = context.watch<AppState>().gymController;
      } catch (_) {}
    }
    try {
      settingsCtrl = context.watch<SettingsController>();
    } catch (_) {
      try {
        settingsCtrl = context.watch<AppState>().settingsController;
      } catch (_) {}
    }
    try {
      weightCtrl = context.watch<WeightController>();
    } catch (_) {
      try {
        weightCtrl = context.watch<AppState>().weightController;
      } catch (_) {}
    }

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    const weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    const months = [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    final dateDisplay = '$weekday, ${now.day}. $month';

    final todayWorkouts = (activityCtrl?.workouts ?? []).where((w) {
      final d = w.startUtc.toLocal();
      return DateFormat('yyyy-MM-dd').format(d) == todayStr;
    }).toList();

    final todayGymSessions = (gymCtrl?.recentSessions ?? []).where((s) {
      final d = DateTime.tryParse(s.startUtc)?.toLocal();
      if (d == null) return false;
      return DateFormat('yyyy-MM-dd').format(d) == todayStr;
    }).toList();

    // Calculate individual components
    double cardioKcal = 0;
    for (final w in todayWorkouts) {
      cardioKcal += w.energyKcal ?? (w.durationSeconds / 60.0 * 8.0);
    }

    double gymKcal = 0;
    for (final s in todayGymSessions) {
      gymKcal += (s.durationSeconds / 60.0 * 6.5);
    }

    final stepKcal = (steps * 0.04).roundToDouble();
    final workoutSum = cardioKcal + gymKcal;
    final neatKcal = activeCalories > workoutSum
        ? (activeCalories - workoutSum)
        : (steps > 0 ? stepKcal : 0.0);

    final effectiveMissing = missingBmrParameters.isNotEmpty
        ? missingBmrParameters
        : () {
            final list = <String>[];
            final w = weightCtrl?.currentWeight;
            if (w == null || w <= 0) list.add('Körpergewicht');
            final h = settingsCtrl?.goals.userHeight ?? 170.0;
            if (h <= 0 || h < 50) list.add('Körpergröße');
            final a = settingsCtrl?.goals.userAge ?? 30;
            if (a <= 0 || a < 10) list.add('Alter');
            return list;
          }();

    final effectiveBmr = bmr ??
        (effectiveMissing.isEmpty && weightCtrl?.currentWeight != null
            ? (settingsCtrl?.calculateBmr(
                  weightKg: weightCtrl!.currentWeight!,
                ) ??
                1750.0)
            : (totalCalories != null && totalCalories! > activeCalories
                ? (totalCalories! - activeCalories)
                : 1750.0));

    final dayProgress =
        ((now.hour * 3600 + now.minute * 60 + now.second) / 86400.0)
            .clamp(0.0, 1.0);
    final proportionalBmr = effectiveBmr * dayProgress;

    // Gesamtumsatz = Aktivkalorien + anteiliger Grundumsatz
    final calculatedTotal = totalCalories ?? (activeCalories + proportionalBmr);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.deepOrange,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kalorienverbrauch heute',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateDisplay,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Schließen',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hero Breakdown Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.deepOrange.withValues(alpha: 0.25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${activeCalories.round()}',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'kcal aktiv',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Gesamt: ${effectiveMissing.isEmpty ? "" : "~"}${calculatedTotal.round()} kcal',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (effectiveMissing.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Gesamtumsatz = Aktivkalorien + anteiliger Grundumsatz. Für exakte Berechnung fehlt: ${effectiveMissing.join(", ")}.',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.amber.shade200
                                      : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Stacked Distribution Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 14,
                        child: Row(
                          children: [
                            // BMR Segment (Ruhe)
                            Expanded(
                              flex: (effectiveBmr.clamp(100, 5000)).round(),
                              child: Container(color: Colors.indigoAccent),
                            ),
                            // NEAT Segment (Schritte/Alltag)
                            if (neatKcal > 0)
                              Expanded(
                                flex: (neatKcal.clamp(1, 3000)).round(),
                                child: Container(color: Colors.teal),
                              ),
                            // Cardio Segment
                            if (cardioKcal > 0)
                              Expanded(
                                flex: (cardioKcal.clamp(1, 3000)).round(),
                                child: Container(color: Colors.deepOrange),
                              ),
                            // Gym Segment
                            if (gymKcal > 0)
                              Expanded(
                                flex: (gymKcal.clamp(1, 3000)).round(),
                                child: Container(color: Colors.amber.shade700),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Legend
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _buildLegendItem(
                          color: Colors.indigoAccent,
                          label:
                              'Grundumsatz (${effectiveBmr.round()} kcal${effectiveMissing.isNotEmpty ? " geschätzt" : ""})',
                        ),
                        if (neatKcal > 0)
                          _buildLegendItem(
                            color: Colors.teal,
                            label: 'Alltag (${neatKcal.round()} kcal)',
                          ),
                        if (cardioKcal > 0)
                          _buildLegendItem(
                            color: Colors.deepOrange,
                            label: 'Cardio (${cardioKcal.round()} kcal)',
                          ),
                        if (gymKcal > 0)
                          _buildLegendItem(
                            color: Colors.amber.shade700,
                            label: 'Gym (${gymKcal.round()} kcal)',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Aufschlüsselung der Herkunft',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // 1. Schritte & Alltagsbewegung
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.teal.withValues(alpha: 0.2)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.withValues(alpha: 0.15),
                  child: const Icon(Icons.directions_walk, color: Colors.teal),
                ),
                title: const Text(
                  'Alltagsbewegung & Schritte (NEAT)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '$steps Schritte · ${distanceKm.toStringAsFixed(1)} km zurückgelegt',
                ),
                trailing: Text(
                  '+${neatKcal.round()} kcal',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 2. Workouts (Cardio & GPS)
            if (todayWorkouts.isNotEmpty)
              for (final w in todayWorkouts)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.deepOrange.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepOrange.withValues(
                        alpha: 0.15,
                      ),
                      child: Icon(
                        _iconForWorkoutType(w.type),
                        color: Colors.deepOrange,
                      ),
                    ),
                    title: Text(
                      w.type,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${DateFormat('HH:mm').format(w.startUtc.toLocal())} Uhr · '
                      '${(w.durationSeconds / 60).round()} min'
                      '${w.distanceMeters != null && w.distanceMeters! > 0 ? ' · ${(w.distanceMeters! / 1000).toStringAsFixed(2)} km' : ''}',
                    ),
                    trailing: Text(
                      '+${(w.energyKcal ?? (w.durationSeconds / 60.0 * 8.0)).round()} kcal',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                )
            else
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.directions_run, color: Colors.white),
                  ),
                  title: Text('Keine Cardio-Workouts heute'),
                  subtitle: Text('Starte einen Lauf oder eine Radtour via GPS'),
                ),
              ),
            const SizedBox(height: 8),

            // 3. Gym / Kraftsport
            if (todayGymSessions.isNotEmpty)
              for (final s in todayGymSessions)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.amber.shade700.withValues(alpha: 0.25),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.shade700.withValues(
                        alpha: 0.15,
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    title: Text(
                      s.routineName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${(s.durationSeconds / 60).round()} min Krafttraining · '
                      '${(s.totalTonnageKg / 1000).toStringAsFixed(1)} t Tonnage',
                    ),
                    trailing: Text(
                      '+${(s.durationSeconds / 60.0 * 6.5).round()} kcal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                )
            else
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.fitness_center, color: Colors.white),
                  ),
                  title: Text('Kein Krafttraining heute'),
                  subtitle: Text('Einheiten aus dem Gym-Tab erscheinen hier'),
                ),
              ),
            const SizedBox(height: 8),

            // 4. Grundumsatz (BMR)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: effectiveMissing.isEmpty
                      ? Colors.indigoAccent.withValues(alpha: 0.2)
                      : Colors.amber.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (effectiveMissing.isEmpty
                              ? Colors.indigoAccent
                              : Colors.amber)
                          .withValues(alpha: 0.15),
                      child: Icon(
                        effectiveMissing.isEmpty
                            ? Icons.nightlight_round
                            : Icons.warning_amber_rounded,
                        color: effectiveMissing.isEmpty
                            ? Colors.indigoAccent
                            : Colors.amber.shade800,
                      ),
                    ),
                    title: const Text(
                      'Grundumsatz (BMR / Ruheenergie)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      effectiveMissing.isEmpty
                          ? 'Berechnet nach ${settingsCtrl?.goals.bmrFormula == BmrFormula.harris ? "Harris-Benedict" : "Mifflin-St Jeor"} (${weightCtrl?.currentWeight?.toStringAsFixed(1) ?? ""} kg, ${settingsCtrl?.goals.userHeight.round() ?? 170} cm, ${settingsCtrl?.goals.userAge ?? 30} J.)'
                          : 'Geschätzter Richtwert (~${effectiveBmr.round()} kcal). Werte fehlen: ${effectiveMissing.join(", ")}',
                    ),
                    trailing: Text(
                      '${effectiveMissing.isEmpty ? "" : "~"}${effectiveBmr.round()} kcal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: effectiveMissing.isEmpty
                            ? Colors.indigoAccent
                            : Colors.amber.shade800,
                      ),
                    ),
                  ),
                  if (effectiveMissing.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Für die genaue Grundumsatz-Berechnung fehlen: ${effectiveMissing.join(", ")}.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.amber.shade200
                                    : Colors.amber.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bitte trage ${effectiveMissing.contains("Körpergewicht") ? "dein Gewicht (im Gewicht-Tab) " : ""}${effectiveMissing.any((e) => e != "Körpergewicht") ? "und deine Profilangaben in den Einstellungen " : ""}ein, um deinen persönlichen Grundumsatz genau zu berechnen.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gesamtumsatz (Stand jetzt) = Aktivkalorien (${activeCalories.round()} kcal) + anteiliger Grundumsatz (${proportionalBmr.round()} kcal von ${effectiveBmr.round()} kcal/Tag) = ${calculatedTotal.round()} kcal. Aktivkalorien stammen aus deinen Schritten, Alltagsbewegungen sowie erfassten Trainings.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Button to Activities
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onNavigateToActivity?.call();
              },
              icon: const Icon(Icons.directions_run),
              label: const Text('Zu den Aktivitäten & Routen'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
