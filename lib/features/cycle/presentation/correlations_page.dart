import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../activity/presentation/activity_controller.dart';
import '../../nutrition/presentation/nutrition_controller.dart';
import '../domain/correlation_engine.dart';
import 'cycle_controller.dart';

class CorrelationsPage extends StatelessWidget {
  const CorrelationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cycleController = context.watch<CycleController>();
    final activityController = context.watch<ActivityController?>();
    final nutritionController = context.watch<NutritionController?>();

    final allNutrition = [
      if (nutritionController != null) ...[
        ...nutritionController.breakfast,
        ...nutritionController.lunch,
        ...nutritionController.dinner,
        ...nutritionController.snacks,
      ],
    ];

    final result = CorrelationEngine.analyze(
      periods: cycleController.periodsState,
      logs: cycleController.logsState,
      healthSummaries: activityController?.weeklySummaries ?? const [],
      nutritionItems: allNutrition,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorative Zusammenhänge'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.surfaceVariant,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Hinweis zu explorativen Trends',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Alle Analysen werden 100 % lokal auf deinem Gerät berechnet. Sie zeigen statistische Muster auf, stellen jedoch keine medizinischen Diagnosen oder Kausalitäten dar.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Datenbasis & Fortschritt',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.progressDescription, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (result.observationDaysCount / result.requiredDays).clamp(0.0, 1.0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!result.hasSufficientData) ...[
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.query_stats, size: 48, color: Colors.blueGrey),
                    SizedBox(height: 12),
                    Text(
                      'Noch nicht genügend Daten',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Sobald mindestens 7 Beobachtungstage oder 2 Zyklen erfasst sind, erscheinen hier deine persönlichen Trendmuster.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Text(
              'Erkannte Zusammenhänge (${result.insights.length})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final insight in result.insights) ...[
              Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              insight.title,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildConfidenceChip(context, insight.confidenceLevel),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        insight.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            'Datenbasis: n = ${insight.sampleSizeDays} Tage',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceChip(BuildContext context, CorrelationConfidence level) {
    final theme = Theme.of(context);
    switch (level) {
      case CorrelationConfidence.high:
        return Chip(
          label: const Text('Hohe Signifikanz', style: TextStyle(fontSize: 10)),
          backgroundColor: theme.colorScheme.primaryContainer,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      case CorrelationConfidence.moderate:
        return Chip(
          label: const Text('Moderate Evidenz', style: TextStyle(fontSize: 10)),
          backgroundColor: theme.colorScheme.surfaceVariant,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      case CorrelationConfidence.low:
        return Chip(
          label: const Text('Geringe Stichprobe', style: TextStyle(fontSize: 10)),
          backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.5),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
    }
  }
}
