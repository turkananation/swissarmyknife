import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('CollectionAdvancedKnife', () {
    group('slidingWindow', () {
      test('should yield overlapping windows of size', () {
        final list = [1, 2, 3, 4];
        expect(list.slidingWindow(2).toList(), equals([[1, 2], [2, 3], [3, 4]]));
      });
      test('should handle step', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.slidingWindow(2, step: 2).toList(), equals([[1, 2], [3, 4]]));
      });
      test('should handle partialWindows', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.slidingWindow(2, step: 2, partialWindows: true).toList(),
            equals([[1, 2], [3, 4], [5]]));
      });
    });

    group('getOrNull & getOrElse', () {
      test('getOrNull', () {
        final list = [1, 2, 3];
        expect(list.getOrNull(1), equals(2));
        expect(list.getOrNull(5), isNull);
        expect(list.getOrNull(-1), isNull);
      });
      test('getOrElse', () {
        final list = [1, 2, 3];
        expect(list.getOrElse(1, 100), equals(2));
        expect(list.getOrElse(5, 100), equals(100));
      });
    });
  });

  group('ListAdvancedKnife', () {
    group('permutations', () {
      test('should generate all permutations', () {
        final list = [1, 2, 3];
        final perms = list.permutations().toList();
        expect(perms.length, equals(6));
        expect(perms, containsAll([
          [1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]
        ]));
      });
    });

    group('combinations', () {
      test('should generate all combinations of size k', () {
        final list = [1, 2, 3];
        final combos = list.combinations(2).toList();
        expect(combos.length, equals(3));
        expect(combos, containsAll([[1, 2], [1, 3], [2, 3]]));
      });
    });

    group('set operations', () {
      test('intersection, union, difference, symmetricDifference', () {
        final list1 = [1, 2, 3];
        final list2 = [3, 4, 5];

        expect(list1.intersection(list2), equals([3]));
        expect(list1.union(list2), containsAll([1, 2, 3, 4, 5]));
        expect(list1.difference(list2), equals([1, 2]));
        expect(list1.symmetricDifference(list2), containsAll([1, 2, 4, 5]));
      });
    });

    group('immutable modifications', () {
      test('replaceAt', () {
        final list = [1, 2, 3];
        final replaced = list.replaceAt(1, 9);
        expect(replaced, equals([1, 9, 3]));
        expect(list, equals([1, 2, 3])); // original unchanged
      });

      test('insertAt', () {
        final list = [1, 2, 3];
        final inserted = list.insertAt(1, 9);
        expect(inserted, equals([1, 9, 2, 3]));
      });

      test('removeAtCopy', () {
        final list = [1, 2, 3];
        final removed = list.removeAtCopy(1);
        expect(removed, equals([1, 3]));
      });
    });
  });
}
