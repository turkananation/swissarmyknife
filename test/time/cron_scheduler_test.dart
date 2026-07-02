import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('CronExpression', () {
    test('should match five-field cron expressions', () {
      final expression = CronExpression.parse('*/15 9-17 * * MON-FRI');

      expect(expression.matches(DateTime(2026, 7, 2, 9, 0)), isTrue);
      expect(expression.matches(DateTime(2026, 7, 2, 9, 15)), isTrue);
      expect(expression.matches(DateTime(2026, 7, 2, 9, 10)), isFalse);
      expect(expression.matches(DateTime(2026, 7, 4, 9, 0)), isFalse);
    });

    test('should find next occurrences strictly after a cursor', () {
      final expression = CronExpression.parse('0 9 * * *');

      expect(
        expression.next(DateTime(2026, 7, 2, 8, 59, 59)),
        equals(DateTime(2026, 7, 2, 9)),
      );
      expect(
        expression.next(DateTime(2026, 7, 2, 9)),
        equals(DateTime(2026, 7, 3, 9)),
      );
      expect(
        expression.occurrences(DateTime(2026, 7, 2, 8), 3),
        equals([
          DateTime(2026, 7, 2, 9),
          DateTime(2026, 7, 3, 9),
          DateTime(2026, 7, 4, 9),
        ]),
      );
    });

    test('should parse lists, ranges, steps, and names', () {
      final expression = CronExpression.parse('0,30 8-10/2 1 JAN,MAR SUN-SAT');

      expect(expression.matches(DateTime(2026, 1, 1, 8, 0)), isTrue);
      expect(expression.matches(DateTime(2026, 3, 1, 10, 30)), isTrue);
      expect(expression.matches(DateTime(2026, 2, 1, 8, 0)), isFalse);
      expect(expression.matches(DateTime(2026, 1, 2, 8, 0)), isFalse);
      expect(expression.toString(), equals('0,30 8-10/2 1 JAN,MAR SUN-SAT'));
    });

    test('should validate malformed expressions', () {
      expect(() => CronExpression.parse('* * * *'), throwsFormatException);
      expect(() => CronExpression.parse('*/0 * * * *'), throwsFormatException);
      expect(() => CronExpression.parse('60 * * * *'), throwsFormatException);
      expect(() => CronExpression.parse('10-5 * * * *'), throwsFormatException);
      expect(() => CronExpression.parse('* * * BAD *'), throwsFormatException);
      expect(
        () => CronExpression.parse(
          '0 0 31 2 *',
        ).next(DateTime(2026), maxSearch: const Duration(days: 60)),
        throwsStateError,
      );
      expect(
        () => CronExpression.parse('* * * * *').occurrences(DateTime(2026), -1),
        throwsArgumentError,
      );
    });
  });

  group('CronScheduler', () {
    test('should run due tasks and advance next run', () async {
      var now = DateTime(2026, 7, 2, 8, 59);
      final scheduler = CronScheduler(clock: () => now);
      var count = 0;

      final task = scheduler.schedule(
        '0 9 * * *',
        () => count++,
        name: 'daily',
      );

      expect(task.name, equals('daily'));
      expect(task.nextRun, equals(DateTime(2026, 7, 2, 9)));

      var results = await scheduler.runDue(now: now);
      expect(results, isEmpty);
      expect(count, equals(0));

      now = DateTime(2026, 7, 2, 9);
      results = await scheduler.runDue(now: now);

      expect(results, hasLength(1));
      expect(results.single.isSuccess, isTrue);
      expect(results.single.scheduledAt, equals(DateTime(2026, 7, 2, 9)));
      expect(count, equals(1));
      expect(task.runCount, equals(1));
      expect(task.nextRun, equals(DateTime(2026, 7, 3, 9)));
    });

    test('should capture task failures and continue scheduling', () async {
      final scheduler = CronScheduler(clock: () => DateTime(2026, 7, 2, 8, 59));
      final task = scheduler.schedule(
        '0 9 * * *',
        () => throw StateError('bad'),
      );

      final results = await scheduler.runDue(now: DateTime(2026, 7, 2, 9));

      expect(results.single.isFailure, isTrue);
      expect(results.single.error, isA<StateError>());
      expect(task.runCount, equals(1));
      expect(task.nextRun, equals(DateTime(2026, 7, 3, 9)));
    });

    test('should cancel tasks and dispose scheduler', () {
      final scheduler = CronScheduler(clock: () => DateTime(2026, 7, 2, 8, 59));
      final task = scheduler.schedule('0 9 * * *', () {});

      scheduler.start();
      expect(scheduler.isRunning, isTrue);

      task.cancel();
      expect(task.isCancelled, isTrue);
      expect(scheduler.tasks, isEmpty);

      scheduler.schedule('0 10 * * *', () {});
      scheduler.dispose();

      expect(scheduler.isRunning, isFalse);
      expect(scheduler.tasks, isEmpty);
    });

    test('should validate scheduled expression type', () {
      final scheduler = CronScheduler();

      expect(() => scheduler.schedule(123, () {}), throwsArgumentError);
    });
  });
}
