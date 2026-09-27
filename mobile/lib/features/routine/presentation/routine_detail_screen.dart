import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../domain/routine.dart';
import '../domain/routine_exercise.dart';
import 'routine_detail_controller.dart';
import '../../workout/presentation/widgets/session_conflict_dialog.dart';

/// Screen displaying a detailed read-only view of a routine with its planned
/// sets breakdown, notes, and instant "START WORKOUT" action.
///
/// Implements Law L1 (<1s startup), Law L2 (offline instant render),
/// and Law L7 (leaves routine unmutated on session start).
class RoutineDetailScreen extends ConsumerWidget {
  const RoutineDetailScreen({
    super.key,
    required this.routineId,
  });

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
    final routineAsync = ref.watch(routineDetailControllerProvider(routineId));

    return routineAsync.when(
      data: (routine) {
        if (routine == null) {
          return _buildNotFoundScreen(context);
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft,
                  color: AppTheme.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              l10n.routineDetailTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppTheme.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.pencil,
                    size: 18, color: AppTheme.primary),
                onPressed: () => context.push('/routines/$routineId/edit'),
              ),
              _buildOptionsMenu(context, ref, routine),
              const SizedBox(width: AppTheme.spaceXs),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(color: AppTheme.border, height: 1),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, AppTheme.spaceLg, AppTheme.spaceLg, 100),
              children: [
                _buildHeader(routine),
                const SizedBox(height: AppTheme.spaceLg),
                _buildSummaryBadges(context, routine),
                const SizedBox(height: AppTheme.spaceXxl),
                _buildExercisesSection(context, routine),
              ],
            ),
          ),
          bottomSheet: _buildStickyStartBar(context, ref, routine),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: SingleChildScrollView(
            child: LoadingStateWidget(),
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppTheme.background,
        body: ErrorStateWidget(
          error: err,
          onRetry: () =>
              ref.invalidate(routineDetailControllerProvider(routineId)),
        ),
      ),
    );
  }

  Widget _buildHeader(Routine routine) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            routine.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              color: AppTheme.textPrimary,
            ),
          ),
          if (routine.description != null &&
              routine.description!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              routine.description!,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryBadges(BuildContext context, Routine routine) {
    final l10n = l10nOf(context);
    return Row(
      children: [
        Expanded(
          child: _buildBadgeCard(
            label: l10n.statExercises,
            value: '${routine.exerciseCount}',
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBadgeCard(
            label: l10n.totalSetsLabel,
            value: '${routine.totalSets}',
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBadgeCard(
            label: l10n.estDurationLabel,
            value: '${routine.estimatedDurationMinutes} MIN',
            color: AppTheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd, horizontal: AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            value,
            style: AppTheme.num(
              15,
              weight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesSection(BuildContext context, Routine routine) {
    final l10n = l10nOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.plannedExercisesLabel} (${routine.exercises.length})',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        if (routine.exercises.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceXxl),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Center(
              child: Text(
                l10n.noExercisesInRoutine,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
          )
        else
          ...routine.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final ex = entry.value;
            return _buildExerciseDetailCard(context, index, ex);
          }),
      ],
    );
  }

  Widget _buildExerciseDetailCard(
    BuildContext context,
    int index,
    RoutineExercise exercise,
  ) {
    final exName =
        exercise.exerciseName ?? exercise.exercise?.name ?? l10nOf(context).exerciseFallbackName;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: AppTheme.num(
                      12,
                      weight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Text(
                    exName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    '${exercise.restSeconds}s rest',
                    style: AppTheme.num(
                      11,
                      color: AppTheme.secondary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            // Sets Breakdown Table
            _buildSetsTable(context, exercise),
            if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.messageSquare,
                      size: 12,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        exercise.notes!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSetsTable(BuildContext context, RoutineExercise exercise) {
    final l10n = l10nOf(context);
    final sets = exercise.sets;

    if (sets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXs),
        child: Text(
          'Target: ${exercise.targetSummary}',
          style: AppTheme.num(13, color: AppTheme.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        // Table Header
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              _buildTableHeaderCell(l10n.setColumn, flex: 1),
              _buildTableHeaderCell(l10n.targetWeightColumn, flex: 2),
              _buildTableHeaderCell(l10n.targetRepsColumn, flex: 2),
              _buildTableHeaderCell(l10n.targetRpeColumn, flex: 2),
            ],
          ),
        ),
        const Divider(color: AppTheme.border, height: 1),
        const SizedBox(height: 6),
        // Table Rows
        ...sets.map((s) {
          final weightStr = (s.targetWeightKg != null && s.targetWeightKg! > 0)
              ? '${s.targetWeightKg!.toStringAsFixed(s.targetWeightKg!.truncateToDouble() == s.targetWeightKg ? 0 : 1)} kg'
              : '-';
          final repsStr = s.targetReps != null ? '${s.targetReps}' : '-';
          final rpeStr = s.targetRpe != null ? '${s.targetRpe}' : '-';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXs),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '${s.position}',
                    style: AppTheme.num(
                      12,
                      weight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    weightStr,
                    style: AppTheme.num(
                      12,
                      color: s.targetWeightKg != null && s.targetWeightKg! > 0
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    repsStr,
                    style: AppTheme.num(12, color: AppTheme.textPrimary),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    rpeStr,
                    style: AppTheme.num(
                      12,
                      color: s.targetRpe != null
                          ? AppTheme.secondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTableHeaderCell(String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
  ) {
    final l10n = l10nOf(context);
    return PopupMenuButton<String>(
      icon: const Icon(
        LucideIcons.ellipsisVertical,
        color: AppTheme.textSecondary,
        size: 18,
      ),
      color: AppTheme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppTheme.border),
      ),
      onSelected: (action) async {
        if (action == 'duplicate') {
          final controller =
              ref.read(routineDetailControllerProvider(routine.id).notifier);
          final cloned = await controller.duplicateRoutine();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.routineDuplicated(routine.name)),
                backgroundColor: AppTheme.surfaceElevated,
              ),
            );
            context.push('/routines/${cloned.id}');
          }
        } else if (action == 'delete') {
          _confirmDelete(context, ref, routine);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              const Icon(LucideIcons.copy, size: 16, color: AppTheme.textPrimary),
              const SizedBox(width: 10),
              Text(l10n.duplicateMenu,
                  style: const TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(LucideIcons.trash2, size: 16, color: AppTheme.warning),
              const SizedBox(width: 10),
              Text(l10n.deleteRoutineMenu,
                  style: const TextStyle(color: AppTheme.warning)),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
  ) {
    final l10n = l10nOf(context);
    showDialog(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: l10n.deleteRoutineTitle,
        message: l10n.deleteRoutineMessage(routine.name),
        confirmLabel: l10n.deleteWorkoutConfirm,
        cancelLabel: l10n.dialogCancel,
        style: ConfirmStyle.destructive,
        onConfirm: () async {
          await ref
              .read(routineDetailControllerProvider(routine.id).notifier)
              .deleteRoutine();
          if (context.mounted) {
            context.pop();
          }
        },
      ),
    );
  }

  Widget _buildStickyStartBar(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
  ) {
    final l10n = l10nOf(context);
    return Container(
      color: AppTheme.surfaceElevated,
      padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, AppTheme.spaceMd, AppTheme.spaceLg, AppTheme.spaceLg),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () async {
              // One-session rule (§8.1): never silently discards the
              // active session.
              final mayStart = await resolveOneSessionRule(context, ref);
              if (!mayStart || !context.mounted) return;

              final controller = ref.read(
                  routineDetailControllerProvider(routine.id).notifier);
              final session = await controller.startWorkout();
              if (session != null && context.mounted) {
                context.push('/workout/active');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.background,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: const Icon(LucideIcons.play, size: 18),
            label: Text(
              l10n.historyStartWorkout,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundScreen(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceXxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.fileQuestion,
                size: 48,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              Text(
                l10n.routineNotFoundTitle,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                l10n.routineNotFoundMessage,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: AppTheme.spaceXxl),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.background,
                ),
                child: Text(l10n.backToRoutines),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
