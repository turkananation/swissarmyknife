import 'dart:convert' as convert;

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('CodecPipeline', () {
    test('should compose typed transforms', () {
      final pipeline =
          CodecPipeline<String, String>((value) => value.trim(), name: 'trim')
              .then(int.parse, name: 'parse')
              .then((value) => value * 2, name: 'double');

      expect(pipeline.convert(' 21 '), equals(42));
      expect(pipeline(' 7 '), equals(14));
      expect(pipeline.stepNames, equals(['trim', 'parse', 'double']));
      expect(pipeline.length, equals(3));
      expect(pipeline.isIdentity, isFalse);
      expect(
        pipeline.toString(),
        equals('CodecPipeline(trim -> parse -> double)'),
      );
    });

    test('should support identity pipelines', () {
      final pipeline = CodecPipelines.identity<String>();

      expect(pipeline.convert('value'), equals('value'));
      expect(pipeline.isIdentity, isTrue);
      expect(pipeline.length, equals(0));
      expect(pipeline.stepNames, isEmpty);
      expect(pipeline.toString(), equals('CodecPipeline(identity)'));
    });

    test('should compose Dart converters and pipelines', () {
      final pipeline = CodecPipelines.utf8Encode.thenPipeline(
        CodecPipelines.base64Encode,
      );

      expect(pipeline.convert('hello'), equals('aGVsbG8='));
      expect(pipeline.stepNames, equals(['utf8.encode', 'base64.encode']));
    });

    test('should expose common string and JSON pipelines', () {
      final encodedText = CodecPipelines.stringToBase64.convert('hello');
      final jsonPayload = {
        'name': 'Ada',
        'tags': ['math', 'code'],
      };
      final encodedJson = CodecPipelines.jsonToBase64.convert(jsonPayload);

      expect(encodedText, equals('aGVsbG8='));
      expect(
        CodecPipelines.base64ToString.convert(encodedText),
        equals('hello'),
      );
      expect(
        CodecPipelines.base64ToJson.convert(encodedJson),
        equals(jsonPayload),
      );
    });

    test('should create pipelines from codec encoders and decoders', () {
      final encoder = CodecPipeline<String, List<int>>.fromCodecEncoder(
        convert.utf8,
        name: 'utf8 codec encode',
      );
      final decoder = CodecPipeline<List<int>, String>.fromCodecDecoder(
        convert.utf8,
        name: 'utf8 codec decode',
      );

      expect(encoder.convert('Hi'), equals([72, 105]));
      expect(decoder.convert([72, 105]), equals('Hi'));
      expect(encoder.stepNames, equals(['utf8 codec encode']));
      expect(decoder.stepNames, equals(['utf8 codec decode']));
    });

    test('should convert many inputs lazily', () {
      final pipeline = CodecPipeline<String, int>(
        int.parse,
        name: 'parse',
      ).then((value) => value + 1, name: 'increment');

      expect(pipeline.convertAll(['1', '2', '3']), equals([2, 3, 4]));
      expect(pipeline.tryConvertAll(['4', '5']).valueOrNull, equals([5, 6]));
    });

    test('should return Result failures with failed stage details', () {
      final result = CodecPipelines.base64ToString.tryConvert('not base64');

      expect(result.isFailure, isTrue);
      final error = result.errorOrNull!;
      expect(error.stepIndex, equals(0));
      expect(error.stepName, equals('base64.decode'));
      expect(error.cause, isA<FormatException>());
      expect(error.toString(), contains('base64.decode'));
    });

    test('should wrap failures thrown by later stages', () {
      final pipeline = CodecPipelines.stringToBase64.then(
        (_) => throw StateError('bad suffix'),
        name: 'suffix',
      );

      final result = pipeline.tryConvert('hello');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.stepIndex, equals(2));
      expect(result.errorOrNull!.stepName, equals('suffix'));
      expect(result.errorOrNull!.cause, isA<StateError>());
    });
  });
}
