import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ui/design_system.dart';
import '../../../models/app_state.dart';
import '../../health/domain/health_models.dart';
import '../domain/cardio_metrics_calculator.dart';
import 'activity_controller.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key, this.database, this.controller});

  final AppDatabase? database;
  final ActivityController? controller;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  AppDatabase? _database;
  ActivityController? _controller;
  bool _ownsDatabase = false;
  bool _initialized = false;
  bool _loading = true;
  String? _error;
  List<WorkoutSessionRow> _workouts = const [];
  List<SleepSessionRow> _sleep = const [];
  double? _heartRate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      if (widget.controller != null) {
        _controller = widget.controller;
      } else {
        final fromProvider =
            Provider.of<ActivityController?>(context, listen: false);
        final fromAppState =
            Provider.of<AppState?>(context, listen: false)?.activityController;
        if (fromProvider != null) {
          _controller = fromProvider;
        } else if (fromAppState != null) {
          _controller = fromAppState;
        }
      }

      if (widget.database != null) {
        _database = widget.database!;
      } else if (_controller == null) {
        _database = AppDatabase();
        _ownsDatabase = true;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _load();
        }
      });
    }
  }

  @override
  void dispose() {
    if (_ownsDatabase) {
      _database?.close();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (_controller != null) {
      await _controller!.loadActivityData();
      if (!mounted) return;
      if (_database != null) {
        await _loadDatabaseExtras();
      } else {
        setState(() {
          _loading = false;
          _error = _controller!.errorMessage;
        });
      }
      return;
    }

    await _loadDatabaseExtras();
  }

  Future<void> _loadDatabaseExtras() async {
    if (_database == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final from = DateTime.now().toUtc().subtract(const Duration(days: 30));
      final workouts = await (_database!.select(_database!.workoutSessions)
            ..where((row) =>
                row.startUtc.isBiggerOrEqualValue(from.toIso8601String()))
            ..orderBy([(row) => OrderingTerm.desc(row.startUtc)]))
          .get();
      final sleep = await (_database!.select(_database!.sleepSessions)
            ..where((row) =>
                row.startUtc.isBiggerOrEqualValue(from.toIso8601String()))
            ..orderBy([(row) => OrderingTerm.desc(row.startUtc)]))
          .get();
      final heartRows = await (_database!.select(_database!.healthRecords)
            ..where((row) => row.type.equals('heartRate'))
            ..where((row) =>
                row.startUtc.isBiggerOrEqualValue(from.toIso8601String())))
          .get();
      final average = heartRows.isEmpty
          ? null
          : heartRows.map((row) => row.value).reduce((a, b) => a + b) /
              heartRows.length;
      if (!mounted) return;
      setState(() {
        _workouts = workouts;
        _sleep = sleep;
        _heartRate = average;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Aktivitätsdaten konnten nicht geladen werden.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: LoadingState());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Aktivität')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) ErrorState(message: _error!, onRetry: _load),
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Workouts',
                    value: '${_workouts.length}',
                    subtitle: 'letzte 30 Tage',
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: KpiCard(
                    title: 'Schlafsessions',
                    value: '${_sleep.length}',
                    subtitle: 'importiert',
                    icon: Icons.bedtime_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            KpiCard(
              title: 'Herzfrequenz',
              value: _heartRate == null ? '–' : '${_heartRate!.round()} bpm',
              subtitle: 'Durchschnitt aus verfügbaren Samples',
              icon: Icons.favorite_outline,
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.deepOrangeAccent),
                title: const Text('Kraftsport & Gym (OpenGym)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Geführte Workouts, Progression & Muscle Map'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushNamed(context, '/gym'),
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Workouts'),
            const SizedBox(height: 8),
            if (_workouts.isEmpty)
              const EmptyState(
                title: 'Keine Workouts',
                message:
                    'Importierte Workouts erscheinen hier, sobald Health Connect sie bereitstellt.',
              )
            else
              for (final workout in _workouts)
                _WorkoutTile(database: _database, workout: workout),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Schlaf'),
            const SizedBox(height: 8),
            if (_sleep.isEmpty)
              const EmptyState(
                title: 'Keine Schlafsessions',
                message:
                    'Schlafdaten sind abhängig von Quelle und erteilter Berechtigung.',
              )
            else
              for (final session in _sleep)
                ListTile(
                  leading: const Icon(Icons.bedtime_outlined),
                  title: Text(
                      '${(session.durationMinutes / 60).toStringAsFixed(1)} Stunden'),
                  subtitle:
                      Text('${session.startUtc} · Quelle: ${session.sourceId}'),
                ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile({required this.database, required this.workout});

  final AppDatabase? database;
  final WorkoutSessionRow workout;

  IconData _iconForType(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('bike') || lower.contains('biking') || lower.contains('cycl') || lower.contains('rad')) {
      return Icons.directions_bike;
    }
    if (lower.contains('hike') || lower.contains('hiking') || lower.contains('wander')) {
      return Icons.hiking;
    }
    if (lower.contains('gym') || lower.contains('strength') || lower.contains('kraft') || lower.contains('weight')) {
      return Icons.fitness_center;
    }
    if (lower.contains('walk') || lower.contains('gehen') || lower.contains('spazier')) {
      return Icons.directions_walk;
    }
    return Icons.directions_run;
  }

  @override
  Widget build(BuildContext context) {
    final distance = workout.distanceM;
    final metricText = (distance != null && distance > 0 && workout.durationSeconds > 0)
        ? CardioMetricsCalculator.formatSportMetric(workout.type, distance, workout.durationSeconds)
        : null;

    final isCycling = workout.type.toLowerCase().contains('bike') ||
        workout.type.toLowerCase().contains('biking') ||
        workout.type.toLowerCase().contains('cycl') ||
        workout.type.toLowerCase().contains('rad');

    return Card(
      child: ListTile(
        leading: Icon(_iconForType(workout.type)),
        title: Text(workout.type),
        subtitle: Text(
          '${workout.startUtc} · ${(workout.durationSeconds / 60).round()} min'
          '${distance == null ? '' : ' · ${(distance / 1000).toStringAsFixed(2)} km'}'
          '${metricText == null ? '' : (isCycling ? ' · $metricText' : ' · Pace $metricText')}\n'
          'Quelle: ${workout.sourceId}',
        ),
        trailing: workout.routeStatus == 'available' && database != null
            ? IconButton(
                tooltip: 'Route anzeigen',
                icon: const Icon(Icons.map_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutRoutePage(
                      database: database!,
                      workout: workout,
                    ),
                  ),
                ),
              )
            : const Icon(Icons.route_outlined),
      ),
    );
  }
}

class WorkoutRoutePage extends StatefulWidget {
  const WorkoutRoutePage(
      {super.key, required this.database, required this.workout});

  final AppDatabase database;
  final WorkoutSessionRow workout;

  @override
  State<WorkoutRoutePage> createState() => _WorkoutRoutePageState();
}

class _WorkoutRoutePageState extends State<WorkoutRoutePage> {
  late Future<List<WorkoutRoutePointRow>> _points;
  static const _calculator = CardioMetricsCalculator();

  @override
  void initState() {
    super.initState();
    _points = (widget.database.select(widget.database.workoutRoutePoints)
          ..where((row) => row.workoutId.equals(widget.workout.id))
          ..orderBy([(row) => OrderingTerm(expression: row.sequence)]))
        .get();
  }

  Future<void> _exportGpx(List<WorkoutRoutePointRow> points) async {
    final pointModels = points
        .map((p) => WorkoutRoutePointModel(
              latitude: p.latitude,
              longitude: p.longitude,
              timestampUtc: DateTime.tryParse(p.timestampUtc) ?? DateTime.now(),
            ))
        .toList();

    final gpxContent = CardioMetricsCalculator.generateGpxString(
      workoutName: '${widget.workout.type} (${widget.workout.startUtc})',
      points: pointModels,
    );

    await Share.share(gpxContent, subject: '${widget.workout.type}_route.gpx');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCycling = widget.workout.type.toLowerCase().contains('bike') ||
        widget.workout.type.toLowerCase().contains('cycl') ||
        widget.workout.type.toLowerCase().contains('rad');

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.workout.type} · Analyse'),
        actions: [
          FutureBuilder<List<WorkoutRoutePointRow>>(
            future: _points,
            builder: (ctx, snap) {
              if (snap.hasData && snap.data!.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'GPX Exportieren',
                  onPressed: () => _exportGpx(snap.data!),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<WorkoutRoutePointRow>>(
        future: _points,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingState();
          final points = snapshot.data!;
          if (points.isEmpty) {
            return const EmptyState(
              title: 'Keine Route verfügbar',
              message: 'Die Quelle hat für dieses Workout keine GPS-Punkte bereitgestellt.',
            );
          }

          final locations = points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList(growable: false);
          final center = locations[locations.length ~/ 2];

          final pointModels = points
              .map((p) => WorkoutRoutePointModel(
                    latitude: p.latitude,
                    longitude: p.longitude,
                    timestampUtc: DateTime.tryParse(p.timestampUtc) ?? DateTime.now(),
                  ))
              .toList();

          final workoutDetail = WorkoutDetail(
            id: widget.workout.id,
            type: widget.workout.type,
            startUtc: DateTime.parse(widget.workout.startUtc),
            endUtc: DateTime.parse(widget.workout.endUtc),
            durationSeconds: widget.workout.durationSeconds,
            distanceMeters: widget.workout.distanceM,
            energyKcal: widget.workout.energyKcal,
            routeStatus: widget.workout.routeStatus,
            sourceId: widget.workout.sourceId,
            routePoints: pointModels,
          );

          final splits = _calculator.calculateSplits(workoutDetail);
          final hrZones = _calculator.calculateHeartRateZones(190);

          final distanceKm = (widget.workout.distanceM ?? 0) / 1000.0;
          final durationMin = (widget.workout.durationSeconds / 60).round();
          final metricFormatted = CardioMetricsCalculator.formatSportMetric(
            widget.workout.type,
            widget.workout.distanceM ?? 0.0,
            widget.workout.durationSeconds,
          );

          return ListView(
            children: [
              // Map View Card
              SizedBox(
                height: 260,
                child: FlutterMap(
                  options: MapOptions(initialCenter: center, initialZoom: 13),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.macro_mate',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(points: locations, strokeWidth: 4, color: Colors.blueAccent),
                      ],
                    ),
                  ],
                ),
              ),

              // KPI Stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _KpiTile(
                            title: 'Distanz',
                            value: '${distanceKm.toStringAsFixed(2)} km',
                            icon: Icons.straighten,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _KpiTile(
                            title: 'Dauer',
                            value: '$durationMin min',
                            icon: Icons.timer_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _KpiTile(
                            title: isCycling ? 'Geschwindigkeit' : 'Pace',
                            value: metricFormatted,
                            icon: isCycling ? Icons.speed : Icons.directions_run,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Kilometer Splits Table
                    if (splits.isNotEmpty) ...[
                      Text(
                        'Kilometer-Splits',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 40, child: Text('Km', style: TextStyle(fontWeight: FontWeight.bold))),
                                    const Expanded(child: Text('Dauer', style: TextStyle(fontWeight: FontWeight.bold))),
                                    Text(isCycling ? 'Schnitt' : 'Pace', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const Divider(),
                              for (final split in splits)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          '${split.km}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${(split.durationSeconds / 60).floor()}:${(split.durationSeconds.round() % 60).toString().padLeft(2, '0')} min',
                                        ),
                                      ),
                                      Text(
                                        isCycling ? split.formattedSpeed : split.formattedPace,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Heart Rate Zones
                    Text(
                      'Herzfrequenz-Zonen (Referenz)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            for (final z in hrZones) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _zoneColor(z.zone),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Z${z.zone}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(z.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          if (z.description != null)
                                            Text(z.description!, style: TextStyle(color: theme.hintColor, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${z.minBpm} - ${z.maxBpm} bpm',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _zoneColor(int zone) {
    return switch (zone) {
      1 => Colors.grey,
      2 => Colors.blue,
      3 => Colors.green,
      4 => Colors.orange,
      _ => Colors.red,
    };
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
            Text(title, style: TextStyle(color: theme.hintColor, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
