import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/workout_set.dart';
import 'active_workout_controller.dart';
import 'active_workout_state.dart';

/// Declarative Active Workout Screen built with Sharp Glassmorphism design tokens.
///
/// Observes [activeWorkoutControllerProvider] and dispatches unidirectional actions.
class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(activeWorkoutControllerProvider);
    final controller = ref.read(activeWorkoutControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        title: Text(
          'ACTIVE WORKOUT',
          style: AppTheme.num(18, weight: FontWeight.w700, color: AppTheme.neonCyan),
        ),
        actions: [
          stateAsync.whenOrNull(
                data: (state) => state.hasActiveSession
                    ? TextButton(
                        onPressed: () => _confirmFinishWorkout(context, controller),
                        child: Text(
                          'FINISH',
                          style: AppTheme.num(
                            14,
                            weight: FontWeight.w700,
                            color: AppTheme.voltGreen,
                          ),
                        ),
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.neonCyan),
        ),
        error: (err, stack) => _buildErrorState(err, controller),
        data: (state) {
          if (!state.hasActiveSession) {
            return _buildEmptyState(context, controller);
          }
          return _buildActiveWorkoutView(context, state, controller);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ActiveWorkoutController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.dumbbell, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'NO ACTIVE WORKOUT',
              style: AppTheme.num(20, weight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start a quick session or pick a routine from your library.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => controller.startWorkout(name: 'Quick Workout'),
              icon: const Icon(LucideIcons.play, size: 18),
              label: const Text('START EMPTY WORKOUT'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.neonCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, ActiveWorkoutController controller) {
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
              onPressed: () => controller.startWorkout(),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWorkoutView(
    BuildContext context,
    ActiveWorkoutState state,
    ActiveWorkoutController controller,
  ) {
    return Column(
      children: [
        // Summary & Rest timer bar
        if (state.isRestTimerRunning)
          _buildRestTimerBar(state, controller),

        // Workout stats header
        _buildStatsHeader(state),

        // Exercise and sets list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildExerciseCard(
                exerciseName: 'Barbell Bench Press',
                exerciseId: 'ex_bench_press',
                sets: state.sets.where((s) => s.exerciseId == 'ex_bench_press').toList(),
                controller: controller,
              ),
              const SizedBox(height: 16),
              _buildExerciseCard(
                exerciseName: 'Incline Dumbbell Press',
                exerciseId: 'ex_incline_db_press',
                sets: state.sets.where((s) => s.exerciseId == 'ex_incline_db_press').toList(),
                controller: controller,
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => _confirmCancelWorkout(context, controller),
                icon: const Icon(LucideIcons.trash2, size: 16, color: AppTheme.burntOrange),
                label: const Text(
                  'CANCEL WORKOUT',
                  style: TextStyle(color: AppTheme.burntOrange, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.burntOrange),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestTimerBar(ActiveWorkoutState state, ActiveWorkoutController controller) {
    final remaining = state.restTimerRemainingSeconds;
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      color: const Color(0xFF13222B),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(LucideIcons.timer, size: 20, color: AppTheme.neonCyan),
          const SizedBox(width: 8),
          Text(
            'REST TIMER:',
            style: AppTheme.num(13, weight: FontWeight.w600, color: AppTheme.neonCyan),
          ),
          const SizedBox(width: 6),
          Text(
            '$minutes:$seconds',
            style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => controller.addRestTime(15),
            child: Text(
              '+15s',
              style: AppTheme.num(13, weight: FontWeight.w700, color: AppTheme.neonCyan),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 18, color: AppTheme.textSecondary),
            onPressed: controller.stopRestTimer,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(ActiveWorkoutState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('SETS', '${state.completedSetsCount} / ${state.sets.length}'),
          _buildStatColumn('VOLUME', '${state.totalVolumeKg.toStringAsFixed(1)} kg'),
          _buildStatColumn('SESSION', state.session?.name ?? 'Workout'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.num(15, weight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildExerciseCard({
    required String exerciseName,
    required String exerciseId,
    required List<WorkoutSet> sets,
    required ActiveWorkoutController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exerciseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.ellipsis, size: 18, color: AppTheme.textSecondary),
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.glassBorder, height: 1),

          // Sets Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text('SET', style: _tableHeaderStyle),
                ),
                Expanded(
                  child: Text('PREV', style: _tableHeaderStyle, textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('KG', style: _tableHeaderStyle, textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('REPS', style: _tableHeaderStyle, textAlign: TextAlign.center),
                ),
                const SizedBox(width: 44, child: Text('✓', textAlign: TextAlign.center, style: _tableHeaderStyle)),
              ],
            ),
          ),

          // Set Rows
          if (sets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No sets logged yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ),
            )
          else
            ...sets.map((set) => _buildSetRow(set, controller)),

          // Add Set Action
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => controller.addSet(
                  exerciseId: exerciseId,
                  weightKg: sets.isNotEmpty ? sets.last.weightKg : 60.0,
                  reps: sets.isNotEmpty ? sets.last.reps : 10,
                ),
                icon: const Icon(LucideIcons.plus, size: 16, color: AppTheme.neonCyan),
                label: const Text(
                  'ADD SET',
                  style: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0x1A00F0FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(WorkoutSet set, ActiveWorkoutController controller) {
    final isDone = set.isCompleted;

    return Container(
      color: isDone ? const Color(0x14E2F835) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              set.setNumber.toString(),
              style: AppTheme.num(14, weight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              '—',
              textAlign: TextAlign.center,
              style: AppTheme.num(14, color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              set.weightKg.toStringAsFixed(1),
              textAlign: TextAlign.center,
              style: AppTheme.num(14, weight: FontWeight.w700, color: Colors.white),
            ),
          ),
          Expanded(
            child: Text(
              set.reps.toString(),
              textAlign: TextAlign.center,
              style: AppTheme.num(14, weight: FontWeight.w700, color: Colors.white),
            ),
          ),
          SizedBox(
            width: 44,
            child: Center(
              child: InkWell(
                onTap: () => controller.toggleSetCompleted(set.id),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone ? AppTheme.voltGreen : const Color(0xFF22262B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDone ? AppTheme.voltGreen : AppTheme.glassBorder,
                    ),
                  ),
                  child: Icon(
                    LucideIcons.check,
                    size: 18,
                    color: isDone ? Colors.black : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const TextStyle _tableHeaderStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppTheme.textSecondary,
    letterSpacing: 0.5,
  );

  void _confirmFinishWorkout(BuildContext context, ActiveWorkoutController controller) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.glassFill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'FINISH WORKOUT',
          style: AppTheme.num(18, weight: FontWeight.w700, color: Colors.white),
        ),
        content: const Text(
          'Are you ready to complete and save this workout session?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.finishWorkout();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.voltGreen, foregroundColor: Colors.black),
            child: const Text('FINISH & SAVE'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelWorkout(BuildContext context, ActiveWorkoutController controller) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.glassFill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'CANCEL WORKOUT',
          style: AppTheme.num(18, weight: FontWeight.w700, color: AppTheme.burntOrange),
        ),
        content: const Text(
          'Are you sure you want to discard this workout? All sets logged in this session will be removed.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('RESUME', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.cancelWorkout();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.burntOrange, foregroundColor: Colors.white),
            child: const Text('DISCARD'),
          ),
        ],
      ),
    );
  }
}
