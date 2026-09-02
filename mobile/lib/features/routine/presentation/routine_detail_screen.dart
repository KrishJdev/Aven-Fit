import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
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
    final routineAsync = ref.watch(routineDetailControllerProvider(routineId));

    return routineAsync.when(
      data: (routine) {
        if (routine == null) {
          return _buildNotFoundScreen(context);
        }

        return Scaffold(
          backgroundColor: AppTheme.oledBlack,
          appBar: AppBar(
            backgroundColor: AppTheme.oledBlack,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft,
                  color: AppTheme.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'ROUTINE DETAIL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppTheme.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.pencil,
                    size: 18, color: AppTheme.neonCyan),
                onPressed: () => context.push('/routines/$routineId/edit'),
              ),
              _buildOptionsMenu(context, ref, routine),
              const SizedBox(width: 4),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(color: AppTheme.glassBorder, height: 1),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _buildHeader(routine),
                const SizedBox(height: 16),
                _buildSummaryBadges(routine),
                const SizedBox(height: 24),
                _buildExercisesSection(context, routine),
              ],
            ),
          ),
          bottomSheet: _buildStickyStartBar(context, ref, routine),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppTheme.oledBlack,
        body: Center(
          child: SingleChildScrollView(
            child: LoadingStateWidget(),
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppTheme.oledBlack,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
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
            const SizedBox(height: 8),
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

  Widget _buildSummaryBadges(Routine routine) {
    return Row(
      children: [
        Expanded(
          child: _buildBadgeCard(
            label: 'EXERCISES',
            value: '${routine.exerciseCount}',
            color: AppTheme.neonCyan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBadgeCard(
            label: 'TOTAL SETS',
            value: '${routine.totalSets}',
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBadgeCard(
            label: 'EST. DURATION',
            value: '${routine.estimatedDurationMinutes} MIN',
            color: AppTheme.voltGreen,
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.glassBorder),
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
          const SizedBox(height: 4),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLANNED EXERCISES (${routine.exercises.length})',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (routine.exercises.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.glassFill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: const Center(
              child: Text(
                'No exercises added to this routine yet.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
        exercise.exerciseName ?? exercise.exercise?.name ?? 'Exercise';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
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
                    color: AppTheme.neonCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: AppTheme.num(
                      12,
                      weight: FontWeight.w800,
                      color: AppTheme.neonCyan,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.glassFill,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.glassBorder),
                  ),
                  child: Text(
                    '${exercise.restSeconds}s rest',
                    style: AppTheme.num(
                      11,
                      color: AppTheme.voltGreen,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Sets Breakdown Table
            _buildSetsTable(exercise),
            if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF141416),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.glassBorder),
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

  Widget _buildSetsTable(RoutineExercise exercise) {
    final sets = exercise.sets;

    if (sets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
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
              _buildTableHeaderCell('SET', flex: 1),
              _buildTableHeaderCell('TARGET WEIGHT', flex: 2),
              _buildTableHeaderCell('TARGET REPS', flex: 2),
              _buildTableHeaderCell('TARGET RPE', flex: 2),
            ],
          ),
        ),
        const Divider(color: AppTheme.glassBorder, height: 1),
        const SizedBox(height: 6),
        // Table Rows
        ...sets.map((s) {
          final weightStr = (s.targetWeightKg != null && s.targetWeightKg! > 0)
              ? '${s.targetWeightKg!.toStringAsFixed(s.targetWeightKg!.truncateToDouble() == s.targetWeightKg ? 0 : 1)} kg'
              : '-';
          final repsStr = s.targetReps != null ? '${s.targetReps}' : '-';
          final rpeStr = s.targetRpe != null ? '${s.targetRpe}' : '-';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
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
                          ? AppTheme.neonCyan
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
                          ? AppTheme.voltGreen
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
    return PopupMenuButton<String>(
      icon: const Icon(
        LucideIcons.ellipsisVertical,
        color: AppTheme.textSecondary,
        size: 18,
      ),
      color: const Color(0xFF141416),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppTheme.glassBorder),
      ),
      onSelected: (action) async {
        if (action == 'duplicate') {
          final controller =
              ref.read(routineDetailControllerProvider(routine.id).notifier);
          final cloned = await controller.duplicateRoutine();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Duplicated "${routine.name}"'),
                backgroundColor: const Color(0xFF1F1F24),
              ),
            );
            context.push('/routines/${cloned.id}');
          }
        } else if (action == 'delete') {
          _confirmDelete(context, ref, routine);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(LucideIcons.copy, size: 16, color: AppTheme.textPrimary),
              SizedBox(width: 10),
              Text('Duplicate',
                  style: TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(LucideIcons.trash2, size: 16, color: AppTheme.burntOrange),
              SizedBox(width: 10),
              Text('Delete Routine',
                  style: TextStyle(color: AppTheme.burntOrange)),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141416),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppTheme.glassBorder),
        ),
        title: const Text(
          'Delete Routine?',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${routine.name}"? Historical workouts logged from this routine will remain intact.',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.burntOrange,
              foregroundColor: AppTheme.textPrimary,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(routineDetailControllerProvider(routine.id).notifier)
                  .deleteRoutine();
              if (context.mounted) {
                context.pop();
              }
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyStartBar(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
  ) {
    return Container(
      color: const Color(0xFF101012),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
              backgroundColor: AppTheme.neonCyan,
              foregroundColor: AppTheme.oledBlack,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: const Icon(LucideIcons.play, size: 18),
            label: const Text(
              'START WORKOUT',
              style: TextStyle(
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
    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.fileQuestion,
                size: 48,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Routine Not Found',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This routine may have been deleted.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonCyan,
                  foregroundColor: AppTheme.oledBlack,
                ),
                child: const Text('BACK TO ROUTINES'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
