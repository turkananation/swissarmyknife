---
title: Platform Support
description: Supported targets and the verification gates behind those claims.
---

SwissArmyKnife targets Dart SDK `^3.12.0` and declares support for Android,
iOS, Linux, macOS, web, and Windows.

## Release Gates

- Formatting check
- Static analysis
- Unit tests
- Web compilation through the public example import
- Dartdoc generation
- Pub publish dry-run
- Jaspr site build

## Browser Builds

The public barrel import is web-compilable. `Env.load()` reads dotenv files and
therefore only works on Dart VM platforms. Use `Env.fromMap()` in browser code.

```dart
Env.fromMap({
  'API_BASE_URL': 'https://api.example.com',
});
```
