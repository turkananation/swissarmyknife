import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Http', () {
    test('should send GET requests with headers', () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response('ok', 200);
      });

      final result = await Http.get(
        'https://example.com/users',
        client: client,
      ).withHeaders({'Authorization': 'Bearer token'}).execute();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.body, equals('ok'));
      expect(capturedRequest.method, equals('GET'));
      expect(
        capturedRequest.url,
        equals(Uri.parse('https://example.com/users')),
      );
      expect(capturedRequest.headers['Authorization'], equals('Bearer token'));
    });

    test('should send JSON bodies', () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response('created', 201);
      });

      final result = await Http.post(
        Uri.parse('https://example.com/users'),
        client: client,
      ).withJsonBody({'name': 'Ada'}).execute();

      expect(result.isSuccess, isTrue);
      expect(capturedRequest.method, equals('POST'));
      expect(
        capturedRequest.headers['content-type'],
        equals('application/json; charset=utf-8'),
      );
      expect(jsonDecode(capturedRequest.body), equals({'name': 'Ada'}));
    });

    test('should fail on non-success status by default', () async {
      final client = MockClient((_) async => http.Response('missing', 404));

      final result = await Http.get(
        'https://example.com/missing',
        client: client,
      ).execute();

      expect(result.isFailure, isTrue);
      final error = result.errorOrNull;
      expect(error, isA<HttpStatusError>());
      expect((error as HttpStatusError).statusCode, equals(404));
      expect(error.response.body, equals('missing'));
    });

    test('should allow custom successful status predicates', () async {
      final client = MockClient((_) async => http.Response('accepted', 404));

      final result = await Http.get(
        'https://example.com/missing',
        client: client,
      ).acceptStatus((status) => status == 404).execute();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.body, equals('accepted'));
    });

    test('should timeout requests', () async {
      final client = MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return http.Response('late', 200);
      });

      final result = await Http.get(
        'https://example.com/slow',
        client: client,
      ).withTimeout(const Duration(milliseconds: 1)).execute();

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<HttpTimeoutError>());
    });

    test('should retry transient status responses', () async {
      var attempts = 0;
      final client = MockClient((_) async {
        attempts++;
        if (attempts < 3) {
          return http.Response('try again', 503);
        }
        return http.Response('ok', 200);
      });

      final result = await Http.get(
        'https://example.com/flaky',
        client: client,
      ).withRetry(3, delay: Duration.zero).execute();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.body, equals('ok'));
      expect(attempts, equals(3));
    });

    test('should retry transport exceptions when allowed', () async {
      var attempts = 0;
      final client = MockClient((request) async {
        attempts++;
        if (attempts == 1) {
          throw http.ClientException('offline', request.url);
        }
        return http.Response('ok', 200);
      });

      final result = await Http.get(
        'https://example.com/flaky',
        client: client,
      ).withRetry(2, delay: Duration.zero).execute();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.body, equals('ok'));
      expect(attempts, equals(2));
    });

    test('should expose final transport failure', () async {
      final client = MockClient((request) async {
        throw http.ClientException('offline', request.url);
      });

      final result = await Http.get(
        'https://example.com/offline',
        client: client,
      ).withRetry(2, delay: Duration.zero).execute();

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<HttpTransportError>());
      expect(result.errorOrNull?.cause, isA<http.ClientException>());
    });

    test('should validate timeout and retry configuration', () {
      expect(
        () => Http.get('https://example.com').withTimeout(Duration.zero),
        throwsArgumentError,
      );
      expect(
        () => Http.get('https://example.com').withRetry(0),
        throwsArgumentError,
      );
      expect(
        () => Http.get('https://example.com').withRetry(1, jitter: 1.1),
        throwsArgumentError,
      );
    });
  });
}
