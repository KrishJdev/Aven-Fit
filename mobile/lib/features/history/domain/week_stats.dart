import 'package:freezed_annotation/freezed_annotation.dart';

part 'week_stats.freezed.dart';

/// Pure immutable one-week training aggregate (WU-X.1, FEATURES.md §7.1
/// glance stats). Semantics mirror the history feed exactly: confirmed
/// sets only, warm-ups excluded from volume (L1). Weeks are bucketed
/// through the single Monday anchor (`StreakInfo.startOfWeek`).
///
/// Derived state — recomputed from the session/set tables on every read,
/// never persisted, so edits and deletes self-heal (L7/L8).
@freezed
abstract class WeekStats with _$WeekStats {
  const WeekStats._();

  const factory WeekStats({
    @Default(0) int workoutCount,
    @Default(0) int completedSetCount,
    @Default(0.0) double volumeKg,
  }) = _WeekStats;

  /// Volume display: trims trailing ".0" for whole kilograms.
  String get volumeDisplay =>
      volumeKg % 1 == 0 ? volumeKg.toInt().toString() : volumeKg.toStringAsFixed(1);
}

/// This week vs last week — the raw input for the ▲/▼ glance deltas
/// (§7.1). A plain record: no behavior beyond the two buckets.
typedef WeeklyGlance = ({WeekStats thisWeek, WeekStats lastWeek});
