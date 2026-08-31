import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../exercise/domain/exercise.dart';
import '../data/ghost_prefill_service.dart';
import '../domain/ghost_set.dart';
import 'active_workout_controller.dart';
import 'active_workout_state.dart';
import 'exercise_picker_screen.dart';
import 'widgets/exercise_block_card.dart';

/// Complete rebuild of the Active Workout Screen.
///
/// Implements FEATURES.md §8.1, Law L1 (<3s set logging), Law L2 (100% offline),
/// and Law L7 (instant write-through persistence).
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
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronDown, color: Colors.white, size: 22),
          onPressed: () => context.pop(),
        ),
        title: stateAsync.whenOrNull(
              data: (state) => state.hasActiveSession
                  ? GestureDetector(
                      onTap: () => _editSessionNameDialog(
                        context,
                        currentName: state.session?.name ?? 'Workout',
                        onSubmitted: controller.updateWorkoutName,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              state.session?.name ?? 'ACTIVE WORKOUT',
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(LucideIcons.pencil, size: 14, color: AppTheme.textSecondary),
                        ],
                      ),
                    )
                  : Text(
                      'ACTIVE WORKOUT',
                      style: AppTheme.num(18, weight: FontWeight.w700, color: AppTheme.neonCyan),
                    ),
            ) ??
            const SizedBox.shrink(),
        actions: [
          stateAsync.whenOrNull(
                data: (state) => state.hasActiveSession
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _confirmFinishWorkout(context, controller),
                            child: Text(
                              'FINISH',
                              style: AppTheme.num(
                                14,
                                weight: FontWeight.w700,
                                color: AppTheme.voltGreen,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(LucideIcons.ellipsisVertical, color: AppTheme.textSecondary, size: 20),
                            color: const Color(0xFF1B1F24),
                            onSelected: (val) {
                              if (val == 'cancel') {
                                _confirmCancelWorkout(context, controller);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'cancel',
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.trash2, size: 16, color: AppTheme.burntOrange),
                                    SizedBox(width: 8),
                                    Text('Discard Workout', style: TextStyle(color: AppTheme.burntOrange, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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
          return _buildActiveWorkoutView(context, ref, state, controller);
        },
      ),
      bottomNavigationBar: stateAsync.whenOrNull(
        data: (state) => state.hasActiveSession
            ? _buildBottomStickyBar(context, ref, state, controller)
            : null,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ActiveWorkoutController controller) {
    final defaultName = ActiveWorkoutController.generateDefaultWorkoutName();

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
              onPressed: () => controller.startWorkout(name: defaultName),
              icon: const Icon(LucideIcons.play, size: 18),
              label: const Text('START EMPTY WORKOUT'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.neonCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    WidgetRef ref,
    ActiveWorkoutState state,
    ActiveWorkoutController controller,
  ) {
    final exercises = state.exercises;

    return Column(
      children: [
        // Live Rest Timer Bar (if running)
        if (state.isRestTimerRunning)
          _buildRestTimerBar(state, controller),

        // Session Stats Summary Header
        _buildStatsHeader(state),

        // Exercise Blocks List
        Expanded(
          child: exercises.isEmpty
              ? _buildNoExercisesPlaceholder(context, ref, controller)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final se = exercises[index];
                    final sets = state.sets.where((s) => s.sessionExerciseId == se.id).toList();

                    return FutureBuilder<List<GhostSet>>(
                      future: ref.read(ghostPrefillServiceProvider).resolveGhostSetsForExercise(
                            exerciseId: se.exerciseId,
                            totalSetsCount: sets.isNotEmpty ? sets.length : 1,
                            activeSessionSets: sets,
                          ),
                      builder: (context, snapshot) {
                        final ghosts = snapshot.data ?? const [];
                        return ExerciseBlockCard(
                          sessionExercise: se,
                          sets: sets,
                          ghostSets: ghosts,
                          controller: controller,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoExercisesPlaceholder(
    BuildContext context,
    WidgetRef ref,
    ActiveWorkoutController controller,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.plusCircle, size: 52, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'ADD YOUR FIRST EXERCISE',
              style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Search from 55+ built-in exercises or create your own custom exercise.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _openExercisePicker(context, controller),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('ADD EXERCISE'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.neonCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(ActiveWorkoutState state) {
    final completedSets = state.completedSetsCount;
    final totalSets = state.sets.length;
    final volume = state.totalVolumeKg % 1 == 0
        ? state.totalVolumeKg.toInt().toString()
        : state.totalVolumeKg.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('SETS', '$completedSets / $totalSets'),
          _buildStatColumn('WORKING VOLUME', '$volume kg', isHighlight: true),
          _buildStatColumn('EXERCISES', '${state.exercises.length}'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {bool isHighlight = false}) {
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
            14,
            weight: FontWeight.w700,
            color: isHighlight ? AppTheme.voltGreen : Colors.white,
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
      color: const Color(0xFF11222C),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(LucideIcons.timer, size: 18, color: AppTheme.neonCyan),
          const SizedBox(width: 8),
          Text(
            'REST TIMER:',
            style: AppTheme.num(12, weight: FontWeight.w600, color: AppTheme.neonCyan),
          ),
          const SizedBox(width: 6),
          Text(
            '$minutes:$seconds',
            style: AppTheme.num(15, weight: FontWeight.w700, color: Colors.white),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => controller.addRestTime(15),
            child: Text(
              '+15s',
              style: AppTheme.num(12, weight: FontWeight.w700, color: AppTheme.neonCyan),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 16, color: AppTheme.textSecondary),
            onPressed: controller.stopRestTimer,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStickyBar(
    BuildContext context,
    WidgetRef ref,
    ActiveWorkoutState state,
    ActiveWorkoutController controller,
  ) {
    return Container(
      color: AppTheme.oledBlack,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _openExercisePicker(context, controller),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('ADD EXERCISE'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.neonCyan,
                    side: const BorderSide(color: AppTheme.neonCyan),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: () => _confirmFinishWorkout(context, controller),
                  icon: const Icon(LucideIcons.check, size: 18),
                  label: const Text('FINISH'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.voltGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openExercisePicker(BuildContext context, ActiveWorkoutController controller) {
    Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (ctx) => ExercisePickerScreen(
          onExerciseSelected: (exercise) {
            controller.addExercise(exercise.id);
          },
        ),
      ),
    );
  }

  void _editSessionNameDialog(
    BuildContext context, {
    required String currentName,
    required ValueChanged<String> onSubmitted,
  }) {
    final textController = TextEditingController(text: currentName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16191D),
        title: Text('RENAME WORKOUT', style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white)),
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
              if (textController.text.trim().isNotEmpty) {
                onSubmitted(textController.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.neonCyan, foregroundColor: Colors.black),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _confirmFinishWorkout(BuildContext context, ActiveWorkoutController controller) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16191D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            child: const Text('RESUME', style: TextStyle(color: AppTheme.textSecondary)),
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
        backgroundColor: const Color(0xFF16191D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'DISCARD WORKOUT',
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
