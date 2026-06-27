import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('UriKnife', () {
    group('addQueryParams', () {
      test('should append query params to Uri', () {
        final uri = Uri.parse('https://example.com/users?id=123');
        final updated = uri.addQueryParams({'role': 'admin', 'active': true});
        expect(updated.queryParameters['id'], equals('123'));
        expect(updated.queryParameters['role'], equals('admin'));
        expect(updated.queryParameters['active'], equals('true'));
      });

      test(
        'should handle iterable values (lists) for duplicate query keys',
        () {
          final uri = Uri.parse('https://example.com/posts');
          final updated = uri.addQueryParams({
            'tags': ['dart', 'flutter'],
          });
          expect(
            updated.queryParametersAll['tags'],
            equals(['dart', 'flutter']),
          );
        },
      );

      test('should override existing query param values with new values', () {
        final uri = Uri.parse('https://example.com/posts?tags=old');
        final updated = uri.addQueryParams({
          'tags': ['dart', 'flutter'],
        });
        expect(updated.queryParametersAll['tags'], equals(['dart', 'flutter']));
      });
    });

    group('removeQueryParams', () {
      test('should remove specified query params', () {
        final uri = Uri.parse(
          'https://example.com?id=123&token=abc&role=admin',
        );
        final updated = uri.removeQueryParams(['token', 'role']);
        expect(updated.queryParameters['id'], equals('123'));
        expect(updated.queryParameters.containsKey('token'), isFalse);
        expect(updated.queryParameters.containsKey('role'), isFalse);
      });
    });
  });
}
