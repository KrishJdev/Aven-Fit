import 'package:aven_fit/core/l10n/l10n.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:aven_fit/features/history/domain/workout_history_item.dart';
import 'package:aven_fit/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A completed-workout card for a [WorkoutHistoryItem] (§7.1 #6 / §8.6).
///
/// Two variants share one structure — `InkWell > surface Container > Row
/// ([title-row + date-line + meta-line], chevron)` — so the history-feed and
/// Home recent-workouts surfaces render the same data the same way. The
/// variant only selects typography, string source, and the meta accent:
///
/// - [HistoryCardVariant.compact]  — Home's recent-workouts row: l10n strings,
///   secondary-colored meta, 16px chevron, `Expanded` title (chip pinned right).
/// - [HistoryCardVariant.standard] — the History feed card: hardcoded strings
///   (pending the l10n pass), primary-colored meta, 18px chevron, `Flexible`
///   title (chip follows the name).
///
/// Same data, same pattern (§2.3). The PR chip, date, and meta are always
/// rendered; the variant never changes *what* is shown, only *how*.
class WorkoutHistoryCard extends StatelessWidget {
  const WorkoutHistoryCard({
    required this.item,
    required this.cardKey,
    this.variant = HistoryCardVariant.standard,
    this.prChipKey,
    super.key,
  });

  final WorkoutHistoryItem item;
  final Key cardKey;
  final HistoryCardVariant variant;

  /// Optional test key for the PR chip — lets the compact variant preserve
  /// the Home `home_recent_pr_chip` `find.byKey` contract.
  final Key? prChipKey;

  @override
  Widget build(BuildContext context) {
    final isCompact = variant == HistoryCardVariant.compact;
    final l10n = l10nOf(context);
    final now = DateTime.now();

    final relativeDate = isCompact
        ? _compactRelativeDate(l10n, item.date, now)
        : _standardRelativeDate(item.date, now);
    final dateLine = isCompact
        ? relativeDate
        : '$relativeDate · ${item.exerciseCount} exercise${item.exerciseCount == 1 ? '' : 's'}';
    final meta = isCompact
        ? l10n.homeRecentCardMeta(
            item.exerciseCount,
            item.totalSetsCount,
            item.volumeDisplay,
            _compactDuration(item.durationSeconds),
          )
        : '${item.totalSetsCount} sets · ${item.volumeDisplay} kg · ${_standardDuration(item.durationSeconds)}';
    final prChipText = isCompact ? l10n.prCountChip(item.prCount) : '${item.prCount} PR';

    final nameWidget = Text(
      item.name,
      overflow: TextOverflow.ellipsis,
      style: isCompact
          ? const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            )
          : AppTheme.num(14, weight: FontWeight.w700, color: AppTheme.textPrimary),
    );

    return InkWell(
      key: cardKey,
      onTap: () => context.push('/history/${item.id}'),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row: name + optional PR chip.
                  Row(
                    children: [
                      if (isCompact)
                        Expanded(child: nameWidget)
                      else
                        Flexible(child: nameWidget),
                      if (item.prCount > 0) ...[
                        const SizedBox(width: AppTheme.spaceSm),
                        Container(
                          key: prChipKey,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AppTheme.spaceXxs),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary
                                .withValues(alpha: isCompact ? 0.12 : 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            prChipText,
                            style: AppTheme.num(
                              10,
                              weight: FontWeight.w700,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: isCompact ? 3 : AppTheme.spaceXs),
                  Text(
                    dateLine,
                    style: isCompact
                        ? AppTheme.num(10.5, weight: FontWeight.w500, color: AppTheme.textSecondary)
                        : const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  SizedBox(height: isCompact ? 5 : 6),
                  Text(
                    meta,
                    style: isCompact
                        ? AppTheme.num(11.5, weight: FontWeight.w600, color: AppTheme.textSecondary)
                        : AppTheme.num(12, weight: FontWeight.w600, color: AppTheme.primary),
                  ),
                ],
              ),
            ),
            if (isCompact) const SizedBox(width: AppTheme.spaceSm),
            Icon(
              LucideIcons.chevronRight,
              size: isCompact ? 16 : 18,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ---- Variant-specific string helpers ----

  String _compactRelativeDate(AppLocalizations l10n, DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return l10n.dateToday;
    if (diff == 1) return l10n.dateYesterday;
    return l10n.dateDaysAgo(diff);
  }

  String _standardRelativeDate(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _compactDuration(int totalSeconds) {
    if (totalSeconds >= 3600) {
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${(totalSeconds / 60).round()} min';
  }

  String _standardDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

enum HistoryCardVariant { compact, standard }
