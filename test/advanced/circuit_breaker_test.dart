import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

final class _FakeClock {
  _FakeClock(this.now);

  DateTime now;

  DateTime call() => now;

  void advance(Duration duration) {
    now = now.add(duration);
  }
}

void main() {
  group('CircuitBreaker', () {
    test('should execute successful actions while closed', () async {
      final breaker = CircuitBreaker();

      final result = await breaker.execute(() => 42);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, equals(42));
      expect(breaker.state, equals(CircuitBreakerState.closed));
      expect(breaker.failureCount, equals(0));
    });

    test('should open after failure threshold', () async {
      final clock = _FakeClock(DateTime(2026));
      final breaker = CircuitBreaker(
        failureThreshold: 2,
        openTimeout: const Duration(seconds: 5),
        clock: clock.call,
      );

      expect(
        (await breaker.execute<int>(() => throw StateError('one'))).isFailure,
        isTrue,
      );
      expect(breaker.state, equals(CircuitBreakerState.closed));

      final result = await breaker.execute<int>(() => throw StateError('two'));

      expect(result.errorOrNull, isA<CircuitBreakerExecutionError>());
      expect(breaker.state, equals(CircuitBreakerState.open));
      expect(breaker.openedAt, equals(clock.now));
      expect(
        breaker.nextAttemptAt,
        equals(clock.now.add(const Duration(seconds: 5))),
      );
      expect(breaker.lastError, isA<StateError>());
    });

    test('should fail fast while open', () async {
      final clock = _FakeClock(DateTime(2026));
      final breaker = CircuitBreaker(
        failureThreshold: 1,
        openTimeout: const Duration(seconds: 5),
        clock: clock.call,
      );
      await breaker.execute<int>(() => throw StateError('bad'));

      final result = await breaker.execute(() => 42);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<CircuitBreakerOpenError>());
      expect(breaker.canAttempt, isFalse);
      expect(breaker.state, equals(CircuitBreakerState.open));
    });

    test(
      'should half-open after timeout and close after success threshold',
      () async {
        final clock = _FakeClock(DateTime(2026));
        final breaker = CircuitBreaker(
          failureThreshold: 1,
          successThreshold: 2,
          openTimeout: const Duration(seconds: 5),
          clock: clock.call,
        );
        await breaker.execute<int>(() => throw StateError('bad'));
        clock.advance(const Duration(seconds: 5));

        expect(await breaker.execute(() => 'probe-1'), isA<Success>());
        expect(breaker.state, equals(CircuitBreakerState.halfOpen));
        expect(breaker.successCount, equals(1));

        expect(await breaker.execute(() => 'probe-2'), isA<Success>());

        expect(breaker.state, equals(CircuitBreakerState.closed));
        expect(breaker.successCount, equals(0));
        expect(breaker.failureCount, equals(0));
        expect(breaker.lastError, isNull);
      },
    );

    test('should reopen when half-open probe fails', () async {
      final clock = _FakeClock(DateTime(2026));
      final breaker = CircuitBreaker(
        failureThreshold: 1,
        openTimeout: const Duration(seconds: 5),
        clock: clock.call,
      );
      await breaker.execute<int>(() => throw StateError('initial'));
      clock.advance(const Duration(seconds: 5));

      final result = await breaker.execute<int>(
        () => throw StateError('probe'),
      );

      expect(result.errorOrNull, isA<CircuitBreakerExecutionError>());
      expect(breaker.state, equals(CircuitBreakerState.open));
      expect(breaker.openedAt, equals(clock.now));
    });

    test('should reset and force states', () async {
      final breaker = CircuitBreaker(failureThreshold: 1);
      await breaker.execute<int>(() => throw StateError('bad'));

      breaker.reset();

      expect(breaker.state, equals(CircuitBreakerState.closed));
      expect(breaker.failureCount, equals(0));
      expect(breaker.lastError, isNull);

      breaker.forceOpen();
      expect(breaker.state, equals(CircuitBreakerState.open));

      breaker.forceClosed();
      expect(breaker.state, equals(CircuitBreakerState.closed));
    });

    test('should validate configuration', () {
      expect(() => CircuitBreaker(failureThreshold: 0), throwsArgumentError);
      expect(() => CircuitBreaker(successThreshold: 0), throwsArgumentError);
      expect(
        () => CircuitBreaker(openTimeout: Duration.zero),
        throwsArgumentError,
      );
    });
  });
}
