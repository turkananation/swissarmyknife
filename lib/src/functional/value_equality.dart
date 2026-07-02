/// Internal structural equality helpers for functional value objects.
///
/// These helpers keep wrapper equality useful when values contain Dart
/// collections, whose default equality is identity-based.
library;

/// Compares two values using structural equality for maps, sets, and iterables.
///
/// Example:
/// ```dart
/// functionalValuesEqual([1, 2], [1, 2]); // true
/// ```
bool functionalValuesEqual(Object? left, Object? right) {
  if (identical(left, right)) return true;

  if (left is Map && right is Map) {
    return _mapsEqual(left, right);
  }
  if (left is Set && right is Set) {
    return _setsEqual(left, right);
  }
  if (left is Iterable && right is Iterable) {
    return _iterablesEqual(left, right);
  }

  return left == right;
}

/// Returns a hash code compatible with [functionalValuesEqual].
///
/// Example:
/// ```dart
/// functionalValueHash([1, 2]) == functionalValueHash([1, 2]); // true
/// ```
int functionalValueHash(Object? value) {
  if (value == null) return 0;

  if (value is Map) {
    var hash = 0;
    for (final entry in value.entries) {
      hash ^= Object.hash(
        functionalValueHash(entry.key),
        functionalValueHash(entry.value),
      );
    }
    return Object.hash(Map, value.length, hash);
  }

  if (value is Set) {
    var hash = 0;
    for (final element in value) {
      hash ^= functionalValueHash(element);
    }
    return Object.hash(Set, value.length, hash);
  }

  if (value is Iterable) {
    var count = 0;
    var hash = 0;
    for (final element in value) {
      hash = Object.hash(hash, functionalValueHash(element));
      count++;
    }
    return Object.hash(Iterable, count, hash);
  }

  return value.hashCode;
}

bool _mapsEqual(Map<Object?, Object?> left, Map<Object?, Object?> right) {
  if (left.length != right.length) return false;

  final matched = <Object?>{};
  for (final leftEntry in left.entries) {
    var found = false;
    for (final rightEntry in right.entries) {
      if (matched.contains(rightEntry.key)) continue;
      if (!functionalValuesEqual(leftEntry.key, rightEntry.key)) continue;
      if (!functionalValuesEqual(leftEntry.value, rightEntry.value)) {
        return false;
      }
      matched.add(rightEntry.key);
      found = true;
      break;
    }
    if (!found) return false;
  }

  return true;
}

bool _setsEqual(Set<Object?> left, Set<Object?> right) {
  if (left.length != right.length) return false;

  final rightValues = right.toList();
  final matchedIndexes = <int>{};
  for (final leftValue in left) {
    var found = false;
    for (var i = 0; i < rightValues.length; i++) {
      if (matchedIndexes.contains(i)) continue;
      if (!functionalValuesEqual(leftValue, rightValues[i])) continue;
      matchedIndexes.add(i);
      found = true;
      break;
    }
    if (!found) return false;
  }

  return true;
}

bool _iterablesEqual(Iterable<Object?> left, Iterable<Object?> right) {
  final leftIterator = left.iterator;
  final rightIterator = right.iterator;

  while (true) {
    final hasLeft = leftIterator.moveNext();
    final hasRight = rightIterator.moveNext();
    if (hasLeft != hasRight) return false;
    if (!hasLeft) return true;
    if (!functionalValuesEqual(leftIterator.current, rightIterator.current)) {
      return false;
    }
  }
}
