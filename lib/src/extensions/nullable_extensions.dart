/// Library-level comment for nullable type extensions.
///
/// Contains chainable null-handling utilities such as default values,
/// lazy computations, and safe mapping guards.
library;

/// Extensions on nullable types [T?] to provide chainable null-handling utilities.
///
/// Example:
/// ```dart
/// final int? value = null;
/// print(value.orDefault(10)); // 10
/// ```
extension NullableKnife<T extends Object> on T? {
  /// Returns this value if it is not null, otherwise returns [value].
  ///
  /// This is equivalent to Dart's `??` operator but allows chainable calls.
  ///
  /// Example:
  /// ```dart
  /// final int? number = null;
  /// print(number.orDefault(5).toString()); // '5'
  /// ```
  T orDefault(T value) => this ?? value;

  /// Returns this value if it is not null, otherwise evaluates and returns [compute].
  ///
  /// This is equivalent to Dart's `?? compute()` operator but allows chainable calls.
  ///
  /// Example:
  /// ```dart
  /// final int? number = null;
  /// print(number.orCompute(() => 5).toString()); // '5'
  /// ```
  T orCompute(T Function() compute) => this ?? compute();

  /// Applies the [transform] function to this value only if it is not null.
  ///
  /// Returns the transformed value, or `null` if this value is null.
  ///
  /// Example:
  /// ```dart
  /// final String? name = 'hello';
  /// print(name.guard((n) => n.toUpperCase())); // 'HELLO'
  ///
  /// final String? emptyName = null;
  /// print(emptyName.guard((n) => n.toUpperCase())); // null
  /// ```
  R? guard<R>(R Function(T value) transform) {
    final self = this;
    if (self == null) return null;
    return transform(self);
  }
}
