/// Tests for double extensions.
library;

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('DoubleKnife', () {
    group('lerp', () {
      test('should linearly interpolate between two numbers at t=0.5', () {
        expect(10.0.lerp(20.0, 0.5), equals(15.0));
      });

      test('should return start value when t is 0.0', () {
        expect(10.0.lerp(20.0, 0.0), equals(10.0));
      });

      test('should return end value when t is 1.0', () {
        expect(10.0.lerp(20.0, 1.0), equals(20.0));
      });

      test('should interpolate outside bounds when t is greater than 1.0', () {
        expect(10.0.lerp(20.0, 2.0), equals(30.0));
      });
    });

    group('inverseLerp', () {
      test('should return correct ratio for value within range', () {
        expect(15.0.inverseLerp(10.0, 20.0), equals(0.5));
      });

      test(
        'should return 0.0 when min equals max to avoid division by zero',
        () {
          expect(10.0.inverseLerp(10.0, 10.0), equals(0.0));
        },
      );

      test('should return ratio outside 0..1 for values outside range', () {
        expect(25.0.inverseLerp(10.0, 20.0), equals(1.5));
      });
    });

    group('remap', () {
      test('should correctly map value from one range to another', () {
        expect(5.0.remap(0.0, 10.0, 0.0, 100.0), equals(50.0));
      });

      test('should map outside output range for value outside input range', () {
        expect(12.0.remap(0.0, 10.0, 0.0, 100.0), equals(120.0));
      });
    });

    group('isApproximately', () {
      test('should return true for values within default tolerance', () {
        final sum = 0.1 + 0.2;
        expect(sum.isApproximately(0.3), isTrue);
      });

      test('should return false for values outside tolerance', () {
        expect(0.1.isApproximately(0.1001, epsilon: 1e-5), isFalse);
        expect(0.1.isApproximately(0.100001, epsilon: 1e-5), isTrue);
      });
    });

    group('toPrecision', () {
      test(
        'should round to specified significant digits for positive number',
        () {
          expect(123.456.toPrecision(3), equals(123.0));
          expect(123.456.toPrecision(4), equals(123.5));
          expect(0.0012345.toPrecision(2), equals(0.0012));
        },
      );

      test(
        'should round to specified significant digits for negative number',
        () {
          expect((-123.456).toPrecision(3), equals(-123.0));
          expect((-0.0012345).toPrecision(2), equals(-0.0012));
        },
      );

      test('should return original value for zero, NaN, or infinity', () {
        expect(0.0.toPrecision(3), equals(0.0));
        expect(double.nan.toPrecision(3).isNaN, isTrue);
        expect(double.infinity.toPrecision(3), equals(double.infinity));
      });

      test('should throw ArgumentError for digits less than 1', () {
        expect(() => 123.456.toPrecision(0), throwsArgumentError);
        expect(() => 123.456.toPrecision(-1), throwsArgumentError);
      });
    });
  });
}
