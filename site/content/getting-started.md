---
title: Getting Started
description: Add SwissArmyKnife to a Dart or Flutter project and start using the single public import.
---

## Install

```yaml
dependencies:
  swissarmyknife: ^0.1.0
```

```bash
dart pub get
```

## Import

```dart
import 'package:swissarmyknife/swissarmyknife.dart';
```

## First Use

```dart
final title = 'release_candidate'.toTitleCase();
final number = '42'.toIntOrNull();
final maybeUser = Option.fromNullable('Ada');

print(title);
print(number);
print(maybeUser.map((name) => name.toUpperCase()).getOrElse('UNKNOWN'));
```

## Good Defaults

Use SwissArmyKnife where it removes repeated glue:

- `Result` for operations that may fail.
- `Validator` for edge input before it reaches domain code.
- `SafeJson` for map payloads from HTTP or storage.
- `TaskQueue` and `RateLimiter` where concurrency and throughput matter.
- `CircuitBreaker` around unreliable remote dependencies.

## Platform Note

The public barrel import is web-compilable. `Env.load()` reads files and is
VM-only; use `Env.fromMap()` for browser and app-managed configuration.
