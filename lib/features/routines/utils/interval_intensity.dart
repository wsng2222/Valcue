import '../models/interval.dart';

/// Whether an interval counts as a hard (work) segment in the interval strip
/// and workout profile: 8+ km/h, 100+ RPM or level 8+.
bool isHardInterval(Interval interval) {
  if (interval.rpm != null) return interval.rpm! >= 100;
  if (interval.level != null) return interval.level! >= 8;
  return (interval.speedKmh ?? 0) >= 8;
}
