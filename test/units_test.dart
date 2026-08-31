import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/units/units.dart';

void main() {
  test('converts distance and pace using metric units', () {
    const units = Units();
    expect(units.distanceFromMeters(5000), closeTo(5, 0.0001));
    expect(units.distanceLabel(5000), '5.0 km');
    expect(
      units.paceMinutesPerUnit(
        meters: 5000,
        duration: const Duration(minutes: 25),
      ),
      closeTo(5, 0.0001),
    );
  });

  test('supports imperial distance and energy conversion', () {
    const units = Units(distanceUnit: DistanceUnit.imperial);
    expect(units.distanceFromMeters(1609.344), closeTo(1, 0.0001));
    expect(units.distanceLabel(1609.344), '1.0 mi');
    expect(units.kcalToKilojoules(100), closeTo(418.4, 0.0001));
    expect(units.kilojoulesToKcal(418.4), closeTo(100, 0.0001));
  });

  test('returns no pace for invalid duration or distance', () {
    const units = Units();
    expect(
      units.paceMinutesPerUnit(
        meters: 0,
        duration: const Duration(minutes: 10),
      ),
      isNull,
    );
    expect(
      units.paceMinutesPerUnit(
        meters: 1000,
        duration: Duration.zero,
      ),
      isNull,
    );
  });
}
