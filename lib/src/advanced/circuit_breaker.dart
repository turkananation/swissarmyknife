/// Circuit breaker for isolating repeatedly failing operations.
///
/// Use [CircuitBreaker] around remote calls or expensive operations where
/// repeated failures should temporarily fail fast before probing for recovery.
library;

import 'dart:async';

import '../functional/result.dart';

/// Circuit breaker state.
enum CircuitBreakerState {
  /// Calls pass through until failure threshold is reached.
  closed,

  /// Calls fail fast until cooldown expires.
  open,

  /// Limited probe calls are allowed to determine recovery.
  halfOpen,
}

/// Base type for circuit breaker failures.
sealed class CircuitBreakerError {
  const CircuitBreakerError({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// Human-readable failure message.
  final String message;

  /// Original thrown object, when available.
  final Object? cause;

  /// Stack trace for thrown failures, when available.
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

/// Failure returned when the breaker is open and not ready for a probe.
final class CircuitBreakerOpenError extends CircuitBreakerError {
  /// Creates an open-circuit failure.
  const CircuitBreakerOpenError({required this.nextAttemptAt})
    : super(message: 'Circuit breaker is open until $nextAttemptAt.');

  /// Time at which a half-open probe may be attempted.
  final DateTime nextAttemptAt;
}

/// Failure returned when the protected action throws.
final class CircuitBreakerExecutionError extends CircuitBreakerError {
  /// Creates an execution failure.
  const CircuitBreakerExecutionError({
    required super.cause,
    required super.stackTrace,
  }) : super(message: 'Circuit breaker action failed: $cause.');
}

/// Protects operations with closed/open/half-open circuit states.
final class CircuitBreaker {
  /// Creates a circuit breaker.
  CircuitBreaker({
    this.failureThreshold = 3,
    this.successThreshold = 1,
    this.openTimeout = const Duration(seconds: 30),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    if (failureThreshold <= 0) {
      throw ArgumentError.value(
        failureThreshold,
        'failureThreshold',
        'Must be positive.',
      );
    }
    if (successThreshold <= 0) {
      throw ArgumentError.value(
        successThreshold,
        'successThreshold',
        'Must be positive.',
      );
    }
    if (openTimeout <= Duration.zero) {
      throw ArgumentError.value(
        openTimeout,
        'openTimeout',
        'Must be positive.',
      );
    }
  }

  /// Failures needed to open the circuit from [CircuitBreakerState.closed].
  final int failureThreshold;

  /// Successes needed to close the circuit from [CircuitBreakerState.halfOpen].
  final int successThreshold;

  /// Cooldown before open circuit allows a half-open probe.
  final Duration openTimeout;

  final DateTime Function() _clock;

  CircuitBreakerState _state = CircuitBreakerState.closed;
  int _failureCount = 0;
  int _successCount = 0;
  DateTime? _openedAt;
  DateTime? _nextAttemptAt;
  Object? _lastError;

  /// Current circuit state.
  CircuitBreakerState get state => _state;

  /// Consecutive failure count in the current closed window.
  int get failureCount => _failureCount;

  /// Consecutive half-open success count.
  int get successCount => _successCount;

  /// Time the circuit last opened.
  DateTime? get openedAt => _openedAt;

  /// Time at which a half-open probe may be attempted.
  DateTime? get nextAttemptAt => _nextAttemptAt;

  /// Last thrown object captured from a protected action.
  Object? get lastError => _lastError;

  /// Whether an action can be attempted at the current time.
  bool get canAttempt {
    if (_state != CircuitBreakerState.open) return true;
    final nextAttempt = _nextAttemptAt;
    return nextAttempt != null && !_clock().isBefore(nextAttempt);
  }

  /// Executes [action] if the circuit allows it.
  Future<Result<T, CircuitBreakerError>> execute<T>(
    FutureOr<T> Function() action,
  ) async {
    if (_state == CircuitBreakerState.open) {
      if (!canAttempt) {
        return Result<T, CircuitBreakerError>.failure(
          CircuitBreakerOpenError(nextAttemptAt: _nextAttemptAt!),
        );
      }
      _state = CircuitBreakerState.halfOpen;
      _successCount = 0;
    }

    try {
      final value = await action();
      _recordSuccess();
      return Result<T, CircuitBreakerError>.success(value);
    } catch (error, stackTrace) {
      _recordFailure(error);
      return Result<T, CircuitBreakerError>.failure(
        CircuitBreakerExecutionError(cause: error, stackTrace: stackTrace),
      );
    }
  }

  /// Resets the circuit to closed and clears counters.
  void reset() {
    _state = CircuitBreakerState.closed;
    _failureCount = 0;
    _successCount = 0;
    _openedAt = null;
    _nextAttemptAt = null;
    _lastError = null;
  }

  /// Forces the circuit open immediately.
  void forceOpen() {
    _open();
  }

  /// Forces the circuit closed and clears counters.
  void forceClosed() {
    reset();
  }

  void _recordSuccess() {
    _lastError = null;
    if (_state == CircuitBreakerState.halfOpen) {
      _successCount++;
      if (_successCount >= successThreshold) {
        reset();
      }
      return;
    }

    _failureCount = 0;
  }

  void _recordFailure(Object error) {
    _lastError = error;
    if (_state == CircuitBreakerState.halfOpen) {
      _open();
      return;
    }

    _failureCount++;
    if (_failureCount >= failureThreshold) {
      _open();
    }
  }

  void _open() {
    final now = _clock();
    _state = CircuitBreakerState.open;
    _openedAt = now;
    _nextAttemptAt = now.add(openTimeout);
    _successCount = 0;
  }
}
