/// Library-level comment for string iterable extensions.
///
/// Contains extensions on collections of strings to support custom joining,
/// finding the longest common prefix, and sorting (case-sensitive and case-insensitive).
library;

import 'dart:math' as math;

/// Extensions on [Iterable<String>] to provide string-specific collection helpers.
///
/// Example:
/// ```dart
/// final list = ['apple', 'banana', 'cherry'];
/// print(list.joinWithLast(', ', ', and ')); // 'apple, banana, and cherry'
/// ```
extension StringIterableKnife on Iterable<String> {
  /// Joins strings in this collection, using a different separator for the last element.
  ///
  /// Example:
  /// ```dart
  /// print(['a', 'b', 'c'].joinWithLast(', ', ', and ')); // 'a, b, and c'
  /// print(['a', 'b'].joinWithLast(', ', ' & ')); // 'a & b'
  /// print(['a'].joinWithLast(', ', ', and ')); // 'a'
  /// ```
  String joinWithLast(String separator, String lastSeparator) {
    final list = toList();
    if (list.isEmpty) return '';
    if (list.length == 1) return list.first;
    if (list.length == 2) return '${list[0]}$lastSeparator${list[1]}';
    final head = list.sublist(0, list.length - 1).join(separator);
    return '$head$lastSeparator${list.last}';
  }

  /// Finds the longest common prefix among all strings in this collection.
  ///
  /// Returns an empty string if this collection is empty or if no common prefix exists.
  ///
  /// Example:
  /// ```dart
  /// print(['flower', 'flow', 'flight'].longestCommonPrefix()); // 'fl'
  /// print(['dog', 'racecar', 'car'].longestCommonPrefix()); // ''
  /// ```
  String longestCommonPrefix() {
    if (isEmpty) return '';
    final iterator = this.iterator;
    if (!iterator.moveNext()) return '';
    var prefix = iterator.current;
    while (iterator.moveNext()) {
      final next = iterator.current;
      var commonLength = 0;
      final minLen = math.min(prefix.length, next.length);
      while (commonLength < minLen &&
          prefix.codeUnitAt(commonLength) == next.codeUnitAt(commonLength)) {
        commonLength++;
      }
      prefix = prefix.substring(0, commonLength);
      if (prefix.isEmpty) return '';
    }
    return prefix;
  }

  /// Returns a new sorted list of strings.
  ///
  /// Does not mutate the original collection.
  ///
  /// Example:
  /// ```dart
  /// final fruits = ['cherry', 'banana', 'apple'];
  /// print(fruits.sorted()); // ['apple', 'banana', 'cherry']
  /// ```
  List<String> sorted() {
    final list = toList();
    list.sort();
    return list;
  }

  /// Returns a new sorted list of strings, sorting case-insensitively.
  ///
  /// Does not mutate the original collection.
  ///
  /// Example:
  /// ```dart
  /// final words = ['banana', 'Apple', 'cherry'];
  /// print(words.sortedCaseInsensitive()); // ['Apple', 'banana', 'cherry']
  /// ```
  List<String> sortedCaseInsensitive() {
    final list = toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }
}
