# Platform Support

SwissArmyKnife targets Dart SDK `^3.12.0` and declares support for Android,
iOS, Linux, macOS, web, and Windows.

## Verified Gates

The release gate runs:

- `dart format --set-exit-if-changed`
- `dart analyze`
- `dart test`
- `dart compile js` against the public example import
- `dart doc` into a temporary directory
- `dart pub publish --dry-run`
- Jaspr documentation site build

## Browser Builds

The public barrel import is web-compilable. `Env.load()` is intentionally
VM-only because browsers cannot read local dotenv files. Use `Env.fromMap()` in
browser builds:

```dart
Env.fromMap({
  'API_BASE_URL': 'https://api.example.com',
});
```

## HTTP

Networking is built on `package:http`, which provides platform-specific client
behavior. Use the default `Http` helpers for common cases, or inject your own
`http.Client` where an application needs lifecycle control.
