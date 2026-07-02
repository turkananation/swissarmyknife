import 'dart:async';

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Debouncer', () {
    test('should run only latest scheduled action', () async {
      final debouncer = Debouncer(const Duration(milliseconds: 20));
      final values = <int>[];

      debouncer.run(() => values.add(1));
      debouncer.run(() => values.add(2));

      expect(debouncer.isActive, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(values, equals([2]));
      expect(debouncer.isActive, isFalse);
      debouncer.dispose();
    });

    test('should cancel pending action', () async {
      final debouncer = Debouncer(const Duration(milliseconds: 20));
      var called = false;

      debouncer.run(() => called = true);
      debouncer.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(called, isFalse);
      debouncer.dispose();
    });

    test('should prevent use after dispose', () {
      final debouncer = Debouncer(const Duration(milliseconds: 20));

      debouncer.dispose();

      expect(debouncer.isDisposed, isTrue);
      expect(() => debouncer.run(() {}), throwsStateError);
    });
  });

  group('Throttler', () {
    test('should run first action immediately and suppress active window', () {
      final throttler = Throttler(const Duration(milliseconds: 30));
      final values = <int>[];

      throttler.run(() => values.add(1));
      throttler.run(() => values.add(2));

      expect(values, equals([1]));
      expect(throttler.isActive, isTrue);
      throttler.dispose();
    });

    test('should allow another action after throttle window', () async {
      final throttler = Throttler(const Duration(milliseconds: 20));
      final values = <int>[];

      throttler.run(() => values.add(1));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      throttler.run(() => values.add(2));

      expect(values, equals([1, 2]));
      throttler.dispose();
    });

    test('should cancel active window and prevent use after dispose', () {
      final throttler = Throttler(const Duration(milliseconds: 20));
      final values = <int>[];

      throttler.run(() => values.add(1));
      throttler.cancel();
      throttler.run(() => values.add(2));
      throttler.dispose();

      expect(values, equals([1, 2]));
      expect(throttler.isDisposed, isTrue);
      expect(() => throttler.run(() {}), throwsStateError);
    });
  });

  group('StreamKnife debounce & throttle', () {
    test('debounce should emit latest event after quiet period', () async {
      final controller = StreamController<int>();
      final valuesFuture = controller.stream
          .debounce(const Duration(milliseconds: 20))
          .toList();

      controller.add(1);
      controller.add(2);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      controller.add(3);
      await controller.close();

      expect(await valuesFuture, equals([2, 3]));
    });

    test('throttle should emit first event in each window', () async {
      final controller = StreamController<int>();
      final valuesFuture = controller.stream
          .throttle(const Duration(milliseconds: 20))
          .toList();

      controller.add(1);
      controller.add(2);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      controller.add(3);
      await controller.close();

      expect(await valuesFuture, equals([1, 3]));
    });
  });
}
