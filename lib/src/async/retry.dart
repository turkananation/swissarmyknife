/// Retry utilities with configurable backoff.
///
/// Use [retry] to wrap transient operations without scattering retry loops and
/// exception handling through application code.
library;

import 'dart:async';
import 'dart:math' as math;

import '../functional/result.dart';

/// Backoff strategies supported by [retry].
///
/// Example:
/// ```dart
/// await retry(fetch, backoff: BackoffStrategy.exponential);
/// ```
enum BackoffStrategy {
  /// Uses the same delay after every failed attempt.
  constant,

  /// Multiplies delay by the current attempt number.
  linear,

  /// Doubles delay for each retry attempt.
  exponential,
}

/// Information about a retry attempt.
///
/// Example:
/// ```dart
/// retry(load, onRetry: (attempt) => print(attempt.nextDelay));
/// ```
final class RetryAttempt {
  /// Creates retry attempt information.
  const RetryAttempt({
    required this.attemptNumber,
    required this.maxAttempts,
    required this.error,
    required this.nextDelay,
  });

  /// The 1-based attempt number that failed.
  final int attemptNumber;

  /// The maximum number of attempts configured.
  final int maxAttempts;

  /// The error thrown by the failed attempt.
  final Object error;

  /// The delay before the next attempt.
  final Duration nextDelay;

  /// Whether another attempt will be made.
  bool get hasMoreAttempts => attemptNumber < maxAttempts;
}

/// Retries [action] until it succeeds or retry policy stops.
///
/// Returns [Result.success] with the action value, or [Result.failure] with the
/// final error. [retryIf] can stop retries for non-transient errors.
///
/// Example:
/// ```dart
/// final result = await retry(
///   () => fetchUser(),
///   maxAttempts: 3,
///   backoff: BackoffStrategy.exponential,
/// );
/// ```
Future<Result<T, Object>> retry<T>(
  FutureOr<T> Function() action, {
  int maxAttempts = 3,
  Duration delay = const Duration(milliseconds: 100),
  BackoffStrategy backoff = BackoffStrategy.constant,
  double jitter = 0,
  bool Function(Object error)? retryIf,
  void Function(RetryAttempt attempt)? onRetry,
  math.Random? random,
}) async {
  if (maxAttempts <= 0) {
    throw ArgumentError.value(maxAttempts, 'maxAttempts', 'Must be positive.');
  }
  if (delay.isNegative) {
    throw ArgumentError.value(delay, 'delay', 'Must not be negative.');
  }
  if (jitter < 0 || jitter > 1) {
    throw ArgumentError.value(jitter, 'jitter', 'Must be between 0 and 1.');
  }

  final rng = random ?? math.Random();

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return Result<T, Object>.success(await action());
    } catch (error) {
      final shouldRetry = retryIf?.call(error) ?? true;
      final isLastAttempt = attempt >= maxAttempts;
      if (!shouldRetry || isLastAttempt) {
        return Result<T, Object>.failure(error);
      }

      final nextDelay = _delayForAttempt(
        baseDelay: delay,
        failedAttempt: attempt,
        strategy: backoff,
        jitter: jitter,
        random: rng,
      );

      onRetry?.call(
        RetryAttempt(
          attemptNumber: attempt,
          maxAttempts: maxAttempts,
          error: error,
          nextDelay: nextDelay,
        ),
      );

      if (nextDelay > Duration.zero) {
        await Future<void>.delayed(nextDelay);
      }
    }
  }

  throw StateError('Unreachable retry state.');
}

Duration _delayForAttempt({
  required Duration baseDelay,
  required int failedAttempt,
  required BackoffStrategy strategy,
  required double jitter,
  required math.Random random,
}) {
  final multiplier = switch (strategy) {
    BackoffStrategy.constant => 1,
    BackoffStrategy.linear => failedAttempt,
    BackoffStrategy.exponential => math.pow(2, failedAttempt - 1).toInt(),
  };

  final baseMicros = baseDelay.inMicroseconds * multiplier;
  if (jitter == 0 || baseMicros == 0) {
    return Duration(microseconds: baseMicros);
  }

  final jitterRange = (baseMicros * jitter).round();
  final adjustment = random.nextInt(jitterRange * 2 + 1) - jitterRange;
  final jitteredMicros = math.max(0, baseMicros + adjustment);
  return Duration(microseconds: jitteredMicros);
}
