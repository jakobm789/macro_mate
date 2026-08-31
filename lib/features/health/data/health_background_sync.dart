import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/database/app_database.dart';
import 'drift_health_repository.dart';
import 'health_connect_source.dart';

const healthBackgroundTask = 'health-connect-sync';
bool _backgroundSyncInitialized = false;

/// Registers a best-effort periodic refresh. Health permissions are never
/// requested from the worker; a user must opt in from the Health screen first.
Future<void> initializeHealthBackgroundSync() async {
  if ((!Platform.isAndroid && !Platform.isIOS) || _backgroundSyncInitialized) {
    return;
  }
  await Workmanager().initialize(healthBackgroundCallback);
  await Workmanager().registerPeriodicTask(
    healthBackgroundTask,
    healthBackgroundTask,
    frequency: const Duration(hours: 6),
    // Health Connect is local; requiring a network would unnecessarily stop
    // imports while the device is offline.
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
  _backgroundSyncInitialized = true;
}

@pragma('vm:entry-point')
void healthBackgroundCallback() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (task != healthBackgroundTask) return true;
    final database = AppDatabase();
    try {
      final repository = DriftHealthRepository(
        database: database,
        source: HealthConnectSource(),
      );
      final now = DateTime.now().toUtc();
      await repository.sync(
        startUtc: now.subtract(const Duration(days: 2)),
        endUtc: now,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      await database.close();
    }
  });
}
