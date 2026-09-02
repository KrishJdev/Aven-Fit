import 'package:aven_fit/core/l10n/l10n.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:aven_fit/core/widgets/empty_state_widget.dart';
import 'package:aven_fit/core/widgets/error_state_widget.dart';
import 'package:aven_fit/core/widgets/loading_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/pr_local_source.dart';
import '../domain/pr_record.dart';
import 'pr_vault_controller.dart';

/// Sort modes for the vault (§10.2 "sort by date/value"): newest
/// achievement first, or highest record value first.
enum PrVaultSort { date, value }

/// Sentinel for the "all exercises" filter option (a DropdownButton needs
/// a non-null value per item).
const String _allExercises = '__all__';

/// Full PR vault (WU-X.3, FEATURES.md §10.2): every personal record
/// grouped by exercise, showing all four record types per exercise, with
/// **filter by exercise** and **sort by date/value** controls. Renders
/// reactively from local SQLite (L2/L8); the designed empty state
/// explains that records are detected automatically (L6).
class PrVaultScreen extends ConsumerStatefulWidget {
  const PrVaultScreen({super.key});

  @override
  ConsumerState<PrVaultScreen> createState() => _PrVaultScreenState();
}

class _PrVaultScreenState extends ConsumerState<PrVaultScreen> {
  PrVaultSort _sort = PrVaultSort.date;
  String _exerciseFilter = _allExercises;

  /// Applies the filter, then orders rows (and groups) by the chosen key.
  /// Date mode keeps the stream's newest-first order; value mode ranks
  /// rows — and each exercise group by its best record — by value.
  List<PRVaultEntry> _visibleEntries(List<PRVaultEntry> entries) {
    final filtered = _exerciseFilter == _allExercises
        ? entries
        : entries
            .where((e) => e.exerciseName == _exerciseFilter)
            .toList();
    if (_sort == PrVaultSort.date) {
      return filtered;
    }
    final sorted = [...filtered]..sort(
        (a, b) => b.record.value.compareTo(a.record.value),
      );
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final vaultAsync = ref.watch(prVaultStreamProvider);
    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.prVaultTitle,
          style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: vaultAsync.when(
        loading: () => const Center(
          child: SingleChildScrollView(
            child: LoadingStateWidget(),
          ),
        ),
        error: (err, _) => ErrorStateWidget(
          error: err,
          onRetry: () => ref.invalidate(prVaultStreamProvider),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: EmptyStateWidget(
                key: const ValueKey('pr_vault_empty'),
                icon: LucideIcons.trophy,
                title: l10n.prVaultEmptyTitle,
                message: l10n.prVaultEmptyMessage,
              ),
            );
          }

          final visible = _visibleEntries(entries);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _VaultControls(
                sort: _sort,
                exerciseFilter: _exerciseFilter,
                exerciseNames: groupByExercise(entries).keys.toList(),
                onSortChanged: (mode) => setState(() => _sort = mode),
                onExerciseChanged: (name) =>
                    setState(() => _exerciseFilter = name),
              ),
              Expanded(
                child: _VaultList(entries: visible),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Filter/sort control row (§10.2): exercise dropdown + date/value toggle.
class _VaultControls extends StatelessWidget {
  const _VaultControls({
    required this.sort,
    required this.exerciseFilter,
    required this.exerciseNames,
    required this.onSortChanged,
    required this.onExerciseChanged,
  });

  final PrVaultSort sort;
  final String exerciseFilter;
  final List<String> exerciseNames;
  final ValueChanged<PrVaultSort> onSortChanged;
  final ValueChanged<String> onExerciseChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          // Exercise filter — hidden when a single exercise covers all rows
          // (nothing to filter).
          if (exerciseNames.length > 1) ...[
            Expanded(
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppTheme.glassFill,
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    key: const ValueKey('pr_vault_exercise_filter'),
                    value: exerciseFilter,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF16191D),
                    icon: const Icon(
                      LucideIcons.chevronDown,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: _allExercises,
                        child: Text(l10nOf(context).vaultFilterAllExercises),
                      ),
                      for (final name in exerciseNames)
                        DropdownMenuItem(value: name, child: Text(name)),
                    ],
                    onChanged: (name) {
                      if (name != null) onExerciseChanged(name);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          // Sort toggle: date (newest) ↔ value (highest).
          InkWell(
            key: const ValueKey('pr_vault_sort_toggle'),
            onTap: () => onSortChanged(
              sort == PrVaultSort.date ? PrVaultSort.value : PrVaultSort.date,
            ),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppTheme.glassFill,
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    sort == PrVaultSort.date
                        ? LucideIcons.calendar
                        : LucideIcons.arrowDownWideNarrow,
                    size: 13,
                    color: AppTheme.neonCyan,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sort == PrVaultSort.date
                        ? l10nOf(context).vaultSortNewest
                        : l10nOf(context).vaultSortBestValue,
                    style: AppTheme.num(
                      10.5,
                      weight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Groups the vault rows by exercise (input order preserved — the screen
/// pre-sorts entries, so group order and within-group order follow the
/// chosen sort mode).
Map<String, List<PRVaultEntry>> groupByExercise(List<PRVaultEntry> entries) {
  final groups = <String, List<PRVaultEntry>>{};
  for (final entry in entries) {
    groups.putIfAbsent(entry.exerciseName, () => []).add(entry);
  }
  return groups;
}

class _VaultList extends StatelessWidget {
  const _VaultList({required this.entries});

  final List<PRVaultEntry> entries;

  @override
  Widget build(BuildContext context) {
    final groups = groupByExercise(entries);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (final exerciseName in groups.keys)
          _ExercisePrGroup(
            exerciseName: exerciseName,
            records: groups[exerciseName]!,
          ),
      ],
    );
  }
}

/// One exercise's record card: the name header and every record row
/// (type label, value, achievement date).
class _ExercisePrGroup extends StatelessWidget {
  const _ExercisePrGroup({required this.exerciseName, required this.records});

  final String exerciseName;
  final List<PRVaultEntry> records;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('pr_vault_group_$exerciseName'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exerciseName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in records)
            _PrRow(
              key: ValueKey('pr_vault_row_${entry.record.id}'),
              entry: entry,
            ),
        ],
      ),
    );
  }
}

/// Single record row: type badge, value, relative achievement date.
/// The drift row stores the type as text — parsed through the domain
/// enum's tolerant [RecordType.fromName].
class _PrRow extends StatelessWidget {
  const _PrRow({required this.entry, super.key});

  final PRVaultEntry entry;

  RecordType get type => RecordType.fromName(entry.record.recordType);

  static String _relativeDate(
    BuildContext context,
    DateTime date,
    DateTime now,
  ) {
    final l10n = l10nOf(context);
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return l10n.dateToday;
    if (diff == 1) return l10n.dateYesterday;
    return l10n.dateDaysAgo(diff);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.neonCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type.label,
              style: AppTheme.num(
                9.5,
                weight: FontWeight.w700,
                color: AppTheme.neonCyan,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              type.formatValue(
                entry.record.value,
                weightKg: entry.record.weightKg,
              ),
              style: AppTheme.num(
                13.5,
                weight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            _relativeDate(context, entry.record.achievedAt, DateTime.now()),
            style: AppTheme.num(
              10.5,
              weight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
