/// SwissArmyKnife verification runner.
///
/// Usage:
///   dart run tool/agent/verify.dart quick
///   dart run tool/agent/verify.dart release
library;

import 'dart:async';
import 'dart:io';

Future<void> main(List<String> args) async {
  final mode = args.isEmpty ? 'quick' : args.first;

  switch (mode) {
    case 'quick':
      await _quick();
    case 'site':
      await _site();
    case 'release':
      await _release();
    default:
      stderr.writeln('Unknown mode: $mode');
      stderr.writeln('Expected one of: quick, site, release');
      exitCode = 64;
  }
}

Future<void> _quick() async {
  await _run('format', 'dart', [
    'format',
    '--output=none',
    '--set-exit-if-changed',
    'lib',
    'test',
    'example',
    'tool',
  ]);
  await _run('analyze', 'dart', ['analyze']);
  await _run('test', 'dart', ['test']);
}

Future<void> _site() async {
  await _run('site pub get', 'dart', ['pub', 'get'], workingDirectory: 'site');
  await _run('site format', 'dart', [
    'format',
    '--output=none',
    '--set-exit-if-changed',
    'lib',
  ], workingDirectory: 'site');
  await _run('site analyze', 'dart', ['analyze'], workingDirectory: 'site');
  await _run('jaspr cli', 'dart', ['pub', 'global', 'activate', 'jaspr_cli']);
  await _run('jaspr build', 'dart', [
    'pub',
    'global',
    'run',
    'jaspr_cli:jaspr',
    'build',
    '--verbose',
    '--sitemap-domain',
    'https://turkananation.github.io/swissarmyknife',
  ], workingDirectory: 'site');
}

Future<void> _release() async {
  await _quick();
  await _webCompile();
  await _dartDoc();
  await _run('publish dry-run', 'dart', ['pub', 'publish', '--dry-run']);
  await _site();
}

Future<void> _webCompile() async {
  final temp = Directory.systemTemp.createTempSync('sak-web-compile-');
  try {
    await _run('web compile', 'dart', [
      'compile',
      'js',
      '-O2',
      '-o',
      '${temp.path}/example.js',
      'example/swissarmyknife_example.dart',
    ]);
  } finally {
    temp.deleteSync(recursive: true);
  }
}

Future<void> _dartDoc() async {
  final temp = Directory.systemTemp.createTempSync('sak-dartdoc-');
  try {
    await _run('dartdoc', 'dart', ['doc', '--output', temp.path]);
  } finally {
    temp.deleteSync(recursive: true);
  }
}

Future<void> _run(
  String name,
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  stdout.writeln('==> $name');
  stdout.writeln([executable, ...arguments].join(' '));

  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
  );
  final code = await process.exitCode;
  if (code != 0) {
    throw ProcessException(executable, arguments, '$name failed', code);
  }
}
