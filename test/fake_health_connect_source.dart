import 'package:macro_mate/features/cycle/domain/cycle_models.dart';
import 'package:macro_mate/features/health/data/health_data_source.dart';
import 'package:macro_mate/features/health/domain/health_models.dart';

class FakeHealthConnectSource implements HealthDataSource {
  FakeHealthConnectSource({
    this.availability = HealthAvailability.available,
    HealthPermissionState? initialPermissions,
    this.menstruationPermissionGranted = true,
  }) : permissions = initialPermissions ??
            const HealthPermissionState(
              readGranted: true,
              historyGranted: true,
              backgroundGranted: true,
            );

  HealthAvailability availability;
  HealthPermissionState permissions;
  bool menstruationPermissionGranted;
  final List<HealthRecord> records = [];
  final List<HealthMenstruationRecord> menstruationRecords = [];
  bool shouldThrowOnRead = false;

  @override
  Future<HealthAvailability> getAvailability() async => availability;

  @override
  Future<HealthPermissionState> currentPermissions() async => permissions;

  @override
  Future<HealthPermissionState> requestPermissions({
    bool includeHistory = false,
    bool includeBackground = false,
  }) async {
    permissions = HealthPermissionState(
      readGranted: true,
      historyGranted: includeHistory,
      backgroundGranted: includeBackground,
    );
    return permissions;
  }

  @override
  Future<bool> hasMenstruationPermission() async =>
      menstruationPermissionGranted;

  @override
  Future<bool> requestMenstruationPermission() async {
    menstruationPermissionGranted = true;
    return true;
  }

  @override
  Future<void> revokePermissions() async {
    permissions = const HealthPermissionState(
      readGranted: false,
      historyGranted: false,
      backgroundGranted: false,
    );
  }

  @override
  Future<List<HealthRecord>> read(DateTime startUtc, DateTime endUtc) async {
    if (shouldThrowOnRead) {
      throw Exception('Simulierter Health Connect Verbindungsfehler');
    }
    return records.where((r) {
      return !r.startUtc.isBefore(startUtc) && !r.startUtc.isAfter(endUtc);
    }).toList();
  }

  @override
  Future<List<HealthMenstruationRecord>> readMenstruation(
    DateTime startUtc,
    DateTime endUtc,
  ) async {
    if (shouldThrowOnRead) {
      throw Exception('Simulierter Health Connect Verbindungsfehler');
    }
    if (!menstruationPermissionGranted) {
      throw const HealthPermissionException(
        'Health Connect Menstruationsberechtigung wurde nicht erteilt.',
      );
    }
    return menstruationRecords.where((r) {
      return !r.startDay.isBefore(startUtc) && !r.startDay.isAfter(endUtc);
    }).toList();
  }

  void addRecord(HealthRecord record) {
    records.add(record);
  }

  void addMenstruationRecord(HealthMenstruationRecord record) {
    menstruationRecords.add(record);
  }

  void clear() {
    records.clear();
    menstruationRecords.clear();
  }
}
