import 'package:freezed_annotation/freezed_annotation.dart';

part 'lifetime_stats.freezed.dart';

/// Pure immutable lifetime aggregate for the Profile screen (WU-5.3,
/// FEATURES.md §12.1). Totals mirror the Workout History semantics:
/// warm-up sets are excluded from working volume (L1) and the set count
/// covers confirmed sets only.
///
/// Derived state — recomputed from the session/set tables on every read,
/// never persisted, so edits and deletes self-heal (L7/L8).
/// [firstSessionAt] (earliest non-discarded session start) is the local
/// "member since" anchor; null before the very first session (L6: the
/// unknown renders "—", never a fake zero).
@freezed
abstract class LifetimeStats with _$LifetimeStats {
  const LifetimeStats._();

  const factory LifetimeStats({
    @Default(0) int workoutCount,
    @Default(0) int completedSetCount,
    @Default(0.0) double totalVolumeKg,
    DateTime? firstSessionAt,
  }) = _LifetimeStats;

  /// Working volume display: trims trailing ".0" for whole kilograms
  /// (mirrors `WorkoutHistoryItem.volumeDisplay`).
  String get volumeDisplay => totalVolumeKg % 1 == 0
      ? totalVolumeKg.toInt().toString()
      : totalVolumeKg.toStringAsFixed(1);

  /// "Member since" display (§12.1): short month + year ("Aug 2026"),
  /// or "—" while there is no first session yet (L6).
  String get memberSinceDisplay {
    final at = firstSessionAt;
    if (at == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[at.month - 1]} ${at.year}';
  }
}
