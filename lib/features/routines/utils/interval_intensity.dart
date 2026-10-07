import '../models/interval.dart';

/// Whether an interval counts as a hard (work) segment in the interval strip
/// and workout profile: 8+ km/h, 5+ grade, 100+ RPM or level 8+.
///
/// Grade is checked alongside speed for treadmill intervals - an incline
/// routine's work segments (e.g. 6.0 grade at a walking pace) never reach
/// 8 km/h, so speed alone would flatten the whole strip to one uniform tint.
bool isHardInterval(Interval interval) {
  if (interval.rpm != null) return interval.rpm! >= 100;
  if (interval.level != null) return interval.level! >= 8;
  return (interval.speedKmh ?? 0) >= 8 || (interval.grade ?? 0) >= 5;
}
