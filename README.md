# SwissArmyKnife

> A Dart extension toolkit for cleaner, more expressive code.

[![Pub Version](https://img.shields.io/pub/v/swissarmyknife.svg)](https://pub.dev/packages/swissarmyknife)
[![Dart](https://img.shields.io/badge/Dart-%5E3.12.0-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

SwissArmyKnife is a focused Dart package of extension helpers for common tasks:
strings, collections, numbers, dates, async flows, URIs, regex, binary data,
and more.

- Single barrel import: `import 'package:swissarmyknife/swissarmyknife.dart';`
- Collections, strings, numbers, dates, async, regex, URI, and byte utilities
- Lightweight, idiomatic Dart with a minimal dependency footprint
- Designed for fast iteration and better readability across Dart projects

## ✨ What it includes

SwissArmyKnife currently exposes a curated set of extension modules under `lib/src/extensions/`:

- `bool_extensions.dart`
- `collection_extensions.dart`
- `collection_advanced_extensions.dart`
- `comparable_iterable_extensions.dart`
- `datetime_extensions.dart`
- `datetime_advanced_extensions.dart`
- `double_extensions.dart`
- `duration_extra_extensions.dart`
- `future_extensions.dart`
- `int_math_extensions.dart`
- `map_extensions.dart`
- `map_entry_extensions.dart`
- `nullable_extensions.dart`
- `numeric_iterable_extensions.dart`
- `random_extensions.dart`
- `regexp_extensions.dart`
- `scope_functions.dart`
- `set_extensions.dart`
- `stream_extensions.dart`
- `string_extensions.dart`
- `string_advanced_extensions.dart`
- `string_iterable_extensions.dart`
- `uint8list_extensions.dart`
- `uri_extensions.dart`

## 🚀 Why use SwissArmyKnife?

- Keep code concise with extension methods instead of helper classes
- Avoid repetitive boilerplate for common tasks
- Improve readability with fluent, chainable operations
- Works in Dart CLI, server, and Flutter code

## 📦 Install

Add to your `pubspec.yaml`:

```yaml
dependencies:
  swissarmyknife: ^0.1.0
```

Then run:

```bash
dart pub get
```

## � Example

A complete example is available at `example/swissarmyknife_example.dart`.

```dart
import 'package:swissarmyknife/swissarmyknife.dart';

void main() {
  print('hello_world'.toPascalCase()); // HelloWorld
  print(1500000.toCompactString()); // 1.5M
  print('hello'.wrap('[', ']')); // [hello]
}
```

## �📘 Usage

```dart
import 'package:swissarmyknife/swissarmyknife.dart';

void main() {
  print('hello_world'.toPascalCase()); // HelloWorld
  print(1500000.toCompactString());    // 1.5M
  print('hello'.wrap('[', ']'));       // [hello]
}
```

## 🔧 Core features

- String helpers: `toPascalCase`, `wrap`, `truncate`, `isBlank`, `replaceMultiple`
- Numeric helpers: `toCompactString`, `clamp`, `toIntOrNull`, `toDoubleOrNull`
- Date helpers: formatting, range comparisons, start/end boundaries
- Collection helpers: safe lookup, deep merge, zip, chunk, intersect, difference
- Async helpers: `timeoutOrNull`, `delay`, `suppressError`, `onErrorReturn`
- URI helpers: query param modification and removal
- Regex helpers: named capture extraction and mapped replacement
- Byte helpers: hex/base64 encoding, safe UTF-8 decoding, constant-time comparison

## 🧪 Testing

The package includes complete extension tests under `test/extensions/`.
Run all tests with:

```bash
dart test
```

## 📁 Project structure

- `lib/swissarmyknife.dart` — single import entrypoint
- `lib/src/extensions/` — all extension modules
- `test/extensions/` — unit tests for each extension file

## 🤝 Contributing

Contributions are welcome. Open issues or PRs for:

- new extension helpers
- bug fixes and edge-case coverage
- improvements to existing APIs

## � License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## �📬 Get help

- Repository: <https://github.com/turkananation/swissarmyknife>
- Issues: <https://github.com/turkananation/swissarmyknife/issues>

---

Built to make Dart code cleaner, faster, and easier to write.
