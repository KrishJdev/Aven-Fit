import 'package:workmanager/workmanager.dart';

/// Canonical WorkManager task IDs. The sync queue drain (Slice 5) is the
/// only consumer today; register future task families here.
abstract final class WorkmanagerTasks {
  /// Drains the local `sync_queue` to the Spring Boot API with
  /// exponential backoff (network-constrained, per AGENTS.md L8).
  static const syncQueueDrain = 'com.avenfit.aven_fit.sync.queue_drain';
}

/// Runs when the Android OS wakes the app for scheduled background work.
///
/// Must stay a **top-level** function annotated `@pragma('vm:entry-point')`
/// so the Dart entry point survives AOT tree-shaking — WorkManager invokes
/// it from a background isolate with no other context. `executeTask`
/// registers the handler and returns immediately (void by design in
/// workmanager 0.10.x); it must not be awaited.
@pragma('vm:entry-point')
void workmanagerDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case WorkmanagerTasks.syncQueueDrain:
        // Slice 5 wires the real queue drain; until then the task
        // succeeds cheaply so the scheduler keeps a healthy cadence.
        return true;
      default:
        // Unknown tasks must not crash the isolate — report failure so
        // WorkManager applies backoff instead of retrying blind.
        return false;
    }
  });
}
