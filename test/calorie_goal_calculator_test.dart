import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/services/calorie_goal_calculator.dart';

void main() {
  test('diet target is one percent bodyweight per week', () {
    expect(
      CalorieGoalCalculator.targetWeeklyChange(
        mode: CalorieGoalMode.diet,
        currentWeight: 100,
        customPercentPerMonth: 0,
      ),
      -1,
    );
  });

  test('custom target is converted from percent per month to kg per week', () {
    expect(
      CalorieGoalCalculator.targetWeeklyChange(
        mode: CalorieGoalMode.custom,
        currentWeight: 80,
        customPercentPerMonth: 2,
      ),
      closeTo(0.4, 0.001),
    );
  });

  test('weekly kg change maps to daily calorie delta', () {
    expect(CalorieGoalCalculator.calorieDeltaForWeeklyWeightChange(-0.7), -770);
    expect(CalorieGoalCalculator.calorieDeltaForWeeklyWeightChange(0.35), 385);
  });

  test('daily calories are bounded', () {
    expect(CalorieGoalCalculator.clampDailyCalories(500), 1000);
    expect(CalorieGoalCalculator.clampDailyCalories(7000), 6000);
    expect(CalorieGoalCalculator.clampDailyCalories(2200), 2200);
  });
}
