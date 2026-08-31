import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/ghost_set.dart';
import '../../domain/session_exercise.dart';
import '../../domain/workout_set.dart';
import '../active_workout_controller.dart';
import 'set_row_widget.dart';
import 'warmup_pyramid_sheet.dart';

/// Exercise card block displaying exercise title, muscle tags, options menu,
/// interactive set table with ghost values, and set creation actions.
///
/// Implements FEATURES.md §8.1 and Law L1 (<3s set logging).
class ExerciseBlockCard extends StatelessWidget {
  const ExerciseBlockCard({
    super.key,
    required this.sessionExercise,
    required this.sets,
    this.ghostSets = const [],
    required this.controller,
    this.onReplaceExercise,
  });

  final SessionExercise sessionExercise;
  final List<WorkoutSet> sets;
  final List<GhostSet> ghostSets;
  final ActiveWorkoutController controller;
  final VoidCallback? onReplaceExercise;

  @override
  Widget build(BuildContext context) {
    final exerciseName = sessionExercise.exerciseName ?? 'Exercise';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Block Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (sessionExercise.exercise?.primaryMuscle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.neonCyan.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              sessionExercise.exercise!.primaryMuscle!,
                              style: const TextStyle(
                                color: AppTheme.neonCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Warm-up pyramid quick action
                IconButton(
                  icon: const Icon(LucideIcons.flame, size: 18, color: AppTheme.burntOrange),
                  tooltip: 'Warm-up Pyramid',
                  onPressed: () => _openWarmupPyramidSheet(context),
                  visualDensity: VisualDensity.compact,
                ),
                // 3-dots options menu
                PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.ellipsisVertical, size: 18, color: AppTheme.textSecondary),
                  color: const Color(0xFF1B1F24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onSelected: (val) {
                    if (val == 'warmup') {
                      _openWarmupPyramidSheet(context);
                    } else if (val == 'remove') {
                      controller.removeExercise(sessionExercise.id);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'warmup',
                      child: Row(
                        children: [
                          Icon(LucideIcons.flame, size: 16, color: AppTheme.burntOrange),
                          SizedBox(width: 8),
                          Text('Warm-up Pyramid', style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(LucideIcons.trash2, size: 16, color: AppTheme.burntOrange),
                          SizedBox(width: 8),
                          Text('Remove Exercise', style: TextStyle(color: AppTheme.burntOrange, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
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
                const SizedBox(
                  width: 36,
                  child: Text('SET', style: _tableHeaderStyle),
                ),
                const Expanded(
                  flex: 3,
                  child: Text('PREV', style: _tableHeaderStyle, textAlign: TextAlign.center),
                ),
                const Expanded(
                  flex: 4,
                  child: Text('KG', style: _tableHeaderStyle, textAlign: TextAlign.center),
                ),
                const SizedBox(width: 4),
                const Expanded(
                  flex: 4,
                  child: Text('REPS', style: _tableHeaderStyle, textAlign: TextAlign.center),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 38,
                  child: Text('✓', textAlign: TextAlign.center, style: _tableHeaderStyle),
                ),
              ],
            ),
          ),

          // Set Rows List
          if (sets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No sets logged yet. Tap + ADD SET below.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            ...sets.asMap().entries.map((entry) {
              final idx = entry.key;
              final set = entry.value;
              final ghost = idx < ghostSets.length
                  ? ghostSets[idx]
                  : const GhostSet(source: GhostSource.none);

              return SetRowWidget(
                set: set,
                ghost: ghost,
                onUpdateSet: controller.updateSet,
                onToggleComplete: () => controller.toggleSetCompleted(set.id),
                onDeleteSet: () => controller.deleteSet(set.id),
              );
            }),

          // Action Footer (+ ADD SET button)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextButton.icon(
                      onPressed: () {
                        final lastSet = sets.isNotEmpty ? sets.last : null;
                        final defaultWeight = lastSet?.weightKg ?? 60.0;
                        final defaultReps = lastSet?.reps ?? 10;
                        controller.addSet(
                          sessionExerciseId: sessionExercise.id,
                          exerciseId: sessionExercise.exerciseId,
                          weightKg: defaultWeight > 0 ? defaultWeight : 60.0,
                          reps: defaultReps > 0 ? defaultReps : 10,
                        );
                      },
                      icon: const Icon(LucideIcons.plus, size: 16, color: AppTheme.neonCyan),
                      label: const Text(
                        'ADD SET',
                        style: TextStyle(
                          color: AppTheme.neonCyan,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.neonCyan.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openWarmupPyramidSheet(BuildContext context) {
    final workingWeight = sets.isNotEmpty ? sets.last.weightKg : 80.0;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.oledBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => WarmupPyramidSheet(
        workingWeightKg: workingWeight,
        onGenerate: (weight) {
          controller.generateWarmupPyramid(
            sessionExerciseId: sessionExercise.id,
            exerciseId: sessionExercise.exerciseId,
            workingWeightKg: weight,
          );
        },
      ),
    );
  }

  static const TextStyle _tableHeaderStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppTheme.textSecondary,
    letterSpacing: 0.5,
  );
}
