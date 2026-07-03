/// Dart VM environment and dotenv file access for [Env].
library;

import 'dart:io';

/// Reads a dotenv-style file as lines.
List<String> readEnvFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    throw ArgumentError.value(path, 'path', 'File does not exist.');
  }
  return file.readAsLinesSync();
}

/// Returns a process environment value by [key].
String? platformEnvironmentValue(String key) => Platform.environment[key];
