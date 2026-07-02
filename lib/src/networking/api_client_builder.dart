/// Small API client builder on top of the package HTTP helpers.
///
/// Use [ApiClientBuilder] when repeated requests share a base URL, headers,
/// timeout/retry policy, and typed JSON decoding behavior.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../async/retry.dart';
import '../functional/result.dart';
import 'http_client.dart';

/// Result type returned by API client requests.
typedef ApiResult<T> = Result<T, ApiClientError>;

/// Provides headers at request time.
typedef ApiHeaderProvider = FutureOr<Map<String, String>> Function();

/// Decodes a JSON-compatible value into [T].
typedef ApiJsonDecoder<T> = T Function(Object? json);

/// API client request failure.
sealed class ApiClientError {
  /// Creates an API client error.
  const ApiClientError({
    required this.method,
    required this.uri,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// HTTP method.
  final String method;

  /// Request URI.
  final Uri uri;

  /// Human-readable message.
  final String message;

  /// Original cause, when available.
  final Object? cause;

  /// Original stack trace, when available.
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

/// Failure before a request could be sent.
final class ApiRequestError extends ApiClientError {
  /// Creates an API request setup error.
  const ApiRequestError({
    required super.method,
    required super.uri,
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Failure returned by the underlying HTTP helper.
final class ApiHttpError extends ApiClientError {
  /// Creates an API HTTP error.
  ApiHttpError(this.error)
    : super(
        method: error.method,
        uri: error.uri,
        message: error.message,
        cause: error.cause,
        stackTrace: error.stackTrace,
      );

  /// Underlying HTTP error.
  final HttpError error;
}

/// Failure while decoding a successful HTTP response.
final class ApiDecodeError extends ApiClientError {
  /// Creates an API decode error.
  ApiDecodeError({
    required super.method,
    required super.uri,
    required this.response,
    required Object super.cause,
    super.stackTrace,
  }) : super(message: '$method $uri response could not be decoded: $cause.');

  /// Response that failed decoding.
  final http.Response response;
}

/// Immutable builder for [ApiClient].
final class ApiClientBuilder {
  /// Creates an API client builder with [baseUrl].
  ApiClientBuilder(Object baseUrl)
    : this._(
        baseUri: _normalizeBaseUri(baseUrl),
        headers: const {},
        headerProviders: const [],
      );

  const ApiClientBuilder._({
    required this.baseUri,
    required this.headers,
    required this.headerProviders,
    this.client,
    this.timeout,
    this._retryPolicy,
    this.statusPredicate,
  });

  /// Base URI used to resolve relative request paths.
  final Uri baseUri;

  /// Static headers included in every request.
  final Map<String, String> headers;

  /// Dynamic header providers evaluated for every request.
  final List<ApiHeaderProvider> headerProviders;

  /// Optional shared HTTP client.
  final http.Client? client;

  /// Optional request timeout.
  final Duration? timeout;

  final _ApiRetryPolicy? _retryPolicy;

  /// Optional status predicate.
  final HttpStatusPredicate? statusPredicate;

  /// Returns a copy with [client].
  ApiClientBuilder withClient(http.Client client) => _copyWith(client: client);

  /// Returns a copy with [name] set to [value].
  ApiClientBuilder withHeader(String name, String value) {
    return withHeaders({name: value});
  }

  /// Returns a copy with [headers] merged into existing static headers.
  ApiClientBuilder withHeaders(Map<String, String> headers) {
    return _copyWith(headers: {...this.headers, ...headers});
  }

  /// Returns a copy with a bearer authorization header.
  ApiClientBuilder withBearerToken(String token) {
    return withHeader('Authorization', 'Bearer $token');
  }

  /// Returns a copy with an HTTP Basic authorization header.
  ApiClientBuilder withBasicAuth(String username, String password) {
    final credentials = base64Encode(utf8.encode('$username:$password'));
    return withHeader('Authorization', 'Basic $credentials');
  }

  /// Returns a copy with a user-agent header.
  ApiClientBuilder withUserAgent(String value) {
    return withHeader('User-Agent', value);
  }

  /// Returns a copy with [provider] appended to the dynamic header providers.
  ApiClientBuilder withHeaderProvider(ApiHeaderProvider provider) {
    return _copyWith(headerProviders: [...headerProviders, provider]);
  }

  /// Returns a copy with [timeout].
  ApiClientBuilder withTimeout(Duration timeout) {
    if (timeout <= Duration.zero) {
      throw ArgumentError.value(timeout, 'timeout', 'Must be positive.');
    }
    return _copyWith(timeout: timeout);
  }

  /// Returns a copy with retry behavior.
  ApiClientBuilder withRetry(
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
      retryPolicy: _ApiRetryPolicy(
        maxAttempts: maxAttempts,
        delay: delay,
        backoff: backoff,
        jitter: jitter,
        retryIf: retryIf,
      ),
    );
  }

  /// Returns a copy using [predicate] to classify successful status codes.
  ApiClientBuilder acceptStatus(HttpStatusPredicate predicate) {
    return _copyWith(statusPredicate: predicate);
  }

  /// Returns a copy that treats any status code as successful.
  ApiClientBuilder acceptAnyStatus() => acceptStatus((_) => true);

  /// Builds the API client.
  ApiClient build() {
    return ApiClient._(
      baseUri: baseUri,
      headers: Map<String, String>.unmodifiable(headers),
      headerProviders: List<ApiHeaderProvider>.unmodifiable(headerProviders),
      client: client,
      timeout: timeout,
      retryPolicy: _retryPolicy,
      statusPredicate: statusPredicate,
    );
  }

  ApiClientBuilder _copyWith({
    Uri? baseUri,
    Map<String, String>? headers,
    List<ApiHeaderProvider>? headerProviders,
    http.Client? client,
    Duration? timeout,
    _ApiRetryPolicy? retryPolicy,
    HttpStatusPredicate? statusPredicate,
  }) {
    return ApiClientBuilder._(
      baseUri: baseUri ?? this.baseUri,
      headers: Map<String, String>.unmodifiable(headers ?? this.headers),
      headerProviders: List<ApiHeaderProvider>.unmodifiable(
        headerProviders ?? this.headerProviders,
      ),
      client: client ?? this.client,
      timeout: timeout ?? this.timeout,
      retryPolicy: retryPolicy ?? _retryPolicy,
      statusPredicate: statusPredicate ?? this.statusPredicate,
    );
  }
}

/// Configured API client.
final class ApiClient {
  const ApiClient._({
    required this.baseUri,
    required this.headers,
    required this.headerProviders,
    this.client,
    this.timeout,
    this._retryPolicy,
    this.statusPredicate,
  });

  /// Base URI used to resolve relative request paths.
  final Uri baseUri;

  /// Static request headers.
  final Map<String, String> headers;

  /// Dynamic request header providers.
  final List<ApiHeaderProvider> headerProviders;

  /// Optional shared HTTP client.
  final http.Client? client;

  /// Optional request timeout.
  final Duration? timeout;

  final _ApiRetryPolicy? _retryPolicy;

  /// Optional status predicate.
  final HttpStatusPredicate? statusPredicate;

  /// Resolves [path] against [baseUri] and merges [query] parameters.
  Uri resolve(Object path, {Map<String, Object?>? query}) {
    final uri = _parseRequestUri(path);
    final resolved = uri.hasScheme ? uri : baseUri.resolveUri(uri);
    return _mergeQuery(resolved, query);
  }

  /// Creates a typed endpoint rooted at [path].
  ApiEndpoint<T> endpoint<T>(Object path, {ApiJsonDecoder<T>? decode}) {
    return ApiEndpoint<T>._(this, path, decode);
  }

  /// Sends a request and returns the raw HTTP response.
  Future<ApiResult<http.Response>> send(
    String method,
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    bool jsonBody = false,
    HttpStatusPredicate? acceptStatus,
  }) async {
    final normalizedMethod = method.toUpperCase();
    late final Uri uri;
    late final Map<String, String> requestHeaders;

    try {
      uri = resolve(path, query: query);
      requestHeaders = await _resolveHeaders(headers);
    } catch (error, stackTrace) {
      return Result<http.Response, ApiClientError>.failure(
        ApiRequestError(
          method: normalizedMethod,
          uri: baseUri,
          message: '$normalizedMethod $baseUri could not be prepared: $error.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }

    var request = Http.request(
      normalizedMethod,
      uri,
      client: client,
    ).withHeaders(requestHeaders);

    if (jsonBody) {
      request = request.withJsonBody(body);
    } else if (body != null) {
      request = request.withBody(body);
    }

    final requestTimeout = timeout;
    if (requestTimeout != null) {
      request = request.withTimeout(requestTimeout);
    }

    final policy = _retryPolicy;
    if (policy != null) {
      request = request.withRetry(
        policy.maxAttempts,
        delay: policy.delay,
        backoff: policy.backoff,
        jitter: policy.jitter,
        retryIf: policy.retryIf,
      );
    }

    final status = acceptStatus ?? statusPredicate;
    if (status != null) {
      request = request.acceptStatus(status);
    }

    final result = await request.execute();
    return switch (result) {
      Success<http.Response, HttpError>(:final value) =>
        Result<http.Response, ApiClientError>.success(value),
      Failure<http.Response, HttpError>(:final error) =>
        Result<http.Response, ApiClientError>.failure(ApiHttpError(error)),
    };
  }

  /// Sends a request and returns the response body.
  Future<ApiResult<String>> sendText(
    String method,
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    bool jsonBody = false,
    HttpStatusPredicate? acceptStatus,
  }) async {
    final result = await send(
      method,
      path,
      query: query,
      headers: headers,
      body: body,
      jsonBody: jsonBody,
      acceptStatus: acceptStatus,
    );
    return switch (result) {
      Success<http.Response, ApiClientError>(:final value) =>
        Result<String, ApiClientError>.success(value.body),
      Failure<http.Response, ApiClientError>(:final error) =>
        Result<String, ApiClientError>.failure(error),
    };
  }

  /// Sends a request and decodes the response body as JSON.
  Future<ApiResult<T>> sendJson<T>(
    String method,
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    bool jsonBody = false,
    HttpStatusPredicate? acceptStatus,
    ApiJsonDecoder<T>? decode,
  }) async {
    final result = await send(
      method,
      path,
      query: query,
      headers: headers,
      body: body,
      jsonBody: jsonBody,
      acceptStatus: acceptStatus,
    );

    return switch (result) {
      Success<http.Response, ApiClientError>(:final value) => _decodeJson<T>(
        method.toUpperCase(),
        value.request?.url ?? resolve(path, query: query),
        value,
        decode,
      ),
      Failure<http.Response, ApiClientError>(:final error) =>
        Result<T, ApiClientError>.failure(error),
    };
  }

  /// Sends a GET request.
  Future<ApiResult<http.Response>> get(
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    HttpStatusPredicate? acceptStatus,
  }) {
    return send(
      'GET',
      path,
      query: query,
      headers: headers,
      acceptStatus: acceptStatus,
    );
  }

  /// Sends a POST request.
  Future<ApiResult<http.Response>> post(
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    bool jsonBody = false,
    HttpStatusPredicate? acceptStatus,
  }) {
    return send(
      'POST',
      path,
      query: query,
      headers: headers,
      body: body,
      jsonBody: jsonBody,
      acceptStatus: acceptStatus,
    );
  }

  /// Sends a PUT request.
  Future<ApiResult<http.Response>> put(
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    bool jsonBody = false,
    HttpStatusPredicate? acceptStatus,
  }) {
    return send(
      'PUT',
      path,
      query: query,
      headers: headers,
      body: body,
      jsonBody: jsonBody,
      acceptStatus: acceptStatus,
    );
  }

  /// Sends a PATCH request.
  Future<ApiResult<http.Response>> patch(
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    bool jsonBody = false,
    HttpStatusPredicate? acceptStatus,
  }) {
    return send(
      'PATCH',
      path,
      query: query,
      headers: headers,
      body: body,
      jsonBody: jsonBody,
      acceptStatus: acceptStatus,
    );
  }

  /// Sends a DELETE request.
  Future<ApiResult<http.Response>> delete(
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    bool jsonBody = false,
    HttpStatusPredicate? acceptStatus,
  }) {
    return send(
      'DELETE',
      path,
      query: query,
      headers: headers,
      body: body,
      jsonBody: jsonBody,
      acceptStatus: acceptStatus,
    );
  }

  /// Sends a HEAD request.
  Future<ApiResult<http.Response>> head(
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    HttpStatusPredicate? acceptStatus,
  }) {
    return send(
      'HEAD',
      path,
      query: query,
      headers: headers,
      acceptStatus: acceptStatus,
    );
  }

  /// Sends a GET request and decodes JSON.
  Future<ApiResult<T>> getJson<T>(
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    HttpStatusPredicate? acceptStatus,
    ApiJsonDecoder<T>? decode,
  }) {
    return sendJson<T>(
      'GET',
      path,
      query: query,
      headers: headers,
      acceptStatus: acceptStatus,
      decode: decode,
    );
  }

  /// Sends a POST request with a JSON body and decodes JSON.
  Future<ApiResult<T>> postJson<T>(
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    HttpStatusPredicate? acceptStatus,
    ApiJsonDecoder<T>? decode,
  }) {
    return sendJson<T>(
      'POST',
      path,
      query: query,
      headers: headers,
      body: body,
      jsonBody: true,
      acceptStatus: acceptStatus,
      decode: decode,
    );
  }

  /// Sends a PUT request with a JSON body and decodes JSON.
  Future<ApiResult<T>> putJson<T>(
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    HttpStatusPredicate? acceptStatus,
    ApiJsonDecoder<T>? decode,
  }) {
    return sendJson<T>(
      'PUT',
      path,
      query: query,
      headers: headers,
      body: body,
      jsonBody: true,
      acceptStatus: acceptStatus,
      decode: decode,
    );
  }

  /// Sends a PATCH request with a JSON body and decodes JSON.
  Future<ApiResult<T>> patchJson<T>(
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    HttpStatusPredicate? acceptStatus,
    ApiJsonDecoder<T>? decode,
  }) {
    return sendJson<T>(
      'PATCH',
      path,
      query: query,
      headers: headers,
      body: body,
      jsonBody: true,
      acceptStatus: acceptStatus,
      decode: decode,
    );
  }

  /// Sends a DELETE request with an optional JSON body and decodes JSON.
  Future<ApiResult<T>> deleteJson<T>(
    Object path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    HttpStatusPredicate? acceptStatus,
    ApiJsonDecoder<T>? decode,
  }) {
    return sendJson<T>(
      'DELETE',
      path,
      query: query,
      headers: headers,
      body: body,
      jsonBody: true,
      acceptStatus: acceptStatus,
      decode: decode,
    );
  }

  Future<Map<String, String>> _resolveHeaders(
    Map<String, String>? requestHeaders,
  ) async {
    final resolved = <String, String>{...headers};
    for (final provider in headerProviders) {
      resolved.addAll(await provider());
    }
    resolved.addAll(requestHeaders ?? const {});
    return resolved;
  }

  ApiResult<T> _decodeJson<T>(
    String method,
    Uri uri,
    http.Response response,
    ApiJsonDecoder<T>? decode,
  ) {
    try {
      final json = response.body.isEmpty ? null : jsonDecode(response.body);
      final value = decode == null ? json as T : decode(json);
      return Result<T, ApiClientError>.success(value);
    } catch (error, stackTrace) {
      return Result<T, ApiClientError>.failure(
        ApiDecodeError(
          method: method,
          uri: uri,
          response: response,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

/// Typed API endpoint rooted at a fixed path.
final class ApiEndpoint<T> {
  const ApiEndpoint._(this._client, this.path, this._decode);

  final ApiClient _client;

  /// Endpoint path.
  final Object path;

  final ApiJsonDecoder<T>? _decode;

  /// Sends a GET request and decodes JSON.
  Future<ApiResult<T>> get({
    Map<String, Object?>? query,
    Map<String, String>? headers,
    HttpStatusPredicate? acceptStatus,
  }) {
    return _client.getJson<T>(
      path,
      query: query,
      headers: headers,
      acceptStatus: acceptStatus,
      decode: _decode,
    );
  }

  /// Sends a POST request with a JSON body and decodes JSON.
  Future<ApiResult<T>> post({
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    HttpStatusPredicate? acceptStatus,
  }) {
    return _client.postJson<T>(
      path,
      query: query,
      headers: headers,
      body: body,
      acceptStatus: acceptStatus,
      decode: _decode,
    );
  }

  /// Sends a PUT request with a JSON body and decodes JSON.
  Future<ApiResult<T>> put({
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    HttpStatusPredicate? acceptStatus,
  }) {
    return _client.putJson<T>(
      path,
      query: query,
      headers: headers,
      body: body,
      acceptStatus: acceptStatus,
      decode: _decode,
    );
  }

  /// Sends a PATCH request with a JSON body and decodes JSON.
  Future<ApiResult<T>> patch({
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    HttpStatusPredicate? acceptStatus,
  }) {
    return _client.patchJson<T>(
      path,
      query: query,
      headers: headers,
      body: body,
      acceptStatus: acceptStatus,
      decode: _decode,
    );
  }

  /// Sends a DELETE request with an optional JSON body and decodes JSON.
  Future<ApiResult<T>> delete({
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Object? body,
    HttpStatusPredicate? acceptStatus,
  }) {
    return _client.deleteJson<T>(
      path,
      query: query,
      headers: headers,
      body: body,
      acceptStatus: acceptStatus,
      decode: _decode,
    );
  }
}

final class _ApiRetryPolicy {
  const _ApiRetryPolicy({
    required this.maxAttempts,
    required this.delay,
    required this.backoff,
    required this.jitter,
    this.retryIf,
  });

  final int maxAttempts;
  final Duration delay;
  final BackoffStrategy backoff;
  final double jitter;
  final HttpRetryPredicate? retryIf;
}

Uri _normalizeBaseUri(Object baseUrl) {
  final uri = _parseRequestUri(baseUrl);
  if (!uri.hasScheme || uri.host.isEmpty) {
    throw ArgumentError.value(baseUrl, 'baseUrl', 'Must be an absolute URI.');
  }
  final path = uri.path.isEmpty || uri.path.endsWith('/')
      ? uri.path
      : '${uri.path}/';
  return uri.replace(path: path.isEmpty ? '/' : path);
}

Uri _parseRequestUri(Object value) {
  return switch (value) {
    final Uri uri => uri,
    final String text => Uri.parse(text),
    _ => throw ArgumentError.value(value, 'uri', 'Must be a Uri or String.'),
  };
}

Uri _mergeQuery(Uri uri, Map<String, Object?>? query) {
  if (query == null || query.isEmpty) return uri;

  final merged = <String, Object?>{};
  for (final entry in uri.queryParametersAll.entries) {
    merged[entry.key] = entry.value.length == 1
        ? entry.value.single
        : entry.value;
  }

  for (final entry in query.entries) {
    final value = entry.value;
    if (value == null) continue;
    merged[entry.key] = switch (value) {
      final Iterable<Object?> values when value is! String =>
        values
            .where((item) => item != null)
            .map((item) => item.toString())
            .toList(),
      _ => value.toString(),
    };
  }

  return uri.replace(queryParameters: merged);
}
