/// Extension methods on numbers (num, int, double).
///
/// Contains currency/size formatting, range coercion/validation, Roman numeral
/// conversion, ordinal number formatting, and duration shortcuts.
library;

import 'dart:math' as math;

/// Extensions on the [num] type to provide fluent numeric utilities.
///
/// Example:
/// ```dart
/// final price = 1250.5;
/// print(price.toCurrency()); // '$1,250.50'
/// ```
extension NumKnife on num {
  /// Formats this number as a currency string.
  ///
  /// Example:
  /// ```dart
  /// print(1234.56.toCurrency(symbol: '€')); // '€1,234.56'
  /// print((-100).toCurrency()); // '-$100.00'
  /// ```
  String toCurrency({String symbol = '\$', int decimals = 2}) {
    final fixed = abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final buffer = StringBuffer();
    final len = integerPart.length;
    for (var i = 0; i < len; i++) {
      buffer.write(integerPart[i]);
      if ((len - i - 1) % 3 == 0 && i < len - 1) {
        buffer.write(',');
      }
    }
    final sign = this < 0 ? '-' : '';
    return '$sign$symbol${buffer.toString()}$decimalPart';
  }

  /// Formats this number as a percentage string.
  ///
  /// Example:
  /// ```dart
  /// print(0.85.toPercentString()); // '85%'
  /// print(0.1234.toPercentString(decimals: 2)); // '12.34%'
  /// ```
  String toPercentString({int decimals = 0}) {
    final pct = this * 100;
    return '${pct.toStringAsFixed(decimals)}%';
  }

  /// Checks if this number is within the range [min] and [max] (inclusive).
  ///
  /// Example:
  /// ```dart
  /// print(5.isBetween(1, 10)); // true
  /// ```
  bool isBetween(num min, num max) => this >= min && this <= max;

  /// Checks if this number is strictly positive (> 0).
  bool get isPositive => this > 0;

  /// Checks if this number is strictly negative (< 0).
  bool get isNegative => this < 0;

  /// Checks if this number is equal to zero.
  bool get isZero => this == 0;

  /// Rounds this number to the specified number of [decimals].
  ///
  /// Example:
  /// ```dart
  /// print(1.23456.roundTo(2)); // 1.23
  /// ```
  double roundTo(int decimals) {
    if (decimals <= 0) return round().toDouble();
    final factor = math.pow(10, decimals);
    return (this * factor).round() / factor;
  }

  /// Coerces this number to be within the range [min] and [max].
  ///
  /// Example:
  /// ```dart
  /// print(15.coerceIn(0, 10)); // 10
  /// print((-5).coerceIn(0, 10)); // 0
  /// ```
  num coerceIn(num min, num max) {
    if (min > max) {
      throw ArgumentError('min ($min) cannot be greater than max ($max).');
    }
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Coerces this number to be at least [min].
  ///
  /// Example:
  /// ```dart
  /// print(5.coerceAtLeast(10)); // 10
  /// ```
  num coerceAtLeast(num min) => this < min ? min : this;

  /// Coerces this number to be at most [max].
  ///
  /// Example:
  /// ```dart
  /// print(15.coerceAtMost(10)); // 10
  /// ```
  num coerceAtMost(num max) => this > max ? max : this;
}

/// Extensions on the [int] type to provide integer-specific helpers.
extension IntKnife on int {
  /// Formats this integer (bytes) as a human-readable file size string.
  ///
  /// Example:
  /// ```dart
  /// print(1536.toFileSizeString()); // '1.5 KB'
  /// print(1048576.toFileSizeString()); // '1.0 MB'
  /// ```
  String toFileSizeString() {
    if (this <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB'];
    var i = 0;
    var size = toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    if (i == 0) {
      return '$this B';
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Formats this integer as an ordinal number string.
  ///
  /// Example:
  /// ```dart
  /// print(1.toOrdinal()); // '1st'
  /// print(22.toOrdinal()); // '22nd'
  /// ```
  String toOrdinal() {
    if (this < 0) return toString();
    final mod100 = this % 100;
    if (mod100 >= 11 && mod100 <= 13) {
      return '${this}th';
    }
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  /// Converts this integer to a Roman numeral string.
  ///
  /// Only supports values between 1 and 3999. Returns empty string for invalid ranges.
  ///
  /// Example:
  /// ```dart
  /// print(4.toRoman()); // 'IV'
  /// print(2026.toRoman()); // 'MMXXVI'
  /// ```
  String toRoman() {
    if (this <= 0 || this >= 4000) return '';
    const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    const symbols = [
      'M',
      'CM',
      'D',
      'CD',
      'C',
      'XC',
      'L',
      'XL',
      'X',
      'IX',
      'V',
      'IV',
      'I',
    ];
    var num = this;
    final roman = StringBuffer();
    for (var i = 0; i < values.length; i++) {
      while (num >= values[i]) {
        num -= values[i];
        roman.write(symbols[i]);
      }
    }
    return roman.toString();
  }

  /// Formats this integer to a compact string notation (e.g. 1.2K, 1.5M).
  ///
  /// Example:
  /// ```dart
  /// print(1500.toCompactString()); // '1.5K'
  /// print(1500000.toCompactString()); // '1.5M'
  /// ```
  String toCompactString() {
    final absVal = abs();
    if (absVal < 1000) return toString();
    const suffixes = ['', 'K', 'M', 'B', 'T'];
    var i = 0;
    var numVal = absVal.toDouble();
    while (numVal >= 1000 && i < suffixes.length - 1) {
      numVal /= 1000;
      i++;
    }
    final sign = this < 0 ? '-' : '';
    final formatted = numVal.toStringAsFixed(1);
    final cleanStr = formatted.endsWith('.0')
        ? formatted.substring(0, formatted.length - 2)
        : formatted;
    return '$sign$cleanStr${suffixes[i]}';
  }

  /// Converts this integer (representing milliseconds) into a [Duration].
  Duration get milliseconds => Duration(milliseconds: this);

  /// Converts this integer (representing seconds) into a [Duration].
  Duration get seconds => Duration(seconds: this);

  /// Converts this integer (representing minutes) into a [Duration].
  Duration get minutes => Duration(minutes: this);

  /// Converts this integer (representing hours) into a [Duration].
  Duration get hours => Duration(hours: this);

  /// Converts this integer (representing days) into a [Duration].
  Duration get days => Duration(days: this);
}
