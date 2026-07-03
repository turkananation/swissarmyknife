# Platform Support

SwissArmyKnife targets Dart SDK `^3.12.0` and declares support for Android,
iOS, Linux, macOS, web, and Windows.

The public barrel import is web-compilable. `Env.load()` reads dotenv files and
is only available on Dart VM platforms. Use `Env.fromMap()` for browser or
app-managed configuration.
