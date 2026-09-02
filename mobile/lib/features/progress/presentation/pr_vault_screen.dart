import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../data/pr_local_source.dart';
import '../domain/pr_record.dart';
import 'pr_vault_controller.dart';

/// Full PR vault (WU-X.3, FEATURES.md §10.2): every personal record
/// grouped by exercise, showing all four record types per exercise.
/// Renders reactively from local SQLite (L2/L8); the designed empty
/// state explains that records are detected automatically (L6).
class PrVaultScreen extends ConsumerWidget {
  const PrVaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'PR VAULT',
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
                title: 'NO RECORDS YET',
                message:
                    'Confirm a working set — records are detected automatically.',
              ),
            );
          }
          return _VaultList(entries: entries);
        },
      ),
    );
  }
}

/// Groups the newest-first vault rows by exercise (first-seen order =
/// the group's newest achievement), preserving newest-first within.
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

  static String _relativeDate(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    return '${diff}d ago';
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
            _relativeDate(entry.record.achievedAt, DateTime.now()),
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

