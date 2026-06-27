import 'dart:async';
import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('StreamKnife', () {
    group('buffer', () {
      test('should buffer elements into lists of specified count', () async {
        final stream = Stream.fromIterable([1, 2, 3, 4, 5]).buffer(2);
        final result = await stream.toList();
        expect(
          result,
          equals([
            [1, 2],
            [3, 4],
            [5],
          ]),
        );
      });

      test('should throw ArgumentError for invalid buffer counts', () {
        final stream = Stream.fromIterable([1, 2, 3]);
        expect(() => stream.buffer(0), throwsArgumentError);
        expect(() => stream.buffer(-1), throwsArgumentError);
      });
    });

    group('bufferTime', () {
      test('should buffer events emitted during time window', () async {
        final controller = StreamController<int>();
        final stream = controller.stream.bufferTime(const Duration(milliseconds: 50));
        
        final listFuture = stream.toList();
        
        controller.add(1);
        controller.add(2);
        await Future<void>.delayed(const Duration(milliseconds: 60));
        controller.add(3);
        await Future<void>.delayed(const Duration(milliseconds: 60));
        await controller.close();

        final result = await listFuture;
        expect(result.length, greaterThanOrEqualTo(2));
        expect(result.expand((x) => x).toList(), equals([1, 2, 3]));
      });
    });

    group('delay', () {
      test('should delay stream event emissions', () async {
        final stream = Stream.fromIterable([1, 2]).delay(const Duration(milliseconds: 50));
        final stopwatch = Stopwatch()..start();
        final result = await stream.toList();
        stopwatch.stop();

        expect(result, equals([1, 2]));
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(45));
      });
    });

    group('tap', () {
      test('should trigger side-effects without altering stream data', () async {
        final items = <int>[];
        final stream = Stream.fromIterable([1, 2, 3]).tap((val) => items.add(val * 10));
        final result = await stream.toList();

        expect(result, equals([1, 2, 3]));
        expect(items, equals([10, 20, 30]));
      });
    });

    group('onErrorReturn', () {
      test('should emit default value and close on error', () async {
        final controller = StreamController<int>();
        final stream = controller.stream.onErrorReturn(-1);
        
        final listFuture = stream.toList();
        controller.add(1);
        controller.addError(Exception('Ouch'));
        
        // This add should not be received since stream closes on error.
        controller.add(2);
        await controller.close();

        final result = await listFuture;
        expect(result, equals([1, -1]));
      });
    });
  });
}
