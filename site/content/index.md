---
title: Dart utilities with release discipline
description: SwissArmyKnife is a production-grade Dart toolkit for extensions, functional types, async control, validation, HTTP, caching, and app infrastructure.
keywords:
  - Dart utilities
  - Dart extensions
  - Result Option Either
  - Jaspr documentation
image: images/hero-console.svg
imageAlt: SwissArmyKnife release dashboard
---

SwissArmyKnife is the utility layer you reach for when application code starts
collecting local helpers. It keeps the surface broad, typed, and tested while
staying behind a single import.

<Info>
  v0.1.0 is guarded by formatting, static analysis, the full test suite, web
  compilation, dartdoc generation, pub dry-run, and this Jaspr site build.
</Info>

```dart
import 'package:swissarmyknife/swissarmyknife.dart';

final parsed = Result.runCatching(() => int.parse('42'));
final email = Validator<String>.email().validate('team@example.com');
final name = {'user': {'name': 'Ada'}}.at('user.name').asStringOr('Unknown');
```

## The Shape

| Layer | What it gives you |
| --- | --- |
| Extensions | Strings, collections, maps, numbers, dates, futures, streams, URIs, regex, bytes, nullable values |
| Control flow | `Result`, `Option`, `Either`, tuples, sync and async pipelines |
| Coordination | Retry, debounce, throttle, rate limits, task queues, circuit breakers |
| App glue | Validation, HTTP, API clients, safe JSON, schema validation, cache, env, logging |
| Architecture | State machines, commands, event bus, lazy values, reactive store, middleware |

## Release Posture

The package is intentionally conservative about claims. Platform support is
checked by compile gates, not prose. Pub packaging is checked with a dry-run.
Releases are tagged as `v<version>` from the verified commit.

## Start

Install from pub.dev:

```yaml
dependencies:
  swissarmyknife: ^0.1.0
```

Then read [Getting Started](getting-started), scan the [API Guide](api), and
keep the [Cookbook](cookbook) nearby for common patterns.
