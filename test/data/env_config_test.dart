import 'dart:io';

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Env', () {
    tearDown(() {
      Env.fromMap({});
    });

    test('should read values from map', () {
      Env.fromMap({
        'API_KEY': 'secret',
        'PORT': '8080',
        'DEBUG': 'true',
        'RATIO': '1.5',
      });

      expect(Env.get('API_KEY'), equals('secret'));
      expect(Env.getInt('PORT'), equals(8080));
      expect(Env.getBool('DEBUG'), isTrue);
      expect(Env.getDouble('RATIO'), equals(1.5));
      expect(Env.getOr('MISSING', 'fallback'), equals('fallback'));
      expect(Env.getOrNull('MISSING'), isNull);
    });

    test('should load dotenv files', () {
      final file = File(
        '${Directory.systemTemp.path}/swissarmyknife_env_test.env',
      );
      file.writeAsStringSync('''
# ignored
API_KEY="secret"
PORT=8080
NAME='Ada'
''');

      addTearDown(() {
        if (file.existsSync()) file.deleteSync();
      });

      Env.load(file.path);

      expect(Env.get('API_KEY'), equals('secret'));
      expect(Env.get('NAME'), equals('Ada'));
      expect(Env.getInt('PORT'), equals(8080));
    });

    test('should require keys and reject invalid typed values', () {
      Env.fromMap({'PORT': 'not-int', 'DEBUG': 'maybe'});

      expect(() => Env.get('MISSING'), throwsStateError);
      expect(() => Env.require(['PORT', 'API_KEY']), throwsStateError);
      expect(() => Env.getInt('PORT'), throwsStateError);
      expect(() => Env.getBool('DEBUG'), throwsStateError);
      expect(() => Env.getDouble('PORT'), throwsStateError);
    });
  });
}
