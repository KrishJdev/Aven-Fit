import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Standard confirmation dialog (design system §10.10): title + body +
/// right-aligned cancel (tertiary) + confirm (primary or destructive).
/// Destructive actions use [ConfirmStyle.destructive] so the confirm
/// button renders in [AppTheme.warning] (§10.1). Two-step confirmations
/// for permanent deletions stay a caller concern — this widget is the
/// single confirm surface.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel,
    this.onCancel,
    this.style = ConfirmStyle.primary,
    this.cancelKey,
    this.confirmKey,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final ConfirmStyle style;

  /// Optional test keys for the action buttons — lets callers preserve
  /// `find.byKey` contracts (e.g. the Profile sign-out confirm/cancel)
  /// when adopting this widget.
  final Key? cancelKey;
  final Key? confirmKey;

  @override
  Widget build(BuildContext context) {
    final isDestructive = style == ConfirmStyle.destructive;
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppTheme.textSecondary),
      ),
      actions: [
        TextButton(
          key: cancelKey,
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(
            (cancelLabel ?? 'Cancel').toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        FilledButton(
          key: confirmKey,
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true);
          },
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive ? AppTheme.warning : AppTheme.primary,
            foregroundColor: AppTheme.textOnPrimary,
          ),
          child: Text(
            confirmLabel.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

enum ConfirmStyle { primary, destructive }
