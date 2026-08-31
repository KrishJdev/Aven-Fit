import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/workout_repository.dart';
import '../../domain/workout_session.dart';

/// Outcome chosen by the user in the one-session conflict dialog (§8.1).
enum SessionConflictDecision { resume, saveAsCompleted, discard }

/// Enforces the one-session rule (FEATURES.md §8.1): only one active session
/// may exist. Call before any flow that would create a new session.
///
/// Returns `true` when the caller may proceed with starting the new session:
/// * no active session → proceeds immediately (single indexed SQLite read).
/// * Resume → navigates to the active workout and returns `false`.
/// * Save as completed → finishes the current session (epoch-math duration)
///   and returns `true` — the data is kept, never lost (L7).
/// * Discard → asks a destructive-action confirmation (L7) and discards.
/// * Dismissed → returns `false`.
Future<bool> resolveOneSessionRule(
  BuildContext context,
  WidgetRef ref,
) async {
  final repository = ref.read(workoutRepositoryProvider);
  final active = await repository.getActiveSession();
  if (active == null) return true;
  if (!context.mounted) return false;

  final decision = await showDialog<SessionConflictDecision>(
    context: context,
    builder: (_) => SessionConflictDialog(session: active),
  );
  if (decision == null || !context.mounted) return false;

  switch (decision) {
    case SessionConflictDecision.resume:
      context.go('/workout/active');
      return false;

    case SessionConflictDecision.saveAsCompleted:
      await repository.finishWorkout(
        active.id,
        durationSeconds: active.elapsedSecondsNow(),
      );
      return true;

    case SessionConflictDecision.discard:
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF16191D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'DISCARD SESSION?',
            style: AppTheme.num(16, weight: FontWeight.w700, color: AppTheme.burntOrange),
          ),
          content: const Text(
            'Discard the in-progress workout? This can\'t be undone.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('KEEP', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.burntOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('DISCARD'),
            ),
          ],
        ),
      );
      if (confirmed != true) return false;
      await repository.cancelWorkout(active.id);
      return true;
  }
}

/// Sharp Glassmorphism prompt shown when a session is already active
/// (FEATURES.md §8.1): Resume / Save current as completed / Discard current.
class SessionConflictDialog extends StatelessWidget {
  const SessionConflictDialog({required this.session, super.key});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final elapsed = session.elapsedSecondsNow();
    final elapsedText =
        '${(elapsed ~/ 60).toString().padLeft(2, '0')}:${(elapsed % 60).toString().padLeft(2, '0')}';

    return AlertDialog(
      backgroundColor: const Color(0xFF16191D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'SESSION IN PROGRESS',
        style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
      ),
      content: Text(
        '"${session.name}" is still running · $elapsedText elapsed. One session can be active at a time.',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      ),
      actions: [
        TextButton(
          key: const ValueKey('conflict_discard'),
          onPressed: () =>
              Navigator.of(context).pop(SessionConflictDecision.discard),
          child: const Text('DISCARD',
              style: TextStyle(color: AppTheme.burntOrange)),
        ),
        TextButton(
          key: const ValueKey('conflict_save_completed'),
          onPressed: () => Navigator.of(context)
              .pop(SessionConflictDecision.saveAsCompleted),
          child: const Text('SAVE AS COMPLETED',
              style: TextStyle(color: AppTheme.voltGreen)),
        ),
        FilledButton(
          key: const ValueKey('conflict_resume'),
          onPressed: () =>
              Navigator.of(context).pop(SessionConflictDecision.resume),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.neonCyan,
            foregroundColor: Colors.black,
          ),
          child: const Text('RESUME'),
        ),
      ],
    );
  }
}
