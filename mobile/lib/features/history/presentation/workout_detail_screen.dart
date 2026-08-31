import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../workout/domain/session_exercise.dart';
import '../../workout/domain/workout_session.dart';
import '../../workout/domain/workout_set.dart';
import '../../workout/presentation/widgets/session_conflict_dialog.dart';
import 'workout_detail_controller.dart';

/// Read-only view of a past workout (WU-3.9, FEATURES.md §8.7): same layout
/// as the Workout Summary minus celebrations, plus Repeat / Save-as-routine /
/// Rename / Delete actions. All states are designed (L6) and every action
/// runs offline from SQLite (L2/L7).
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(workoutDetailControllerProvider(sessionId));
    final controller =
        ref.read(workoutDetailControllerProvider(sessionId).notifier);

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 22),
          onPressed: () => context.pop(),
        ),
        title: sessionAsync.whenOrNull(
              data: (session) => session == null
                  ? Text(
                      'WORKOUT',
                      style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
                    )
                  : GestureDetector(
                      onTap: () => _renameDialog(context, controller, session.name),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              session.name,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(LucideIcons.pencil, size: 14, color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
            ) ??
            const SizedBox.shrink(),
        actions: [
          sessionAsync.whenOrNull(
                data: (session) => session == null
                    ? null
                    : PopupMenuButton<String>(
                        icon: const Icon(LucideIcons.ellipsisVertical,
                            color: AppTheme.textSecondary, size: 20),
                        color: const Color(0xFF1B1F24),
                        onSelected: (value) {
                          if (value == 'save_routine') {
                            _saveAsRoutineDialog(context, controller, session.name);
                          } else if (value == 'delete') {
                            _confirmDelete(context, controller);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'save_routine',
                            child: Row(
                              children: [
                                Icon(LucideIcons.bookmark, size: 16, color: AppTheme.neonCyan),
                                SizedBox(width: 8),
                                Text('Save as routine',
                                    style: TextStyle(color: Colors.white, fontSize: 13)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(LucideIcons.trash2, size: 16, color: AppTheme.burntOrange),
                                SizedBox(width: 8),
                                Text('Delete workout',
                                    style: TextStyle(color: AppTheme.burntOrange, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.neonCyan),
        ),
        error: (err, _) => _ErrorState(error: err, sessionId: sessionId),
        data: (session) {
          if (session == null) {
            return const _NotFoundState();
          }
          return _buildDetailView(context, ref, session, controller);
        },
      ),
      bottomNavigationBar: sessionAsync.whenOrNull(
        data: (session) => session == null
            ? null
            : _buildBottomBar(context, ref, controller),
      ),
    );
  }

  Widget _buildDetailView(
    BuildContext context,
    WidgetRef ref,
    WorkoutSession session,
    WorkoutDetailController controller,
  ) {
    final completedAt = session.completedAt ?? session.startedAt;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'COMPLETED · ${_formatDate(completedAt)}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _StatsGrid(session: session),
        const SizedBox(height: 16),
        if (session.exercises.isEmpty)
          const _NoExercisesNote()
        else
          ...session.exercises.map(
            (exercise) => _ExerciseBreakdownCard(exercise: exercise),
          ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    WorkoutDetailController controller,
  ) {
    return Container(
      color: AppTheme.oledBlack,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            key: const ValueKey('repeat_workout_button'),
            onPressed: () => _repeatWorkout(context, ref, controller),
            icon: const Icon(LucideIcons.rotateCcw, size: 18),
            label: const Text('REPEAT WORKOUT'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.voltGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _repeatWorkout(
    BuildContext context,
    WidgetRef ref,
    WorkoutDetailController controller,
  ) async {
    // One-session rule (§8.1): never silently discards the active session.
    final mayStart = await resolveOneSessionRule(context, ref);
    if (!mayStart || !context.mounted) return;

    final newSessionId = await controller.repeatWorkout();
    if (newSessionId != null && context.mounted) {
      context.push('/workout/active');
    }
  }

  void _renameDialog(
    BuildContext context,
    WorkoutDetailController controller,
    String currentName,
  ) {
    final textController = TextEditingController(text: currentName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16191D),
        title: Text('RENAME WORKOUT',
            style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white)),
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
              controller.renameWorkout(textController.text);
              Navigator.of(ctx).pop();
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

  void _saveAsRoutineDialog(
    BuildContext context,
    WorkoutDetailController controller,
    String defaultName,
  ) {
    final textController = TextEditingController(text: defaultName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16191D),
        title: Text('SAVE AS ROUTINE',
            style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Routine name...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final routineId = await controller.saveAsRoutine(textController.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      routineId != null
                          ? 'Saved to your routines'
                          : 'Could not save as routine',
                    ),
                    backgroundColor: const Color(0xFF1F1F24),
                  ),
                );
              }
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

  void _confirmDelete(
    BuildContext context,
    WorkoutDetailController controller,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16191D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'DELETE WORKOUT',
          style: AppTheme.num(16, weight: FontWeight.w700, color: AppTheme.burntOrange),
        ),
        content: const Text(
          'Delete this workout and all of its sets? This can\'t be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('KEEP', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await controller.deleteWorkout();
              if (context.mounted) {
                context.pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.burntOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} · $hour:$minute';
  }
}

/// 2×2 stats grid mirroring the Workout Summary (§8.7: same layout, no
/// celebration).
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final duration = _formatDuration(session.elapsedSecondsNow());
    final volume = session.totalVolumeKg % 1 == 0
        ? session.totalVolumeKg.toInt().toString()
        : session.totalVolumeKg.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatCell(label: 'DURATION', value: duration),
              _StatCell(label: 'WORKING VOLUME', value: '$volume kg', highlight: true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatCell(label: 'SETS', value: '${session.completedSetsCount}'),
              _StatCell(label: 'PRS', value: '${_prCount(session)}'),
            ],
          ),
        ],
      ),
    );
  }

  int _prCount(WorkoutSession session) =>
      session.sets.where((s) => s.isCompleted && s.isPr).length;

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

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: AppTheme.num(
            16,
            weight: FontWeight.w700,
            color: highlight ? AppTheme.voltGreen : Colors.white,
          ),
        ),
      ],
    );
  }
}

/// One card per exercise: every set as `weight × reps`, warm-ups W-badged,
/// PR sets chipped (volt green).
class _ExerciseBreakdownCard extends StatelessWidget {
  const _ExerciseBreakdownCard({required this.exercise});

  final SessionExercise exercise;

  @override
  Widget build(BuildContext context) {
    final sets = exercise.sets;

    return Container(
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
            exercise.exerciseName ?? 'Exercise',
            style: AppTheme.num(14, weight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          if (sets.isEmpty)
            const Text(
              'No sets logged',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            )
          else
            ...sets.map((set) => _SetRow(set: set)),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.set});

  final WorkoutSet set;

  @override
  Widget build(BuildContext context) {
    final weight = set.weightKg % 1 == 0
        ? set.weightKg.toInt().toString()
        : set.weightKg.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: set.type == SetType.warmup
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'W',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                    ),
                  )
                : Text(
                    '#${set.setNumber}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: set.isCompleted
                ? Text(
                    '$weight kg × ${set.reps}',
                    style: AppTheme.num(13, weight: FontWeight.w600, color: Colors.white),
                  )
                : Text(
                    '$weight kg × ${set.reps} (not completed)',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
          ),
          if (set.isPr)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.voltGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'PR',
                style: AppTheme.num(10, weight: FontWeight.w700, color: AppTheme.voltGreen),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoExercisesNote extends StatelessWidget {
  const _NoExercisesNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: const Text(
        'This workout had no logged exercises.',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      ),
    );
  }
}

/// Designed error state with a recovery path (L6).
class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.error, required this.sessionId});

  final Object error;
  final String sessionId;

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
              'COULD NOT LOAD WORKOUT',
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
              onPressed: () => ref.invalidate(
                workoutDetailControllerProvider(sessionId),
              ),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Workout-not-found state — a clear way back, never blank (L6).
class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.circleQuestionMark, size: 52, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'WORKOUT NOT FOUND',
              style: AppTheme.num(18, weight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'This workout may have been deleted.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('BACK TO HISTORY'),
            ),
          ],
        ),
      ),
    );
  }
}
