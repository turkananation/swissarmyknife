/// Library-level comment for MapEntry extensions.
///
/// Contains extensions on MapEntry to swap keys and values, convert entries to records,
/// and map iterables of MapEntry to Maps or lists of pairs.
library;

/// Extensions on [MapEntry] to provide conversion and transformation utilities.
///
/// Example:
/// ```dart
/// final entry = MapEntry('a', 1);
/// print(entry.swap()); // MapEntry(1, 'a')
/// print(entry.toPair()); // ('a', 1)
/// ```
extension MapEntryKnife<K, V> on MapEntry<K, V> {
  /// Swaps the key and value of this [MapEntry], returning a new [MapEntry].
  ///
  /// Example:
  /// ```dart
  /// final entry = MapEntry('key', 'value');
  /// final swapped = entry.swap();
  /// print(swapped.key); // 'value'
  /// print(swapped.value); // 'key'
  /// ```
  MapEntry<V, K> swap() => MapEntry(value, key);

  /// Converts this [MapEntry] to a Dart 3 record pair `(key, value)`.
  ///
  /// Example:
  /// ```dart
  /// final entry = MapEntry('id', 101);
  /// final pair = entry.toPair();
  /// print(pair); // ('id', 101)
  /// ```
  (K, V) toPair() => (key, value);
}

/// Extensions on [Iterable] of [MapEntry] elements to ease collection conversion.
extension MapEntryIterableKnife<K, V> on Iterable<MapEntry<K, V>> {
  /// Collects this iterable of [MapEntry] elements into a standard [Map].
  ///
  /// If there are duplicate keys in the iterable, the last-write-wins behavior
  /// of [Map.fromEntries] applies.
  ///
  /// Example:
  /// ```dart
  /// final entries = [MapEntry('a', 1), MapEntry('b', 2)];
  /// final map = entries.toMap();
  /// print(map); // {'a': 1, 'b': 2}
  /// ```
  Map<K, V> toMap() => Map<K, V>.fromEntries(this);

  /// Converts this iterable of [MapEntry] elements to a [List] of record pairs `(key, value)`.
  ///
  /// Example:
  /// ```dart
  /// final entries = [MapEntry('a', 1), MapEntry('b', 2)];
  /// final pairs = entries.toPairs();
  /// print(pairs); // [('a', 1), ('b', 2)]
  /// ```
  List<(K, V)> toPairs() => map((entry) => entry.toPair()).toList();
}
