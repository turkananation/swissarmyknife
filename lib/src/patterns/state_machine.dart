/// Finite state machine helpers with typed states, events, and transitions.
///
/// Use [StateMachine] for explicit workflow rules where invalid transitions
/// should be represented as [Result] failures instead of scattered conditionals.
library;

import '../functional/result.dart';

/// Predicate that can allow or reject a transition.
typedef StateGuard<S, E> = bool Function(StateTransitionRequest<S, E> request);

/// Side effect invoked after a successful transition.
typedef StateAction<S, E> = void Function(StateTransition<S, E> transition);

/// Immutable request evaluated before a state transition occurs.
final class StateTransitionRequest<S, E> {
  /// Creates a transition request.
  const StateTransitionRequest({
    required this.from,
    required this.event,
    required this.to,
  });

  /// Current state.
  final S from;

  /// Event being triggered.
  final E event;

  /// Target state.
  final S to;
}

/// Immutable successful transition record.
final class StateTransition<S, E> {
  /// Creates a transition record.
  const StateTransition({
    required this.from,
    required this.event,
    required this.to,
    required this.timestamp,
  });

  /// Previous state.
  final S from;

  /// Event that caused the transition.
  final E event;

  /// New state.
  final S to;

  /// Timestamp from the machine clock.
  final DateTime timestamp;
}

/// Transition rule for a finite state machine.
final class StateTransitionRule<S, E> {
  /// Creates a transition rule.
  const StateTransitionRule({
    required this.from,
    required this.event,
    required this.to,
    this.guard,
    this.action,
  });

  /// State this rule starts from.
  final S from;

  /// Event this rule handles.
  final E event;

  /// State this rule transitions to.
  final S to;

  /// Optional predicate that can reject the transition.
  final StateGuard<S, E>? guard;

  /// Optional side effect invoked after the transition.
  final StateAction<S, E>? action;

  bool _matches(S state, E triggeredEvent) {
    return from == state && event == triggeredEvent;
  }
}

/// Base type for state machine transition failures.
sealed class StateMachineError<S, E> {
  const StateMachineError({
    required this.state,
    required this.event,
    required this.message,
  });

  /// State at the time the event was triggered.
  final S state;

  /// Event that failed.
  final E event;

  /// Human-readable error message.
  final String message;

  @override
  String toString() => message;
}

/// Failure caused by a missing transition rule.
final class MissingTransitionError<S, E> extends StateMachineError<S, E> {
  /// Creates a missing-transition error.
  const MissingTransitionError({required super.state, required super.event})
    : super(message: 'No transition from $state for $event.');
}

/// Failure caused by a rejected transition guard.
final class RejectedTransitionError<S, E> extends StateMachineError<S, E> {
  /// Creates a rejected-transition error.
  const RejectedTransitionError({
    required super.state,
    required super.event,
    required this.targetState,
  }) : super(message: 'Transition from $state to $targetState was rejected.');

  /// State that would have been entered if the guard passed.
  final S targetState;
}

/// Mutable finite state machine with typed transition rules.
final class StateMachine<S, E> {
  /// Creates a state machine.
  StateMachine({
    required S initialState,
    Iterable<StateTransitionRule<S, E>> transitions = const [],
    DateTime Function()? clock,
  }) : _currentState = initialState,
       _clock = clock ?? DateTime.now {
    _rules.addAll(transitions);
  }

  S _currentState;
  final DateTime Function() _clock;
  final List<StateTransitionRule<S, E>> _rules = [];
  final List<StateTransition<S, E>> _history = [];
  final List<StateAction<S, E>> _listeners = [];

  /// Current state.
  S get currentState => _currentState;

  /// Transition history in the order transitions occurred.
  List<StateTransition<S, E>> get history => List.unmodifiable(_history);

  /// Registered transition rules.
  List<StateTransitionRule<S, E>> get transitions => List.unmodifiable(_rules);

  /// Events currently accepted from [currentState].
  Iterable<E> get availableEvents sync* {
    for (final rule in _rules) {
      if (rule.from == _currentState) {
        yield rule.event;
      }
    }
  }

  /// Target states currently reachable from [currentState].
  Iterable<S> get availableStates sync* {
    for (final rule in _rules) {
      if (rule.from == _currentState) {
        yield rule.to;
      }
    }
  }

  /// Whether the machine is currently in [state].
  bool isIn(S state) => _currentState == state;

  /// Adds a transition rule.
  void addTransition(
    S from,
    E event,
    S to, {
    StateGuard<S, E>? guard,
    StateAction<S, E>? action,
  }) {
    _rules.add(
      StateTransitionRule<S, E>(
        from: from,
        event: event,
        to: to,
        guard: guard,
        action: action,
      ),
    );
  }

  /// Whether [event] has a rule from [currentState].
  ///
  /// Guards are not evaluated here; use [trigger] for the authoritative result.
  bool can(E event) => _findRule(event) != null;

  /// Triggers [event], returning a transition or typed error.
  Result<StateTransition<S, E>, StateMachineError<S, E>> trigger(E event) {
    final rule = _findRule(event);
    if (rule == null) {
      return Result.failure(
        MissingTransitionError<S, E>(state: _currentState, event: event),
      );
    }

    final request = StateTransitionRequest<S, E>(
      from: _currentState,
      event: event,
      to: rule.to,
    );
    final guard = rule.guard;
    if (guard != null && !guard(request)) {
      return Result.failure(
        RejectedTransitionError<S, E>(
          state: _currentState,
          event: event,
          targetState: rule.to,
        ),
      );
    }

    final transition = StateTransition<S, E>(
      from: _currentState,
      event: event,
      to: rule.to,
      timestamp: _clock(),
    );
    _currentState = rule.to;
    _history.add(transition);

    rule.action?.call(transition);
    for (final listener in List<StateAction<S, E>>.of(_listeners)) {
      listener(transition);
    }

    return Result.success(transition);
  }

  /// Registers [listener] and returns an unsubscribe callback.
  void Function() listen(StateAction<S, E> listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  /// Forces the current state without recording a transition.
  void reset(S state, {bool clearHistory = true}) {
    _currentState = state;
    if (clearHistory) {
      _history.clear();
    }
  }

  /// Clears transition history.
  void clearHistory() {
    _history.clear();
  }

  StateTransitionRule<S, E>? _findRule(E event) {
    for (final rule in _rules) {
      if (rule._matches(_currentState, event)) {
        return rule;
      }
    }
    return null;
  }
}
