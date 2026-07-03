/// Simple dotenv-style environment configuration.
///
/// Use [Env.load] for CLI/server `.env` files and [Env.fromMap] for tests or
/// already-loaded configuration maps.
library;

import 'env_source.dart';

/// Process-wide environment configuration.
///
/// Example:
/// ```dart
/// Env.load('.env');
/// final apiKey = Env.get('API_KEY');
/// ```
final class Env {
  const Env._();

  static final Map<String, String> _values = <String, String>{};

  /// Loads dotenv-style values from [path].
  ///
  /// Existing loaded values are replaced. File loading is available on Dart VM
  /// platforms. Browser builds should use [fromMap] with configuration supplied
  /// by the application shell.
  static void load(String path) {
    fromMap(_parse(readEnvFile(path)));
  }

  /// Replaces current values from [values].
  static void fromMap(Map<String, String> values) {
    _values
      ..clear()
      ..addAll(values);
  }

  /// Returns required value [key], or throws if missing.
  static String get(String key) {
    final value = _values[key] ?? platformEnvironmentValue(key);
    if (value == null) {
      throw StateError('Missing required environment value: $key');
    }
    return value;
  }

  /// Returns optional value [key], or `null`.
  static String? getOrNull(String key) {
    return _values[key] ?? platformEnvironmentValue(key);
  }

  /// Returns value [key], or [defaultValue].
  static String getOr(String key, String defaultValue) {
    return getOrNull(key) ?? defaultValue;
  }

  /// Returns integer value [key], or throws if missing or invalid.
  static int getInt(String key) {
    final value = int.tryParse(get(key));
    if (value == null) {
      throw StateError('Environment value is not an int: $key');
    }
    return value;
  }

  /// Returns boolean value [key], or throws if missing or invalid.
  static bool getBool(String key) {
    final value = get(key).trim().toLowerCase();
    return switch (value) {
      'true' || '1' || 'yes' || 'on' => true,
      'false' || '0' || 'no' || 'off' => false,
      _ => throw StateError('Environment value is not a bool: $key'),
    };
  }

  /// Returns double value [key], or throws if missing or invalid.
  static double getDouble(String key) {
    final value = double.tryParse(get(key));
    if (value == null) {
      throw StateError('Environment value is not a double: $key');
    }
    return value;
  }

  /// Verifies all [keys] are present.
  static void require(Iterable<String> keys) {
    final missing = [
      for (final key in keys)
        if (getOrNull(key) == null) key,
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing required environment values: ${missing.join(', ')}',
      );
    }
  }

  static Map<String, String> _parse(List<String> lines) {
    final values = <String, String>{};
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      final separatorIndex = trimmed.indexOf('=');
      if (separatorIndex <= 0) continue;

      final key = trimmed.substring(0, separatorIndex).trim();
      final rawValue = trimmed.substring(separatorIndex + 1).trim();
      values[key] = _stripQuotes(rawValue);
    }
    return values;
  }

  static String _stripQuotes(String value) {
    if (value.length < 2) return value;
    final first = value[0];
    final last = value[value.length - 1];
    if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }
}
