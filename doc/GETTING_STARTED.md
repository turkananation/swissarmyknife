# Getting Started

SwissArmyKnife is meant to be boring in the best way: add one dependency,
import one library, and use small utilities that make ordinary Dart code more
explicit.

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

The package exports through one public barrel. Application code should not
import `src/` files directly.

## First Pass

```dart
import 'package:swissarmyknife/swissarmyknife.dart';

void main() {
  final name = 'ada_lovelace'.toTitleCase();
  final parsed = Result.runCatching(() => int.parse('42'));
  final email = Validator<String>.email().validate('ada@example.com');

  print(name);
  print(parsed.getOrElse(0));
  print(email.isSuccess);
}
```

## Use It Where It Helps

SwissArmyKnife is intentionally broad, but each utility is small. Prefer it for
recurring application glue:

- Extension methods that remove local helper functions.
- `Result`, `Option`, and `Either` when success and failure should be explicit.
- Async coordination such as retry, debounce, throttle, and rate limiting.
- Infrastructure helpers such as schema validation, safe JSON access, HTTP
  wrappers, logging, task queues, and circuit breakers.

## Platform Note

The barrel import compiles for web. `Env.load()` is the one VM-only behavior
because browsers cannot read dotenv files. Use `Env.fromMap()` for browser and
Flutter web configuration.
