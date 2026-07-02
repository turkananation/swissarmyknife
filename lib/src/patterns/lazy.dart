/// Lazy value helpers for deferred initialization.
///
/// Use [Lazy] when a value should be computed only on first access, and
/// [AsyncLazy] when initialization is asynchronous and should share in-flight
/// work between callers.
library;

import 'dart:async';

/// Synchronous lazy value.
///
/// Example:
/// ```dart
/// final config = Lazy(() => loadConfig());
/// final value = config.value;
/// ```
final class Lazy<T> {
  /// Creates a lazy value from [initializer].
  Lazy(T Function() initializer, {this.cache = true})
    : _initializer = initializer;

  /// Creates an already-initialized lazy value.
  Lazy.value(T value) : cache = true, _initializer = (() => value) {
    _value = value;
    _isInitialized = true;
  }

  final T Function() _initializer;

  /// Whether the computed value is cached after first access.
  final bool cache;

  T? _value;
  bool _isInitialized = false;

  /// Whether this lazy value currently has a cached value.
  bool get isInitialized => _isInitialized;

  /// Current cached value, or `null` if not initialized.
  T? get valueOrNull => _isInitialized ? _value : null;

  /// Resolves the value, computing it on first access.
  T get value {
    if (!cache) return _initializer();
    if (!_isInitialized) {
      _value = _initializer();
      _isInitialized = true;
    }
    return _value as T;
  }

  /// Resolves the value.
  T call() => value;

  /// Clears the cached value so the next access recomputes it.
  void reset() {
    _value = null;
    _isInitialized = false;
  }

  /// Creates a lazy value by transforming this lazy value when accessed.
  Lazy<R> map<R>(R Function(T value) transform, {bool cache = true}) {
    return Lazy<R>(() => transform(value), cache: cache);
  }
}

/// Asynchronous lazy value.
///
/// Concurrent callers share the same in-flight future when [cache] is true.
/// Failed futures are not retained, allowing later calls to retry.
final class AsyncLazy<T> {
  /// Creates an async lazy value from [initializer].
  AsyncLazy(FutureOr<T> Function() initializer, {this.cache = true})
    : _initializer = initializer;

  /// Creates an already-initialized async lazy value.
  AsyncLazy.value(T value)
    : cache = true,
      _initializer = (() => value),
      _future = Future<T>.value(value);

  final FutureOr<T> Function() _initializer;

  /// Whether the future is cached after first access.
  final bool cache;

  Future<T>? _future;

  /// Whether this lazy value has started and cached an in-flight or completed
  /// future.
  bool get isStarted => _future != null;

  /// Resolves the value, starting initialization on first access.
  Future<T> get value {
    if (!cache) {
      return Future<T>.sync(_initializer);
    }

    final existing = _future;
    if (existing != null) return existing;

    late final Future<T> future;
    future = Future<T>.sync(_initializer).then(
      (value) => value,
      onError: (Object error, StackTrace stackTrace) {
        if (identical(_future, future)) {
          _future = null;
        }
        Error.throwWithStackTrace(error, stackTrace);
      },
    );
    _future = future;
    return future;
  }

  /// Resolves the value.
  Future<T> call() => value;

  /// Clears the cached future so the next access recomputes it.
  void reset() {
    _future = null;
  }

  /// Creates an async lazy value by transforming this lazy value when accessed.
  AsyncLazy<R> map<R>(
    FutureOr<R> Function(T value) transform, {
    bool cache = true,
  }) {
    return AsyncLazy<R>(() async => transform(await value), cache: cache);
  }
}
