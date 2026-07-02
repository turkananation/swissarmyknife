/// Composable codec pipelines for typed encoding and decoding workflows.
///
/// Use [CodecPipeline] to chain conversion stages while keeping stage names,
/// bulk conversion, and `Result`-based error handling in one place.
library;

import 'dart:convert' as dart_convert;

import '../functional/result.dart';

/// Synchronous conversion step used by [CodecPipeline].
typedef CodecPipelineTransform<I, O> = O Function(I input);

/// Error thrown when a codec pipeline stage fails.
final class CodecPipelineException implements Exception {
  /// Creates a pipeline exception.
  const CodecPipelineException({
    required this.stepIndex,
    required this.stepName,
    required this.cause,
    required this.stackTrace,
  });

  /// Zero-based index of the failed step.
  final int stepIndex;

  /// Name of the failed step.
  final String stepName;

  /// Original thrown object.
  final Object cause;

  /// Original stack trace.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'CodecPipelineException(step: $stepIndex "$stepName", cause: '
        '$cause)';
  }
}

/// Typed, composable conversion pipeline.
///
/// Example:
/// ```dart
/// final pipeline = CodecPipelines.utf8Encode
///     .thenPipeline(CodecPipelines.base64Encode);
/// final encoded = pipeline.convert('hello');
/// ```
final class CodecPipeline<I, O> {
  CodecPipeline._(Iterable<_CodecPipelineStage> stages)
    : _stages = List<_CodecPipelineStage>.unmodifiable(stages);

  /// Creates a pipeline from one transform.
  factory CodecPipeline(
    CodecPipelineTransform<I, O> transform, {
    String? name,
  }) {
    return CodecPipeline<I, I>.identity().then<O>(transform, name: name);
  }

  /// Creates an identity pipeline.
  factory CodecPipeline.identity() => CodecPipeline<I, O>._(const []);

  /// Creates a pipeline from a Dart [dart_convert.Converter].
  factory CodecPipeline.fromConverter(
    dart_convert.Converter<I, O> converter, {
    String? name,
  }) {
    return CodecPipeline<I, I>.identity().thenConverter<O>(
      converter,
      name: name,
    );
  }

  /// Creates a pipeline from a Dart [dart_convert.Codec] encoder.
  factory CodecPipeline.fromCodecEncoder(
    dart_convert.Codec<I, O> codec, {
    String? name,
  }) {
    return CodecPipeline<I, I>.identity().thenCodecEncoder<O>(
      codec,
      name: name,
    );
  }

  /// Creates a pipeline from a Dart [dart_convert.Codec] decoder.
  factory CodecPipeline.fromCodecDecoder(
    dart_convert.Codec<O, I> codec, {
    String? name,
  }) {
    return CodecPipeline<I, I>.identity().thenCodecDecoder<O>(
      codec,
      name: name,
    );
  }

  final List<_CodecPipelineStage> _stages;

  /// Names of the pipeline steps in execution order.
  List<String> get stepNames {
    return List<String>.unmodifiable(_stages.map((stage) => stage.name));
  }

  /// Number of conversion steps.
  int get length => _stages.length;

  /// Whether this pipeline has no conversion steps.
  bool get isIdentity => _stages.isEmpty;

  /// Appends a typed transform.
  CodecPipeline<I, N> then<N>(
    CodecPipelineTransform<O, N> transform, {
    String? name,
  }) {
    final stepName = name ?? 'step ${_stages.length + 1}';
    return CodecPipeline<I, N>._([
      ..._stages,
      _CodecPipelineStage(stepName, (input) => transform(input as O)),
    ]);
  }

  /// Appends a Dart [dart_convert.Converter].
  CodecPipeline<I, N> thenConverter<N>(
    dart_convert.Converter<O, N> converter, {
    String? name,
  }) {
    return then<N>(
      converter.convert,
      name: name ?? converter.runtimeType.toString(),
    );
  }

  /// Appends a Dart [dart_convert.Codec] encoder.
  CodecPipeline<I, N> thenCodecEncoder<N>(
    dart_convert.Codec<O, N> codec, {
    String? name,
  }) {
    return then<N>(codec.encode, name: name ?? '${codec.runtimeType}.encode');
  }

  /// Appends a Dart [dart_convert.Codec] decoder.
  CodecPipeline<I, N> thenCodecDecoder<N>(
    dart_convert.Codec<N, O> codec, {
    String? name,
  }) {
    return then<N>(codec.decode, name: name ?? '${codec.runtimeType}.decode');
  }

  /// Appends every stage from [pipeline].
  CodecPipeline<I, N> thenPipeline<N>(CodecPipeline<O, N> pipeline) {
    return CodecPipeline<I, N>._([..._stages, ...pipeline._stages]);
  }

  /// Converts [input] through every stage.
  O convert(I input) {
    Object? current = input;

    for (var i = 0; i < _stages.length; i++) {
      final stage = _stages[i];
      try {
        current = stage.convert(current);
      } catch (error, stackTrace) {
        Error.throwWithStackTrace(
          CodecPipelineException(
            stepIndex: i,
            stepName: stage.name,
            cause: error,
            stackTrace: stackTrace,
          ),
          stackTrace,
        );
      }
    }

    return current as O;
  }

  /// Alias for [convert].
  O call(I input) => convert(input);

  /// Converts many [inputs] lazily.
  Iterable<O> convertAll(Iterable<I> inputs) sync* {
    for (final input in inputs) {
      yield convert(input);
    }
  }

  /// Converts [input], returning a [Result] instead of throwing.
  Result<O, CodecPipelineException> tryConvert(I input) {
    try {
      return Result<O, CodecPipelineException>.success(convert(input));
    } on CodecPipelineException catch (error) {
      return Result<O, CodecPipelineException>.failure(error);
    }
  }

  /// Converts many [inputs], returning the first stage failure as a [Result].
  Result<List<O>, CodecPipelineException> tryConvertAll(Iterable<I> inputs) {
    try {
      return Result<List<O>, CodecPipelineException>.success(
        convertAll(inputs).toList(growable: false),
      );
    } on CodecPipelineException catch (error) {
      return Result<List<O>, CodecPipelineException>.failure(error);
    }
  }

  @override
  String toString() {
    if (isIdentity) return 'CodecPipeline(identity)';
    return 'CodecPipeline(${stepNames.join(' -> ')})';
  }
}

/// Common prebuilt codec pipelines.
abstract final class CodecPipelines {
  /// Identity pipeline.
  static CodecPipeline<T, T> identity<T>() => CodecPipeline<T, T>.identity();

  /// String to UTF-8 bytes.
  static CodecPipeline<String, List<int>> get utf8Encode {
    return CodecPipeline<String, List<int>>.fromConverter(
      dart_convert.utf8.encoder,
      name: 'utf8.encode',
    );
  }

  /// UTF-8 bytes to string.
  static CodecPipeline<List<int>, String> get utf8Decode {
    return CodecPipeline<List<int>, String>.fromConverter(
      dart_convert.utf8.decoder,
      name: 'utf8.decode',
    );
  }

  /// Bytes to base64 string.
  static CodecPipeline<List<int>, String> get base64Encode {
    return CodecPipeline<List<int>, String>.fromConverter(
      dart_convert.base64.encoder,
      name: 'base64.encode',
    );
  }

  /// Base64 string to bytes.
  static CodecPipeline<String, List<int>> get base64Decode {
    return CodecPipeline<String, List<int>>.fromConverter(
      dart_convert.base64.decoder,
      name: 'base64.decode',
    );
  }

  /// JSON-compatible value to JSON text.
  static CodecPipeline<Object?, String> get jsonEncode {
    return CodecPipeline<Object?, String>.fromConverter(
      dart_convert.json.encoder,
      name: 'json.encode',
    );
  }

  /// JSON text to decoded JSON-compatible value.
  static CodecPipeline<String, Object?> get jsonDecode {
    return CodecPipeline<String, Object?>.fromConverter(
      dart_convert.json.decoder,
      name: 'json.decode',
    );
  }

  /// String to base64 text through UTF-8 bytes.
  static CodecPipeline<String, String> get stringToBase64 {
    return utf8Encode.thenPipeline(base64Encode);
  }

  /// Base64 text to string through UTF-8 bytes.
  static CodecPipeline<String, String> get base64ToString {
    return base64Decode.thenPipeline(utf8Decode);
  }

  /// JSON-compatible value to base64-encoded JSON text.
  static CodecPipeline<Object?, String> get jsonToBase64 {
    return jsonEncode.thenPipeline(utf8Encode).thenPipeline(base64Encode);
  }

  /// Base64-encoded JSON text to a decoded JSON-compatible value.
  static CodecPipeline<String, Object?> get base64ToJson {
    return base64Decode.thenPipeline(utf8Decode).thenPipeline(jsonDecode);
  }
}

final class _CodecPipelineStage {
  const _CodecPipelineStage(this.name, this.convert);

  final String name;
  final Object? Function(Object? input) convert;
}
