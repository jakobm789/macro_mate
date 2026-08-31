import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/core/time/clock.dart';
import 'package:macro_mate/features/cycle/data/drift_cycle_repository.dart';
import 'package:macro_mate/features/cycle/domain/cycle_models.dart';

void main() {
  late AppDatabase database;
  late DriftCycleRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftCycleRepository(
      database: database,
      clock: FixedClock(DateTime.utc(2026, 8, 31, 12)),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('supports period and daily-log CRUD with deterministic timestamps',
      () async {
    await repository.addPeriod(
      startDay: DateTime(2026, 8, 1),
      endDay: DateTime(2026, 8, 5),
      flow: BleedingLevel.medium,
    );
    var periods = await repository.periods();
    expect(periods, hasLength(1));
    expect(periods.single.endDay, DateTime(2026, 8, 5));
    expect(periods.single.flow, BleedingLevel.medium);

    final id = periods.single.id;
    await repository.updatePeriod(
      id: id,
      startDay: DateTime(2026, 8, 2),
      endDay: DateTime(2026, 8, 6),
      flow: BleedingLevel.light,
    );
    periods = await repository.periods();
    expect(periods.single.startDay, DateTime(2026, 8, 2));
    expect(periods.single.flow, BleedingLevel.light);

    final log = CycleDailyLog(
      day: DateTime(2026, 8, 3),
      mood: 'ruhig',
      pain: 2,
      energy: 7,
      sleepQuality: 8,
      tags: const ['Kopfweh'],
    );
    await repository.saveDailyLog(log);
    expect((await repository.dailyLogs()).single.mood, 'ruhig');
    await repository.deleteDailyLog(log.day);
    expect(await repository.dailyLogs(), isEmpty);

    await repository.deletePeriod(id);
    expect(await repository.periods(), isEmpty);
  });

  test('rejects invalid period and intensity ranges', () async {
    expect(
      () => repository.addPeriod(
        startDay: DateTime(2026, 8, 5),
        endDay: DateTime(2026, 8, 1),
      ),
      throwsArgumentError,
    );
    expect(
      () => repository.saveDailyLog(
        CycleDailyLog(day: DateTime(2026, 8, 1), pain: 11),
      ),
      throwsArgumentError,
    );
  });
}
