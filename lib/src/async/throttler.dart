/// Throttles actions so work runs at most once per duration.
///
/// Use [Throttler] for scroll, pointer, resize, and polling callbacks where
/// leading-edge execution is desired.
library;

import 'dart:async';

/// Runs at most one action during each [duration] window.
///
/// Example:
/// ```dart
/// final throttler = Throttler(const Duration(milliseconds: 250));
/// throttler.run(() => print('tick'));
/// ```
final class Throttler {
  /// Creates a throttler with the given [duration] window.
  Throttler(this.duration);

  /// The throttle window.
  final Duration duration;

  Timer? _timer;
  bool _isDisposed = false;

  /// Whether this throttler is currently suppressing calls.
  bool get isActive => _timer?.isActive ?? false;

  /// Whether this throttler has been disposed.
  bool get isDisposed => _isDisposed;

  /// Runs [action] immediately if no throttle window is active.
  ///
  /// Calls made while [isActive] is true are ignored.
  ///
  /// Example:
  /// ```dart
  /// throttler.run(() => sendTelemetry());
  /// ```
  void run(void Function() action) {
    _ensureNotDisposed();
    if (isActive) return;

    action();
    _timer = Timer(duration, () {
      _timer = null;
    });
  }

  /// Cancels the current throttle window.
  ///
  /// Example:
  /// ```dart
  /// throttler.cancel();
  /// ```
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels the current window and prevents future use.
  ///
  /// Example:
  /// ```dart
  /// throttler.dispose();
  /// ```
  void dispose() {
    if (_isDisposed) return;
    cancel();
    _isDisposed = true;
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot use a disposed Throttler.');
    }
  }
}
