import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('RegExpKnife', () {
    group('allMatchesWithNames', () {
      test('should extract named capture groups for all matches', () {
        final regex = RegExp(r'(?<key>\w+): (?<value>\w+)');
        final matches = regex.allMatchesWithNames('id: 123 name: john');
        expect(matches.length, equals(2));
        expect(matches[0], equals({'key': 'id', 'value': '123'}));
        expect(matches[1], equals({'key': 'name', 'value': 'john'}));
      });

      test('should return empty maps if matches have no named groups', () {
        final regex = RegExp(r'\w+');
        final matches = regex.allMatchesWithNames('hello world');
        expect(matches.length, equals(2));
        expect(matches[0], isEmpty);
        expect(matches[1], isEmpty);
      });

      test('should return empty list if no matches', () {
        final regex = RegExp(r'\d+');
        expect(regex.allMatchesWithNames('hello world'), isEmpty);
      });
    });

    group('firstMatchWithNames', () {
      test('should extract named capture groups for the first match', () {
        final regex = RegExp(r'(?<key>\w+): (?<value>\w+)');
        final match = regex.firstMatchWithNames('id: 123 name: john');
        expect(match, equals({'key': 'id', 'value': '123'}));
      });

      test('should return null if no match is found', () {
        final regex = RegExp(r'\d+');
        expect(regex.firstMatchWithNames('hello world'), isNull);
      });
    });

    group('replaceAllMappedNamed', () {
      test('should replace all matches using named group map', () {
        final regex = RegExp(r'\$(?<var>\w+)');
        final result = regex.replaceAllMappedNamed(
          'hello \$user, greeting \$user',
          (groups) => groups['var'] == 'user' ? 'Alice' : '',
        );
        expect(result, equals('hello Alice, greeting Alice'));
      });

      test('should return original string if no matches', () {
        final regex = RegExp(r'\$(?<var>\w+)');
        final result = regex.replaceAllMappedNamed(
          'hello world',
          (groups) => 'test',
        );
        expect(result, equals('hello world'));
      });
    });

    group('isMatch', () {
      test('should return true if regex matches', () {
        expect(RegExp(r'\d+').isMatch('123'), isTrue);
      });

      test('should return false if regex does not match', () {
        expect(RegExp(r'\d+').isMatch('abc'), isFalse);
      });
    });
  });
}
