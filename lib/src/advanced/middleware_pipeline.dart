/// Generic async-aware middleware pipeline.
///
/// Middleware can transform input before calling `next`, wrap the downstream
/// result after `next`, or short-circuit by returning without calling `next`.
library;

import 'dart:async';

import '../functional/result.dart';

/// Continues a middleware chain with [input].
typedef MiddlewareNext<T> = Future<T> Function(T input);

/// Middleware function.
typedef Middleware<T> = FutureOr<T> Function(T input, MiddlewareNext<T> next);

/// Terminal handler at the end of a pipeline.
typedef MiddlewareHandler<T> = FutureOr<T> Function(T input);

/// Immutable middleware pipeline.
final class MiddlewarePipeline<T> {
  /// Creates a middleware pipeline.
  MiddlewarePipeline({
    Iterable<Middleware<T>> middleware = const [],
    MiddlewareHandler<T>? terminal,
  }) : middleware = List<Middleware<T>>.unmodifiable(middleware),
       terminal = terminal ?? _identityTerminal;

  /// Middleware in execution order.
  final List<Middleware<T>> middleware;

  /// Terminal handler.
  final MiddlewareHandler<T> terminal;

  /// Number of middleware entries.
  int get length => middleware.length;

  /// Whether no middleware entries are registered.
  bool get isEmpty => middleware.isEmpty;

  /// Returns a copy with [entry] appended.
  MiddlewarePipeline<T> use(Middleware<T> entry) {
    return MiddlewarePipeline<T>(
      middleware: [...middleware, entry],
      terminal: terminal,
    );
  }

  /// Returns a copy with [entries] appended.
  MiddlewarePipeline<T> useAll(Iterable<Middleware<T>> entries) {
    return MiddlewarePipeline<T>(
      middleware: [...middleware, ...entries],
      terminal: terminal,
    );
  }

  /// Returns a copy with [handler] as terminal.
  MiddlewarePipeline<T> withTerminal(MiddlewareHandler<T> handler) {
    return MiddlewarePipeline<T>(middleware: middleware, terminal: handler);
  }

  /// Runs the pipeline.
  Future<T> run(T input, {MiddlewareHandler<T>? terminal}) {
    final activeTerminal = terminal ?? this.terminal;

    Future<T> dispatch(int index, T value) async {
      if (index >= middleware.length) {
        return activeTerminal(value);
      }

      var nextCalled = false;
      final entry = middleware[index];
      return entry(value, (nextValue) {
        if (nextCalled) {
          throw StateError('Middleware next() was called more than once.');
        }
        nextCalled = true;
        return dispatch(index + 1, nextValue);
      });
    }

    return dispatch(0, input);
  }

  /// Runs the pipeline and captures thrown objects as [Result] failures.
  Future<Result<T, Object>> tryRun(
    T input, {
    MiddlewareHandler<T>? terminal,
  }) async {
    return Result.runCatchingAsync(() => run(input, terminal: terminal));
  }

  /// Middleware that observes [input] without changing it.
  static Middleware<T> tap<T>(FutureOr<void> Function(T input) observe) {
    return (input, next) async {
      await observe(input);
      return next(input);
    };
  }

  /// Middleware that transforms input before continuing.
  static Middleware<T> transform<T>(FutureOr<T> Function(T input) transform) {
    return (input, next) async {
      return next(await transform(input));
    };
  }

  /// Middleware that throws [error] when [test] rejects the input.
  static Middleware<T> guard<T>(bool Function(T input) test, {Object? error}) {
    return (input, next) {
      if (!test(input)) {
        final failure = error ?? StateError('Middleware guard rejected input.');
        throw failure;
      }
      return next(input);
    };
  }
}

T _identityTerminal<T>(T input) => input;
