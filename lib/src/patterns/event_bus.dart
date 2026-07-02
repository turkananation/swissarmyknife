/// Typed event bus utilities.
///
/// Use [EventBus] for lightweight in-process pub/sub without introducing a
/// dependency or global stream plumbing.
library;

import 'dart:async';

/// A typed broadcast event bus.
///
/// Example:
/// ```dart
/// final bus = EventBus();
/// bus.on<String>().listen(print);
/// bus.fire('ready');
/// ```
final class EventBus {
  /// Creates a broadcast event bus.
  EventBus({bool sync = false})
    : _controller = StreamController.broadcast(sync: sync);

  final StreamController<Object?> _controller;
  bool _isDisposed = false;

  /// Whether this bus has been disposed.
  bool get isDisposed => _isDisposed;

  /// Fires [event] to listeners of its runtime type.
  ///
  /// Example:
  /// ```dart
  /// bus.fire(UserLoggedIn(userId));
  /// ```
  void fire<T extends Object?>(T event) {
    _ensureNotDisposed();
    _controller.add(event);
  }

  /// Returns a stream of events assignable to [T].
  ///
  /// Example:
  /// ```dart
  /// final messages = bus.on<String>();
  /// ```
  Stream<T> on<T>() {
    _ensureNotDisposed();
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  /// Returns a stream of [T] events matching [test].
  ///
  /// Example:
  /// ```dart
  /// final errors = bus.onWhere<String>((event) => event.startsWith('error'));
  /// ```
  Stream<T> onWhere<T>(bool Function(T event) test) {
    return on<T>().where(test);
  }

  /// Completes with the next event assignable to [T].
  ///
  /// Example:
  /// ```dart
  /// final next = await bus.once<String>();
  /// ```
  Future<T> once<T>() {
    return on<T>().first;
  }

  /// Closes the bus and prevents future events or subscriptions.
  ///
  /// Example:
  /// ```dart
  /// await bus.dispose();
  /// ```
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _controller.close();
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot use a disposed EventBus.');
    }
  }
}

/// Global singleton event bus for application-wide events.
///
/// Example:
/// ```dart
/// GlobalEventBus.instance.fire('ready');
/// ```
final class GlobalEventBus {
  const GlobalEventBus._();

  /// The shared application-wide event bus.
  static final EventBus instance = EventBus();
}
