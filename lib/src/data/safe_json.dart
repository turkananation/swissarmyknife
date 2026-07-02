/// Null-safe JSON navigation and typed conversion helpers.
///
/// Use [SafeJson] when reading untrusted or optional JSON structures where
/// missing keys and wrong types should fall back predictably.
library;

/// Extension for starting safe JSON traversal from a map.
///
/// Example:
/// ```dart
/// final name = json.at('user.profile.name').asStringOr('Unknown');
/// ```
extension SafeJsonMapKnife on Map<String, dynamic> {
  /// Reads a dot-separated [path] from this map.
  SafeJson at(String path) => SafeJson(this).at(path);
}

/// A safely traversable JSON value.
///
/// Example:
/// ```dart
/// final age = SafeJson(json).at('user.age').asIntOr(0);
/// ```
final class SafeJson {
  /// Wraps [value] for safe traversal and conversion.
  const SafeJson(this.value, {this.exists = true});

  /// A missing JSON value.
  const SafeJson.missing() : value = null, exists = false;

  /// The wrapped raw value.
  final Object? value;

  /// Whether the value was found while traversing.
  final bool exists;

  /// Whether the found value is `null` or missing.
  bool get isNull => value == null;

  /// Reads a dot-separated [path] from this JSON value.
  ///
  /// Numeric path segments index into lists.
  SafeJson at(String path) {
    if (path.trim().isEmpty) return this;

    Object? current = value;
    for (final segment in path.split('.')) {
      if (current is Map) {
        if (!current.containsKey(segment)) return const SafeJson.missing();
        current = current[segment];
      } else if (current is List) {
        final index = int.tryParse(segment);
        if (index == null || index < 0 || index >= current.length) {
          return const SafeJson.missing();
        }
        current = current[index];
      } else {
        return const SafeJson.missing();
      }
    }

    return SafeJson(current);
  }

  /// Converts the value to a string or returns [defaultValue].
  String asStringOr(String defaultValue) => asStringOrNull() ?? defaultValue;

  /// Converts the value to a string or returns `null`.
  String? asStringOrNull() {
    final raw = value;
    if (!exists || raw == null) return null;
    if (raw is String) return raw;
    if (raw is num || raw is bool) return raw.toString();
    return null;
  }

  /// Converts the value to an integer or returns [defaultValue].
  int asIntOr(int defaultValue) => asIntOrNull() ?? defaultValue;

  /// Converts the value to an integer or returns `null`.
  int? asIntOrNull() {
    final raw = value;
    if (!exists || raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  /// Converts the value to a double or returns [defaultValue].
  double asDoubleOr(double defaultValue) => asDoubleOrNull() ?? defaultValue;

  /// Converts the value to a double or returns `null`.
  double? asDoubleOrNull() {
    final raw = value;
    if (!exists || raw == null) return null;
    if (raw is double) return raw;
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  /// Converts the value to a boolean or returns [defaultValue].
  bool asBoolOr(bool defaultValue) => asBoolOrNull() ?? defaultValue;

  /// Converts the value to a boolean or returns `null`.
  bool? asBoolOrNull() {
    final raw = value;
    if (!exists || raw == null) return null;
    if (raw is bool) return raw;
    if (raw is String) {
      return switch (raw.trim().toLowerCase()) {
        'true' || '1' || 'yes' || 'on' => true,
        'false' || '0' || 'no' || 'off' => false,
        _ => null,
      };
    }
    if (raw is num) {
      if (raw == 1) return true;
      if (raw == 0) return false;
    }
    return null;
  }

  /// Converts the value to a typed list or returns [defaultValue].
  List<T> asListOr<T>(List<T> defaultValue) =>
      asListOrNull<T>() ?? defaultValue;

  /// Converts the value to a typed list or returns `null`.
  List<T>? asListOrNull<T>() {
    final raw = value;
    if (!exists || raw is! List) return null;
    if (raw.every((element) => element is T)) {
      return raw.cast<T>();
    }
    return null;
  }

  /// Converts the value to a JSON-like map or returns [defaultValue].
  Map<String, dynamic> asMapOr(Map<String, dynamic> defaultValue) {
    return asMapOrNull() ?? defaultValue;
  }

  /// Converts the value to a JSON-like map or returns `null`.
  Map<String, dynamic>? asMapOrNull() {
    final raw = value;
    if (!exists || raw is! Map) return null;
    final result = <String, dynamic>{};
    for (final entry in raw.entries) {
      if (entry.key is! String) return null;
      result[entry.key as String] = entry.value;
    }
    return result;
  }
}
