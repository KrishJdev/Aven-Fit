import 'package:freezed_annotation/freezed_annotation.dart';

import 'workout_set.dart';

part 'ghost_set.freezed.dart';
part 'ghost_set.g.dart';

/// Origin source of a ghost / prefilled suggestion.
enum GhostSource {
  /// Prefilled from the most recent completed performance in history.
  history,

  /// Prefilled from the routine's configured targets.
  routineTarget,

  /// Copied from the previous set in the active workout session.
  previousSet,

  /// No prefill available (first-ever exercise without routine targets).
  none,
}

/// Pure immutable domain value object representing a placeholder (ghost) set suggestion.
///
/// Implements Law L1 (<3s set logging) and Law L7 (write-through integrity).
@freezed
abstract class GhostSet with _$GhostSet {
  const GhostSet._();

  const factory GhostSet({
    double? weightKg,
    int? reps,
    double? rpe,
    @Default(SetType.normal) SetType setType,
    @Default(GhostSource.none) GhostSource source,
  }) = _GhostSet;

  factory GhostSet.fromJson(Map<String, dynamic> json) =>
      _$GhostSetFromJson(json);

  /// Whether this ghost suggestion contains usable numeric values.
  bool get hasValue =>
      (weightKg != null && weightKg! > 0) || (reps != null && reps! > 0);

  /// Formatted weight string (e.g. "80" or "82.5" or "—")
  String get weightDisplay {
    if (weightKg == null || weightKg! <= 0) return '—';
    return weightKg! % 1 == 0
        ? weightKg!.toInt().toString()
        : weightKg!.toStringAsFixed(1);
  }

  /// Formatted reps string (e.g. "8" or "—")
  String get repsDisplay {
    if (reps == null || reps! <= 0) return '—';
    return reps.toString();
  }

  /// Formatted summary string for previous performance column (e.g. "80kg × 8" or "—")
  String get prevSummary {
    if (!hasValue) return '—';
    final w = weightDisplay;
    final r = repsDisplay;
    if (w != '—' && r != '—') {
      return '$w kg × $r';
    } else if (w != '—') {
      return '$w kg';
    } else {
      return '$r reps';
    }
  }
}
