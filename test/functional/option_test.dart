import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Option', () {
    group('some, none & fromNullable', () {
      test('should expose Some state and value', () {
        const option = Option<int>.some(42);

        expect(option.isSome, isTrue);
        expect(option.isNone, isFalse);
        expect(option.valueOrNull, equals(42));
      });

      test('should expose None state', () {
        const option = Option<int>.none();

        expect(option.isSome, isFalse);
        expect(option.isNone, isTrue);
        expect(option.valueOrNull, isNull);
      });

      test('should create Some for non-null values', () {
        expect(
          Option.fromNullable('Ada'),
          equals(const Option<String>.some('Ada')),
        );
      });

      test('should create None for null values', () {
        expect(
          Option<String>.fromNullable(null),
          equals(const Option<String>.none()),
        );
      });
    });

    group('fold', () {
      test('should call some branch', () {
        const option = Option<int>.some(2);

        expect(option.fold((value) => value * 2, () => 0), equals(4));
      });

      test('should call none branch', () {
        const option = Option<int>.none();

        expect(option.fold((value) => value * 2, () => 0), equals(0));
      });
    });

    group('map & flatMap', () {
      test('should map Some value', () {
        final option = const Option<int>.some(2).map((value) => value * 3);

        expect(option, equals(const Option<int>.some(6)));
      });

      test('should leave None untouched when mapping', () {
        final option = const Option<int>.none().map((value) => value * 3);

        expect(option, equals(const Option<int>.none()));
      });

      test('should chain Some value', () {
        final option = const Option<String>.some(
          '42',
        ).flatMap((value) => Option.fromNullable(int.tryParse(value)));

        expect(option, equals(const Option<int>.some(42)));
      });

      test('should short-circuit None when chaining', () {
        final option = const Option<String>.none().flatMap(
          (value) => Option.fromNullable(int.tryParse(value)),
        );

        expect(option, equals(const Option<int>.none()));
      });
    });

    group('filter', () {
      test('should keep value when predicate matches', () {
        final option = const Option<int>.some(3).filter((value) => value > 0);

        expect(option, equals(const Option<int>.some(3)));
      });

      test('should drop value when predicate fails', () {
        final option = const Option<int>.some(-1).filter((value) => value > 0);

        expect(option, equals(const Option<int>.none()));
      });
    });

    group('getOrElse & getOrThrow', () {
      test('should return contained value', () {
        const option = Option<int>.some(7);

        expect(option.getOrElse(0), equals(7));
        expect(option.getOrThrow(), equals(7));
      });

      test('should return default or throw for None', () {
        const option = Option<int>.none();

        expect(option.getOrElse(0), equals(0));
        expect(option.getOrThrow, throwsStateError);
      });
    });

    group('toResult', () {
      test('should convert Some to success', () {
        expect(
          const Option<int>.some(1).toResult('missing'),
          equals(const Result<int, String>.success(1)),
        );
      });

      test('should convert None to failure', () {
        expect(
          const Option<int>.none().toResult('missing'),
          equals(const Result<int, String>.failure('missing')),
        );
      });
    });

    group('zip', () {
      test('should combine two Some values', () {
        final option = const Option<int>.some(
          1,
        ).zip(const Option<String>.some('one'));

        expect(option.valueOrNull, equals((1, 'one')));
      });

      test('should return None if either option is None', () {
        final option = const Option<int>.some(
          1,
        ).zip(const Option<String>.none());

        expect(option, equals(const Option<(int, String)>.none()));
      });
    });

    group('equality & toString', () {
      test('should compare matching variants', () {
        expect(const Option<int>.some(1), equals(const Option<int>.some(1)));
        expect(const Option<int>.none(), equals(const Option<int>.none()));
      });

      test('should describe option variants', () {
        expect(const Option<int>.some(1).toString(), equals('Option.some(1)'));
        expect(const Option<int>.none().toString(), equals('Option.none()'));
      });
    });
  });
}
