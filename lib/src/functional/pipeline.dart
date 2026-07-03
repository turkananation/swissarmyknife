/// Pipeline and pipe helpers for explicit value transformation flows.
///
/// Use [Pipe] for reusable transforms, [Pipeline] for value-first chains, and
/// [AsyncPipeline] when any step may be asynchronous.
library;

import 'dart:async';

import 'result.dart';

/// A reusable synchronous transformation from [T] to [R].
///
/// Example:
/// ```dart
/// final trimAndParse = Pipe<String, String>((s) => s.trim())
///     .then((s) => int.parse(s));
/// ```
final class Pipe<T, R> {
  /// Creates a reusable pipe from the supplied transformation.
  const Pipe(this._transform);

  final R Function(T value) _transform;

  /// Runs this pipe.
  R call(T value) => _transform(value);

  /// Composes this pipe with another synchronous [next] transform.
  Pipe<T, N> then<N>(N Function(R value) next) {
    return Pipe<T, N>((value) => next(_transform(value)));
  }

  /// Composes this pipe with an asynchronous [next] transform.
  AsyncPipe<T, N> thenAsync<N>(FutureOr<N> Function(R value) next) {
    return AsyncPipe<T, N>((value) async => next(_transform(value)));
  }

  /// Runs this pipe and captures thrown objects as a [Result].
  Result<R, Object> runCatching(T value) {
    return Result.runCatching(() => _transform(value));
  }
}

/// A reusable asynchronous transformation from [T] to [R].
final class AsyncPipe<T, R> {
  /// Creates a reusable async pipe from the supplied transformation.
  const AsyncPipe(this._transform);

  final FutureOr<R> Function(T value) _transform;

  /// Runs this async pipe.
  Future<R> call(T value) async => _transform(value);

  /// Composes this async pipe with another sync or async [next] transform.
  AsyncPipe<T, N> then<N>(FutureOr<N> Function(R value) next) {
    return AsyncPipe<T, N>((value) async => next(await call(value)));
  }

  /// Runs this pipe and captures thrown objects as a [Result].
  Future<Result<R, Object>> runCatching(T value) {
    return Result.runCatchingAsync(() => call(value));
  }
}

/// Starts a [Pipeline] with [value].
Pipeline<T> pipeline<T>(T value) => Pipeline<T>(value);

/// Starts an [AsyncPipeline] with [value].
AsyncPipeline<T> asyncPipeline<T>(FutureOr<T> value) {
  return AsyncPipeline<T>.value(value);
}

/// Value-first synchronous transformation chain.
///
/// Example:
/// ```dart
/// final value = Pipeline(' 21 ')
///     .map((s) => s.trim())
///     .map(int.parse)
///     .map((n) => n * 2)
///     .result;
/// ```
final class Pipeline<T> {
  /// Creates a pipeline with [value].
  const Pipeline(this.value);

  /// Current pipeline value.
  final T value;

  /// Current pipeline value.
  T get result => value;

  /// Transforms the current value.
  Pipeline<R> map<R>(R Function(T value) transform) {
    return Pipeline<R>(transform(value));
  }

  /// Alias for [map] when reading the chain as sequential steps.
  Pipeline<R> then<R>(R Function(T value) transform) => map(transform);

  /// Applies a reusable [pipe].
  Pipeline<R> apply<R>(Pipe<T, R> pipe) => Pipeline<R>(pipe(value));

  /// Runs [action] for side effects and preserves the current value.
  Pipeline<T> tap(void Function(T value) action) {
    action(value);
    return this;
  }

  /// Requires [predicate] to pass for the current value.
  ///
  /// Throws [StateError] with [message] when the predicate returns false.
  Pipeline<T> guard(
    bool Function(T value) predicate, {
    String message = 'Pipeline guard failed.',
  }) {
    if (!predicate(value)) {
      throw StateError(message);
    }
    return this;
  }

  /// Transforms the current value asynchronously.
  AsyncPipeline<R> mapAsync<R>(FutureOr<R> Function(T value) transform) {
    return AsyncPipeline<R>.value(Future<R>.sync(() => transform(value)));
  }

  /// Applies an async [pipe].
  AsyncPipeline<R> applyAsync<R>(AsyncPipe<T, R> pipe) {
    return AsyncPipeline<R>.value(pipe(value));
  }

  /// Returns the current value as a successful [Result].
  Result<T, Never> toResult() => Result<T, Never>.success(value);

  /// Runs [transform] and captures thrown objects as a [Result].
  Result<R, Object> runCatching<R>(R Function(T value) transform) {
    return Result.runCatching(() => transform(value));
  }
}

/// Value-first async transformation chain.
final class AsyncPipeline<T> {
  const AsyncPipeline._(this._future);

  /// Creates an async pipeline from a value or future.
  factory AsyncPipeline.value(FutureOr<T> value) {
    return AsyncPipeline<T>._(Future<T>.value(value));
  }

  final Future<T> _future;

  /// Resolves the current pipeline value.
  Future<T> get result => _future;

  /// Transforms the current value with a sync or async [transform].
  AsyncPipeline<R> map<R>(FutureOr<R> Function(T value) transform) {
    return AsyncPipeline<R>._(_future.then((value) => transform(value)));
  }

  /// Alias for [map] when reading the chain as sequential steps.
  AsyncPipeline<R> then<R>(FutureOr<R> Function(T value) transform) {
    return map(transform);
  }

  /// Applies a reusable async [pipe].
  AsyncPipeline<R> apply<R>(AsyncPipe<T, R> pipe) {
    return AsyncPipeline<R>._(_future.then(pipe.call));
  }

  /// Applies a reusable synchronous [pipe].
  AsyncPipeline<R> applySync<R>(Pipe<T, R> pipe) {
    return AsyncPipeline<R>._(_future.then(pipe.call));
  }

  /// Runs [action] for side effects and preserves the current value.
  AsyncPipeline<T> tap(FutureOr<void> Function(T value) action) {
    return AsyncPipeline<T>._(
      _future.then((value) async {
        await action(value);
        return value;
      }),
    );
  }

  /// Requires [predicate] to pass for the current value.
  AsyncPipeline<T> guard(
    FutureOr<bool> Function(T value) predicate, {
    String message = 'Pipeline guard failed.',
  }) {
    return AsyncPipeline<T>._(
      _future.then((value) async {
        if (!await predicate(value)) {
          throw StateError(message);
        }
        return value;
      }),
    );
  }

  /// Resolves the current value and captures thrown objects as a [Result].
  Future<Result<T, Object>> runCatching() {
    return Result.runCatchingAsync(() => _future);
  }
}

/// Pipe helpers on any value.
extension PipeKnife<T> on T {
  /// Applies [transform] to this value.
  R pipe<R>(R Function(T value) transform) => transform(this);

  /// Starts a [Pipeline] with this value.
  Pipeline<T> toPipeline() => Pipeline<T>(this);

  /// Starts an [AsyncPipeline] with this value.
  AsyncPipeline<T> toAsyncPipeline() => AsyncPipeline<T>.value(this);
}

/// Pipe helpers on futures.
extension FuturePipeKnife<T> on Future<T> {
  /// Starts an [AsyncPipeline] from this future.
  AsyncPipeline<T> toAsyncPipeline() => AsyncPipeline<T>.value(this);
}
