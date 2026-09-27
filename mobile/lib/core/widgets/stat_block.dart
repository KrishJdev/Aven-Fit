import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A core metric display pattern (design system §10.5). Three variants share
/// one widget so stat surfaces stay visually consistent across the app:
///
/// - [StatVariant.hero]   — 1–3 headline metrics at the top of a dashboard
///   (calories remaining, workout duration). JetBrains Mono `display` size.
/// - [StatVariant.standard] — a horizontal row of 2–4 secondary metrics
///   (sets, volume, PRs, duration). `title`-size numerals.
/// - [StatVariant.inline]   — label left, value right on one line, used in
///   detail screens and list-item metadata.
///
/// Numerals always use [AppTheme.num] (tabular figures) so columns align.
/// Color independence (§18.6): meaning never relies on color alone — the
/// label is always rendered.
class StatBlock extends StatelessWidget {
  const StatBlock({
    required this.label,
    required this.value,
    this.variant = StatVariant.standard,
    this.valueColor,
    this.semanticLabel,
    this.valueKey,
    super.key,
  });

  final String label;
  final String value;
  final StatVariant variant;
  final Color? valueColor;
  final String? semanticLabel;

  /// Optional test key for the value text — lets callers preserve
  /// `find.byKey` contracts (e.g. the Profile lifetime-stats values).
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case StatVariant.hero:
        return _Hero(label: label, value: value, valueColor: valueColor, semanticLabel: semanticLabel, valueKey: valueKey);
      case StatVariant.standard:
        return _Standard(label: label, value: value, valueColor: valueColor, semanticLabel: semanticLabel, valueKey: valueKey);
      case StatVariant.inline:
        return _Inline(label: label, value: value, valueColor: valueColor, semanticLabel: semanticLabel, valueKey: valueKey);
    }
  }
}

enum StatVariant { hero, standard, inline }

class _Hero extends StatelessWidget {
  const _Hero({required this.label, required this.value, this.valueColor, this.semanticLabel, this.valueKey});

  final String label;
  final String value;
  final Color? valueColor;
  final String? semanticLabel;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? '$value $label',
      excludeSemantics: semanticLabel != null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            key: valueKey,
            style: AppTheme.num(30, weight: FontWeight.w700, color: valueColor ?? AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Standard extends StatelessWidget {
  const _Standard({required this.label, required this.value, this.valueColor, this.semanticLabel, this.valueKey});

  final String label;
  final String value;
  final Color? valueColor;
  final String? semanticLabel;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? '$value $label',
      excludeSemantics: semanticLabel != null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            key: valueKey,
            style: AppTheme.num(16, weight: FontWeight.w600, color: valueColor ?? AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spaceXxs),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Inline extends StatelessWidget {
  const _Inline({required this.label, required this.value, this.valueColor, this.semanticLabel, this.valueKey});

  final String label;
  final String value;
  final Color? valueColor;
  final String? semanticLabel;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? '$value $label',
      excludeSemantics: semanticLabel != null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Text(
            value,
            key: valueKey,
            style: AppTheme.num(14, weight: FontWeight.w500, color: valueColor ?? AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
