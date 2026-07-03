# SwissArmyKnife

Production-grade Dart utilities behind one import.

```text
███████╗██╗    ██╗██╗███████╗███████╗
██╔════╝██║    ██║██║██╔════╝██╔════╝
███████╗██║ █╗ ██║██║███████╗███████╗
╚════██║██║███╗██║██║╚════██║╚════██║
███████║╚███╔███╔╝██║███████║███████║
╚══════╝ ╚══╝╚══╝ ╚═╝╚══════╝╚══════╝

 █████╗ ██████╗ ███╗   ███╗██╗   ██╗
██╔══██╗██╔══██╗████╗ ████║╚██╗ ██╔╝
███████║██████╔╝██╔████╔██║ ╚████╔╝
██╔══██║██╔══██╗██║╚██╔╝██║  ╚██╔╝
██║  ██║██║  ██║██║ ╚═╝ ██║   ██║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝   ╚═╝

██╗  ██╗███╗   ██╗██╗███████╗███████╗
██║ ██╔╝████╗  ██║██║██╔════╝██╔════╝
█████╔╝ ██╔██╗ ██║██║█████╗  █████╗
██╔═██╗ ██║╚██╗██║██║██╔══╝  ██╔══╝
██║  ██╗██║ ╚████║██║██║     ███████╗
╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚══════╝

        production-grade Dart utilities · one import
```

[![Pub Version](https://img.shields.io/pub/v/swissarmyknife.svg)](https://pub.dev/packages/swissarmyknife)
[![CI](https://github.com/turkananation/swissarmyknife/actions/workflows/ci.yml/badge.svg)](https://github.com/turkananation/swissarmyknife/actions/workflows/ci.yml)
[![Docs](https://github.com/turkananation/swissarmyknife/actions/workflows/pages.yml/badge.svg)](https://turkananation.github.io/swissarmyknife/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

SwissArmyKnife is a focused Dart toolkit for the small pieces every serious
project eventually needs: expressive extensions, functional result types,
async control, validation, HTTP helpers, safe JSON, caching, date ranges,
cron scheduling, logging, memoization, circuit breakers, task queues, trees,
graphs, reactive state, and middleware pipelines.

It is built for one clear habit:

```dart
import 'package:swissarmyknife/swissarmyknife.dart';
```

## Why It Stands Out

- One barrel import for a broad, tested utility surface.
- Fluent extensions for strings, collections, maps, numbers, dates, futures,
  streams, URIs, regular expressions, bytes, and nullable values.
- Sealed `Result`, `Option`, and `Either` types for explicit control flow.
- Production helpers for retry, debounce, throttle, rate limiting, validation,
  event buses, disposal, commands, state machines, and lazy values.
- App infrastructure primitives: HTTP requests, API clients, safe JSON,
  schema validation, LRU cache, env config, logging, benchmarking, cron, and
  date ranges.
- Advanced composition tools: memoization, circuit breaker, priority task
  queue, tree/graph utilities, codecs, expression evaluation, reactive store,
  and middleware pipeline.
- Release gate covers formatting, static analysis, tests, web compilation,
  dartdoc generation, pub dry-run, and the Jaspr documentation site build.

## Install

```yaml
dependencies:
  swissarmyknife: ^0.1.0
```

```bash
dart pub get
```

## Quick Start

```dart
import 'package:swissarmyknife/swissarmyknife.dart';

Future<void> main() async {
  print('hello_world'.toPascalCase()); // HelloWorld
  print(1500000.toCompactString()); // 1.5M

  final parsed = Result.runCatching(() => int.parse('42'));
  print(parsed.getOrElse(0)); // 42

  final validator = Validator<String>.email().minLength(5);
  print(validator.validate('me@example.com').isSuccess); // true

  final json = {
    'user': {'name': 'Ada'},
  };
  print(json.at('user.name').asStringOr('Unknown')); // Ada

  final queue = TaskQueue(concurrency: 2);
  print(await queue.add(() => 'done').future); // done
}
```

See [example/swissarmyknife_example.dart](example/swissarmyknife_example.dart)
for a broader walk-through.

## Feature Map

| Area | Highlights |
| --- | --- |
| Extensions | Strings, collections, maps, numbers, dates, durations, futures, streams, sets, regex, URIs, bytes, nullable values |
| Functional | `Result`, `Option`, `Either`, tuples, sync and async pipelines |
| Async | `Debouncer`, `Throttler`, `retry`, token-bucket and sliding-window rate limiters |
| Patterns | `Validator`, `EventBus`, `DisposeBag`, `Lazy`, `StateMachine`, `CommandHistory` |
| Data and IO | `SafeJson`, `SchemaValidator`, `Cache`, `Env`, `Http`, `ApiClientBuilder` |
| Time | `benchmark`, `benchmarkAsync`, `DateRange`, `Recurrence`, `CronExpression`, `CronScheduler` |
| Advanced | Memoization, circuit breaker, task queue, tree/graph tools, codec pipelines, expression evaluator, reactive store, middleware pipeline |

## Platform Support

The package is designed for Dart VM, Flutter mobile, Flutter desktop, and web
compilation. `Env.load()` reads dotenv files and is only available on Dart VM
platforms; use `Env.fromMap()` for browser builds or app-managed runtime
configuration.

## Documentation

- Full site: <https://turkananation.github.io/swissarmyknife/>
- Getting started: [doc/GETTING_STARTED.md](doc/GETTING_STARTED.md)
- API guide: [doc/API_GUIDE.md](doc/API_GUIDE.md)
- Cookbook: [doc/COOKBOOK.md](doc/COOKBOOK.md)
- Release process: [doc/RELEASE.md](doc/RELEASE.md)
- Platform support: [doc/PLATFORM_SUPPORT.md](doc/PLATFORM_SUPPORT.md)

## Verification

Run the standard development gate:

```bash
dart run tool/agent/verify.dart quick
```

Run the full release gate before tagging:

```bash
dart run tool/agent/verify.dart release
```

The `release` gate includes the Jaspr site build and `dart pub publish
--dry-run`. Releases are tagged as `v<version>` from the verified commit.

## License

MIT. See [LICENSE](LICENSE).
