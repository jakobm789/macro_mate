import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/app_database.dart';
import '../../core/ui/design_system.dart';
import '../../features/activity/presentation/activity_page.dart';
import '../../features/cycle/presentation/cycle_page.dart';
import '../../features/dashboard/presentation/today_page.dart';
import '../../features/health/presentation/health_controller.dart';
import '../../models/app_state.dart';
import '../../pages/home_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.database,
    this.enablePeriodicSync = true,
  });

  final AppDatabase? database;
  final bool enablePeriodicSync;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0;
  HealthController? _healthController;

  @override
  void initState() {
    super.initState();
    if (widget.enablePeriodicSync) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.enablePeriodicSync) {
      final health = Provider.of<HealthController?>(context, listen: false) ??
          Provider.of<AppState?>(context, listen: false)?.healthController;
      if (_healthController != health) {
        _healthController?.stopPeriodicForegroundSync();
        _healthController = health;
        _healthController?.startPeriodicForegroundSync(
          interval: const Duration(seconds: 30),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.enablePeriodicSync) {
      _healthController?.handleLifecycleChange(state);
    }
  }

  @override
  void dispose() {
    if (widget.enablePeriodicSync) {
      WidgetsBinding.instance.removeObserver(this);
      _healthController?.stopPeriodicForegroundSync();
    }
    super.dispose();
  }

  void _onSelectTab(int index) {
    if (_index != index) {
      setState(() => _index = index);
    }
  }

  void _goToHome() {
    if (_index != 0) {
      setState(() => _index = 0);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: _index == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _goToHome();
        },
        child: Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              TodayPage(onNavigateToTab: _onSelectTab),
              MyHomePage(title: 'Ernährung', onBackToHome: _goToHome),
              ActivityPage(database: widget.database, onBackToHome: _goToHome),
              CyclePage(onBackToHome: _goToHome),
              MorePage(onBackToHome: _goToHome),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (index) => setState(() => _index = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today),
                label: 'Heute',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_outlined),
                selectedIcon: Icon(Icons.restaurant),
                label: 'Ernährung',
              ),
              NavigationDestination(
                icon: Icon(Icons.directions_run_outlined),
                selectedIcon: Icon(Icons.directions_run),
                label: 'Aktivität',
              ),
              NavigationDestination(
                icon: Icon(Icons.water_drop_outlined),
                selectedIcon: Icon(Icons.water_drop),
                label: 'Zyklus',
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz),
                selectedIcon: Icon(Icons.more),
                label: 'Mehr',
              ),
            ],
          ),
        ),
      );
}

class MorePage extends StatelessWidget {
  const MorePage({super.key, this.onBackToHome});

  final VoidCallback? onBackToHome;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: onBackToHome != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Zurück zur Hauptseite',
                  onPressed: onBackToHome,
                )
              : null,
          title: const Text('Mehr'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Verwalten'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: const Text('Kraftsport & Gym (OpenGym)'),
                    subtitle: const Text(
                        'Pläne, Live-Workout, Muscle Map & AI Coach'),
                    onTap: () => Navigator.pushNamed(context, '/gym'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.monitor_weight_outlined),
                    title: const Text('Gewicht'),
                    onTap: () => Navigator.pushNamed(context, '/weight'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Einstellungen'),
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.health_and_safety_outlined),
                    title: const Text('Health Connect & Diagnose'),
                    onTap: () => Navigator.pushNamed(context, '/health'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('Backup & Wiederherstellung'),
                    onTap: () => Navigator.pushNamed(context, '/backup'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.insights_outlined),
                    title: const Text('Ernährungs-Wochenbericht'),
                    onTap: () =>
                        Navigator.pushNamed(context, '/weekly_dashboard'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Health- und Zyklusdaten werden nicht an den bestehenden PostgreSQL-Zugang übertragen.',
            ),
          ],
        ),
      );
}
