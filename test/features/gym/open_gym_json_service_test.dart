import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/gym/data/drift_gym_repository.dart';
import 'package:macro_mate/features/gym/data/open_gym_json_service.dart';

void main() {
  group('OpenGymJsonService Tests', () {
    late AppDatabase db;
    late DriftGymRepository repo;
    late OpenGymJsonService service;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = DriftGymRepository(database: db);
      service = OpenGymJsonService(repository: repo);
    });

    tearDown(() async {
      await db.close();
    });

    test('Imports plan from OpenGym JSON and exports it back', () async {
      const sampleJson = '''
{
  "format": "opengym_plan_v1",
  "name": "Greyskull Linear LP",
  "description": "3-Tage Ganzkörperplan mit AMRAP",
  "daysPerWeek": 3,
  "routines": [
    {
      "name": "Tag A",
      "dayOfWeek": 1,
      "progressionType": "greyskull",
      "exercises": [
        {
          "exerciseId": "ex_bench_press",
          "targetSets": 3,
          "targetRepsMin": 5,
          "targetRepsMax": 5,
          "restSeconds": 150
        }
      ]
    }
  ]
}
''';

      final planId = await service.importPlanFromJson(sampleJson);
      expect(planId, isNotEmpty);

      final activePlan = await repo.getActivePlan();
      expect(activePlan?.name, 'Greyskull Linear LP');

      final exported = await service.exportPlanToJson(planId);
      expect(exported, contains('Greyskull Linear LP'));
      expect(exported, contains('ex_bench_press'));
    });
  });
}
