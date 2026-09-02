// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reactive week-over-week glance for the Home stats (§7.1): drift
/// re-emits on any session/set change — zero polling (L8).

@ProviderFor(weeklyGlanceStream)
final weeklyGlanceStreamProvider = WeeklyGlanceStreamProvider._();

/// Reactive week-over-week glance for the Home stats (§7.1): drift
/// re-emits on any session/set change — zero polling (L8).

final class WeeklyGlanceStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeeklyGlance>,
          WeeklyGlance,
          Stream<WeeklyGlance>
        >
    with $FutureModifier<WeeklyGlance>, $StreamProvider<WeeklyGlance> {
  /// Reactive week-over-week glance for the Home stats (§7.1): drift
  /// re-emits on any session/set change — zero polling (L8).
  WeeklyGlanceStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyGlanceStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyGlanceStreamHash();

  @$internal
  @override
  $StreamProviderElement<WeeklyGlance> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<WeeklyGlance> create(Ref ref) {
    return weeklyGlanceStream(ref);
  }
}

String _$weeklyGlanceStreamHash() =>
    r'59171855560a9524e9ef3041484be76792ce4264';

/// Recent logs feed for Home — the last 10 completed workouts (§7.1),
/// same reactive source as the full history list.

@ProviderFor(recentWorkoutsStream)
final recentWorkoutsStreamProvider = RecentWorkoutsStreamProvider._();

/// Recent logs feed for Home — the last 10 completed workouts (§7.1),
/// same reactive source as the full history list.

final class RecentWorkoutsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutHistoryItem>>,
          List<WorkoutHistoryItem>,
          Stream<List<WorkoutHistoryItem>>
        >
    with
        $FutureModifier<List<WorkoutHistoryItem>>,
        $StreamProvider<List<WorkoutHistoryItem>> {
  /// Recent logs feed for Home — the last 10 completed workouts (§7.1),
  /// same reactive source as the full history list.
  RecentWorkoutsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentWorkoutsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentWorkoutsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<WorkoutHistoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WorkoutHistoryItem>> create(Ref ref) {
    return recentWorkoutsStream(ref);
  }
}

String _$recentWorkoutsStreamHash() =>
    r'9fc4960e6c1631cbb5dabb3cc55402fe2e7d9048';

/// All routines (name-ordered) — the suggestion pool (§7.1).

@ProviderFor(allRoutinesStream)
final allRoutinesStreamProvider = AllRoutinesStreamProvider._();

/// All routines (name-ordered) — the suggestion pool (§7.1).

final class AllRoutinesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Routine>>,
          List<Routine>,
          Stream<List<Routine>>
        >
    with $FutureModifier<List<Routine>>, $StreamProvider<List<Routine>> {
  /// All routines (name-ordered) — the suggestion pool (§7.1).
  AllRoutinesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allRoutinesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allRoutinesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Routine>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Routine>> create(Ref ref) {
    return allRoutinesStream(ref);
  }
}

String _$allRoutinesStreamHash() => r'72be74fb672248d3063bc29cfbad5ab1e6cecedc';

/// Reactive id of the most-recently used routine (§7.1 P0 heuristic).

@ProviderFor(suggestedRoutineIdStream)
final suggestedRoutineIdStreamProvider = SuggestedRoutineIdStreamProvider._();

/// Reactive id of the most-recently used routine (§7.1 P0 heuristic).

final class SuggestedRoutineIdStreamProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// Reactive id of the most-recently used routine (§7.1 P0 heuristic).
  SuggestedRoutineIdStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suggestedRoutineIdStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suggestedRoutineIdStreamHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return suggestedRoutineIdStream(ref);
  }
}

String _$suggestedRoutineIdStreamHash() =>
    r'1867a50a219846d62e22895bb5b4f027658ccf05';

/// Goals singleton for the calories chip — null while unset so the chip
/// is hidden entirely (never a nag, L4).

@ProviderFor(homeNutritionGoalsStream)
final homeNutritionGoalsStreamProvider = HomeNutritionGoalsStreamProvider._();

/// Goals singleton for the calories chip — null while unset so the chip
/// is hidden entirely (never a nag, L4).

final class HomeNutritionGoalsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<NutritionGoals?>,
          NutritionGoals?,
          Stream<NutritionGoals?>
        >
    with $FutureModifier<NutritionGoals?>, $StreamProvider<NutritionGoals?> {
  /// Goals singleton for the calories chip — null while unset so the chip
  /// is hidden entirely (never a nag, L4).
  HomeNutritionGoalsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeNutritionGoalsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeNutritionGoalsStreamHash();

  @$internal
  @override
  $StreamProviderElement<NutritionGoals?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NutritionGoals?> create(Ref ref) {
    return homeNutritionGoalsStream(ref);
  }
}

String _$homeNutritionGoalsStreamHash() =>
    r'9650d1df578296a335b0e4967dc30d519dc5226e';

/// Today's logged totals for the calories chip (§7.1). The DAO buckets
/// through the single local-midnight day anchor.

@ProviderFor(homeTodayTotalsStream)
final homeTodayTotalsStreamProvider = HomeTodayTotalsStreamProvider._();

/// Today's logged totals for the calories chip (§7.1). The DAO buckets
/// through the single local-midnight day anchor.

final class HomeTodayTotalsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<DailyNutritionTotals>,
          DailyNutritionTotals,
          Stream<DailyNutritionTotals>
        >
    with
        $FutureModifier<DailyNutritionTotals>,
        $StreamProvider<DailyNutritionTotals> {
  /// Today's logged totals for the calories chip (§7.1). The DAO buckets
  /// through the single local-midnight day anchor.
  HomeTodayTotalsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeTodayTotalsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeTodayTotalsStreamHash();

  @$internal
  @override
  $StreamProviderElement<DailyNutritionTotals> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DailyNutritionTotals> create(Ref ref) {
    return homeTodayTotalsStream(ref);
  }
}

String _$homeTodayTotalsStreamHash() =>
    r'063e0040b1a55ecd05eb172c58c082c7884eb0e9';

/// Riverpod Notifier composing the Home dashboard state (WU-X.1,
/// FEATURES.md §7.1): the active session, streak, week-over-week glance,
/// recent logs, suggested routine, and today's nutrition summary. Every
/// field streams from local SQLite — re-emits on any source change,
/// zero polling (L2/L8).

@ProviderFor(HomeController)
final homeControllerProvider = HomeControllerProvider._();

/// Riverpod Notifier composing the Home dashboard state (WU-X.1,
/// FEATURES.md §7.1): the active session, streak, week-over-week glance,
/// recent logs, suggested routine, and today's nutrition summary. Every
/// field streams from local SQLite — re-emits on any source change,
/// zero polling (L2/L8).
final class HomeControllerProvider
    extends $NotifierProvider<HomeController, HomeState> {
  /// Riverpod Notifier composing the Home dashboard state (WU-X.1,
  /// FEATURES.md §7.1): the active session, streak, week-over-week glance,
  /// recent logs, suggested routine, and today's nutrition summary. Every
  /// field streams from local SQLite — re-emits on any source change,
  /// zero polling (L2/L8).
  HomeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeControllerHash();

  @$internal
  @override
  HomeController create() => HomeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeState>(value),
    );
  }
}

String _$homeControllerHash() => r'f2a72b21e1fde2f0ba09ad76a286deaa7404a7e0';

/// Riverpod Notifier composing the Home dashboard state (WU-X.1,
/// FEATURES.md §7.1): the active session, streak, week-over-week glance,
/// recent logs, suggested routine, and today's nutrition summary. Every
/// field streams from local SQLite — re-emits on any source change,
/// zero polling (L2/L8).

abstract class _$HomeController extends $Notifier<HomeState> {
  HomeState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeState, HomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeState, HomeState>,
              HomeState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
