import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    group('success & failure', () {
      test('should expose success state and value', () {
        const result = Result<int, String>.success(42);

        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.valueOrNull, equals(42));
        expect(result.errorOrNull, isNull);
      });

      test('should expose failure state and error', () {
        const result = Result<int, String>.failure('bad');

        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.valueOrNull, isNull);
        expect(result.errorOrNull, equals('bad'));
      });
    });

    group('fold', () {
      test('should call success branch', () {
        const result = Result<int, String>.success(2);

        expect(
          result.fold((value) => value * 2, (error) => error.length),
          equals(4),
        );
      });

      test('should call failure branch', () {
        const result = Result<int, String>.failure('bad');

        expect(
          result.fold((value) => value * 2, (error) => error.length),
          equals(3),
        );
      });
    });

    group('map & flatMap', () {
      test('should map success value', () {
        final result = const Result<int, String>.success(
          2,
        ).map((value) => value * 3);

        expect(result, equals(const Result<int, String>.success(6)));
      });

      test('should leave failure untouched when mapping', () {
        final result = const Result<int, String>.failure(
          'bad',
        ).map((value) => value * 3);

        expect(result, equals(const Result<int, String>.failure('bad')));
      });

      test('should chain success result', () {
        final result = const Result<int, String>.success(
          2,
        ).flatMap((value) => Result<int, String>.success(value * 3));

        expect(result, equals(const Result<int, String>.success(6)));
      });

      test('should short-circuit failure when chaining', () {
        final result = const Result<int, String>.failure(
          'bad',
        ).flatMap((value) => Result<int, String>.success(value * 3));

        expect(result, equals(const Result<int, String>.failure('bad')));
      });
    });

    group('mapError', () {
      test('should transform failure value', () {
        final result = const Result<int, String>.failure(
          'bad',
        ).mapError((error) => error.length);

        expect(result, equals(const Result<int, int>.failure(3)));
      });

      test('should leave success untouched', () {
        final result = const Result<int, String>.success(
          1,
        ).mapError((error) => error.length);

        expect(result, equals(const Result<int, int>.success(1)));
      });
    });

    group('getOrElse & getOrThrow', () {
      test('should return success value', () {
        const result = Result<int, String>.success(7);

        expect(result.getOrElse(0), equals(7));
        expect(result.getOrThrow(), equals(7));
      });

      test('should return default or throw for failure', () {
        const result = Result<int, String>.failure('bad');

        expect(result.getOrElse(0), equals(0));
        expect(result.getOrThrow, throwsA(equals('bad')));
      });

      test('should throw StateError for null failure values', () {
        const result = Result<int, Null>.failure(null);

        expect(result.getOrThrow, throwsStateError);
      });
    });

    group('toOption', () {
      test('should convert success to Some', () {
        expect(
          const Result<int, String>.success(1).toOption(),
          equals(const Option<int>.some(1)),
        );
      });

      test('should convert failure to None', () {
        expect(
          const Result<int, String>.failure('bad').toOption(),
          equals(const Option<int>.none()),
        );
      });
    });

    group('runCatching', () {
      test('should capture successful sync action', () {
        final result = Result.runCatching(() => int.parse('42'));

        expect(result, equals(const Result<int, Object>.success(42)));
      });

      test('should capture thrown sync object', () {
        final result = Result.runCatching(() => int.parse('nope'));

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<FormatException>());
      });
    });

    group('runCatchingAsync', () {
      test('should capture successful async action', () async {
        final result = await Result.runCatchingAsync(() async => 42);

        expect(result, equals(const Result<int, Object>.success(42)));
      });

      test('should capture thrown async object', () async {
        final result = await Result.runCatchingAsync<int>(
          () async => throw StateError('bad'),
        );

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<StateError>());
      });
    });

    group('combine', () {
      test('should combine all success values', () {
        final result = Result.combine([
          const Result<int, String>.success(1),
          const Result<int, String>.success(2),
        ]);

        expect(result, equals(const Result<List<int>, String>.success([1, 2])));
      });

      test('should return first failure', () {
        final result = Result.combine([
          const Result<int, String>.success(1),
          const Result<int, String>.failure('first'),
          const Result<int, String>.failure('second'),
        ]);

        expect(
          result,
          equals(const Result<List<int>, String>.failure('first')),
        );
      });
    });

    group('equality & toString', () {
      test('should compare matching successes and failures', () {
        expect(
          const Result<int, String>.success(1),
          equals(const Result<int, String>.success(1)),
        );
        expect(
          const Result<int, String>.failure('bad'),
          equals(const Result<int, String>.failure('bad')),
        );
      });

      test('should describe result variants', () {
        expect(
          const Result<int, String>.success(1).toString(),
          equals('Result.success(1)'),
        );
        expect(
          const Result<int, String>.failure('bad').toString(),
          equals('Result.failure(bad)'),
        );
      });
    });
  });
}
