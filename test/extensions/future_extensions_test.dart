import 'dart:async';
import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('FutureKnife', () {
    group('timeoutOrNull', () {
      test('should return value when future completes within timeout', () async {
        final future = Future.value(42);
        final result = await future.timeoutOrNull(const Duration(seconds: 1));
        expect(result, equals(42));
      });

      test('should return null when future times out', () async {
        final future = Future<int>.delayed(const Duration(milliseconds: 100), () => 42);
        final result = await future.timeoutOrNull(const Duration(milliseconds: 10));
        expect(result, isNull);
      });
    });

    group('delay', () {
      test('should delay completion of future', () async {
        final stopwatch = Stopwatch()..start();
        final future = Future.value(100);
        final result = await future.delay(const Duration(milliseconds: 50));
        stopwatch.stop();
        expect(result, equals(100));
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(45));
      });
    });

    group('suppressError & onErrorReturnNull', () {
      test('should return value when future succeeds', () async {
        final future = Future.value('success');
        expect(await future.suppressError(), equals('success'));
        expect(await future.onErrorReturnNull(), equals('success'));
      });

      test('should return null when future throws error', () async {
        final future = Future<String>.error(Exception('Failed'));
        expect(await future.suppressError(), isNull);
        expect(await future.onErrorReturnNull(), isNull);
      });
    });

    group('onErrorReturn', () {
      test('should return value when future succeeds', () async {
        final future = Future.value(5);
        expect(await future.onErrorReturn(0), equals(5));
      });

      test('should return default value when future throws error', () async {
        final future = Future<int>.error(Exception('Failed'));
        expect(await future.onErrorReturn(10), equals(10));
      });
    });
  });
}
