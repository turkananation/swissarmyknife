import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Either', () {
    group('left & right', () {
      test('should expose left state and value', () {
        const either = Either<String, int>.left('bad');

        expect(either.isLeft, isTrue);
        expect(either.isRight, isFalse);
        expect(either.leftOrNull, equals('bad'));
        expect(either.rightOrNull, isNull);
      });

      test('should expose right state and value', () {
        const either = Either<String, int>.right(42);

        expect(either.isLeft, isFalse);
        expect(either.isRight, isTrue);
        expect(either.leftOrNull, isNull);
        expect(either.rightOrNull, equals(42));
      });
    });

    group('fold', () {
      test('should call left branch', () {
        const either = Either<String, int>.left('bad');

        expect(either.fold((left) => left.length, (right) => right), equals(3));
      });

      test('should call right branch', () {
        const either = Either<String, int>.right(4);

        expect(
          either.fold((left) => left.length, (right) => right * 2),
          equals(8),
        );
      });
    });

    group('mapLeft & mapRight', () {
      test('should transform left value', () {
        final either = const Either<String, int>.left(
          'bad',
        ).mapLeft((value) => value.length);

        expect(either, equals(const Either<int, int>.left(3)));
      });

      test('should leave right value untouched when mapping left', () {
        final either = const Either<String, int>.right(
          2,
        ).mapLeft((value) => value.length);

        expect(either, equals(const Either<int, int>.right(2)));
      });

      test('should transform right value', () {
        final either = const Either<String, int>.right(
          2,
        ).mapRight((value) => value * 3);

        expect(either, equals(const Either<String, int>.right(6)));
      });

      test('should leave left value untouched when mapping right', () {
        final either = const Either<String, int>.left(
          'bad',
        ).mapRight((value) => value * 3);

        expect(either, equals(const Either<String, int>.left('bad')));
      });
    });

    group('flatMap', () {
      test('should chain right value', () {
        final either = const Either<String, int>.right(
          2,
        ).flatMap((value) => Either<String, int>.right(value * 3));

        expect(either, equals(const Either<String, int>.right(6)));
      });

      test('should short-circuit left value', () {
        final either = const Either<String, int>.left(
          'bad',
        ).flatMap((value) => Either<String, int>.right(value * 3));

        expect(either, equals(const Either<String, int>.left('bad')));
      });
    });

    group('swap', () {
      test('should swap left into right', () {
        expect(
          const Either<String, int>.left('bad').swap(),
          equals(const Either<int, String>.right('bad')),
        );
      });

      test('should swap right into left', () {
        expect(
          const Either<String, int>.right(1).swap(),
          equals(const Either<int, String>.left(1)),
        );
      });
    });

    group('getLeftOrElse & getRightOrElse', () {
      test('should return present side values', () {
        expect(
          const Either<String, int>.left('bad').getLeftOrElse('none'),
          equals('bad'),
        );
        expect(const Either<String, int>.right(7).getRightOrElse(0), equals(7));
      });

      test('should return defaults for absent sides', () {
        expect(
          const Either<String, int>.right(7).getLeftOrElse('none'),
          equals('none'),
        );
        expect(
          const Either<String, int>.left('bad').getRightOrElse(0),
          equals(0),
        );
      });
    });

    group('toResult', () {
      test('should convert right to success', () {
        expect(
          const Either<String, int>.right(1).toResult(),
          equals(const Result<int, String>.success(1)),
        );
      });

      test('should convert left to failure', () {
        expect(
          const Either<String, int>.left('bad').toResult(),
          equals(const Result<int, String>.failure('bad')),
        );
      });
    });

    group('equality & toString', () {
      test('should compare matching variants', () {
        expect(
          const Either<String, int>.left('bad'),
          equals(const Either<String, int>.left('bad')),
        );
        expect(
          const Either<String, int>.right(1),
          equals(const Either<String, int>.right(1)),
        );
      });

      test('should describe either variants', () {
        expect(
          const Either<String, int>.left('bad').toString(),
          equals('Either.left(bad)'),
        );
        expect(
          const Either<String, int>.right(1).toString(),
          equals('Either.right(1)'),
        );
      });
    });
  });
}
