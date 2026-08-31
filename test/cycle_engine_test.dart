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

  test('ignores an isolated long-cycle outlier for the median', () {
    final forecast = CycleEngine.forecast(
      periods: [
        _period('1', DateTime(2026, 1, 1)),
        _period('2', DateTime(2026, 1, 29)),
        _period('3', DateTime(2026, 2, 26)),
        _period('4', DateTime(2026, 5, 17)),
      ],
      today: DateTime(2026, 3, 1),
    );

    expect(forecast, isNotNull);
    expect(forecast!.cycleLength, 28);
  });

  test('reports historical median and spread', () {
    final stats = CycleEngine.historyStats([
      _period('1', DateTime(2026, 1, 1), end: DateTime(2026, 1, 5)),
      _period('2', DateTime(2026, 1, 29), end: DateTime(2026, 2, 2)),
      _period('3', DateTime(2026, 2, 26), end: DateTime(2026, 3, 2)),
    ]);

    expect(stats.medianCycleLength, 28);
    expect(stats.medianPeriodLength, 5);
    expect(stats.cycleStandardDeviation, 0);
  });

  test('handles irregular, short, and long cycle lengths', () {
    // Short cycle (22 days)
    final shortForecast = CycleEngine.forecast(
      periods: [
        _period('1', DateTime(2026, 1, 1)),
        _period('2', DateTime(2026, 1, 23)),
        _period('3', DateTime(2026, 2, 14)),
      ],
      today: DateTime(2026, 2, 15),
    );
    expect(shortForecast!.cycleLength, 22);

    // Long cycle (38 days)
    final longForecast = CycleEngine.forecast(
      periods: [
        _period('1', DateTime(2026, 1, 1)),
        _period('2', DateTime(2026, 2, 8)),
        _period('3', DateTime(2026, 3, 18)),
      ],
      today: DateTime(2026, 3, 20),
    );
    expect(longForecast!.cycleLength, 38);
  });

  test('detects symptom patterns only with sufficient data (>= 2 logs)', () {
    final periods = [
      _period('1', DateTime(2026, 1, 1), end: DateTime(2026, 1, 5)),
      _period('2', DateTime(2026, 1, 29), end: DateTime(2026, 2, 2)),
    ];

    // Single log is not enough
    final singleLog = [
      CycleDailyLog(
        day: DateTime(2026, 1, 25), // Day 25 = Lutealphase
        pain: 5,
      ),
    ];
    final noPatterns = CycleEngine.detectSymptomPatterns(
      periods: periods,
      logs: singleLog,
    );
    expect(noPatterns, isEmpty);

    // Two logs in luteal phase with pain
    final twoLogs = [
      CycleDailyLog(
        day: DateTime(2026, 1, 25),
        pain: 5,
      ),
      CycleDailyLog(
        day: DateTime(2026, 2, 22),
        pain: 6,
      ),
    ];
    final patterns = CycleEngine.detectSymptomPatterns(
      periods: periods,
      logs: twoLogs,
    );
    expect(patterns.length, 1);
    expect(patterns.first.phaseName, 'Lutealphase');
    expect(patterns.first.symptomName, 'Schmerzen');
    expect(patterns.first.occurrenceCount, 2);
    expect(patterns.first.explanation, contains('basierend auf 2 Einträgen'));
  });
}

