import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Glassmorphism skeleton loader (WU-X.4, Law L6) — the standard loading
/// state for every async screen load.
///
/// Deliberately a STATIC skeleton: local SQLite reads complete in <2s
/// cold start (L2), so an animated shimmer would burn frames and battery
/// for nothing on the target ₹9,000 phones (L5/L8 spirit). The glass
/// rows hint at the content shape instead of a bare spinner.
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({this.rows = 4, super.key});

  /// How many skeleton list rows to draw.
  final int rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar — hints at the first card's title.
          _SkeletonBox(height: 18, widthFactor: 0.45),
          const SizedBox(height: 14),
          for (var i = 0; i < rows; i++) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.glassFill,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(height: 12, widthFactor: 0.6),
                  const SizedBox(height: 8),
                  _SkeletonBox(height: 10, widthFactor: 0.85),
                ],
              ),
            ),
            if (i < rows - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// One glass skeleton bar — a fraction of the available width.
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
        decoration: BoxDecoration(
          color: AppTheme.glassFill,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.glassBorder),
        ),
      ),
    );
  }
}
