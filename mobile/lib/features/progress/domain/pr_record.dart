import 'package:freezed_annotation/freezed_annotation.dart';

part 'pr_record.freezed.dart';
part 'pr_record.g.dart';

/// The four personal-record types tracked per exercise (FEATURES.md §10.2).
enum RecordType {
  /// Heaviest weight ever lifted for the exercise.
  maxWeight,

  /// Best estimated 1RM via the Epley formula.
  epley1rm,

  /// Most reps completed at a specific weight (weight-keyed record).
  maxRepsAtWeight,

  /// Biggest single-set volume (weight × reps) for the exercise.
  volume;

  /// Short badge/chip label used across the UI.
  String get label => switch (this) {
        RecordType.maxWeight => 'MAX WEIGHT',
        RecordType.epley1rm => 'e1RM',
        RecordType.maxRepsAtWeight => 'REPS @ WEIGHT',
        RecordType.volume => 'VOLUME',
      };

  /// Tolerant parse from the stored `record_type` column.
  static RecordType fromName(String value) => RecordType.values.firstWhere(
        (t) => t.name == value || t.name.toUpperCase() == value.toUpperCase(),
        orElse: () => RecordType.maxWeight,
      );

  /// Human value display for the vault surfaces (WU-X.3, §10.2): the
  /// weight-keyed reps record reads "N reps @ W kg", the e1RM reads with
  /// its unit, the rest as kilograms. Trims trailing ".0".
  String formatValue(double value, {double? weightKg}) {
    String trim(double v) =>
        v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
    return switch (this) {
      RecordType.maxWeight => '${trim(value)} kg',
      RecordType.epley1rm => '${trim(value)} kg e1RM',
      RecordType.maxRepsAtWeight =>
        '${value.round()} reps @ ${trim(weightKg ?? 0)} kg',
      RecordType.volume => '${trim(value)} kg',
    };
  }
}

/// Pure immutable domain entity representing a personal record (PR).
///
/// One record holds the current best value for (exerciseId, recordType) —
/// plus one per weight for the weight-keyed [RecordType.maxRepsAtWeight].
/// Records are computed locally and incrementally at set-save time; warm-up
/// sets never count (§10.2).
@freezed
abstract class PRRecord with _$PRRecord {
  const factory PRRecord({
    required String id,
    required String exerciseId,
    required RecordType recordType,
    required double value,

    /// Weight key for [RecordType.maxRepsAtWeight] records; null otherwise.
    double? weightKg,
    required DateTime achievedAt,
    String? sessionId,
    String? setId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PRRecord;

  factory PRRecord.fromJson(Map<String, dynamic> json) =>
      _$PRRecordFromJson(json);

  /// Epley estimated 1RM formula (§10.2): `weight × (1 + reps / 30)`.
  ///
  /// Returns 0 for empty sets so they can never produce a record value.
  static double epleyE1RM({required double weightKg, required int reps}) {
    if (weightKg <= 0 || reps <= 0) return 0;
    return weightKg * (1 + reps / 30.0);
  }
}
