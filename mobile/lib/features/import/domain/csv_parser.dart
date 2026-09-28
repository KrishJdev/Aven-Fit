import 'package:csv/csv.dart';

import 'import_models.dart';

/// On-device CSV parser for Hevy & Strong workout exports (FEATURES.md
/// §12.4, J4 journey). 100% local — no network, no upload (L2/L9).
///
/// Detects the source format from the header row, maps columns by
/// normalized header name (handles format/version variations), groups
/// rows into workouts → exercises → sets, and converts imperial weights
/// to kilograms.
class CsvParser {
  const CsvParser();

  /// Parses raw CSV text into a [ParsedCsvSummary].
  ///
  /// Throws [CsvParseException] on unrecoverable errors (empty file,
  /// missing required columns). Malformed individual rows are skipped
  /// with a count returned via [ParseResult.errors] — never aborts the
  /// whole file for one bad row (L7 spirit: no data loss).
  ParseResult parse(String csvContent) {
    final rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvContent);

    if (rows.isEmpty) {
      throw const CsvParseException('CSV file is empty.');
    }

    // Detect format from the header row.
    final headerRow =
        rows.first.map((c) => c.toString().trim()).toList();
    final source = _detectSource(headerRow);
    if (source == null) {
      throw CsvParseException(
        'Unrecognized CSV format. Expected a Strong or Hevy export. '
        'Headers found: ${headerRow.join(', ')}',
      );
    }

    final col = _ColumnMap.fromHeader(headerRow, source);
    final workouts = <ParsedWorkout>[];
    final errors = <String>[];

    // Group rows by (date, workout name) → exercise → sets.
    final grouped = <String, _WorkoutAccum>{};

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.every((c) => c.toString().trim().isEmpty)) continue; // skip blanks

      try {
        final dateStr = col.read(row, Col.date);
        final workoutName = col.read(row, Col.workoutName);
        if (dateStr == null || dateStr.isEmpty) {
          errors.add('Row $i: missing date — skipped.');
          continue;
        }
        if (workoutName == null || workoutName.isEmpty) {
          errors.add('Row $i: missing workout name — skipped.');
          continue;
        }

        final date = _parseDate(dateStr);
        if (date == null) {
          errors.add('Row $i: unparseable date "$dateStr" — skipped.');
          continue;
        }

        final exerciseName = col.read(row, Col.exerciseName);
        if (exerciseName == null || exerciseName.isEmpty) {
          errors.add('Row $i: missing exercise name — skipped.');
          continue;
        }

        final weight = _parseDouble(col.read(row, Col.weight));
        final weightUnit = col.read(row, Col.weightUnit);
        final weightKg = _toKg(weight, weightUnit, source);

        final reps = _parseInt(col.read(row, Col.reps)) ?? 0;
        final setOrder = _parseInt(col.read(row, Col.setOrder)) ?? 1;
        final rpe = _parseDouble(col.read(row, Col.rpe));
        final notes = col.read(row, Col.notes);
        final isWarmup = _isWarmup(col, row, source);

        final distanceKm = _parseDouble(col.read(row, Col.distance));
        final durationSeconds = _parseInt(col.read(row, Col.duration));

        final set = ParsedSet(
          setOrder: setOrder,
          weightKg: weightKg,
          reps: reps,
          isWarmup: isWarmup,
          rpe: rpe,
          notes: (notes != null && notes.isNotEmpty) ? notes : null,
          distanceKm: distanceKm,
          durationSeconds: durationSeconds,
        );

        // Group key: ISO date (date-only) + workout name. Sets on the
        // same date with the same workout name belong to one session.
        final dateKey = '${date.year}-${date.month}-${date.day}';
        final key = '$dateKey|$workoutName';
        final accum = grouped.putIfAbsent(
          key,
          () => _WorkoutAccum(date: date, name: workoutName),
        );

        accum.addSet(exerciseName: exerciseName, set: set, notes: notes);
      } catch (e) {
        errors.add('Row $i: $e — skipped.');
      }
    }

    // Build the final workout list, sorted by date ascending (oldest
    // first — chronological import for correct PR replay).
    for (final accum in grouped.values) {
      workouts.add(accum.build());
    }
    workouts.sort((a, b) => a.date.compareTo(b.date));

    return ParseResult(
      summary: ParsedCsvSummary(source: source, workouts: workouts),
      errors: errors,
    );
  }

  ImportSource? _detectSource(List<String> headers) {
    final joined = headers.join('|').toLowerCase();
    // Strong exports have a "Weight Unit" column; Hevy uses "Weight (kg)".
    if (joined.contains('weight unit') ||
        joined.contains('duration unit')) {
      return ImportSource.strong;
    }
    if (joined.contains('weight (kg)') ||
        joined.contains('set type') ||
        joined.contains('weight_kg')) {
      return ImportSource.hevy;
    }
    // Fallback: check for Strong's typical column set.
    if (joined.contains('workout name') && joined.contains('set order')) {
      // Could be either — infer from weight column name.
      if (joined.contains('weight') && !joined.contains('weight (kg)')) {
        return ImportSource.strong; // bare "Weight" + "Weight Unit" = Strong
      }
      return ImportSource.hevy;
    }
    return null;
  }

  DateTime? _parseDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // ISO 8601 — the most common machine-generated format.
    final iso = DateTime.tryParse(trimmed);
    if (iso != null) return iso;

    // Strong exports use "MMM dd, yyyy h:mm AM/PM" (locale-dependent).
    // Try a manual parse for the common English-locale format.
    final strongMatch = RegExp(
      r'(\w{3})\s+(\d{1,2}),?\s+(\d{4})\s+(\d{1,2}):(\d{2})\s*(AM|PM)?',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (strongMatch != null) {
      final month = _monthIndex(strongMatch.group(1)!);
      if (month != null) {
        final day = int.parse(strongMatch.group(2)!);
        final year = int.parse(strongMatch.group(3)!);
        var hour = int.parse(strongMatch.group(4)!);
        final minute = int.parse(strongMatch.group(5)!);
        final ampm = strongMatch.group(6)?.toUpperCase();
        if (ampm == 'PM' && hour != 12) hour += 12;
        if (ampm == 'AM' && hour == 12) hour = 0;
        try {
          return DateTime(year, month, day, hour, minute);
        } catch (_) {
          // fall through
        }
      }
    }

    // "yyyy-MM-dd HH:mm:ss" (Hevy / generic).
    final hevyMatch =
        RegExp(r'(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?')
            .firstMatch(trimmed);
    if (hevyMatch != null) {
      return DateTime(
        int.parse(hevyMatch.group(1)!),
        int.parse(hevyMatch.group(2)!),
        int.parse(hevyMatch.group(3)!),
        int.parse(hevyMatch.group(4)!),
        int.parse(hevyMatch.group(5)!),
        hevyMatch.group(6) != null ? int.parse(hevyMatch.group(6)!) : 0,
      );
    }

    // Last resort: date-only "yyyy-MM-dd".
    final dateOnly = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(trimmed);
    if (dateOnly != null) {
      return DateTime(
        int.parse(dateOnly.group(1)!),
        int.parse(dateOnly.group(2)!),
        int.parse(dateOnly.group(3)!),
      );
    }

    return null;
  }

  int? _monthIndex(String abbrev) {
    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };
    return months[abbrev.toLowerCase()];
  }

  double _parseDouble(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0.0;
    final cleaned = raw.trim().replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }

  int? _parseInt(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final cleaned = raw.trim().replaceAll(RegExp(r'\.0+$'), '');
    return int.tryParse(cleaned);
  }

  /// Converts weight to kg. Strong exports may use "lb"; Hevy is always kg.
  double _toKg(double weight, String? unit, ImportSource source) {
    if (weight <= 0) return 0.0;
    final u = unit?.trim().toLowerCase() ?? '';
    if (u == 'lb' || u == 'lbs' || u == 'pounds') {
      return _roundTo(weight * 0.45359237, decimals: 2);
    }
    // Strong with no unit column or "kg" → already kg.
    // Hevy → already kg.
    return _roundTo(weight, decimals: 2);
  }

  double _roundTo(double v, {int decimals = 2}) {
    final factor = pow10(decimals);
    return (v * factor).round() / factor;
  }

  int pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  /// Detects warm-up sets. Strong doesn't have a dedicated column; some
  /// Hevy exports have a "Set Type" column. Falls back to the exercise
  /// name or notes containing "warm".
  bool _isWarmup(_ColumnMap col, List<dynamic> row, ImportSource source) {
    final setType = col.read(row, Col.setType);
    if (setType != null) {
      final s = setType.toLowerCase();
      if (s.contains('warm')) return true;
    }
    final exerciseName = col.read(row, Col.exerciseName);
    if (exerciseName != null) {
      final n = exerciseName.toLowerCase();
      if (n.contains('warm up') || n.contains('warmup') || n.contains('warm-up')) {
        return true;
      }
    }
    // Notes column is the last-resort signal — Strong exports put "warm
    // up" in the Notes column for warm-up sets.
    final notes = col.read(row, Col.notes);
    if (notes != null) {
      final n = notes.toLowerCase();
      if (n.contains('warm up') || n.contains('warmup') || n.contains('warm-up') || n == 'warm') {
        return true;
      }
    }
    return false;
  }
}

/// The result of parsing a CSV file — the summary plus any per-row errors.
class ParseResult {
  const ParseResult({required this.summary, this.errors = const []});

  final ParsedCsvSummary summary;
  final List<String> errors;
}

class CsvParseException implements Exception {
  const CsvParseException(this.message);
  final String message;
  @override
  String toString() => 'CsvParseException: $message';
}

/// Canonical column identifiers — the parser works in terms of these,
/// not raw header strings, so format variations are absorbed by the
/// [_ColumnMap] resolver.
enum Col {
  date,
  workoutName,
  exerciseName,
  setOrder,
  weight,
  weightUnit,
  reps,
  rpe,
  notes,
  setType,
  distance,
  duration,
}

/// Maps canonical [Col]s to column indices in a specific CSV header row.
class _ColumnMap {
  _ColumnMap(this._indices);

  final Map<Col, int?> _indices;

  static _ColumnMap fromHeader(List<String> headers, ImportSource source) {
    final normalized = <String, int>{};
    for (var i = 0; i < headers.length; i++) {
      final h = headers[i].trim().toLowerCase();
      if (h.isNotEmpty) {
        normalized[h] = i;
      }
    }

    int? find(List<String> candidates) {
      for (final c in candidates) {
        final idx = normalized[c];
        if (idx != null) return idx;
      }
      // Substring match as a fallback for format variations.
      for (final entry in normalized.entries) {
        for (final c in candidates) {
          if (entry.key.contains(c)) return entry.value;
        }
      }
      return null;
    }

    return _ColumnMap({
      Col.date: find(['date', 'workout date', 'date ']),
      Col.workoutName: find(['workout name', 'workout', 'session name']),
      Col.exerciseName: find(['exercise name', 'exercise', 'exercise title']),
      Col.setOrder: find(['set order', 'set number', 'position', 'set #']),
      Col.weight: find(['weight (kg)', 'weight', 'weight_kg', 'weight (lb)']),
      Col.weightUnit: find(['weight unit', 'unit']),
      Col.reps: find(['reps', 'repetitions', 'rep count']),
      Col.rpe: find(['rpe', 'rpe rating', 'perceived exertion']),
      Col.notes: find(['notes', 'note', 'comment', 'comments']),
      Col.setType: find(['set type', 'warmup', 'warm up', 'type']),
      Col.distance: find(['distance (km)', 'distance', 'distance (mi)']),
      Col.duration: find(['duration (sec)', 'duration', 'duration (s)', 'time']),
    });
  }

  String? read(List<dynamic> row, Col col) {
    final idx = _indices[col];
    if (idx == null || idx >= row.length) return null;
    final val = row[idx];
    if (val == null) return null;
    final s = val.toString().trim();
    return s.isEmpty ? null : s;
  }
}

/// Accumulates sets into workout → exercise groups during parsing.
class _WorkoutAccum {
  _WorkoutAccum({required this.date, required this.name});

  final DateTime date;
  final String name;
  final Map<String, _ExerciseAccum> _exercises = {};

  void addSet({required String exerciseName, required ParsedSet set, String? notes}) {
    _exercises.putIfAbsent(exerciseName, () => _ExerciseAccum(name: exerciseName, notes: notes)).sets.add(set);
  }

  ParsedWorkout build() {
    final exercises = _exercises.values.map((e) => ParsedExercise(
      name: e.name,
      sets: e.sets
        ..sort((a, b) => a.setOrder.compareTo(b.setOrder)),
      notes: e.notes,
    )).toList();
    // Sort exercises by first set order for stable ordering.
    exercises.sort((a, b) =>
        (a.sets.isNotEmpty ? a.sets.first.setOrder : 0)
            .compareTo(b.sets.isNotEmpty ? b.sets.first.setOrder : 0));
    return ParsedWorkout(date: date, name: name, exercises: exercises);
  }
}

class _ExerciseAccum {
  _ExerciseAccum({required this.name, this.notes});
  final String name;
  final String? notes;
  final List<ParsedSet> sets = [];
}
