/// Small immutable tuple value objects.
///
/// Use [Pair] and [Triple] when a lightweight named container is clearer than
/// passing loosely related records through multiple APIs.
library;

import 'value_equality.dart';

/// A two-value immutable tuple.
///
/// Example:
/// ```dart
/// final pair = Pair('id', 42);
/// final record = pair.toRecord();
/// ```
final class Pair<A, B> {
  /// Creates a pair containing [first] and [second].
  const Pair(this.first, this.second);

  /// Creates a pair from a record.
  ///
  /// Example:
  /// ```dart
  /// final pair = Pair.fromRecord(('id', 42));
  /// ```
  factory Pair.fromRecord((A, B) record) {
    return Pair(record.$1, record.$2);
  }

  /// The first value.
  final A first;

  /// The second value.
  final B second;

  /// Transforms [first] while preserving [second].
  ///
  /// Example:
  /// ```dart
  /// final pair = Pair(1, 'a').mapFirst((value) => value + 1);
  /// ```
  Pair<R, B> mapFirst<R>(R Function(A value) transform) {
    return Pair(transform(first), second);
  }

  /// Transforms [second] while preserving [first].
  ///
  /// Example:
  /// ```dart
  /// final pair = Pair(1, 'a').mapSecond((value) => value.toUpperCase());
  /// ```
  Pair<A, R> mapSecond<R>(R Function(B value) transform) {
    return Pair(first, transform(second));
  }

  /// Converts this pair to a positional record.
  ///
  /// Example:
  /// ```dart
  /// final (key, value) = Pair('id', 42).toRecord();
  /// ```
  (A, B) toRecord() => (first, second);

  /// Converts this pair to a list.
  ///
  /// Example:
  /// ```dart
  /// final values = Pair('id', 42).toList();
  /// ```
  List<Object?> toList() => [first, second];

  /// Converts this pair to a named map.
  ///
  /// Example:
  /// ```dart
  /// final map = Pair('id', 42).toMap();
  /// ```
  Map<String, Object?> toMap() => {'first': first, 'second': second};

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Pair<A, B> &&
            functionalValuesEqual(other.first, first) &&
            functionalValuesEqual(other.second, second);
  }

  @override
  int get hashCode =>
      Object.hash(functionalValueHash(first), functionalValueHash(second));

  @override
  String toString() => 'Pair($first, $second)';
}

/// A three-value immutable tuple.
///
/// Example:
/// ```dart
/// final triple = Triple('x', 1, true);
/// final values = triple.toList();
/// ```
final class Triple<A, B, C> {
  /// Creates a triple containing [first], [second], and [third].
  const Triple(this.first, this.second, this.third);

  /// Creates a triple from a record.
  ///
  /// Example:
  /// ```dart
  /// final triple = Triple.fromRecord(('x', 1, true));
  /// ```
  factory Triple.fromRecord((A, B, C) record) {
    return Triple(record.$1, record.$2, record.$3);
  }

  /// The first value.
  final A first;

  /// The second value.
  final B second;

  /// The third value.
  final C third;

  /// Transforms [first] while preserving [second] and [third].
  ///
  /// Example:
  /// ```dart
  /// final triple = Triple(1, 2, 3).mapFirst((value) => value + 1);
  /// ```
  Triple<R, B, C> mapFirst<R>(R Function(A value) transform) {
    return Triple(transform(first), second, third);
  }

  /// Transforms [second] while preserving [first] and [third].
  ///
  /// Example:
  /// ```dart
  /// final triple = Triple(1, 'a', true)
  ///     .mapSecond((value) => value.toUpperCase());
  /// ```
  Triple<A, R, C> mapSecond<R>(R Function(B value) transform) {
    return Triple(first, transform(second), third);
  }

  /// Transforms [third] while preserving [first] and [second].
  ///
  /// Example:
  /// ```dart
  /// final triple = Triple(1, 2, '3').mapThird(int.parse);
  /// ```
  Triple<A, B, R> mapThird<R>(R Function(C value) transform) {
    return Triple(first, second, transform(third));
  }

  /// Converts this triple to a positional record.
  ///
  /// Example:
  /// ```dart
  /// final (a, b, c) = Triple('x', 1, true).toRecord();
  /// ```
  (A, B, C) toRecord() => (first, second, third);

  /// Converts this triple to a list.
  ///
  /// Example:
  /// ```dart
  /// final values = Triple('x', 1, true).toList();
  /// ```
  List<Object?> toList() => [first, second, third];

  /// Converts this triple to a named map.
  ///
  /// Example:
  /// ```dart
  /// final map = Triple('x', 1, true).toMap();
  /// ```
  Map<String, Object?> toMap() => {
    'first': first,
    'second': second,
    'third': third,
  };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Triple<A, B, C> &&
            functionalValuesEqual(other.first, first) &&
            functionalValuesEqual(other.second, second) &&
            functionalValuesEqual(other.third, third);
  }

  @override
  int get hashCode => Object.hash(
    functionalValueHash(first),
    functionalValueHash(second),
    functionalValueHash(third),
  );

  @override
  String toString() => 'Triple($first, $second, $third)';
}
