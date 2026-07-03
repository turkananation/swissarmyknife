/// Advanced String extensions including diacritics mapping and fuzzy matching.
///
/// Contains accent removal, Levenshtein distance, similarity ratios,
/// whitespace normalization, and content extraction utilities.
library;

import 'dart:math' as math;

/// Extensions on [String] for advanced parsing, matching, and transformations.
///
/// Example:
/// ```dart
/// final text = 'Café';
/// print(text.removeDiacritics()); // 'Cafe'
/// ```
extension StringAdvancedKnife on String {
  /// Removes all accents and diacritics from the string.
  ///
  /// Example:
  /// ```dart
  /// print('À la carte'.removeDiacritics()); // 'A la carte'
  /// print('München'.removeDiacritics()); // 'Munchen'
  /// ```
  String removeDiacritics() {
    if (isEmpty) return '';
    const diacritics = {
      'À': 'A',
      'Á': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'Å': 'A',
      'Æ': 'AE',
      'Ç': 'C',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ð': 'D',
      'Ñ': 'N',
      'Ò': 'O',
      'Ó': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'Ø': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ý': 'Y',
      'Þ': 'TH',
      'ß': 'ss',
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'å': 'a',
      'æ': 'ae',
      'ç': 'c',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ð': 'd',
      'ñ': 'n',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ø': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ý': 'y',
      'þ': 'th',
      'ÿ': 'y',
      'Ā': 'A',
      'ā': 'a',
      'Ă': 'A',
      'ă': 'a',
      'Ą': 'A',
      'ą': 'a',
      'Ć': 'C',
      'ć': 'c',
      'Ĉ': 'C',
      'ĉ': 'c',
      'Ċ': 'C',
      'ċ': 'c',
      'Č': 'C',
      'č': 'c',
      'Ď': 'D',
      'ď': 'd',
      'Đ': 'D',
      'đ': 'd',
      'Ē': 'E',
      'ē': 'e',
      'Ĕ': 'E',
      'ĕ': 'e',
      'Ė': 'E',
      'ė': 'e',
      'Ę': 'E',
      'ę': 'e',
      'Ě': 'E',
      'ě': 'e',
      'Ĝ': 'G',
      'ĝ': 'g',
      'Ğ': 'G',
      'ğ': 'g',
      'Ġ': 'G',
      'ġ': 'g',
      'Ģ': 'G',
      'ģ': 'g',
      'Ĥ': 'H',
      'ĥ': 'h',
      'Ħ': 'H',
      'ħ': 'h',
      'Ĩ': 'I',
      'ĩ': 'i',
      'Ī': 'I',
      'ī': 'i',
      'Ĭ': 'I',
      'ĭ': 'i',
      'Į': 'I',
      'į': 'i',
      'İ': 'I',
      'ı': 'i',
      'Ĳ': 'IJ',
      'ĳ': 'ij',
      'Ĵ': 'J',
      'ĵ': 'j',
      'Ķ': 'K',
      'ķ': 'k',
      'ĸ': 'k',
      'Ĺ': 'L',
      'ĺ': 'l',
      'Ļ': 'L',
      'ļ': 'l',
      'Ľ': 'L',
      'ľ': 'l',
      'Ŀ': 'L',
      'ŀ': 'l',
      'Ł': 'L',
      'ł': 'l',
      'Ń': 'N',
      'ń': 'n',
      'Ņ': 'N',
      'ņ': 'n',
      'Ň': 'N',
      'ň': 'n',
      'ŉ': 'n',
      'Ŋ': 'N',
      'ŋ': 'n',
      'Ō': 'O',
      'ō': 'o',
      'Ŏ': 'O',
      'ŏ': 'o',
      'Ő': 'O',
      'ő': 'o',
      'Œ': 'OE',
      'œ': 'oe',
      'Ŕ': 'R',
      'ŕ': 'r',
      'Ŗ': 'R',
      'ŗ': 'r',
      'Ř': 'R',
      'ř': 'r',
      'Ś': 'S',
      'ś': 's',
      'Ŝ': 'S',
      'ŝ': 's',
      'Ş': 'S',
      'ş': 's',
      'Š': 'S',
      'š': 's',
      'Ţ': 'T',
      'ţ': 't',
      'Ť': 'T',
      'ť': 't',
      'Ŧ': 'T',
      'ŧ': 't',
      'Ũ': 'U',
      'ũ': 'u',
      'Ū': 'U',
      'ū': 'u',
      'Ŭ': 'U',
      'ŭ': 'u',
      'Ů': 'U',
      'ů': 'u',
      'Ű': 'U',
      'ű': 'u',
      'Ų': 'U',
      'ų': 'u',
      'Ŵ': 'W',
      'ŵ': 'w',
      'Ŷ': 'Y',
      'ŷ': 'y',
      'Ÿ': 'Y',
      'Ź': 'Z',
      'ź': 'z',
      'Ż': 'Z',
      'ż': 'z',
      'Ž': 'Z',
      'ž': 'z',
      'ſ': 's',
    };

    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      final char = this[i];
      buffer.write(diacritics[char] ?? char);
    }
    return buffer.toString();
  }

  /// Calculates the Levenshtein distance between this string and [other].
  ///
  /// Example:
  /// ```dart
  /// print('kitten'.levenshteinDistance('sitting')); // 3
  /// ```
  int levenshteinDistance(String other) {
    if (this == other) return 0;
    if (isEmpty) return other.length;
    if (other.isEmpty) return length;

    var prevRow = List<int>.generate(other.length + 1, (i) => i);
    var currentRow = List<int>.filled(other.length + 1, 0);

    for (var i = 0; i < length; i++) {
      currentRow[0] = i + 1;
      for (var j = 0; j < other.length; j++) {
        final cost = (this[i] == other[j]) ? 0 : 1;
        currentRow[j + 1] = _min3(
          currentRow[j] + 1, // insertion
          prevRow[j + 1] + 1, // deletion
          prevRow[j] + cost, // substitution
        );
      }
      final temp = prevRow;
      prevRow = currentRow;
      currentRow = temp;
    }
    return prevRow[other.length];
  }

  int _min3(int a, int b, int c) {
    var m = a < b ? a : b;
    return m < c ? m : c;
  }

  /// Calculates a similarity score between this string and [other] (from 0.0 to 1.0).
  ///
  /// Example:
  /// ```dart
  /// print('apple'.similarity('apply')); // 0.8
  /// ```
  double similarity(String other) {
    if (this == other) return 1.0;
    final maxLen = math.max(length, other.length);
    if (maxLen == 0) return 1.0;
    final distance = levenshteinDistance(other);
    return (maxLen - distance) / maxLen;
  }

  /// Normalizes the whitespace of this string.
  ///
  /// Trims leading/trailing whitespace and replaces multiple spaces/tabs/newlines
  /// with a single space character.
  ///
  /// Example:
  /// ```dart
  /// print('  hello   \n  world  '.removeWhitespace()); // 'hello world'
  /// ```
  String removeWhitespace() {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Extracts all email addresses found within this string.
  List<String> extractEmails() {
    final regex = RegExp(
      r'[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+',
    );
    return regex.allMatches(this).map((m) => m.group(0)!).toList();
  }

  /// Extracts all HTTP/HTTPS URLs found within this string.
  List<String> extractUrls() {
    final regex = RegExp(r'https?://[a-zA-Z0-9\-._~:/?#\[\]@!$&’()*+,;=%]+');
    return regex.allMatches(this).map((m) => m.group(0)!).toList();
  }

  /// Extracts all phone numbers found within this string.
  List<String> extractPhoneNumbers() {
    final regex = RegExp(r'\+?[0-9][0-9\-.\s()]{6,18}[0-9]');
    return regex.allMatches(this).map((m) => m.group(0)!.trim()).toList();
  }

  /// Extracts all hashtags (e.g. #dart) found within this string.
  List<String> extractHashtags() {
    final regex = RegExp(r'#[a-zA-Z0-9_]+');
    return regex.allMatches(this).map((m) => m.group(0)!).toList();
  }

  /// Extracts all user mentions (e.g. @user) found within this string.
  List<String> extractMentions() {
    final regex = RegExp(r'@[a-zA-Z0-9_]+');
    return regex.allMatches(this).map((m) => m.group(0)!).toList();
  }
}
