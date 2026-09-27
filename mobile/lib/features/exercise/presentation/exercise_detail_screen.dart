import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_state_widget.dart';
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
    final l10n = l10nOf(context);
    final detailAsync = ref.watch(exerciseDetailControllerProvider(exerciseId));
    final controller =
        ref.read(exerciseDetailControllerProvider(exerciseId).notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.exerciseDetailTitle,
          style: const TextStyle(
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
                              ? AppTheme.secondary
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
                  const SizedBox(height: AppTheme.spaceLg),
                  Text(
                    l10n.exerciseNotFound,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primary),
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: Text(
                      l10n.backToDirectory,
                      style: const TextStyle(color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceMd),
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
                        color: AppTheme.primary,
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
                      _DetailBadge(
                        label: l10n.customBadge,
                        color: AppTheme.secondary,
                      ),
                  ],
                ),

                const SizedBox(height: AppTheme.spaceXxl),

                // Instructions Card
                _GlassCard(
                  title: l10n.instructionsCardTitle,
                  icon: LucideIcons.bookOpen,
                  child: Text(
                    exercise.instructions != null &&
                            exercise.instructions!.isNotEmpty
                        ? exercise.instructions!
                        : l10n.noInstructionsRecorded,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spaceLg),

                // Target Muscles Card
                _GlassCard(
                  title: l10n.targetAnatomyTitle,
                  icon: LucideIcons.layers,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (exercise.primaryMuscle != null) ...[
                        Row(
                          children: [
                            Text(
                              l10n.primaryDriverLabel,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spaceSm),
                            Text(
                              exercise.primaryMuscle!,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (exercise.secondaryMuscles.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spaceSm),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.secondarySynergistsLabel,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spaceSm),
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

                const SizedBox(height: AppTheme.spaceLg),

                // Performance History Placeholder
                _GlassCard(
                  title: l10n.performanceHistoryTitle,
                  icon: LucideIcons.trendingUp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.noLoggedSetsYet,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.performanceHistoryHint,
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
                        color: AppTheme.warning,
                      ),
                      label: Text(
                        l10n.deleteCustomExercise,
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.warning),
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
          child: SingleChildScrollView(
            child: LoadingStateWidget(),
          ),
        ),
        error: (err, _) => ErrorStateWidget(
          error: err,
          onRetry: () =>
              ref.invalidate(exerciseDetailControllerProvider(exerciseId)),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ExerciseDetailController controller,
  ) async {
    final l10n = l10nOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: l10n.deleteExerciseTitle,
        message: l10n.deleteExerciseMessage,
        confirmLabel: l10n.deleteExerciseConfirm,
        cancelLabel: l10n.dialogCancel,
        style: ConfirmStyle.destructive,
        onConfirm: () {},
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
        color: AppTheme.surface,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primary),
              const SizedBox(width: AppTheme.spaceSm),
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
          const SizedBox(height: AppTheme.spaceMd),
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
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm, vertical: AppTheme.spaceXs),
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
