import '../models/interval.dart';
import '../models/machine_type.dart';
import 'dart:math';

// Indoor cycle virtual distance ~ rpm * kmPerRpmMin km/min, calibrated so a
// realistic 80-90rpm aerobic cadence lands around a 25-32 km/h virtual pace.
// Shared with the UI layer (which needs the same conversion to show/derive
// distance for a routine already built) so the two never drift apart again.
const double kmPerRpmMin = 0.0065;

/// Actual distance a set of generated treadmill intervals covers, summing
/// each interval's speed * time rather than trusting the (possibly clamped)
/// input target.
double treadmillDistanceKm(List<Interval> intervals) {
  double km = 0;
  for (final interval in intervals) {
    if (interval.speedKmh != null) {
      km += interval.speedKmh! * (interval.durationSeconds / 3600.0);
    }
  }
  return km;
}

/// Actual virtual distance a set of generated cycle intervals covers. See
/// [kmPerRpmMin].
double cycleDistanceKm(List<Interval> intervals) {
  double km = 0;
  for (final interval in intervals) {
    if (interval.rpm != null) {
      km += interval.rpm! * kmPerRpmMin * (interval.durationSeconds / 60.0);
    }
  }
  return km;
}

/// Estimated floors climbed by a set of generated stairmaster intervals,
/// inverting the same level<->pace relationship
/// (stepsPerMin = level * 5, floorsPerMin = stepsPerMin / 16) that
/// [buildCustomRoutineIntervals] uses below to turn a floors target into a
/// level.
double stairmasterFloorsClimbed(List<Interval> intervals) {
  double floors = 0;
  for (final interval in intervals) {
    if (interval.level != null) {
      final stepsPerMin = interval.level! * 5.0;
      final floorsPerMin = stepsPerMin / 16.0;
      floors += floorsPerMin * (interval.durationSeconds / 60.0);
    }
  }
  return floors;
}

/// The range of targets a routine can actually deliver for these settings:
/// kilometres for treadmill and cycle, floors for the stairmaster.
///
/// Measured by building the gentlest and the hardest routine the
/// difficulty allows, so it can never disagree with
/// [buildCustomRoutineIntervals]. A target outside it would force the
/// generator past its safety limits or leave the routine short of what its
/// name promises, so the target slider is bounded by it.
({double min, double max}) customRoutineTargetRange({
  required MachineType machineType,
  required int durationMinutes,
  required String difficulty,
  bool includeWarmupCooldown = true,
}) {
  double measure(double target, int variationSeed) => _measureTarget(
        machineType,
        buildCustomRoutineIntervals(
          machineType: machineType,
          durationMinutes: durationMinutes,
          distanceTargetKm: target,
          caloriesTarget: 0,
          bodyWeightKg: 70,
          includeWarmupCooldown: includeWarmupCooldown,
          stairsTargetFloors: target.round(),
          variationSeed: variationSeed,
          difficulty: difficulty,
          randomSeed: 0,
        ),
      );
  // Every pattern (flat, build-up, pyramid) has to reach the whole range -
  // a build-up's last sets hit the speed cap sooner than a flat routine's -
  // so the range is what all three can deliver, trimmed by 1% for the
  // small random variation each routine carries.
  const patterns = [0, 1, 2];
  final low = patterns.map((p) => measure(0.1, p)).reduce(max) * 1.01;
  final high = patterns.map((p) => measure(100000, p)).reduce(min) * 0.99;
  return (min: low, max: max(low, high));
}

double _measureTarget(MachineType machineType, List<Interval> intervals) {
  switch (machineType) {
    case MachineType.treadmill:
      return treadmillDistanceKm(intervals);
    case MachineType.cycle:
      return cycleDistanceKm(intervals);
    case MachineType.stairmaster:
      return stairmasterFloorsClimbed(intervals);
  }
}

/// One block of the main interval set, before any intensity is applied.
class _Block {
  _Block(this.isWork, this.seconds);
  final bool isWork;
  int seconds;
}

/// Splits [mainSeconds] into alternating work/recovery blocks on a clean
/// 30-second grid that add up to exactly [mainSeconds].
///
/// Leftover time never becomes an orphan block shorter than 90 s - it is
/// folded into the last block instead - so a routine never ends on an odd
/// 30-second scrap.
List<_Block> _planBlocks({
  required int mainSeconds,
  required int workSeconds,
  required int recoverySeconds,
  required bool workFirst,
  bool varyDurations = false,
}) {
  int snap30(int sec) => ((sec / 30.0).round() * 30).clamp(30, 600);
  const minBlockSeconds = 90;

  final blocks = <_Block>[];
  var left = mainSeconds;
  var step = 0;
  while (left > 0) {
    // Build-up and pyramid variations stretch later work blocks a little.
    final workMultiplier =
        varyDurations && step > 0 ? 1.0 + (step % 3) * 0.25 : 1.0;
    final work = snap30((workSeconds * workMultiplier).round());
    final recovery =
        snap30((recoverySeconds * (1.0 + (step % 2) * 0.20)).round());
    final pair = workFirst
        ? [_Block(true, work), _Block(false, recovery)]
        : [_Block(false, recovery), _Block(true, work)];

    for (final block in pair) {
      if (left <= 0) break;
      if (left >= block.seconds) {
        blocks.add(block);
        left -= block.seconds;
      } else if (left < minBlockSeconds && blocks.isNotEmpty) {
        blocks.last.seconds += left;
        left = 0;
      } else {
        blocks.add(_Block(block.isWork, left));
        left = 0;
      }
    }
    step++;
  }
  return blocks;
}

/// Finds the intensity in [low, high] whose routine lands closest to
/// [target]. Every machine's output rises with its intensity knob, so a
/// bisection converges; integer knobs (stair levels) are scanned instead.
double _solveIntensity({
  required double low,
  required double high,
  required double target,
  required double Function(double intensity) measure,
  bool integer = false,
}) {
  if (integer) {
    var best = low;
    var bestError = double.infinity;
    for (var level = low; level <= high; level += 1) {
      final error = (measure(level) - target).abs();
      if (error < bestError) {
        best = level;
        bestError = error;
      }
    }
    return best;
  }
  if (measure(low) >= target) return low;
  if (measure(high) <= target) return high;
  var lo = low;
  var hi = high;
  for (var i = 0; i < 40; i++) {
    final mid = (lo + hi) / 2;
    if (measure(mid) < target) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}

/// Builds a routine for the requested machine, length and target.
///
/// Each machine has one intensity knob (treadmill work speed, cycle work
/// cadence, stair work level). The routine is laid out first, then the knob
/// is solved so the finished routine - after every rounding and safety
/// clamp - lands on the target. Estimating the knob up front instead let
/// clamps and rounding push routines far off their target, and let an easy
/// treadmill routine reach sprint speeds.
///
/// [randomSeed] pins the micro-variation for repeatable output (tests and
/// [customRoutineTargetRange]); by default it differs on every call.
List<Interval> buildCustomRoutineIntervals({
  required MachineType machineType,
  required int durationMinutes,
  required double distanceTargetKm,
  required int caloriesTarget,
  required double bodyWeightKg,
  bool includeIncline = true,
  bool includeWarmupCooldown = true,
  int? stairsTargetFloors,
  int variationSeed = 0,
  String difficulty = 'medium',
  int? randomSeed,
}) {
  final seedValue =
      (randomSeed ?? DateTime.now().millisecondsSinceEpoch) + variationSeed;
  final totalSeconds = durationMinutes * 60;
  final isEasy = difficulty == 'easy';
  final isHard = difficulty == 'hard';
  final patternMode = variationSeed % 3; // 0 flat, 1 build-up, 2 pyramid

  final warmupSeconds =
      includeWarmupCooldown ? (durationMinutes <= 15 ? 90 : 180) : 0;
  final cooldownSeconds =
      includeWarmupCooldown ? (durationMinutes <= 15 ? 60 : 120) : 0;
  final mainSeconds = totalSeconds - warmupSeconds - cooldownSeconds;

  // Work/recovery block lengths per workout length and difficulty.
  T pick<T>(T easy, T medium, T hard) =>
      isEasy ? easy : (isHard ? hard : medium);
  final (int workBlock, int recoveryBlock) = switch (machineType) {
    MachineType.treadmill || MachineType.cycle => durationMinutes <= 15
        ? (pick(60, 90, 120), 60)
        : durationMinutes <= 25
            ? (pick(90, 120, 180), pick(90, 90, 60))
            : durationMinutes <= 40
                ? (pick(120, 180, 240), pick(120, 90, 90))
                : (pick(180, 240, 300), pick(150, 120, 120)),
    MachineType.stairmaster => durationMinutes <= 15
        ? (pick(90, 120, 150), 60)
        : durationMinutes <= 30
            ? (pick(120, 180, 240), 90)
            : (pick(180, 240, 300), pick(120, 120, 90)),
  };

  final blocks = _planBlocks(
    mainSeconds: mainSeconds,
    workSeconds: workBlock,
    recoverySeconds: recoveryBlock,
    // With a warmup the body is ready to work straight away; without one,
    // the routine eases in with a recovery block first.
    workFirst: includeWarmupCooldown,
    varyDurations: machineType == MachineType.treadmill && patternMode != 0,
  );
  final workCount = blocks.where((block) => block.isWork).length;

  // Per-set intensity shape: flat, steadily building, or peaking mid-way.
  double patternFactor(int setIndex, double spread) {
    if (workCount <= 1 || patternMode == 0) return 1.0;
    final t = setIndex / (workCount - 1);
    if (patternMode == 1) return 1.0 - spread + t * 2 * spread;
    final fromMid = (t - 0.5).abs() * 2; // 0 at the peak, 1 at the ends
    return 1.0 - spread + (1.0 - fromMid) * 2 * spread;
  }

  List<Interval> withGroups(List<Interval Function(String groupId)> main) {
    final groupId = 'ai_group_${Random(seedValue).nextInt(10000)}';
    return [for (final make in main) make(groupId)];
  }

  switch (machineType) {
    case MachineType.treadmill:
      // Realistic gym speeds per difficulty, and how far recovery drops.
      // Ceilings sized for people who already run: 30 minutes on medium
      // reaches about 5 km, on hard about 6 km.
      final minWork = pick(6.5, 8.0, 9.5).toDouble();
      final maxWork = pick(11.0, 13.0, 16.0).toDouble();
      final speedGap = pick(3.8, 4.5, 5.5).toDouble();
      // Recovery tops out at a brisk walk on easy and an easy jog above it.
      final maxRest = pick(7.0, 8.0, 9.0).toDouble();
      final warmupSpeed = pick(4.0, 5.0, 5.5).toDouble();
      const cooldownSpeed = 4.5;
      final workGrade =
          includeIncline ? pick(1.0, 2.0, 3.0).toDouble() : 0.0;
      final restGrade = includeIncline ? 0.5 : 0.0;
      final warmupGrade = includeIncline ? 0.5 : 0.0;

      double round1(double value) => (value * 10).round() / 10;

      List<Interval> build(double baseSpeed) {
        final random = Random(seedValue);
        // Recovery is a brisk walk or easy jog, always clearly slower.
        final restJitter =
            (random.nextDouble() - 0.5) * (variationSeed > 0 ? 0.4 : 0.1);
        final restSpeed = round1(
          (baseSpeed - speedGap + restJitter)
              .clamp(4.0, maxRest)
              .clamp(4.0, max(4.0, baseSpeed - 2.0)),
        );
        var setIndex = 0;
        final main = <Interval Function(String)>[];
        for (final block in blocks) {
          if (block.isWork) {
            final speed = round1(
              (baseSpeed * patternFactor(setIndex++, 0.12))
                  .clamp(5.5, maxWork),
            );
            main.add((g) => Interval.treadmill(
                  durationSeconds: block.seconds,
                  speedKmh: speed,
                  grade: workGrade,
                  groupId: g,
                  repeatCount: 1,
                ));
          } else {
            main.add((g) => Interval.treadmill(
                  durationSeconds: block.seconds,
                  speedKmh: restSpeed,
                  grade: restGrade,
                  groupId: g,
                  repeatCount: 1,
                ));
          }
        }
        return [
          if (includeWarmupCooldown)
            Interval.treadmill(
              durationSeconds: warmupSeconds,
              speedKmh: warmupSpeed,
              grade: warmupGrade,
            ),
          ...withGroups(main),
          if (includeWarmupCooldown)
            Interval.treadmill(
              durationSeconds: cooldownSeconds,
              speedKmh: cooldownSpeed,
              grade: 0.0,
            ),
        ];
      }

      final speed = _solveIntensity(
        low: minWork,
        high: maxWork,
        target: distanceTargetKm,
        measure: (value) => treadmillDistanceKm(build(value)),
      );
      return build(speed);

    case MachineType.cycle:
      // Evidence-based indoor cycling resistance (AFAA/ACE spinning
      // protocol): recovery 3-5, easy 7-9, threshold 10-13, HIIT 14-18.
      final minRpm = pick(60, 65, 75).toDouble();
      final maxRpm = pick(85, 100, 110).toDouble();
      const restRes = 4;
      // Heavier riders get slightly less resistance for the same effort.
      final weightFactor = (bodyWeightKg / 70.0).clamp(0.85, 1.15);
      final baseWorkRes =
          (pick(8, 11, 15) / weightFactor).clamp(4.0, 20.0);

      int workResistance(int setIndex) {
        final t = workCount > 1 ? setIndex / (workCount - 1) : 0.0;
        final double res = switch (patternMode) {
          1 => baseWorkRes + t * 6.0, // build-up
          2 => baseWorkRes + (1.0 - (t - 0.5).abs() * 2) * 6.0, // pyramid
          _ => setIndex.isEven ? baseWorkRes : baseWorkRes + 3, // alternate
        };
        return res.round().clamp(2, 20);
      }

      List<Interval> build(double baseRpm) {
        final random = Random(seedValue);
        final restRpm = (baseRpm * 0.70).clamp(45.0, 80.0);
        var setIndex = 0;
        final main = <Interval Function(String)>[];
        for (final block in blocks) {
          // Always a slight cadence variation; larger when regenerating.
          final offset = (random.nextInt(5) - 2) +
              (variationSeed > 0 ? random.nextInt(7) - 3 : 0);
          if (block.isWork) {
            final res = workResistance(setIndex++);
            final rpm = (baseRpm + offset).clamp(55.0, 115.0).round();
            main.add((g) => Interval.cycle(
                  durationSeconds: block.seconds,
                  rpm: rpm,
                  resistance: res,
                  groupId: g,
                  repeatCount: 1,
                ));
          } else {
            final rpm = (restRpm + offset ~/ 2).clamp(45.0, 90.0).round();
            main.add((g) => Interval.cycle(
                  durationSeconds: block.seconds,
                  rpm: rpm,
                  resistance: restRes,
                  groupId: g,
                  repeatCount: 1,
                ));
          }
        }
        return [
          if (includeWarmupCooldown)
            Interval.cycle(
              durationSeconds: warmupSeconds,
              rpm: (restRpm - 2).clamp(45, 80).round(),
              resistance: restRes - 1,
            ),
          ...withGroups(main),
          if (includeWarmupCooldown)
            Interval.cycle(
              durationSeconds: cooldownSeconds,
              rpm: (restRpm - 10).clamp(40, 70).round(),
              resistance: restRes - 1,
            ),
        ];
      }

      final rpm = _solveIntensity(
        low: minRpm,
        high: maxRpm,
        target: distanceTargetKm,
        measure: (value) => cycleDistanceKm(build(value)),
      );
      return build(rpm);

    case MachineType.stairmaster:
      final floorsGoal = (stairsTargetFloors ?? 50).toDouble();
      final minWork = pick(4, 6, 8).toDouble();
      final maxWork = pick(12, 16, 20).toDouble();
      final restMax = pick(7, 9, 11);
      final restMin = pick(2, 2, 3);

      List<Interval> build(double workLevelValue) {
        final workLevel = workLevelValue.round();
        // Recovery rides at ~60% of the work level, at least 3 levels below.
        final restLevel = min(
          (workLevel * 0.6).round().clamp(restMin, restMax),
          max(1, workLevel - 3),
        );
        var setIndex = 0;
        final main = <Interval Function(String)>[];
        for (final block in blocks) {
          if (block.isWork) {
            final offset =
                variationSeed > 0 ? (setIndex % 3) - 1 : 0; // gentle wave
            setIndex++;
            final level = (workLevel + offset)
                .clamp(minWork.round(), maxWork.round());
            main.add((g) => Interval.stairmaster(
                  durationSeconds: block.seconds,
                  level: level,
                  groupId: g,
                  repeatCount: 1,
                ));
          } else {
            main.add((g) => Interval.stairmaster(
                  durationSeconds: block.seconds,
                  level: restLevel,
                  groupId: g,
                  repeatCount: 1,
                ));
          }
        }
        return [
          if (includeWarmupCooldown)
            Interval.stairmaster(
              durationSeconds: warmupSeconds,
              level: max(1, restLevel - 1),
            ),
          ...withGroups(main),
          if (includeWarmupCooldown)
            Interval.stairmaster(
              durationSeconds: cooldownSeconds,
              level: max(1, restLevel - 1),
            ),
        ];
      }

      final level = _solveIntensity(
        low: minWork,
        high: maxWork,
        target: floorsGoal,
        measure: (value) => stairmasterFloorsClimbed(build(value)),
        integer: true,
      );
      return build(level);
  }
}
