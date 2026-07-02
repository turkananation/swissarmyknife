import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('benchmark', () {
    test('should measure synchronous actions', () {
      var count = 0;

      final result = benchmark(() => count++, iterations: 3, name: 'count');

      expect(count, equals(3));
      expect(result.name, equals('count'));
      expect(result.iterations, equals(3));
      expect(result.elapsed, isA<Duration>());
      expect(result.perIteration, isA<Duration>());
      expect(result.opsPerSecond, greaterThan(0));
    });

    test('should measure asynchronous actions', () async {
      var count = 0;

      final result = await benchmarkAsync(() async {
        count++;
      }, iterations: 2);

      expect(count, equals(2));
      expect(result.iterations, equals(2));
    });

    test('should compare named benchmarks', () {
      final comparison = compareBenchmarks({
        'a': () {},
        'b': () {},
      }, iterations: 2);

      expect(comparison.results, hasLength(2));
      expect(comparison.fastest, isNotNull);
      expect(comparison.toString(), contains('ops/s'));
    });

    test('should validate iteration count', () {
      expect(() => benchmark(() {}, iterations: 0), throwsArgumentError);
      expect(() => compareBenchmarks({}, iterations: 0), throwsArgumentError);
    });
  });
}
