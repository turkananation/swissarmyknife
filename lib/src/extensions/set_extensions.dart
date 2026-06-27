/// Library-level comment for set extensions.
///
/// Contains advanced set theory operations including symmetric difference,
/// power set, cartesian product, and subset/superset verification.
library;

/// Extensions on [Set] to provide advanced set operations.
///
/// Example:
/// ```dart
/// final a = {1, 2};
/// final b = {2, 3};
/// print(a.symmetricDifference(b)); // {1, 3}
/// ```
extension SetKnife<T> on Set<T> {
  /// Returns the symmetric difference between this set and [other].
  ///
  /// The symmetric difference contains elements that are in either of the sets,
  /// but not in both.
  ///
  /// Example:
  /// ```dart
  /// final a = {1, 2};
  /// final b = {2, 3};
  /// print(a.symmetricDifference(b)); // {1, 3}
  /// ```
  Set<T> symmetricDifference(Set<T> other) {
    return difference(other).union(other.difference(this));
  }

  /// Computes the power set (set of all subsets) of this set.
  ///
  /// Returns `null` if the set has more than 20 elements to prevent
  /// out-of-memory errors.
  ///
  /// Example:
  /// ```dart
  /// final s = {1, 2};
  /// print(s.powerSet()); // {{}, {1}, {2}, {1, 2}}
  /// ```
  Set<Set<T>>? powerSet() {
    if (length > 20) return null;
    final result = <Set<T>>{{}};
    for (final element in this) {
      final nextSubsets = <Set<T>>{};
      for (final subset in result) {
        nextSubsets.add({...subset, element});
      }
      result.addAll(nextSubsets);
    }
    return result;
  }

  /// Computes the Cartesian product of this set and [other].
  ///
  /// Returns a set of 2-tuples (Dart records) containing all combinations of
  /// elements.
  ///
  /// Example:
  /// ```dart
  /// final a = {1, 2};
  /// final b = {'a', 'b'};
  /// print(a.cartesianProduct(b)); // {(1, 'a'), (1, 'b'), (2, 'a'), (2, 'b')}
  /// ```
  Set<(T, U)> cartesianProduct<U>(Set<U> other) {
    final result = <(T, U)>{};
    for (final a in this) {
      for (final b in other) {
        result.add((a, b));
      }
    }
    return result;
  }

  /// Returns `true` if this set is a subset of [other].
  ///
  /// Example:
  /// ```dart
  /// print({1}.isSubsetOf({1, 2})); // true
  /// ```
  bool isSubsetOf(Set<T> other) => other.containsAll(this);

  /// Returns `true` if this set is a superset of [other].
  ///
  /// Example:
  /// ```dart
  /// print({1, 2}.isSupersetOf({1})); // true
  /// ```
  bool isSupersetOf(Set<T> other) => containsAll(other);

  /// Returns `true` if this set is a proper subset of [other].
  ///
  /// A proper subset is a subset that is not equal to the original set.
  ///
  /// Example:
  /// ```dart
  /// print({1}.isProperSubsetOf({1})); // false
  /// print({1}.isProperSubsetOf({1, 2})); // true
  /// ```
  bool isProperSubsetOf(Set<T> other) =>
      length < other.length && isSubsetOf(other);

  /// Returns `true` if this set is a proper superset of [other].
  ///
  /// A proper superset is a superset that is not equal to the original set.
  ///
  /// Example:
  /// ```dart
  /// print({1, 2}.isProperSupersetOf({1})); // true
  /// print({1}.isProperSupersetOf({1})); // false
  /// ```
  bool isProperSupersetOf(Set<T> other) =>
      length > other.length && isSupersetOf(other);

  /// Returns `true` if this set and [other] share no elements.
  ///
  /// Example:
  /// ```dart
  /// print({1}.disjoint({2, 3})); // true
  /// print({1}.disjoint({1, 2})); // false
  /// ```
  bool disjoint(Set<T> other) {
    for (final element in this) {
      if (other.contains(element)) {
        return false;
      }
    }
    return true;
  }
}
