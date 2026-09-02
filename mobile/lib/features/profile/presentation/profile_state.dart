import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/auth_state.dart';
import '../../history/domain/lifetime_stats.dart';

part 'profile_state.freezed.dart';

/// Immutable Profile screen state (WU-5.3, FEATURES.md §12.1): the auth
/// union drives identity (guest banner vs account header) and the
/// lifetime stats drive the totals grid. Pure state — every display
/// string comes from the domain models.
@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    required AuthState auth,
    required LifetimeStats stats,
  }) = _ProfileState;
}
