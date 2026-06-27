/// Kotlin-inspired scope functions and safe type casting helpers.
///
/// Contains functional extensions to allow cleaner method chaining,
/// side effects, filtering, and safe casting on any object.
library;

/// Kotlin-like scope functions on any type [T].
///
/// Example:
/// ```dart
/// final length = 'hello'.let((s) => s.length); // 5
/// ```
extension ScopeKnife<T> on T {
  /// Calls the specified function [transform] with `this` value as its
  /// argument and returns its result.
  ///
  /// Example:
  /// ```dart
  /// final result = 'hello'.let((s) => s.toUpperCase()); // 'HELLO'
  /// ```
  R let<R>(R Function(T value) transform) => transform(this);

  /// Calls the specified function [action] with `this` value as its argument
  /// and returns `this` value.
  ///
  /// Typically used for side effects, like logging or debugging.
  ///
  /// Example:
  /// ```dart
  /// final value = 'hello'.also((s) => print(s)); // Prints 'hello', returns 'hello'
  /// ```
  T also(void Function(T value) action) {
    action(this);
    return this;
  }

  /// Returns `this` value if it satisfies the given [predicate], or `null`
  /// otherwise.
  ///
  /// Example:
  /// ```dart
  /// final positiveOrNull = 5.takeIf((x) => x > 0); // 5
  /// final negativeOrNull = 5.takeIf((x) => x < 0); // null
  /// ```
  T? takeIf(bool Function(T value) predicate) => predicate(this) ? this : null;

  /// Returns `this` value if it does NOT satisfy the given [predicate], or
  /// `null` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final nonZero = 0.takeUnless((x) => x == 0); // null
  /// final five = 5.takeUnless((x) => x == 0); // 5
  /// ```
  T? takeUnless(bool Function(T value) predicate) =>
      !predicate(this) ? this : null;
}

/// Type casting and checking helpers on nullable objects.
///
/// Example:
/// ```dart
/// final dynamic val = 'hello';
/// final stringVal = val.tryCast<String>(); // 'hello'
/// ```
extension CastKnife on Object? {
  /// Safely attempts to cast this object to type [R].
  ///
  /// Returns the casted value if this object is an instance of [R],
  /// or `null` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final dynamic val = 123;
  /// final stringVal = val.tryCast<String>(); // null
  /// final intVal = val.tryCast<int>(); // 123
  /// ```
  R? tryCast<R>() {
    final value = this;
    return value is R ? value : null;
  }

  /// Checks if this object is of type [R].
  ///
  /// Example:
  /// ```dart
  /// final dynamic val = 'hello';
  /// print(val.isType<String>()); // true
  /// ```
  bool isType<R>() => this is R;
}
