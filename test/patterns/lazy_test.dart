import 'dart:async';

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Lazy', () {
    test('should compute value on first access', () {
      var calls = 0;
      final lazy = Lazy<int>(() => ++calls);

      expect(lazy.isInitialized, isFalse);
      expect(lazy.value, equals(1));
      expect(lazy.isInitialized, isTrue);
      expect(lazy.value, equals(1));
      expect(calls, equals(1));
    });

    test('should support uncached values', () {
      var calls = 0;
      final lazy = Lazy<int>(() => ++calls, cache: false);

      expect(lazy.value, equals(1));
      expect(lazy.value, equals(2));
      expect(lazy.isInitialized, isFalse);
    });

    test('should expose valueOrNull and reset cached values', () {
      var calls = 0;
      final lazy = Lazy<int>(() => ++calls);

      expect(lazy.valueOrNull, isNull);
      expect(lazy(), equals(1));
      expect(lazy.valueOrNull, equals(1));

      lazy.reset();

      expect(lazy.isInitialized, isFalse);
      expect(lazy(), equals(2));
    });

    test('should create eager lazy values', () {
      final lazy = Lazy.value('ready');

      expect(lazy.isInitialized, isTrue);
      expect(lazy.value, equals('ready'));
    });

    test('should map lazy values lazily', () {
      var calls = 0;
      final mapped = Lazy<int>(() => ++calls).map((value) => value * 2);

      expect(calls, equals(0));
      expect(mapped.value, equals(2));
      expect(mapped.value, equals(2));
      expect(calls, equals(1));
    });
  });

  group('AsyncLazy', () {
    test('should compute async value on first access', () async {
      var calls = 0;
      final lazy = AsyncLazy<int>(() async => ++calls);

      expect(lazy.isStarted, isFalse);
      expect(await lazy.value, equals(1));
      expect(lazy.isStarted, isTrue);
      expect(await lazy.value, equals(1));
      expect(calls, equals(1));
    });

    test('should share in-flight futures', () async {
      var calls = 0;
      final completer = Completer<int>();
      final lazy = AsyncLazy<int>(() {
        calls++;
        return completer.future;
      });

      final first = lazy();
      final second = lazy();
      completer.complete(42);

      await expectLater(Future.wait([first, second]), completion([42, 42]));
      expect(calls, equals(1));
    });

    test('should retry after failed cached futures', () async {
      var calls = 0;
      final lazy = AsyncLazy<int>(() async {
        calls++;
        if (calls == 1) throw StateError('bad');
        return 7;
      });

      await expectLater(lazy.value, throwsStateError);
      await Future<void>.delayed(Duration.zero);

      expect(lazy.isStarted, isFalse);
      expect(await lazy.value, equals(7));
      expect(calls, equals(2));
    });

    test('should support uncached async values', () async {
      var calls = 0;
      final lazy = AsyncLazy<int>(() async => ++calls, cache: false);

      expect(await lazy.value, equals(1));
      expect(await lazy.value, equals(2));
      expect(lazy.isStarted, isFalse);
    });

    test('should map async lazy values lazily', () async {
      var calls = 0;
      final mapped = AsyncLazy<int>(
        () async => ++calls,
      ).map((value) async => value * 3);

      expect(calls, equals(0));
      expect(await mapped.value, equals(3));
      expect(await mapped.value, equals(3));
      expect(calls, equals(1));
    });

    test('should reset cached async values', () async {
      var calls = 0;
      final lazy = AsyncLazy<int>(() async => ++calls);

      expect(await lazy.value, equals(1));
      lazy.reset();

      expect(lazy.isStarted, isFalse);
      expect(await lazy.value, equals(2));
    });
  });
}
