// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The dashboard's selected calendar day, bucketed to local midnight via
/// [LoggedMealItem.normalizeDay] — the single day-anchor every nutrition
/// read goes through (WU-4.3), so navigation never leaves a stray time
/// component. Defaults to today.

@ProviderFor(SelectedNutritionDay)
final selectedNutritionDayProvider = SelectedNutritionDayProvider._();

/// The dashboard's selected calendar day, bucketed to local midnight via
/// [LoggedMealItem.normalizeDay] — the single day-anchor every nutrition
/// read goes through (WU-4.3), so navigation never leaves a stray time
/// component. Defaults to today.
final class SelectedNutritionDayProvider
    extends $NotifierProvider<SelectedNutritionDay, DateTime> {
  /// The dashboard's selected calendar day, bucketed to local midnight via
  /// [LoggedMealItem.normalizeDay] — the single day-anchor every nutrition
  /// read goes through (WU-4.3), so navigation never leaves a stray time
  /// component. Defaults to today.
  SelectedNutritionDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedNutritionDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedNutritionDayHash();

  @$internal
  @override
  SelectedNutritionDay create() => SelectedNutritionDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedNutritionDayHash() =>
    r'353599b25439b0e1a1eba9ee89e2dc2d21c7314f';

/// The dashboard's selected calendar day, bucketed to local midnight via
/// [LoggedMealItem.normalizeDay] — the single day-anchor every nutrition
/// read goes through (WU-4.3), so navigation never leaves a stray time
/// component. Defaults to today.

abstract class _$SelectedNutritionDay extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Reactive daily log for [day] — the dashboard's item source. Drift
/// re-emits on every log mutation and catalog change; zero polling (L8).

@ProviderFor(dailyLogStream)
final dailyLogStreamProvider = DailyLogStreamFamily._();

/// Reactive daily log for [day] — the dashboard's item source. Drift
/// re-emits on every log mutation and catalog change; zero polling (L8).

final class DailyLogStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NutritionLogEntry>>,
          List<NutritionLogEntry>,
          Stream<List<NutritionLogEntry>>
        >
    with
        $FutureModifier<List<NutritionLogEntry>>,
        $StreamProvider<List<NutritionLogEntry>> {
  /// Reactive daily log for [day] — the dashboard's item source. Drift
  /// re-emits on every log mutation and catalog change; zero polling (L8).
  DailyLogStreamProvider._({
    required DailyLogStreamFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'dailyLogStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dailyLogStreamHash();

  @override
  String toString() {
    return r'dailyLogStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<NutritionLogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<NutritionLogEntry>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return dailyLogStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyLogStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dailyLogStreamHash() => r'0dd3f2caae8ed0dd056e27d5de42be2b1f57feb9';

/// Reactive daily log for [day] — the dashboard's item source. Drift
/// re-emits on every log mutation and catalog change; zero polling (L8).

final class DailyLogStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<NutritionLogEntry>>, DateTime> {
  DailyLogStreamFamily._()
    : super(
        retry: null,
        name: r'dailyLogStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Reactive daily log for [day] — the dashboard's item source. Drift
  /// re-emits on every log mutation and catalog change; zero polling (L8).

  DailyLogStreamProvider call(DateTime day) =>
      DailyLogStreamProvider._(argument: day, from: this);

  @override
  String toString() => r'dailyLogStreamProvider';
}

/// Reactive daily macro totals for [day] — derived on every read from the
/// log snapshots, never stored, so edits/deletes self-heal (L7/L8).

@ProviderFor(dailyTotalsStream)
final dailyTotalsStreamProvider = DailyTotalsStreamFamily._();

/// Reactive daily macro totals for [day] — derived on every read from the
/// log snapshots, never stored, so edits/deletes self-heal (L7/L8).

final class DailyTotalsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<DailyNutritionTotals>,
          DailyNutritionTotals,
          Stream<DailyNutritionTotals>
        >
    with
        $FutureModifier<DailyNutritionTotals>,
        $StreamProvider<DailyNutritionTotals> {
  /// Reactive daily macro totals for [day] — derived on every read from the
  /// log snapshots, never stored, so edits/deletes self-heal (L7/L8).
  DailyTotalsStreamProvider._({
    required DailyTotalsStreamFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'dailyTotalsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dailyTotalsStreamHash();

  @override
  String toString() {
    return r'dailyTotalsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DailyNutritionTotals> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DailyNutritionTotals> create(Ref ref) {
    final argument = this.argument as DateTime;
    return dailyTotalsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyTotalsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dailyTotalsStreamHash() => r'8eac4b08ece00d51734d7c6ff9f5af248a0b576e';

/// Reactive daily macro totals for [day] — derived on every read from the
/// log snapshots, never stored, so edits/deletes self-heal (L7/L8).

final class DailyTotalsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DailyNutritionTotals>, DateTime> {
  DailyTotalsStreamFamily._()
    : super(
        retry: null,
        name: r'dailyTotalsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Reactive daily macro totals for [day] — derived on every read from the
  /// log snapshots, never stored, so edits/deletes self-heal (L7/L8).

  DailyTotalsStreamProvider call(DateTime day) =>
      DailyTotalsStreamProvider._(argument: day, from: this);

  @override
  String toString() => r'dailyTotalsStreamProvider';
}

/// Reactive goals singleton — emits null while unset so the dashboard
/// hides the calories-remaining card entirely (never a nag, L4).

@ProviderFor(nutritionGoalsStream)
final nutritionGoalsStreamProvider = NutritionGoalsStreamProvider._();

/// Reactive goals singleton — emits null while unset so the dashboard
/// hides the calories-remaining card entirely (never a nag, L4).

final class NutritionGoalsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<NutritionGoals?>,
          NutritionGoals?,
          Stream<NutritionGoals?>
        >
    with $FutureModifier<NutritionGoals?>, $StreamProvider<NutritionGoals?> {
  /// Reactive goals singleton — emits null while unset so the dashboard
  /// hides the calories-remaining card entirely (never a nag, L4).
  NutritionGoalsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionGoalsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionGoalsStreamHash();

  @$internal
  @override
  $StreamProviderElement<NutritionGoals?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NutritionGoals?> create(Ref ref) {
    return nutritionGoalsStream(ref);
  }
}

String _$nutritionGoalsStreamHash() =>
    r'93b084a8713f1ca9904e3798adc150f4d0147cd4';

/// Riverpod Notifier composing the Nutrition Dashboard state (WU-4.5,
/// FEATURES.md §11.1): the selected day plus the three reactive SQLite
/// streams (daily log, daily totals, goals). Re-emits whenever any source
/// changes — including day navigation, which re-subscribes through the
/// keyed stream providers.
///
/// Mutations are thin write-through pass-throughs to the repository; the
/// daily-log stream re-emits the resulting state, so the macro math is
/// never duplicated here (single path: [LoggedMealItem.calculate] →
/// `FoodItem.scaleFor`, L1/L7).

@ProviderFor(NutritionDashboardController)
final nutritionDashboardControllerProvider =
    NutritionDashboardControllerProvider._();

/// Riverpod Notifier composing the Nutrition Dashboard state (WU-4.5,
/// FEATURES.md §11.1): the selected day plus the three reactive SQLite
/// streams (daily log, daily totals, goals). Re-emits whenever any source
/// changes — including day navigation, which re-subscribes through the
/// keyed stream providers.
///
/// Mutations are thin write-through pass-throughs to the repository; the
/// daily-log stream re-emits the resulting state, so the macro math is
/// never duplicated here (single path: [LoggedMealItem.calculate] →
/// `FoodItem.scaleFor`, L1/L7).
final class NutritionDashboardControllerProvider
    extends
        $NotifierProvider<
          NutritionDashboardController,
          NutritionDashboardState
        > {
  /// Riverpod Notifier composing the Nutrition Dashboard state (WU-4.5,
  /// FEATURES.md §11.1): the selected day plus the three reactive SQLite
  /// streams (daily log, daily totals, goals). Re-emits whenever any source
  /// changes — including day navigation, which re-subscribes through the
  /// keyed stream providers.
  ///
  /// Mutations are thin write-through pass-throughs to the repository; the
  /// daily-log stream re-emits the resulting state, so the macro math is
  /// never duplicated here (single path: [LoggedMealItem.calculate] →
  /// `FoodItem.scaleFor`, L1/L7).
  NutritionDashboardControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionDashboardControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionDashboardControllerHash();

  @$internal
  @override
  NutritionDashboardController create() => NutritionDashboardController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NutritionDashboardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NutritionDashboardState>(value),
    );
  }
}

String _$nutritionDashboardControllerHash() =>
    r'c77b2fc6b22a2d66d29e621addd1e64bf95bb81e';

/// Riverpod Notifier composing the Nutrition Dashboard state (WU-4.5,
/// FEATURES.md §11.1): the selected day plus the three reactive SQLite
/// streams (daily log, daily totals, goals). Re-emits whenever any source
/// changes — including day navigation, which re-subscribes through the
/// keyed stream providers.
///
/// Mutations are thin write-through pass-throughs to the repository; the
/// daily-log stream re-emits the resulting state, so the macro math is
/// never duplicated here (single path: [LoggedMealItem.calculate] →
/// `FoodItem.scaleFor`, L1/L7).

abstract class _$NutritionDashboardController
    extends $Notifier<NutritionDashboardState> {
  NutritionDashboardState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<NutritionDashboardState, NutritionDashboardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NutritionDashboardState, NutritionDashboardState>,
              NutritionDashboardState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
