/// Library-level comment for duration extra extensions.
///
/// Contains bridge methods between Duration and DateTime to resolve relative dates,
/// as well as conversions into whole weeks and approximate whole months.
library;

/// Extensions on [Duration] to provide DateTime bridge and unit conversion helpers.
///
/// Example:
/// ```dart
/// final duration = Duration(days: 14);
/// print(duration.inWholeWeeks); // 2
/// ```
extension DurationExtraKnife on Duration {
  /// Returns a [DateTime] representing this duration in the future relative to now.
  ///
  /// Example:
  /// ```dart
  /// final nextWeek = Duration(days: 7).fromNow;
  /// ```
  DateTime get fromNow => DateTime.now().add(this);

  /// Returns a [DateTime] representing this duration in the past relative to now.
  ///
  /// Example:
  /// ```dart
  /// final lastWeek = Duration(days: 7).ago;
  /// ```
  DateTime get ago => DateTime.now().subtract(this);

  /// Returns the duration in complete whole weeks (`inDays ~/ 7`).
  ///
  /// Example:
  /// ```dart
  /// print(Duration(days: 15).inWholeWeeks); // 2
  /// ```
  int get inWholeWeeks => inDays ~/ 7;

  /// Returns the duration in approximate whole months (`inDays ~/ 30`).
  ///
  /// > [!IMPORTANT]
  /// > This is an approximation based on a fixed 30-day month duration, as
  /// > months have variable lengths.
  ///
  /// Example:
  /// ```dart
  /// print(Duration(days: 62).inWholeMonths); // 2
  /// ```
  int get inWholeMonths => inDays ~/ 30;
}
