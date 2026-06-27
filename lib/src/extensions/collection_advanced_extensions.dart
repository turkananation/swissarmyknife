/// Advanced collections, sliding windows, permutations, combinations, and set utilities.
///
/// Contains combinatorial math algorithms, safe indexing, sliding window frames,
/// and non-mutating list operation shorthands.
library;

/// Advanced extensions on [Iterable] for windowing and safe indexing.
extension CollectionAdvancedKnife<T> on Iterable<T> {
  /// Emits a sliding window of elements of the specified [size] and [step].
  ///
  /// If [partialWindows] is true, it yields windows at the end of the collection
  /// even if they contain fewer than [size] elements.
  ///
  /// Example:
  /// ```dart
  /// final windows = [1, 2, 3, 4].slidingWindow(2); // [[1, 2], [2, 3], [3, 4]]
  /// ```
  Iterable<List<T>> slidingWindow(
    int size, {
    int step = 1,
    bool partialWindows = false,
  }) sync* {
    if (size <= 0 || step <= 0) {
      throw ArgumentError('Size and step must be greater than zero.');
    }
    final list = toList();
    if (list.isEmpty) return;

    for (var i = 0; i < list.length; i += step) {
      final end = i + size;
      if (end <= list.length) {
        yield list.sublist(i, end);
      } else if (partialWindows) {
        yield list.sublist(i);
      } else {
        break;
      }
    }
  }

  /// Safely retrieves the element at [index], or returns `null` if out of bounds.
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }

  /// Safely retrieves the element at [index], or returns [defaultValue] if out of bounds.
  T getOrElse(int index, T defaultValue) {
    if (index < 0 || index >= length) return defaultValue;
    return elementAt(index);
  }
}

/// Advanced extensions on [List] for combinatorics, set operations, and non-mutating updates.
extension ListAdvancedKnife<T> on List<T> {
  /// Computes all permutations of elements in this list using Heap's algorithm.
  ///
  /// Example:
  /// ```dart
  /// print([1, 2].permutations().toList()); // [[1, 2], [2, 1]]
  /// ```
  Iterable<List<T>> permutations() sync* {
    if (isEmpty) {
      yield [];
      return;
    }
    final list = toList();
    final n = list.length;
    final c = List<int>.filled(n, 0);

    yield List<T>.from(list);

    var i = 0;
    while (i < n) {
      if (c[i] < i) {
        if (i.isEven) {
          final temp = list[0];
          list[0] = list[i];
          list[i] = temp;
        } else {
          final temp = list[c[i]];
          list[c[i]] = list[i];
          list[i] = temp;
        }
        yield List<T>.from(list);
        c[i] += 1;
        i = 0;
      } else {
        c[i] = 0;
        i += 1;
      }
    }
  }

  /// Computes all combinations of size [k] from elements in this list.
  ///
  /// Example:
  /// ```dart
  /// print([1, 2, 3].combinations(2).toList()); // [[1, 2], [1, 3], [2, 3]]
  /// ```
  Iterable<List<T>> combinations(int k) sync* {
    if (k < 0) throw ArgumentError('k must be non-negative.');
    if (k == 0) {
      yield [];
      return;
    }
    if (k > length) return;

    final list = toList();

    Iterable<List<T>> helper(int start, int depth) sync* {
      if (depth == k) {
        yield [];
        return;
      }
      for (var i = start; i <= list.length - (k - depth); i++) {
        for (final combo in helper(i + 1, depth + 1)) {
          yield [list[i], ...combo];
        }
      }
    }

    yield* helper(0, 0);
  }

  /// Returns a new list containing elements present in both this list and [other].
  List<T> intersection(Iterable<T> other) {
    final otherSet = other.toSet();
    return where((e) => otherSet.contains(e)).toList();
  }

  /// Returns a new list containing unique elements present in either this list or [other].
  List<T> union(Iterable<T> other) {
    final set = toSet()..addAll(other);
    return set.toList();
  }

  /// Returns a new list containing elements present in this list but not in [other].
  List<T> difference(Iterable<T> other) {
    final otherSet = other.toSet();
    return where((e) => !otherSet.contains(e)).toList();
  }

  /// Returns a new list containing elements present in either this list or [other], but not both.
  List<T> symmetricDifference(Iterable<T> other) {
    final thisSet = toSet();
    final otherSet = other.toSet();
    final diff1 = where((e) => !otherSet.contains(e));
    final diff2 = other.where((e) => !thisSet.contains(e));
    return [...diff1, ...diff2];
  }

  /// Non-mutating replacement: returns a copy of this list with [value] at [index].
  List<T> replaceAt(int index, T value) {
    final list = toList();
    list[index] = value;
    return list;
  }

  /// Non-mutating insertion: returns a copy of this list with [value] inserted at [index].
  List<T> insertAt(int index, T value) {
    final list = toList();
    list.insert(index, value);
    return list;
  }

  /// Non-mutating deletion: returns a copy of this list with element at [index] removed.
  List<T> removeAtCopy(int index) {
    final list = toList();
    list.removeAt(index);
    return list;
  }
}
