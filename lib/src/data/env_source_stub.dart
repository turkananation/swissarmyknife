/// Browser-safe environment access for [Env].
library;

/// Dotenv files are not available in browser builds.
List<String> readEnvFile(String path) {
  throw UnsupportedError(
    'Env.load is only available on Dart VM platforms. Use Env.fromMap in '
    'browser builds.',
  );
}

/// Browser builds do not expose a process environment.
String? platformEnvironmentValue(String key) => null;
