/// Library-level comment for double extensions.
///
/// Contains precision checks, linear interpolation (lerp), inverse interpolation,
/// range remapping, and precision rounding utilities.
library;

/// Extensions on the [double] type to provide precision and math utilities.
///
/// Example:
/// ```dart
/// final value = 0.5;
/// print(value.lerp(10.0, 0.5)); // 5.0
/// ```
extension DoubleKnife on double {
  /// Performs linear interpolation between this and [other] at factor [t].
  ///
  /// The factor [t] is typically in the range `[0.0, 1.0]`, representing the
  /// progression between this value and [other].
  ///
  /// Example:
  /// ```dart
  /// print(10.0.lerp(20.0, 0.5)); // 15.0
  /// print(0.0.lerp(100.0, 0.2)); // 20.0
  /// ```
  double lerp(double other, double t) => this + (other - this) * t;

  /// Returns where this value falls in the range [[min], [max]] as a 0.0–1.0 ratio.
  ///
  /// Returns `0.0` if [min] is equal to [max] to avoid division by zero.
  ///
  /// Example:
  /// ```dart
  /// print(15.0.inverseLerp(10.0, 20.0)); // 0.5
  /// print(10.0.inverseLerp(10.0, 10.0)); // 0.0
  /// ```
  double inverseLerp(double min, double max) {
    if (min == max) return 0.0;
    return (this - min) / (max - min);
  }

  /// Remaps this value from input range [[inMin], [inMax]] to output range [[outMin], [outMax]].
  ///
  /// Combines [inverseLerp] on the input range with [lerp] on the output range.
  ///
  /// Example:
  /// ```dart
  /// print(5.0.remap(0.0, 10.0, 0.0, 100.0)); // 50.0
  /// ```
  double remap(
    double inMin,
    double inMax,
    double outMin,
    double outMax,
  ) {
    final t = inverseLerp(inMin, inMax);
    return outMin + (outMax - outMin) * t;
  }

  /// Compares this double with [other] for approximate equality with a given [epsilon] tolerance.
  ///
  /// Example:
  /// ```dart
  /// print(0.1 + 0.2 == 0.3); // false
  /// print((0.1 + 0.2).isApproximately(0.3)); // true
  /// ```
  bool isApproximately(double other, {double epsilon = 1e-10}) {
    return (this - other).abs() <= epsilon;
  }

  /// Rounds this double to the specified number of [significantDigits].
  ///
  /// The [significantDigits] must be greater than or equal to 1.
  ///
  /// Example:
  /// ```dart
  /// print(123.456.toPrecision(3)); // 123.0
  /// print(0.0012345.toPrecision(2)); // 0.0012
  /// ```
  double toPrecision(int significantDigits) {
    if (significantDigits < 1) {
      throw ArgumentError.value(
        significantDigits,
        'significantDigits',
        'Must be greater than or equal to 1.',
      );
    }
    if (isNaN || isInfinite || this == 0.0) {
      return this;
    }
    return double.parse(toStringAsExponential(significantDigits - 1));
  }
}
