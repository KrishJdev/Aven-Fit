import 'package:aven_fit/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../data/history_repository.dart';
import '../domain/workout_history_item.dart';
import 'widgets/workout_history_card.dart';

/// Full workout history list (WU-3.9, FEATURES.md §8.6): every completed
/// workout, grouped by date bucket, with sets · volume · duration and a PR
/// chip per row. Renders reactively from local SQLite — zero network (L2),
/// virtualized list, designed empty/loading/error states (L6).
class HistoryListScreen extends ConsumerWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(watchWorkoutHistoryProvider);
    final limit = ref.watch(historyFeedLimitProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppTheme.textPrimary, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10nOf(context).historyTitle,
          style: AppTheme.num(16, weight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
      ),
      body: feedAsync.when(
        loading: () => const Center(
          child: SingleChildScrollView(
            child: LoadingStateWidget(),
          ),
        ),
        error: (err, _) => _HistoryErrorState(error: err),
        data: (items) {
          if (items.isEmpty) {
            return const _HistoryEmptyState();
          }
          return _HistoryFeed(items: items, limit: limit);
        },
      ),
    );
  }
}

class _HistoryFeed extends ConsumerWidget {
  const _HistoryFeed({required this.items, required this.limit});

  final List<WorkoutHistoryItem> items;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
    final now = DateTime.now();
    final groups = <String, List<WorkoutHistoryItem>>{};
    for (final item in items) {
      groups.putIfAbsent(_groupLabel(l10n, item.date, now), () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, AppTheme.spaceSm, AppTheme.spaceLg, AppTheme.spaceXxl),
      itemCount: groups.length + (items.length >= limit ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= groups.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
            child: OutlinedButton(
              key: const ValueKey('history_load_more'),
              onPressed: () => ref
                  .read(historyFeedLimitProvider.notifier)
                  .loadMore(),
              child: Text(
                l10n.historyLoadMore,
                style: const TextStyle(color: AppTheme.primary, fontSize: 13),
              ),
            ),
          );
        }
        final label = groups.keys.elementAt(index);
        final bucket = groups[label]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.spaceXs, AppTheme.spaceLg, AppTheme.spaceXs, AppTheme.spaceSm),
              child: Text(
                label,
                style: AppTheme.num(11, weight: FontWeight.w700, color: AppTheme.textSecondary),
              ),
            ),
            ...bucket.map(
              (item) => WorkoutHistoryCard(
                item: item,
                cardKey: ValueKey('history_card_${item.id}'),
                variant: HistoryCardVariant.standard,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Date buckets (§8.6: grouped by week/month): TODAY · YESTERDAY ·
  /// THIS WEEK · month name for anything older. The first three are UI
  /// labels (localized); the month-year format is domain-derived date
  /// formatting, deferred to the V1.1 plural-aware i18n pass.
  String _groupLabel(AppLocalizations l10n, DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return l10n.historyBucketToday;
    if (diff == 1) return l10n.historyBucketYesterday;
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    if (day.isAfter(weekStart.subtract(const Duration(days: 1)))) {
      return l10n.historyBucketThisWeek;
    }
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Designed empty state (L6): full history is empty — first-run welcome.
class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.history, size: 56, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              l10n.historyEmptyTitle,
              style: AppTheme.num(18, weight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              l10n.historyEmptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: AppTheme.spaceXxl),
            FilledButton.icon(
              onPressed: () => context.push('/workout/active'),
              icon: const Icon(LucideIcons.play, size: 16),
              label: Text(l10n.historyStartWorkout),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Designed error state (L6) with a recovery path.
class _HistoryErrorState extends ConsumerWidget {
  const _HistoryErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.triangleAlert, size: 48, color: AppTheme.warning),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              l10n.historyErrorTitle,
              style: AppTheme.num(16, weight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            OutlinedButton(
              onPressed: () => ref.invalidate(watchWorkoutHistoryProvider),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
