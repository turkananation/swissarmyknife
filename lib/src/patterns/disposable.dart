/// Disposable resource helpers.
///
/// Use [Disposable] and [DisposeBag] to collect timers, stream subscriptions,
/// controllers, and custom resources behind one cleanup point.
library;

import 'dart:async';

/// Mixin for objects with a synchronous dispose lifecycle.
///
/// Example:
/// ```dart
/// class Controller with Disposable {
///   void close() => dispose();
/// }
/// ```
mixin Disposable {
  bool _isDisposed = false;

  /// Whether this object has been disposed.
  bool get isDisposed => _isDisposed;

  /// Marks this object as disposed.
  ///
  /// Override this method for custom cleanup and call `super.dispose()`.
  void dispose() {
    _isDisposed = true;
  }

  /// Throws if this object has already been disposed.
  ///
  /// Example:
  /// ```dart
  /// ensureNotDisposed();
  /// ```
  void ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('Object has been disposed.');
    }
  }
}

/// Collects resources and disposes them together.
///
/// Example:
/// ```dart
/// final bag = DisposeBag();
/// bag.addTimer(Timer.run(() {}));
/// await bag.disposeAll();
/// ```
final class DisposeBag with Disposable {
  final _disposeActions = <FutureOr<void> Function()>[];

  /// Number of resources currently registered.
  int get length => _disposeActions.length;

  /// Whether no resources are currently registered.
  bool get isEmpty => _disposeActions.isEmpty;

  /// Registers a supported [resource] and returns it unchanged.
  ///
  /// Supports [Disposable], [StreamSubscription], [Timer], and
  /// [StreamController].
  T add<T>(T resource) {
    ensureNotDisposed();
    switch (resource) {
      case Disposable disposable:
        _disposeActions.add(disposable.dispose);
      case StreamSubscription<dynamic> subscription:
        _disposeActions.add(subscription.cancel);
      case Timer timer:
        _disposeActions.add(timer.cancel);
      case StreamController<dynamic> controller:
        _disposeActions.add(() {
          unawaited(controller.close());
        });
      default:
        throw ArgumentError.value(
          resource,
          'resource',
          'Unsupported disposable resource.',
        );
    }
    return resource;
  }

  /// Registers [timer] for cancellation.
  ///
  /// Example:
  /// ```dart
  /// bag.addTimer(Timer(const Duration(seconds: 1), () {}));
  /// ```
  Timer addTimer(Timer timer) => add(timer);

  /// Registers [controller] for closing.
  ///
  /// Example:
  /// ```dart
  /// bag.addController(StreamController<int>());
  /// ```
  StreamController<T> addController<T>(StreamController<T> controller) {
    return add(controller);
  }

  /// Registers [subscription] for cancellation.
  ///
  /// Example:
  /// ```dart
  /// bag.addSubscription(stream.listen(print));
  /// ```
  StreamSubscription<T> addSubscription<T>(StreamSubscription<T> subscription) {
    return add(subscription);
  }

  /// Registers [resource] with a custom [dispose] callback.
  ///
  /// Example:
  /// ```dart
  /// bag.autoDispose(file, (file) => file.close());
  /// ```
  T autoDispose<T>(T resource, FutureOr<void> Function(T resource) dispose) {
    ensureNotDisposed();
    _disposeActions.add(() => dispose(resource));
    return resource;
  }

  /// Disposes all resources in reverse registration order.
  ///
  /// If multiple resources throw, the first error is rethrown after every
  /// resource has had a chance to clean up.
  Future<void> disposeAll() async {
    if (isDisposed) return;

    Object? firstError;
    StackTrace? firstStackTrace;
    final actions = List<FutureOr<void> Function()>.from(_disposeActions);
    _disposeActions.clear();

    for (final action in actions.reversed) {
      try {
        await Future<void>.sync(action);
      } catch (error, stackTrace) {
        firstError ??= error;
        firstStackTrace ??= stackTrace;
      }
    }

    super.dispose();

    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStackTrace!);
    }
  }

  @override
  void dispose() {
    unawaited(disposeAll());
  }
}
