import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/muscle_group.dart';
import 'exercise_detail_controller.dart';

/// Screen presenting complete exercise details, anatomical target breakdown, instructions,
/// performance history placeholder, and custom exercise management.
///
/// Implements Law L2 (100% offline view), Law L6 (designed fallback states), and Law L7 (confirmed deletion).
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(exerciseDetailControllerProvider(exerciseId));
    final controller =
        ref.read(exerciseDetailControllerProvider(exerciseId).notifier);

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'EXERCISE DETAIL',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          detailAsync.whenOrNull(
                data: (exercise) => exercise != null
                    ? IconButton(
                        icon: Icon(
                          exercise.isFavourite
                              ? LucideIcons.star
                              : LucideIcons.star,
                          color: exercise.isFavourite
                              ? AppTheme.voltGreen
                              : AppTheme.textSecondary,
                        ),
                        onPressed: controller.toggleFavourite,
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: detailAsync.when(
        data: (exercise) {
          if (exercise == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.searchX,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Exercise not found',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.neonCyan),
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const Text(
                      'BACK TO DIRECTORY',
                      style: TextStyle(color: AppTheme.neonCyan),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Name
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Tags / Badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (exercise.primaryMuscle != null)
                      _DetailBadge(
                        label: exercise.primaryMuscle!,
                        color: AppTheme.neonCyan,
                      ),
                    if (exercise.equipment != Equipment.none)
                      _DetailBadge(
                        label: exercise.equipment.name.toUpperCase(),
                        color: AppTheme.textSecondary,
                      ),
                    _DetailBadge(
                      label: exercise.category.name.toUpperCase(),
                      color: AppTheme.textSecondary,
                    ),
                    if (exercise.isCustom)
                      const _DetailBadge(
                        label: 'CUSTOM',
                        color: AppTheme.voltGreen,
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Instructions Card
                _GlassCard(
                  title: 'INSTRUCTIONS & FORM NOTES',
                  icon: LucideIcons.bookOpen,
                  child: Text(
                    exercise.instructions != null &&
                            exercise.instructions!.isNotEmpty
                        ? exercise.instructions!
                        : 'No form instructions recorded for this exercise.',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Target Muscles Card
                _GlassCard(
                  title: 'TARGET ANATOMY',
                  icon: LucideIcons.layers,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (exercise.primaryMuscle != null) ...[
                        Row(
                          children: [
                            const Text(
                              'Primary Driver:',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              exercise.primaryMuscle!,
                              style: const TextStyle(
                                color: AppTheme.neonCyan,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (exercise.secondaryMuscles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Secondary / Synergists:',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                exercise.secondaryMuscles.join(', '),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Performance History Placeholder
                _GlassCard(
                  title: 'PERFORMANCE HISTORY & PRs',
                  icon: LucideIcons.trendingUp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No logged sets for this exercise yet.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Past weights, reps, estimated 1RM trends, and ghost suggestions will populate here automatically after logging sets in workout sessions.',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.7),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete custom exercise button (if applicable)
                if (exercise.isCustom) ...[
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        LucideIcons.trash2,
                        size: 16,
                        color: AppTheme.burntOrange,
                      ),
                      label: const Text(
                        'DELETE CUSTOM EXERCISE',
                        style: TextStyle(
                          color: AppTheme.burntOrange,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.burntOrange),
                        shape: const RoundedRectangleBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _confirmDelete(context, controller),
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.neonCyan,
            strokeWidth: 2,
          ),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: AppTheme.burntOrange),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ExerciseDetailController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.oledBlack,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppTheme.glassBorder),
        ),
        title: const Text(
          'Delete Exercise?',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'This will permanently delete this custom exercise. Previously logged workout sessions and historical records will remain intact.',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.burntOrange),
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'DELETE',
              style: TextStyle(
                color: AppTheme.burntOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.deleteExercise();
      if (success && context.mounted) {
        context.pop();
      }
    }
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        border: Border.all(color: AppTheme.glassBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.neonCyan),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
