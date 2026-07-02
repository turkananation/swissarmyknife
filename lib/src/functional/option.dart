/// Optional values that make absence explicit.
///
/// Use [Option] when a value may be present or absent and `null` would hide
/// intent at the call site.
library;

import 'result.dart';
import 'value_equality.dart';

/// Represents either a present [T] value or no value.
///
/// Example:
/// ```dart
/// final option = Option.fromNullable('Ada');
/// final label = option.fold((name) => name, () => 'Unknown');
/// ```
sealed class Option<T> {
  /// Creates an option base value.
  const Option._();

  /// Creates an option containing [value].
  const factory Option.some(T value) = Some<T>;

  /// Creates an option containing no value.
  const factory Option.none() = None<T>;

  /// Creates [Some] when [value] is non-null, otherwise [None].
  ///
  /// Example:
  /// ```dart
  /// final option = Option.fromNullable(possiblyNull);
  /// ```
  factory Option.fromNullable(T? value) {
    if (value == null) return Option<T>.none();
    return Option<T>.some(value);
  }

  /// Whether this option contains a value.
  bool get isSome;

  /// Whether this option contains no value.
  bool get isNone => !isSome;

  /// The contained value, or `null` when this is [None].
  T? get valueOrNull;

  /// Pattern matches this option into one return value.
  ///
  /// Example:
  /// ```dart
  /// final text = option.fold((value) => '$value', () => 'empty');
  /// ```
  R fold<R>(R Function(T value) onSome, R Function() onNone);

  /// Transforms the contained value when present.
  ///
  /// Example:
  /// ```dart
  /// final doubled = Option.some(2).map((value) => value * 2);
  /// ```
  Option<R> map<R>(R Function(T value) transform) {
    return fold(
      (value) => Option<R>.some(transform(value)),
      () => Option<R>.none(),
    );
  }

  /// Chains another option-producing operation when a value is present.
  ///
  /// Example:
  /// ```dart
  /// final parsed = Option.some('42').flatMap(
  ///   (text) => Option.fromNullable(int.tryParse(text)),
  /// );
  /// ```
  Option<R> flatMap<R>(Option<R> Function(T value) transform) {
    return fold(transform, () => Option<R>.none());
  }

  /// Keeps the value only when [test] returns true.
  ///
  /// Example:
  /// ```dart
  /// final positive = Option.some(3).filter((value) => value > 0);
  /// ```
  Option<T> filter(bool Function(T value) test) {
    return fold(
      (value) => test(value) ? this : Option<T>.none(),
      () => Option<T>.none(),
    );
  }

  /// Returns the contained value or [defaultValue] when absent.
  ///
  /// Example:
  /// ```dart
  /// final name = Option<String>.none().getOrElse('Unknown');
  /// ```
  T getOrElse(T defaultValue) {
    return fold((value) => value, () => defaultValue);
  }

  /// Returns the contained value or throws a [StateError] when absent.
  ///
  /// Example:
  /// ```dart
  /// final value = Option.some(1).getOrThrow();
  /// ```
  T getOrThrow() {
    return fold((value) => value, () => throw StateError('Option is none.'));
  }

  /// Converts this option to a [Result], using [error] for [None].
  ///
  /// Example:
  /// ```dart
  /// final result = Option.some(1).toResult('missing');
  /// ```
  Result<T, E> toResult<E>(E error) {
    return fold(
      (value) => Result<T, E>.success(value),
      () => Result<T, E>.failure(error),
    );
  }

  /// Combines two present options into one option containing a record.
  ///
  /// Example:
  /// ```dart
  /// final zipped = Option.some(1).zip(Option.some('one'));
  /// ```
  Option<(T, U)> zip<U>(Option<U> other) {
    return flatMap((value) => other.map((otherValue) => (value, otherValue)));
  }
}

/// An [Option] containing [value].
///
/// Example:
/// ```dart
/// const value = Some(1);
/// ```
final class Some<T> extends Option<T> {
  /// Creates an option containing [value].
  const Some(this.value) : super._();

  /// The contained value.
  final T value;

  @override
  bool get isSome => true;

  @override
  T? get valueOrNull => value;

  @override
  R fold<R>(R Function(T value) onSome, R Function() onNone) {
    return onSome(value);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Some<T> && functionalValuesEqual(other.value, value);
  }

  @override
  int get hashCode => Object.hash(Some, functionalValueHash(value));

  @override
  String toString() => 'Option.some($value)';
}

/// An [Option] containing no value.
///
/// Example:
/// ```dart
/// const empty = None<int>();
/// ```
final class None<T> extends Option<T> {
  /// Creates an option containing no value.
  const None() : super._();

  @override
  bool get isSome => false;

  @override
  T? get valueOrNull => null;

  @override
  R fold<R>(R Function(T value) onSome, R Function() onNone) {
    return onNone();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is None<T>;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Option.none()';
}
