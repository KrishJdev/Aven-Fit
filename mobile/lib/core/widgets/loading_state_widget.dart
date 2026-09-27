import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Static skeleton loader (WU-X.4, Law L6; v2 §10.14) — the standard
/// loading state for every async screen load.
///
/// Deliberately a STATIC skeleton: local SQLite reads complete in <2s
/// cold start (L2), so an animated shimmer would burn frames and battery
/// for nothing on the target ₹9,000 phones (L5/L8 spirit). The surface
/// rows hint at the content shape instead of a bare spinner. v2: solid
/// [AppTheme.surface] fill, [AppTheme.radiusMd], no border (§11.5).
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({this.rows = 4, super.key});

  /// How many skeleton list rows to draw.
  final int rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar — hints at the first card's title.
          const _SkeletonBox(height: 18, widthFactor: 0.45),
          const SizedBox(height: AppTheme.spaceMd),
          for (var i = 0; i < rows; i++) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusMd)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SkeletonBox(height: 12, widthFactor: 0.6),
                  const SizedBox(height: AppTheme.spaceSm),
                  const _SkeletonBox(height: 10, widthFactor: 0.85),
                ],
              ),
            ),
            if (i < rows - 1) const SizedBox(height: AppTheme.spaceSm),
          ],
        ],
      ),
    );
  }
}

/// One skeleton bar — a fraction of the available width.
class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, required this.widthFactor});

  final double height;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceActive,
          borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusSm)),
        ),
      ),
    );
  }
}
