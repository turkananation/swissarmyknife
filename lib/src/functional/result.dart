/// Explicit success and failure values for fallible operations.
///
/// Use [Result] when an operation can fail and callers should handle that
/// failure directly instead of relying on exceptions.
library;

import 'option.dart';
import 'value_equality.dart';

/// Represents either a successful [T] value or a failure [E] value.
///
/// Example:
/// ```dart
/// final result = Result<int, String>.success(42);
/// final label = result.fold((value) => 'ok: $value', (error) => error);
/// ```
sealed class Result<T, E> {
  /// Creates a result base value.
  const Result._();

  /// Creates a successful [Result] containing [value].
  const factory Result.success(T value) = Success<T, E>;

  /// Creates a failed [Result] containing [error].
  const factory Result.failure(E error) = Failure<T, E>;

  /// Runs [action] and captures thrown objects as [Failure] values.
  ///
  /// Example:
  /// ```dart
  /// final parsed = Result.runCatching(() => int.parse('42'));
  /// ```
  static Result<T, Object> runCatching<T>(T Function() action) {
    try {
      return Result<T, Object>.success(action());
    } catch (error) {
      return Result<T, Object>.failure(error);
    }
  }

  /// Runs async [action] and captures thrown objects as [Failure] values.
  ///
  /// Example:
  /// ```dart
  /// final value = await Result.runCatchingAsync(() async => 42);
  /// ```
  static Future<Result<T, Object>> runCatchingAsync<T>(
    Future<T> Function() action,
  ) async {
    try {
      return Result<T, Object>.success(await action());
    } catch (error) {
      return Result<T, Object>.failure(error);
    }
  }

  /// Combines many results into one result containing all success values.
  ///
  /// Returns the first failure immediately.
  ///
  /// Example:
  /// ```dart
  /// final values = Result.combine([
  ///   Result<int, String>.success(1),
  ///   Result<int, String>.success(2),
  /// ]);
  /// ```
  static Result<List<T>, E> combine<T, E>(Iterable<Result<T, E>> results) {
    final values = <T>[];
    for (final result in results) {
      switch (result) {
        case Success<T, E>(:final value):
          values.add(value);
        case Failure<T, E>(:final error):
          return Result<List<T>, E>.failure(error);
      }
    }
    return Result<List<T>, E>.success(values);
  }

  /// Whether this result is a [Success].
  bool get isSuccess;

  /// Whether this result is a [Failure].
  bool get isFailure => !isSuccess;

  /// The success value, or `null` when this is a [Failure].
  T? get valueOrNull;

  /// The failure value, or `null` when this is a [Success].
  E? get errorOrNull;

  /// Pattern matches this result into one return value.
  ///
  /// Example:
  /// ```dart
  /// final text = result.fold((value) => '$value', (error) => 'error');
  /// ```
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure);

  /// Transforms the success value while leaving failures untouched.
  ///
  /// Example:
  /// ```dart
  /// final doubled = Result<int, String>.success(2).map((value) => value * 2);
  /// ```
  Result<R, E> map<R>(R Function(T value) transform) {
    return fold(
      (value) => Result<R, E>.success(transform(value)),
      (error) => Result<R, E>.failure(error),
    );
  }

  /// Chains another result-producing operation after a success.
  ///
  /// Example:
  /// ```dart
  /// final value = Result<int, String>.success(2)
  ///     .flatMap((n) => Result.success(n * 2));
  /// ```
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) {
    return fold(transform, (error) => Result<R, E>.failure(error));
  }

  /// Transforms the failure value while leaving successes untouched.
  ///
  /// Example:
  /// ```dart
  /// final result = Result<int, String>.failure('bad')
  ///     .mapError((error) => error.length);
  /// ```
  Result<T, F> mapError<F>(F Function(E error) transform) {
    return fold(
      (value) => Result<T, F>.success(value),
      (error) => Result<T, F>.failure(transform(error)),
    );
  }

  /// Returns the success value or [defaultValue] for failures.
  ///
  /// Example:
  /// ```dart
  /// final value = Result<int, String>.failure('bad').getOrElse(0);
  /// ```
  T getOrElse(T defaultValue) {
    return fold((value) => value, (_) => defaultValue);
  }

  /// Returns the success value or throws the failure value.
  ///
  /// If the failure value is `null`, a [StateError] is thrown instead.
  ///
  /// Example:
  /// ```dart
  /// final value = Result<int, String>.success(1).getOrThrow();
  /// ```
  T getOrThrow() {
    return fold((value) => value, (error) {
      if (error case final Object object) {
        throw object;
      }
      throw StateError('Cannot throw a null failure value.');
    });
  }

  /// Converts this result to an [Option], dropping any failure value.
  ///
  /// Example:
  /// ```dart
  /// final option = Result<int, String>.success(1).toOption();
  /// ```
  Option<T> toOption() {
    return fold((value) => Option<T>.some(value), (_) => Option<T>.none());
  }
}

/// A successful [Result] containing [value].
///
/// Example:
/// ```dart
/// const success = Success<int, String>(1);
/// ```
final class Success<T, E> extends Result<T, E> {
  /// Creates a successful result with [value].
  const Success(this.value) : super._();

  /// The successful value.
  final T value;

  @override
  bool get isSuccess => true;

  @override
  T? get valueOrNull => value;

  @override
  E? get errorOrNull => null;

  @override
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) {
    return onSuccess(value);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Success<T, E> && functionalValuesEqual(other.value, value);
  }

  @override
  int get hashCode => Object.hash(Success, functionalValueHash(value));

  @override
  String toString() => 'Result.success($value)';
}

/// A failed [Result] containing [error].
///
/// Example:
/// ```dart
/// const failure = Failure<int, String>('bad input');
/// ```
final class Failure<T, E> extends Result<T, E> {
  /// Creates a failed result with [error].
  const Failure(this.error) : super._();

  /// The failure value.
  final E error;

  @override
  bool get isSuccess => false;

  @override
  T? get valueOrNull => null;

  @override
  E? get errorOrNull => error;

  @override
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) {
    return onFailure(error);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Failure<T, E> && functionalValuesEqual(other.error, error);
  }

  @override
  int get hashCode => Object.hash(Failure, functionalValueHash(error));

  @override
  String toString() => 'Result.failure($error)';
}
