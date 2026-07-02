/// Console logging helpers with levels, tags, colors, and stack traces.
///
/// Use [Log] for lightweight application diagnostics without wiring a logging
/// framework through every call site.
library;

/// Receives a formatted log line.
typedef LogOutput = void Function(String line);

/// Log severity levels in increasing priority order.
///
/// Example:
/// ```dart
/// Log.config(minLevel: LogLevel.info);
/// ```
enum LogLevel {
  /// Verbose diagnostic details.
  debug(10, 'DEBUG', '\x1B[90m'),

  /// Informational events.
  info(20, 'INFO', '\x1B[34m'),

  /// Recoverable problems.
  warning(30, 'WARN', '\x1B[33m'),

  /// Errors that should be investigated.
  error(40, 'ERROR', '\x1B[31m'),

  /// Fatal errors after which normal execution may not continue.
  fatal(50, 'FATAL', '\x1B[35m');

  const LogLevel(this.priority, this.label, this.ansiColor);

  /// Numeric severity used for filtering.
  final int priority;

  /// Short display label.
  final String label;

  /// ANSI color prefix for this level.
  final String ansiColor;
}

/// Immutable logger configuration.
///
/// Example:
/// ```dart
/// Log.config(showTimestamp: true, useColors: true);
/// ```
final class LogConfig {
  /// Creates logger configuration.
  const LogConfig({
    this.minLevel = LogLevel.debug,
    this.showTimestamp = false,
    this.useColors = false,
    this.enabledTags,
    this.output,
    this.clock,
  });

  /// Minimum emitted log level.
  final LogLevel minLevel;

  /// Whether formatted lines include an ISO-8601 timestamp.
  final bool showTimestamp;

  /// Whether ANSI color escape sequences are emitted.
  final bool useColors;

  /// Optional allow-list of tags. Untagged lines are skipped when this is set.
  final Set<String>? enabledTags;

  /// Optional output sink. Defaults to [print].
  final LogOutput? output;

  /// Optional timestamp source. Defaults to [DateTime.now].
  final DateTime Function()? clock;

  /// Returns a copy with selected fields changed.
  LogConfig copyWith({
    LogLevel? minLevel,
    bool? showTimestamp,
    bool? useColors,
    Set<String>? enabledTags,
    bool clearEnabledTags = false,
    LogOutput? output,
    bool clearOutput = false,
    DateTime Function()? clock,
    bool clearClock = false,
  }) {
    return LogConfig(
      minLevel: minLevel ?? this.minLevel,
      showTimestamp: showTimestamp ?? this.showTimestamp,
      useColors: useColors ?? this.useColors,
      enabledTags: clearEnabledTags ? null : enabledTags ?? this.enabledTags,
      output: clearOutput ? null : output ?? this.output,
      clock: clearClock ? null : clock ?? this.clock,
    );
  }
}

/// Static logger facade.
///
/// Example:
/// ```dart
/// Log.i('Application started', tag: 'BOOT');
/// ```
final class Log {
  const Log._();

  static const _defaultConfig = LogConfig();
  static LogConfig _config = _defaultConfig;

  /// Current logger configuration.
  static LogConfig get currentConfig => _config;

  /// Configures logger behavior.
  ///
  /// Example:
  /// ```dart
  /// Log.config(minLevel: LogLevel.warning, showTimestamp: true);
  /// ```
  static void config({
    LogLevel minLevel = LogLevel.debug,
    bool showTimestamp = false,
    bool useColors = false,
    Set<String>? enabledTags,
    LogOutput? output,
    DateTime Function()? clock,
  }) {
    _config = LogConfig(
      minLevel: minLevel,
      showTimestamp: showTimestamp,
      useColors: useColors,
      enabledTags: enabledTags == null ? null : Set.unmodifiable(enabledTags),
      output: output,
      clock: clock,
    );
  }

  /// Restores default logger behavior.
  static void reset() {
    _config = _defaultConfig;
  }

  /// Emits a debug line.
  static void d(Object? message, {String? tag}) {
    log(LogLevel.debug, message, tag: tag);
  }

  /// Emits an info line.
  static void i(Object? message, {String? tag}) {
    log(LogLevel.info, message, tag: tag);
  }

  /// Emits a warning line.
  static void w(Object? message, {String? tag}) {
    log(LogLevel.warning, message, tag: tag);
  }

  /// Emits an error line with optional [error] and [stackTrace].
  static void e(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Emits a fatal line with optional [error] and [stackTrace].
  static void wtf(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Emits [message] at [level] if allowed by current configuration.
  ///
  /// Example:
  /// ```dart
  /// Log.log(LogLevel.warning, 'Disk almost full', tag: 'FS');
  /// ```
  static void log(
    LogLevel level,
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_shouldLog(level, tag)) return;

    final output = _config.output ?? print;
    final buffer = StringBuffer();
    if (_config.showTimestamp) {
      final now = (_config.clock ?? DateTime.now)();
      buffer.write('${now.toIso8601String()} ');
    }

    buffer.write(level.label);
    if (tag != null && tag.isNotEmpty) {
      buffer.write(' [$tag]');
    }
    buffer.write(' $message');
    if (error != null) {
      buffer.write(' | $error');
    }

    final line = buffer.toString();
    output(_config.useColors ? '${level.ansiColor}$line\x1B[0m' : line);

    if (stackTrace != null &&
        (level == LogLevel.error || level == LogLevel.fatal)) {
      output(stackTrace.toString());
    }
  }

  static bool _shouldLog(LogLevel level, String? tag) {
    if (level.priority < _config.minLevel.priority) return false;

    final enabledTags = _config.enabledTags;
    if (enabledTags == null) return true;
    if (tag == null) return false;
    return enabledTags.contains(tag);
  }
}
