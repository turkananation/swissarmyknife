import 'dart:math';
import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('RandomKnife', () {
    late Random random;

    setUp(() {
      // Use a seeded random so test runs are deterministic
      random = Random(42);
    });

    group('nextElement', () {
      test('should select random element', () {
        final list = ['apple', 'banana', 'orange'];
        final element = random.nextElement(list);
        expect(list, contains(element));
      });
      test('should throw on empty list', () {
        expect(() => random.nextElement([]), throwsArgumentError);
      });
    });

    group('nextWeightedElement', () {
      test('should select weighted element', () {
        final elements = ['A', 'B'];
        // Seed 42 with weights [0.999, 0.001] should almost certainly select A
        final element = random.nextWeightedElement(elements, [0.999, 0.001]);
        expect(element, equals('A'));
      });

      test('should throw if elements and weights lengths mismatch', () {
        expect(() => random.nextWeightedElement(['A'], [0.5, 0.5]), throwsArgumentError);
      });
    });

    group('nextIntInRange', () {
      test('should return integer in range inclusive', () {
        final minVal = 5;
        final maxVal = 10;
        for (var i = 0; i < 50; i++) {
          final val = random.nextIntInRange(minVal, maxVal);
          expect(val, greaterThanOrEqualTo(minVal));
          expect(val, lessThanOrEqualTo(maxVal));
        }
      });
      test('should throw if min > max', () {
        expect(() => random.nextIntInRange(10, 5), throwsArgumentError);
      });
    });

    group('nextDoubleInRange', () {
      test('should return double in range', () {
        final minVal = 1.5;
        final maxVal = 3.5;
        for (var i = 0; i < 50; i++) {
          final val = random.nextDoubleInRange(minVal, maxVal);
          expect(val, greaterThanOrEqualTo(minVal));
          expect(val, lessThanOrEqualTo(maxVal));
        }
      });
    });

    group('nextBoolWithProbability', () {
      test('should return true with 1.0 probability', () {
        expect(random.nextBoolWithProbability(1.0), isTrue);
      });
      test('should return false with 0.0 probability', () {
        expect(random.nextBoolWithProbability(0.0), isFalse);
      });
      test('should throw if probability out of bounds', () {
        expect(() => random.nextBoolWithProbability(-0.1), throwsArgumentError);
        expect(() => random.nextBoolWithProbability(1.1), throwsArgumentError);
      });
    });
  });
}
