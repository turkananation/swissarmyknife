/// Lightweight benchmarking helpers.
///
/// Use these utilities for quick local comparisons and diagnostics. They are
/// not a replacement for full statistical benchmarking suites.
library;

/// Result of a benchmark run.
///
/// Example:
/// ```dart
/// final result = benchmark(() => doWork(), iterations: 100);
/// print(result.opsPerSecond);
/// ```
final class BenchmarkResult {
  /// Creates a benchmark result.
  const BenchmarkResult({
    required this.iterations,
    required this.elapsed,
    this.name,
  });

  /// Optional benchmark name.
  final String? name;

  /// Number of iterations executed.
  final int iterations;

  /// Total elapsed duration.
  final Duration elapsed;

  /// Average duration per iteration.
  Duration get perIteration {
    if (iterations == 0) return Duration.zero;
    return Duration(microseconds: elapsed.inMicroseconds ~/ iterations);
  }

  /// Approximate operations per second.
  double get opsPerSecond {
    final micros = elapsed.inMicroseconds;
    if (micros == 0) return double.infinity;
    return iterations * Duration.microsecondsPerSecond / micros;
  }

  @override
  String toString() {
    final label = name == null ? 'benchmark' : 'benchmark $name';
    return '$label: $iterations iterations in ${elapsed.inMicroseconds}us';
  }
}

/// Collection of benchmark comparison results.
///
/// Example:
/// ```dart
/// final comparison = compareBenchmarks({'a': a, 'b': b});
/// ```
final class BenchmarkComparison {
  /// Creates a comparison from [results].
  const BenchmarkComparison(this.results);

  /// Benchmark results in input order.
  final List<BenchmarkResult> results;

  /// The fastest benchmark result, or `null` when empty.
  BenchmarkResult? get fastest {
    if (results.isEmpty) return null;
    return results.reduce(
      (best, next) => next.elapsed < best.elapsed ? next : best,
    );
  }

  @override
  String toString() {
    return results
        .map((result) {
          final name = result.name ?? 'benchmark';
          final micros = result.perIteration.inMicroseconds;
          return '$name: ${micros}us/iter, ${result.opsPerSecond.toStringAsFixed(2)} ops/s';
        })
        .join('\n');
  }
}

/// Benchmarks a synchronous [action].
BenchmarkResult benchmark(
  void Function() action, {
  int iterations = 1,
  String? name,
}) {
  _validateIterations(iterations);
  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    action();
  }
  stopwatch.stop();
  return BenchmarkResult(
    name: name,
    iterations: iterations,
    elapsed: stopwatch.elapsed,
  );
}

/// Benchmarks an asynchronous [action].
Future<BenchmarkResult> benchmarkAsync(
  Future<void> Function() action, {
  int iterations = 1,
  String? name,
}) async {
  _validateIterations(iterations);
  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    await action();
  }
  stopwatch.stop();
  return BenchmarkResult(
    name: name,
    iterations: iterations,
    elapsed: stopwatch.elapsed,
  );
}

/// Benchmarks several named [actions] for side-by-side comparison.
BenchmarkComparison compareBenchmarks(
  Map<String, void Function()> actions, {
  int iterations = 1,
}) {
  _validateIterations(iterations);
  return BenchmarkComparison([
    for (final entry in actions.entries)
      benchmark(entry.value, iterations: iterations, name: entry.key),
  ]);
}

void _validateIterations(int iterations) {
  if (iterations <= 0) {
    throw ArgumentError.value(iterations, 'iterations', 'Must be positive.');
  }
}
