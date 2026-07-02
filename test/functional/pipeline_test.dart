import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Pipe', () {
    test('should run reusable transformations', () {
      final parseDouble = Pipe<String, String>(
        (value) => value.trim(),
      ).then(int.parse).then((value) => value * 2);

      expect(parseDouble(' 21 '), equals(42));
    });

    test('should compose with asynchronous transformations', () async {
      final pipe = Pipe<int, int>(
        (value) => value + 1,
      ).thenAsync((value) async => value * 3);

      await expectLater(pipe(4), completion(equals(15)));
    });

    test('should capture synchronous failures', () {
      final parse = Pipe<String, int>(int.parse);

      final result = parse.runCatching('nope');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<FormatException>());
    });
  });

  group('AsyncPipe', () {
    test('should compose asynchronous transformations', () async {
      final pipe = AsyncPipe<int, int>(
        (value) async => value + 2,
      ).then((value) => value * 4);

      await expectLater(pipe(3), completion(equals(20)));
    });

    test('should capture asynchronous failures', () async {
      final pipe = AsyncPipe<int, int>((_) async => throw StateError('bad'));

      final result = await pipe.runCatching(1);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<StateError>());
    });
  });

  group('Pipeline', () {
    test('should transform values through map and then', () {
      final result = Pipeline(' 21 ')
          .map((value) => value.trim())
          .then(int.parse)
          .map((value) => value * 2)
          .result;

      expect(result, equals(42));
    });

    test('should apply reusable pipes', () {
      final normalize = Pipe<String, String>(
        (value) => value.trim(),
      ).then((value) => value.toUpperCase());

      final result = pipeline(' ada ').apply(normalize).result;

      expect(result, equals('ADA'));
    });

    test('should tap values without changing them', () {
      final seen = <int>[];

      final result = 4.toPipeline().tap(seen.add).map((value) => value * 2);

      expect(result.result, equals(8));
      expect(seen, equals([4]));
    });

    test('should guard values', () {
      expect(
        () => Pipeline(
          3,
        ).guard((value) => value.isEven, message: 'Expected even.'),
        throwsA(isA<StateError>()),
      );
    });

    test('should capture transform failures', () {
      final result = Pipeline('bad').runCatching(int.parse);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<FormatException>());
    });
  });

  group('AsyncPipeline', () {
    test('should transform values through async steps', () async {
      final result = await asyncPipeline(
        2,
      ).map((value) async => value + 3).then((value) => value * 4).result;

      expect(result, equals(20));
    });

    test('should start from futures', () async {
      final result = await Future.value(
        5,
      ).toAsyncPipeline().map((value) => value + 1).result;

      expect(result, equals(6));
    });

    test('should tap and guard async values', () async {
      final seen = <int>[];

      final result = await AsyncPipeline.value(4)
          .tap((value) async => seen.add(value))
          .guard((value) => Future<bool>.value(value.isEven))
          .result;

      expect(result, equals(4));
      expect(seen, equals([4]));
    });

    test('should apply sync and async pipes', () async {
      final increment = Pipe<int, int>((value) => value + 1);
      final doubleAsync = AsyncPipe<int, int>((value) async => value * 2);

      final result = await 3
          .toAsyncPipeline()
          .applySync(increment)
          .apply(doubleAsync)
          .result;

      expect(result, equals(8));
    });

    test('should capture asynchronous failures', () async {
      final result = await AsyncPipeline.value(
        3,
      ).guard((value) => value.isEven, message: 'Expected even.').runCatching();

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<StateError>());
    });
  });

  group('PipeKnife', () {
    test('should pipe values through a transform', () {
      final result = 'dart'.pipe((value) => value.toUpperCase());

      expect(result, equals('DART'));
    });

    test('should create async pipelines from values', () async {
      final result = await 10
          .toAsyncPipeline()
          .map((value) => Future<int>.value(value ~/ 2))
          .result;

      expect(result, equals(5));
    });
  });
}
