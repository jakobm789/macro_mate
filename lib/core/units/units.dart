enum DistanceUnit { metric, imperial }

class Units {
  const Units({this.distanceUnit = DistanceUnit.metric});

  final DistanceUnit distanceUnit;

  double distanceFromMeters(double meters) =>
      distanceUnit == DistanceUnit.metric ? meters / 1000 : meters / 1609.344;

  String distanceLabel(double meters, {int decimals = 1}) {
    final value = distanceFromMeters(meters).toStringAsFixed(decimals);
    return distanceUnit == DistanceUnit.metric ? '$value km' : '$value mi';
  }

  /// Returns pace in minutes per displayed distance unit.
  double? paceMinutesPerUnit(
      {required double meters, required Duration duration}) {
    if (meters <= 0 || duration.inSeconds <= 0) return null;
    final units = distanceFromMeters(meters);
    return duration.inSeconds / 60 / units;
  }

  double kcalToKilojoules(double kcal) => kcal * 4.184;

  double kilojoulesToKcal(double kilojoules) => kilojoules / 4.184;
}
