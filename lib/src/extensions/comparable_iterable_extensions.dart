/// Library-level comment for comparable iterable extensions.
///
/// Contains extensions on collections of comparable elements to determine
/// sorting order (ascending/descending) and extract the min/max value range.
library;

/// Extensions on [Iterable] of [Comparable] elements to provide order and range checks.
///
/// Example:
/// ```dart
/// final list = [1, 5, 3];
/// print(list.isSorted); // false
/// print(list.range); // (1, 5)
/// ```
extension ComparableIterableKnife<T extends Comparable<T>> on Iterable<T> {
  /// Checks if the elements in this collection are in non-descending (ascending) order.
  ///
  /// Returns `true` if the collection is empty or contains a single element.
  ///
  /// Example:
  /// ```dart
  /// print([1, 2, 2, 3].isSorted); // true
  /// print([1, 3, 2].isSorted); // false
  /// ```
  bool get isSorted {
    if (isEmpty) return true;
    final iterator = this.iterator;
    if (!iterator.moveNext()) return true;
    var previous = iterator.current;
    while (iterator.moveNext()) {
      final current = iterator.current;
      if (previous.compareTo(current) > 0) return false;
      previous = current;
    }
    return true;
  }

  /// Checks if the elements in this collection are in non-ascending (descending) order.
  ///
  /// Returns `true` if the collection is empty or contains a single element.
  ///
  /// Example:
  /// ```dart
  /// print([3, 2, 2, 1].isSortedDescending); // true
  /// print([3, 1, 2].isSortedDescending); // false
  /// ```
  bool get isSortedDescending {
    if (isEmpty) return true;
    final iterator = this.iterator;
    if (!iterator.moveNext()) return true;
    var previous = iterator.current;
    while (iterator.moveNext()) {
      final current = iterator.current;
      if (previous.compareTo(current) < 0) return false;
      previous = current;
    }
    return true;
  }

  /// Returns a record of `(min, max)` elements from this collection.
  ///
  /// Throws a [StateError] if the collection is empty.
  ///
  /// Example:
  /// ```dart
  /// final range = [10, 5, 20, 15].range;
  /// print(range); // (5, 20)
  /// ```
  (T, T) get range {
    if (isEmpty) {
      throw StateError('Cannot determine range of an empty collection.');
    }
    final iterator = this.iterator;
    iterator.moveNext();
    var min = iterator.current;
    var max = iterator.current;
    while (iterator.moveNext()) {
      final current = iterator.current;
      if (current.compareTo(min) < 0) {
        min = current;
      }
      if (current.compareTo(max) > 0) {
        max = current;
      }
    }
    return (min, max);
  }
}
