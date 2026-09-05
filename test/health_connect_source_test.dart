import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:macro_mate/core/logging/app_logger.dart';
import 'package:macro_mate/features/health/data/health_connect_source.dart';
import 'package:macro_mate/features/health/domain/health_models.dart';

class _MockHealthClient implements Health {
  bool configureCalled = false;
  List<HealthDataType>? requestedAuthTypes;
  List<HealthDataType>? queriedDataTypes;
  bool shouldThrowOnBatchQuery = false;
  final List<HealthDataType> individuallyQueriedTypes = [];

  @override
  Future<void> configure() async {
    configureCalled = true;
  }

  @override
  bool isDataTypeAvailable(HealthDataType dataType) {
    if (Platform.isAndroid) {
      return dataType != HealthDataType.DISTANCE_WALKING_RUNNING;
    } else {
      return dataType != HealthDataType.DISTANCE_DELTA;
    }
  }

  @override
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) async {
    requestedAuthTypes = List.from(types);
    return true;
  }

  List<HealthDataType>? grantedTypes;

  @override
  Future<bool?> hasPermissions(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) async {
    if (grantedTypes != null) {
      return types.every((t) => grantedTypes!.contains(t));
    }
    return true;
  }

  @override
  Future<List<HealthDataPoint>> getHealthDataFromTypes({
    required List<HealthDataType> types,
    Map<HealthDataType, HealthDataUnit>? preferredUnits,
    required DateTime startTime,
    required DateTime endTime,
    List<RecordingMethod> recordingMethodsToFilter = const [],
  }) async {
    queriedDataTypes = List.from(types);
    if (types.length > 1 && shouldThrowOnBatchQuery) {
      throw Exception('Simulated batch failure');
    }
    if (types.length == 1) {
      individuallyQueriedTypes.add(types.first);
    }
    return [
      HealthDataPoint(
        uuid: 'test-point-1',
        value: NumericHealthValue(numericValue: 1200),
        type: types.first,
        unit: HealthDataUnit.METER,
        dateFrom: startTime,
        dateTo: endTime,
        sourcePlatform: Platform.isAndroid
            ? HealthPlatformType.googleHealthConnect
            : HealthPlatformType.appleHealth,
        sourceDeviceId: 'device-1',
        sourceId: 'src-1',
        sourceName: 'Test Source',
        recordingMethod: RecordingMethod.unknown,
      ),
    ];
  }

  @override
  Future<bool> isHealthDataHistoryAuthorized() async => true;

  @override
  Future<bool> isHealthDataInBackgroundAuthorized() async => true;

  @override
  Future<bool> isHealthDataInBackgroundAvailable() async => true;

  @override
  Future<bool> isHealthConnectAvailable() async => true;

  @override
  Future<int?> getTotalStepsInInterval(
    DateTime startTime,
    DateTime endTime, {
    bool includeManualEntry = true,
  }) async =>
      4000;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _MockHealthClient mockClient;
  late HealthConnectSource source;

  setUp(() {
    mockClient = _MockHealthClient();
    source = HealthConnectSource(
      client: mockClient,
      logger: const AppLogger(),
    );
  });

  group('HealthConnectSource platform compatibility', () {
    test('does not request unsupported distance type on Android', () async {
      await source.requestPermissions();
      expect(mockClient.requestedAuthTypes, isNotNull);
      if (Platform.isAndroid) {
        expect(
          mockClient.requestedAuthTypes!
              .contains(HealthDataType.DISTANCE_WALKING_RUNNING),
          isFalse,
        );
        expect(
          mockClient.requestedAuthTypes!
              .contains(HealthDataType.DISTANCE_DELTA),
          isTrue,
        );
      }
    });

    test('maps distance data correctly without crashing', () async {
      final now = DateTime.utc(2026, 9, 3, 12, 0);
      final records = await source.read(
        now.subtract(const Duration(hours: 1)),
        now,
      );

      expect(records, isNotEmpty);
      expect(records.first.metric, HealthMetric.steps);
    });

    test('recovers from batch query failure by fetching individual types',
        () async {
      mockClient.shouldThrowOnBatchQuery = true;
      final now = DateTime.utc(2026, 9, 3, 12, 0);

      final records = await source.read(
        now.subtract(const Duration(hours: 1)),
        now,
      );

      expect(records, isNotEmpty);
      expect(mockClient.individuallyQueriedTypes, isNotEmpty);
    });

    test(
      'currentPermissions grants read when subset of types is authorized',
      () async {
        mockClient.grantedTypes = [
          HealthDataType.STEPS,
          HealthDataType.ACTIVE_ENERGY_BURNED,
        ];
        final perms = await source.currentPermissions();
        expect(perms.readGranted, isTrue);

        // Queries only granted types in read()
        final now = DateTime.utc(2026, 9, 3, 12, 0);
        await source.read(now.subtract(const Duration(hours: 1)), now);
        expect(mockClient.queriedDataTypes, isNotNull);
        expect(
          mockClient.queriedDataTypes!.contains(HealthDataType.STEPS),
          isTrue,
        );
        expect(
          mockClient.queriedDataTypes!.contains(HealthDataType.SLEEP_SESSION),
          isFalse,
        );
      },
    );

    test('currentPermissions denies read when no types are authorized',
        () async {
      mockClient.grantedTypes = [];
      final perms = await source.currentPermissions();
      expect(perms.readGranted, isFalse);
    });
  });
}
