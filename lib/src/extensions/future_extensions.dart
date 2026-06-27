/// Library-level comment for Future extensions.
///
/// Contains asynchronous utilities on Future values including safe timeouts,
/// delayed resolution, error suppression, and fallback error recovery.
library;

import 'dart:async';

/// Extensions on [Future] to provide advanced async and control flow helpers.
///
/// Example:
/// ```dart
/// final value = await Future.value(42).delay(const Duration(seconds: 1));
/// print(value); // 42 after 1 second
/// ```
extension FutureKnife<T> on Future<T> {
  /// Waits for this future to complete, returning `null` on timeout instead of
  /// throwing a [TimeoutException].
  ///
  /// Example:
  /// ```dart
  /// final result = await Future.delayed(
  ///   const Duration(seconds: 2),
  ///   () => 'completed',
  /// ).timeoutOrNull(const Duration(seconds: 1));
  /// print(result); // null
  /// ```
  Future<T?> timeoutOrNull(Duration duration) async {
    try {
      return await timeout(duration);
    } on TimeoutException catch (_) {
      return null;
    }
  }

  /// Delays the emission of this future's resolved value by [duration].
  ///
  /// Example:
  /// ```dart
  /// final delayedFuture = Future.value('hi').delay(const Duration(seconds: 1));
  /// print(await delayedFuture); // Prints 'hi' after a 1-second delay
  /// ```
  Future<T> delay(Duration duration) async {
    final result = await this;
    await Future<void>.delayed(duration);
    return result;
  }

  /// Catches any exception thrown by this future and returns `null` instead.
  ///
  /// Example:
  /// ```dart
  /// final result = await Future<String>.error('oops').suppressError();
  /// print(result); // null
  /// ```
  Future<T?> suppressError() async {
    try {
      return await this;
    } catch (_) {
      return null;
    }
  }

  /// Alias for [suppressError].
  ///
  /// Catches any exception thrown by this future and returns `null` instead.
  Future<T?> onErrorReturnNull() => suppressError();

  /// Catches any exception thrown by this future and returns [defaultValue]
  /// instead.
  ///
  /// Example:
  /// ```dart
  /// final result = await Future<int>.error('err').onErrorReturn(0);
  /// print(result); // 0
  /// ```
  Future<T> onErrorReturn(T defaultValue) async {
    try {
      return await this;
    } catch (_) {
      return defaultValue;
    }
  }
}
