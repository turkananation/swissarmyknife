/// Extension methods on collections (Iterable, List).
///
/// Contains grouping, sorting, zipping, partitioning, rotation, sampling,
/// interleaving, index-based iteration, and null filtering.
library;

import 'dart:math' as math;

/// Extensions on [Iterable] to provide fluent aggregate and query methods.
///
/// Example:
/// ```dart
/// final numbers = [1, 2, 3, 4];
/// final chunks = numbers.chunk(2); // [[1, 2], [3, 4]]
/// ```
extension IterableKnife<T> on Iterable<T> {
  /// Groups elements by a key selector [key].
  ///
  /// Example:
  /// ```dart
  /// final list = ['apple', 'apricot', 'banana'];
  /// final grouped = list.groupBy((s) => s[0]); // {'a': ['apple', 'apricot'], 'b': ['banana']}
  /// ```
  Map<K, List<T>> groupBy<K>(K Function(T element) key) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final k = key(element);
      map.putIfAbsent(k, () => <T>[]).add(element);
    }
    return map;
  }

  /// Returns a sorted list of elements based on a comparable key selector [key].
  ///
  /// This operation is non-mutating (returns a new list).
  ///
  /// Example:
  /// ```dart
  /// final list = ['banana', 'apple', 'cherry'];
  /// final sorted = list.sortedBy((s) => s.length); // ['apple', 'banana', 'cherry']
  /// ```
  List<T> sortedBy<K extends Comparable>(K Function(T element) key) {
    final list = toList();
    list.sort((a, b) => key(a).compareTo(key(b)));
    return list;
  }

  /// Returns a descending-sorted list of elements based on a comparable key selector [key].
  ///
  /// This operation is non-mutating (returns a new list).
  ///
  /// Example:
  /// ```dart
  /// final list = ['apple', 'cherry', 'banana'];
  /// final sorted = list.sortedByDescending((s) => s.length); // ['cherry', 'banana', 'apple']
  /// ```
  List<T> sortedByDescending<K extends Comparable>(K Function(T element) key) {
    final list = toList();
    list.sort((a, b) => key(b).compareTo(key(a)));
    return list;
  }

  /// Returns a list containing only unique elements according to a key selector [key].
  ///
  /// Example:
  /// ```dart
  /// final list = ['apple', 'apricot', 'banana'];
  /// final distinct = list.distinctBy((s) => s[0]); // ['apple', 'banana']
  /// ```
  List<T> distinctBy<K>(K Function(T element) key) {
    final set = <K>{};
    final list = <T>[];
    for (final element in this) {
      final k = key(element);
      if (set.add(k)) {
        list.add(element);
      }
    }
    return list;
  }

  /// Splits this iterable into chunks of size [size].
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// print(list.chunk(2)); // [[1, 2], [3, 4], [5]]
  /// ```
  List<List<T>> chunk(int size) {
    if (size <= 0) {
      throw ArgumentError('Size must be greater than zero.');
    }
    final chunks = <List<T>>[];
    var currentChunk = <T>[];
    for (final element in this) {
      currentChunk.add(element);
      if (currentChunk.length == size) {
        chunks.add(currentChunk);
        currentChunk = <T>[];
      }
    }
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }
    return chunks;
  }

  /// Finds the first element satisfying [test], or returns `null`.
  ///
  /// Example:
  /// ```dart
  /// final val = [1, 2, 3].firstWhereOrNull((x) => x > 5); // null
  /// ```
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Finds the last element satisfying [test], or returns `null`.
  ///
  /// Example:
  /// ```dart
  /// final val = [1, 2, 3].lastWhereOrNull((x) => x > 1); // 3
  /// ```
  T? lastWhereOrNull(bool Function(T element) test) {
    T? result;
    for (final element in this) {
      if (test(element)) result = element;
    }
    return result;
  }

  /// Partitions the collection into a record of two lists:
  /// `(matching, notMatching)` based on [test].
  ///
  /// Example:
  /// ```dart
  /// final (evens, odds) = [1, 2, 3, 4].partition((x) => x.isEven);
  /// ```
  (List<T> matching, List<T> notMatching) partition(
    bool Function(T element) test,
  ) {
    final matching = <T>[];
    final notMatching = <T>[];
    for (final element in this) {
      if (test(element)) {
        matching.add(element);
      } else {
        notMatching.add(element);
      }
    }
    return (matching, notMatching);
  }

  /// Counts the frequency of each element in this collection.
  ///
  /// Example:
  /// ```dart
  /// final freq = ['a', 'b', 'a'].frequencyMap(); // {'a': 2, 'b': 1}
  /// ```
  Map<T, int> frequencyMap() {
    final map = <T, int>{};
    for (final element in this) {
      map[element] = (map[element] ?? 0) + 1;
    }
    return map;
  }

  /// Returns the element yielding the minimum value for the key selector [key],
  /// or `null` if the collection is empty.
  ///
  /// Example:
  /// ```dart
  /// final list = ['apple', 'banana', 'cherry'];
  /// final min = list.minBy((s) => s.length); // 'apple'
  /// ```
  T? minBy<K extends Comparable>(K Function(T element) key) {
    if (isEmpty) return null;
    T? minElement;
    K? minValue;
    for (final element in this) {
      final val = key(element);
      if (minValue == null || val.compareTo(minValue) < 0) {
        minElement = element;
        minValue = val;
      }
    }
    return minElement;
  }

  /// Returns the element yielding the maximum value for the key selector [key],
  /// or `null` if the collection is empty.
  ///
  /// Example:
  /// ```dart
  /// final list = ['apple', 'banana', 'cherry'];
  /// final max = list.maxBy((s) => s.length); // 'banana' (last wins if tie, or first depending on comparison)
  /// ```
  T? maxBy<K extends Comparable>(K Function(T element) key) {
    if (isEmpty) return null;
    T? maxElement;
    K? maxValue;
    for (final element in this) {
      final val = key(element);
      if (maxValue == null || val.compareTo(maxValue) > 0) {
        maxElement = element;
        maxValue = val;
      }
    }
    return maxElement;
  }

  /// Sums the values returned by the [selector] function for each element.
  ///
  /// Example:
  /// ```dart
  /// final totalLen = ['a', 'bc'].sumBy((s) => s.length); // 3
  /// ```
  num sumBy(num Function(T element) selector) {
    num sum = 0;
    for (final element in this) {
      sum += selector(element);
    }
    return sum;
  }

  /// Computes the average of values returned by [selector], returning `0.0` if empty.
  ///
  /// Example:
  /// ```dart
  /// final avgLen = ['a', 'bc'].averageBy((s) => s.length); // 1.5
  /// ```
  double averageBy(num Function(T element) selector) {
    if (isEmpty) return 0.0;
    return sumBy(selector) / length;
  }

  /// Performs the action [action] on each element along with its index.
  ///
  /// Example:
  /// ```dart
  /// ['a', 'b'].forEachIndexed((index, element) => print('$index: $element'));
  /// ```
  void forEachIndexed(void Function(int index, T element) action) {
    var index = 0;
    for (final element in this) {
      action(index++, element);
    }
  }

  /// Transforms each element along with its index using [transform].
  Iterable<R> mapIndexed<R>(R Function(int index, T element) transform) sync* {
    var index = 0;
    for (final element in this) {
      yield transform(index++, element);
    }
  }

  /// Filters elements along with their index using [test].
  Iterable<T> whereIndexed(bool Function(int index, T element) test) sync* {
    var index = 0;
    for (final element in this) {
      if (test(index++, element)) {
        yield element;
      }
    }
  }

  /// Selects [count] random elements from this collection.
  ///
  /// Example:
  /// ```dart
  /// final randomSublist = [1, 2, 3, 4, 5].sample(count: 2);
  /// ```
  Iterable<T> sample({int count = 1, math.Random? random}) {
    if (count <= 0) return const [];
    final r = random ?? math.Random();
    final list = toList();
    if (list.isEmpty) return const [];
    if (count >= list.length) {
      list.shuffle(r);
      return list;
    }
    list.shuffle(r);
    return list.take(count);
  }

  /// Takes elements while [test] is true, including the first non-matching element.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// final res = list.takeWhileInclusive((x) => x < 3); // [1, 2, 3]
  /// ```
  Iterable<T> takeWhileInclusive(bool Function(T element) test) sync* {
    for (final element in this) {
      yield element;
      if (!test(element)) break;
    }
  }

  /// Inserts [separator] between consecutive elements in this collection.
  ///
  /// Example:
  /// ```dart
  /// final list = ['a', 'b', 'c'].separatedBy('-'); // ['a', '-', 'b', '-', 'c']
  /// ```
  Iterable<T> separatedBy(T separator) sync* {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield separator;
        yield iterator.current;
      }
    }
  }

  /// Checks if this collection contains any of the specified [elements].
  bool containsAny(Iterable<T> elements) {
    final set = elements.toSet();
    return any((element) => set.contains(element));
  }
}

/// Extensions on [List] to provide list-specific utility methods.
extension ListKnife<T> on List<T> {
  /// Combines this list and [other] list pairwise using a [combine] function.
  ///
  /// The resulting list's length is equal to the shorter list.
  ///
  /// Example:
  /// ```dart
  /// final joined = [1, 2].zipWith(['a', 'b'], (n, s) => '$n$s'); // ['1a', '2b']
  /// ```
  List<R> zipWith<R, U>(List<U> other, R Function(T a, U b) combine) {
    final length = math.min(this.length, other.length);
    final result = <R>[];
    for (var i = 0; i < length; i++) {
      result.add(combine(this[i], other[i]));
    }
    return result;
  }

  /// Zips this list with [other] list, returning a list of record pairs.
  ///
  /// The resulting list's length is equal to the shorter list.
  ///
  /// Example:
  /// ```dart
  /// final zipped = [1, 2].zip(['a', 'b']); // [(1, 'a'), (2, 'b')]
  /// ```
  List<(T, U)> zip<U>(List<U> other) {
    final length = math.min(this.length, other.length);
    final result = <(T, U)>[];
    for (var i = 0; i < length; i++) {
      result.add((this[i], other[i]));
    }
    return result;
  }

  /// Rotates elements of this list by [positions] steps.
  ///
  /// Positive [positions] shifts elements right, negative shifts left.
  ///
  /// Example:
  /// ```dart
  /// final rotated = [1, 2, 3, 4].rotate(1); // [4, 1, 2, 3]
  /// ```
  List<T> rotate(int positions) {
    if (isEmpty) return toList();
    final len = length;
    var shift = positions % len;
    if (shift < 0) shift += len;
    if (shift == 0) return toList();
    return [...sublist(len - shift), ...sublist(0, len - shift)];
  }

  /// Alternates elements of this list with elements from [other].
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2].interleave([3, 4, 5]); // [1, 3, 2, 4, 5]
  /// ```
  List<T> interleave(List<T> other) {
    final result = <T>[];
    final maxLen = math.max(length, other.length);
    for (var i = 0; i < maxLen; i++) {
      if (i < length) {
        result.add(this[i]);
      }
      if (i < other.length) {
        result.add(other[i]);
      }
    }
    return result;
  }

  /// Shuffles elements of this list without modifying the original.
  List<T> shuffled({math.Random? random}) {
    final list = toList();
    list.shuffle(random ?? math.Random());
    return list;
  }
}

/// Extension on nested iterables to allow flattening.
extension IterableFlatten<T> on Iterable<Iterable<T>> {
  /// Flattens a nested iterable sequence one level.
  ///
  /// Example:
  /// ```dart
  /// final nested = [[1, 2], [3]];
  /// print(nested.flatten().toList()); // [1, 2, 3]
  /// ```
  Iterable<T> flatten() sync* {
    for (final sublist in this) {
      yield* sublist;
    }
  }
}

/// Extension on nullable collections to filter out null values.
extension IterableCompact<T> on Iterable<T?> {
  /// Removes all null elements from this collection and returns typed non-nulls.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, null, 2].compact(); // [1, 2]
  /// ```
  Iterable<T> compact() {
    return where((element) => element != null).cast<T>();
  }
}
