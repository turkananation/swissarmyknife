import 'dart:async';

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

final class _TrackedDisposable with Disposable {
  int disposeCount = 0;

  @override
  void dispose() {
    disposeCount++;
    super.dispose();
  }
}

void main() {
  group('Disposable', () {
    test('should track disposed state', () {
      final disposable = _TrackedDisposable();

      expect(disposable.isDisposed, isFalse);
      disposable.ensureNotDisposed();
      disposable.dispose();

      expect(disposable.isDisposed, isTrue);
      expect(disposable.ensureNotDisposed, throwsStateError);
      expect(disposable.disposeCount, equals(1));
    });
  });

  group('DisposeBag', () {
    test('should dispose registered Disposable resources', () async {
      final bag = DisposeBag();
      final disposable = bag.add(_TrackedDisposable());

      expect(bag.length, equals(1));
      await bag.disposeAll();

      expect(disposable.isDisposed, isTrue);
      expect(bag.isDisposed, isTrue);
      expect(bag.isEmpty, isTrue);
    });

    test('should cancel timers and stream subscriptions', () async {
      final bag = DisposeBag();
      final controller = StreamController<int>();
      var timerCalled = false;
      var subscriptionDone = false;

      final timer = bag.addTimer(
        Timer(const Duration(milliseconds: 30), () => timerCalled = true),
      );
      final subscription = bag.addSubscription(
        controller.stream.listen((_) {}, onDone: () => subscriptionDone = true),
      );

      await bag.disposeAll();
      await controller.close();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(timer.isActive, isFalse);
      expect(timerCalled, isFalse);
      expect(subscription, isA<StreamSubscription<int>>());
      expect(subscriptionDone, isFalse);
    });

    test('should close stream controllers and custom resources', () async {
      final bag = DisposeBag();
      final controller = bag.addController(StreamController<int>());
      final events = <String>[];

      bag.autoDispose('first', (value) => events.add(value));
      bag.autoDispose('second', (value) => events.add(value));

      await bag.disposeAll();

      expect(controller.isClosed, isTrue);
      expect(events, equals(['second', 'first']));
    });

    test('should reject unsupported resources and use after dispose', () async {
      final bag = DisposeBag();

      expect(() => bag.add(Object()), throwsArgumentError);
      await bag.disposeAll();
      expect(() => bag.add(_TrackedDisposable()), throwsStateError);
    });
  });
}
