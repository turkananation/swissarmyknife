import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

enum _OrderState { draft, submitted, approved, rejected }

enum _OrderEvent { submit, approve, reject, reopen }

final class _FakeClock {
  _FakeClock(this.now);

  DateTime now;

  DateTime call() => now;
}

void main() {
  group('StateMachine', () {
    test('should transition between states', () {
      final clock = _FakeClock(DateTime.utc(2026, 1, 1));
      final machine = StateMachine<_OrderState, _OrderEvent>(
        initialState: _OrderState.draft,
        transitions: [
          const StateTransitionRule(
            from: _OrderState.draft,
            event: _OrderEvent.submit,
            to: _OrderState.submitted,
          ),
        ],
        clock: clock.call,
      );

      final result = machine.trigger(_OrderEvent.submit);

      expect(result.isSuccess, isTrue);
      expect(machine.currentState, equals(_OrderState.submitted));
      expect(machine.isIn(_OrderState.submitted), isTrue);
      expect(result.valueOrNull?.from, equals(_OrderState.draft));
      expect(result.valueOrNull?.to, equals(_OrderState.submitted));
      expect(result.valueOrNull?.timestamp, equals(clock.now));
      expect(machine.history, hasLength(1));
    });

    test('should expose available events and states', () {
      final machine = StateMachine<_OrderState, _OrderEvent>(
        initialState: _OrderState.submitted,
        transitions: [
          const StateTransitionRule(
            from: _OrderState.submitted,
            event: _OrderEvent.approve,
            to: _OrderState.approved,
          ),
          const StateTransitionRule(
            from: _OrderState.submitted,
            event: _OrderEvent.reject,
            to: _OrderState.rejected,
          ),
        ],
      );

      expect(
        machine.availableEvents,
        equals([_OrderEvent.approve, _OrderEvent.reject]),
      );
      expect(
        machine.availableStates,
        equals([_OrderState.approved, _OrderState.rejected]),
      );
      expect(machine.can(_OrderEvent.approve), isTrue);
      expect(machine.can(_OrderEvent.reopen), isFalse);
    });

    test('should fail when no transition exists', () {
      final machine = StateMachine<_OrderState, _OrderEvent>(
        initialState: _OrderState.draft,
      );

      final result = machine.trigger(_OrderEvent.approve);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<MissingTransitionError>());
      expect(machine.currentState, equals(_OrderState.draft));
      expect(machine.history, isEmpty);
    });

    test('should reject guarded transitions', () {
      final machine = StateMachine<_OrderState, _OrderEvent>(
        initialState: _OrderState.submitted,
        transitions: [
          StateTransitionRule(
            from: _OrderState.submitted,
            event: _OrderEvent.approve,
            to: _OrderState.approved,
            guard: (_) => false,
          ),
        ],
      );

      final result = machine.trigger(_OrderEvent.approve);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<RejectedTransitionError>());
      expect(machine.currentState, equals(_OrderState.submitted));
      expect(machine.history, isEmpty);
    });

    test('should run transition actions and listeners', () {
      final actions = <String>[];
      final machine = StateMachine<_OrderState, _OrderEvent>(
        initialState: _OrderState.draft,
      );
      machine.addTransition(
        _OrderState.draft,
        _OrderEvent.submit,
        _OrderState.submitted,
        action: (transition) => actions.add('action:${transition.event.name}'),
      );
      final unsubscribe = machine.listen(
        (transition) => actions.add('listen:${transition.to.name}'),
      );

      machine.trigger(_OrderEvent.submit);
      unsubscribe();
      machine.addTransition(
        _OrderState.submitted,
        _OrderEvent.reject,
        _OrderState.rejected,
      );
      machine.trigger(_OrderEvent.reject);

      expect(actions, equals(['action:submit', 'listen:submitted']));
    });

    test('should reset state and clear history', () {
      final machine = StateMachine<_OrderState, _OrderEvent>(
        initialState: _OrderState.draft,
        transitions: [
          const StateTransitionRule(
            from: _OrderState.draft,
            event: _OrderEvent.submit,
            to: _OrderState.submitted,
          ),
        ],
      );

      machine.trigger(_OrderEvent.submit);
      machine.reset(_OrderState.draft);

      expect(machine.currentState, equals(_OrderState.draft));
      expect(machine.history, isEmpty);

      machine.trigger(_OrderEvent.submit);
      machine.clearHistory();

      expect(machine.history, isEmpty);
      expect(machine.currentState, equals(_OrderState.submitted));
    });
  });
}
