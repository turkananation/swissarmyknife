/// Advanced Date/Time truncation, calendar week day lookups, and Duration formatting.
///
/// Contains precise interval truncation, next/previous weekday searches, and
/// concise/human-readable Duration serializers.
library;

/// Intervals for date/time truncation.
enum DateTimeInterval {
  /// Year interval.
  year,

  /// Month interval.
  month,

  /// Day interval.
  day,

  /// Hour interval.
  hour,

  /// Minute interval.
  minute,

  /// Second interval.
  second,
}

/// Extensions on [DateTime] for advanced interval-based time calculation.
extension DateTimeAdvancedKnife on DateTime {
  /// Truncates smaller fields of this DateTime based on [interval].
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 6, 26, 15, 30, 45, 123);
  /// print(date.truncateTo(DateTimeInterval.day)); // 2026-06-26 00:00:00.000
  /// ```
  DateTime truncateTo(DateTimeInterval interval) {
    if (isUtc) {
      switch (interval) {
        case DateTimeInterval.year:
          return DateTime.utc(year);
        case DateTimeInterval.month:
          return DateTime.utc(year, month);
        case DateTimeInterval.day:
          return DateTime.utc(year, month, day);
        case DateTimeInterval.hour:
          return DateTime.utc(year, month, day, hour);
        case DateTimeInterval.minute:
          return DateTime.utc(year, month, day, hour, minute);
        case DateTimeInterval.second:
          return DateTime.utc(year, month, day, hour, minute, second);
      }
    }
    switch (interval) {
      case DateTimeInterval.year:
        return DateTime(year);
      case DateTimeInterval.month:
        return DateTime(year, month);
      case DateTimeInterval.day:
        return DateTime(year, month, day);
      case DateTimeInterval.hour:
        return DateTime(year, month, day, hour);
      case DateTimeInterval.minute:
        return DateTime(year, month, day, hour, minute);
      case DateTimeInterval.second:
        return DateTime(year, month, day, hour, minute, second);
    }
  }

  /// Finds the next occurrence of [dayOfWeek] (1 = Monday, 7 = Sunday).
  ///
  /// Example:
  /// ```dart
  /// // If today is Friday (5), next weekday Monday (1) is in 3 days.
  /// final nextMon = DateTime.now().nextWeekday(DateTime.monday);
  /// ```
  DateTime nextWeekday(int dayOfWeek) {
    if (dayOfWeek < 1 || dayOfWeek > 7) {
      throw ArgumentError('dayOfWeek must be between 1 and 7.');
    }
    var daysToAdd = dayOfWeek - weekday;
    if (daysToAdd <= 0) daysToAdd += 7;
    return add(Duration(days: daysToAdd));
  }

  /// Finds the previous occurrence of [dayOfWeek] (1 = Monday, 7 = Sunday).
  ///
  /// Example:
  /// ```dart
  /// final lastMon = DateTime.now().previousWeekday(DateTime.monday);
  /// ```
  DateTime previousWeekday(int dayOfWeek) {
    if (dayOfWeek < 1 || dayOfWeek > 7) {
      throw ArgumentError('dayOfWeek must be between 1 and 7.');
    }
    var daysToSubtract = weekday - dayOfWeek;
    if (daysToSubtract <= 0) daysToSubtract += 7;
    return subtract(Duration(days: daysToSubtract));
  }
}

/// Extensions on [Duration] for formatting and humanization.
extension DurationKnife on Duration {
  /// Formats this duration as a concise string omitting zero fields (e.g. 2d 4h 12m).
  ///
  /// Example:
  /// ```dart
  /// final dur = Duration(days: 2, hours: 4, seconds: 12);
  /// print(dur.toFormattedString()); // '2d 4h 12s'
  /// ```
  String toFormattedString() {
    if (inMicroseconds == 0) return '0s';

    final days = inDays;
    final hours = inHours % 24;
    final minutes = inMinutes % 60;
    final seconds = inSeconds % 60;

    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0) parts.add('${seconds}s');

    if (parts.isEmpty) {
      final ms = inMilliseconds;
      if (ms > 0) return '${ms}ms';
      return '${inMicroseconds}us';
    }

    return parts.join(' ');
  }

  /// Formats this duration to a comma-separated human-readable string.
  ///
  /// Example:
  /// ```dart
  /// final dur = Duration(days: 2, hours: 4, minutes: 12);
  /// print(dur.toHumanReadable()); // '2 days, 4 hours, 12 minutes'
  /// ```
  String toHumanReadable() {
    if (inMicroseconds == 0) return '0 seconds';

    final days = inDays;
    final hours = inHours % 24;
    final minutes = inMinutes % 60;
    final seconds = inSeconds % 60;

    final parts = <String>[];
    if (days > 0) {
      parts.add('$days ${days == 1 ? 'day' : 'days'}');
    }
    if (hours > 0) {
      parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
    }
    if (minutes > 0) {
      parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
    }
    if (seconds > 0) {
      parts.add('$seconds ${seconds == 1 ? 'second' : 'seconds'}');
    }

    if (parts.isEmpty) {
      final ms = inMilliseconds;
      if (ms > 0) return '$ms milliseconds';
      return '$inMicroseconds microseconds';
    }

    return parts.join(', ');
  }
}
