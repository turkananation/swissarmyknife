/// Tests for comparable iterable extensions.
library;

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('ComparableIterableKnife', () {
    group('isSorted', () {
      test('should return true for empty collection', () {
        expect(<int>[].isSorted, isTrue);
      });

      test('should return true for single element collection', () {
        expect([10].isSorted, isTrue);
      });

      test('should return true for sorted collection in ascending order', () {
        expect([1, 2, 3, 4, 5].isSorted, isTrue);
        expect(['apple', 'banana', 'cherry'].isSorted, isTrue);
      });

      test(
        'should return true for collection with duplicate sorted elements',
        () {
          expect([1, 2, 2, 3, 3, 3].isSorted, isTrue);
        },
      );

      test('should return false for unsorted collection', () {
        expect([1, 3, 2].isSorted, isFalse);
        expect(['cherry', 'apple', 'banana'].isSorted, isFalse);
      });
    });

    group('isSortedDescending', () {
      test('should return true for empty collection', () {
        expect(<int>[].isSortedDescending, isTrue);
      });

      test('should return true for single element collection', () {
        expect([10].isSortedDescending, isTrue);
      });

      test('should return true for sorted collection in descending order', () {
        expect([5, 4, 3, 2, 1].isSortedDescending, isTrue);
        expect(['cherry', 'banana', 'apple'].isSortedDescending, isTrue);
      });

      test(
        'should return true for collection with duplicate sorted elements',
        () {
          expect([3, 3, 2, 2, 1, 1].isSortedDescending, isTrue);
        },
      );

      test('should return false for unsorted collection', () {
        expect([3, 1, 2].isSortedDescending, isFalse);
      });
    });

    group('range', () {
      test('should throw StateError for empty collection', () {
        expect(() => <int>[].range, throwsStateError);
      });

      test('should return same element as min and max for single element', () {
        final r = [42].range;
        expect(r.$1, equals(42));
        expect(r.$2, equals(42));
      });

      test('should return correct min and max for multiple elements', () {
        final r = [10, 5, 20, 15].range;
        expect(r.$1, equals(5));
        expect(r.$2, equals(20));

        final rStr = ['cherry', 'apple', 'banana'].range;
        expect(rStr.$1, equals('apple'));
        expect(rStr.$2, equals('cherry'));
      });
    });
  });
}
