import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/ui/design_system.dart';
import '../../features/activity/presentation/activity_page.dart';
import '../../features/cycle/presentation/cycle_page.dart';
import '../../features/dashboard/presentation/today_page.dart';
import '../../pages/home_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.database});

  final AppDatabase? database;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            const TodayPage(),
            const MyHomePage(title: 'Ernährung'),
            ActivityPage(database: widget.database),
            CyclePage(database: widget.database),
            const MorePage(),
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
      );
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Mehr')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Verwalten'),
            Card(
              child: Column(
                children: [
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
