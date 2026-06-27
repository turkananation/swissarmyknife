/// Non-mutating URI query parameter manipulation extensions.
///
/// Contains parameter appending/updating and parameter stripping helpers.
library;

/// Extensions on [Uri] to provide fluent query parameter management.
///
/// Example:
/// ```dart
/// final uri = Uri.parse('https://api.example.com/users?id=123');
/// final updated = uri.addQueryParams({'role': 'admin'}); // 'https://api.example.com/users?id=123&role=admin'
/// ```
extension UriKnife on Uri {
  /// Returns a new [Uri] adding or updating query [params].
  ///
  /// Supports values of type [String], primitive types, or [Iterable] for multi-value keys.
  ///
  /// Example:
  /// ```dart
  /// final uri = Uri.parse('https://example.com');
  /// print(uri.addQueryParams({'q': 'search', 'tags': ['dart', 'flutter']}));
  /// // 'https://example.com?q=search&tags=dart&tags=flutter'
  /// ```
  Uri addQueryParams(Map<String, dynamic> params) {
    if (params.isEmpty) return this;
    final queryMap = Map<String, dynamic>.from(queryParametersAll);
    for (final entry in params.entries) {
      final value = entry.value;
      if (value is Iterable) {
        queryMap[entry.key] = value.map((e) => e.toString()).toList();
      } else {
        queryMap[entry.key] = [value.toString()];
      }
    }
    // Using replace is a clean, non-mutating way to rebuild the Uri.
    return replace(queryParameters: queryMap);
  }

  /// Returns a new [Uri] with the specified query parameter [keys] removed.
  ///
  /// Example:
  /// ```dart
  /// final uri = Uri.parse('https://example.com?id=123&token=abc');
  /// print(uri.removeQueryParams(['token'])); // 'https://example.com?id=123'
  /// ```
  Uri removeQueryParams(Iterable<String> keys) {
    if (keys.isEmpty) return this;
    final queryMap = Map<String, List<String>>.from(queryParametersAll);
    for (final key in keys) {
      queryMap.remove(key);
    }
    return replace(queryParameters: queryMap);
  }
}
