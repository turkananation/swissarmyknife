import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('ApiClientBuilder', () {
    test(
      'should resolve paths, merge headers, and encode query values',
      () async {
        late http.Request capturedRequest;
        final client = MockClient((request) async {
          capturedRequest = request;
          return http.Response('ok', 200, request: request);
        });

        final api = ApiClientBuilder('https://example.com/v1')
            .withClient(client)
            .withHeader('x-static', 'static')
            .withHeaderProvider(() async => {'x-dynamic': 'dynamic'})
            .build();

        final result = await api.get(
          'users',
          query: {
            'page': 2,
            'tags': ['dart', 'utils'],
            'skip': null,
          },
          headers: {'x-request': 'request'},
        );

        expect(result.isSuccess, isTrue);
        expect(capturedRequest.method, equals('GET'));
        expect(
          capturedRequest.url,
          equals(
            Uri.parse(
              'https://example.com/v1/users?page=2&tags=dart&tags=utils',
            ),
          ),
        );
        expect(capturedRequest.headers['x-static'], equals('static'));
        expect(capturedRequest.headers['x-dynamic'], equals('dynamic'));
        expect(capturedRequest.headers['x-request'], equals('request'));
      },
    );

    test('should send JSON bodies and decode JSON responses', () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'id': 7, 'name': 'Ada'}),
          201,
          request: request,
        );
      });

      final api = ApiClientBuilder(
        Uri.parse('https://example.com/api/'),
      ).withClient(client).withBearerToken('token').build();

      final result = await api.postJson<String>(
        'users',
        body: {'name': 'Ada'},
        decode: (json) => (json as Map<String, dynamic>)['name'] as String,
      );

      expect(result.valueOrNull, equals('Ada'));
      expect(capturedRequest.method, equals('POST'));
      expect(capturedRequest.headers['Authorization'], equals('Bearer token'));
      expect(
        capturedRequest.headers['content-type'],
        equals('application/json; charset=utf-8'),
      );
      expect(jsonDecode(capturedRequest.body), equals({'name': 'Ada'}));
    });

    test('should support typed endpoints', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'id': 7, 'name': 'Ada'}),
          200,
          request: request,
        );
      });

      final api = ApiClientBuilder(
        'https://example.com',
      ).withClient(client).build();
      final users = api.endpoint<String>(
        '/users/7',
        decode: (json) => (json as Map<String, dynamic>)['name'] as String,
      );

      final result = await users.get();

      expect(result.valueOrNull, equals('Ada'));
    });

    test('should expose HTTP errors as API HTTP errors', () async {
      final client = MockClient((request) async {
        return http.Response('missing', 404, request: request);
      });
      final api = ApiClientBuilder(
        'https://example.com',
      ).withClient(client).build();

      final result = await api.get('/missing');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ApiHttpError>());
      final error = result.errorOrNull as ApiHttpError;
      expect(error.error, isA<HttpStatusError>());
      expect((error.error as HttpStatusError).statusCode, equals(404));
    });

    test('should expose decode failures as API decode errors', () async {
      final client = MockClient((request) async {
        return http.Response('not json', 200, request: request);
      });
      final api = ApiClientBuilder(
        'https://example.com',
      ).withClient(client).build();

      final result = await api.getJson<Map<String, dynamic>>('/bad');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ApiDecodeError>());
      expect((result.errorOrNull as ApiDecodeError).response.body, 'not json');
    });

    test(
      'should apply retry policy through the underlying HTTP helper',
      () async {
        var attempts = 0;
        final client = MockClient((request) async {
          attempts++;
          if (attempts == 1) {
            return http.Response('try again', 503, request: request);
          }
          return http.Response('ok', 200, request: request);
        });

        final api = ApiClientBuilder(
          'https://example.com',
        ).withClient(client).withRetry(2, delay: Duration.zero).build();

        final result = await api.get('/flaky');

        expect(result.valueOrNull?.body, equals('ok'));
        expect(attempts, equals(2));
      },
    );

    test('should validate builder configuration', () {
      expect(() => ApiClientBuilder('/relative'), throwsArgumentError);
      expect(
        () =>
            ApiClientBuilder('https://example.com').withTimeout(Duration.zero),
        throwsArgumentError,
      );
      expect(
        () => ApiClientBuilder('https://example.com').withRetry(0),
        throwsArgumentError,
      );
      expect(
        () => ApiClientBuilder('https://example.com').withRetry(1, jitter: 1.1),
        throwsArgumentError,
      );
    });

    test('should create basic auth headers', () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response('ok', 200, request: request);
      });
      final api = ApiClientBuilder(
        'https://example.com',
      ).withClient(client).withBasicAuth('ada', 'secret').build();

      await api.get('/secure');

      expect(
        capturedRequest.headers['Authorization'],
        equals('Basic ${base64Encode(utf8.encode('ada:secret'))}'),
      );
    });
  });
}
