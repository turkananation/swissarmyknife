/// Dual-typed values for APIs that can return one of two value families.
///
/// Use [Either] when both sides are meaningful domain values and callers
/// should choose how to handle each side.
library;

import 'result.dart';
import 'value_equality.dart';

/// Represents either a left [L] value or a right [R] value.
///
/// By convention, [Right] is commonly used for success and [Left] for the
/// alternative path, but both sides are plain values.
///
/// Example:
/// ```dart
/// final value = Either<String, int>.right(42);
/// final text = value.fold((error) => error, (number) => '$number');
/// ```
sealed class Either<L, R> {
  /// Creates an either base value.
  const Either._();

  /// Creates a left value.
  const factory Either.left(L value) = Left<L, R>;

  /// Creates a right value.
  const factory Either.right(R value) = Right<L, R>;

  /// Whether this either contains a left value.
  bool get isLeft;

  /// Whether this either contains a right value.
  bool get isRight => !isLeft;

  /// The left value, or `null` when this is [Right].
  L? get leftOrNull;

  /// The right value, or `null` when this is [Left].
  R? get rightOrNull;

  /// Pattern matches this either into one return value.
  ///
  /// Example:
  /// ```dart
  /// final label = either.fold((left) => 'left', (right) => 'right');
  /// ```
  T fold<T>(T Function(L value) onLeft, T Function(R value) onRight);

  /// Transforms the left value while leaving right values untouched.
  ///
  /// Example:
  /// ```dart
  /// final value = Either<String, int>.left('bad')
  ///     .mapLeft((error) => error.length);
  /// ```
  Either<T, R> mapLeft<T>(T Function(L value) transform) {
    return fold(
      (value) => Either<T, R>.left(transform(value)),
      (value) => Either<T, R>.right(value),
    );
  }

  /// Transforms the right value while leaving left values untouched.
  ///
  /// Example:
  /// ```dart
  /// final value = Either<String, int>.right(2).mapRight((n) => n * 2);
  /// ```
  Either<L, T> mapRight<T>(T Function(R value) transform) {
    return fold(
      (value) => Either<L, T>.left(value),
      (value) => Either<L, T>.right(transform(value)),
    );
  }

  /// Chains another right-producing either operation.
  ///
  /// Example:
  /// ```dart
  /// final value = Either<String, int>.right(2)
  ///     .flatMap((n) => Either.right(n * 2));
  /// ```
  Either<L, T> flatMap<T>(Either<L, T> Function(R value) transform) {
    return fold((value) => Either<L, T>.left(value), transform);
  }

  /// Swaps left and right values.
  ///
  /// Example:
  /// ```dart
  /// final swapped = Either<String, int>.left('bad').swap();
  /// ```
  Either<R, L> swap() {
    return fold(
      (value) => Either<R, L>.right(value),
      (value) => Either<R, L>.left(value),
    );
  }

  /// Returns the left value or [defaultValue] for right values.
  ///
  /// Example:
  /// ```dart
  /// final error = Either<String, int>.right(1).getLeftOrElse('none');
  /// ```
  L getLeftOrElse(L defaultValue) {
    return fold((value) => value, (_) => defaultValue);
  }

  /// Returns the right value or [defaultValue] for left values.
  ///
  /// Example:
  /// ```dart
  /// final value = Either<String, int>.left('bad').getRightOrElse(0);
  /// ```
  R getRightOrElse(R defaultValue) {
    return fold((_) => defaultValue, (value) => value);
  }

  /// Converts this either to a [Result].
  ///
  /// Left values become failures, and right values become successes.
  ///
  /// Example:
  /// ```dart
  /// final result = Either<String, int>.right(1).toResult();
  /// ```
  Result<R, L> toResult() {
    return fold(
      (value) => Result<R, L>.failure(value),
      (value) => Result<R, L>.success(value),
    );
  }
}

/// The left side of an [Either].
///
/// Example:
/// ```dart
/// const left = Left<String, int>('missing');
/// ```
final class Left<L, R> extends Either<L, R> {
  /// Creates a left value.
  const Left(this.value) : super._();

  /// The contained left value.
  final L value;

  @override
  bool get isLeft => true;

  @override
  L? get leftOrNull => value;

  @override
  R? get rightOrNull => null;

  @override
  T fold<T>(T Function(L value) onLeft, T Function(R value) onRight) {
    return onLeft(value);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Left<L, R> && functionalValuesEqual(other.value, value);
  }

  @override
  int get hashCode => Object.hash(Left, functionalValueHash(value));

  @override
  String toString() => 'Either.left($value)';
}

/// The right side of an [Either].
///
/// Example:
/// ```dart
/// const right = Right<String, int>(1);
/// ```
final class Right<L, R> extends Either<L, R> {
  /// Creates a right value.
  const Right(this.value) : super._();

  /// The contained right value.
  final R value;

  @override
  bool get isLeft => false;

  @override
  L? get leftOrNull => null;

  @override
  R? get rightOrNull => value;

  @override
  T fold<T>(T Function(L value) onLeft, T Function(R value) onRight) {
    return onRight(value);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Right<L, R> && functionalValuesEqual(other.value, value);
  }

  @override
  int get hashCode => Object.hash(Right, functionalValueHash(value));

  @override
  String toString() => 'Either.right($value)';
}
