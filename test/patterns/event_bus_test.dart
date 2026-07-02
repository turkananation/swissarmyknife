import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('EventBus', () {
    test('should deliver typed events only to matching listeners', () async {
      final bus = EventBus();
      final strings = bus.on<String>().take(2).toList();

      bus.fire('ready');
      bus.fire(42);
      bus.fire('done');

      expect(await strings, equals(['ready', 'done']));
      await bus.dispose();
    });

    test('should filter events with onWhere', () async {
      final bus = EventBus();
      final errors = bus
          .onWhere<String>((event) => event.startsWith('error'))
          .take(1)
          .toList();

      bus.fire('info: ready');
      bus.fire('error: failed');

      expect(await errors, equals(['error: failed']));
      await bus.dispose();
    });

    test('should complete once with next typed event', () async {
      final bus = EventBus();
      final next = bus.once<int>();

      bus.fire('ignored');
      bus.fire(7);

      expect(await next, equals(7));
      await bus.dispose();
    });

    test('should prevent use after dispose', () async {
      final bus = EventBus();

      await bus.dispose();

      expect(bus.isDisposed, isTrue);
      expect(() => bus.fire('late'), throwsStateError);
      expect(bus.on<String>, throwsStateError);
    });

    test('should expose a global singleton instance', () {
      expect(GlobalEventBus.instance, same(GlobalEventBus.instance));
    });
  });
}
