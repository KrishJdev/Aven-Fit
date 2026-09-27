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
import 'routine_list_controller.dart';
import '../../workout/presentation/widgets/session_conflict_dialog.dart';

/// Screen displaying the user's workout routines, splits, and starter templates.
///
/// Complies with Law L2 (offline instant render), Law L3 (unlimited routines),
/// Law L6 (designed empty states), and Law L7 (write-through duplication & safe deletion).
class RoutineListScreen extends ConsumerStatefulWidget {
  const RoutineListScreen({super.key});

  @override
  ConsumerState<RoutineListScreen> createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends ConsumerState<RoutineListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final routinesAsync = ref.watch(routineListControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: routinesAsync.when(
                data: (routines) {
                  final filtered = _searchQuery.isEmpty
                      ? routines
                      : routines.where((r) {
                          final nameMatch = r.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());
                          final descMatch = (r.description ?? '')
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());
                          return nameMatch || descMatch;
                        }).toList();

                  if (routines.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  if (filtered.isEmpty) {
                    return _buildNoSearchResults(context);
                  }

                  return _buildRoutinesList(context, filtered);
                },
                loading: () => const Center(
                  child: SingleChildScrollView(
                    child: LoadingStateWidget(),
                  ),
                ),
                error: (err, stack) => ErrorStateWidget(
                  error: err,
                  onRetry: () =>
                      ref.invalidate(routineListControllerProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: Text(
          l10n.newRoutine,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        onPressed: () => context.push('/routines/new'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = l10nOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl, vertical: AppTheme.spaceLg),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.routinesTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXxs),
                  Text(
                    l10n.routinesSubtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/exercises'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  side: const BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd,
                    vertical: AppTheme.spaceSm,
                  ),
                ),
                icon: const Icon(LucideIcons.dumbbell, size: 16),
                label: Text(
                  l10n.statExercises,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: l10n.searchRoutinesHint,
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          color: AppTheme.textSecondary,
                          size: 16,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                  vertical: AppTheme.spaceMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesList(BuildContext context, List<Routine> routines) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, AppTheme.spaceLg, AppTheme.spaceLg, 88),
      itemCount: routines.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spaceMd),
      itemBuilder: (context, index) {
        final routine = routines[index];
        return _buildRoutineCard(context, routine);
      },
    );
  }

  Widget _buildRoutineCard(BuildContext context, Routine routine) {
    final l10n = l10nOf(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: InkWell(
        onTap: () => context.push('/routines/${routine.id}'),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (routine.description != null &&
                            routine.description!.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spaceXs),
                          Text(
                            routine.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildRoutineMenu(context, routine),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              // Tags Row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildMetricTag(
                    label: '${routine.exerciseCount} EXERCISES',
                    color: AppTheme.primary,
                  ),
                  _buildMetricTag(
                    label: '${routine.totalSets} SETS',
                    color: AppTheme.textSecondary,
                  ),
                  _buildMetricTag(
                    icon: LucideIcons.clock,
                    label: '${routine.estimatedDurationMinutes} MIN',
                    color: AppTheme.secondary,
                  ),
                ],
              ),
              if (routine.exercises.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceMd),
                const Divider(color: AppTheme.border, height: 1),
                const SizedBox(height: 10),
                ...routine.exercises.take(3).map((e) {
                  final exName = e.exerciseName ??
                      e.exercise?.name ??
                      l10n.exerciseFallbackName;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spaceXs),
                    child: Row(
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            exName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          '${e.setsCount} sets',
                          style: AppTheme.num(
                            12,
                            color: AppTheme.textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (routine.exercises.length > 3) ...[
                  const SizedBox(height: AppTheme.spaceXxs),
                  Text(
                    '+ ${routine.exercises.length - 3} more exercises',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 14),
              // START Button (instant session startup in <1s, Law L1, L7)
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: () => _handleStartWorkout(context, routine),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(LucideIcons.play, size: 16),
                  label: Text(
                    l10n.historyStartWorkout,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTag({
    IconData? icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm, vertical: AppTheme.spaceXs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppTheme.spaceXs),
          ],
          Text(
            label,
            style: AppTheme.num(
              11,
              weight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineMenu(BuildContext context, Routine routine) {
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
      onSelected: (action) {
        if (action == 'edit') {
          context.push('/routines/${routine.id}/edit');
        } else if (action == 'duplicate') {
          _handleDuplicate(routine);
        } else if (action == 'delete') {
          _confirmDelete(context, routine);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(LucideIcons.pencil, size: 16, color: AppTheme.textPrimary),
              const SizedBox(width: 10),
              Text(l10n.editRoutineMenu, style: const TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              const Icon(LucideIcons.copy, size: 16, color: AppTheme.textPrimary),
              const SizedBox(width: 10),
              Text(l10n.duplicateMenu, style: const TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(LucideIcons.trash2, size: 16, color: AppTheme.warning),
              const SizedBox(width: 10),
              Text(l10n.deleteMenu, style: const TextStyle(color: AppTheme.warning)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleStartWorkout(BuildContext context, Routine routine) async {
    // One-session rule (§8.1): never silently discards the active session.
    final mayStart = await resolveOneSessionRule(context, ref);
    if (!mayStart || !context.mounted) return;

    final controller = ref.read(routineListControllerProvider.notifier);
    await controller.startWorkoutFromRoutine(routine);
    if (context.mounted) {
      context.push('/workout/active');
    }
  }

  Future<void> _handleDuplicate(Routine routine) async {
    final controller = ref.read(routineListControllerProvider.notifier);
    await controller.duplicateRoutine(routine.id);
    if (mounted) {
      final l10n = l10nOf(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.routineDuplicated(routine.name)),
          backgroundColor: AppTheme.surfaceElevated,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, Routine routine) {
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
              .read(routineListControllerProvider.notifier)
              .deleteRoutine(routine.id);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = l10nOf(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXxxl, vertical: AppTheme.spaceXxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                LucideIcons.dumbbell,
                size: 36,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            Text(
              l10n.routineEmptyTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              l10n.routineEmptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppTheme.spaceXxl),
            SizedBox(
              width: 220,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/routines/new'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: Text(
                  l10n.createRoutine,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(BuildContext context) {
    final l10n = l10nOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.searchX,
              size: 40,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.noRoutinesMatching(_searchQuery),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Text(
                l10n.clearSearch,
                style: const TextStyle(color: AppTheme.primary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
