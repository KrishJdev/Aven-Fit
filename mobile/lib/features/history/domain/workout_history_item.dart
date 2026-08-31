import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_history_item.freezed.dart';
part 'workout_history_item.g.dart';

/// Pure immutable summary of a completed workout for history list display
/// (WU-3.9, FEATURES.md §8.6). Metrics mirror the Workout Summary semantics:
/// warm-up sets are excluded from working volume (L1) and the set count
/// covers confirmed sets only.
@freezed
abstract class WorkoutHistoryItem with _$WorkoutHistoryItem {
  const WorkoutHistoryItem._();

  const factory WorkoutHistoryItem({
    required String id,
    @Default('Workout') String name,
    /// When the workout was completed (falls back to its start time).
    required DateTime date,
    @Default(0) int durationSeconds,
    @Default(0) int exerciseCount,
    @Default(0) int totalSetsCount,
    @Default(0.0) double totalVolumeKg,
    @Default(0) int prCount,
  }) = _WorkoutHistoryItem;

  factory WorkoutHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$WorkoutHistoryItemFromJson(json);

  /// Working volume display: trims trailing ".0" for whole kilograms.
  String get volumeDisplay => totalVolumeKg % 1 == 0
      ? totalVolumeKg.toInt().toString()
      : totalVolumeKg.toStringAsFixed(1);
}
