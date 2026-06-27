import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('IterableKnife', () {
    group('groupBy', () {
      test('should group items correctly', () {
        final list = ['apple', 'apricot', 'banana'];
        final grouped = list.groupBy((s) => s[0]);
        expect(grouped, equals({
          'a': ['apple', 'apricot'],
          'b': ['banana'],
        }));
      });
    });

    group('sortedBy & sortedByDescending', () {
      test('should sort ascending', () {
        final list = ['banana', 'apple', 'cherry'];
        expect(list.sortedBy((s) => s.length), equals(['apple', 'banana', 'cherry']));
      });
      test('should sort descending', () {
        final list = ['apple', 'cherry', 'banana'];
        expect(list.sortedByDescending((s) => s.length), equals(['cherry', 'banana', 'apple']));
      });
    });

    group('distinctBy', () {
      test('should return distinct items by selector', () {
        final list = ['apple', 'apricot', 'banana'];
        expect(list.distinctBy((s) => s[0]), equals(['apple', 'banana']));
      });
    });

    group('chunk', () {
      test('should split list into chunks', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.chunk(2), equals([[1, 2], [3, 4], [5]]));
      });
      test('should throw on chunk <= 0', () {
        expect(() => [1, 2].chunk(0), throwsArgumentError);
      });
    });

    group('firstWhereOrNull & lastWhereOrNull', () {
      test('firstWhereOrNull', () {
        expect([1, 2, 3].firstWhereOrNull((x) => x > 1), equals(2));
        expect([1, 2, 3].firstWhereOrNull((x) => x > 5), isNull);
      });
      test('lastWhereOrNull', () {
        expect([1, 2, 3].lastWhereOrNull((x) => x > 1), equals(3));
        expect([1, 2, 3].lastWhereOrNull((x) => x > 5), isNull);
      });
    });

    group('partition', () {
      test('should divide elements matching test', () {
        final (evens, odds) = [1, 2, 3, 4].partition((x) => x.isEven);
        expect(evens, equals([2, 4]));
        expect(odds, equals([1, 3]));
      });
    });

    group('frequencyMap', () {
      test('should count frequencies', () {
        expect(['a', 'b', 'a'].frequencyMap(), equals({'a': 2, 'b': 1}));
      });
    });

    group('minBy & maxBy', () {
      test('minBy', () {
        final list = ['banana', 'apple', 'cherry'];
        expect(list.minBy((s) => s.length), equals('apple'));
      });
      test('maxBy', () {
        final list = ['apple', 'banana', 'cherry'];
        expect(list.maxBy((s) => s.length), equals('banana'));
      });
    });

    group('sumBy & averageBy', () {
      test('sumBy', () {
        expect(['a', 'bc'].sumBy((s) => s.length), equals(3));
      });
      test('averageBy', () {
        expect(['a', 'bc'].averageBy((s) => s.length), equals(1.5));
        expect(<String>[].averageBy((s) => s.length), equals(0.0));
      });
    });

    group('forEachIndexed, mapIndexed, whereIndexed', () {
      test('forEachIndexed', () {
        final indices = <int>[];
        ['a', 'b'].forEachIndexed((index, element) {
          indices.add(index);
        });
        expect(indices, equals([0, 1]));
      });

      test('mapIndexed', () {
        final res = ['a', 'b'].mapIndexed((index, element) => '$index-$element').toList();
        expect(res, equals(['0-a', '1-b']));
      });

      test('whereIndexed', () {
        final res = [10, 20, 30].whereIndexed((index, element) => index.isEven).toList();
        expect(res, equals([10, 30]));
      });
    });

    group('sample', () {
      test('should return sample of requested size', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.sample(count: 2).length, equals(2));
        expect(list.sample(count: 10).length, equals(5));
      });
    });

    group('takeWhileInclusive', () {
      test('should include first element that fails test', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.takeWhileInclusive((x) => x < 3).toList(), equals([1, 2, 3]));
      });
    });

    group('separatedBy', () {
      test('should insert separators', () {
        expect(['a', 'b', 'c'].separatedBy('-').toList(), equals(['a', '-', 'b', '-', 'c']));
      });
    });

    group('containsAny', () {
      test('should return true if any exists', () {
        expect([1, 2, 3].containsAny([3, 4]), isTrue);
        expect([1, 2, 3].containsAny([4, 5]), isFalse);
      });
    });
  });

  group('ListKnife', () {
    group('zipWith', () {
      test('should combine list elements', () {
        final res = [1, 2].zipWith(['a', 'b'], (n, s) => '$n$s');
        expect(res, equals(['1a', '2b']));
      });
    });

    group('zip', () {
      test('should zip into records', () {
        final zipped = [1, 2].zip(['a', 'b']);
        expect(zipped.length, equals(2));
        expect(zipped[0].$1, equals(1));
        expect(zipped[0].$2, equals('a'));
      });
    });

    group('rotate', () {
      test('should rotate right with positive', () {
        expect([1, 2, 3, 4].rotate(1), equals([4, 1, 2, 3]));
      });
      test('should rotate left with negative', () {
        expect([1, 2, 3, 4].rotate(-1), equals([2, 3, 4, 1]));
      });
      test('should handle empty', () {
        expect(<int>[].rotate(5), equals([]));
      });
    });

    group('interleave', () {
      test('should alternate elements', () {
        expect([1, 2].interleave([3, 4, 5]), equals([1, 3, 2, 4, 5]));
      });
    });

    group('shuffled', () {
      test('should shuffle without mutating original', () {
        final list = [1, 2, 3, 4, 5];
        final shuffled = list.shuffled();
        expect(shuffled, isNot(same(list)));
      });
    });
  });

  group('IterableFlatten', () {
    test('should flatten nested iterables', () {
      final nested = [[1, 2], [3]];
      expect(nested.flatten().toList(), equals([1, 2, 3]));
    });
  });

  group('IterableCompact', () {
    test('should filter out nulls', () {
      final list = [1, null, 2];
      expect(list.compact().toList(), equals([1, 2]));
    });
  });
}
