import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/pr_local_source.dart';
import '../data/pr_repository.dart';

part 'pr_vault_controller.g.dart';

/// Reactive PR vault (WU-X.3, FEATURES.md §10.2): every personal record
/// joined with its exercise name, newest achievement first — the
/// Progress preview and the full vault screen share this one stream.
/// Drift re-emits on any record change (L8, zero polling).
@riverpod
Stream<List<PRVaultEntry>> prVaultStream(Ref ref) {
  return ref.watch(prRepositoryProvider).watchVault();
}
