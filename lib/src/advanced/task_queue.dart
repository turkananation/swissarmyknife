/// Asynchronous task queue with bounded concurrency and priorities.
///
/// Use [TaskQueue] to serialize or limit background work while preserving a
/// typed [Future] for every queued task.
library;

import 'dart:async';

/// Error emitted when a pending queued task is cancelled.
final class TaskCancelledError implements Exception {
  /// Creates a cancelled-task error.
  const TaskCancelledError(this.taskName);

  /// Optional task name.
  final String? taskName;

  @override
  String toString() {
    final name = taskName;
    return name == null ? 'Task was cancelled.' : 'Task "$name" was cancelled.';
  }
}

/// Handle for a queued task.
final class QueuedTask<T> {
  QueuedTask._(this._entry);

  final _QueuedTaskEntry<T> _entry;

  /// Task name, when provided.
  String? get name => _entry.name;

  /// Task priority. Higher values run first.
  int get priority => _entry.priority;

  /// Whether this task is still waiting to run.
  bool get isPending => _entry.isPending;

  /// Whether this task is actively running.
  bool get isRunning => _entry.isRunning;

  /// Whether this task was cancelled before it ran.
  bool get isCancelled => _entry.isCancelled;

  /// Future completed with the task result.
  Future<T> get future => _entry.completer.future;

  /// Attempts to cancel this task before it starts.
  bool cancel() => _entry.queue._cancel(_entry);
}

/// Bounded asynchronous task queue.
final class TaskQueue {
  /// Creates a task queue.
  TaskQueue({this.concurrency = 1, this.autoStart = true}) {
    if (concurrency <= 0) {
      throw ArgumentError.value(
        concurrency,
        'concurrency',
        'Must be positive.',
      );
    }
  }

  /// Maximum active tasks.
  final int concurrency;

  /// Whether tasks start automatically when enqueued.
  final bool autoStart;

  final List<_QueuedTaskEntry<Object?>> _pending = [];
  int _activeCount = 0;
  int _sequence = 0;
  bool _isPaused = false;
  bool _isClosed = false;

  /// Number of pending tasks.
  int get pendingCount => _pending.length;

  /// Number of active tasks.
  int get activeCount => _activeCount;

  /// Whether the queue is paused.
  bool get isPaused => _isPaused;

  /// Whether the queue is closed to new tasks.
  bool get isClosed => _isClosed;

  /// Whether pending or active work exists.
  bool get hasWork => pendingCount > 0 || activeCount > 0;

  /// Pending task names in the order they would be considered for execution.
  List<String?> get pendingNames {
    final snapshot = [..._pending]..sort(_compareEntries);
    return List<String?>.unmodifiable(snapshot.map((entry) => entry.name));
  }

  /// Adds [action] to the queue.
  ///
  /// Higher [priority] tasks run before lower-priority tasks. Equal-priority
  /// tasks run FIFO.
  QueuedTask<T> add<T>(
    FutureOr<T> Function() action, {
    int priority = 0,
    String? name,
  }) {
    if (_isClosed) {
      throw StateError('TaskQueue is closed.');
    }

    final entry = _QueuedTaskEntry<T>(
      queue: this,
      action: action,
      priority: priority,
      sequence: _sequence++,
      name: name,
    );
    _pending.add(entry as _QueuedTaskEntry<Object?>);
    if (autoStart) {
      _drain();
    }
    return QueuedTask<T>._(entry);
  }

  /// Starts queued tasks if capacity is available.
  void start() {
    _isPaused = false;
    _drain();
  }

  /// Pauses starting additional pending tasks.
  ///
  /// Active tasks are not interrupted.
  void pause() {
    _isPaused = true;
  }

  /// Resumes starting pending tasks.
  void resume() {
    start();
  }

  /// Cancels every pending task.
  int cancelPending() {
    final entries = List<_QueuedTaskEntry<Object?>>.of(_pending);
    var cancelled = 0;
    for (final entry in entries) {
      if (_cancel(entry)) {
        cancelled++;
      }
    }
    return cancelled;
  }

  /// Closes the queue to new tasks.
  ///
  /// Pending tasks are cancelled by default; active tasks are allowed to finish.
  void close({bool cancelPending = true}) {
    _isClosed = true;
    if (cancelPending) {
      this.cancelPending();
    }
  }

  bool _cancel<T>(_QueuedTaskEntry<T> entry) {
    if (!entry.isPending) return false;
    final removed = _pending.remove(entry);
    if (!removed) return false;
    entry.isCancelled = true;
    entry.completer.completeError(TaskCancelledError(entry.name));
    return true;
  }

  void _drain() {
    if (_isPaused) return;
    while (_activeCount < concurrency && _pending.isNotEmpty) {
      _pending.sort(_compareEntries);
      final entry = _pending.removeAt(0);
      if (entry.isCancelled) continue;
      _start(entry);
    }
  }

  void _start(_QueuedTaskEntry<Object?> entry) {
    entry.isPending = false;
    entry.isRunning = true;
    _activeCount++;

    () async {
      try {
        final value = await entry.run();
        if (!entry.completer.isCompleted) {
          entry.complete(value);
        }
      } catch (error, stackTrace) {
        if (!entry.completer.isCompleted) {
          entry.completer.completeError(error, stackTrace);
        }
      } finally {
        entry.isRunning = false;
        _activeCount--;
        _drain();
      }
    }();
  }

  int _compareEntries(
    _QueuedTaskEntry<Object?> left,
    _QueuedTaskEntry<Object?> right,
  ) {
    final priority = right.priority.compareTo(left.priority);
    if (priority != 0) return priority;
    return left.sequence.compareTo(right.sequence);
  }
}

final class _QueuedTaskEntry<T> {
  _QueuedTaskEntry({
    required this.queue,
    required this.action,
    required this.priority,
    required this.sequence,
    required this.name,
  });

  final TaskQueue queue;
  final FutureOr<T> Function() action;
  final int priority;
  final int sequence;
  final String? name;
  final Completer<T> completer = Completer<T>();

  bool isPending = true;
  bool isRunning = false;
  bool isCancelled = false;

  Future<T> run() async => action();

  void complete(Object? value) {
    completer.complete(value as T);
  }
}
