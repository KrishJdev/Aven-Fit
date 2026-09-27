import 'package:aven_fit/core/l10n/l10n.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:aven_fit/core/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../history/presentation/widgets/workout_history_card.dart';
import '../../routine/domain/routine.dart';
import '../domain/workout_session.dart';
import 'home_controller.dart';
import 'home_state.dart';
import 'widgets/session_conflict_dialog.dart';

/// Root shell hosting the four main tabs (FEATURES.md §7): OLED-black
/// bar, white active tint, divider top.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppTheme.background,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: [
            NavigationDestination(icon: const Icon(LucideIcons.home), label: l10nOf(context).navHome),
            NavigationDestination(icon: const Icon(LucideIcons.dumbbell), label: l10nOf(context).navWorkouts),
            NavigationDestination(icon: const Icon(LucideIcons.chartColumn), label: l10nOf(context).navProgress),
            NavigationDestination(icon: const Icon(LucideIcons.salad), label: l10nOf(context).navNutrition),
          ],
        ),
      ),
    );
  }
}

/// Home — today's launchpad (WU-X.1, FEATURES.md §7.1): resume or start
/// a workout in one tap, momentum at a glance, and the recent logs.
/// Every section renders from local SQLite — zero network (L2), designed
/// first-run and no-history states (L6), adherence-neutral stats (L4).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, AppTheme.spaceSm, AppTheme.spaceLg, AppTheme.spaceXxl),
          children: [
            _HomeHeader(now: now),
            if (state.activeSession != null) ...[
              const SizedBox(height: AppTheme.spaceMd),
              _ResumeBanner(session: state.activeSession!),
            ],
            const SizedBox(height: AppTheme.spaceXl),
            _StartSessionButton(isFirstRun: state.isFirstRun),
            if (state.suggestedRoutine != null) ...[
              const SizedBox(height: AppTheme.spaceMd),
              _SuggestedRoutineCard(routine: state.suggestedRoutine!),
            ],
            const SizedBox(height: AppTheme.spaceLg),
            _GlanceSection(state: state),
            _RecentWorkoutsSection(state: state),
          ],
        ),
      ),
    );
  }
}

/// Header (§7.1 #1): time-of-day greeting + date, with the profile
/// avatar — Profile is reached from the Home header, never a tab.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spaceSm, bottom: AppTheme.spaceXs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key: const ValueKey('home_greeting'),
                  HomeState.greetingLabel(now),
                  style: AppTheme.num(
                    20,
                    weight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXxs),
                Text(
                  HomeState.dateLabel(now),
                  style: AppTheme.num(
                    11,
                    weight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('home_profile_avatar'),
            tooltip: l10nOf(context).homeProfileTooltip,
            onPressed: () => context.push('/profile'),
            icon: const Icon(
              LucideIcons.circleUserRound,
              size: 26,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cyan-bordered "Workout in progress" card (FEATURES.md §7.1) — one tap
/// returns to the Active Workout screen with all sets and the epoch-math
/// timer restored from SQLite (L7/L8).
class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final elapsed = session.elapsedSecondsNow();
    final elapsedText =
        '${(elapsed ~/ 60).toString().padLeft(2, '0')}:${(elapsed % 60).toString().padLeft(2, '0')}';
    final setsDone = session.completedSetsCount;
    final setsTotal = session.totalSetsCount;

    return InkWell(
      key: const ValueKey('home_resume_banner'),
      onTap: () => context.push('/workout/active'),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppTheme.primary),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.play, size: 18, color: AppTheme.primary),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeResumeBannerTitle,
                    style: AppTheme.num(12, weight: FontWeight.w700, color: AppTheme.primary),
                  ),
                  const SizedBox(height: AppTheme.spaceXxs),
                  Text(
                    l10n.homeResumeBannerSubtitle(session.name, elapsedText, setsDone, setsTotal),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}

/// Giant primary action (§7.1 #3): START FIRST WORKOUT on the very first
/// run (§5.1's 60-second goal), START NEW SESSION afterwards. The
/// one-session rule (§8.1) guards every start — never silently discards.
class _StartSessionButton extends ConsumerWidget {
  const _StartSessionButton({required this.isFirstRun});

  final bool isFirstRun;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final mayStart = await resolveOneSessionRule(context, ref);
    if (!mayStart || !context.mounted) return;

    await ref.read(homeControllerProvider.notifier).startNewWorkout();
    if (context.mounted) {
      context.push('/workout/active');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: FilledButton(
        key: const ValueKey('home_start_button'),
        onPressed: () => _start(context, ref),
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.background,
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        child: Text(isFirstRun ? l10n.homeStartFirstWorkout : l10n.homeStartNewSession),
      ),
    );
  }
}

/// Suggested routine card (§7.1 #4): the most-recently used routine with
/// a one-tap start through the same <1s write-through path the Routines
/// tab uses (L1/L7 — the routine itself is never mutated).
class _SuggestedRoutineCard extends ConsumerWidget {
  const _SuggestedRoutineCard({required this.routine});

  final Routine routine;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final mayStart = await resolveOneSessionRule(context, ref);
    if (!mayStart || !context.mounted) {
      return;
    }
    final sessionId =
        await ref.read(homeControllerProvider.notifier).startSuggestedRoutine();
    if (sessionId != null && context.mounted) {
      context.push('/workout/active');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
    final meta = l10n.homeSuggestedRoutineMeta(
      routine.exerciseCount,
      routine.totalSets,
      routine.estimatedDurationMinutes,
    );

    return InkWell(
      key: const ValueKey('home_suggested_routine'),
      onTap: () => _start(context, ref),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.dumbbell, size: 20, color: AppTheme.primary),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeSuggestedRoutineTitle,
                    style: AppTheme.num(
                      10,
                      weight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    routine.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXxs),
                  Text(
                    meta,
                    style: AppTheme.num(
                      11.5,
                      weight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.play, size: 18, color: AppTheme.secondary),
          ],
        ),
      ),
    );
  }
}

/// Glance stats (§7.1 #5): weekly progress toward the forgiving goal,
/// volume with the ▲/▼ week-over-week delta, sets this week, the current
/// streak (omitted at 0 — a fact, never a shaming verdict, L4), and the
/// calories chip only when goals are set (hidden otherwise, L4).
class _GlanceSection extends StatelessWidget {
  const _GlanceSection({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final streak = state.streak;
    final glance = state.weeklyGlance;

    Widget? volumeBadge;
    final delta = state.volumeDeltaPercent;
    if (delta != null) {
      final up = delta >= 0;
      final color = up ? AppTheme.secondary : AppTheme.warning;
      volumeBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AppTheme.spaceXxs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${up ? '▲' : '▼'} ${delta.abs().round()}%',
          style: AppTheme.num(10, weight: FontWeight.w700, color: color),
        ),
      );
    } else if (state.volumeIsNewThisWeek) {
      volumeBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AppTheme.spaceXxs),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          l10n.glanceVolumeNew,
          style: AppTheme.num(
            10,
            weight: FontWeight.w700,
            color: AppTheme.secondary,
          ),
        ),
      );
    }

    final calories = state.caloriesRemaining;

    return Wrap(
      key: const ValueKey('home_glance_stats'),
      spacing: 10,
      runSpacing: 10,
      children: [
        _GlanceChip(
          label: l10n.glanceThisWeek,
          value: streak?.weeklyProgressDisplay ?? '—',
          accent: (streak?.weeklyGoalMet ?? false)
              ? AppTheme.primary
              : AppTheme.textSecondary,
        ),
        _GlanceChip(
          label: l10n.glanceVolume,
          value: glance == null ? '—' : '${glance.thisWeek.volumeDisplay} kg',
          trailing: volumeBadge,
        ),
        _GlanceChip(
          label: l10n.glanceSets,
          value: glance == null ? '—' : '${glance.thisWeek.completedSetCount}',
        ),
        if (streak != null && streak.currentStreakWeeks > 0)
          _GlanceChip(
            label: l10n.glanceStreak,
            value: streak.streakDisplay,
            accent: AppTheme.primary,
          ),
        if (state.hasCalorieGoal && calories != null)
          _GlanceChip(
            label: l10n.glanceCaloriesLeft,
            value: '${calories.round()} kcal',
          ),
      ],
    );
  }
}

/// Single surface glance chip — accent-colored label, tabular-numeral
/// value, optional trailing badge (the ▲/▼ volume delta).
class _GlanceChip extends StatelessWidget {
  const _GlanceChip({
    required this.label,
    required this.value,
    this.accent = AppTheme.textSecondary,
    this.trailing,
  });

  final String label;
  final String value;
  final Color accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.num(10, weight: FontWeight.w700, color: accent),
          ),
          const SizedBox(height: AppTheme.spaceXxs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTheme.num(
                  14,
                  weight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Recent logs (§7.1 #6): the last 10 completed workouts with designed
/// first-run / no-history states (§5.1 + L6).
class _RecentWorkoutsSection extends StatelessWidget {
  const _RecentWorkoutsSection({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          label: l10n.homeRecentWorkouts,
          actionLabel:
              state.recentWorkouts.isNotEmpty ? l10n.viewAll : null,
          onAction:
              state.recentWorkouts.isNotEmpty ? () => context.push('/history') : null,
          actionKey: const ValueKey('home_view_all_history'),
        ),
        if (state.recentWorkouts.isEmpty)
          const _RecentEmptyState()
        else
          ...state.recentWorkouts.map(
            (item) => WorkoutHistoryCard(
              item: item,
              cardKey: ValueKey('home_recent_card_${item.id}'),
              variant: HistoryCardVariant.compact,
              prChipKey: const ValueKey('home_recent_pr_chip'),
            ),
          ),
      ],
    );
  }
}

/// First-run / no-history state (§7.1: "Your history will appear here";
/// §5.1: the welcome explainer — never a blank section, L6).
class _RecentEmptyState extends StatelessWidget {
  const _RecentEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Container(
      key: const ValueKey('home_recent_empty'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl, vertical: AppTheme.spaceXxl),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        children: [
          Text(
            l10n.homeHistoryEmptyTitle,
            style: AppTheme.num(
              12,
              weight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.homeHistoryEmptyMessage,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
