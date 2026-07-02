/// Date ranges and simple recurrence helpers.
///
/// Use [DateRange] for inclusive date windows and [Recurrence] for lightweight
/// daily, weekly, monthly, and yearly occurrence generation.
library;

/// Inclusive date range.
///
/// Example:
/// ```dart
/// final range = DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 3));
/// print(range.days); // 3
/// ```
final class DateRange {
  /// Creates an inclusive range from [start] to [end].
  DateRange(this.start, this.end) {
    if (end.isBefore(start)) {
      throw ArgumentError.value(end, 'end', 'Must not be before start.');
    }
  }

  /// Start of the range.
  final DateTime start;

  /// End of the range.
  final DateTime end;

  /// Duration between [start] and [end].
  Duration get duration => end.difference(start);

  /// Number of calendar dates included in the range.
  int get days => end.difference(start).inDays + 1;

  /// Whether [date] is inside this range, inclusive.
  bool contains(DateTime date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  /// Whether this range overlaps [other].
  bool overlaps(DateRange other) {
    return contains(other.start) ||
        contains(other.end) ||
        other.contains(start);
  }

  /// Returns the overlapping range with [other], or `null`.
  DateRange? intersection(DateRange other) {
    if (!overlaps(other)) return null;
    final newStart = start.isAfter(other.start) ? start : other.start;
    final newEnd = end.isBefore(other.end) ? end : other.end;
    return DateRange(newStart, newEnd);
  }

  /// Iterates dates in the range using [step].
  Iterable<DateTime> iterate({Duration step = const Duration(days: 1)}) sync* {
    if (step <= Duration.zero) {
      throw ArgumentError.value(step, 'step', 'Must be greater than zero.');
    }

    var current = start;
    while (!current.isAfter(end)) {
      yield current;
      current = current.add(step);
    }
  }

  /// Returns all dates in this range using a one-day step.
  List<DateTime> toList() => iterate().toList();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start, $end)';
}

enum _RecurrenceUnit { day, week, month, year }

/// Simple calendar recurrence.
///
/// Example:
/// ```dart
/// final recurrence = Recurrence.weekly();
/// final next = recurrence.nextAfter(DateTime(2026, 1, 1));
/// ```
final class Recurrence {
  const Recurrence._(this._unit, this.interval);

  /// Creates a daily recurrence.
  factory Recurrence.daily({int interval = 1}) {
    return Recurrence._(_RecurrenceUnit.day, _validateInterval(interval));
  }

  /// Creates a weekly recurrence.
  factory Recurrence.weekly({int interval = 1}) {
    return Recurrence._(_RecurrenceUnit.week, _validateInterval(interval));
  }

  /// Creates a monthly recurrence.
  factory Recurrence.monthly({int interval = 1}) {
    return Recurrence._(_RecurrenceUnit.month, _validateInterval(interval));
  }

  /// Creates a yearly recurrence.
  factory Recurrence.yearly({int interval = 1}) {
    return Recurrence._(_RecurrenceUnit.year, _validateInterval(interval));
  }

  final _RecurrenceUnit _unit;

  /// Number of units between occurrences.
  final int interval;

  /// Generates [count] occurrences starting at [from].
  List<DateTime> occurrences(DateTime from, int count) {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'Must be non-negative.');
    }

    final values = <DateTime>[];
    var current = from;
    for (var i = 0; i < count; i++) {
      values.add(current);
      current = _add(current);
    }
    return values;
  }

  /// Returns the next occurrence strictly after [date].
  DateTime nextAfter(DateTime date) => _add(date);

  DateTime _add(DateTime date) {
    return switch (_unit) {
      _RecurrenceUnit.day => date.add(Duration(days: interval)),
      _RecurrenceUnit.week => date.add(Duration(days: interval * 7)),
      _RecurrenceUnit.month => _copyCalendar(date, monthOffset: interval),
      _RecurrenceUnit.year => _copyCalendar(date, yearOffset: interval),
    };
  }

  static int _validateInterval(int interval) {
    if (interval <= 0) {
      throw ArgumentError.value(interval, 'interval', 'Must be positive.');
    }
    return interval;
  }
}

DateTime _copyCalendar(
  DateTime date, {
  int yearOffset = 0,
  int monthOffset = 0,
}) {
  final totalMonths = date.year * 12 + (date.month - 1) + monthOffset;
  final year = totalMonths ~/ 12 + yearOffset;
  final month = totalMonths % 12 + 1;
  final day = date.day.clamp(1, _daysInMonth(year, month));

  if (date.isUtc) {
    return DateTime.utc(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
  return DateTime(
    year,
    month,
    day,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}

int _daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}
