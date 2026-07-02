import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Log', () {
    late List<String> lines;

    setUp(() {
      lines = <String>[];
      Log.config(output: lines.add);
    });

    tearDown(Log.reset);

    test('should emit level-specific messages', () {
      Log.d('debug');
      Log.i('info');
      Log.w('warning');
      Log.e('error');
      Log.wtf('fatal');

      expect(
        lines,
        equals([
          'DEBUG debug',
          'INFO info',
          'WARN warning',
          'ERROR error',
          'FATAL fatal',
        ]),
      );
    });

    test('should filter by minimum level', () {
      Log.config(minLevel: LogLevel.warning, output: lines.add);

      Log.d('debug');
      Log.i('info');
      Log.w('warning');

      expect(lines, equals(['WARN warning']));
    });

    test('should include tags and filter by enabled tags', () {
      Log.config(enabledTags: {'HTTP'}, output: lines.add);

      Log.i('hidden');
      Log.i('visible', tag: 'HTTP');
      Log.i('hidden', tag: 'DB');

      expect(lines, equals(['INFO [HTTP] visible']));
    });

    test('should include timestamp when configured', () {
      Log.config(
        showTimestamp: true,
        clock: () => DateTime.utc(2026, 1, 2, 3, 4, 5),
        output: lines.add,
      );

      Log.i('ready');

      expect(lines.single, equals('2026-01-02T03:04:05.000Z INFO ready'));
    });

    test('should emit ANSI color codes when configured', () {
      Log.config(useColors: true, output: lines.add);

      Log.e('failed');

      expect(lines.single, startsWith('\x1B[31mERROR failed'));
      expect(lines.single, endsWith('\x1B[0m'));
    });

    test('should include error details and stack traces for errors', () {
      final stackTrace = StackTrace.fromString('trace');

      Log.e('failed', error: StateError('bad'), stackTrace: stackTrace);

      expect(lines.first, contains('ERROR failed | Bad state: bad'));
      expect(lines.last, equals('trace'));
    });
  });
}
