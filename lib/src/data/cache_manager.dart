/// In-memory LRU cache with optional per-entry TTL.
///
/// Use [Cache] for small local caches where deterministic eviction and simple
/// hit/miss statistics are useful.
library;

import 'dart:collection';

/// Cache hit/miss counters.
///
/// Example:
/// ```dart
/// final rate = cache.stats.hitRate;
/// ```
final class CacheStats {
  /// Creates immutable cache statistics.
  const CacheStats({
    required this.hits,
    required this.misses,
    required this.evictions,
  });

  /// Successful cache reads.
  final int hits;

  /// Failed cache reads.
  final int misses;

  /// Entries evicted due to capacity.
  final int evictions;

  /// Total cache read attempts.
  int get total => hits + misses;

  /// Fraction of reads that were hits.
  double get hitRate => total == 0 ? 0 : hits / total;

  /// Fraction of reads that were misses.
  double get missRate => total == 0 ? 0 : misses / total;
}

final class _CacheEntry<V> {
  _CacheEntry(this.value, this.expiresAt);

  final V value;
  final DateTime? expiresAt;

  bool isExpired(DateTime now) {
    final expires = expiresAt;
    return expires != null && !expires.isAfter(now);
  }
}

/// In-memory least-recently-used cache.
///
/// Example:
/// ```dart
/// final cache = Cache<String, int>(maxSize: 100);
/// final value = cache.get('answer', orElse: () => 42);
/// ```
final class Cache<K, V> {
  /// Creates a cache with [maxSize] entries.
  Cache({this.maxSize = 100, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    if (maxSize <= 0) {
      throw ArgumentError.value(maxSize, 'maxSize', 'Must be positive.');
    }
  }

  /// Maximum number of entries retained.
  final int maxSize;

  final DateTime Function() _clock;
  final LinkedHashMap<K, _CacheEntry<V>> _entries = LinkedHashMap();

  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;

  /// Number of live entries.
  int get size {
    _purgeExpired();
    return _entries.length;
  }

  /// Live cache keys in least-to-most-recent order.
  Iterable<K> get keys {
    _purgeExpired();
    return List<K>.unmodifiable(_entries.keys);
  }

  /// Current cache statistics.
  CacheStats get stats =>
      CacheStats(hits: _hits, misses: _misses, evictions: _evictions);

  /// Reads [key], optionally computing and storing a value on miss.
  ///
  /// Example:
  /// ```dart
  /// final user = cache.get(id, orElse: () => loadUser(id));
  /// ```
  V? get(K key, {V Function()? orElse, Duration? ttl}) {
    final now = _clock();
    final entry = _entries.remove(key);
    if (entry != null && !entry.isExpired(now)) {
      _hits++;
      _entries[key] = entry;
      return entry.value;
    }

    _misses++;
    if (orElse == null) return null;

    final value = orElse();
    put(key, value, ttl: ttl);
    return value;
  }

  /// Stores [value] for [key], replacing any existing value.
  void put(K key, V value, {Duration? ttl}) {
    _entries.remove(key);
    _entries[key] = _CacheEntry(value, _expiresAt(ttl));
    _evictIfNeeded();
  }

  /// Removes [key] from the cache.
  bool invalidate(K key) => _entries.remove(key) != null;

  /// Removes every entry from the cache.
  void invalidateAll() {
    _entries.clear();
  }

  /// Whether [key] has a live cached value.
  bool containsKey(K key) {
    final entry = _entries[key];
    if (entry == null) return false;
    if (entry.isExpired(_clock())) {
      _entries.remove(key);
      return false;
    }
    return true;
  }

  DateTime? _expiresAt(Duration? ttl) {
    if (ttl == null) return null;
    if (ttl <= Duration.zero) return _clock();
    return _clock().add(ttl);
  }

  void _evictIfNeeded() {
    while (_entries.length > maxSize) {
      _entries.remove(_entries.keys.first);
      _evictions++;
    }
  }

  void _purgeExpired() {
    final now = _clock();
    _entries.removeWhere((_, entry) => entry.isExpired(now));
  }
}
