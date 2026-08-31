import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../data/drift_health_repository.dart';
import '../data/health_connect_source.dart';
import '../domain/health_models.dart';
import 'health_controller.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key, this.database, this.controller});

  final AppDatabase? database;
  final HealthController? controller;

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  late final AppDatabase _database;
  late final HealthController _controller;
  bool _ownsDatabase = false;
  bool _ownsController = false;
  bool _includeHistory = false;
  bool _includeBackground = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      if (widget.database != null) {
        _database = widget.database!;
      } else {
        _database = AppDatabase();
        _ownsDatabase = true;
      }
      _controller = HealthController(
        repository: DriftHealthRepository(
          database: _database,
          source: HealthConnectSource(),
        ),
      )..load();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsDatabase) {
      _database.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final permissions = _controller.permissionState;
        final availability = _controller.availabilityState;
        return Scaffold(
          appBar: AppBar(title: const Text('Health & Aktivität')),
          body: RefreshIndicator(
            onRefresh: _controller.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatusCard(
                  availability: availability,
                  permissions: permissions,
                  loading: _controller.isLoading,
                ),
                if (_controller.syncStatesState.isNotEmpty ||
                    _controller.sourcesState.isNotEmpty)
                  _DiagnosticsCard(controller: _controller),
                if (_controller.errorMessage != null)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_controller.errorMessage!),
                    ),
                  ),
                const SizedBox(height: 12),
                if (permissions?.readGranted != true) ...[
                  SwitchListTile.adaptive(
                    value: _includeHistory,
                    onChanged: (value) =>
                        setState(() => _includeHistory = value),
                    title: const Text('Historische Daten erlauben'),
                    subtitle:
                        const Text('Älter als die standardmäßigen 30 Tage'),
                  ),
                  SwitchListTile.adaptive(
                    value: _includeBackground,
                    onChanged: (value) =>
                        setState(() => _includeBackground = value),
                    title: const Text('Hintergrund-Synchronisierung'),
                    subtitle: const Text(
                        'Nur aktivieren, wenn du sie wirklich brauchst'),
                  ),
                  FilledButton.icon(
                    onPressed: _controller.isLoading
                        ? null
                        : () => _controller.requestPermissions(
                              includeHistory: _includeHistory,
                              includeBackground: _includeBackground,
                            ),
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Health Connect verbinden'),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _controller.isLoading
                              ? null
                              : _controller.syncLast30Days,
                          icon: const Icon(Icons.sync),
                          label: const Text('Jetzt synchronisieren'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Verbindung trennen',
                        onPressed: _controller.isLoading
                            ? null
                            : _controller.revokePermissions,
                        icon: const Icon(Icons.link_off),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Letzte 30 Tage',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (_controller.summariesState.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child:
                          Text('Noch keine Gesundheitsdaten synchronisiert.'),
                    ),
                  )
                else
                  for (final summary in _controller.summariesState)
                    _SummaryCard(summary: summary),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.availability,
    required this.permissions,
    required this.loading,
  });

  final HealthAvailability? availability;
  final HealthPermissionState? permissions;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final label = switch (availability) {
      HealthAvailability.available => 'Health Connect ist verfügbar',
      HealthAvailability.installRequired =>
        'Health Connect muss installiert werden',
      HealthAvailability.permissionRequired => 'Berechtigung erforderlich',
      HealthAvailability.unavailable =>
        'Health Connect ist auf diesem Gerät nicht verfügbar',
      null => 'Health Connect wird geprüft …',
    };
    final color = availability == HealthAvailability.available
        ? Colors.green
        : Theme.of(context).colorScheme.primary;
    return Card(
      child: ListTile(
        leading: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.favorite, color: color),
        title: Text(label),
        subtitle: Text(
          permissions?.readGranted == true
              ? 'Leseberechtigung aktiv'
              : 'Die App liest nur Daten – sie schreibt nichts in Health Connect.',
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final DailyHealthSummary summary;

  @override
  Widget build(BuildContext context) {
    final date = '${summary.day.day.toString().padLeft(2, '0')}. '
        '${summary.day.month.toString().padLeft(2, '0')}.';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _Metric(label: 'Schritte', value: '${summary.steps}'),
                _Metric(
                  label: 'Aktiv',
                  value: '${summary.activeCalories.round()} kcal',
                ),
                _Metric(
                  label: 'Distanz',
                  value:
                      '${(summary.distanceMeters / 1000).toStringAsFixed(1)} km',
                ),
                if (summary.sleepMinutes case final sleep? when sleep > 0)
                  _Metric(
                    label: 'Schlaf',
                    value: '${(sleep / 60).toStringAsFixed(1)} h',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticsCard extends StatelessWidget {
  const _DiagnosticsCard({required this.controller});

  final HealthController controller;

  @override
  Widget build(BuildContext context) {
    final errors = controller.syncStatesState
        .map((state) => state.lastError)
        .whereType<String>()
        .where((error) => error.isNotEmpty)
        .toList(growable: false);
    final lastError = errors.isEmpty ? null : errors.first;
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.monitor_heart_outlined),
        title: const Text('Synchronisationsdiagnose'),
        subtitle: Text(
          controller.lastSuccessfulSyncUtc == null
              ? 'Noch kein erfolgreicher Import'
              : 'Zuletzt erfolgreich: ${controller.lastSuccessfulSyncUtc!.toLocal()}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          for (final state in controller.syncStatesState)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(state.metric.name),
              subtitle: Text(
                '${state.status.name} · Cursor: ${state.cursorUtc?.toLocal() ?? '–'}',
              ),
              trailing: state.lastError == null
                  ? null
                  : const Icon(Icons.error_outline, color: Colors.orange),
            ),
          if (controller.sourcesState.isNotEmpty) ...[
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Erkannte Quellen'),
            ),
            for (final source in controller.sourcesState)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${source.name} · ${source.recordCount} Datensätze · Priorität ${source.priority}',
                ),
              ),
          ],
          if (lastError != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Letzter Fehler: $lastError',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Text('$label: $value');
}
