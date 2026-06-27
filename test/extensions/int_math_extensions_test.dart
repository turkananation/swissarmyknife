/// Tests for integer math extensions.
library;

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('IntMathKnife', () {
    group('isPrime', () {
      test('should return false for numbers less than or equal to 1', () {
        expect(0.isPrime, isFalse);
        expect(1.isPrime, isFalse);
        expect((-7).isPrime, isFalse);
      });

      test('should return true for 2 and 3', () {
        expect(2.isPrime, isTrue);
        expect(3.isPrime, isTrue);
      });

      test('should return true for prime numbers', () {
        expect(5.isPrime, isTrue);
        expect(17.isPrime, isTrue);
        expect(97.isPrime, isTrue);
      });

      test('should return false for composite numbers', () {
        expect(4.isPrime, isFalse);
        expect(15.isPrime, isFalse);
        expect(100.isPrime, isFalse);
      });
    });

    group('factorial', () {
      test('should return 1 for 0 and 1', () {
        expect(0.factorial(), equals(1));
        expect(1.factorial(), equals(1));
      });

      test('should return correct factorial for positive numbers', () {
        expect(5.factorial(), equals(120));
        expect(6.factorial(), equals(720));
      });

      test('should return -1 for negative numbers', () {
        expect((-5).factorial(), equals(-1));
      });
    });

    group('gcd', () {
      test('should return correct GCD for positive numbers', () {
        expect(24.gcd(18), equals(6));
        expect(101.gcd(10), equals(1));
      });

      test('should handle negative numbers correctly', () {
        expect((-24).gcd(18), equals(6));
        expect(24.gcd(-18), equals(6));
        expect((-24).gcd(-18), equals(6));
      });

      test('should handle zero correctly', () {
        expect(0.gcd(5), equals(5));
        expect(5.gcd(0), equals(5));
        expect(0.gcd(0), equals(0));
      });
    });

    group('lcm', () {
      test('should return correct LCM for positive numbers', () {
        expect(12.lcm(18), equals(36));
        expect(5.lcm(7), equals(35));
      });

      test('should handle negative numbers correctly', () {
        expect((-12).lcm(18), equals(36));
        expect(12.lcm(-18), equals(36));
      });

      test('should return 0 when either operand is 0', () {
        expect(0.lcm(5), equals(0));
        expect(5.lcm(0), equals(0));
      });
    });

    group('digits', () {
      test('should split positive integers into digits', () {
        expect(12345.digits, equals([1, 2, 3, 4, 5]));
      });

      test('should split negative integers using their absolute value', () {
        expect((-987).digits, equals([9, 8, 7]));
      });

      test('should handle zero correctly', () {
        expect(0.digits, equals([0]));
      });
    });

    group('digitSum', () {
      test('should return sum of digits for positive numbers', () {
        expect(12345.digitSum, equals(15));
      });

      test('should return sum of digits for negative numbers using absolute value', () {
        expect((-987).digitSum, equals(24));
      });

      test('should return 0 for zero', () {
        expect(0.digitSum, equals(0));
      });
    });

    group('toBinaryString', () {
      test('should convert positive numbers to binary', () {
        expect(10.toBinaryString(), equals('1010'));
        expect(0.toBinaryString(), equals('0'));
      });

      test('should convert negative numbers to binary with a minus sign', () {
        expect((-10).toBinaryString(), equals('-1010'));
      });
    });

    group('toOctalString', () {
      test('should convert positive numbers to octal', () {
        expect(8.toOctalString(), equals('10'));
        expect(0.toOctalString(), equals('0'));
      });

      test('should convert negative numbers to octal with a minus sign', () {
        expect((-8).toOctalString(), equals('-10'));
      });
    });
  });
}
