import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/design_system.dart';
import '../../../models/app_state.dart';
import 'active_calories_breakdown_sheet.dart';
import 'dashboard_config_sheet.dart';
import 'dashboard_controller.dart';
import 'overview_summary_card.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key, this.onNavigateToTab});

  final ValueChanged<int>? onNavigateToTab;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  String get _formattedDate {
    final now = DateTime.now();
    const weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag'
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
      'Dezember'
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day}. ${months[now.month - 1]}';
  }

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

    final weight = dashboard?.latestWeight ??
        (appState.weightEntries.isNotEmpty
            ? appState.weightEntries.last.weight
            : null);
    final weightTrend = dashboard?.weightTrend;

    final missingBmr = dashboard?.missingBmrParameters ??
        (() {
          final list = <String>[];
          if (weight == null || weight <= 0) list.add('Körpergewicht');
          if (appState.userHeight <= 0 || appState.userHeight < 50) {
            list.add('Körpergröße');
          }
          if (appState.userAge <= 0 || appState.userAge < 10) {
            list.add('Alter');
          }
          return list;
        })();

    final bmr = dashboard?.bmr ??
        (weight != null && weight > 0 && missingBmr.isEmpty
            ? appState.settingsController.calculateBmr(weightKg: weight)
            : 1750.0);

    // Gesamtumsatz = Aktivkalorien + Grundumsatz
    final totalKcal = dashboard?.totalCalories ?? (activeKcal + bmr);

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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formattedDate,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dein Überblick',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
                    bmr: bmr,
                    missingBmr: missingBmr,
                    weight: weight,
                    weightTrend: weightTrend,
                    lastSync: lastSync,
                    healthError: healthError,
                    cycleDay: cycleDay,
                    cyclePhase: cyclePhase,
                    cycleTip: cycleTip,
                    impulses: impulses,
                  ),
                  const SizedBox(height: 12),
                ],
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Health- und Zyklusdaten bleiben stets lokal auf diesem Gerät. Verschlüsselte Backups werden separat geschützt.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
    double bmr = 1750.0,
    List<String> missingBmr = const [],
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
        return NutritionHeroCard(
          consumedCal: consumedCal,
          targetCal: targetCal,
          consumedCarbs: consumedCarbs,
          targetCarbs: targetCarbs,
          consumedProt: consumedProt,
          targetProt: targetProt,
          consumedFat: consumedFat,
          targetFat: targetFat,
          onTap: () {
            if (widget.onNavigateToTab != null) {
              widget.onNavigateToTab!(1);
            } else {
              Navigator.pushNamed(context, '/nutrition');
            }
          },
        );
      case 'steps':
        return ActivityMetricCard(
          title: 'Schritte & Distanz',
          value: '$steps Schritte',
          subtitle: steps == 0
              ? 'Noch keine Schritte synchronisiert'
              : '${distanceKm.toStringAsFixed(1)} km zurückgelegt (Ziel: 10.000)',
          icon: Icons.directions_walk,
          accentColor: Colors.teal,
          progress: steps > 0 ? (steps / 10000.0) : null,
          onTap: () {
            if (widget.onNavigateToTab != null) {
              widget.onNavigateToTab!(2);
            } else {
              Navigator.pushNamed(context, '/activity');
            }
          },
        );
      case 'active_energy':
        final effectiveTotal = totalKcal ?? (activeKcal + bmr);
        final String subtitleText;
        if (missingBmr.isNotEmpty) {
          subtitleText =
              'Gesamtumsatz: ~${effectiveTotal.round()} kcal · Fehlend für Grundumsatz: ${missingBmr.join(", ")}';
        } else {
          subtitleText =
              'Gesamtumsatz: ${effectiveTotal.round()} kcal (inkl. ${bmr.round()} kcal Grundumsatz)';
        }
        return ActivityMetricCard(
          title: 'Aktivenergie',
          value: '${activeKcal.round()} kcal aktiv',
          subtitle: subtitleText,
          icon: Icons.bolt,
          accentColor: Colors.deepOrange,
          onTap: () => ActiveCaloriesBreakdownSheet.show(
            context,
            activeCalories: activeKcal,
            totalCalories: effectiveTotal,
            bmr: bmr,
            missingBmrParameters: missingBmr,
            steps: steps,
            distanceKm: distanceKm,
            onNavigateToActivity: () {
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(2);
              } else {
                Navigator.pushNamed(context, '/activity');
              }
            },
          ),
        );
      case 'weight':
        return WeightMetricCard(
          weight: weight,
          trendKg: weightTrend,
          onTap: () => Navigator.pushNamed(context, '/weight'),
        );
      case 'health_sync':
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.3),
            ),
          ),
          child: SyncStatus(
            lastSyncUtc: lastSync,
            error: healthError,
          ),
        );
      case 'cycle':
        final hasCycleData = cyclePhase != null || cycleDay != null;
        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.purple.withValues(alpha: 0.25),
            ),
          ),
          child: InkWell(
            onTap: () {
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(3);
              } else {
                Navigator.pushNamed(context, '/cycle');
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.water_drop_outlined,
                      color: Colors.purple,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasCycleData
                              ? 'Zyklustag $cycleDay · $cyclePhase'
                              : 'Zyklus & Wohlbefinden',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cycleTip ?? 'Tippe für Zyklushistorie und Kalender',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        );
      case 'impulses':
        if (impulses.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  const Text(
                    'Handlungsimpulse',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            for (final impulse in impulses)
              Card(
                elevation: 1.5,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.amber, size: 20),
                  ),
                  title: Text(
                    impulse.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(impulse.description),
                  trailing: FilledButton.tonal(
                    onPressed: () {
                      if (impulse.targetRoute == '/nutrition' &&
                          widget.onNavigateToTab != null) {
                        widget.onNavigateToTab!(1);
                      } else if (impulse.targetRoute == '/activity' &&
                          widget.onNavigateToTab != null) {
                        widget.onNavigateToTab!(2);
                      } else if (impulse.targetRoute == '/cycle' &&
                          widget.onNavigateToTab != null) {
                        widget.onNavigateToTab!(3);
                      } else {
                        Navigator.pushNamed(context, impulse.targetRoute);
                      }
                    },
                    child: const Text('Öffnen'),
                  ),
                ),
              ),
          ],
        );
      case 'overview':
        return OverviewSummaryCard(
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
          totalKcal: totalKcal ?? (activeKcal + bmr),
          weight: weight,
          weightTrend: weightTrend,
          cycleDay: cycleDay,
          cyclePhase: cyclePhase,
          onNavigateToTab: widget.onNavigateToTab,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
