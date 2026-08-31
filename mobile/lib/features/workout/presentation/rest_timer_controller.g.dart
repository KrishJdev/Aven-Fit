// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_timer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Epoch-based rest countdown controller (WU-3.5, FEATURES.md §8.3).
///
/// The source of truth is the epoch deadline in [RestTimerState]; a
/// `Stream.periodic` subscription exists purely to refresh the UI and the
/// Android notification once per second — the displayed value is always
/// recomputed from the deadline, never accumulated (L8: zero CPU polling).
///
/// Resting and lifting are mutually exclusive states: starting a countdown
/// replaces any live one, [cancel] clears it instantly, and warm-up sets
/// never trigger rest. Keep-alive so the countdown survives navigation to
/// the exercise picker or other tabs while the session stays active.
///
/// WU-3.10: the controller also owns the foreground-service notification
/// actions (it is the keep-alive session-scope component): "+15s" adjusts
/// the countdown, "Finish Workout" completes the active session
/// (write-through, L7) and stops the service. Rest deadlines are pushed to
/// the service on every change so the lock-screen notification stays live.

@ProviderFor(RestTimerController)
final restTimerControllerProvider = RestTimerControllerProvider._();

/// Epoch-based rest countdown controller (WU-3.5, FEATURES.md §8.3).
///
/// The source of truth is the epoch deadline in [RestTimerState]; a
/// `Stream.periodic` subscription exists purely to refresh the UI and the
/// Android notification once per second — the displayed value is always
/// recomputed from the deadline, never accumulated (L8: zero CPU polling).
///
/// Resting and lifting are mutually exclusive states: starting a countdown
/// replaces any live one, [cancel] clears it instantly, and warm-up sets
/// never trigger rest. Keep-alive so the countdown survives navigation to
/// the exercise picker or other tabs while the session stays active.
///
/// WU-3.10: the controller also owns the foreground-service notification
/// actions (it is the keep-alive session-scope component): "+15s" adjusts
/// the countdown, "Finish Workout" completes the active session
/// (write-through, L7) and stops the service. Rest deadlines are pushed to
/// the service on every change so the lock-screen notification stays live.
final class RestTimerControllerProvider
    extends $NotifierProvider<RestTimerController, RestTimerState> {
  /// Epoch-based rest countdown controller (WU-3.5, FEATURES.md §8.3).
  ///
  /// The source of truth is the epoch deadline in [RestTimerState]; a
  /// `Stream.periodic` subscription exists purely to refresh the UI and the
  /// Android notification once per second — the displayed value is always
  /// recomputed from the deadline, never accumulated (L8: zero CPU polling).
  ///
  /// Resting and lifting are mutually exclusive states: starting a countdown
  /// replaces any live one, [cancel] clears it instantly, and warm-up sets
  /// never trigger rest. Keep-alive so the countdown survives navigation to
  /// the exercise picker or other tabs while the session stays active.
  ///
  /// WU-3.10: the controller also owns the foreground-service notification
  /// actions (it is the keep-alive session-scope component): "+15s" adjusts
  /// the countdown, "Finish Workout" completes the active session
  /// (write-through, L7) and stops the service. Rest deadlines are pushed to
  /// the service on every change so the lock-screen notification stays live.
  RestTimerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restTimerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restTimerControllerHash();

  @$internal
  @override
  RestTimerController create() => RestTimerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestTimerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestTimerState>(value),
    );
  }
}

String _$restTimerControllerHash() =>
    r'04188416fea20deddd3469238f606905f073a996';

/// Epoch-based rest countdown controller (WU-3.5, FEATURES.md §8.3).
///
/// The source of truth is the epoch deadline in [RestTimerState]; a
/// `Stream.periodic` subscription exists purely to refresh the UI and the
/// Android notification once per second — the displayed value is always
/// recomputed from the deadline, never accumulated (L8: zero CPU polling).
///
/// Resting and lifting are mutually exclusive states: starting a countdown
/// replaces any live one, [cancel] clears it instantly, and warm-up sets
/// never trigger rest. Keep-alive so the countdown survives navigation to
/// the exercise picker or other tabs while the session stays active.
///
/// WU-3.10: the controller also owns the foreground-service notification
/// actions (it is the keep-alive session-scope component): "+15s" adjusts
/// the countdown, "Finish Workout" completes the active session
/// (write-through, L7) and stops the service. Rest deadlines are pushed to
/// the service on every change so the lock-screen notification stays live.

abstract class _$RestTimerController extends $Notifier<RestTimerState> {
  RestTimerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RestTimerState, RestTimerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RestTimerState, RestTimerState>,
              RestTimerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
