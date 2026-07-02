/// Fluent HTTP request helpers built on top of `package:http`.
///
/// Use [Http] for small application calls that need headers, JSON bodies,
/// timeouts, retry policy, and explicit [Result] based error handling.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../async/retry.dart';
import '../functional/result.dart';

/// Result type returned by [HttpRequestBuilder.execute].
typedef HttpResult = Result<http.Response, HttpError>;

/// Selects which HTTP status codes count as successful.
typedef HttpStatusPredicate = bool Function(int statusCode);

/// Selects which HTTP errors should be retried.
typedef HttpRetryPredicate = bool Function(HttpError error);

/// Static entrypoint for fluent HTTP requests.
///
/// Example:
/// ```dart
/// final response = await Http.get('https://api.example.com/users')
///     .withHeaders({'Authorization': 'Bearer token'})
///     .withTimeout(Duration(seconds: 5))
///     .withRetry(3, backoff: BackoffStrategy.exponential)
///     .execute();
/// ```
final class Http {
  const Http._();

  /// Creates a request with an arbitrary HTTP [method].
  static HttpRequestBuilder request(
    String method,
    Object url, {
    http.Client? client,
  }) {
    return HttpRequestBuilder._(
      method: method.toUpperCase(),
      uri: _parseUri(url),
      headers: const {},
      client: client,
      statusPredicate: _isSuccessStatus,
    );
  }

  /// Creates a GET request.
  static HttpRequestBuilder get(Object url, {http.Client? client}) {
    return request('GET', url, client: client);
  }

  /// Creates a POST request.
  static HttpRequestBuilder post(Object url, {http.Client? client}) {
    return request('POST', url, client: client);
  }

  /// Creates a PUT request.
  static HttpRequestBuilder put(Object url, {http.Client? client}) {
    return request('PUT', url, client: client);
  }

  /// Creates a PATCH request.
  static HttpRequestBuilder patch(Object url, {http.Client? client}) {
    return request('PATCH', url, client: client);
  }

  /// Creates a DELETE request.
  static HttpRequestBuilder delete(Object url, {http.Client? client}) {
    return request('DELETE', url, client: client);
  }

  /// Creates a HEAD request.
  static HttpRequestBuilder head(Object url, {http.Client? client}) {
    return request('HEAD', url, client: client);
  }
}

/// Immutable fluent HTTP request builder.
final class HttpRequestBuilder {
  const HttpRequestBuilder._({
    required this.method,
    required this.uri,
    required this.headers,
    required this.statusPredicate,
    this.client,
    this._body,
    this.timeout,
    this._retryPolicy,
  });

  /// HTTP method used by the request.
  final String method;

  /// Target URI.
  final Uri uri;

  /// Request headers.
  final Map<String, String> headers;

  /// Optional HTTP client. When omitted, [execute] creates and closes one.
  final http.Client? client;

  /// Optional request body.
  final _HttpBody? _body;

  /// Optional request timeout.
  final Duration? timeout;

  /// Optional retry policy.
  final _HttpRetryPolicy? _retryPolicy;

  /// Predicate used to classify response status codes as successful.
  final HttpStatusPredicate statusPredicate;

  /// Returns a copy with [headers] merged into existing headers.
  HttpRequestBuilder withHeaders(Map<String, String> headers) {
    return _copyWith(headers: {...this.headers, ...headers});
  }

  /// Returns a copy with a string or byte [body].
  ///
  /// [String] values are encoded with [encoding]. `List<int>` values are sent
  /// as bytes. Other objects are converted with `toString()`.
  HttpRequestBuilder withBody(Object body, {Encoding encoding = utf8}) {
    final httpBody = switch (body) {
      final List<int> bytes => _HttpBody.bytes(List<int>.unmodifiable(bytes)),
      final String text => _HttpBody.text(text, encoding),
      _ => _HttpBody.text(body.toString(), encoding),
    };
    return _copyWith(body: httpBody);
  }

  /// Returns a copy with a JSON-encoded request [body].
  HttpRequestBuilder withJsonBody(
    Object? body, {
    Object? Function(Object? object)? toEncodable,
  }) {
    final nextHeaders = {...headers};
    nextHeaders.putIfAbsent(
      'content-type',
      () => 'application/json; charset=utf-8',
    );
    return _copyWith(
      headers: nextHeaders,
      body: _HttpBody.text(jsonEncode(body, toEncodable: toEncodable), utf8),
    );
  }

  /// Returns a copy with [timeout] applied to the request.
  HttpRequestBuilder withTimeout(Duration timeout) {
    if (timeout <= Duration.zero) {
      throw ArgumentError.value(timeout, 'timeout', 'Must be positive.');
    }
    return _copyWith(timeout: timeout);
  }

  /// Returns a copy with retry behavior.
  ///
  /// By default, retry is attempted for timeouts, transport exceptions, and
  /// 5xx status responses.
  HttpRequestBuilder withRetry(
    int maxAttempts, {
    Duration delay = const Duration(milliseconds: 100),
    BackoffStrategy backoff = BackoffStrategy.constant,
    double jitter = 0,
    HttpRetryPredicate? retryIf,
  }) {
    if (maxAttempts <= 0) {
      throw ArgumentError.value(
        maxAttempts,
        'maxAttempts',
        'Must be positive.',
      );
    }
    if (delay.isNegative) {
      throw ArgumentError.value(delay, 'delay', 'Must not be negative.');
    }
    if (jitter < 0 || jitter > 1) {
      throw ArgumentError.value(jitter, 'jitter', 'Must be between 0 and 1.');
    }

    return _copyWith(
      retryPolicy: _HttpRetryPolicy(
        maxAttempts: maxAttempts,
        delay: delay,
        backoff: backoff,
        jitter: jitter,
        retryIf: retryIf,
      ),
    );
  }

  /// Returns a copy using [predicate] to classify successful status codes.
  HttpRequestBuilder acceptStatus(HttpStatusPredicate predicate) {
    return _copyWith(statusPredicate: predicate);
  }

  /// Returns a copy that treats any HTTP status code as successful.
  HttpRequestBuilder acceptAnyStatus() {
    return acceptStatus((_) => true);
  }

  /// Sends the request and returns either an HTTP response or [HttpError].
  Future<HttpResult> execute() async {
    final policy = _retryPolicy ?? const _HttpRetryPolicy(maxAttempts: 1);
    final rng = math.Random();

    for (var attempt = 1; attempt <= policy.maxAttempts; attempt++) {
      final ownsClient = client == null;
      final activeClient = client ?? http.Client();

      try {
        final response = await _sendOnce(activeClient);
        if (statusPredicate(response.statusCode)) {
          return Result<http.Response, HttpError>.success(response);
        }

        final error = HttpStatusError(
          method: method,
          uri: uri,
          response: response,
        );
        if (!_shouldRetry(policy, error, attempt)) {
          return Result<http.Response, HttpError>.failure(error);
        }
        await _waitBeforeRetry(policy, attempt, rng);
      } on TimeoutException catch (error, stackTrace) {
        final failure = HttpTimeoutError(
          method: method,
          uri: uri,
          timeout: timeout,
          cause: error,
          stackTrace: stackTrace,
        );
        if (!_shouldRetry(policy, failure, attempt)) {
          return Result<http.Response, HttpError>.failure(failure);
        }
        await _waitBeforeRetry(policy, attempt, rng);
      } on http.ClientException catch (error, stackTrace) {
        final failure = HttpTransportError(
          method: method,
          uri: uri,
          cause: error,
          stackTrace: stackTrace,
        );
        if (!_shouldRetry(policy, failure, attempt)) {
          return Result<http.Response, HttpError>.failure(failure);
        }
        await _waitBeforeRetry(policy, attempt, rng);
      } catch (error, stackTrace) {
        final failure = HttpTransportError(
          method: method,
          uri: uri,
          cause: error,
          stackTrace: stackTrace,
        );
        if (!_shouldRetry(policy, failure, attempt)) {
          return Result<http.Response, HttpError>.failure(failure);
        }
        await _waitBeforeRetry(policy, attempt, rng);
      } finally {
        if (ownsClient) {
          activeClient.close();
        }
      }
    }

    throw StateError('Unreachable HTTP retry state.');
  }

  Future<http.Response> _sendOnce(http.Client activeClient) {
    final request = http.Request(method, uri)..headers.addAll(headers);
    _body?.applyTo(request);

    final future = activeClient.send(request).then(http.Response.fromStream);
    final requestTimeout = timeout;
    if (requestTimeout == null) return future;
    return future.timeout(requestTimeout);
  }

  HttpRequestBuilder _copyWith({
    Map<String, String>? headers,
    _HttpBody? body,
    Duration? timeout,
    _HttpRetryPolicy? retryPolicy,
    HttpStatusPredicate? statusPredicate,
  }) {
    return HttpRequestBuilder._(
      method: method,
      uri: uri,
      headers: Map<String, String>.unmodifiable(headers ?? this.headers),
      client: client,
      body: body ?? _body,
      timeout: timeout ?? this.timeout,
      retryPolicy: retryPolicy ?? _retryPolicy,
      statusPredicate: statusPredicate ?? this.statusPredicate,
    );
  }
}

/// Base type for HTTP request failures.
sealed class HttpError {
  /// Creates an HTTP error.
  const HttpError({
    required this.method,
    required this.uri,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// Request method.
  final String method;

  /// Request URI.
  final Uri uri;

  /// Human-readable message.
  final String message;

  /// Original exception or failure cause, when available.
  final Object? cause;

  /// Stack trace for thrown failures, when available.
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

/// Failure caused by an unacceptable HTTP status code.
final class HttpStatusError extends HttpError {
  /// Creates an HTTP status error.
  HttpStatusError({
    required super.method,
    required super.uri,
    required this.response,
  }) : super(message: '$method $uri returned HTTP ${response.statusCode}.');

  /// HTTP response that failed status validation.
  final http.Response response;

  /// Failed status code.
  int get statusCode => response.statusCode;
}

/// Failure caused by a request timeout.
final class HttpTimeoutError extends HttpError {
  /// Creates an HTTP timeout error.
  HttpTimeoutError({
    required super.method,
    required super.uri,
    required this.timeout,
    super.cause,
    super.stackTrace,
  }) : super(message: '$method $uri timed out after $timeout.');

  /// Timeout that was applied to the request.
  final Duration? timeout;
}

/// Failure caused by request transport or response decoding exceptions.
final class HttpTransportError extends HttpError {
  /// Creates an HTTP transport error.
  HttpTransportError({
    required super.method,
    required super.uri,
    super.cause,
    super.stackTrace,
  }) : super(message: '$method $uri failed: $cause.');
}

final class _HttpBody {
  const _HttpBody._({this.text, this.bytes, this.encoding = utf8});

  factory _HttpBody.text(String text, Encoding encoding) {
    return _HttpBody._(text: text, encoding: encoding);
  }

  factory _HttpBody.bytes(List<int> bytes) {
    return _HttpBody._(bytes: bytes);
  }

  final String? text;
  final List<int>? bytes;
  final Encoding encoding;

  void applyTo(http.Request request) {
    final bodyBytes = bytes;
    if (bodyBytes != null) {
      request.bodyBytes = bodyBytes;
      return;
    }

    final bodyText = text;
    if (bodyText != null) {
      request.encoding = encoding;
      request.body = bodyText;
    }
  }
}

final class _HttpRetryPolicy {
  const _HttpRetryPolicy({
    required this.maxAttempts,
    this.delay = Duration.zero,
    this.backoff = BackoffStrategy.constant,
    this.jitter = 0,
    this.retryIf,
  });

  final int maxAttempts;
  final Duration delay;
  final BackoffStrategy backoff;
  final double jitter;
  final HttpRetryPredicate? retryIf;
}

Uri _parseUri(Object url) {
  return switch (url) {
    final Uri uri => uri,
    final String value => Uri.parse(value),
    _ => throw ArgumentError.value(url, 'url', 'Must be a Uri or String.'),
  };
}

bool _isSuccessStatus(int statusCode) {
  return statusCode >= 200 && statusCode < 300;
}

bool _shouldRetry(_HttpRetryPolicy policy, HttpError error, int attempt) {
  if (attempt >= policy.maxAttempts) return false;
  return policy.retryIf?.call(error) ?? _defaultRetryIf(error);
}

bool _defaultRetryIf(HttpError error) {
  return switch (error) {
    HttpStatusError(:final statusCode) => statusCode >= 500,
    HttpTimeoutError() => true,
    HttpTransportError() => true,
  };
}

Future<void> _waitBeforeRetry(
  _HttpRetryPolicy policy,
  int failedAttempt,
  math.Random random,
) async {
  final delay = _delayForAttempt(policy, failedAttempt, random);
  if (delay > Duration.zero) {
    await Future<void>.delayed(delay);
  }
}

Duration _delayForAttempt(
  _HttpRetryPolicy policy,
  int failedAttempt,
  math.Random random,
) {
  final multiplier = switch (policy.backoff) {
    BackoffStrategy.constant => 1,
    BackoffStrategy.linear => failedAttempt,
    BackoffStrategy.exponential => math.pow(2, failedAttempt - 1).toInt(),
  };

  final baseMicros = policy.delay.inMicroseconds * multiplier;
  if (policy.jitter == 0 || baseMicros == 0) {
    return Duration(microseconds: baseMicros);
  }

  final jitterRange = (baseMicros * policy.jitter).round();
  final adjustment = random.nextInt(jitterRange * 2 + 1) - jitterRange;
  final jitteredMicros = math.max(0, baseMicros + adjustment);
  return Duration(microseconds: jitteredMicros);
}
