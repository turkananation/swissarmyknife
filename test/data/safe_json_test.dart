import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('SafeJson', () {
    test('should read nested map values by dot path', () {
      final json = {
        'user': {
          'profile': {'name': 'Ada', 'age': '37'},
        },
      };

      expect(json.at('user.profile.name').asStringOr('Unknown'), equals('Ada'));
      expect(json.at('user.profile.age').asIntOr(0), equals(37));
    });

    test('should read list indexes by numeric path segments', () {
      final json = {
        'users': [
          {'name': 'Ada'},
          {'name': 'Grace'},
        ],
      };

      expect(json.at('users.1.name').asStringOr('Unknown'), equals('Grace'));
      expect(json.at('users.2.name').exists, isFalse);
    });

    test('should convert primitive values with defaults', () {
      final json = {'flag': 'yes', 'ratio': '1.5', 'count': 2.9};

      expect(json.at('flag').asBoolOr(false), isTrue);
      expect(json.at('ratio').asDoubleOr(0), equals(1.5));
      expect(json.at('count').asIntOr(0), equals(2));
      expect(json.at('missing').asStringOr('fallback'), equals('fallback'));
    });

    test('should convert typed lists and maps safely', () {
      final json = {
        'tags': ['dart', 'utils'],
        'badTags': ['dart', 1],
        'meta': {'active': true},
      };

      expect(json.at('tags').asListOr<String>([]), equals(['dart', 'utils']));
      expect(
        json.at('badTags').asListOr<String>(['fallback']),
        equals(['fallback']),
      );
      expect(json.at('meta').asMapOr({}), equals({'active': true}));
    });
  });
}
