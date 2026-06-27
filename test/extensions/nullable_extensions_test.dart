/// Tests for nullable extensions.
library;

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('NullableKnife', () {
    group('orDefault', () {
      test('should return default value when nullable is null', () {
        const String? name = null;
        expect(name.orDefault('default'), equals('default'));
      });

      test('should return original value when nullable is not null', () {
        String? name = 'hello';
        expect(name.orDefault('default'), equals('hello'));
      });
    });

    group('orCompute', () {
      test('should call compute and return result when nullable is null', () {
        const int? number = null;
        var called = false;
        final result = number.orCompute(() {
          called = true;
          return 42;
        });
        expect(result, equals(42));
        expect(called, isTrue);
      });

      test('should not call compute and return original value when nullable is not null', () {
        int? number = 10;
        var called = false;
        final result = number.orCompute(() {
          called = true;
          return 42;
        });
        expect(result, equals(10));
        expect(called, isFalse);
      });
    });

    group('guard', () {
      test('should return null when nullable is null', () {
        const String? name = null;
        final result = name.guard((n) => n.toUpperCase());
        expect(result, isNull);
      });

      test('should return transformed value when nullable is not null', () {
        String? name = 'hello';
        final result = name.guard((n) => n.toUpperCase());
        expect(result, equals('HELLO'));
      });

      test('should support chainable guard calls', () {
        String? name = '123';
        final result = name
            .guard((n) => int.tryParse(n))
            .guard((val) => val * 2);
        expect(result, equals(246));
      });
    });
  });
}
