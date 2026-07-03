/// Library-level comment for Uint8List extensions.
///
/// Contains byte array operations such as hex formatting, base64 encoding,
/// safe UTF-8 decoding, sublist search, and timing-safe content comparison.
library;

import 'dart:convert';
import 'dart:typed_data';

/// Extensions on [Uint8List] to provide advanced binary and byte utilities.
///
/// Example:
/// ```dart
/// final bytes = Uint8List.fromList([72, 101, 108, 108, 111]);
/// print(bytes.toUtf8StringOrNull()); // 'Hello'
/// ```
extension Uint8ListKnife on Uint8List {
  /// Converts this byte list to a hexadecimal string.
  ///
  /// The [separator] parameter can be used to join individual hex bytes.
  ///
  /// Example:
  /// ```dart
  /// final bytes = Uint8List.fromList([222, 173, 190, 239]);
  /// print(bytes.toHexString()); // 'DEADBEEF'
  /// print(bytes.toHexString(separator: ':')); // 'DE:AD:BE:EF'
  /// ```
  String toHexString({String separator = ''}) {
    return map(
      (byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase(),
    ).join(separator);
  }

  /// Encodes this byte list into a Base64 string.
  ///
  /// Example:
  /// ```dart
  /// final bytes = Uint8List.fromList([72, 101, 108, 108, 111]);
  /// print(bytes.toBase64String()); // 'SGVsbG8='
  /// ```
  String toBase64String() => base64Encode(this);

  /// Safely decodes this byte list into a UTF-8 string.
  ///
  /// Returns `null` if the bytes are not valid UTF-8.
  ///
  /// Example:
  /// ```dart
  /// final bytes = Uint8List.fromList([72, 101, 108, 108, 111]);
  /// print(bytes.toUtf8StringOrNull()); // 'Hello'
  /// ```
  String? toUtf8StringOrNull() {
    try {
      return utf8.decode(this);
    } catch (_) {
      return null;
    }
  }

  /// Finds the first index of the specified [sublist] in this byte list.
  ///
  /// Returns `-1` if the sublist is not found. Starts searching from [start].
  ///
  /// Example:
  /// ```dart
  /// final bytes = Uint8List.fromList([1, 2, 3, 4, 2, 3]);
  /// print(bytes.indexOfSublist([2, 3])); // 1
  /// print(bytes.indexOfSublist([2, 3], 2)); // 4
  /// ```
  int indexOfSublist(List<int> sublist, [int start = 0]) {
    if (sublist.isEmpty) return start;
    var searchStart = start < 0 ? 0 : start;
    if (searchStart + sublist.length > length) return -1;

    for (var i = searchStart; i <= length - sublist.length; i++) {
      var found = true;
      for (var j = 0; j < sublist.length; j++) {
        if (this[i + j] != sublist[j]) {
          found = false;
          break;
        }
      }
      if (found) {
        return i;
      }
    }
    return -1;
  }

  /// Performs a constant-time comparison between this and [other] byte list.
  ///
  /// This prevents timing attacks when comparing cryptographic signatures or hashes.
  ///
  /// Example:
  /// ```dart
  /// final a = Uint8List.fromList([1, 2, 3]);
  /// final b = Uint8List.fromList([1, 2, 3]);
  /// print(a.contentEquals(b)); // true
  /// ```
  bool contentEquals(List<int> other) {
    if (length != other.length) {
      return false;
    }
    var result = 0;
    for (var i = 0; i < length; i++) {
      result |= this[i] ^ other[i];
    }
    return result == 0;
  }
}
