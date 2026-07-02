/// Debounces actions so only the latest scheduled action runs.
///
/// Use [Debouncer] for search boxes, resize handlers, and other bursty inputs
/// where only the final event should trigger work.
library;

import 'dart:async';

/// Runs the latest action after a quiet [duration].
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(const Duration(milliseconds: 300));
/// debouncer.run(() => print('search'));
/// ```
final class Debouncer {
  /// Creates a debouncer with the given quiet [duration].
  Debouncer(this.duration);

  /// The quiet period required before an action is executed.
  final Duration duration;

  Timer? _timer;
  bool _isDisposed = false;

  /// Whether an action is currently scheduled.
  bool get isActive => _timer?.isActive ?? false;

  /// Whether this debouncer has been disposed.
  bool get isDisposed => _isDisposed;

  /// Schedules [action], replacing any pending action.
  ///
  /// Example:
  /// ```dart
  /// debouncer.run(() => submitQuery(query));
  /// ```
  void run(void Function() action) {
    _ensureNotDisposed();
    cancel();
    _timer = Timer(duration, () {
      if (!_isDisposed) {
        action();
      }
    });
  }

  /// Cancels any pending action.
  ///
  /// Example:
  /// ```dart
  /// debouncer.cancel();
  /// ```
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels pending work and prevents future scheduling.
  ///
  /// Example:
  /// ```dart
  /// debouncer.dispose();
  /// ```
  void dispose() {
    if (_isDisposed) return;
    cancel();
    _isDisposed = true;
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot use a disposed Debouncer.');
    }
  }
}
