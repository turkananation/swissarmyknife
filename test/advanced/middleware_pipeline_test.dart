import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('MiddlewarePipeline', () {
    test('should run middleware around the terminal handler', () async {
      final events = <String>[];
      final pipeline =
          MiddlewarePipeline<String>(
                terminal: (input) {
                  events.add('terminal:$input');
                  return '$input!';
                },
              )
              .use((input, next) async {
                events.add('a before:$input');
                final output = await next('$input-a');
                events.add('a after:$output');
                return '$output-A';
              })
              .use((input, next) async {
                events.add('b before:$input');
                final output = await next('$input-b');
                events.add('b after:$output');
                return '$output-B';
              });

      final result = await pipeline.run('start');

      expect(result, equals('start-a-b!-B-A'));
      expect(
        events,
        equals([
          'a before:start',
          'b before:start-a',
          'terminal:start-a-b',
          'b after:start-a-b!',
          'a after:start-a-b!-B',
        ]),
      );
    });

    test('should short-circuit when middleware does not call next', () async {
      final pipeline = MiddlewarePipeline<int>(
        terminal: (_) => 100,
      ).use((input, next) => input * 2);

      expect(await pipeline.run(4), equals(8));
    });

    test('should provide tap, transform, and guard helpers', () async {
      final seen = <int>[];
      final pipeline = MiddlewarePipeline<int>()
          .use(MiddlewarePipeline.tap<int>(seen.add))
          .use(MiddlewarePipeline.guard<int>((value) => value >= 0))
          .use(MiddlewarePipeline.transform<int>((value) => value + 1));

      expect(await pipeline.run(4), equals(5));
      expect(seen, equals([4]));
      await expectLater(pipeline.run(-1), throwsStateError);
    });

    test('should keep pipeline composition immutable', () async {
      final base = MiddlewarePipeline<String>();
      final next = base.use(MiddlewarePipeline.transform((value) => '$value!'));

      expect(base.length, equals(0));
      expect(base.isEmpty, isTrue);
      expect(next.length, equals(1));
      expect(await base.run('a'), equals('a'));
      expect(await next.run('a'), equals('a!'));
    });

    test('should allow per-run terminal overrides', () async {
      final pipeline = MiddlewarePipeline<int>().use(
        MiddlewarePipeline.transform((value) => value + 1),
      );

      expect(
        await pipeline.run(1, terminal: (value) => value * 10),
        equals(20),
      );
    });

    test('should reject calling next more than once', () async {
      final pipeline = MiddlewarePipeline<int>().use((input, next) async {
        await next(input);
        return next(input);
      });

      await expectLater(pipeline.run(1), throwsStateError);
    });

    test('should capture thrown failures with tryRun', () async {
      final pipeline = MiddlewarePipeline<int>().use((input, next) {
        throw StateError('bad');
      });

      final result = await pipeline.tryRun(1);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<StateError>());
    });

    test('should append multiple middleware entries', () async {
      final pipeline = MiddlewarePipeline<int>().useAll([
        MiddlewarePipeline.transform((value) => value + 1),
        MiddlewarePipeline.transform((value) => value * 3),
      ]);

      expect(await pipeline.run(2), equals(9));
    });
  });
}
