/// Extension methods on String and Nullable String values.
///
/// Provides rich text transformation, case conversion, validation,
/// masking, and parsing utilities.
library;

/// Extensions on the [String] type to provide fluent string operations.
///
/// Example:
/// ```dart
/// final text = 'hello world';
/// print(text.capitalize()); // 'Hello world'
/// ```
extension StringKnife on String {
  /// Helper to split a string into words based on case transitions and non-alphanumeric chars.
  List<String> _splitIntoWords() {
    if (isEmpty) return const [];
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      final char = this[i];
      if (i > 0) {
        final prev = this[i - 1];
        final isLowerToUpper = _isLowercase(prev) && _isUppercase(char);
        final isUpperWordBoundary = i < length - 1 &&
            _isUppercase(prev) &&
            _isUppercase(char) &&
            _isLowercase(this[i + 1]);

        if (isLowerToUpper || isUpperWordBoundary) {
          buffer.write(' ');
        }
      }

      if (_isAlphanumericChar(char)) {
        buffer.write(char);
      } else {
        buffer.write(' ');
      }
    }
    return buffer
        .toString()
        .split(' ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  bool _isLowercase(String char) =>
      char.codeUnitAt(0) >= 97 && char.codeUnitAt(0) <= 122;

  bool _isUppercase(String char) =>
      char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90;

  bool _isAlphanumericChar(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 97 && code <= 122) || // a-z
        (code >= 65 && code <= 90) || // A-Z
        (code >= 48 && code <= 57); // 0-9
  }

  /// Capitalizes the first letter of this string.
  ///
  /// Example:
  /// ```dart
  /// print('hello'.capitalize()); // 'Hello'
  /// ```
  String capitalize() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalizes the first letter of each word in this string.
  ///
  /// Example:
  /// ```dart
  /// print('hello world'.capitalizeEach()); // 'Hello World'
  /// ```
  String capitalizeEach() {
    if (isEmpty) return '';
    return split(' ').map((w) => w.capitalize()).join(' ');
  }

  /// Converts this string to Title Case, respecting minor words.
  ///
  /// Minor words like articles and prepositions are kept in lowercase,
  /// unless they are the first or last word.
  ///
  /// Example:
  /// ```dart
  /// print('the lord of the rings'.toTitleCase()); // 'The Lord of the Rings'
  /// ```
  String toTitleCase() {
    final words = _splitIntoWords();
    if (words.isEmpty) return '';
    const minorWords = {
      'a',
      'an',
      'the',
      'and',
      'but',
      'or',
      'for',
      'nor',
      'in',
      'on',
      'at',
      'to',
      'by',
      'of',
      'up',
      'with',
      'from',
      'as',
    };

    final result = <String>[];
    for (var i = 0; i < words.length; i++) {
      final word = words[i].toLowerCase();
      if (i == 0 || i == words.length - 1 || !minorWords.contains(word)) {
        result.add(word[0].toUpperCase() + word.substring(1));
      } else {
        result.add(word);
      }
    }
    return result.join(' ');
  }

  /// Converts this string to camelCase.
  ///
  /// Example:
  /// ```dart
  /// print('hello_world'.toCamelCase()); // 'helloWorld'
  /// ```
  String toCamelCase() {
    final words = _splitIntoWords();
    if (words.isEmpty) return '';
    final first = words[0].toLowerCase();
    final rest = words.skip(1).map((w) => w.toLowerCase().capitalize()).join();
    return first + rest;
  }

  /// Converts this string to snake_case.
  ///
  /// Example:
  /// ```dart
  /// print('helloWorld'.toSnakeCase()); // 'hello_world'
  /// ```
  String toSnakeCase() {
    return _splitIntoWords().map((w) => w.toLowerCase()).join('_');
  }

  /// Converts this string to kebab-case.
  ///
  /// Example:
  /// ```dart
  /// print('HelloWorld'.toKebabCase()); // 'hello-world'
  /// ```
  String toKebabCase() {
    return _splitIntoWords().map((w) => w.toLowerCase()).join('-');
  }

  /// Converts this string to PascalCase.
  ///
  /// Example:
  /// ```dart
  /// print('hello_world'.toPascalCase()); // 'HelloWorld'
  /// ```
  String toPascalCase() {
    return _splitIntoWords().map((w) => w.toLowerCase().capitalize()).join();
  }

  /// Converts this string into a URL-friendly slug.
  ///
  /// Example:
  /// ```dart
  /// print('Hello, World!'.slugify()); // 'hello-world'
  /// ```
  String slugify() {
    return _splitIntoWords().map((w) => w.toLowerCase()).join('-');
  }

  /// Truncates this string to [maxLength], appending [ellipsis] if truncated.
  ///
  /// Example:
  /// ```dart
  /// print('long text'.truncate(6)); // 'lon...'
  /// ```
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    if (maxLength <= ellipsis.length) {
      return substring(0, maxLength);
    }
    return substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  /// Removes all HTML tags from this string.
  ///
  /// Example:
  /// ```dart
  /// print('<p>Hello</p>'.removeHtml()); // 'Hello'
  /// ```
  String removeHtml() {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Reverses the characters in this string.
  ///
  /// Example:
  /// ```dart
  /// print('abc'.reverse()); // 'cba'
  /// ```
  String reverse() {
    return split('').reversed.join();
  }

  /// Masks sensitive parts of this string, keeping [visibleCount] characters visible at the end.
  ///
  /// Example:
  /// ```dart
  /// print('12345678'.mask()); // '****5678'
  /// ```
  String mask({int visibleCount = 4, String maskChar = '*'}) {
    if (length <= visibleCount) return this;
    final maskLen = length - visibleCount;
    return (maskChar * maskLen) + substring(maskLen);
  }

  /// Extracts the initials from this string.
  ///
  /// Example:
  /// ```dart
  /// print('John Doe'.initials()); // 'JD'
  /// ```
  String initials({int count = 2}) {
    final words = _splitIntoWords();
    if (words.isEmpty) return '';
    return words
        .take(count)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
  }

  /// Checks if this string is a valid email address.
  bool get isEmail {
    final regex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}"
      r"[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    );
    return regex.hasMatch(this);
  }

  /// Checks if this string is a valid HTTP/HTTPS URL.
  bool get isUrl {
    final regex = RegExp(
      r'^https?://[a-zA-Z0-9\-._~:/?#\[\]@!$&'
      r"'()*+,;=]+$",
      caseSensitive: false,
    );
    return regex.hasMatch(this);
  }

  /// Checks if this string contains only numeric characters (supports decimals and negative signs).
  bool get isNumeric {
    final regex = RegExp(r'^-?[0-9]+(?:\.[0-9]+)?$');
    return regex.hasMatch(this);
  }

  /// Checks if this string contains only alphabetic characters.
  bool get isAlpha {
    final regex = RegExp(r'^[a-zA-Z]+$');
    return regex.hasMatch(this);
  }

  /// Checks if this string contains only alphanumeric characters.
  bool get isAlphanumeric {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(this);
  }

  /// Counts the number of words in this string.
  int get wordCount => _splitIntoWords().length;

  /// Returns a map of character frequencies in this string.
  ///
  /// Example:
  /// ```dart
  /// print('hello'.charFrequency()); // {'h': 1, 'e': 1, 'l': 2, 'o': 1}
  /// ```
  Map<String, int> charFrequency() {
    final freq = <String, int>{};
    for (var i = 0; i < length; i++) {
      final char = this[i];
      freq[char] = (freq[char] ?? 0) + 1;
    }
    return freq;
  }

  /// Wraps this string with the specified [prefix] and [suffix].
  ///
  /// Example:
  /// ```dart
  /// print('body'.wrap('{', '}')); // '{body}'
  /// ```
  String wrap(String prefix, String suffix) => '$prefix$this$suffix';

  /// Unwraps this string if it is surrounded by [prefix] and [suffix].
  ///
  /// Example:
  /// ```dart
  /// print('{body}'.unwrap('{', '}')); // 'body'
  /// ```
  String unwrap(String prefix, String suffix) {
    if (startsWith(prefix) && endsWith(suffix)) {
      return substring(prefix.length, length - suffix.length);
    }
    return this;
  }

  /// Safely parses this string to an integer, returning `null` on failure.
  int? toIntOrNull() => int.tryParse(this);

  /// Safely parses this string to a double, returning `null` on failure.
  double? toDoubleOrNull() => double.tryParse(this);

  /// Repeats this string [n] times, separated by [separator].
  ///
  /// Example:
  /// ```dart
  /// print('a'.repeatWith(3, separator: '-')); // 'a-a-a'
  /// ```
  String repeatWith(int n, {String separator = ''}) {
    if (n <= 0) return '';
    return List.filled(n, this).join(separator);
  }

  /// Performs multiple string replacements in a single pass.
  ///
  /// Example:
  /// ```dart
  /// final result = 'hello world'.replaceMultiple({'hello': 'hi', 'world': 'there'});
  /// print(result); // 'hi there'
  /// ```
  String replaceMultiple(Map<String, String> replacements) {
    final validReplacements = Map<String, String>.fromEntries(
      replacements.entries.where((e) => e.key.isNotEmpty),
    );
    if (validReplacements.isEmpty) return this;
    final escapedKeys = validReplacements.keys.map(RegExp.escape).join('|');
    final pattern = RegExp(escapedKeys);
    return replaceAllMapped(pattern, (match) {
      final matchedText = match.group(0);
      return validReplacements[matchedText] ?? matchedText ?? '';
    });
  }

  /// Checks if this string contains any of the specified [patterns].
  bool containsAny(List<String> patterns) {
    return patterns.any((p) => contains(p));
  }

  /// Performs a case-insensitive equality comparison with [other].
  bool equalsIgnoreCase(String other) {
    return toLowerCase() == other.toLowerCase();
  }
}

/// Nullable String extension methods.
extension NullableStringKnife on String? {
  /// Checks if this string is null, empty, or consists only of whitespace.
  ///
  /// Example:
  /// ```dart
  /// String? val;
  /// print(val.isBlank); // true
  /// print('   '.isBlank); // true
  /// ```
  bool get isBlank {
    final value = this;
    if (value == null) return true;
    return value.trim().isEmpty;
  }

  /// Checks if this string is not null, not empty, and does not consist only of whitespace.
  ///
  /// Example:
  /// ```dart
  /// String? val = 'hello';
  /// print(val.isNotBlank); // true
  /// ```
  bool get isNotBlank => !isBlank;
}
