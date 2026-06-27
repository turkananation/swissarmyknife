import 'dart:typed_data';
import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Uint8ListKnife', () {
    group('toHexString', () {
      test('should format bytes to uppercase hex string without separator', () {
        final bytes = Uint8List.fromList([0, 10, 15, 255]);
        expect(bytes.toHexString(), equals('000A0FFF'));
      });

      test('should format bytes to hex string with custom separator', () {
        final bytes = Uint8List.fromList([0, 10, 15, 255]);
        expect(bytes.toHexString(separator: ':'), equals('00:0A:0F:FF'));
      });
    });

    group('toBase64String', () {
      test('should encode byte array to base64 string', () {
        final bytes = Uint8List.fromList([72, 101, 108, 108, 111]);
        expect(bytes.toBase64String(), equals('SGVsbG8='));
      });
    });

    group('toUtf8StringOrNull', () {
      test('should decode valid UTF-8 bytes to string', () {
        final bytes = Uint8List.fromList([72, 101, 108, 108, 111]);
        expect(bytes.toUtf8StringOrNull(), equals('Hello'));
      });

      test('should return null for invalid UTF-8 bytes', () {
        final bytes = Uint8List.fromList([0xFF, 0xFE]);
        expect(bytes.toUtf8StringOrNull(), isNull);
      });
    });

    group('indexOfSublist', () {
      test('should find sublist starting at correct index', () {
        final bytes = Uint8List.fromList([1, 2, 3, 4, 2, 3]);
        expect(bytes.indexOfSublist([2, 3]), equals(1));
        expect(bytes.indexOfSublist([2, 3], 2), equals(4));
      });

      test('should return -1 if sublist is not found', () {
        final bytes = Uint8List.fromList([1, 2, 3]);
        expect(bytes.indexOfSublist([4]), equals(-1));
      });

      test('should handle empty sublist and out of bounds start', () {
        final bytes = Uint8List.fromList([1, 2, 3]);
        expect(bytes.indexOfSublist([], 1), equals(1));
        expect(bytes.indexOfSublist([1], 5), equals(-1));
      });
    });

    group('contentEquals', () {
      test('should return true for byte lists with identical content', () {
        final a = Uint8List.fromList([1, 2, 3]);
        final b = Uint8List.fromList([1, 2, 3]);
        expect(a.contentEquals(b), isTrue);
      });

      test('should return false for byte lists with differing content', () {
        final a = Uint8List.fromList([1, 2, 3]);
        final b = Uint8List.fromList([1, 2, 4]);
        expect(a.contentEquals(b), isFalse);
      });

      test('should return false for byte lists with differing lengths', () {
        final a = Uint8List.fromList([1, 2, 3]);
        final b = Uint8List.fromList([1, 2]);
        expect(a.contentEquals(b), isFalse);
      });
    });
  });
}
