/// Lightweight reactive state store with selectors.
///
/// Use [ReactiveStore] when a small Dart application needs explicit state
/// updates, synchronous listeners, streams, and derived values without a
/// framework dependency.
library;

import 'dart:async';

/// Compares two values for equality.
typedef StoreEquality<T> = bool Function(T previous, T next);

/// Updates store state.
typedef StoreReducer<T> = T Function(T state);

/// Receives a store change notification.
typedef StoreListener<T> = void Function(StoreChange<T> change);

/// Versioned state change.
final class StoreChange<T> {
  /// Creates a store change.
  const StoreChange({
    required this.previous,
    required this.current,
    required this.version,
  });

  /// State before the change.
  final T previous;

  /// State after the change.
  final T current;

  /// Store version after the change.
  final int version;

  @override
  String toString() => 'StoreChange($previous -> $current, version: $version)';
}

/// Cancellable store listener subscription.
final class StoreSubscription {
  StoreSubscription._(this._cancel);

  final void Function() _cancel;
  bool _isCancelled = false;

  /// Whether this subscription has been cancelled.
  bool get isCancelled => _isCancelled;

  /// Cancels the subscription once.
  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    _cancel();
  }
}

/// Mutable reactive state store.
final class ReactiveStore<T> {
  /// Creates a store with [initialState].
  ReactiveStore(T initialState, {StoreEquality<T>? equals})
    : _state = initialState,
      _equals = equals ?? _defaultEquals;

  final StoreEquality<T> _equals;
  final List<StoreListener<T>> _listeners = [];
  final StreamController<T> _stateController = StreamController<T>.broadcast(
    sync: true,
  );
  final StreamController<StoreChange<T>> _changeController =
      StreamController<StoreChange<T>>.broadcast(sync: true);

  T _state;
  int _version = 0;
  bool _isDisposed = false;

  /// Current state.
  T get state => _state;

  /// Monotonic version. Starts at zero and increments for effective changes.
  int get version => _version;

  /// Whether this store was disposed.
  bool get isDisposed => _isDisposed;

  /// Stream of current state values after changes.
  Stream<T> get stream => _stateController.stream;

  /// Stream of versioned changes.
  Stream<StoreChange<T>> get changes => _changeController.stream;

  /// Sets [nextState].
  ///
  /// Returns `true` when the value changed according to the store equality.
  bool set(T nextState) {
    _ensureActive();
    if (_equals(_state, nextState)) return false;

    final previous = _state;
    _state = nextState;
    _version++;
    _emit(
      StoreChange<T>(previous: previous, current: nextState, version: _version),
    );
    return true;
  }

  /// Updates state with [reducer] and returns the current state.
  T update(StoreReducer<T> reducer) {
    _ensureActive();
    set(reducer(_state));
    return _state;
  }

  /// Adds a synchronous [listener].
  StoreSubscription listen(
    StoreListener<T> listener, {
    bool fireImmediately = false,
  }) {
    _ensureActive();
    _listeners.add(listener);
    if (fireImmediately) {
      listener(
        StoreChange<T>(previous: _state, current: _state, version: _version),
      );
    }
    return StoreSubscription._(() => _listeners.remove(listener));
  }

  /// Creates a derived selector that only emits when selected values change.
  StoreSelector<S> select<S>(
    S Function(T state) selector, {
    StoreEquality<S>? equals,
  }) {
    _ensureActive();
    final selected = StoreSelector<S>._(
      selector(_state),
      equals ?? _defaultEquals,
    );
    final parentSubscription = listen((change) {
      selected._set(selector(change.current));
    });
    selected._attachParent(parentSubscription);
    return selected;
  }

  /// Disposes listeners and closes streams.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _listeners.clear();
    await Future.wait([_stateController.close(), _changeController.close()]);
  }

  void _emit(StoreChange<T> change) {
    _stateController.add(change.current);
    _changeController.add(change);
    for (final listener in List<StoreListener<T>>.of(_listeners)) {
      listener(change);
    }
  }

  void _ensureActive() {
    if (_isDisposed) {
      throw StateError('ReactiveStore has been disposed.');
    }
  }
}

/// Derived reactive value created by [ReactiveStore.select].
final class StoreSelector<T> {
  StoreSelector._(T initialValue, this._equals) : _value = initialValue;

  final StoreEquality<T> _equals;
  final List<StoreListener<T>> _listeners = [];
  final StreamController<T> _stateController = StreamController<T>.broadcast(
    sync: true,
  );
  final StreamController<StoreChange<T>> _changeController =
      StreamController<StoreChange<T>>.broadcast(sync: true);

  T _value;
  int _version = 0;
  bool _isDisposed = false;
  StoreSubscription? _parentSubscription;

  /// Current selected value.
  T get value => _value;

  /// Selector version. Starts at zero and increments for effective changes.
  int get version => _version;

  /// Whether this selector was disposed.
  bool get isDisposed => _isDisposed;

  /// Stream of selected values after changes.
  Stream<T> get stream => _stateController.stream;

  /// Stream of selected value changes.
  Stream<StoreChange<T>> get changes => _changeController.stream;

  /// Adds a synchronous [listener].
  StoreSubscription listen(
    StoreListener<T> listener, {
    bool fireImmediately = false,
  }) {
    _ensureActive();
    _listeners.add(listener);
    if (fireImmediately) {
      listener(
        StoreChange<T>(previous: _value, current: _value, version: _version),
      );
    }
    return StoreSubscription._(() => _listeners.remove(listener));
  }

  /// Disposes this selector and detaches it from the parent store.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _parentSubscription?.cancel();
    _listeners.clear();
    await Future.wait([_stateController.close(), _changeController.close()]);
  }

  void _attachParent(StoreSubscription subscription) {
    _parentSubscription = subscription;
  }

  void _set(T nextValue) {
    if (_isDisposed || _equals(_value, nextValue)) return;

    final previous = _value;
    _value = nextValue;
    _version++;
    final change = StoreChange<T>(
      previous: previous,
      current: nextValue,
      version: _version,
    );

    _stateController.add(nextValue);
    _changeController.add(change);
    for (final listener in List<StoreListener<T>>.of(_listeners)) {
      listener(change);
    }
  }

  void _ensureActive() {
    if (_isDisposed) {
      throw StateError('StoreSelector has been disposed.');
    }
  }
}

bool _defaultEquals<T>(T previous, T next) => previous == next;
