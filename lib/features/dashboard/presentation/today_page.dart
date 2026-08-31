import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/design_system.dart';
import '../../../models/app_state.dart';
import 'dashboard_config_sheet.dart';
import 'dashboard_controller.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  void _openConfigSheet(DashboardController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const DashboardConfigSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardController?>();
    final appState = context.watch<AppState>();

    // Fallbacks if DashboardController is not provided directly in tree
    final consumedCal =
        dashboard?.consumedCalories ?? appState.consumedCalories;
    final targetCal = dashboard?.dailyCalorieGoal ?? appState.dailyCalorieGoal;
    final consumedCarbs = dashboard?.consumedCarbs ?? appState.consumedCarbs;
    final targetCarbs = dashboard?.dailyCarbGoal ?? appState.dailyCarbGoal;
    final consumedProt = dashboard?.consumedProtein ?? appState.consumedProtein;
    final targetProt = dashboard?.dailyProteinGoal ?? appState.dailyProteinGoal;
    final consumedFat = dashboard?.consumedFat ?? appState.consumedFat;
    final targetFat = dashboard?.dailyFatGoal ?? appState.dailyFatGoal;

    final steps = dashboard?.steps ?? 0;
    final activeKcal = dashboard?.activeCalories ?? 0.0;
    final distanceKm = dashboard?.distanceKm ?? 0.0;
    final totalKcal = dashboard?.totalCalories;

    final weight = dashboard?.latestWeight ??
        (appState.weightEntries.isNotEmpty
            ? appState.weightEntries.last.weight
            : null);
    final weightTrend = dashboard?.weightTrend;

    final lastSync = dashboard?.lastSyncTime;
    final healthError = dashboard?.healthErrorMessage;

    final cycleDay = dashboard?.cycleDay;
    final cyclePhase = dashboard?.cyclePhase;
    final cycleTip = dashboard?.discreteCycleTip;
    final impulses = dashboard?.actionImpulses ?? const [];

    final cardOrder =
        dashboard?.cardOrder ?? DashboardController.defaultCardOrder;
    final visibility = dashboard?.cardVisibility ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heute'),
        actions: [
          if (dashboard != null)
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Dashboard anpassen',
              onPressed: () => _openConfigSheet(dashboard),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aktualisieren',
            onPressed: () async {
              if (dashboard != null) {
                await dashboard.refresh();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (dashboard != null) {
            await dashboard.refresh();
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Dein Überblick'),
            const SizedBox(height: 12),
            for (final cardId in cardOrder)
              if (visibility[cardId] != false) ...[
                _buildCardById(
                  context: context,
                  cardId: cardId,
                  consumedCal: consumedCal,
                  targetCal: targetCal,
                  consumedCarbs: consumedCarbs,
                  targetCarbs: targetCarbs,
                  consumedProt: consumedProt,
                  targetProt: targetProt,
                  consumedFat: consumedFat,
                  targetFat: targetFat,
                  steps: steps,
                  distanceKm: distanceKm,
                  activeKcal: activeKcal,
                  totalKcal: totalKcal,
                  weight: weight,
                  weightTrend: weightTrend,
                  lastSync: lastSync,
                  healthError: healthError,
                  cycleDay: cycleDay,
                  cyclePhase: cyclePhase,
                  cycleTip: cycleTip,
                  impulses: impulses,
                ),
                const SizedBox(height: 8),
              ],
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Health- und Zyklusdaten bleiben stets lokal auf diesem Gerät. Verschlüsselte Backups werden separat geschützt.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardById({
    required BuildContext context,
    required String cardId,
    required double consumedCal,
    required int targetCal,
    required double consumedCarbs,
    required double targetCarbs,
    required double consumedProt,
    required double targetProt,
    required double consumedFat,
    required double targetFat,
    required int steps,
    required double distanceKm,
    required double activeKcal,
    required double? totalKcal,
    required double? weight,
    required double? weightTrend,
    required DateTime? lastSync,
    required String? healthError,
    required int? cycleDay,
    required String? cyclePhase,
    required String? cycleTip,
    required List<ActionImpulse> impulses,
  }) {
    switch (cardId) {
      case 'calories':
        return KpiCard(
          title: 'Kalorien & Makros',
          value: '${consumedCal.round()} / $targetCal kcal',
          subtitle:
              'KH: ${consumedCarbs.round()}/${targetCarbs.round()}g · Protein: ${consumedProt.round()}/${targetProt.round()}g · Fett: ${consumedFat.round()}/${targetFat.round()}g',
          icon: Icons.local_fire_department_outlined,
          onTap: () => Navigator.pushNamed(context, '/nutrition'),
        );
      case 'steps':
        return KpiCard(
          title: 'Schritte & Distanz',
          value: '$steps Schritte',
          subtitle: steps == 0
              ? 'Noch keine Schritte synchronisiert'
              : '${distanceKm.toStringAsFixed(1)} km zurückgelegt',
          icon: Icons.directions_walk,
          onTap: () => Navigator.pushNamed(context, '/activity'),
        );
      case 'active_energy':
        return KpiCard(
          title: 'Aktivenergie',
          value: '${activeKcal.round()} kcal aktiv',
          subtitle: totalKcal != null
              ? 'Gesamtumsatz: ${totalKcal.round()} kcal'
              : 'Reine Aktivkalorien (getrennt vom Grundumsatz)',
          icon: Icons.bolt,
          onTap: () => Navigator.pushNamed(context, '/activity'),
        );
      case 'weight':
        return KpiCard(
          title: 'Gewicht',
          value: weight == null ? '–' : '${weight.toStringAsFixed(1)} kg',
          subtitle: weightTrend != null
              ? '7-Tage-Trend: ${weightTrend >= 0 ? '+' : ''}${weightTrend.toStringAsFixed(1)} kg'
              : 'Letzter Messwert',
          icon: Icons.monitor_weight_outlined,
          onTap: () => Navigator.pushNamed(context, '/weight'),
        );
      case 'health_sync':
        return Card(
          child: SyncStatus(
            lastSyncUtc: lastSync,
            error: healthError,
          ),
        );
      case 'cycle':
        return Card(
          child: ListTile(
            leading:
                const Icon(Icons.water_drop_outlined, color: Colors.purple),
            title: Text(cyclePhase != null
                ? 'Zyklustag $cycleDay · $cyclePhase'
                : 'Zyklus-Status'),
            subtitle: Text(cycleTip ?? 'Tippe für Zyklushistorie und Kalender'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/cycle'),
          ),
        );
      case 'impulses':
        if (impulses.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Handlungsimpulse',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            for (final impulse in impulses)
              Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(impulse.title),
                  subtitle: Text(impulse.description),
                  trailing: FilledButton.tonal(
                    onPressed: () =>
                        Navigator.pushNamed(context, impulse.targetRoute),
                    child: const Text('Öffnen'),
                  ),
                ),
              ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
