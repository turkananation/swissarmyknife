/// Extension methods on Map and String-keyed Map structures.
///
/// Contains key picking, omitting, inversion, filtering, deep nesting
/// transformations (flatten, unflatten, dot access), query string serialization,
/// and null value filtering.
library;

/// Extensions on generic [Map] to provide common map-manipulation helpers.
///
/// Example:
/// ```dart
/// final map = {'a': 1, 'b': 2, 'c': 3};
/// final picked = map.pick(['a', 'c']); // {'a': 1, 'c': 3}
/// ```
extension MapKnife<K, V> on Map<K, V> {
  /// Returns a new map containing only the entries with the specified [keys].
  ///
  /// Example:
  /// ```dart
  /// final picked = {'a': 1, 'b': 2}.pick(['a']); // {'a': 1}
  /// ```
  Map<K, V> pick(Iterable<K> keys) {
    final result = <K, V>{};
    for (final key in keys) {
      if (containsKey(key)) {
        result[key] = this[key] as V;
      }
    }
    return result;
  }

  /// Returns a new map omitting entries with the specified [keys].
  ///
  /// Example:
  /// ```dart
  /// final omitted = {'a': 1, 'b': 2}.omit(['a']); // {'b': 2}
  /// ```
  Map<K, V> omit(Iterable<K> keys) {
    final result = Map<K, V>.from(this);
    for (final key in keys) {
      result.remove(key);
    }
    return result;
  }

  /// Inverts this map, swapping keys and values.
  ///
  /// If duplicate values exist, the last key associated with that value wins.
  ///
  /// Example:
  /// ```dart
  /// final inverted = {'a': 1, 'b': 2}.invert(); // {1: 'a', 2: 'b'}
  /// ```
  Map<V, K> invert() {
    final result = <V, K>{};
    for (final entry in entries) {
      result[entry.value] = entry.key;
    }
    return result;
  }

  /// Returns a new map containing only the entries whose keys satisfy [test].
  Map<K, V> filterKeys(bool Function(K key) test) {
    final result = <K, V>{};
    for (final entry in entries) {
      if (test(entry.key)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Returns a new map containing only the entries whose values satisfy [test].
  Map<K, V> filterValues(bool Function(V value) test) {
    final result = <K, V>{};
    for (final entry in entries) {
      if (test(entry.value)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Returns a new map where keys are transformed by [transform].
  Map<K2, V> mapKeys<K2>(K2 Function(K key, V value) transform) {
    final result = <K2, V>{};
    for (final entry in entries) {
      result[transform(entry.key, entry.value)] = entry.value;
    }
    return result;
  }

  /// Returns a new map where values are transformed by [transform] (named to avoid clash with Map.map).
  Map<K, V2> mapValuesWithKey<V2>(V2 Function(K key, V value) transform) {
    final result = <K, V2>{};
    for (final entry in entries) {
      result[entry.key] = transform(entry.key, entry.value);
    }
    return result;
  }
}

/// Extensions on [Map] structures with String keys.
extension StringMapKnife on Map<String, dynamic> {
  /// Recursively merges this map with [other].
  ///
  /// If both maps have a key whose values are maps, they are recursively merged.
  /// Otherwise, the value from [other] overwrites the value from this map.
  ///
  /// Example:
  /// ```dart
  /// final m1 = {'a': {'b': 1}};
  /// final m2 = {'a': {'c': 2}, 'd': 3};
  /// print(m1.deepMerge(m2)); // {'a': {'b': 1, 'c': 2}, 'd': 3}
  /// ```
  Map<String, dynamic> deepMerge(Map<String, dynamic> other) {
    final result = Map<String, dynamic>.from(this);
    for (final entry in other.entries) {
      final key = entry.key;
      final value = entry.value;
      final existing = result[key];
      if (existing is Map && value is Map) {
        final existingMap = Map<String, dynamic>.from(existing);
        final valueMap = Map<String, dynamic>.from(value);
        result[key] = existingMap.deepMerge(valueMap);
      } else {
        result[key] = value;
      }
    }
    return result;
  }

  /// Flattens a nested map structure into a flat map with dot-notation keys.
  ///
  /// Example:
  /// ```dart
  /// final nested = {'a': {'b': 1}};
  /// print(nested.flattenKeys()); // {'a.b': 1}
  /// ```
  Map<String, dynamic> flattenKeys({String separator = '.'}) {
    final result = <String, dynamic>{};
    void helper(String currentPath, Map<dynamic, dynamic> map) {
      for (final entry in map.entries) {
        final key = entry.key.toString();
        final val = entry.value;
        final newPath = currentPath.isEmpty
            ? key
            : '$currentPath$separator$key';
        if (val is Map) {
          helper(newPath, val);
        } else {
          result[newPath] = val;
        }
      }
    }

    helper('', this);
    return result;
  }

  /// Rebuilds a nested map structure from a flat map with dot-notation keys.
  ///
  /// Example:
  /// ```dart
  /// final flat = {'a.b': 1};
  /// print(flat.unflattenKeys()); // {'a': {'b': 1}}
  /// ```
  Map<String, dynamic> unflattenKeys({String separator = '.'}) {
    final result = <String, dynamic>{};
    for (final entry in entries) {
      final path = entry.key;
      final value = entry.value;
      final parts = path.split(separator);

      Map<String, dynamic> current = result;
      for (var i = 0; i < parts.length - 1; i++) {
        final part = parts[i];
        if (!current.containsKey(part) || current[part] is! Map) {
          current[part] = <String, dynamic>{};
        } else if (current[part] is! Map<String, dynamic>) {
          current[part] = Map<String, dynamic>.from(current[part] as Map);
        }
        current = current[part] as Map<String, dynamic>;
      }
      current[parts.last] = value;
    }
    return result;
  }

  /// Retrieves a nested value from this map using a dot-notation [path].
  ///
  /// Returns `null` if the path does not exist.
  ///
  /// Example:
  /// ```dart
  /// final map = {'user': {'profile': {'name': 'John'}}};
  /// print(map.getNestedValue('user.profile.name')); // 'John'
  /// ```
  dynamic getNestedValue(String path, {String separator = '.'}) {
    final parts = path.split(separator);
    dynamic current = this;
    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  /// Sets a nested value in this map using a dot-notation [path], returning a new map.
  ///
  /// Example:
  /// ```dart
  /// final map = <String, dynamic>{};
  /// final updated = map.setNestedValue('user.name', 'John'); // {'user': {'name': 'John'}}
  /// ```
  Map<String, dynamic> setNestedValue(
    String path,
    dynamic value, {
    String separator = '.',
  }) {
    final result = Map<String, dynamic>.from(this);
    final parts = path.split(separator);
    Map<String, dynamic> current = result;
    for (var i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (!current.containsKey(part) || current[part] is! Map) {
        current[part] = <String, dynamic>{};
      } else {
        current[part] = Map<String, dynamic>.from(current[part] as Map);
      }
      current = current[part] as Map<String, dynamic>;
    }
    current[parts.last] = value;
    return result;
  }

  /// Converts this map into a URL query string format.
  ///
  /// Example:
  /// ```dart
  /// final map = {'name': 'John Doe', 'age': 30};
  /// print(map.toQueryString()); // 'name=John+Doe&age=30'
  /// ```
  String toQueryString() {
    if (isEmpty) return '';
    final parts = <String>[];
    for (final entry in entries) {
      final key = Uri.encodeQueryComponent(entry.key);
      final value = Uri.encodeQueryComponent(entry.value.toString());
      parts.add('$key=$value');
    }
    return parts.join('&');
  }

  /// Returns a new map containing only the entries with non-null values.
  Map<String, dynamic> whereNotNull() {
    final result = <String, dynamic>{};
    for (final entry in entries) {
      if (entry.value != null) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}

/// Parses a URL [queryString] back into a map.
///
/// Example:
/// ```dart
/// final map = queryStringToMap('name=John+Doe&age=30'); // {'name': 'John Doe', 'age': '30'}
/// ```
Map<String, dynamic> queryStringToMap(String queryString) {
  if (queryString.isEmpty) return const {};
  final query = queryString.startsWith('?')
      ? queryString.substring(1)
      : queryString;
  final result = <String, dynamic>{};
  final parts = query.split('&');
  for (final part in parts) {
    if (part.isEmpty) continue;
    final kv = part.split('=');
    final key = Uri.decodeQueryComponent(kv[0]);
    final val = kv.length > 1 ? Uri.decodeQueryComponent(kv[1]) : '';
    result[key] = val;
  }
  return result;
}

/// Extensions to filter out null values from Maps.
extension MapNullableValueKnife<K, V> on Map<K, V?> {
  /// Removes entries with null values from this map and returns a typed `Map<K, V>`.
  ///
  /// Example:
  /// ```dart
  /// final map = {'a': 1, 'b': null}.compact(); // {'a': 1}
  /// ```
  Map<K, V> compact() {
    final result = <K, V>{};
    for (final entry in entries) {
      if (entry.value != null) {
        result[entry.key] = entry.value as V;
      }
    }
    return result;
  }
}
