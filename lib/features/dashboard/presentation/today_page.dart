import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/design_system.dart';
import '../../../models/app_state.dart';
import 'dashboard_controller.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardController?>();
    final appState = context.watch<AppState>();

    // Fallbacks if DashboardController is not provided directly in tree
    final consumedCal = dashboard?.consumedCalories ?? appState.consumedCalories;
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
        (appState.weightEntries.isNotEmpty ? appState.weightEntries.last.weight : null);
    final weightTrend = dashboard?.weightTrend;

    final syncStatus = dashboard?.syncStatus;
    final lastSync = dashboard?.lastSyncTime;
    final healthError = dashboard?.healthErrorMessage;

    final cycleDay = dashboard?.cycleDay;
    final cyclePhase = dashboard?.cyclePhase;
    final cycleTip = dashboard?.discreteCycleTip;
    final impulses = dashboard?.actionImpulses ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heute'),
        actions: [
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
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 600 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: columns == 1 ? 2.8 : 1.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    KpiCard(
                      title: 'Kalorien & Makros',
                      value: '${consumedCal.round()} / $targetCal kcal',
                      subtitle:
                          'KH: ${consumedCarbs.round()}/${targetCarbs.round()}g · Protein: ${consumedProt.round()}/${targetProt.round()}g · Fett: ${consumedFat.round()}/${targetFat.round()}g',
                      icon: Icons.local_fire_department_outlined,
                      onTap: () => Navigator.pushNamed(context, '/nutrition'),
                    ),
                    KpiCard(
                      title: 'Schritte & Distanz',
                      value: '$steps Schritte',
                      subtitle: steps == 0
                          ? 'Health Connect verbinden'
                          : '${distanceKm.toStringAsFixed(1)} km zurückgelegt',
                      icon: Icons.directions_walk,
                      onTap: () => Navigator.pushNamed(context, '/activity'),
                    ),
                    KpiCard(
                      title: 'Aktivenergie',
                      value: '${activeKcal.round()} kcal aktiv',
                      subtitle: totalKcal != null
                          ? 'Gesamtumsatz: ${totalKcal.round()} kcal'
                          : 'Reine Aktivkalorien (getrennt von Grundumsatz)',
                      icon: Icons.bolt,
                      onTap: () => Navigator.pushNamed(context, '/activity'),
                    ),
                    KpiCard(
                      title: 'Gewicht',
                      value: weight == null
                          ? '–'
                          : '${weight.toStringAsFixed(1)} kg',
                      subtitle: weightTrend != null
                          ? '7-Tage-Trend: ${weightTrend >= 0 ? '+' : ''}${weightTrend.toStringAsFixed(1)} kg'
                          : 'Letzter Messwert',
                      icon: Icons.monitor_weight_outlined,
                      onTap: () => Navigator.pushNamed(context, '/weight'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Status & Hinweise'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SyncStatus(
                    lastSyncUtc: lastSync,
                    error: healthError,
                  ),
                  if (cycleDay != null || cyclePhase != null || cycleTip != null) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.water_drop_outlined, color: Colors.purple),
                      title: Text(cyclePhase != null
                          ? 'Zyklustag $cycleDay · $cyclePhase'
                          : 'Zyklus-Status'),
                      subtitle: Text(cycleTip ?? 'Tippe für Zyklushistorie und Kalender'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/cycle'),
                    ),
                  ],
                ],
              ),
            ),
            if (impulses.isNotEmpty) ...[
              const SizedBox(height: 16),
              const SectionHeader(title: 'Handlungsimpulse'),
              const SizedBox(height: 8),
              for (final impulse in impulses)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb_outline),
                    title: Text(impulse.title),
                    subtitle: Text(impulse.description),
                    trailing: FilledButton.tonal(
                      onPressed: () => Navigator.pushNamed(context, impulse.targetRoute),
                      child: const Text('Öffnen'),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Health- und Zyklusdaten bleiben stets lokal und verschlüsselt auf deinem Gerät.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
