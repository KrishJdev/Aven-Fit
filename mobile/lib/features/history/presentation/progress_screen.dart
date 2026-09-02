import 'package:aven_fit/core/l10n/l10n.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../history/domain/workout_history_item.dart';
import '../../progress/data/streak_repository.dart';
import '../../progress/domain/streak_info.dart';
import '../../progress/presentation/pr_vault_controller.dart';
import '../../progress/data/pr_local_source.dart';
import '../../progress/domain/pr_record.dart';
import '../../workout/presentation/home_controller.dart';

/// Progress tab (WU-X.3, FEATURES.md §10/§17): the streak at a glance,
/// the PR Vault preview with the full vault one tap away, the recent
/// workouts list, and the body-weight placeholder. Everything renders
/// reactively from local SQLite — zero network (L2); adherence-neutral
/// facts only (L4), designed empty states (L6).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
    final streakAsync = ref.watch(watchStreakInfoProvider);
    final vaultAsync = ref.watch(prVaultStreamProvider);
    final recentAsync = ref.watch(recentWorkoutsStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              l10n.progressTitle,
              style: AppTheme.num(
                20,
                weight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Streak (§17): current chain + this week's forgiving progress.
            streakAsync.maybeWhen(
              data: (streak) => _StreakCard(streak: streak),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // PR Vault preview (§10.2): the newest records, full vault
            // one tap away.
            _SectionHeader(
              title: l10n.prVaultTitle,
              actionKey: 'progress_pr_view_all',
              actionLabel: l10n.viewAll,
              onAction: () => context.push('/progress/prs'),
              visible: vaultAsync.value?.isNotEmpty ?? false,
            ),
            vaultAsync.maybeWhen(
              data: (entries) => entries.isEmpty
                  ? const _PrEmptyState()
                  : Column(
                      key: const ValueKey('progress_pr_section'),
                      children: [
                        for (final entry in entries.take(5))
                          _PrPreviewRow(entry: entry),
                      ],
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Recent workouts (§7.1 parity): top 5, full history one tap
            // away (WU-3.9).
            _SectionHeader(
              title: l10n.homeRecentWorkouts,
              actionKey: 'progress_recent_view_all',
              actionLabel: l10n.viewAll,
              onAction: () => context.push('/history'),
              visible: recentAsync.value?.isNotEmpty ?? false,
            ),
            recentAsync.maybeWhen(
              data: (items) => items.isEmpty
                  ? const _RecentEmptyState()
                  : Column(
                      key: const ValueKey('progress_recent_section'),
                      children: [
                        for (final item in items.take(5))
                          _RecentWorkoutCard(item: item),
                      ],
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Body-weight preview (§10.3 [PROPOSED]) — P1 placeholder.
            const _BodyWeightPlaceholder(),
          ],
        ),
      ),
    );
  }
}

/// Section header with an optional VIEW ALL action.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionKey,
    required this.actionLabel,
    required this.onAction,
    required this.visible,
  });

  final String title;
  final String actionKey;
  final String actionLabel;
  final VoidCallback onAction;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: AppTheme.num(
              11,
              weight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          if (visible)
            TextButton(
              key: ValueKey(actionKey),
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: AppTheme.neonCyan,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Streak card (§17): the forgiving weekly goal progress plus the
/// current chain — neutral facts; a 0-week streak reads as "0 weeks",
/// never a shaming verdict (L4).
class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final StreakInfo streak;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final met = streak.weeklyGoalMet;
    return Container(
      key: const ValueKey('progress_streak_card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.glanceThisWeek,
                  style: AppTheme.num(
                    10,
                    weight: FontWeight.w700,
                    color: met ? AppTheme.neonCyan : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  key: const ValueKey('progress_week_value'),
                  streak.weeklyProgressDisplay,
                  style: AppTheme.num(
                    17,
                    weight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 34,
            color: AppTheme.glassBorder,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'STREAK',
                  style: AppTheme.num(
                    10,
                    weight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  key: const ValueKey('progress_streak_value'),
                  streak.currentStreakWeeks > 0
                      ? streak.streakDisplay
                      : l10nOf(context).streakZeroWeeks,
                  style: AppTheme.num(
                    17,
                    weight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One PR preview row: exercise name + type badge + value + date.
class _PrPreviewRow extends StatelessWidget {
  const _PrPreviewRow({required this.entry});

  final PRVaultEntry entry;

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
    final record = entry.record;
    final type = RecordType.fromName(record.recordType);
    return InkWell(
      key: ValueKey('progress_pr_entry_${record.id}'),
      onTap: () => context.push('/progress/prs'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.glassFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.exerciseName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _relativeDate(context, record.achievedAt, DateTime.now()),
                    style: AppTheme.num(
                      10.5,
                      weight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              type.formatValue(record.value, weightKg: record.weightKg),
              style: AppTheme.num(
                13,
                weight: FontWeight.w600,
                color: AppTheme.voltGreen,
              ),
            ),
            const SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }
}

/// Designed empty PR state (L6): records are detected automatically at
/// set confirmation (§10.2) — a fact, not a challenge (L4).
class _PrEmptyState extends StatelessWidget {
  const _PrEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Container(
      key: const ValueKey('progress_pr_empty'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Text(
        l10n.progressPrEmpty,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
      ),
    );
  }
}

/// Compact history card — same composition as the Home recent card.
class _RecentWorkoutCard extends StatelessWidget {
  const _RecentWorkoutCard({required this.item});

  final WorkoutHistoryItem item;

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
    final l10n = l10nOf(context);
    final meta = l10n.progressRecentCardMeta(
      _relativeDate(context, item.date, DateTime.now()),
      item.exerciseCount,
      item.totalSetsCount,
      item.volumeDisplay,
    );

    return InkWell(
      key: ValueKey('progress_recent_card_${item.id}'),
      onTap: () => context.push('/history/${item.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.glassFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (item.prCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.voltGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.prCountChip(item.prCount),
                            style: AppTheme.num(
                              10,
                              weight: FontWeight.w700,
                              color: AppTheme.voltGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_relativeDate(context, item.date, DateTime.now())} · $meta',
                    style: AppTheme.num(
                      11,
                      weight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Designed empty recent-workouts state (L6).
class _RecentEmptyState extends StatelessWidget {
  const _RecentEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Container(
      key: const ValueKey('progress_recent_empty'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Text(
        l10n.homeHistoryEmptyMessageShort,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
      ),
    );
  }
}

/// Body-weight preview (§10.3 [PROPOSED]) — designed P1 placeholder, L6.
class _BodyWeightPlaceholder extends StatelessWidget {
  const _BodyWeightPlaceholder();

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Container(
      key: const ValueKey('progress_body_weight'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.scale,
            size: 18,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.linkBodyWeight,
                  style: AppTheme.num(
                    11,
                    weight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.bodyWeightPlaceholder,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
