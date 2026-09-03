import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ui/design_system.dart';
import '../../health/presentation/health_controller.dart';
import '../data/drift_cycle_repository.dart';
import '../domain/cycle_engine.dart';
import '../domain/cycle_models.dart';
import '../../../models/app_state.dart';
import 'cycle_controller.dart';
import 'cycle_import_preview_sheet.dart';
import 'correlations_page.dart';

class CyclePage extends StatefulWidget {
  const CyclePage({
    super.key,
    this.database,
    this.controller,
    this.initialFocusedDay,
    this.onBackToHome,
  });

  final AppDatabase? database;
  final CycleController? controller;
  final DateTime? initialFocusedDay;
  final VoidCallback? onBackToHome;

  @override
  State<CyclePage> createState() => _CyclePageState();
}

class _CyclePageState extends State<CyclePage> {
  late CycleController _controller;
  AppDatabase? _database;
  bool _ownsDatabase = false;
  bool _ownsController = false;
  bool _initialized = false;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay ?? DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      if (widget.controller != null) {
        _controller = widget.controller!;
      } else {
        final fromProvider =
            Provider.of<CycleController?>(context, listen: false);
        final fromAppState =
            Provider.of<AppState?>(context, listen: false)?.cycleController;
        if (fromProvider != null) {
          _controller = fromProvider;
        } else if (fromAppState != null) {
          _controller = fromAppState;
        } else {
          if (widget.database != null) {
            _database = widget.database!;
          } else {
            _database = AppDatabase();
            _ownsDatabase = true;
          }
          _controller = CycleController(
            repository: DriftCycleRepository(database: _database!),
          )..load();
          _ownsController = true;
        }
      }
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsDatabase) {
      _database?.close();
    }
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
    if (date == null) return;
    if (!mounted) return;
    final endDate = await showDatePicker(
      context: context,
      firstDate: date,
      lastDate: DateTime.now(),
      initialDate: date,
      helpText: 'Letzter Tag (optional)',
    );
    if (!mounted) return;
    await _controller.addPeriod(date, endDay: endDate);
  }

  Future<void> _editPeriod(PeriodEntry period) async {
    final start = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
      initialDate: period.startDay,
      helpText: 'Erster Tag der Periode',
    );
    if (start == null || !mounted) return;
    final end = await showDatePicker(
      context: context,
      firstDate: start,
      lastDate: DateTime.now(),
      initialDate: period.endDay ?? start,
      helpText: 'Letzter Tag der Periode',
    );
    if (!mounted) return;
    await _controller.updatePeriod(
      id: period.id,
      startDay: start,
      endDay: end,
      flow: period.flow,
    );
  }

  Future<void> _deletePeriod(PeriodEntry period) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Periode löschen?'),
        content:
            const Text('Der lokale Periodeneintrag wird dauerhaft gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _controller.deletePeriod(period.id);
  }

  Future<void> _saveTodayLog() async {
    var pain = 0;
    var energy = 3;
    var sleepQuality = 3;
    var bleeding = BleedingLevel.none;
    String? mood;
    var notes = '';
    final result = await showDialog<
        ({
          int pain,
          int energy,
          int sleepQuality,
          BleedingLevel bleeding,
          String? mood,
          String notes,
        })>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Check-in für ${_format(_selectedDay ?? DateTime.now())}'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<BleedingLevel>(
                  initialValue: bleeding,
                  decoration: const InputDecoration(labelText: 'Blutung'),
                  items: [
                    for (final item in BleedingLevel.values)
                      DropdownMenuItem(value: item, child: Text(item.name)),
                  ],
                  onChanged: (value) => setState(() {
                    if (value != null) bleeding = value;
                  }),
                ),
                DropdownButtonFormField<String>(
                  initialValue: mood,
                  decoration: const InputDecoration(labelText: 'Stimmung'),
                  items: const [
                    DropdownMenuItem(value: 'ruhig', child: Text('Ruhig')),
                    DropdownMenuItem(value: 'neutral', child: Text('Neutral')),
                    DropdownMenuItem(
                        value: 'angespannt', child: Text('Angespannt')),
                    DropdownMenuItem(value: 'traurig', child: Text('Traurig')),
                  ],
                  onChanged: (value) => setState(() => mood = value),
                ),
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
                  onChanged: (value) => setState(() => energy = value.round()),
                ),
                Text('Schlafqualität: $sleepQuality/5'),
                Slider(
                  value: sleepQuality.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) =>
                      setState(() => sleepQuality = value.round()),
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Notiz (optional)'),
                  maxLines: 2,
                  onChanged: (value) => notes = value,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              (
                pain: pain,
                energy: energy,
                sleepQuality: sleepQuality,
                bleeding: bleeding,
                mood: mood,
                notes: notes,
              ),
            ),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (result != null) {
      await _controller.saveLog(
        CycleDailyLog(
          day: _selectedDay ?? DateTime.now(),
          bleeding:
              result.bleeding == BleedingLevel.none ? null : result.bleeding,
          mood: result.mood,
          pain: result.pain,
          energy: result.energy,
          sleepQuality: result.sleepQuality,
          notes: result.notes.isEmpty ? null : result.notes,
        ),
      );
    }
  }

  Future<void> _openHealthImport() async {
    final hasPerm = await _controller.hasMenstruationPermission();
    if (!mounted) return;
    if (!hasPerm) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Menstruationsdaten importieren'),
          content: const Text(
            'Health Connect benötigt deine ausdrückliche Zustimmung, um Menstruationsdaten zu lesen. '
            'Deine Zyklusdaten bleiben stets lokal auf diesem Gerät gespeichert.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Berechtigung anfordern'),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }

    final result = await _controller.previewHealthConnectImport();
    if (!mounted) return;

    switch (result) {
      case MenstruationImportSuccess(:final conflicts):
        if (conflicts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Keine neuen Menstruationsdaten in Health Connect gefunden.',
              ),
            ),
          );
          return;
        }
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => ChangeNotifierProvider.value(
            value: _controller,
            child: const CycleImportPreviewSheet(),
          ),
        );
      case MenstruationImportPermissionDenied(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      case MenstruationImportUnavailable(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      case MenstruationImportError(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final forecast = _controller.forecastState;
          final history = CycleEngine.historyStats(_controller.periodsState);
          return Scaffold(
            appBar: AppBar(
              leading: widget.onBackToHome != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Zurück zur Hauptseite',
                      onPressed: widget.onBackToHome,
                    )
                  : null,
              title: const Text('Zyklus & Wohlbefinden'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.sync_alt),
                  tooltip: 'Health Connect Menstruationsimport',
                  onPressed: _openHealthImport,
                ),
              ],
            ),
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
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: TableCalendar<String>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) =>
                          setState(() => _focusedDay = focusedDay),
                      eventLoader: _eventsFor,
                      calendarStyle: const CalendarStyle(
                        markerDecoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child:
                        Text('Legende: ● erfasste Periode · ● Tages-Check-in'),
                  ),
                  if (history.cycleLengths.isNotEmpty ||
                      history.periodLengths.isNotEmpty)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.query_stats),
                        title: const Text('Zyklus-Historie'),
                        subtitle: Text(
                          'Median Zyklus: ${history.medianCycleLength?.toString() ?? '–'} Tage · '
                          'Median Periode: ${history.medianPeriodLength?.toString() ?? '–'} Tage\n'
                          'Streuung: ${history.cycleStandardDeviation?.toStringAsFixed(1) ?? '–'} Tage · '
                          '${history.cycleLengths.length} Intervalle ausgewertet',
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.auto_graph, color: Colors.indigo),
                      title: const Text('Explorative Zusammenhänge'),
                      subtitle: const Text(
                          'Erfahre mehr über Wechselwirkungen zwischen Zyklus, Schlaf, Energie und Aktivität.'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: _controller,
                              child: const CorrelationsPage(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: _controller.isLoading ? null : _saveTodayLog,
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Heutigen Check-in erfassen'),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (ctx) {
                      HealthController? healthCtrl;
                      try {
                        healthCtrl = ctx.watch<HealthController>();
                      } catch (_) {
                        try {
                          healthCtrl = ctx.watch<AppState>().healthController;
                        } catch (_) {}
                      }
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(ctx)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: SyncStatus(
                          lastSyncUtc: healthCtrl?.lastSyncTime,
                          error: healthCtrl?.errorMessage,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
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
                        onTap: () => _editPeriod(period),
                        trailing: IconButton(
                          tooltip: 'Periode löschen',
                          onPressed: _controller.isLoading
                              ? null
                              : () => _deletePeriod(period),
                          icon: const Icon(Icons.delete_outline),
                        ),
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
                            'Schmerz ${log.pain ?? '-'} · Energie ${log.energy ?? '-'}'
                            '${log.mood == null ? '' : ' · ${log.mood}'}'),
                        trailing: IconButton(
                          tooltip: 'Check-in löschen',
                          onPressed: _controller.isLoading
                              ? null
                              : () => _deleteLog(log.day),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      );

  List<String> _eventsFor(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    final events = <String>[];
    for (final period in _controller.periodsState) {
      final end = period.endDay ?? period.startDay;
      final start = DateTime(
        period.startDay.year,
        period.startDay.month,
        period.startDay.day,
      );
      final finish = DateTime(end.year, end.month, end.day);
      if (!normalized.isBefore(start) && !normalized.isAfter(finish)) {
        events.add('period');
        break;
      }
    }
    if (_controller.logsState.any((log) => isSameDay(log.day, normalized))) {
      events.add('log');
    }
    return events;
  }

  Future<void> _deleteLog(DateTime day) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check-in löschen?'),
        content: const Text('Dieser lokale Tageslog wird dauerhaft gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _controller.deleteLog(day);
  }

  String _format(DateTime value) => '${value.day.toString().padLeft(2, '0')}. '
      '${value.month.toString().padLeft(2, '0')}.${value.year}';
}
