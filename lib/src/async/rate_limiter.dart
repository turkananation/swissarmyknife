/// Rate limiting utilities for local throttling.
///
/// Use [RateLimiter] to bound local request bursts before work reaches an API,
/// queue, stream processor, or other constrained resource.
library;

/// Limits how frequently callers can acquire permits.
///
/// Example:
/// ```dart
/// final limiter = RateLimiter.tokenBucket(10, const Duration(seconds: 1));
/// if (limiter.tryAcquire()) {
///   sendRequest();
/// }
/// ```
abstract class RateLimiter {
  /// Creates a token-bucket limiter.
  ///
  /// [maxTokens] is the bucket capacity. [refillRate] controls how often
  /// [refillAmount] tokens are added.
  factory RateLimiter.tokenBucket(
    int maxTokens,
    Duration refillRate, {
    int refillAmount = 1,
    DateTime Function()? clock,
  }) {
    return _TokenBucketRateLimiter(
      maxTokens,
      refillRate,
      refillAmount: refillAmount,
      clock: clock,
    );
  }

  /// Creates a sliding-window limiter.
  ///
  /// Allows up to [maxRequests] acquisitions in each [windowDuration].
  factory RateLimiter.slidingWindow(
    int maxRequests,
    Duration windowDuration, {
    DateTime Function()? clock,
  }) {
    return _SlidingWindowRateLimiter(maxRequests, windowDuration, clock: clock);
  }

  const RateLimiter._();

  /// Number of permits available right now.
  int get remaining;

  /// Attempts to acquire [permits] without waiting.
  ///
  /// Returns false when capacity is not currently available.
  bool tryAcquire({int permits = 1});

  /// Waits until [permits] can be acquired.
  Future<void> acquire({int permits = 1});
}

final class _TokenBucketRateLimiter extends RateLimiter {
  _TokenBucketRateLimiter(
    this.maxTokens,
    this.refillRate, {
    this.refillAmount = 1,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _tokens = maxTokens.toDouble(),
       _lastRefill = (clock ?? DateTime.now)(),
       super._() {
    if (maxTokens <= 0) {
      throw ArgumentError.value(maxTokens, 'maxTokens', 'Must be positive.');
    }
    if (refillRate <= Duration.zero) {
      throw ArgumentError.value(
        refillRate,
        'refillRate',
        'Must be greater than zero.',
      );
    }
    if (refillAmount <= 0) {
      throw ArgumentError.value(
        refillAmount,
        'refillAmount',
        'Must be positive.',
      );
    }
  }

  final int maxTokens;
  final Duration refillRate;
  final int refillAmount;
  final DateTime Function() _clock;

  double _tokens;
  DateTime _lastRefill;

  @override
  int get remaining {
    _refill();
    return _tokens.floor();
  }

  @override
  bool tryAcquire({int permits = 1}) {
    _validatePermits(permits);
    _refill();
    if (permits > maxTokens || _tokens < permits) return false;
    _tokens -= permits;
    return true;
  }

  @override
  Future<void> acquire({int permits = 1}) async {
    _validatePermits(permits);
    if (permits > maxTokens) {
      throw ArgumentError.value(
        permits,
        'permits',
        'Cannot acquire more permits than bucket capacity.',
      );
    }

    while (!tryAcquire(permits: permits)) {
      await Future<void>.delayed(_timeUntilAvailable(permits));
    }
  }

  void _refill() {
    final now = _clock();
    final elapsedMicros = now.difference(_lastRefill).inMicroseconds;
    if (elapsedMicros <= 0) return;

    final refillMicros = refillRate.inMicroseconds;
    final tokensToAdd = elapsedMicros / refillMicros * refillAmount;
    _tokens = (_tokens + tokensToAdd).clamp(0, maxTokens).toDouble();
    _lastRefill = now;
  }

  Duration _timeUntilAvailable(int permits) {
    _refill();
    final missingTokens = permits - _tokens;
    if (missingTokens <= 0) return Duration.zero;

    final micros = (missingTokens / refillAmount * refillRate.inMicroseconds)
        .ceil()
        .clamp(1, refillRate.inMicroseconds);
    return Duration(microseconds: micros);
  }
}

final class _SlidingWindowRateLimiter extends RateLimiter {
  _SlidingWindowRateLimiter(
    this.maxRequests,
    this.windowDuration, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super._() {
    if (maxRequests <= 0) {
      throw ArgumentError.value(
        maxRequests,
        'maxRequests',
        'Must be positive.',
      );
    }
    if (windowDuration <= Duration.zero) {
      throw ArgumentError.value(
        windowDuration,
        'windowDuration',
        'Must be greater than zero.',
      );
    }
  }

  final int maxRequests;
  final Duration windowDuration;
  final DateTime Function() _clock;
  final List<DateTime> _requests = <DateTime>[];

  @override
  int get remaining {
    _prune();
    return maxRequests - _requests.length;
  }

  @override
  bool tryAcquire({int permits = 1}) {
    _validatePermits(permits);
    _prune();
    if (permits > maxRequests || remaining < permits) return false;

    final now = _clock();
    for (var i = 0; i < permits; i++) {
      _requests.add(now);
    }
    return true;
  }

  @override
  Future<void> acquire({int permits = 1}) async {
    _validatePermits(permits);
    if (permits > maxRequests) {
      throw ArgumentError.value(
        permits,
        'permits',
        'Cannot acquire more permits than window capacity.',
      );
    }

    while (!tryAcquire(permits: permits)) {
      await Future<void>.delayed(_timeUntilAvailable());
    }
  }

  void _prune() {
    final cutoff = _clock().subtract(windowDuration);
    _requests.removeWhere((request) => !request.isAfter(cutoff));
  }

  Duration _timeUntilAvailable() {
    _prune();
    if (_requests.length < maxRequests) return Duration.zero;

    final now = _clock();
    final oldest = _requests.first;
    final availableAt = oldest.add(windowDuration);
    final wait = availableAt.difference(now);
    if (wait <= Duration.zero) return const Duration(microseconds: 1);
    return wait;
  }
}

void _validatePermits(int permits) {
  if (permits <= 0) {
    throw ArgumentError.value(permits, 'permits', 'Must be positive.');
  }
}
