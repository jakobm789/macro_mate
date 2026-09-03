import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/database/app_database.dart';
import '../../../models/app_state.dart';
import '../domain/location_tracker_service.dart';
import 'activity_page.dart';
import 'running_tracker_controller.dart';

class LiveRunningTrackerPage extends StatefulWidget {
  const LiveRunningTrackerPage({
    super.key,
    this.initialSport = SportType.running,
    this.database,
  });

  final SportType initialSport;
  final AppDatabase? database;

  @override
  State<LiveRunningTrackerPage> createState() => _LiveRunningTrackerPageState();
}

class _LiveRunningTrackerPageState extends State<LiveRunningTrackerPage> {
  final MapController _mapController = MapController();
  bool _followRunner = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _getController(context);
      if (!controller.isTrackingActive) {
        controller.setSport(widget.initialSport);
      }
    });
  }

  RunningTrackerController _getController(BuildContext context,
      {bool listen = false}) {
    try {
      return listen
          ? context.watch<RunningTrackerController>()
          : context.read<RunningTrackerController>();
    } catch (_) {
      final appState =
          listen ? context.watch<AppState?>() : context.read<AppState?>();
      if (appState != null) return appState.runningTrackerController;
      rethrow;
    }
  }

  AppDatabase? _getDatabase(BuildContext context) {
    if (widget.database != null) return widget.database;
    try {
      return context.read<AppDatabase>();
    } catch (_) {
      try {
        final appState = context.read<AppState?>();
        return appState?.database;
      } catch (_) {
        return null;
      }
    }
  }

  void _recenterMap(LatLng target) {
    _followRunner = true;
    _mapController.move(target, 16);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _getController(context, listen: true);
    final theme = Theme.of(context);

    final hasPoints = controller.routePoints.isNotEmpty;
    final currentLatLng = hasPoints
        ? LatLng(controller.routePoints.last.latitude,
            controller.routePoints.last.longitude)
        : const LatLng(52.5200, 13.4050);

    final startLatLng = hasPoints
        ? LatLng(controller.routePoints.first.latitude,
            controller.routePoints.first.longitude)
        : null;

    final polylinePoints = controller.routePoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);

    if (_followRunner && hasPoints) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          final zoom = _mapController.camera.zoom;
          _mapController.move(currentLatLng, zoom);
        } catch (_) {}
      });
    }

    final isCycling = controller.sport == SportType.cycling;

    return PopScope(
      canPop: !controller.isTrackingActive,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmDiscard(context, controller);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (controller.isTrackingActive) {
                _confirmDiscard(context, controller);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text('${controller.sport.displayName} · Tracker'),
        actions: [
          // Auto Pause Switch
          IconButton(
            icon: Icon(
              controller.autoPauseEnabled
                  ? Icons.pause_circle_filled
                  : Icons.pause_circle_outline,
              color:
                  controller.autoPauseEnabled ? Colors.deepOrangeAccent : null,
            ),
            tooltip:
                'Auto-Pause: ${controller.autoPauseEnabled ? "Aktiv" : "Aus"}',
            onPressed: () =>
                controller.toggleAutoPause(!controller.autoPauseEnabled),
          ),
          if (controller.splits.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.format_list_numbered),
              tooltip: 'Splits ansehen',
              onPressed: () => _showSplitsModal(context, controller),
            ),
        ],
      ),
      body: Column(
        children: [
          // Sport Selector (Only shown before start)
          if (!controller.isTrackingActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: SportType.values.map((sport) {
                    final isSelected = controller.sport == sport;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_sportIcon(sport), size: 16),
                            const SizedBox(width: 6),
                            Text(sport.displayName),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) => controller.setSport(sport),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Map Area
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: currentLatLng,
                    initialZoom: 15.5,
                    onPositionChanged: (pos, hasGesture) {
                      if (hasGesture) {
                        setState(() => _followRunner = false);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.macro_mate',
                    ),
                    if (polylinePoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: polylinePoints,
                            strokeWidth: 5,
                            color: Colors.deepOrangeAccent,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (startLatLng != null)
                          Marker(
                            point: startLatLng,
                            width: 24,
                            height: 24,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        Marker(
                          point: currentLatLng,
                          width: 32,
                          height: 32,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Re-center button
                if (!_followRunner)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.small(
                      heroTag: 'recenter_map',
                      onPressed: () => _recenterMap(currentLatLng),
                      child: const Icon(Icons.my_location),
                    ),
                  ),

                // Split Achievement Notification Banner
                if (controller.lastSplitNotification != null)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6)
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events,
                              color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.lastSplitNotification!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.clearSplitNotification,
                            child: const Icon(Icons.close,
                                color: Colors.white70, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Cockpit Metrics Dashboard
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2)),
                ],
              ),
              child: Column(
                children: [
                  // Primary Focus Metric
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        isCycling
                            ? controller.currentSpeedKmh.toStringAsFixed(1)
                            : (controller.currentPaceMinPerKm != null
                                ? _formatPace(controller.currentPaceMinPerKm!)
                                : '--:--'),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.sport.primaryMetricUnit,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Secondary 3-Column Metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricTile(
                        label: 'Distanz',
                        value: '${controller.distanceKm.toStringAsFixed(2)} km',
                      ),
                      _MetricTile(
                        label: 'Zeit',
                        value: RunningTrackerController.formatDuration(
                            controller.elapsedSeconds),
                      ),
                      _MetricTile(
                        label: 'Kalorien',
                        value:
                            '${controller.activeCaloriesBurned.round()} kcal',
                      ),
                      _MetricTile(
                        label: isCycling ? 'Schnitt' : 'Ø Pace',
                        value: isCycling
                            ? '${(controller.distanceKm / (controller.elapsedSeconds > 0 ? controller.elapsedSeconds / 3600.0 : 1.0)).toStringAsFixed(1)} km/h'
                            : (controller.averagePaceMinPerKm != null
                                ? _formatPace(controller.averagePaceMinPerKm!)
                                : '--:--'),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Bottom Action Controls
                  if (!controller.isTrackingActive)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.play_arrow, size: 28),
                        label: Text('START (${controller.sport.displayName})',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          final started = await controller.startWorkout();
                          if (!started && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Standortberechtigung ist erforderlich zum Tracken.'),
                              ),
                            );
                          }
                        },
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Discard Button
                        IconButton.filledTonal(
                          iconSize: 28,
                          tooltip: 'Abbrechen',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDiscard(context, controller),
                        ),

                        // Pause / Resume Main Button
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: controller.isRunning
                                  ? Colors.orange.shade700
                                  : Colors.green.shade600,
                              foregroundColor: Colors.white,
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              if (controller.isRunning) {
                                controller.pauseWorkout();
                              } else {
                                controller.resumeWorkout();
                              }
                            },
                            child: Icon(
                              controller.isRunning
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 38,
                            ),
                          ),
                        ),

                        // Finish Button
                        IconButton.filled(
                          iconSize: 28,
                          tooltip: 'Abschließen',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.stop),
                          onPressed: () =>
                              _confirmFinish(context, controller),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  void _showSplitsModal(
      BuildContext context, RunningTrackerController controller) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kilometer-Splits',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.splits.length,
                itemBuilder: (ctx, i) {
                  final split = controller.splits[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepOrangeAccent,
                      foregroundColor: Colors.white,
                      child: Text('${split.km}'),
                    ),
                    title: Text(split.formattedPace),
                    subtitle: Text(
                        'Dauer: ${(split.durationSeconds / 60).floor()}:${(split.durationSeconds.round() % 60).toString().padLeft(2, '0')} min'),
                    trailing: Text(split.formattedSpeed),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmFinish(
    BuildContext context,
    RunningTrackerController controller,
  ) async {
    final finish = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Workout beenden?'),
        content: Text(
          'Du bist ${controller.distanceKm.toStringAsFixed(2)} km in '
          '${RunningTrackerController.formatDuration(controller.elapsedSeconds)} gelaufen. '
          'Möchtest du das Workout speichern?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Weiter trainieren'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Speichern & Beenden'),
          ),
        ],
      ),
    );

    if (finish == true) {
      if (!context.mounted) return;
      final db = _getDatabase(context) ?? AppDatabase();
      final savedWorkout = await controller.finishAndSaveWorkout(db);
      if (context.mounted) {
        if (savedWorkout != null) {
          // Replace tracker with detailed route view
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutRoutePage(
                database: db,
                workout: savedWorkout,
              ),
            ),
          );
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _confirmDiscard(
      BuildContext context, RunningTrackerController controller) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Workout verwerfen?'),
        content: const Text(
            'Möchtest du die bisherige Aufzeichnung unwiderruflich löschen?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Verwerfen'),
          ),
        ],
      ),
    );

    if (discard == true) {
      controller.discardWorkout();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  String _formatPace(double paceMinPerKm) {
    if (paceMinPerKm <= 0 || paceMinPerKm > 30) return '--:--';
    final minutes = paceMinPerKm.floor();
    final seconds = ((paceMinPerKm - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  IconData _sportIcon(SportType sport) {
    return switch (sport) {
      SportType.running => Icons.directions_run,
      SportType.cycling => Icons.directions_bike,
      SportType.hiking => Icons.terrain,
      SportType.walking => Icons.directions_walk,
    };
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      ],
    );
  }
}
