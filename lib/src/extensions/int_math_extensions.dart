/// Library-level comment for integer math extensions.
///
/// Contains integer number theory operations including primality checks, factorials,
/// greatest common divisor (GCD), least common multiple (LCM), digit operations,
/// and radix representation string formatting.
library;

import 'dart:math' as math;

/// Extensions on [int] to provide integer math and number theory utilities.
///
/// Example:
/// ```dart
/// final num = 12;
/// print(num.gcd(18)); // 6
/// ```
extension IntMathKnife on int {
  /// Checks if this integer is a prime number.
  ///
  /// Uses a trial division primality test optimized with the 6k±1 method.
  ///
  /// Example:
  /// ```dart
  /// print(17.isPrime); // true
  /// print(4.isPrime); // false
  /// ```
  bool get isPrime {
    if (this <= 1) return false;
    if (this <= 3) return true;
    if (this % 2 == 0 || this % 3 == 0) return false;

    final limit = math.sqrt(this).floor();
    for (var i = 5; i <= limit; i += 6) {
      if (this % i == 0 || this % (i + 2) == 0) return false;
    }
    return true;
  }

  /// Calculates the factorial of this integer (n!).
  ///
  /// Returns `1` if this value is 0 or 1. Returns `-1` if this value is negative.
  ///
  /// Example:
  /// ```dart
  /// print(5.factorial()); // 120
  /// print((-3).factorial()); // -1
  /// ```
  int factorial() {
    if (this < 0) return -1;
    var result = 1;
    for (var i = 2; i <= this; i++) {
      result *= i;
    }
    return result;
  }

  /// Calculates the greatest common divisor (GCD) of this integer and [other].
  ///
  /// Uses the Euclidean algorithm.
  ///
  /// Example:
  /// ```dart
  /// print(24.gcd(18)); // 6
  /// ```
  int gcd(int other) {
    var a = abs();
    var b = other.abs();
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  /// Calculates the least common multiple (LCM) of this integer and [other].
  ///
  /// Returns `0` if either operand is `0`.
  ///
  /// Example:
  /// ```dart
  /// print(12.lcm(18)); // 36
  /// ```
  int lcm(int other) {
    if (this == 0 || other == 0) return 0;
    final greatestCommonDivisor = gcd(other);
    if (greatestCommonDivisor == 0) return 0;
    return (this ~/ greatestCommonDivisor * other).abs();
  }

  /// Splits the absolute value of this integer into its individual digits.
  ///
  /// Example:
  /// ```dart
  /// print(105.digits); // [1, 0, 5]
  /// print((-42).digits); // [4, 2]
  /// ```
  List<int> get digits {
    final str = abs().toString();
    return str.codeUnits.map((cu) => cu - 48).toList();
  }

  /// Sums the individual digits of the absolute value of this integer.
  ///
  /// Example:
  /// ```dart
  /// print(123.digitSum); // 6
  /// print((-45).digitSum); // 9
  /// ```
  int get digitSum => digits.fold(0, (sum, digit) => sum + digit);

  /// Converts this integer to a binary string representation.
  ///
  /// Example:
  /// ```dart
  /// print(10.toBinaryString()); // '1010'
  /// ```
  String toBinaryString() => toRadixString(2);

  /// Converts this integer to an octal string representation.
  ///
  /// Example:
  /// ```dart
  /// print(8.toOctalString()); // '10'
  /// ```
  String toOctalString() => toRadixString(8);
}
