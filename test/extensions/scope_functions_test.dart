import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('ScopeKnife', () {
    group('let', () {
      test('should transform value and return result', () {
        final result = 'hello'.let((s) => s.length);
        expect(result, equals(5));
      });

      test('should allow chaining let calls', () {
        final result = 5.let((x) => x * 2).let((x) => 'Value: $x');
        expect(result, equals('Value: 10'));
      });
    });

    group('also', () {
      test('should perform action and return the same value', () {
        var called = false;
        final result = 'hello'.also((s) {
          called = true;
          expect(s, equals('hello'));
        });
        expect(called, isTrue);
        expect(result, equals('hello'));
      });

      test('should work with mutable side effects', () {
        final list = <int>[];
        final result = list.also((l) => l.add(1)).also((l) => l.add(2));
        expect(result, equals([1, 2]));
      });
    });

    group('takeIf', () {
      test('should return value when predicate is true', () {
        final result = 5.takeIf((x) => x > 0);
        expect(result, equals(5));
      });

      test('should return null when predicate is false', () {
        final result = 5.takeIf((x) => x < 0);
        expect(result, isNull);
      });
    });

    group('takeUnless', () {
      test('should return null when predicate is true', () {
        final result = 5.takeUnless((x) => x > 0);
        expect(result, isNull);
      });

      test('should return value when predicate is false', () {
        final result = 5.takeUnless((x) => x < 0);
        expect(result, equals(5));
      });
    });
  });

  group('CastKnife', () {
    group('tryCast', () {
      test('should cast value successfully when types match', () {
        final Object val = 'hello';
        final String? casted = val.tryCast<String>();
        expect(casted, equals('hello'));
      });

      test('should return null when types do not match', () {
        final Object val = 123;
        final String? casted = val.tryCast<String>();
        expect(casted, isNull);
      });
    });

    group('isType', () {
      test('should return true when object is of the type', () {
        final Object val = 'hello';
        expect(val.isType<String>(), isTrue);
      });

      test('should return false when object is not of the type', () {
        final Object val = 123;
        expect(val.isType<String>(), isFalse);
      });
    });
  });
}
