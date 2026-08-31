import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:drift/drift.dart';
import 'package:provider/provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ui/design_system.dart';
import '../../../models/app_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final distance = workout.distanceM;
    final pace =
        distance == null || distance <= 0 || workout.durationSeconds <= 0
            ? null
            : workout.durationSeconds / 60 / (distance / 1000);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.directions_run),
        title: Text(workout.type),
        subtitle: Text(
          '${workout.startUtc} · ${(workout.durationSeconds / 60).round()} min'
          '${distance == null ? '' : ' · ${(distance / 1000).toStringAsFixed(2)} km'}'
          '${pace == null ? '' : ' · Pace ${pace.toStringAsFixed(1)} min/km'}\n'
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

  @override
  void initState() {
    super.initState();
    _points = (widget.database.select(widget.database.workoutRoutePoints)
          ..where((row) => row.workoutId.equals(widget.workout.id))
          ..orderBy([(row) => OrderingTerm(expression: row.sequence)]))
        .get();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('${widget.workout.type} · Route')),
        body: FutureBuilder<List<WorkoutRoutePointRow>>(
          future: _points,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingState();
            final points = snapshot.data!;
            if (points.isEmpty) {
              return const EmptyState(
                title: 'Keine Route verfügbar',
                message:
                    'Die Quelle hat für dieses Workout keine GPS-Punkte bereitgestellt.',
              );
            }
            final locations = points
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList(growable: false);
            final center = locations[locations.length ~/ 2];
            return FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 13),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.macro_mate',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                        points: locations, strokeWidth: 4, color: Colors.blue),
                  ],
                ),
              ],
            );
          },
        ),
      );
}
