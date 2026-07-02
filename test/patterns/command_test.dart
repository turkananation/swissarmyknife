import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Command', () {
    test('should execute command actions', () {
      final command = Command<int>(name: 'double', execute: () => 21 * 2);

      final result = command.execute();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, equals(42));
      expect(command.isUndoable, isFalse);
    });

    test('should reject commands that cannot execute', () {
      final command = Command<int>(
        name: 'blocked',
        canExecute: () => false,
        execute: () => 1,
      );

      final result = command.execute();

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<CommandRejectedError>());
    });

    test('should capture execution failures', () {
      final command = Command<int>(
        name: 'explode',
        execute: () => throw StateError('bad'),
      );

      final result = command.execute();

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<CommandExecutionError>());
      expect(result.errorOrNull?.cause, isA<StateError>());
    });

    test('should undo command actions', () {
      var value = 0;
      final command = Command<int>(
        name: 'increment',
        execute: () => ++value,
        undo: () => value--,
      );

      expect(command.execute().valueOrNull, equals(1));
      expect(command.undo().isSuccess, isTrue);

      expect(value, equals(0));
    });

    test('should fail undo for commands without undo action', () {
      final command = Command<int>(name: 'read', execute: () => 1);

      final result = command.undo();

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<CommandNotUndoableError>());
    });
  });

  group('CommandHistory', () {
    test('should execute, undo, and redo undoable commands', () {
      var value = 0;
      final history = CommandHistory();
      final increment = Command<int>(
        name: 'increment',
        execute: () => ++value,
        undo: () => value--,
      );

      expect(history.execute(increment).valueOrNull, equals(1));
      expect(history.canUndo, isTrue);
      expect(history.undoDepth, equals(1));
      expect(history.undoNames, equals(['increment']));

      expect(history.undo().isSuccess, isTrue);
      expect(value, equals(0));
      expect(history.canRedo, isTrue);
      expect(history.redoNames, equals(['increment']));

      expect(history.redo().isSuccess, isTrue);
      expect(value, equals(1));
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);
    });

    test('should not record failed or non-undoable commands', () {
      final history = CommandHistory();
      final failing = Command<int>(
        name: 'fail',
        execute: () => throw StateError('bad'),
        undo: () {},
      );
      final read = Command<int>(name: 'read', execute: () => 1);

      expect(history.execute(failing).isFailure, isTrue);
      expect(history.execute(read).isSuccess, isTrue);

      expect(history.canUndo, isFalse);
      expect(history.undoDepth, equals(0));
    });

    test('should clear redo stack after new command execution', () {
      var value = 0;
      Command<int> add(String name, int amount) {
        return Command<int>(
          name: name,
          execute: () => value += amount,
          undo: () => value -= amount,
        );
      }

      final history = CommandHistory();
      history.execute(add('add-one', 1));
      history.undo();

      expect(history.canRedo, isTrue);

      history.execute(add('add-two', 2));

      expect(value, equals(2));
      expect(history.canRedo, isFalse);
      expect(history.undoNames, equals(['add-two']));
    });

    test('should preserve stacks when undo or redo fails', () {
      var canRedo = false;
      final history = CommandHistory();
      final command = Command<int>(
        name: 'fragile',
        execute: () {
          if (!canRedo) return 1;
          throw StateError('redo failed');
        },
        undo: () {},
      );

      history.execute(command);
      expect(history.undo().isSuccess, isTrue);
      canRedo = true;

      final redoResult = history.redo();

      expect(redoResult.isFailure, isTrue);
      expect(history.canRedo, isTrue);
      expect(history.canUndo, isFalse);
    });

    test('should report empty history failures', () {
      final history = CommandHistory();

      expect(history.undo().errorOrNull, isA<CommandHistoryEmptyError>());
      expect(history.redo().errorOrNull, isA<CommandHistoryEmptyError>());
    });

    test('should enforce maximum undo depth', () {
      var value = 0;
      final history = CommandHistory(maxDepth: 2);

      for (final name in ['one', 'two', 'three']) {
        history.execute(
          Command<int>(name: name, execute: () => ++value, undo: () => value--),
        );
      }

      expect(history.undoNames, equals(['two', 'three']));
      expect(history.undoDepth, equals(2));
    });

    test('should clear undo and redo stacks', () {
      var value = 0;
      final history = CommandHistory();
      history.execute(
        Command<int>(
          name: 'increment',
          execute: () => ++value,
          undo: () => value--,
        ),
      );
      history.undo();

      history.clear();

      expect(history.canUndo, isFalse);
      expect(history.canRedo, isFalse);
    });

    test('should validate maximum depth', () {
      expect(() => CommandHistory(maxDepth: 0), throwsArgumentError);
    });
  });
}
