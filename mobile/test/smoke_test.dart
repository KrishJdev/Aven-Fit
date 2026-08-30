import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Minimal contract used purely to prove the mocktail harness runs.
/// Mirrors the repository/store mocking pattern the project standardizes
/// on (AGENTS.md tooling table).
abstract class _TaskSink {
  bool execute(String task);
  String? lastTask();
}

class _MockTaskSink extends Mock implements _TaskSink {}

void main() {
  setUpAll(() {
    // Required before any `when()` with non-nullable argument matchers.
    registerFallbackValue('');
  });

  test('mocktail harness executes: stub, act, verify', () {
    final sink = _MockTaskSink();

    when(() => sink.execute(any())).thenReturn(true);
    when(() => sink.lastTask()).thenReturn(null);

    expect(sink.execute('sync_queue_drain'), isTrue);
    expect(sink.lastTask(), isNull);

    verify(() => sink.execute('sync_queue_drain')).called(1);
    verifyNever(() => sink.execute('unknown_task'));
  });

  test('mocktail captures arguments and matches predicates', () {
    final sink = _MockTaskSink();

    when(() => sink.execute(any(that: startsWith('sync')))).thenReturn(true);
    when(() => sink.execute(any(that: isNot(startsWith('sync')))))
        .thenReturn(false);

    expect(sink.execute('sync_queue_drain'), isTrue);
    expect(sink.execute('prune_cache'), isFalse);
  });

  test('test harness executes within flutter_test runner', () {
    // Sanity: matcher plumbing from flutter_test is intact.
    expect(true, isTrue);
    expect(1 + 1, equals(2));
    expect('aven fit', isA<String>());
  });
}
