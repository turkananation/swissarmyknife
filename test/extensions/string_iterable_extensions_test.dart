/// Tests for string iterable extensions.
library;

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('StringIterableKnife', () {
    group('joinWithLast', () {
      test('should return empty string when collection is empty', () {
        expect(<String>[].joinWithLast(', ', ', and '), equals(''));
      });

      test(
        'should return the element itself when collection has 1 element',
        () {
          expect(['apple'].joinWithLast(', ', ', and '), equals('apple'));
        },
      );

      test(
        'should use only the last separator when collection has 2 elements',
        () {
          expect(
            ['apple', 'banana'].joinWithLast(', ', ', and '),
            equals('apple, and banana'),
          );
          expect(
            ['apple', 'banana'].joinWithLast(', ', ' & '),
            equals('apple & banana'),
          );
        },
      );

      test(
        'should use separator and lastSeparator when collection has 3+ elements',
        () {
          expect(
            ['apple', 'banana', 'cherry'].joinWithLast(', ', ', and '),
            equals('apple, banana, and cherry'),
          );
          expect(
            ['apple', 'banana', 'cherry', 'date'].joinWithLast(', ', ', and '),
            equals('apple, banana, cherry, and date'),
          );
        },
      );
    });

    group('longestCommonPrefix', () {
      test('should return empty string for empty iterable', () {
        expect(<String>[].longestCommonPrefix(), equals(''));
      });

      test('should return the string itself for single-element iterable', () {
        expect(['flower'].longestCommonPrefix(), equals('flower'));
      });

      test('should return the common prefix when it exists', () {
        expect(
          ['flower', 'flow', 'flight'].longestCommonPrefix(),
          equals('fl'),
        );
        expect(
          ['interspecies', 'interstellar', 'interstate'].longestCommonPrefix(),
          equals('inters'),
        );
      });

      test('should return empty string when no common prefix exists', () {
        expect(['dog', 'racecar', 'car'].longestCommonPrefix(), equals(''));
      });

      test('should respect case sensitivity', () {
        expect(['flower', 'Flow', 'flight'].longestCommonPrefix(), equals(''));
      });
    });

    group('sorted', () {
      test('should return a new sorted list case-sensitively', () {
        final original = ['cherry', 'banana', 'apple', 'Apple'];
        final result = original.sorted();
        expect(result, equals(['Apple', 'apple', 'banana', 'cherry']));
        expect(
          original,
          equals(['cherry', 'banana', 'apple', 'Apple']),
        ); // non-mutating
      });
    });

    group('sortedCaseInsensitive', () {
      test('should return a new sorted list case-insensitively', () {
        final original = ['cherry', 'banana', 'Apple'];
        final result = original.sortedCaseInsensitive();
        expect(result, equals(['Apple', 'banana', 'cherry']));
        expect(original, equals(['cherry', 'banana', 'Apple'])); // non-mutating
      });
    });
  });
}
