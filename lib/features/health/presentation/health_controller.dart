import 'package:flutter/foundation.dart';

import '../domain/health_models.dart';
import '../domain/health_repository.dart';

class HealthController extends ChangeNotifier {
  HealthController({required HealthRepository repository})
      : _repository = repository;

  final HealthRepository _repository;
  HealthAvailability? availabilityState;
  HealthPermissionState? permissionState;
  List<DailyHealthSummary> summariesState = const [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    await _run(() async {
      availabilityState = await _repository.availability();
      permissionState = await _repository.permissions();
      if (permissionState?.readGranted == true) {
        await _loadSummaries();
      }
    });
  }

  Future<void> requestPermissions({
    bool includeHistory = false,
    bool includeBackground = false,
  }) async {
    await _run(() async {
      permissionState = await _repository.requestPermissions(
        includeHistory: includeHistory,
        includeBackground: includeBackground,
      );
      if (permissionState?.readGranted == true) {
        await _syncLast30Days();
      }
    });
  }

  Future<void> syncLast30Days() async {
    await _run(_syncLast30Days);
  }

  Future<void> _syncLast30Days() async {
    final now = DateTime.now().toUtc();
    final start = now.subtract(const Duration(days: 30));
    summariesState = await _repository.sync(startUtc: start, endUtc: now);
  }

  Future<void> revokePermissions() async {
    await _run(() async {
      await _repository.revokePermissions();
      permissionState = await _repository.permissions();
      summariesState = const [];
    });
  }

  Future<void> _loadSummaries() async {
    final now = DateTime.now();
    summariesState = await _repository.summaries(
      startDay: now.subtract(const Duration(days: 30)),
      endDay: now,
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
