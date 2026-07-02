import 'dart:async';

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('TaskQueue', () {
    test('should run queued tasks and complete typed futures', () async {
      final queue = TaskQueue();

      final task = queue.add(() => 42, name: 'answer');

      expect(task.name, equals('answer'));
      await expectLater(task.future, completion(equals(42)));
      expect(queue.hasWork, isFalse);
    });

    test('should honor concurrency limits', () async {
      final queue = TaskQueue(concurrency: 2);
      final first = Completer<void>();
      final second = Completer<void>();
      final third = Completer<void>();
      final running = <String>[];

      queue.add(() async {
        running.add('first');
        await first.future;
      });
      queue.add(() async {
        running.add('second');
        await second.future;
      });
      queue.add(() async {
        running.add('third');
        await third.future;
      });

      await Future<void>.delayed(Duration.zero);

      expect(running, equals(['first', 'second']));
      expect(queue.activeCount, equals(2));
      expect(queue.pendingCount, equals(1));

      first.complete();
      await Future<void>.delayed(Duration.zero);

      expect(running, equals(['first', 'second', 'third']));
      second.complete();
      third.complete();
    });

    test('should run higher priority pending tasks first', () async {
      final queue = TaskQueue(autoStart: false);
      final order = <String>[];

      queue.add(() => order.add('low'), priority: 0, name: 'low');
      queue.add(() => order.add('high'), priority: 10, name: 'high');
      queue.add(() => order.add('middle'), priority: 5, name: 'middle');

      expect(queue.pendingNames, equals(['high', 'middle', 'low']));

      queue.start();
      await Future<void>.delayed(Duration.zero);

      expect(order, equals(['high', 'middle', 'low']));
    });

    test('should pause and resume starting pending tasks', () async {
      final queue = TaskQueue();
      final order = <int>[];

      queue.pause();
      queue.add(() => order.add(1));
      queue.add(() => order.add(2));
      await Future<void>.delayed(Duration.zero);

      expect(order, isEmpty);
      expect(queue.pendingCount, equals(2));

      queue.resume();
      await Future<void>.delayed(Duration.zero);

      expect(order, equals([1, 2]));
    });

    test('should cancel pending tasks', () async {
      final queue = TaskQueue(autoStart: false);
      final task = queue.add(() => 1, name: 'pending');

      expect(task.cancel(), isTrue);
      expect(task.isCancelled, isTrue);
      expect(queue.pendingCount, equals(0));
      await expectLater(task.future, throwsA(isA<TaskCancelledError>()));
      expect(task.cancel(), isFalse);
    });

    test('should cancel all pending tasks', () async {
      final queue = TaskQueue(autoStart: false);
      final first = queue.add(() => 1, name: 'first');
      final second = queue.add(() => 2, name: 'second');

      expect(queue.cancelPending(), equals(2));

      await expectLater(first.future, throwsA(isA<TaskCancelledError>()));
      await expectLater(second.future, throwsA(isA<TaskCancelledError>()));
      expect(queue.pendingCount, equals(0));
    });

    test('should close queue and reject new tasks', () async {
      final queue = TaskQueue(autoStart: false);
      final task = queue.add(() => 1);

      queue.close();

      expect(queue.isClosed, isTrue);
      expect(queue.pendingCount, equals(0));
      expect(() => queue.add(() => 2), throwsStateError);
      await expectLater(task.future, throwsA(isA<TaskCancelledError>()));
    });

    test('should allow active tasks to finish when closed', () async {
      final queue = TaskQueue();
      final completer = Completer<int>();
      final task = queue.add(() => completer.future);
      await Future<void>.delayed(Duration.zero);

      queue.close();
      completer.complete(7);

      await expectLater(task.future, completion(equals(7)));
      expect(queue.hasWork, isFalse);
    });

    test('should complete task futures with action errors', () async {
      final queue = TaskQueue();

      final task = queue.add<int>(() => throw StateError('bad'));

      await expectLater(task.future, throwsStateError);
      expect(queue.hasWork, isFalse);
    });

    test('should validate concurrency', () {
      expect(() => TaskQueue(concurrency: 0), throwsArgumentError);
    });
  });
}
