/// Cron expression parsing and lightweight task scheduling.
///
/// Supports five-field cron expressions: minute hour day-of-month month
/// weekday. Fields support `*`, lists, ranges, steps, and month/weekday names.
library;

import 'dart:async';

/// Cron task callback.
typedef CronTask = FutureOr<void> Function();

/// Parsed five-field cron expression.
final class CronExpression {
  CronExpression._(
    this.source,
    this._minutes,
    this._hours,
    this._days,
    this._months,
    this._weekdays,
  );

  /// Parses a five-field cron [source].
  factory CronExpression.parse(String source) {
    final parts = source.trim().split(RegExp(r'\s+'));
    if (parts.length != 5) {
      throw FormatException('Cron expression must contain 5 fields.', source);
    }

    return CronExpression._(
      source,
      _CronField.parse(parts[0], min: 0, max: 59),
      _CronField.parse(parts[1], min: 0, max: 23),
      _CronField.parse(parts[2], min: 1, max: 31),
      _CronField.parse(parts[3], min: 1, max: 12, names: _monthNames),
      _CronField.parse(
        parts[4],
        min: 0,
        max: 7,
        names: _weekdayNames,
        normalize: _normalizeWeekday,
        wildcardMin: 1,
      ),
    );
  }

  /// Original expression source.
  final String source;

  final _CronField _minutes;
  final _CronField _hours;
  final _CronField _days;
  final _CronField _months;
  final _CronField _weekdays;

  /// Whether [dateTime] matches this expression.
  bool matches(DateTime dateTime) {
    return _minutes.matches(dateTime.minute) &&
        _hours.matches(dateTime.hour) &&
        _days.matches(dateTime.day) &&
        _months.matches(dateTime.month) &&
        _weekdays.matches(dateTime.weekday);
  }

  /// Returns the next matching minute strictly after [after].
  DateTime next(
    DateTime after, {
    Duration maxSearch = const Duration(days: 366),
  }) {
    final limit = after.add(maxSearch);
    var candidate = DateTime(
      after.year,
      after.month,
      after.day,
      after.hour,
      after.minute,
    ).add(const Duration(minutes: 1));

    while (!candidate.isAfter(limit)) {
      if (matches(candidate)) return candidate;
      candidate = candidate.add(const Duration(minutes: 1));
    }

    throw StateError('No matching cron occurrence found within $maxSearch.');
  }

  /// Generates [count] occurrences after [from].
  List<DateTime> occurrences(DateTime from, int count) {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'Must not be negative.');
    }

    final values = <DateTime>[];
    var cursor = from;
    for (var i = 0; i < count; i++) {
      final nextRun = next(cursor);
      values.add(nextRun);
      cursor = nextRun;
    }
    return List<DateTime>.unmodifiable(values);
  }

  @override
  String toString() => source;
}

/// Lightweight cron scheduler.
final class CronScheduler {
  /// Creates a scheduler.
  CronScheduler({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final List<CronScheduledTask> _tasks = [];
  Timer? _timer;
  bool _isRunning = false;

  /// Scheduled tasks.
  List<CronScheduledTask> get tasks {
    return List<CronScheduledTask>.unmodifiable(_tasks);
  }

  /// Whether timer-backed scheduling is active.
  bool get isRunning => _isRunning;

  /// Schedules [task] using a cron expression string or [CronExpression].
  CronScheduledTask schedule(Object expression, CronTask task, {String? name}) {
    final cron = switch (expression) {
      final CronExpression parsed => parsed,
      final String source => CronExpression.parse(source),
      _ => throw ArgumentError.value(
        expression,
        'expression',
        'Must be a CronExpression or String.',
      ),
    };

    final scheduled = CronScheduledTask._(
      name: name,
      expression: cron,
      task: task,
      nextRun: cron.next(_clock()),
      scheduler: this,
    );
    _tasks.add(scheduled);
    _scheduleTimer();
    return scheduled;
  }

  /// Starts timer-backed scheduling.
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _scheduleTimer();
  }

  /// Stops timer-backed scheduling without cancelling tasks.
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Runs all due tasks at [now] or the scheduler clock time.
  Future<List<CronRunResult>> runDue({DateTime? now}) async {
    final current = now ?? _clock();
    final due = _tasks
        .where((task) => !task.isCancelled && !task.nextRun.isAfter(current))
        .toList(growable: false);
    final results = <CronRunResult>[];

    for (final task in due) {
      results.add(await task._run(current));
    }

    _tasks.removeWhere((task) => task.isCancelled);
    _scheduleTimer();
    return List<CronRunResult>.unmodifiable(results);
  }

  /// Stops scheduling and cancels all tasks.
  void dispose() {
    stop();
    for (final task in List<CronScheduledTask>.of(_tasks)) {
      task.cancel();
    }
    _tasks.clear();
  }

  void _remove(CronScheduledTask task) {
    _tasks.remove(task);
    _scheduleTimer();
  }

  void _scheduleTimer() {
    _timer?.cancel();
    _timer = null;
    if (!_isRunning) return;

    final active = _tasks.where((task) => !task.isCancelled).toList();
    if (active.isEmpty) return;

    final now = _clock();
    final nextRun = active
        .map((task) => task.nextRun)
        .reduce((left, right) => left.isBefore(right) ? left : right);
    final delay = _nonNegative(nextRun.difference(now));

    _timer = Timer(delay, () async {
      await runDue(now: _clock());
    });
  }
}

/// Scheduled cron task.
final class CronScheduledTask {
  CronScheduledTask._({
    required this.name,
    required this.expression,
    required this.task,
    required this.scheduler,
    required this._nextRun,
  });

  /// Optional task name.
  final String? name;

  /// Cron expression.
  final CronExpression expression;

  /// Task callback.
  final CronTask task;

  final CronScheduler scheduler;
  DateTime _nextRun;
  int _runCount = 0;
  bool _isCancelled = false;

  /// Next scheduled run.
  DateTime get nextRun => _nextRun;

  /// Number of completed run attempts.
  int get runCount => _runCount;

  /// Whether this task was cancelled.
  bool get isCancelled => _isCancelled;

  /// Cancels this task.
  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    scheduler._remove(this);
  }

  Future<CronRunResult> _run(DateTime now) async {
    final scheduledAt = _nextRun;
    try {
      await Future<void>.sync(task);
      _runCount++;
      _nextRun = expression.next(now);
      return CronRunResult.success(this, scheduledAt: scheduledAt);
    } catch (error, stackTrace) {
      _runCount++;
      _nextRun = expression.next(now);
      return CronRunResult.failure(
        this,
        scheduledAt: scheduledAt,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Result of a cron task run.
final class CronRunResult {
  const CronRunResult._({
    required this.task,
    required this.scheduledAt,
    required this.isSuccess,
    this.error,
    this.stackTrace,
  });

  /// Successful task result.
  factory CronRunResult.success(
    CronScheduledTask task, {
    required DateTime scheduledAt,
  }) {
    return CronRunResult._(
      task: task,
      scheduledAt: scheduledAt,
      isSuccess: true,
    );
  }

  /// Failed task result.
  factory CronRunResult.failure(
    CronScheduledTask task, {
    required DateTime scheduledAt,
    required Object error,
    required StackTrace stackTrace,
  }) {
    return CronRunResult._(
      task: task,
      scheduledAt: scheduledAt,
      isSuccess: false,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Task that ran.
  final CronScheduledTask task;

  /// Scheduled time that became due.
  final DateTime scheduledAt;

  /// Whether the task completed without throwing.
  final bool isSuccess;

  /// Whether the task threw.
  bool get isFailure => !isSuccess;

  /// Thrown object, when failed.
  final Object? error;

  /// Stack trace, when failed.
  final StackTrace? stackTrace;
}

final class _CronField {
  const _CronField(this.values);

  factory _CronField.parse(
    String source, {
    required int min,
    required int max,
    Map<String, int> names = const {},
    int Function(int value)? normalize,
    int? wildcardMin,
  }) {
    if (source.trim().isEmpty) {
      throw FormatException('Cron field must not be empty.');
    }

    final values = <int>{};
    for (final part in source.split(',')) {
      _parsePart(
        part.trim(),
        values,
        min: min,
        max: max,
        names: names,
        normalize: normalize,
        wildcardMin: wildcardMin ?? min,
      );
    }
    return _CronField(Set<int>.unmodifiable(values));
  }

  final Set<int> values;

  bool matches(int value) => values.contains(value);
}

void _parsePart(
  String part,
  Set<int> values, {
  required int min,
  required int max,
  required Map<String, int> names,
  required int Function(int value)? normalize,
  required int wildcardMin,
}) {
  if (part.isEmpty) {
    throw FormatException('Cron field contains an empty list item.');
  }

  final stepParts = part.split('/');
  if (stepParts.length > 2) {
    throw FormatException('Cron field contains too many step separators.');
  }
  final body = stepParts[0];
  final step = stepParts.length == 2 ? int.tryParse(stepParts[1]) : 1;
  if (step == null || step <= 0) {
    throw FormatException('Cron step must be a positive integer.');
  }

  final (start, end) = switch (body) {
    '*' => (wildcardMin, max),
    _ when body.contains('-') => _parseRange(
      body,
      min: min,
      max: max,
      names: names,
    ),
    _ => _singleRange(_parseValue(body, min: min, max: max, names: names)),
  };

  if (start > end) {
    throw FormatException('Cron range start must be <= range end.');
  }

  for (var value = start; value <= end; value += step) {
    values.add(normalize?.call(value) ?? value);
  }
}

(int, int) _parseRange(
  String body, {
  required int min,
  required int max,
  required Map<String, int> names,
}) {
  final pieces = body.split('-');
  if (pieces.length != 2) {
    throw FormatException('Cron range must have one "-".');
  }
  return (
    _parseValue(pieces[0], min: min, max: max, names: names),
    _parseValue(pieces[1], min: min, max: max, names: names),
  );
}

(int, int) _singleRange(int value) => (value, value);

int _parseValue(
  String source, {
  required int min,
  required int max,
  required Map<String, int> names,
}) {
  final named = names[source.toUpperCase()];
  final value = named ?? int.tryParse(source);
  if (value == null || value < min || value > max) {
    throw FormatException(
      'Cron value "$source" must be between $min and $max.',
    );
  }
  return value;
}

int _normalizeWeekday(int value) => value == 0 ? 7 : value;

Duration _nonNegative(Duration duration) {
  return duration.isNegative ? Duration.zero : duration;
}

final Map<String, int> _monthNames = {
  'JAN': 1,
  'FEB': 2,
  'MAR': 3,
  'APR': 4,
  'MAY': 5,
  'JUN': 6,
  'JUL': 7,
  'AUG': 8,
  'SEP': 9,
  'OCT': 10,
  'NOV': 11,
  'DEC': 12,
};

final Map<String, int> _weekdayNames = {
  'SUN': 0,
  'MON': 1,
  'TUE': 2,
  'WED': 3,
  'THU': 4,
  'FRI': 5,
  'SAT': 6,
};
