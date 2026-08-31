import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/routine.dart';
import 'routine_list_controller.dart';

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
    final routinesAsync = ref.watch(routineListControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.neonCyan,
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.alertTriangle,
                          color: AppTheme.burntOrange,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading routines: $err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.neonCyan,
        foregroundColor: AppTheme.oledBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text(
          'NEW ROUTINE',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        onPressed: () => context.push('/routines/new'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppTheme.oledBlack,
        border: Border(
          bottom: BorderSide(color: AppTheme.glassBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROUTINES',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Workout splits & templates',
                    style: TextStyle(
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
                  side: const BorderSide(color: AppTheme.glassBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(LucideIcons.dumbbell, size: 16),
                label: const Text(
                  'EXERCISES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.glassFill,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search routines by name or muscle...',
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
                  horizontal: 12,
                  vertical: 12,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: routines.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final routine = routines[index];
        return _buildRoutineCard(context, routine);
      },
    );
  }

  Widget _buildRoutineCard(BuildContext context, Routine routine) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
      ),
      child: InkWell(
        onTap: () => context.push('/routines/${routine.id}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          const SizedBox(height: 4),
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
              const SizedBox(height: 12),
              // Tags Row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildMetricTag(
                    label: '${routine.exerciseCount} EXERCISES',
                    color: AppTheme.neonCyan,
                  ),
                  _buildMetricTag(
                    label: '${routine.totalSets} SETS',
                    color: AppTheme.textSecondary,
                  ),
                  _buildMetricTag(
                    icon: LucideIcons.clock,
                    label: '${routine.estimatedDurationMinutes} MIN',
                    color: AppTheme.voltGreen,
                  ),
                ],
              ),
              if (routine.exercises.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: AppTheme.glassBorder, height: 1),
                const SizedBox(height: 10),
                ...routine.exercises.take(3).map((e) {
                  final exName = e.exerciseName ??
                      e.exercise?.name ??
                      'Exercise';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: AppTheme.neonCyan,
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
                  const SizedBox(height: 2),
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
                    backgroundColor: AppTheme.neonCyan,
                    foregroundColor: AppTheme.oledBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(LucideIcons.play, size: 16),
                  label: const Text(
                    'START WORKOUT',
                    style: TextStyle(
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            const SizedBox(width: 4),
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
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(LucideIcons.pencil, size: 16, color: AppTheme.textPrimary),
              SizedBox(width: 10),
              Text('Edit Routine', style: TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(LucideIcons.copy, size: 16, color: AppTheme.textPrimary),
              SizedBox(width: 10),
              Text('Duplicate', style: TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(LucideIcons.trash2, size: 16, color: AppTheme.burntOrange),
              SizedBox(width: 10),
              Text('Delete', style: TextStyle(color: AppTheme.burntOrange)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleStartWorkout(BuildContext context, Routine routine) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Duplicated "${routine.name}"'),
          backgroundColor: const Color(0xFF1F1F24),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, Routine routine) {
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
                  .read(routineListControllerProvider.notifier)
                  .deleteRoutine(routine.id);
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.neonCyan.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.neonCyan.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                LucideIcons.dumbbell,
                size: 36,
                color: AppTheme.neonCyan,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'NO ROUTINES YET',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create unlimited custom routines and workout splits to streamline your gym sessions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/routines/new'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonCyan,
                  foregroundColor: AppTheme.oledBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text(
                  'CREATE ROUTINE',
                  style: TextStyle(
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'No routines matching "$_searchQuery"',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Text(
                'CLEAR SEARCH',
                style: TextStyle(color: AppTheme.neonCyan, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
