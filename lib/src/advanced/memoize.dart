/// Memoization helpers for synchronous and asynchronous functions.
///
/// Use [Memoized] and [AsyncMemoized] when expensive pure computations should
/// be cached by input key with optional TTL and LRU eviction.
library;

import 'dart:async';

import '../data/cache_manager.dart';

/// Derives a cache key from an input value.
typedef MemoKeyOf<K> = Object? Function(K key);

/// Memoizes a single-argument synchronous function.
Memoized<K, V> memoize<K, V extends Object>(
  V Function(K key) compute, {
  MemoKeyOf<K>? keyOf,
  int maxSize = 100,
  Duration? ttl,
  DateTime Function()? clock,
}) {
  return Memoized<K, V>(
    compute,
    keyOf: keyOf,
    maxSize: maxSize,
    ttl: ttl,
    clock: clock,
  );
}

/// Memoizes a zero-argument synchronous function.
Memoized0<V> memoize0<V extends Object>(
  V Function() compute, {
  Duration? ttl,
  DateTime Function()? clock,
}) {
  return Memoized0<V>(compute, ttl: ttl, clock: clock);
}

/// Memoizes a single-argument asynchronous function.
AsyncMemoized<K, V> memoizeAsync<K, V extends Object>(
  FutureOr<V> Function(K key) compute, {
  MemoKeyOf<K>? keyOf,
  int maxSize = 100,
  Duration? ttl,
  DateTime Function()? clock,
}) {
  return AsyncMemoized<K, V>(
    compute,
    keyOf: keyOf,
    maxSize: maxSize,
    ttl: ttl,
    clock: clock,
  );
}

/// Memoizes a zero-argument asynchronous function.
AsyncMemoized0<V> memoizeAsync0<V extends Object>(
  FutureOr<V> Function() compute, {
  Duration? ttl,
  DateTime Function()? clock,
}) {
  return AsyncMemoized0<V>(compute, ttl: ttl, clock: clock);
}

/// Memoized single-argument synchronous function.
///
/// Example:
/// ```dart
/// final fib = Memoized<int, int>((n) => expensiveFib(n));
/// final value = fib(40);
/// ```
final class Memoized<K, V extends Object> {
  /// Creates a memoized wrapper around the supplied computation.
  Memoized(
    this._compute, {
    MemoKeyOf<K>? keyOf,
    int maxSize = 100,
    this.ttl,
    DateTime Function()? clock,
  }) : _keyOf = keyOf ?? ((key) => key),
       _cache = Cache<Object?, V>(maxSize: maxSize, clock: clock);

  final V Function(K key) _compute;
  final MemoKeyOf<K> _keyOf;
  final Cache<Object?, V> _cache;

  /// Optional TTL applied to new memoized values.
  final Duration? ttl;

  /// Number of live cached entries.
  int get size => _cache.size;

  /// Live cache keys in least-to-most-recent order.
  Iterable<Object?> get keys => _cache.keys;

  /// Cache hit/miss/eviction statistics.
  CacheStats get stats => _cache.stats;

  /// Returns the memoized value for [key], computing it on cache miss.
  V call(K key) {
    final cacheKey = _keyOf(key);
    return _cache.get(cacheKey, orElse: () => _compute(key), ttl: ttl) as V;
  }

  /// Whether [key] currently has a live cached value.
  bool containsKey(K key) => _cache.containsKey(_keyOf(key));

  /// Invalidates one cached [key].
  bool invalidate(K key) => _cache.invalidate(_keyOf(key));

  /// Clears all cached values.
  void clear() => _cache.invalidateAll();
}

/// Memoized zero-argument synchronous function.
final class Memoized0<V extends Object> {
  /// Creates a memoized wrapper around [compute].
  Memoized0(V Function() compute, {Duration? ttl, DateTime Function()? clock})
    : _key = Object(),
      _memoized = Memoized<Object, V>(
        (_) => compute(),
        maxSize: 1,
        ttl: ttl,
        clock: clock,
      );

  final Object _key;
  final Memoized<Object, V> _memoized;

  /// Number of live cached entries.
  int get size => _memoized.size;

  /// Cache hit/miss/eviction statistics.
  CacheStats get stats => _memoized.stats;

  /// Returns the memoized value, computing it on first use or after expiry.
  V call() => _memoized(_key);

  /// Invalidates the cached value.
  bool invalidate() => _memoized.invalidate(_key);

  /// Clears the cached value.
  void clear() => _memoized.clear();
}

/// Memoized single-argument asynchronous function.
///
/// Concurrent calls for the same key share the same in-flight future. Failed
/// computations are removed from the cache so a later call can retry.
final class AsyncMemoized<K, V extends Object> {
  /// Creates a memoized async wrapper around the supplied computation.
  AsyncMemoized(
    this._compute, {
    MemoKeyOf<K>? keyOf,
    int maxSize = 100,
    this.ttl,
    DateTime Function()? clock,
  }) : _keyOf = keyOf ?? ((key) => key),
       _cache = Cache<Object?, Future<V>>(maxSize: maxSize, clock: clock);

  final FutureOr<V> Function(K key) _compute;
  final MemoKeyOf<K> _keyOf;
  final Cache<Object?, Future<V>> _cache;

  /// Optional TTL applied to new memoized futures.
  final Duration? ttl;

  /// Number of live cached entries.
  int get size => _cache.size;

  /// Live cache keys in least-to-most-recent order.
  Iterable<Object?> get keys => _cache.keys;

  /// Cache hit/miss/eviction statistics.
  CacheStats get stats => _cache.stats;

  /// Returns the memoized future for [key], computing it on cache miss.
  Future<V> call(K key) {
    final cacheKey = _keyOf(key);
    final future = _cache.get(
      cacheKey,
      orElse: () => _computeFuture(key, cacheKey),
      ttl: ttl,
    );
    return future as Future<V>;
  }

  /// Whether [key] currently has a live cached future.
  bool containsKey(K key) => _cache.containsKey(_keyOf(key));

  /// Invalidates one cached [key].
  bool invalidate(K key) => _cache.invalidate(_keyOf(key));

  /// Clears all cached futures.
  void clear() => _cache.invalidateAll();

  Future<V> _computeFuture(K key, Object? cacheKey) {
    final future = Future<V>.sync(() => _compute(key));
    return future
        .whenComplete(() {
          // Failed futures should not poison the memoized cache.
          future.ignore();
        })
        .catchError((Object error) {
          _cache.invalidate(cacheKey);
          throw error;
        });
  }
}

/// Memoized zero-argument asynchronous function.
final class AsyncMemoized0<V extends Object> {
  /// Creates a memoized async wrapper around [compute].
  AsyncMemoized0(
    FutureOr<V> Function() compute, {
    Duration? ttl,
    DateTime Function()? clock,
  }) : _key = Object(),
       _memoized = AsyncMemoized<Object, V>(
         (_) => compute(),
         maxSize: 1,
         ttl: ttl,
         clock: clock,
       );

  final Object _key;
  final AsyncMemoized<Object, V> _memoized;

  /// Number of live cached entries.
  int get size => _memoized.size;

  /// Cache hit/miss/eviction statistics.
  CacheStats get stats => _memoized.stats;

  /// Returns the memoized future, computing it on first use or after expiry.
  Future<V> call() => _memoized(_key);

  /// Invalidates the cached future.
  bool invalidate() => _memoized.invalidate(_key);

  /// Clears the cached future.
  void clear() => _memoized.clear();
}
