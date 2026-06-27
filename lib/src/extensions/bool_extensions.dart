/// Extension methods on boolean values.
///
/// Contains helpers for boolean conversions, conditional executions, and
/// ternary shorthand operations.
library;

/// Extensions on the [bool] type to provide fluent utility methods.
///
/// Example:
/// ```dart
/// final isEnabled = true;
/// print(isEnabled.toYesNo()); // 'Yes'
/// ```
extension BoolKnife on bool {
  /// Converts this boolean to an integer.
  ///
  /// Returns `1` if `true`, and `0` if `false`.
  ///
  /// Example:
  /// ```dart
  /// print(true.toInt()); // 1
  /// print(false.toInt()); // 0
  /// ```
  int toInt() => this ? 1 : 0;

  /// Converts this boolean to a 'Yes' or 'No' string.
  ///
  /// Returns `'Yes'` if `true`, and `'No'` if `false`.
  ///
  /// Example:
  /// ```dart
  /// print(true.toYesNo()); // 'Yes'
  /// ```
  String toYesNo() => this ? 'Yes' : 'No';

  /// Converts this boolean to an 'On' or 'Off' string.
  ///
  /// Returns `'On'` if `true`, and `'Off'` if `false`.
  ///
  /// Example:
  /// ```dart
  /// print(true.toOnOff()); // 'On'
  /// ```
  String toOnOff() => this ? 'On' : 'Off';

  /// Converts this boolean to an 'Enabled' or 'Disabled' string.
  ///
  /// Returns `'Enabled'` if `true`, and `'Disabled'` if `false`.
  ///
  /// Example:
  /// ```dart
  /// print(true.toEnabledDisabled()); // 'Enabled'
  /// ```
  String toEnabledDisabled() => this ? 'Enabled' : 'Disabled';

  /// Selects a value based on this boolean's state.
  ///
  /// Returns [isTrue] if `true`, or [isFalse] if `false`.
  ///
  /// Example:
  /// ```dart
  /// final color = isPrimary.when(isTrue: Colors.blue, isFalse: Colors.grey);
  /// ```
  T when<T>({
    required T isTrue,
    required T isFalse,
  }) =>
      this ? isTrue : isFalse;

  /// Executes [action] if this boolean is `true`.
  ///
  /// Returns this boolean to allow method chaining.
  ///
  /// Example:
  /// ```dart
  /// hasAccess.ifTrue(() => print('Access granted'));
  /// ```
  bool ifTrue(void Function() action) {
    if (this) {
      action();
    }
    return this;
  }

  /// Executes [action] if this boolean is `false`.
  ///
  /// Returns this boolean to allow method chaining.
  ///
  /// Example:
  /// ```dart
  /// hasAccess.ifFalse(() => print('Access denied'));
  /// ```
  bool ifFalse(void Function() action) {
    if (!this) {
      action();
    }
    return this;
  }
}
