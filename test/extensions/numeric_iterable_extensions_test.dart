import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('NumericIterableKnife', () {
    group('sum', () {
      test('should sum list of numbers', () {
        expect([1, 2.5, 3].sum(), equals(6.5));
      });
      test('should return 0 for empty list', () {
        expect(<num>[].sum(), equals(0));
      });
    });

    group('average', () {
      test('should compute correct average', () {
        expect([1, 2, 3, 4].average(), equals(2.5));
      });
      test('should return 0.0 for empty list', () {
        expect(<num>[].average(), equals(0.0));
      });
    });

    group('median', () {
      test('should find median for odd length', () {
        expect([1, 3, 2].median(), equals(2.0));
      });
      test('should find median for even length', () {
        expect([1, 2, 3, 4].median(), equals(2.5));
      });
      test('should return 0.0 for empty', () {
        expect(<num>[].median(), equals(0.0));
      });
    });

    group('mode', () {
      test('should find single mode', () {
        expect([1, 2, 2, 3].mode(), equals([2]));
      });
      test('should find multiple modes', () {
        expect([1, 1, 2, 2, 3].mode(), equals([1, 2]));
      });
      test('should return empty for empty list', () {
        expect(<num>[].mode(), equals([]));
      });
    });

    group('variance & standardDeviation', () {
      test('should compute population variance and standard deviation', () {
        final list = [2, 4, 4, 4, 5, 5, 7, 9];
        expect(list.variance(), equals(4.0));
        expect(list.standardDeviation(), equals(2.0));
      });
    });

    group('percentile', () {
      test('should compute correct percentiles', () {
        final list = [15, 20, 35, 40, 50];
        expect(list.percentile(0.0), equals(15.0));
        expect(list.percentile(1.0), equals(50.0));
        expect(list.percentile(0.4), equals(29.0));
      });
      test('should throw on out-of-range percentile', () {
        expect(() => [1, 2].percentile(-0.1), throwsArgumentError);
        expect(() => [1, 2].percentile(1.1), throwsArgumentError);
      });
    });

    group('min & max', () {
      test('should return min and max', () {
        expect([5, 1, 9, 3].min(), equals(1));
        expect([5, 1, 9, 3].max(), equals(9));
      });
      test('should throw on empty', () {
        expect(() => <num>[].min(), throwsStateError);
        expect(() => <num>[].max(), throwsStateError);
      });
    });
  });
}
