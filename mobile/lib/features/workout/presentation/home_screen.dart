import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../progress/data/streak_repository.dart';
import '../data/workout_repository.dart';
import '../domain/workout_session.dart';
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

/// Slice-1 placeholder for the Home tab. Real Home lands with its
/// owning slice; the shell proves theme + router + DI wiring end to end.
///
/// WU-3.8 additions: the reactive resume banner (§7.1) and the one-session
/// rule on START NEW SESSION (§8.1).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionAsync = ref.watch(watchActiveSessionProvider);

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AVEN FIT',
                style: AppTheme.num(28, weight: FontWeight.w600, color: AppTheme.neonCyan),
              ),
              const SizedBox(height: 8),
              const Text('Foundation online — offline-first.', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              // Resume banner (§7.1, conditional): cyan-bordered, never
              // buried, renders from local SQLite within 1s of returning
              // home (L2/L7) — restores the exact in-progress state.
              activeSessionAsync.whenOrNull(
                    data: (session) => session == null
                        ? null
                        : _ResumeBanner(session: session),
                  ) ??
                  const SizedBox.shrink(),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  // One-session rule (§8.1): never silently discards data.
                  final mayStart = await resolveOneSessionRule(context, ref);
                  if (mayStart && context.mounted) {
                    context.push('/workout/active');
                  }
                },
                child: const Text('START NEW SESSION'),
              ),
              const SizedBox(height: 16),
              // Glance stats (§5.2): "X of Y" forgiving-streak progress +
              // current streak, reactive from SQLite (WU-X.2). The streak
              // chip is omitted at 0 — a fact, never a shaming verdict (L4).
              const _GlanceStatsRow(),
            ],
          ),
        ),
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
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.glassFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.neonCyan),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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

/// Glance stats row (FEATURES.md §5.2, WU-X.2): weekly "X of Y" progress
/// toward the forgiving goal and the current streak in weeks, both
/// reactive from local SQLite. Renders neutrally while loading and keeps
/// the streak chip out of the UI entirely at 0 (L4 — never shame).
class _GlanceStatsRow extends ConsumerWidget {
  const _GlanceStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(watchStreakInfoProvider);

    return streakAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (streak) {
        return Row(
          key: const ValueKey('home_glance_stats'),
          mainAxisSize: MainAxisSize.min,
          children: [
            _GlanceChip(
              label: 'THIS WEEK',
              value: streak.weeklyProgressDisplay,
              met: streak.weeklyGoalMet,
            ),
            if (streak.currentStreakWeeks > 0) ...[
              const SizedBox(width: 8),
              _GlanceChip(
                label: 'STREAK',
                value: streak.streakDisplay,
                met: true,
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Single glass glance chip — cyan when the goal is met, neutral glass
/// otherwise (adherence-neutral coloring, L4).
class _GlanceChip extends StatelessWidget {
  const _GlanceChip({required this.label, required this.value, required this.met});

  final String label;
  final String value;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final accent = met ? AppTheme.neonCyan : AppTheme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.num(10, weight: FontWeight.w700, color: accent),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.num(14, weight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
