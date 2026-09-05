import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/navigation/app_route_observer.dart';
import '../../../core/ui/design_system.dart';
import '../../../models/app_state.dart';
import 'active_calories_breakdown_sheet.dart';
import 'dashboard_config_sheet.dart';
import 'dashboard_controller.dart';
import 'overview_summary_card.dart';
import 'step_goal_sheet.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({
    super.key,
    this.onNavigateToTab,
    this.isSelectedTab = true,
    this.enableAutoRefresh = true,
    this.autoRefreshInterval = const Duration(seconds: 30),
  });

  final ValueChanged<int>? onNavigateToTab;
  final bool isSelectedTab;
  final bool enableAutoRefresh;
  final Duration autoRefreshInterval;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage>
    with RouteAware, WidgetsBindingObserver {
  Timer? _refreshTimer;
  bool _isTopRoute = true;
  bool _isAppResumed = true;

  bool get _isActive => widget.isSelectedTab && _isTopRoute && _isAppResumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isActive) {
        _reloadAndRestartTimer();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      appRouteObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void didUpdateWidget(covariant TodayPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelectedTab != oldWidget.isSelectedTab ||
        widget.enableAutoRefresh != oldWidget.enableAutoRefresh ||
        widget.autoRefreshInterval != oldWidget.autoRefreshInterval) {
      if (widget.isSelectedTab && widget.enableAutoRefresh) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isActive) {
            _reloadAndRestartTimer();
          }
        });
      } else {
        _stopTimer();
      }
    }
  }

  @override
  void didPushNext() {
    _isTopRoute = false;
    _stopTimer();
  }

  @override
  void didPopNext() {
    _isTopRoute = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isActive) {
        _reloadAndRestartTimer();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppResumed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isActive) {
          _reloadAndRestartTimer();
        }
      });
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _isAppResumed = false;
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _reloadAndRestartTimer() {
    _performReload();
    _startTimer();
  }

  void _startTimer() {
    _stopTimer();
    if (!widget.enableAutoRefresh) return;
    _refreshTimer = Timer.periodic(widget.autoRefreshInterval, (_) {
      if (mounted && _isActive) {
        _performReload();
      }
    });
  }

  void _stopTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _performReload() async {
    if (!mounted) return;
    final dashboard =
        Provider.of<DashboardController?>(context, listen: false) ??
            Provider.of<AppState?>(context, listen: false)?.dashboardController;
    if (dashboard != null) {
      await dashboard.refresh();
    }
  }

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
    final stepGoal = dashboard?.stepGoal ?? appState.dailyStepGoal;
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

    final now = DateTime.now();
    final dayProgress =
        ((now.hour * 3600 + now.minute * 60 + now.second) / 86400.0)
            .clamp(0.0, 1.0);
    final proportionalBmr = dashboard?.proportionalBmr ?? (bmr * dayProgress);

    // Gesamtumsatz = Aktivkalorien + anteiliger Grundumsatz
    final totalKcal =
        dashboard?.totalCalories ?? (activeKcal + proportionalBmr);

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
              await _performReload();
              _startTimer();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _performReload();
          _startTimer();
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
                    stepGoal: stepGoal,
                    distanceKm: distanceKm,
                    activeKcal: activeKcal,
                    totalKcal: totalKcal,
                    bmr: bmr,
                    proportionalBmr: proportionalBmr,
                    missingBmr: missingBmr,
                    weight: weight,
                    weightTrend: weightTrend,
                    lastSync: lastSync,
                    healthError: healthError,
                    cycleDay: cycleDay,
                    cyclePhase: cyclePhase,
                    cycleTip: cycleTip,
                    impulses: impulses,
                    dashboard: dashboard,
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
    int stepGoal = 10000,
    required double distanceKm,
    required double activeKcal,
    required double? totalKcal,
    double bmr = 1750.0,
    double proportionalBmr = 0.0,
    List<String> missingBmr = const [],
    required double? weight,
    required double? weightTrend,
    required DateTime? lastSync,
    required String? healthError,
    required int? cycleDay,
    required String? cyclePhase,
    required String? cycleTip,
    required List<ActionImpulse> impulses,
    DashboardController? dashboard,
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
        final formattedGoal =
            NumberFormat.decimalPattern('de_DE').format(stepGoal);
        return ActivityMetricCard(
          title: 'Schritte & Distanz',
          value: '$steps Schritte',
          subtitle: steps == 0
              ? 'Noch keine Schritte synchronisiert (Ziel: $formattedGoal)'
              : '${distanceKm.toStringAsFixed(1)} km zurückgelegt (Ziel: $formattedGoal)',
          icon: Icons.directions_walk,
          accentColor: Colors.teal,
          progress:
              steps > 0 ? (steps / stepGoal.toDouble()).clamp(0.0, 1.0) : null,
          onTap: () {
            StepGoalSheet.show(
              context,
              currentGoal: stepGoal,
              currentSteps: steps,
              distanceKm: distanceKm,
              onSaveGoal: (newGoal) async {
                if (dashboard != null) {
                  await dashboard.updateStepGoal(newGoal);
                } else {
                  context.read<AppState>().dailyStepGoal = newGoal;
                }
              },
              onNavigateToActivity: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(2);
                } else {
                  Navigator.pushNamed(context, '/activity');
                }
              },
            );
          },
        );
      case 'active_energy':
        final effectiveTotal = totalKcal ?? (activeKcal + proportionalBmr);
        final String subtitleText;
        if (missingBmr.isNotEmpty) {
          subtitleText =
              'Gesamtumsatz: ~${effectiveTotal.round()} kcal · Fehlend für Grundumsatz: ${missingBmr.join(", ")}';
        } else {
          subtitleText = 'Gesamtumsatz: ${effectiveTotal.round()} kcal';
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
          stepGoal: stepGoal,
          distanceKm: distanceKm,
          activeKcal: activeKcal,
          totalKcal: totalKcal ?? (activeKcal + proportionalBmr),
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
