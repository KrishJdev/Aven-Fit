import 'package:freezed_annotation/freezed_annotation.dart';

part 'rest_timer_state.freezed.dart';

/// Immutable state for the rest countdown (WU-3.5, FEATURES.md §8.3).
///
/// The epoch deadline [endsAtEpochMs] is the single source of truth; the
/// remaining time is always recomputed from it, never accumulated — so event
/// loop lag, Doze, or backgrounding can never drift the countdown (L8).
@freezed
abstract class RestTimerState with _$RestTimerState {
  const RestTimerState._();

  const factory RestTimerState({
    @Default(false) bool isRunning,
    @Default(0) int totalSeconds,

    /// Duration the countdown was started with — [restart] always restores
    /// this, even after ±15s adjustments shrank or grew [totalSeconds].
    @Default(0) int initialSeconds,
    int? endsAtEpochMs,
    @Default(0) int remainingSeconds,
    String? sessionExerciseId,
    String? exerciseName,
    @Default(false) bool needsPermissionPrimer,
  }) = _RestTimerState;

  /// MM:SS rendering of the remaining time for bars and notifications.
  String get remainingDisplay {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Fraction of rest remaining (1.0 at start, 0.0 at zero) for the slim bar.
  double get progressFraction =>
      isRunning && totalSeconds > 0 ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;
}
