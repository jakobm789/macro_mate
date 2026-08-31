import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/features/cycle/domain/cycle_engine.dart';
import 'package:macro_mate/features/cycle/domain/cycle_models.dart';

PeriodEntry _period(String id, DateTime start, {DateTime? end}) => PeriodEntry(
      id: id,
      startDay: start,
      endDay: end,
    );

void main() {
  test('uses median cycle interval and estimates fertile window', () {
    final forecast = CycleEngine.forecast(
      periods: [
        _period('1', DateTime(2026, 1, 1), end: DateTime(2026, 1, 5)),
        _period('2', DateTime(2026, 1, 29), end: DateTime(2026, 2, 2)),
        _period('3', DateTime(2026, 2, 26), end: DateTime(2026, 3, 2)),
      ],
      today: DateTime(2026, 2, 10),
    );

    expect(forecast, isNotNull);
    expect(forecast!.cycleLength, 28);
    expect(forecast.periodLength, 5);
    expect(forecast.nextPeriod, DateTime(2026, 3, 26));
    expect(forecast.fertileWindowStart, DateTime(2026, 3, 7));
    expect(forecast.fertileWindowEnd, DateTime(2026, 3, 13));
    expect(forecast.confidence, greaterThan(.5));
  });

  test('falls back to profile defaults with one period', () {
    final forecast = CycleEngine.forecast(
      periods: [_period('1', DateTime(2026, 8, 1))],
      today: DateTime(2026, 8, 10),
      profile:
          const CycleProfile(typicalCycleLength: 30, typicalPeriodLength: 4),
    );

    expect(forecast!.cycleLength, 30);
    expect(forecast.periodLength, 4);
    expect(forecast.cycleDay, 10);
    expect(forecast.confidence, .35);
  });
}
