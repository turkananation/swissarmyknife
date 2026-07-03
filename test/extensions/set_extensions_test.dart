import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('SetKnife', () {
    group('symmetricDifference', () {
      test(
        'should return correct symmetric difference for overlapping sets',
        () {
          final a = {1, 2};
          final b = {2, 3};
          expect(a.symmetricDifference(b), equals({1, 3}));
        },
      );

      test('should return union for disjoint sets', () {
        final a = {1, 2};
        final b = {3, 4};
        expect(a.symmetricDifference(b), equals({1, 2, 3, 4}));
      });

      test('should return empty set for equal sets', () {
        final a = {1, 2};
        final b = {1, 2};
        expect(a.symmetricDifference(b), isEmpty);
      });
    });

    group('powerSet', () {
      test('should compute correct power set for small sets', () {
        final s = {1, 2};
        final power = s.powerSet();
        expect(
          power,
          equals({
            <int>{},
            {1},
            {2},
            {1, 2},
          }),
        );
      });

      test('should return set containing empty set for empty input set', () {
        final s = <int>{};
        expect(s.powerSet(), equals({<int>{}}));
      });

      test('should return null if set size is greater than 20', () {
        final s = List.generate(21, (i) => i).toSet();
        expect(s.powerSet(), isNull);
      });
    });

    group('cartesianProduct', () {
      test('should compute correct cartesian product of two sets', () {
        final a = {1, 2};
        final b = {'a', 'b'};
        expect(
          a.cartesianProduct(b),
          equals({(1, 'a'), (1, 'b'), (2, 'a'), (2, 'b')}),
        );
      });

      test('should return empty set if either set is empty', () {
        final a = {1, 2};
        final b = <String>{};
        expect(a.cartesianProduct(b), isEmpty);
        expect(b.cartesianProduct(a), isEmpty);
      });
    });

    group('isSubsetOf & isSupersetOf', () {
      test('should correctly identify subsets', () {
        expect({1}.isSubsetOf({1, 2}), isTrue);
        expect({1, 2}.isSubsetOf({1, 2}), isTrue);
        expect({3}.isSubsetOf({1, 2}), isFalse);
      });

      test('should correctly identify supersets', () {
        expect({1, 2}.isSupersetOf({1}), isTrue);
        expect({1, 2}.isSupersetOf({1, 2}), isTrue);
        expect({1, 2}.isSupersetOf({3}), isFalse);
      });
    });

    group('isProperSubsetOf & isProperSupersetOf', () {
      test('should correctly identify proper subsets', () {
        expect({1}.isProperSubsetOf({1, 2}), isTrue);
        expect({1, 2}.isProperSubsetOf({1, 2}), isFalse);
      });

      test('should correctly identify proper supersets', () {
        expect({1, 2}.isProperSupersetOf({1}), isTrue);
        expect({1, 2}.isProperSupersetOf({1, 2}), isFalse);
      });
    });

    group('disjoint', () {
      test('should return true if sets share no elements', () {
        expect({1, 2}.disjoint({3, 4}), isTrue);
      });

      test('should return false if sets share elements', () {
        expect({1, 2}.disjoint({2, 3}), isFalse);
      });

      test('should return true if either set is empty', () {
        expect(<int>{}.disjoint({1, 2}), isTrue);
      });
    });
  });
}
