/// Extension methods on DateTime.
///
/// Contains comparisons, range assertions, start/end of period boundaries,
/// business day math, age calculator, ISO week calculations, and formatting.
library;

/// Extensions on the [DateTime] type to provide fluent date/time operations.
///
/// Example:
/// ```dart
/// final now = DateTime.now();
/// print(now.isWeekend); // true if Sat/Sun
/// ```
extension DateTimeKnife on DateTime {
  /// Checks if this date matches today's date.
  bool get isToday => isSameDay(DateTime.now());

  /// Checks if this date matches tomorrow's date.
  bool get isTomorrow => isSameDay(DateTime.now().add(const Duration(days: 1)));

  /// Checks if this date matches yesterday's date.
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Checks if this date is a Saturday or Sunday.
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Checks if this date is a weekday (Monday through Friday).
  bool get isWeekday => !isWeekend;

  /// Checks if this date is on the same year, month, and day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Checks if this date is on the same year and month as [other].
  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  /// Checks if this date is on the same year as [other].
  bool isSameYear(DateTime other) => year == other.year;

  /// Returns a new [DateTime] at midnight (00:00:00.000) of this day.
  DateTime get startOfDay =>
      isUtc ? DateTime.utc(year, month, day) : DateTime(year, month, day);

  /// Returns a new [DateTime] at the end (23:59:59.999) of this day.
  DateTime get endOfDay => isUtc
      ? DateTime.utc(year, month, day, 23, 59, 59, 999, 999)
      : DateTime(year, month, day, 23, 59, 59, 999, 999);

  /// Returns a new [DateTime] representing the start of the week.
  ///
  /// By default, the week starts on [DateTime.monday].
  DateTime startOfWeek({int startDay = DateTime.monday}) {
    var diff = weekday - startDay;
    if (diff < 0) diff += 7;
    return subtract(Duration(days: diff)).startOfDay;
  }

  /// Returns a new [DateTime] representing the end of the week.
  ///
  /// By default, the week starts on [DateTime.monday].
  DateTime endOfWeek({int startDay = DateTime.monday}) {
    return startOfWeek(startDay: startDay).add(const Duration(days: 6)).endOfDay;
  }

  /// Returns a new [DateTime] representing the first day of this month.
  DateTime get startOfMonth =>
      isUtc ? DateTime.utc(year, month, 1) : DateTime(year, month, 1);

  /// Returns a new [DateTime] representing the last day of this month.
  DateTime get endOfMonth {
    return isUtc
        ? DateTime.utc(year, month, daysInMonth, 23, 59, 59, 999, 999)
        : DateTime(year, month, daysInMonth, 23, 59, 59, 999, 999);
  }

  /// Returns a new [DateTime] representing January 1st of this year.
  DateTime get startOfYear =>
      isUtc ? DateTime.utc(year, 1, 1) : DateTime(year, 1, 1);

  /// Returns a new [DateTime] representing December 31st of this year.
  DateTime get endOfYear => isUtc
      ? DateTime.utc(year, 12, 31, 23, 59, 59, 999, 999)
      : DateTime(year, 12, 31, 23, 59, 59, 999, 999);

  /// Returns the number of days in the current month.
  int get daysInMonth {
    const days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && isLeapYear) return 29;
    return days[month];
  }

  /// Checks if the year of this date is a leap year.
  bool get isLeapYear =>
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  /// Returns the quarter (1 through 4) of this date.
  int get quarter => ((month - 1) / 3).floor() + 1;

  /// Returns the ISO 8601 week number of this date (1 through 53).
  int get weekOfYear {
    final thurs = DateTime(year, month, day + (4 - weekday));
    final yearStart = DateTime(thurs.year, 1, 1);
    var firstThurs = yearStart;
    if (firstThurs.weekday != DateTime.thursday) {
      firstThurs = DateTime(thurs.year, 1, 1 + ((4 - yearStart.weekday) % 7));
    }
    final diff = thurs.difference(firstThurs).inDays;
    return (diff / 7).floor() + 1;
  }

  /// Formats the difference between this date and [DateTime.now] as a relative time string.
  ///
  /// Example:
  /// ```dart
  /// print(yesterday.timeAgo()); // 'yesterday'
  /// ```
  String timeAgo() {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.isNegative) return 'in the future';
    if (diff.inSeconds < 45) return 'just now';
    if (diff.inMinutes < 45) {
      final mins = diff.inMinutes;
      return '$mins ${mins == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 22) {
      final hrs = diff.inHours;
      return '$hrs ${hrs == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 26) {
      if (diff.inDays == 1) return 'yesterday';
      return '${diff.inDays} days ago';
    }
    final months = (diff.inDays / 30).floor();
    if (months < 11) {
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
    final years = (diff.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }

  /// Formats the difference between [DateTime.now] and this future date as a relative time string.
  ///
  /// Example:
  /// ```dart
  /// print(tomorrow.timeUntil()); // 'tomorrow'
  /// ```
  String timeUntil() {
    final now = DateTime.now();
    final diff = difference(now);
    if (diff.isNegative) return 'in the past';
    if (diff.inSeconds < 45) return 'just now';
    if (diff.inMinutes < 45) {
      final mins = diff.inMinutes;
      return 'in $mins ${mins == 1 ? 'minute' : 'minutes'}';
    }
    if (diff.inHours < 22) {
      final hrs = diff.inHours;
      return 'in $hrs ${hrs == 1 ? 'hour' : 'hours'}';
    }
    if (diff.inDays < 26) {
      if (diff.inDays == 1) return 'tomorrow';
      return 'in ${diff.inDays} days';
    }
    final months = (diff.inDays / 30).floor();
    if (months < 11) {
      return 'in $months ${months == 1 ? 'month' : 'months'}';
    }
    final years = (diff.inDays / 365).floor();
    return 'in $years ${years == 1 ? 'year' : 'years'}';
  }

  /// Formats this date/time according to a simple custom pattern.
  ///
  /// Supports:
  /// - `yyyy` / `yy` (year)
  /// - `MMMM` / `MMM` / `MM` / `M` (month name/number)
  /// - `dd` / `d` (day)
  /// - `EEEE` / `EEE` (weekday name)
  /// - `HH` / `H` (hours, 24-hr)
  /// - `mm` / `m` (minutes)
  /// - `ss` / `s` (seconds)
  ///
  /// Example:
  /// ```dart
  /// print(now.format('yyyy-MM-dd HH:mm:ss')); // '2026-06-26 15:30:00'
  /// ```
  String format(String pattern) {
    const monthsShort = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const monthsFull = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const weekdaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const weekdaysFull = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    var result = pattern;
    result = result.replaceAll('yyyy', year.toString());
    result = result.replaceAll('yy', (year % 100).toString().padLeft(2, '0'));
    result = result.replaceAll('MMMM', monthsFull[month - 1]);
    result = result.replaceAll('MMM', monthsShort[month - 1]);
    result = result.replaceAll('MM', month.toString().padLeft(2, '0'));
    result = result.replaceAll('M', month.toString());
    result = result.replaceAll('dd', day.toString().padLeft(2, '0'));
    result = result.replaceAll('d', day.toString());
    result = result.replaceAll('EEEE', weekdaysFull[weekday - 1]);
    result = result.replaceAll('EEE', weekdaysShort[weekday - 1]);
    result = result.replaceAll('HH', hour.toString().padLeft(2, '0'));
    result = result.replaceAll('H', hour.toString());
    result = result.replaceAll('mm', minute.toString().padLeft(2, '0'));
    result = result.replaceAll('m', minute.toString());
    result = result.replaceAll('ss', second.toString().padLeft(2, '0'));
    result = result.replaceAll('s', second.toString());
    return result;
  }

  /// Adds [days] of business (weekday) days, skipping weekends (Sat/Sun).
  ///
  /// Example:
  /// ```dart
  /// // If today is Friday, adding 1 business day yields Monday
  /// print(friday.addBusinessDays(1));
  /// ```
  DateTime addBusinessDays(int days) {
    if (days == 0) return this;
    var current = this;
    var count = days.abs();
    final step = days > 0 ? 1 : -1;
    while (count > 0) {
      current = current.add(Duration(days: step));
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        count--;
      }
    }
    return current;
  }

  /// Returns the age (duration) from this date to [DateTime.now].
  Duration get age => DateTime.now().difference(this);

  /// Returns a copy of this [DateTime] with fields replaced.
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    if (isUtc) {
      return DateTime.utc(
        year ?? this.year,
        month ?? this.month,
        day ?? this.day,
        hour ?? this.hour,
        minute ?? this.minute,
        second ?? this.second,
        millisecond ?? this.millisecond,
        microsecond ?? this.microsecond,
      );
    }
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  /// Returns a new [DateTime] with the time parts stripped (set to midnight).
  DateTime toDateOnly() =>
      isUtc ? DateTime.utc(year, month, day) : DateTime(year, month, day);

  /// Checks if this date/time falls within [start] and [end] (inclusive).
  bool isBetween(DateTime start, DateTime end) {
    return (isAfter(start) || isAtSameMomentAs(start)) &&
        (isBefore(end) || isAtSameMomentAs(end));
  }
}
