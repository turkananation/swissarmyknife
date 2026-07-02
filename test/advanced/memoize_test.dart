import 'dart:async';

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
  group('Memoized', () {
    test('should cache synchronous results by key', () {
      var calls = 0;
      final square = Memoized<int, int>((value) {
        calls++;
        return value * value;
      });

      expect(square(4), equals(16));
      expect(square(4), equals(16));
      expect(square(5), equals(25));

      expect(calls, equals(2));
      expect(square.stats.hits, equals(1));
      expect(square.stats.misses, equals(2));
    });

    test('should support custom cache keys', () {
      var calls = 0;
      final sum = memoize<List<int>, int>((values) {
        calls++;
        return values.reduce((a, b) => a + b);
      }, keyOf: (values) => values.join(','));

      expect(sum([1, 2, 3]), equals(6));
      expect(sum([1, 2, 3]), equals(6));

      expect(calls, equals(1));
      expect(sum.keys, equals(['1,2,3']));
    });

    test('should expire values by ttl', () {
      final clock = _FakeClock(DateTime(2026));
      var calls = 0;
      final value = Memoized<String, int>(
        (_) => ++calls,
        ttl: const Duration(seconds: 1),
        clock: clock.call,
      );

      expect(value('a'), equals(1));
      expect(value('a'), equals(1));
      clock.advance(const Duration(seconds: 2));
      expect(value('a'), equals(2));
    });

    test('should evict least recently used values', () {
      final value = Memoized<int, int>((key) => key, maxSize: 2);

      expect(value(1), equals(1));
      expect(value(2), equals(2));
      expect(value(1), equals(1));
      expect(value(3), equals(3));

      expect(value.containsKey(1), isTrue);
      expect(value.containsKey(2), isFalse);
      expect(value.containsKey(3), isTrue);
      expect(value.stats.evictions, equals(1));
    });

    test('should invalidate and clear values', () {
      final value = Memoized<String, int>((key) => key.length);

      expect(value('abc'), equals(3));
      expect(value.invalidate('abc'), isTrue);
      expect(value.containsKey('abc'), isFalse);
      expect(value('abcd'), equals(4));
      value.clear();

      expect(value.size, equals(0));
    });
  });

  group('Memoized0', () {
    test('should cache zero-argument synchronous functions', () {
      var calls = 0;
      final next = memoize0(() => ++calls);

      expect(next(), equals(1));
      expect(next(), equals(1));
      expect(next.stats.hits, equals(1));

      next.invalidate();
      expect(next(), equals(2));
    });
  });

  group('AsyncMemoized', () {
    test('should cache asynchronous results by key', () async {
      var calls = 0;
      final doubleValue = AsyncMemoized<int, int>((value) async {
        calls++;
        return value * 2;
      });

      expect(await doubleValue(3), equals(6));
      expect(await doubleValue(3), equals(6));

      expect(calls, equals(1));
      expect(doubleValue.stats.hits, equals(1));
      expect(doubleValue.stats.misses, equals(1));
    });

    test('should share in-flight asynchronous computations', () async {
      var calls = 0;
      final completer = Completer<int>();
      final value = memoizeAsync<String, int>((_) {
        calls++;
        return completer.future;
      });

      final first = value('a');
      final second = value('a');
      completer.complete(42);

      await expectLater(Future.wait([first, second]), completion([42, 42]));
      expect(calls, equals(1));
      expect(value.stats.hits, equals(1));
    });

    test('should not cache failed asynchronous computations', () async {
      var calls = 0;
      final value = memoizeAsync<String, int>((_) async {
        calls++;
        if (calls == 1) throw StateError('bad');
        return 7;
      });

      await expectLater(value('a'), throwsStateError);
      expect(await value('a'), equals(7));
      expect(calls, equals(2));
    });

    test('should invalidate and clear asynchronous values', () async {
      var calls = 0;
      final value = AsyncMemoized<String, int>((key) async {
        calls++;
        return key.length;
      });

      expect(await value('abc'), equals(3));
      expect(value.invalidate('abc'), isTrue);
      expect(await value('abc'), equals(3));
      value.clear();

      expect(value.size, equals(0));
      expect(calls, equals(2));
    });
  });

  group('AsyncMemoized0', () {
    test('should cache zero-argument asynchronous functions', () async {
      var calls = 0;
      final next = memoizeAsync0(() async => ++calls);

      expect(await next(), equals(1));
      expect(await next(), equals(1));
      expect(next.stats.hits, equals(1));

      next.clear();
      expect(await next(), equals(2));
    });
  });
}
