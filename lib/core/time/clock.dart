/// Time is injected at domain/service boundaries so calculations and sync
/// policies remain deterministic in tests.
abstract interface class Clock {
  DateTime now();

  DateTime nowUtc();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

class FixedClock implements Clock {
  FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;

  @override
  DateTime nowUtc() => value.toUtc();
}
