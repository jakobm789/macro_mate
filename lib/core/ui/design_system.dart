import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (onTap != null) const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
    return onTap == null
        ? Semantics(container: true, label: '$title: $value', child: card)
        : Semantics(
            button: true,
            container: true,
            label: '$title: $value',
            child: InkWell(onTap: onTap, child: card),
          );
  }
}

class MacroPill extends StatelessWidget {
  const MacroPill({
    super.key,
    required this.name,
    required this.consumed,
    required this.goal,
    required this.color,
    this.unit = 'g',
  });

  final String name;
  final double consumed;
  final double goal;
  final Color color;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${consumed.round()} / ${goal.round()}$unit',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NutritionHeroCard extends StatelessWidget {
  const NutritionHeroCard({
    super.key,
    required this.consumedCal,
    required this.targetCal,
    required this.consumedCarbs,
    required this.targetCarbs,
    required this.consumedProt,
    required this.targetProt,
    required this.consumedFat,
    required this.targetFat,
    this.onTap,
  });

  final double consumedCal;
  final int targetCal;
  final double consumedCarbs;
  final double targetCarbs;
  final double consumedProt;
  final double targetProt;
  final double consumedFat;
  final double targetFat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final remaining = targetCal - consumedCal.round();
    final progress =
        targetCal > 0 ? (consumedCal / targetCal).clamp(0.0, 1.0) : 0.0;
    final isOverGoal = remaining < 0;

    final content = Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department_outlined,
                    size: 20,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kalorien & Makros',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  '${remaining.abs()} kcal',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOverGoal
                        ? Colors.red.withValues(alpha: 0.12)
                        : Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOverGoal ? 'Über Ziel' : 'Verbleibend',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isOverGoal
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'Gegessen: ${consumedCal.round()} kcal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  'Ziel: $targetCal kcal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverGoal ? Colors.orange : Colors.lightBlueAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                MacroPill(
                  name: 'Carbs',
                  consumed: consumedCarbs,
                  goal: targetCarbs,
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                MacroPill(
                  name: 'Protein',
                  consumed: consumedProt,
                  goal: targetProt,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                MacroPill(
                  name: 'Fett',
                  consumed: consumedFat,
                  goal: targetFat,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      label: 'Kalorien & Makros: ${consumedCal.round()} von $targetCal kcal',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}

class ActivityMetricCard extends StatelessWidget {
  const ActivityMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.accentColor,
    this.progress,
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? accentColor;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = accentColor ?? Theme.of(context).colorScheme.primary;

    final content = Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: effectiveColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Theme.of(context).colorScheme.outline,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress!.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Semantics(
      button: onTap != null,
      label: '$title: $value',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}

class WeightMetricCard extends StatelessWidget {
  const WeightMetricCard({
    super.key,
    required this.weight,
    this.trendKg,
    this.onTap,
  });

  final double? weight;
  final double? trendKg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasWeight = weight != null;
    final valueText = hasWeight ? '${weight!.toStringAsFixed(1)} kg' : '–';

    final content = Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monitor_weight_outlined,
                    size: 20,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gewicht',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Theme.of(context).colorScheme.outline,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 4,
              children: [
                Text(
                  valueText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (trendKg != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (trendKg! <= 0 ? Colors.green : Colors.orange)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendKg! <= 0
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 12,
                          color: trendKg! <= 0
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${trendKg! >= 0 ? '+' : ''}${trendKg!.toStringAsFixed(1)} kg (7T)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: trendKg! <= 0
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              trendKg != null
                  ? '7-Tage-Trend aktiv'
                  : 'Tippen für Historie & Verlauf',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: onTap != null,
      label: 'Gewicht: $valueText',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (action != null) action!,
        ],
      );
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'Wird geladen …'});

  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        liveRegion: true,
        child: const Center(child: CircularProgressIndicator()),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.inbox_outlined, size: 32),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(message, textAlign: TextAlign.center),
              if (action != null) ...[
                const SizedBox(height: 12),
                action!,
              ],
            ],
          ),
        ),
      );
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: ListTile(
          leading: const Icon(Icons.error_outline),
          title: const Text('Daten konnten nicht geladen werden'),
          subtitle: Text(message),
          trailing: onRetry == null
              ? null
              : IconButton(
                  tooltip: 'Erneut versuchen',
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                ),
        ),
      );
}

class PermissionCard extends StatelessWidget {
  const PermissionCard({
    super.key,
    required this.title,
    required this.message,
    required this.onGrant,
  });

  final String title;
  final String message;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.lock_open_outlined),
          title: Text(title),
          subtitle: Text(message),
          trailing: FilledButton(
            onPressed: onGrant,
            child: const Text('Erlauben'),
          ),
        ),
      );
}

class SyncStatus extends StatelessWidget {
  const SyncStatus({super.key, this.lastSyncUtc, this.error});

  final DateTime? lastSyncUtc;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final text = error != null
        ? 'Fehler: $error'
        : lastSyncUtc == null
            ? 'Noch nicht synchronisiert'
            : 'Zuletzt ${lastSyncUtc!.toLocal()}'
                .replaceFirst(RegExp(r'\.\d+'), '');
    return ListTile(
      leading: Icon(
        error == null ? Icons.sync : Icons.sync_problem,
        color: error == null
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
      title: const Text('Synchronisationsstatus'),
      subtitle: Text(text),
    );
  }
}

class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      );
}
