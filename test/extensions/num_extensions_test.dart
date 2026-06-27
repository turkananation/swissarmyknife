import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('NumKnife', () {
    group('toCurrency', () {
      test('should format positive number as currency with default decimals', () {
        expect(1234.56.toCurrency(), equals('\$1,234.56'));
      });
      test('should format negative number and respect decimals', () {
        expect((-1234.5).toCurrency(symbol: '€', decimals: 0), equals('-€1,235'));
      });
    });

    group('toPercentString', () {
      test('should format fraction to percent', () {
        expect(0.85.toPercentString(), equals('85%'));
      });
      test('should format with custom decimals', () {
        expect(0.1234.toPercentString(decimals: 2), equals('12.34%'));
      });
    });

    group('isBetween', () {
      test('should return true for value in range', () {
        expect(5.isBetween(1, 10), isTrue);
      });
      test('should return false for value outside range', () {
        expect(11.isBetween(1, 10), isFalse);
      });
    });

    group('isPositive, isNegative, isZero', () {
      test('should check positive/negative/zero correctly', () {
        expect(5.isPositive, isTrue);
        expect((-5).isNegative, isTrue);
        expect(0.isZero, isTrue);
      });
    });

    group('roundTo', () {
      test('should round to decimal places', () {
        expect(1.23456.roundTo(2), equals(1.23));
        expect(1.235.roundTo(2), equals(1.24));
      });
    });

    group('coerceIn', () {
      test('should coerce within range', () {
        expect(15.coerceIn(0, 10), equals(10));
        expect((-5).coerceIn(0, 10), equals(0));
        expect(5.coerceIn(0, 10), equals(5));
      });
      test('should throw ArgumentError if min > max', () {
        expect(() => 5.coerceIn(10, 0), throwsArgumentError);
      });
    });

    group('coerceAtLeast & coerceAtMost', () {
      test('should coerce at least', () {
        expect(5.coerceAtLeast(10), equals(10));
        expect(15.coerceAtLeast(10), equals(15));
      });
      test('should coerce at most', () {
        expect(15.coerceAtMost(10), equals(10));
        expect(5.coerceAtMost(10), equals(5));
      });
    });
  });

  group('IntKnife', () {
    group('toFileSizeString', () {
      test('should format bytes correctly', () {
        expect(0.toFileSizeString(), equals('0 B'));
        expect(512.toFileSizeString(), equals('512 B'));
        expect(1536.toFileSizeString(), equals('1.5 KB'));
        expect((1024 * 1024 * 1.5).toInt().toFileSizeString(), equals('1.5 MB'));
      });
    });

    group('toOrdinal', () {
      test('should format basic ordinals', () {
        expect(1.toOrdinal(), equals('1st'));
        expect(2.toOrdinal(), equals('2nd'));
        expect(3.toOrdinal(), equals('3rd'));
        expect(4.toOrdinal(), equals('4th'));
      });
      test('should format teen edge cases', () {
        expect(11.toOrdinal(), equals('11th'));
        expect(12.toOrdinal(), equals('12th'));
        expect(13.toOrdinal(), equals('13th'));
        expect(21.toOrdinal(), equals('21st'));
        expect(111.toOrdinal(), equals('111th'));
      });
    });

    group('toRoman', () {
      test('should convert valid numbers', () {
        expect(4.toRoman(), equals('IV'));
        expect(9.toRoman(), equals('IX'));
        expect(2026.toRoman(), equals('MMXXVI'));
      });
      test('should return empty for invalid numbers', () {
        expect(0.toRoman(), equals(''));
        expect(4000.toRoman(), equals(''));
      });
    });

    group('toCompactString', () {
      test('should compact large integers', () {
        expect(500.toCompactString(), equals('500'));
        expect(1500.toCompactString(), equals('1.5K'));
        expect(1500000.toCompactString(), equals('1.5M'));
        expect((-1200000000).toCompactString(), equals('-1.2B'));
      });
    });

    group('Duration getters', () {
      test('should convert to corresponding Duration', () {
        expect(10.milliseconds, equals(const Duration(milliseconds: 10)));
        expect(5.seconds, equals(const Duration(seconds: 5)));
        expect(2.minutes, equals(const Duration(minutes: 2)));
        expect(3.hours, equals(const Duration(hours: 3)));
        expect(1.days, equals(const Duration(days: 1)));
      });
    });
  });
}
