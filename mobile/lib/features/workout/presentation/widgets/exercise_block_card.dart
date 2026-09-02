import 'package:aven_fit/core/l10n/l10n.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../exercise/data/exercise_repository.dart';
import '../../../exercise/domain/exercise.dart';
import '../../data/workout_repository.dart';
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
    final l10n = l10nOf(context);
    final exerciseName = sessionExercise.exerciseName ?? l10n.exerciseFallbackName;

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
                  child: InkWell(
                    key: ValueKey('block_header_info_${sessionExercise.id}'),
                    onTap: () => _showQuickInfoSheet(context),
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
                ),
                // Warm-up pyramid quick action
                IconButton(
                  icon: const Icon(LucideIcons.flame, size: 18, color: AppTheme.burntOrange),
                  tooltip: l10n.warmupPyramidTooltip,
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
                    PopupMenuItem(
                      value: 'warmup',
                      child: Row(
                        children: [
                          const Icon(LucideIcons.flame, size: 16, color: AppTheme.burntOrange),
                          const SizedBox(width: 8),
                          Text(l10n.warmupPyramidMenu, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          const Icon(LucideIcons.trash2, size: 16, color: AppTheme.burntOrange),
                          const SizedBox(width: 8),
                          Text(l10n.removeExerciseMenu, style: const TextStyle(color: AppTheme.burntOrange, fontSize: 13)),
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
                SizedBox(
                  width: 36,
                  child: Text(l10n.setColumn, style: _tableHeaderStyle),
                ),
                Expanded(
                  flex: 3,
                  child: Text(l10n.prevColumn, style: _tableHeaderStyle, textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 4,
                  child: Text(l10n.kgColumn, style: _tableHeaderStyle, textAlign: TextAlign.center),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 4,
                  child: Text(l10n.repsColumn, style: _tableHeaderStyle, textAlign: TextAlign.center),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 38,
                  child: Text('✓', textAlign: TextAlign.center, style: _tableHeaderStyle),
                ),
              ],
            ),
          ),

          // Set Rows List
          if (sets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  l10n.noSetsLogged,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
                      label: Text(
                        l10n.addSet,
                        style: const TextStyle(
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

  /// §8.1 quick-info sheet: the exercise's muscles and its last completed
  /// performance ("Last: 4 sets · best 62.5 kg × 8") — both read offline
  /// from SQLite at open time (L2/L7).
  void _showQuickInfoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.oledBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final exerciseFuture = ref
              .read(exerciseRepositoryProvider)
              .getExerciseById(sessionExercise.exerciseId);
          final lastSetsFuture = ref
              .read(workoutRepositoryProvider)
              .getLastCompletedSetsForExercise(sessionExercise.exerciseId);

          return FutureBuilder<List<Object?>>(
            future: Future.wait<Object?>([exerciseFuture, lastSetsFuture]),
            builder: (context, snapshot) {
              final exercise =
                  snapshot.data?[0] as Exercise?; // ignore: cast_nullable_to_non_nullable
              final lastSets =
                  (snapshot.data?[1] as List<WorkoutSet>?) ?? const [];

              final muscleParts = <String>[
                if (exercise?.primaryMuscle != null)
                  'Primary: ${exercise!.primaryMuscle}',
                if (exercise != null && exercise.secondaryMuscles.isNotEmpty)
                  'Also: ${exercise.secondaryMuscles.join(', ')}',
              ];
              final muscleText =
                  muscleParts.isEmpty ? '—' : muscleParts.join(' · ');

              final completed =
                  lastSets.where((s) => s.isCompleted).toList(growable: false);
              String lastPerformance;
              if (completed.isEmpty) {
                lastPerformance = l10nOf(context).quickInfoNoHistory;
              } else {
                final best = completed.reduce(
                  (a, b) => a.weightKg >= b.weightKg ? a : b,
                );
                final bestWeight = best.weightKg % 1 == 0
                    ? best.weightKg.toInt().toString()
                    : best.weightKg.toStringAsFixed(1);
                lastPerformance =
                    'Last: ${completed.length} set${completed.length == 1 ? '' : 's'}'
                    ' · best $bestWeight kg × ${best.reps}';
              }

              return Padding(
                key: const ValueKey('block_info_sheet'),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sessionExercise.exerciseName ?? 'Exercise',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10nOf(context).quickInfoMuscles,
                      style: AppTheme.num(
                        10,
                        weight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      muscleText,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10nOf(context).quickInfoLastPerformance,
                      style: AppTheme.num(
                        10,
                        weight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      key: const ValueKey('quick_info_last_performance'),
                      lastPerformance,
                      style: AppTheme.num(
                        13.5,
                        weight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
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
