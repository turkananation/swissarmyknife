import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('ReactiveStore', () {
    test('should set and update state with versioned changes', () {
      final store = ReactiveStore<int>(0);
      final changes = <StoreChange<int>>[];

      store.listen(changes.add);

      expect(store.set(1), isTrue);
      expect(store.update((state) => state + 2), equals(3));

      expect(store.state, equals(3));
      expect(store.version, equals(2));
      expect(changes.map((change) => change.current), equals([1, 3]));
      expect(changes.last.previous, equals(1));
      expect(changes.last.version, equals(2));
    });

    test('should skip equal states', () {
      final store = ReactiveStore<List<int>>(
        const [1, 2],
        equals: (previous, next) =>
            previous.length == next.length &&
            previous.indexed.every((entry) => entry.$2 == next[entry.$1]),
      );
      final changes = <StoreChange<List<int>>>[];
      store.listen(changes.add);

      expect(store.set(const [1, 2]), isFalse);
      expect(store.set(const [1, 2, 3]), isTrue);

      expect(changes, hasLength(1));
      expect(store.version, equals(1));
    });

    test('should support immediate listeners and cancellation', () {
      final store = ReactiveStore<int>(10);
      final values = <int>[];

      final subscription = store.listen(
        (change) => values.add(change.current),
        fireImmediately: true,
      );

      store.set(11);
      subscription.cancel();
      subscription.cancel();
      store.set(12);

      expect(subscription.isCancelled, isTrue);
      expect(values, equals([10, 11]));
    });

    test('should emit state and change streams', () async {
      final store = ReactiveStore<int>(0);
      final states = <int>[];
      final versions = <int>[];

      final stateSub = store.stream.listen(states.add);
      final changeSub = store.changes.listen(
        (change) => versions.add(change.version),
      );

      store
        ..set(1)
        ..set(2);

      expect(states, equals([1, 2]));
      expect(versions, equals([1, 2]));

      await stateSub.cancel();
      await changeSub.cancel();
    });

    test('should select derived values and emit only effective changes', () {
      final store = ReactiveStore<Map<String, Object?>>({
        'count': 0,
        'name': 'Ada',
      });
      final count = store.select((state) => state['count'] as int);
      final selected = <int>[];

      count.listen((change) => selected.add(change.current));

      store.set({'count': 0, 'name': 'Grace'});
      store.set({'count': 1, 'name': 'Grace'});
      store.set({'count': 1, 'name': 'Katherine'});
      store.set({'count': 2, 'name': 'Katherine'});

      expect(count.value, equals(2));
      expect(count.version, equals(2));
      expect(selected, equals([1, 2]));
    });

    test('should support selector streams and disposal', () async {
      final store = ReactiveStore<int>(1);
      final parity = store.select((value) => value.isEven ? 'even' : 'odd');
      final values = <String>[];
      final subscription = parity.stream.listen(values.add);

      store
        ..set(2)
        ..set(4)
        ..set(5);

      expect(values, equals(['even', 'odd']));

      await parity.dispose();
      expect(parity.isDisposed, isTrue);
      expect(() => parity.listen((_) {}), throwsStateError);

      store.set(6);
      expect(values, equals(['even', 'odd']));
      await subscription.cancel();
    });

    test('should dispose stores and reject further work', () async {
      final store = ReactiveStore<int>(0);
      final done = expectLater(store.stream, emitsDone);

      await store.dispose();
      await done;

      expect(store.isDisposed, isTrue);
      expect(() => store.set(1), throwsStateError);
      expect(() => store.listen((_) {}), throwsStateError);
      await store.dispose();
    });
  });
}
