import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../data/drift_cycle_repository.dart';
import '../domain/cycle_models.dart';
import 'cycle_controller.dart';

class CyclePage extends StatefulWidget {
  const CyclePage({super.key});

  @override
  State<CyclePage> createState() => _CyclePageState();
}

class _CyclePageState extends State<CyclePage> {
  late final AppDatabase _database;
  late final CycleController _controller;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
    _controller = CycleController(
      repository: DriftCycleRepository(database: _database),
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _database.close();
    super.dispose();
  }

  Future<void> _addPeriod() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
      helpText: 'Erster Tag der Periode',
    );
    if (date != null) await _controller.addPeriod(date);
  }

  Future<void> _saveTodayLog() async {
    var pain = 0;
    var energy = 3;
    final result = await showDialog<({int pain, int energy})>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tages-Check-in'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  Text('Schmerz: $pain/10'),
                  Slider(
                    value: pain.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    onChanged: (value) => setState(() => pain = value.round()),
                  ),
                  Text('Energie: $energy/5'),
                  Slider(
                    value: energy.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (value) =>
                        setState(() => energy = value.round()),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, (pain: pain, energy: energy)),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (result != null) {
      await _controller.saveLog(
        CycleDailyLog(
          day: DateTime.now(),
          pain: result.pain,
          energy: result.energy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final forecast = _controller.forecastState;
          return Scaffold(
            appBar: AppBar(title: const Text('Zyklus & Wohlbefinden')),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _controller.isLoading ? null : _addPeriod,
              icon: const Icon(Icons.water_drop),
              label: const Text('Periode beginnen'),
            ),
            body: RefreshIndicator(
              onRefresh: _controller.load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_controller.errorMessage != null)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(_controller.errorMessage!),
                      ),
                    ),
                  if (forecast == null)
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.insights),
                        title: Text('Noch keine Vorhersage'),
                        subtitle: Text(
                            'Erfasse den ersten Periodenbeginn für eine lokale Schätzung.'),
                      ),
                    )
                  else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Zyklustag ${forecast.cycleDay}',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text(
                                'Nächste Periode: ${_format(forecast.nextPeriod)}'),
                            Text(
                                'Fruchtbares Fenster: ${_format(forecast.fertileWindowStart)} – '
                                '${_format(forecast.fertileWindowEnd)}'),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(value: forecast.confidence),
                            const SizedBox(height: 4),
                            Text(
                                '${(forecast.confidence * 100).round()} % Konfidenz · ${forecast.rationale}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: _controller.isLoading ? null : _saveTodayLog,
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Heutigen Check-in erfassen'),
                  ),
                  const SizedBox(height: 12),
                  Text('Erfasste Perioden',
                      style: Theme.of(context).textTheme.titleLarge),
                  if (_controller.periodsState.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Noch keine Einträge.'),
                    )
                  else
                    for (final period
                        in _controller.periodsState.reversed.take(8))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_month),
                        title: Text(_format(period.startDay)),
                        subtitle: Text(period.source == 'local'
                            ? 'Manuell erfasst'
                            : period.source),
                      ),
                  if (_controller.logsState.isNotEmpty) ...[
                    const Divider(),
                    Text('Letzte Check-ins',
                        style: Theme.of(context).textTheme.titleLarge),
                    for (final log in _controller.logsState.reversed.take(5))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.mood),
                        title: Text(_format(log.day)),
                        subtitle: Text(
                            'Schmerz ${log.pain ?? '-'} · Energie ${log.energy ?? '-'}'),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      );

  String _format(DateTime value) => '${value.day.toString().padLeft(2, '0')}. '
      '${value.month.toString().padLeft(2, '0')}.${value.year}';
}
