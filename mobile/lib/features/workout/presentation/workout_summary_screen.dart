import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/session_exercise.dart';
import '../domain/workout_set.dart';
import 'workout_summary_controller.dart';
import 'workout_summary_state.dart';

/// Post-workout summary screen (FEATURES.md §8.5).
///
/// The dopamine moment: renders immediately after Finish from already-persisted
/// SQLite data — stats grid (duration · working volume · sets · PRs), the
/// forgiving weekly streak badge when the goal is met, and a per-exercise
/// breakdown with PR badges. Celebration is a single haptic + brief volt-green
/// flash — never confetti-heavy (L5). Never blank: not-found and error states
/// always offer a way back (L6).
class WorkoutSummaryScreen extends ConsumerWidget {
  const WorkoutSummaryScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(workoutSummaryControllerProvider(sessionId));

    // One-shot PR celebration: a single medium haptic when the freshly loaded
    // summary contains new records (L5 — haptic + flash only, no sounds).
    ref.listen<AsyncValue<WorkoutSummaryState>>(
      workoutSummaryControllerProvider(sessionId),
      (prev, next) {
        final prevCount = prev?.value?.prCount ?? 0;
        final prCount = next.value?.prCount ?? 0;
        if (prevCount == 0 && prCount > 0) {
          HapticFeedback.mediumImpact();
        }
      },
    );

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'WORKOUT SUMMARY',
          style: AppTheme.num(16, weight: FontWeight.w700, color: AppTheme.neonCyan),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.neonCyan),
        ),
        error: (err, stack) => _buildErrorState(context, ref, err),
        data: (state) => state.notFound
            ? _buildNotFoundState(context)
            : _buildSummary(context, ref, state),
      ),
      bottomNavigationBar: stateAsync.whenOrNull(
        data: (state) => state.notFound ? null : _buildDoneBar(context),
      ),
    );
  }

  // ---- Body states ----

  Widget _buildSummary(
    BuildContext context,
    WidgetRef ref,
    WorkoutSummaryState state,
  ) {
    final session = state.session!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Editable title (inline rename, L7 write-through)
        GestureDetector(
          onTap: () => _showRenameDialog(context, ref, currentName: session.name),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  session.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.num(20, weight: FontWeight.w700, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.pencil, size: 16, color: AppTheme.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCompletedDate(session.completedAt),
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),

        // Forgiving weekly streak badge — only when the goal is met (never a nag, L4)
        if (state.weeklyGoalMet) ...[
          const SizedBox(height: 12),
          _buildStreakBadge(state.weeklyWorkoutCount, state.weeklyGoal),
        ],

        const SizedBox(height: 16),
        _buildStatsGrid(state),
        const SizedBox(height: 16),

        // Exercise breakdown cards
        ...state.exercises.map(
          (se) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ExerciseSummaryCard(sessionExercise: se),
          ),
        ),
      ],
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.searchX, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'WORKOUT NOT FOUND',
              style: AppTheme.num(20, weight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'This workout may have been discarded or removed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go('/home'),
              child: const Text('BACK TO HOME'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.triangleAlert, size: 48, color: AppTheme.burntOrange),
            const SizedBox(height: 16),
            Text(
              'COULD NOT LOAD SUMMARY',
              style: AppTheme.num(18, weight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => ref.invalidate(workoutSummaryControllerProvider(sessionId)),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Sections ----

  Widget _buildStreakBadge(int weeklyCount, int weeklyGoal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.voltGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.voltGreen.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.flame, size: 16, color: AppTheme.voltGreen),
          const SizedBox(width: 8),
          Text(
            'WEEKLY GOAL MET · $weeklyCount OF $weeklyGoal WORKOUTS',
            style: AppTheme.num(11, weight: FontWeight.w700, color: AppTheme.voltGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(WorkoutSummaryState state) {
    final volume = state.totalVolumeKg;
    final volumeText =
        volume % 1 == 0 ? volume.toInt().toString() : volume.toStringAsFixed(1);
    final prCount = state.prCount;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: [
        _StatCell(label: 'DURATION', value: _formatDuration(state.durationSeconds)),
        _StatCell(
          label: 'WORKING VOLUME',
          value: '$volumeText kg',
          valueColor: AppTheme.voltGreen,
        ),
        _StatCell(label: 'SETS', value: '${state.completedSetsCount}'),
        _PrStatCell(
          label: 'PRS',
          value: '${state.prCount}',
          celebrate: prCount > 0,
        ),
      ],
    );
  }

  Widget _buildDoneBar(BuildContext context) {
    return Container(
      color: AppTheme.oledBlack,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.go('/home'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.neonCyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('DONE'),
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    WidgetRef ref, {
    required String currentName,
  }) {
    final textController = TextEditingController(text: currentName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16191D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'RENAME WORKOUT',
          style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Workout name...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(workoutSummaryControllerProvider(sessionId).notifier)
                  .renameWorkout(textController.text);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.neonCyan,
              foregroundColor: Colors.black,
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  // ---- Formatting helpers ----

  static String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    if (h > 0) return '$h:${two(m)}:${two(s)}';
    return '${two(m)}:${two(s)}';
  }

  static String _formatWeight(double kg) =>
      kg % 1 == 0 ? kg.toInt().toString() : kg.toStringAsFixed(1);

  static String _formatCompletedDate(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} · ${two(dt.hour)}:${two(dt.minute)}';
  }
}

/// Single stat tile in the summary grid.
class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.num(18, weight: FontWeight.w700, color: valueColor),
          ),
        ],
      ),
    );
  }
}

/// PR stat tile with a one-shot volt-green flash celebration (L5 — no confetti).
class _PrStatCell extends StatelessWidget {
  const _PrStatCell({
    required this.label,
    required this.value,
    required this.celebrate,
  });

  final String label;
  final String value;
  final bool celebrate;

  @override
  Widget build(BuildContext context) {
    final cell = _StatCell(
      label: label,
      value: value,
      valueColor: celebrate ? AppTheme.voltGreen : Colors.white,
    );

    if (!celebrate) return cell;

    // Brief volt-green flash that fades out on first render.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      builder: (context, alpha, child) {
        return Container(
          foregroundDecoration: BoxDecoration(
            color: AppTheme.voltGreen.withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        );
      },
      child: cell,
    );
  }
}

/// Per-exercise breakdown card: name, working volume, and each completed set
/// rendered as `weight × reps` with PR badges (FEATURES.md §8.5).
class _ExerciseSummaryCard extends StatelessWidget {
  const _ExerciseSummaryCard({required this.sessionExercise});

  final SessionExercise sessionExercise;

  @override
  Widget build(BuildContext context) {
    final se = sessionExercise;
    final completedSets =
        se.sets.where((s) => s.isCompleted).toList(growable: false);
    final volume = se.totalVolumeKg;
    final volumeText = volume % 1 == 0
        ? volume.toInt().toString()
        : volume.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Row(
            children: [
              Expanded(
                child: Text(
                  se.exerciseName ?? 'Exercise',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$volumeText kg',
                style: AppTheme.num(13, weight: FontWeight.w700, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (completedSets.isEmpty)
            const Text(
              'No sets completed',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            )
          else ...[
            // Table header
            const Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text('SET',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5)),
                ),
                Expanded(
                  child: Text('KG',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5)),
                ),
                Expanded(
                  child: Text('REPS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5)),
                ),
                SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 4),
            ...completedSets.map(_buildSetRow),
          ],
        ],
      ),
    );
  }

  Widget _buildSetRow(WorkoutSet set) {
    final isWarmup = set.type == SetType.warmup;
    final textColor =
        isWarmup ? AppTheme.textSecondary : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: isWarmup
                ? Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppTheme.burntOrange.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppTheme.burntOrange.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      'W',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.burntOrange,
                      ),
                    ),
                  )
                : Text(
                    '${set.setNumber}',
                    textAlign: TextAlign.center,
                    style: AppTheme.num(12, weight: FontWeight.w600, color: textColor),
                  ),
          ),
          Expanded(
            child: Text(
              WorkoutSummaryScreen._formatWeight(set.weightKg),
              textAlign: TextAlign.center,
              style: AppTheme.num(13, weight: FontWeight.w600, color: textColor),
            ),
          ),
          Expanded(
            child: Text(
              '${set.reps}',
              textAlign: TextAlign.center,
              style: AppTheme.num(13, weight: FontWeight.w600, color: textColor),
            ),
          ),
          SizedBox(
            width: 40,
            child: set.isPr
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppTheme.voltGreen.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppTheme.voltGreen.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text(
                      'PR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.voltGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
