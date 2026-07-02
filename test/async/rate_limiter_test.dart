import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

final class _FakeClock {
  _FakeClock(this.now);

  DateTime now;

  DateTime call() => now;

  void advance(Duration duration) {
    now = now.add(duration);
  }
}

void main() {
  group('RateLimiter.tokenBucket', () {
    test('should acquire tokens until bucket is empty', () {
      final clock = _FakeClock(DateTime(2026));
      final limiter = RateLimiter.tokenBucket(
        2,
        const Duration(seconds: 1),
        clock: clock.call,
      );

      expect(limiter.remaining, equals(2));
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isFalse);
      expect(limiter.remaining, equals(0));
    });

    test('should refill tokens over time', () {
      final clock = _FakeClock(DateTime(2026));
      final limiter = RateLimiter.tokenBucket(
        2,
        const Duration(seconds: 1),
        clock: clock.call,
      );

      expect(limiter.tryAcquire(permits: 2), isTrue);
      clock.advance(const Duration(seconds: 1));

      expect(limiter.remaining, equals(1));
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.remaining, equals(0));
    });

    test('should wait when acquiring asynchronously', () async {
      final limiter = RateLimiter.tokenBucket(
        1,
        const Duration(milliseconds: 10),
      );

      expect(limiter.tryAcquire(), isTrue);
      final stopwatch = Stopwatch()..start();
      await limiter.acquire();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(8));
    });
  });

  group('RateLimiter.slidingWindow', () {
    test('should limit requests inside a window', () {
      final clock = _FakeClock(DateTime(2026));
      final limiter = RateLimiter.slidingWindow(
        2,
        const Duration(seconds: 10),
        clock: clock.call,
      );

      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isFalse);
      expect(limiter.remaining, equals(0));
    });

    test('should allow requests after window expires', () {
      final clock = _FakeClock(DateTime(2026));
      final limiter = RateLimiter.slidingWindow(
        1,
        const Duration(seconds: 10),
        clock: clock.call,
      );

      expect(limiter.tryAcquire(), isTrue);
      clock.advance(const Duration(seconds: 11));

      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.remaining, equals(0));
    });

    test('should validate limiter configuration and permits', () {
      expect(
        () => RateLimiter.tokenBucket(0, const Duration(seconds: 1)),
        throwsArgumentError,
      );
      expect(
        () => RateLimiter.slidingWindow(1, Duration.zero),
        throwsArgumentError,
      );

      final limiter = RateLimiter.slidingWindow(1, const Duration(seconds: 1));
      expect(() => limiter.tryAcquire(permits: 0), throwsArgumentError);
      expect(() => limiter.acquire(permits: 2), throwsArgumentError);
    });
  });
}
