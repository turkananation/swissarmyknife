/// Library-level comment for Stream extensions.
///
/// Contains advanced Stream processing operations including buffering by count,
/// rolling time-based buffers, delayed emission, tapping side effects,
/// and fallback error recovery.
library;

import 'dart:async';

/// Extensions on [Stream] to provide advanced stream transformations.
///
/// Example:
/// ```dart
/// final stream = Stream.fromIterable([1, 2, 3, 4]).buffer(2);
/// await for (final chunk in stream) {
///   print(chunk); // [1, 2], then [3, 4]
/// }
/// ```
extension StreamKnife<T> on Stream<T> {
  /// Groups incoming events into lists of size [count].
  ///
  /// The final emitted list may contain fewer than [count] elements if the
  /// source stream completes before filling it.
  ///
  /// Throws [ArgumentError] if [count] is less than or equal to zero.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 3]).buffer(2);
  /// // Emits: [1, 2], [3]
  /// ```
  Stream<List<T>> buffer(int count) {
    if (count <= 0) {
      throw ArgumentError('Buffer count must be greater than zero.');
    }
    return _buffer(count);
  }

  Stream<List<T>> _buffer(int count) async* {
    var currentBuffer = <T>[];
    await for (final element in this) {
      currentBuffer.add(element);
      if (currentBuffer.length >= count) {
        yield currentBuffer;
        currentBuffer = <T>[];
      }
    }
    if (currentBuffer.isNotEmpty) {
      yield currentBuffer;
    }
  }

  /// Periodically emits lists containing all items emitted since the last
  /// buffer emission.
  ///
  /// Example:
  /// ```dart
  /// final source = Stream.periodic(
  ///   const Duration(milliseconds: 50),
  ///   (i) => i,
  /// ).take(5);
  /// final buffered = source.bufferTime(const Duration(milliseconds: 120));
  /// // Emits chunks of items collected every 120ms
  /// ```
  Stream<List<T>> bufferTime(Duration duration) {
    late StreamController<List<T>> controller;
    StreamSubscription<T>? subscription;
    Timer? timer;
    var currentBuffer = <T>[];

    void emitBuffer() {
      if (currentBuffer.isNotEmpty) {
        controller.add(List<T>.from(currentBuffer));
        currentBuffer.clear();
      }
    }

    controller = StreamController<List<T>>(
      onListen: () {
        subscription = listen(
          (data) {
            currentBuffer.add(data);
          },
          onError: (Object error, StackTrace stackTrace) {
            controller.addError(error, stackTrace);
          },
          onDone: () {
            timer?.cancel();
            emitBuffer();
            controller.close();
          },
          cancelOnError: false,
        );

        timer = Timer.periodic(duration, (_) {
          emitBuffer();
        });
      },
      onPause: () {
        subscription?.pause();
        timer?.cancel();
      },
      onResume: () {
        subscription?.resume();
        timer = Timer.periodic(duration, (_) {
          emitBuffer();
        });
      },
      onCancel: () async {
        timer?.cancel();
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }

  /// Delays each event emission in this stream by [duration].
  ///
  /// Example:
  /// ```dart
  /// final delayed = Stream.fromIterable([1, 2]).delay(const Duration(seconds: 1));
  /// // Each element (1 and 2) is emitted 1 second after it would have been normally
  /// ```
  Stream<T> delay(Duration duration) {
    late StreamController<T> controller;
    StreamSubscription<T>? subscription;
    final activeTimers = <Timer>{};
    var isSourceDone = false;

    void checkClose() {
      if (isSourceDone && activeTimers.isEmpty && !controller.isClosed) {
        controller.close();
      }
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = listen(
          (data) {
            late Timer timer;
            timer = Timer(duration, () {
              if (!controller.isClosed) {
                controller.add(data);
              }
              activeTimers.remove(timer);
              checkClose();
            });
            activeTimers.add(timer);
          },
          onError: (Object error, StackTrace stackTrace) {
            controller.addError(error, stackTrace);
          },
          onDone: () {
            isSourceDone = true;
            checkClose();
          },
          cancelOnError: false,
        );
      },
      onPause: () {
        subscription?.pause();
      },
      onResume: () {
        subscription?.resume();
      },
      onCancel: () async {
        for (final timer in activeTimers) {
          timer.cancel();
        }
        activeTimers.clear();
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }

  /// Triggers the side-effect [action] for each element emitted.
  ///
  /// This does not transform or modify the stream elements.
  ///
  /// Example:
  /// ```dart
  /// final tapped = Stream.fromIterable([1, 2]).tap(print);
  /// // Prints 1, then 2 as elements flow through
  /// ```
  Stream<T> tap(void Function(T value) action) {
    return map((data) {
      action(data);
      return data;
    });
  }

  /// Catches any exception in the stream, emits [defaultValue], and closes the stream.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream<int>.error('err').onErrorReturn(0);
  /// // Emits: 0, then completes.
  /// ```
  Stream<T> onErrorReturn(T defaultValue) {
    late StreamController<T> controller;
    StreamSubscription<T>? subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = listen(
          (data) {
            if (!controller.isClosed) {
              controller.add(data);
            }
          },
          onError: (Object error) {
            if (!controller.isClosed) {
              controller.add(defaultValue);
              controller.close();
            }
            subscription?.cancel();
          },
          onDone: () {
            if (!controller.isClosed) {
              controller.close();
            }
          },
          cancelOnError: false,
        );
      },
      onPause: () {
        subscription?.pause();
      },
      onResume: () {
        subscription?.resume();
      },
      onCancel: () async {
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }
}
