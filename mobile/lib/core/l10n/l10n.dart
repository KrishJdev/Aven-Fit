import 'package:aven_fit/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Localization lookup (§15 localization-ready): every screen reads UI
/// strings through [l10nOf] instead of literals, so V1.1's Hindi pass is
/// a translation task, not a rewrite.
///
/// The generated `AppLocalizations.of` returns null when no delegate is
/// installed above [context] (only happens in bare widget-test harnesses
/// that pump screens without localization). We fall back to the template
/// (English) lookup there rather than crashing — the app never installs
/// its delegates without a MaterialApp, so production always resolves the
/// installed delegate.
AppLocalizations l10nOf(BuildContext context) =>
    Localizations.of<AppLocalizations>(context, AppLocalizations) ??
    lookupAppLocalizations(const Locale('en'));
