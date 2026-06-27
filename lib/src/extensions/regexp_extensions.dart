/// Library-level comment for regexp extensions.
///
/// Contains advanced regular expression operations to retrieve named capture
/// groups and perform mapped replacements using named groups.
library;

/// Extensions on [RegExp] to provide advanced regex matching and group extraction.
///
/// Example:
/// ```dart
/// final regex = RegExp(r'(?<word>\w+)');
/// final matches = regex.allMatchesWithNames('hello world');
/// print(matches); // [{'word': 'hello'}, {'word': 'world'}]
/// ```
extension RegExpKnife on RegExp {
  /// Extracts the named capture groups for all matches in [input].
  ///
  /// Returns a list of maps, where each map contains the capture group names
  /// as keys and their corresponding matched values.
  ///
  /// Example:
  /// ```dart
  /// final regex = RegExp(r'(?<key>\w+): (?<value>\w+)');
  /// final matches = regex.allMatchesWithNames('id: 123 name: john');
  /// // [{'key': 'id', 'value': '123'}, {'key': 'name', 'value': 'john'}]
  /// ```
  List<Map<String, String>> allMatchesWithNames(String input) {
    return allMatches(input).map((m) {
      final map = <String, String>{};
      for (final name in m.groupNames) {
        final val = m.namedGroup(name);
        if (val != null) {
          map[name] = val;
        }
      }
      return map;
    }).toList();
  }

  /// Extracts the named capture groups for the first match in [input].
  ///
  /// Returns a map of named capture groups, or `null` if no match is found.
  ///
  /// Example:
  /// ```dart
  /// final regex = RegExp(r'(?<key>\w+): (?<value>\w+)');
  /// final match = regex.firstMatchWithNames('id: 123 name: john');
  /// // {'key': 'id', 'value': '123'}
  /// ```
  Map<String, String>? firstMatchWithNames(String input) {
    final m = firstMatch(input);
    if (m == null) return null;
    final map = <String, String>{};
    for (final name in m.groupNames) {
      final val = m.namedGroup(name);
      if (val != null) {
        map[name] = val;
      }
    }
    return map;
  }

  /// Replaces all matches in [input] using a callback [replace] that receives
  /// a map of named capture groups.
  ///
  /// Example:
  /// ```dart
  /// final regex = RegExp(r'\$(?<var>\w+)');
  /// final result = regex.replaceAllMappedNamed(
  ///   'hello $user',
  ///   (groups) => groups['var'] == 'user' ? 'Alice' : '',
  /// );
  /// print(result); // 'hello Alice'
  /// ```
  String replaceAllMappedNamed(
    String input,
    String Function(Map<String, String> groups) replace,
  ) {
    return input.replaceAllMapped(this, (match) {
      final regExpMatch = match as RegExpMatch;
      final map = <String, String>{};
      for (final name in regExpMatch.groupNames) {
        final val = regExpMatch.namedGroup(name);
        if (val != null) {
          map[name] = val;
        }
      }
      return replace(map);
    });
  }

  /// Returns `true` if this regular expression matches [input].
  ///
  /// Shorthand for [RegExp.hasMatch].
  ///
  /// Example:
  /// ```dart
  /// print(RegExp(r'\d+').isMatch('123')); // true
  /// ```
  bool isMatch(String input) => hasMatch(input);
}
