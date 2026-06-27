/// Tests for MapEntry extensions.
library;

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('MapEntryKnife', () {
    group('swap', () {
      test('should swap key and value of MapEntry', () {
        final entry = const MapEntry('hello', 123);
        final swapped = entry.swap();
        expect(swapped.key, equals(123));
        expect(swapped.value, equals('hello'));
      });
    });

    group('toPair', () {
      test('should convert MapEntry to record pair', () {
        final entry = const MapEntry('hello', 123);
        final pair = entry.toPair();
        expect(pair.$1, equals('hello'));
        expect(pair.$2, equals(123));
      });
    });
  });

  group('MapEntryIterableKnife', () {
    group('toMap', () {
      test('should convert iterable of MapEntry to Map', () {
        final entries = [
          const MapEntry('a', 1),
          const MapEntry('b', 2),
        ];
        final map = entries.toMap();
        expect(map, equals({'a': 1, 'b': 2}));
      });

      test('should use last-write-wins for duplicate keys', () {
        final entries = [
          const MapEntry('a', 1),
          const MapEntry('b', 2),
          const MapEntry('a', 3),
        ];
        final map = entries.toMap();
        expect(map, equals({'a': 3, 'b': 2}));
      });
    });

    group('toPairs', () {
      test('should return empty list for empty iterable', () {
        expect(<MapEntry<String, int>>[].toPairs(), isEmpty);
      });

      test('should convert iterable of MapEntry to list of record pairs', () {
        final entries = [
          const MapEntry('a', 1),
          const MapEntry('b', 2),
        ];
        final pairs = entries.toPairs();
        expect(pairs.length, equals(2));
        expect(pairs[0].$1, equals('a'));
        expect(pairs[0].$2, equals(1));
        expect(pairs[1].$1, equals('b'));
        expect(pairs[1].$2, equals(2));
      });
    });
  });
}
