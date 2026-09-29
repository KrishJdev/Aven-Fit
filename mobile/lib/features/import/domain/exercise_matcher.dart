import '../domain/import_models.dart';
import '../../exercise/domain/exercise.dart';

/// Fuzzy exercise-name matcher (FEATURES.md §12.4).
///
/// Maps CSV export exercise names to the local 55-exercise catalog via
/// normalized-name matching with confidence scoring:
/// - **High:** exact or near-exact normalized match → auto-mapped silently.
/// - **Medium:** token-overlap above threshold → suggested, batch-reviewed.
/// - **Low:** no reasonable match → offered as custom-exercise creation
///   (never silently dropped, L7).
///
/// Pure synchronous logic — no DB, no network. The caller passes the
/// catalog once; the matcher builds a normalized index for O(1) exact
/// lookup + O(n) token-similarity scan.
class ExerciseMatcher {
  ExerciseMatcher(List<Exercise> catalog) : _index = _buildIndex(catalog);

  final List<_CatalogEntry> _index;

  /// Matches a CSV exercise name against the catalog.
  ExerciseMatchResult match(String csvName) {
    final normalized = _normalize(csvName);

    // 1. Exact normalized match → high confidence.
    final exact = _index.firstWhere(
      (e) => e.normalized == normalized,
      orElse: () => const _CatalogEntry._empty(),
    );
    if (exact.id != null) {
      return ExerciseMatchResult(
        originalName: csvName,
        confidence: MatchConfidence.high,
        exerciseId: exact.id,
        matchedName: exact.name,
      );
    }

    // 2. One-directional containment → high confidence (the CSV name is
    // the catalog name + equipment suffix, or vice versa).
    final contained = _index.firstWhere(
      (e) =>
          e.normalized.contains(normalized) &&
          normalized.isNotEmpty &&
          normalized.split(' ').length >= 2 ||
          normalized.contains(e.normalized) && e.normalized.isNotEmpty,
      orElse: () => const _CatalogEntry._empty(),
    );
    if (contained.id != null) {
      return ExerciseMatchResult(
        originalName: csvName,
        confidence: MatchConfidence.high,
        exerciseId: contained.id,
        matchedName: contained.name,
      );
    }

    // 3. Token-overlap similarity (Jaccard) → medium if ≥ 0.5.
    final csvTokens = _tokenize(normalized);
    if (csvTokens.isNotEmpty) {
      _CatalogEntry? best;
      var bestScore = 0.0;
      for (final entry in _index) {
        final score = _jaccard(csvTokens, entry.tokens);
        if (score > bestScore) {
          bestScore = score;
          best = entry;
        }
      }
      if (best != null && bestScore >= 0.5 && best.id != null) {
        // Near-perfect token overlap (all CSV tokens found in the
        // catalog entry) → high confidence — effectively an exact match
        // after equipment-suffix stripping.
        final confidence = bestScore >= 0.8
            ? MatchConfidence.high
            : MatchConfidence.medium;
        return ExerciseMatchResult(
          originalName: csvName,
          confidence: confidence,
          exerciseId: best.id,
          matchedName: best.name,
          score: bestScore,
        );
      }
    }

    // 4. No match → low confidence (custom exercise offer).
    return ExerciseMatchResult(
      originalName: csvName,
      confidence: MatchConfidence.low,
    );
  }

  /// Batch-matches a list of unique CSV exercise names — returns results
  /// keyed by original name for O(n) lookup in the mapping review UI.
  Map<String, ExerciseMatchResult> matchAll(Iterable<String> csvNames) {
    final results = <String, ExerciseMatchResult>{};
    for (final name in csvNames) {
      if (!results.containsKey(name)) {
        results[name] = match(name);
      }
    }
    return results;
  }

  // --- Normalization ---

  /// Normalizes an exercise name for matching: lowercase, strip
  /// parenthetical equipment suffixes ("Bench Press (Barbell)" →
  /// "bench press"), remove special characters, collapse whitespace.
  static String _normalize(String name) {
    var n = name.trim().toLowerCase();
    // Strip parenthetical content: "(Barbell)", "(Dumbbell)", etc.
    n = n.replaceAll(RegExp(r'\([^)]*\)'), '');
    // Strip bracket content: [Barbell]
    n = n.replaceAll(RegExp(r'\[[^\]]*\]'), '');
    // Remove common equipment/movement qualifiers that appear as standalone
    // words (the catalog name already includes these where relevant).
    // e.g. "barbell bench press" → "bench press" for token overlap.
    // (We keep the full normalized string for exact match but strip
    // for token comparison.)
    n = n.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    // Collapse whitespace.
    n = n.replaceAll(RegExp(r'\s+'), ' ').trim();
    return n;
  }

  /// Tokenizes a normalized name into a Set of word tokens, dropping
  /// common stop words that don't contribute to matching.
  static Set<String> _tokenize(String normalized) {
    const stopWords = {
      'the', 'a', 'an', 'with', 'and', 'on', 'to', 'of',
      // Equipment words — these appear in both CSV names and catalog
      // names, so they inflate Jaccard without adding discriminating
      // power. Removing them improves match quality.
      'barbell', 'dumbbell', 'dumbbells', 'machine', 'cable',
      'kettlebell', 'band', 'bodyweight', 'body', 'weight',
      'smith', 'ez', 'bar', 'bands',
    };
    return normalized
        .split(' ')
        .where((t) => t.isNotEmpty && !stopWords.contains(t))
        .map((t) => (t.endsWith('s') && !t.endsWith('ss') && t.length > 3)
            ? t.substring(0, t.length - 1)
            : t)
        .toSet();
  }

  /// Jaccard similarity: |A ∩ B| / |A ∪ B|. Returns 0.0 if both sets
  /// are empty.
  static double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    final intersection = a.intersection(b).length;
    final union = a.union(b).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  static List<_CatalogEntry> _buildIndex(List<Exercise> catalog) {
    return catalog.map((e) {
      final normalized = _normalize(e.name);
      return _CatalogEntry(
        id: e.id,
        name: e.name,
        normalized: normalized,
        tokens: _tokenize(normalized),
      );
    }).toList();
  }
}

class _CatalogEntry {
  const _CatalogEntry({
    required this.id,
    required this.name,
    required this.normalized,
    required this.tokens,
  });

  const _CatalogEntry._empty()
      : id = null,
        name = '',
        normalized = '',
        tokens = const {};

  final String? id;
  final String name;
  final String normalized;
  final Set<String> tokens;
}
