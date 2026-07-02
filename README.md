# SwissArmyKnife

> A Dart extension toolkit for cleaner, more expressive code.

[![Pub Version](https://img.shields.io/pub/v/swissarmyknife.svg)](https://pub.dev/packages/swissarmyknife)
[![Dart](https://img.shields.io/badge/Dart-%5E3.12.0-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

SwissArmyKnife is a focused Dart package of extension helpers and small
functional primitives for common tasks: strings, collections, numbers, dates,
async flows, URIs, regex, binary data, explicit error handling, and more.

- Single barrel import: `import 'package:swissarmyknife/swissarmyknife.dart';`
- Collections, strings, numbers, dates, async, regex, URI, and byte utilities
- `Result`, `Option`, `Either`, `Pair`, and `Triple` for explicit control flow
- Debounce, throttle, retry, rate limiter, validator, event bus, and disposal helpers
- Safe JSON access, LRU cache, benchmarks, env config, and date ranges
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

It also exposes functional modules under `lib/src/functional/`:

- `result.dart`
- `option.dart`
- `either.dart`
- `tuple.dart`
- `pipeline.dart`

Tier 2 async and pattern modules live under `lib/src/async/` and
`lib/src/patterns/`:

- `debouncer.dart`
- `throttler.dart`
- `retry.dart`
- `rate_limiter.dart`
- `command.dart`
- `event_bus.dart`
- `disposable.dart`
- `lazy.dart`
- `state_machine.dart`
- `validator.dart`

Networking, data, time, and logging utilities are available under
`lib/src/networking/`, `lib/src/data/`, `lib/src/time/`, and
`lib/src/logging/`:

- `api_client_builder.dart`
- `http_client.dart`
- `safe_json.dart`
- `schema_validator.dart`
- `cache_manager.dart`
- `env_config.dart`
- `benchmark.dart`
- `cron_scheduler.dart`
- `date_range.dart`
- `logger.dart`

Advanced modules are available under `lib/src/advanced/`:

- `codec_pipeline.dart`
- `circuit_breaker.dart`
- `expression_evaluator.dart`
- `memoize.dart`
- `middleware_pipeline.dart`
- `reactive_store.dart`
- `task_queue.dart`
- `tree_utils.dart`

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

## Example

A complete example is available at `example/swissarmyknife_example.dart`.

```dart
import 'package:swissarmyknife/swissarmyknife.dart';

void main() {
  print('hello_world'.toPascalCase()); // HelloWorld
  print(1500000.toCompactString()); // 1.5M
  print('hello'.wrap('[', ']')); // [hello]

  final parsed = Result.runCatching(() => int.parse('42'));
  print(parsed.getOrElse(0)); // 42

  final debouncer = Debouncer(const Duration(milliseconds: 250));
  debouncer.run(() => print('debounced'));

  final validator = Validator<String>.email().minLength(5);
  print(validator.validate('me@example.com').isSuccess); // true

  final json = {'user': {'name': 'Ada'}};
  print(json.at('user.name').asStringOr('Unknown')); // Ada
}
```

## Usage

```dart
import 'package:swissarmyknife/swissarmyknife.dart';

void main() {
  print('hello_world'.toPascalCase()); // HelloWorld
  print(1500000.toCompactString());    // 1.5M
  print('hello'.wrap('[', ']'));       // [hello]

  final option = Option.fromNullable('Ada');
  print(option.map((name) => name.toUpperCase()).getOrElse('UNKNOWN'));
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
- Functional helpers: sealed `Result`, `Option`, and `Either` types, tuples,
  reusable `Pipe`s, and sync/async `Pipeline`s
- Async helpers: `Debouncer`, `Throttler`, `retry`, `RateLimiter`,
  stream debounce/throttle
- Pattern helpers: typed `EventBus`, `GlobalEventBus`, `Disposable`,
  `DisposeBag`, sync/async `Lazy`, guarded `StateMachine`, and undo/redo
  `CommandHistory`
- Validation helpers: chainable `Validator<T>` with `Result<T, List<String>>`
- Networking helpers: fluent `Http` wrapper with headers, JSON bodies,
  timeouts, retry policy, status validation, and `Result` errors; reusable
  `ApiClientBuilder` with base URLs, shared headers, typed JSON endpoints, and
  API-specific failures
- Data helpers: `SafeJson`, composable `SchemaValidator`, `Cache`, and `Env`
- Time helpers: `benchmark`, `benchmarkAsync`, five-field `CronExpression` /
  `CronScheduler`, `DateRange`, and `Recurrence`
- Logging helpers: configurable `Log` facade with levels, tags, timestamps,
  colors, and stack traces
- Advanced helpers: sync/async memoization with TTL, LRU, custom keys,
  in-flight async sharing, `CircuitBreaker` fail-fast protection, bounded
  priority `TaskQueue`, immutable `TreeNode`, traversal-ready `Graph`, and
  composable `CodecPipeline` encoding/decoding chains
- Expression helpers: compiled numeric `ExpressionEvaluator` with variables,
  constants, functions, parser errors, and `Result` fallbacks
- Reactive helpers: `ReactiveStore` and selectors with versioned changes,
  synchronous subscriptions, streams, custom equality, and disposal
- Middleware helpers: immutable async-aware `MiddlewarePipeline` with
  short-circuiting, terminal overrides, tap/transform/guard helpers, and
  `Result` failure capture

## 🧪 Testing

The package includes complete tests under `test/extensions/`,
`test/functional/`, `test/async/`, `test/patterns/`, `test/data/`,
`test/time/`, `test/logging/`, `test/networking/`, and `test/advanced/`.
Run all tests with:

```bash
dart test
```

## 📁 Project structure

- `lib/swissarmyknife.dart` — single import entrypoint
- `lib/src/extensions/` — all extension modules
- `lib/src/functional/` — functional primitives and tuple types
- `lib/src/async/` — debounce, throttle, retry, and rate limit utilities
- `lib/src/patterns/` — event bus, disposal, and validation helpers
- `lib/src/networking/` — fluent HTTP request helpers
- `lib/src/data/` — safe JSON, cache, and environment config helpers
- `lib/src/time/` — benchmark and date range helpers
- `lib/src/logging/` — configurable console logging helpers
- `lib/src/advanced/` — memoization and higher-level utilities
- `test/extensions/` — unit tests for each extension file
- `test/functional/` — unit tests for functional primitives
- `test/async/` — unit tests for async utilities
- `test/patterns/` — unit tests for pattern helpers
- `test/networking/` — unit tests for HTTP helpers
- `test/data/` — unit tests for data helpers
- `test/time/` — unit tests for time helpers
- `test/logging/` — unit tests for logging helpers
- `test/advanced/` — unit tests for advanced utilities

## 🤝 Contributing

Contributions are welcome. Open issues or PRs for:

- new extension helpers
- bug fixes and edge-case coverage
- improvements to existing APIs

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Get help

- Repository: <https://github.com/turkananation/swissarmyknife>
- Issues: <https://github.com/turkananation/swissarmyknife/issues>

---

Built to make Dart code cleaner, faster, and easier to write.
