import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../data/history_repository.dart';
import '../domain/workout_history_item.dart';

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
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'WORKOUT HISTORY',
          style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: feedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.neonCyan),
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
    final now = DateTime.now();
    final groups = <String, List<WorkoutHistoryItem>>{};
    for (final item in items) {
      groups.putIfAbsent(_groupLabel(item.date, now), () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: groups.length + (items.length >= limit ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= groups.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: OutlinedButton(
              key: const ValueKey('history_load_more'),
              onPressed: () => ref
                  .read(historyFeedLimitProvider.notifier)
                  .loadMore(),
              child: const Text(
                'LOAD MORE',
                style: TextStyle(color: AppTheme.neonCyan, fontSize: 13),
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
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Text(
                label,
                style: AppTheme.num(11, weight: FontWeight.w700, color: AppTheme.textSecondary),
              ),
            ),
            ...bucket.map((item) => _HistoryCard(item: item)),
          ],
        );
      },
    );
  }

  /// Date buckets (§8.6: grouped by week/month): TODAY · YESTERDAY ·
  /// THIS WEEK · month name for anything older.
  String _groupLabel(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    if (day.isAfter(weekStart.subtract(const Duration(days: 1)))) {
      return 'THIS WEEK';
    }
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final WorkoutHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final duration = _formatDuration(item.durationSeconds);
    final relativeDate = _relativeDate(item.date, DateTime.now());

    return InkWell(
      key: ValueKey('history_card_${item.id}'),
      onTap: () => context.push('/history/${item.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      Flexible(
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.num(14, weight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      if (item.prCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.voltGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.prCount} PR',
                            style: AppTheme.num(10, weight: FontWeight.w700, color: AppTheme.voltGreen),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$relativeDate · '
                    '${item.exerciseCount} exercise${item.exerciseCount == 1 ? '' : 's'}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.totalSetsCount} sets · ${item.volumeDisplay} kg · $duration',
                    style: AppTheme.num(12, weight: FontWeight.w600, color: AppTheme.neonCyan),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  String _relativeDate(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Designed empty state (L6): full history is empty — first-run welcome.
class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.history, size: 56, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'NO WORKOUTS YET',
              style: AppTheme.num(18, weight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your history will appear here once you complete your first workout.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/workout/active'),
              icon: const Icon(LucideIcons.play, size: 16),
              label: const Text('START WORKOUT'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.neonCyan,
                foregroundColor: Colors.black,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.triangleAlert, size: 48, color: AppTheme.burntOrange),
            const SizedBox(height: 16),
            Text(
              'COULD NOT LOAD HISTORY',
              style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => ref.invalidate(watchWorkoutHistoryProvider),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}
