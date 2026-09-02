import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../history/domain/workout_history_item.dart';
import '../../routine/domain/routine.dart';
import '../domain/workout_session.dart';
import 'home_controller.dart';
import 'home_state.dart';
import 'widgets/session_conflict_dialog.dart';

/// Root shell hosting the four main tabs (FEATURES.md §7): pitch-black
/// bar, white active tint, glass border top.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppTheme.oledBlack,
          border: Border(top: BorderSide(color: AppTheme.glassBorder)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(icon: Icon(LucideIcons.home), label: 'Home'),
            NavigationDestination(icon: Icon(LucideIcons.dumbbell), label: 'Workouts'),
            NavigationDestination(icon: Icon(LucideIcons.chartColumn), label: 'Progress'),
            NavigationDestination(icon: Icon(LucideIcons.salad), label: 'Nutrition'),
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
      backgroundColor: AppTheme.oledBlack,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HomeHeader(now: now),
            if (state.activeSession != null) ...[
              const SizedBox(height: 12),
              _ResumeBanner(session: state.activeSession!),
            ],
            const SizedBox(height: 20),
            _StartSessionButton(isFirstRun: state.isFirstRun),
            if (state.suggestedRoutine != null) ...[
              const SizedBox(height: 12),
              _SuggestedRoutineCard(routine: state.suggestedRoutine!),
            ],
            const SizedBox(height: 16),
            _GlanceSection(state: state),
            const SizedBox(height: 24),
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
      padding: const EdgeInsets.only(top: 8, bottom: 4),
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
                const SizedBox(height: 2),
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
            tooltip: 'Profile',
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
    final elapsed = session.elapsedSecondsNow();
    final elapsedText =
        '${(elapsed ~/ 60).toString().padLeft(2, '0')}:${(elapsed % 60).toString().padLeft(2, '0')}';
    final setsDone = session.completedSetsCount;
    final setsTotal = session.totalSetsCount;

    return InkWell(
      key: const ValueKey('home_resume_banner'),
      onTap: () => context.push('/workout/active'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.glassFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.neonCyan),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.play, size: 18, color: AppTheme.neonCyan),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WORKOUT IN PROGRESS',
                    style: AppTheme.num(12, weight: FontWeight.w700, color: AppTheme.neonCyan),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${session.name} · $elapsedText elapsed · $setsDone/$setsTotal sets',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.neonCyan),
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
    if (mayStart && context.mounted) {
      context.push('/workout/active');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: FilledButton(
        key: const ValueKey('home_start_button'),
        onPressed: () => _start(context, ref),
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.neonCyan,
          foregroundColor: AppTheme.oledBlack,
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        child: Text(isFirstRun ? 'START FIRST WORKOUT' : 'START NEW SESSION'),
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
    final meta =
        '${routine.exerciseCount} exercises · ${routine.totalSets} sets · '
        '~${routine.estimatedDurationMinutes} min';

    return InkWell(
      key: const ValueKey('home_suggested_routine'),
      onTap: () => _start(context, ref),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.glassFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.dumbbell, size: 20, color: AppTheme.neonCyan),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUGGESTED ROUTINE',
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
                  const SizedBox(height: 2),
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
            const Icon(LucideIcons.play, size: 18, color: AppTheme.voltGreen),
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
    final streak = state.streak;
    final glance = state.weeklyGlance;

    Widget? volumeBadge;
    final delta = state.volumeDeltaPercent;
    if (delta != null) {
      final up = delta >= 0;
      final color = up ? AppTheme.voltGreen : AppTheme.burntOrange;
      volumeBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.voltGreen.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '▲ NEW',
          style: AppTheme.num(
            10,
            weight: FontWeight.w700,
            color: AppTheme.voltGreen,
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
          label: 'THIS WEEK',
          value: streak?.weeklyProgressDisplay ?? '—',
          accent: (streak?.weeklyGoalMet ?? false)
              ? AppTheme.neonCyan
              : AppTheme.textSecondary,
        ),
        _GlanceChip(
          label: 'VOLUME',
          value: glance == null ? '—' : '${glance.thisWeek.volumeDisplay} kg',
          trailing: volumeBadge,
        ),
        _GlanceChip(
          label: 'SETS',
          value: glance == null ? '—' : '${glance.thisWeek.completedSetCount}',
        ),
        if (streak != null && streak.currentStreakWeeks > 0)
          _GlanceChip(
            label: 'STREAK',
            value: streak.streakDisplay,
            accent: AppTheme.neonCyan,
          ),
        if (state.hasCalorieGoal && calories != null)
          _GlanceChip(
            label: 'CALORIES LEFT',
            value: '${calories.round()} kcal',
          ),
      ],
    );
  }
}

/// Single glass glance chip — accent-colored label, tabular-numeral
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.num(10, weight: FontWeight.w700, color: accent),
          ),
          const SizedBox(height: 2),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'RECENT WORKOUTS',
              style: AppTheme.num(
                11,
                weight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            if (state.recentWorkouts.isNotEmpty)
              TextButton(
                key: const ValueKey('home_view_all_history'),
                onPressed: () => context.push('/history'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: AppTheme.neonCyan,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.recentWorkouts.isEmpty)
          const _RecentEmptyState()
        else
          ...state.recentWorkouts.map(
            (item) => _RecentWorkoutCard(item: item),
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
    return Container(
      key: const ValueKey('home_recent_empty'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        children: [
          Text(
            'YOUR HISTORY WILL APPEAR HERE',
            style: AppTheme.num(
              12,
              weight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No account needed. Works offline.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

/// Compact history card (§7.1 #6): name, relative date, exercise/sets/
/// volume/duration line, PR-count chip, tap → Past Workout Detail.
class _RecentWorkoutCard extends StatelessWidget {
  const _RecentWorkoutCard({required this.item});

  final WorkoutHistoryItem item;

  static String _relativeDate(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    return '${diff}d ago';
  }

  static String _duration(int seconds) {
    if (seconds >= 3600) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${(seconds / 60).round()} min';
  }

  @override
  Widget build(BuildContext context) {
    final meta =
        '${item.exerciseCount} exercises · ${item.totalSetsCount} sets · '
        '${item.volumeDisplay} kg · ${_duration(item.durationSeconds)}';

    return InkWell(
      key: ValueKey('home_recent_card_${item.id}'),
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
                      Expanded(
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (item.prCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          key: const ValueKey('home_recent_pr_chip'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.voltGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.prCount} PR',
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
                  const SizedBox(height: 3),
                  Text(
                    _relativeDate(item.date, DateTime.now()),
                    style: AppTheme.num(
                      10.5,
                      weight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    meta,
                    style: AppTheme.num(
                      11.5,
                      weight: FontWeight.w600,
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
