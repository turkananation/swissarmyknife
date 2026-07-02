import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('retry', () {
    test('should return success when action succeeds immediately', () async {
      final result = await retry(() => 42, delay: Duration.zero);

      expect(result, equals(const Result<int, Object>.success(42)));
    });

    test('should retry failures and eventually return success', () async {
      var calls = 0;
      final attempts = <RetryAttempt>[];

      final result = await retry(
        () {
          calls++;
          if (calls < 3) throw StateError('not yet');
          return 'done';
        },
        maxAttempts: 3,
        delay: Duration.zero,
        onRetry: attempts.add,
      );

      expect(result, equals(const Result<String, Object>.success('done')));
      expect(calls, equals(3));
      expect(attempts.map((attempt) => attempt.attemptNumber), equals([1, 2]));
      expect(attempts.every((attempt) => attempt.hasMoreAttempts), isTrue);
    });

    test('should return final failure after max attempts', () async {
      var calls = 0;

      final result = await retry<int>(
        () {
          calls++;
          throw StateError('bad');
        },
        maxAttempts: 2,
        delay: Duration.zero,
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<StateError>());
      expect(calls, equals(2));
    });

    test('should stop retrying when retryIf returns false', () async {
      var calls = 0;

      final result = await retry<int>(
        () {
          calls++;
          throw ArgumentError('fatal');
        },
        maxAttempts: 3,
        delay: Duration.zero,
        retryIf: (error) => error is! ArgumentError,
      );

      expect(result.isFailure, isTrue);
      expect(calls, equals(1));
    });

    test('should calculate linear and exponential backoff delays', () async {
      final linearDelays = <Duration>[];
      await retry<int>(
        () => throw StateError('linear'),
        maxAttempts: 3,
        delay: const Duration(microseconds: 1),
        backoff: BackoffStrategy.linear,
        onRetry: (attempt) => linearDelays.add(attempt.nextDelay),
      );

      final exponentialDelays = <Duration>[];
      await retry<int>(
        () => throw StateError('exponential'),
        maxAttempts: 4,
        delay: const Duration(microseconds: 1),
        backoff: BackoffStrategy.exponential,
        onRetry: (attempt) => exponentialDelays.add(attempt.nextDelay),
      );

      expect(
        linearDelays,
        equals([
          const Duration(microseconds: 1),
          const Duration(microseconds: 2),
        ]),
      );
      expect(
        exponentialDelays,
        equals([
          const Duration(microseconds: 1),
          const Duration(microseconds: 2),
          const Duration(microseconds: 4),
        ]),
      );
    });

    test('should validate retry configuration', () {
      expect(() => retry(() => 1, maxAttempts: 0), throwsArgumentError);
      expect(
        () => retry(() => 1, delay: const Duration(microseconds: -1)),
        throwsArgumentError,
      );
      expect(() => retry(() => 1, jitter: 2), throwsArgumentError);
    });
  });
}
