enum CalorieGoalMode { off, diet, bulk, custom, maintain }

class CalorieGoalCalculator {
  static double targetWeeklyChange({
    required CalorieGoalMode mode,
    required double currentWeight,
    required double customPercentPerMonth,
    double? explicitWeeklyChange,
  }) {
    if (explicitWeeklyChange != null) return explicitWeeklyChange;
    switch (mode) {
      case CalorieGoalMode.diet:
        return -currentWeight * 0.01;
      case CalorieGoalMode.bulk:
        return currentWeight * 0.01 / 4;
      case CalorieGoalMode.custom:
        return currentWeight * customPercentPerMonth / 100 / 4;
      case CalorieGoalMode.maintain:
      case CalorieGoalMode.off:
        return 0.0;
    }
  }

  static int calorieDeltaForWeeklyWeightChange(double weeklyKg) {
    return (weeklyKg * 7700 / 7).round();
  }

  static int clampDailyCalories(int calories) {
    return calories.clamp(1000, 6000).toInt();
  }
}
