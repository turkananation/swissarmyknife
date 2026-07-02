import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

final class _FakeClock {
  _FakeClock(this.now);

  DateTime now;

  DateTime call() => now;

  void advance(Duration duration) {
    now = now.add(duration);
  }
}

void main() {
  group('Cache', () {
    test('should store and retrieve values', () {
      final cache = Cache<String, int>(maxSize: 2);

      cache.put('a', 1);

      expect(cache.get('a'), equals(1));
      expect(cache.containsKey('a'), isTrue);
      expect(cache.size, equals(1));
    });

    test('should compute value on miss and track stats', () {
      final cache = Cache<String, int>(maxSize: 2);

      expect(cache.get('missing', orElse: () => 42), equals(42));
      expect(cache.get('missing'), equals(42));

      expect(cache.stats.misses, equals(1));
      expect(cache.stats.hits, equals(1));
      expect(cache.stats.hitRate, equals(0.5));
    });

    test('should evict least recently used entry', () {
      final cache = Cache<String, int>(maxSize: 2);

      cache.put('a', 1);
      cache.put('b', 2);
      expect(cache.get('a'), equals(1));
      cache.put('c', 3);

      expect(cache.containsKey('a'), isTrue);
      expect(cache.containsKey('b'), isFalse);
      expect(cache.containsKey('c'), isTrue);
      expect(cache.stats.evictions, equals(1));
    });

    test('should expire entries by ttl', () {
      final clock = _FakeClock(DateTime(2026));
      final cache = Cache<String, int>(maxSize: 2, clock: clock.call);

      cache.put('a', 1, ttl: const Duration(seconds: 1));
      clock.advance(const Duration(seconds: 2));

      expect(cache.get('a'), isNull);
      expect(cache.containsKey('a'), isFalse);
    });

    test('should invalidate entries', () {
      final cache = Cache<String, int>(maxSize: 2);

      cache.put('a', 1);
      expect(cache.invalidate('a'), isTrue);
      expect(cache.invalidate('missing'), isFalse);
      cache.put('b', 2);
      cache.invalidateAll();

      expect(cache.size, equals(0));
    });
  });
}
