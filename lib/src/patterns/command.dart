/// Command pattern helpers with undo and redo history.
///
/// Use [Command] to wrap a unit of work and [CommandHistory] to execute,
/// undo, and redo successful undoable commands.
library;

import '../functional/result.dart';

/// Performs command work and returns a value.
typedef CommandAction<T> = T Function();

/// Reverts command work.
typedef CommandUndo = void Function();

/// Determines whether a command can run.
typedef CommandPredicate = bool Function();

/// Base type for command failures.
sealed class CommandError {
  const CommandError({
    required this.commandName,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// Command associated with this failure.
  final String commandName;

  /// Human-readable failure message.
  final String message;

  /// Original thrown object, when available.
  final Object? cause;

  /// Stack trace for thrown failures, when available.
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

/// Failure caused by a command predicate returning false.
final class CommandRejectedError extends CommandError {
  /// Creates a rejected-command error.
  const CommandRejectedError({required super.commandName})
    : super(message: 'Command "$commandName" cannot execute.');
}

/// Failure caused by a thrown command action.
final class CommandExecutionError extends CommandError {
  /// Creates an execution error.
  const CommandExecutionError({
    required super.commandName,
    required super.cause,
    required super.stackTrace,
  }) : super(message: 'Command "$commandName" failed: $cause.');
}

/// Failure caused by undoing a command without undo support.
final class CommandNotUndoableError extends CommandError {
  /// Creates a not-undoable error.
  const CommandNotUndoableError({required super.commandName})
    : super(message: 'Command "$commandName" is not undoable.');
}

/// Failure caused by a thrown undo action.
final class CommandUndoError extends CommandError {
  /// Creates an undo error.
  const CommandUndoError({
    required super.commandName,
    required super.cause,
    required super.stackTrace,
  }) : super(message: 'Undo for "$commandName" failed: $cause.');
}

/// Failure caused by undo or redo with an empty stack.
final class CommandHistoryEmptyError extends CommandError {
  /// Creates an empty-history error.
  const CommandHistoryEmptyError({required super.message})
    : super(commandName: 'history');
}

/// A named unit of work with optional undo support.
///
/// Example:
/// ```dart
/// var value = 0;
/// final increment = Command<int>(
///   name: 'increment',
///   execute: () => ++value,
///   undo: () => value--,
/// );
/// ```
final class Command<T> {
  /// Creates a command.
  Command({
    required this.name,
    required this._execute,
    this._undo,
    this._canExecute,
  });

  /// Command name for diagnostics and history display.
  final String name;

  final CommandAction<T> _execute;
  final CommandUndo? _undo;
  final CommandPredicate? _canExecute;

  /// Whether this command has an undo action.
  bool get isUndoable => _undo != null;

  /// Whether this command is currently allowed to execute.
  bool canExecute() => _canExecute?.call() ?? true;

  /// Runs the command and captures failures as [CommandError] values.
  Result<T, CommandError> execute() {
    if (!canExecute()) {
      return Result<T, CommandError>.failure(
        CommandRejectedError(commandName: name),
      );
    }

    try {
      return Result<T, CommandError>.success(_execute());
    } catch (error, stackTrace) {
      return Result<T, CommandError>.failure(
        CommandExecutionError(
          commandName: name,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Runs the undo action and captures failures as [CommandError] values.
  Result<void, CommandError> undo() {
    final undo = _undo;
    if (undo == null) {
      return Result<void, CommandError>.failure(
        CommandNotUndoableError(commandName: name),
      );
    }

    try {
      undo();
      return Result<void, CommandError>.success(null);
    } catch (error, stackTrace) {
      return Result<void, CommandError>.failure(
        CommandUndoError(
          commandName: name,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

/// Executes commands and maintains undo/redo stacks.
final class CommandHistory {
  /// Creates command history with a maximum undo [maxDepth].
  CommandHistory({this.maxDepth = 100}) {
    if (maxDepth <= 0) {
      throw ArgumentError.value(maxDepth, 'maxDepth', 'Must be positive.');
    }
  }

  /// Maximum number of undoable commands retained.
  final int maxDepth;

  final List<Command<Object?>> _undoStack = [];
  final List<Command<Object?>> _redoStack = [];

  /// Whether there is at least one command to undo.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether there is at least one command to redo.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Number of commands in the undo stack.
  int get undoDepth => _undoStack.length;

  /// Number of commands in the redo stack.
  int get redoDepth => _redoStack.length;

  /// Undo stack command names from oldest to newest.
  List<String> get undoNames =>
      List<String>.unmodifiable(_undoStack.map((command) => command.name));

  /// Redo stack command names from oldest to newest.
  List<String> get redoNames =>
      List<String>.unmodifiable(_redoStack.map((command) => command.name));

  /// Executes [command].
  ///
  /// Successful undoable commands are pushed to the undo stack and clear the
  /// redo stack. Failed or non-undoable commands are not recorded.
  Result<T, CommandError> execute<T>(Command<T> command) {
    final result = command.execute();
    if (result.isSuccess && command.isUndoable) {
      _pushUndo(command);
      _redoStack.clear();
    }
    return result;
  }

  /// Undoes the latest undoable command.
  Result<void, CommandError> undo() {
    if (_undoStack.isEmpty) {
      return const Result<void, CommandError>.failure(
        CommandHistoryEmptyError(message: 'No command to undo.'),
      );
    }

    final command = _undoStack.removeLast();
    final result = command.undo();
    if (result.isSuccess) {
      _redoStack.add(command);
    } else {
      _undoStack.add(command);
    }
    return result;
  }

  /// Redoes the latest undone command.
  Result<void, CommandError> redo() {
    if (_redoStack.isEmpty) {
      return const Result<void, CommandError>.failure(
        CommandHistoryEmptyError(message: 'No command to redo.'),
      );
    }

    final command = _redoStack.removeLast();
    final result = command.execute();
    return result.fold(
      (_) {
        _pushUndo(command);
        return Result<void, CommandError>.success(null);
      },
      (error) {
        _redoStack.add(command);
        return Result<void, CommandError>.failure(error);
      },
    );
  }

  /// Clears undo and redo stacks.
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  void _pushUndo<T>(Command<T> command) {
    _undoStack.add(command as Command<Object?>);
    while (_undoStack.length > maxDepth) {
      _undoStack.removeAt(0);
    }
  }
}
