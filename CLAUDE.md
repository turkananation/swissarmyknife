# CLAUDE.md - SwissArmyKnife Developer Guide

## Project Overview

SwissArmyKnife is a Dart utility package that exposes extensions, functional
types, async helpers, data utilities, networking helpers, time utilities,
logging, and architecture primitives behind one public import.

```dart
import 'package:swissarmyknife/swissarmyknife.dart';
```

## Source Layout

```text
lib/
  swissarmyknife.dart
  src/
    advanced/
    async/
    data/
    extensions/
    functional/
    logging/
    networking/
    patterns/
    time/
```

Tests mirror the `lib/src/` layout under `test/`.

## Coding Standards

- Public APIs must have dartdoc.
- Export public APIs through `lib/swissarmyknife.dart`.
- Do not import `lib/src/` files from examples or public docs.
- Prefer small typed utilities over framework-scale abstractions.
- Keep dependency count low; `http` is the only runtime dependency in v0.1.0.
- Keep web compilation intact for the public barrel import.

## Verification

```bash
dart run tool/agent/verify.dart quick
dart run tool/agent/verify.dart release
```

`quick` runs format, analysis, and tests. `release` also runs web compilation,
dartdoc, pub publish dry-run, and the Jaspr site build.

## Release Rule

Releases are tag-first. Tag the verified commit as `v<version>` and push the
tag to trigger the GitHub release workflow.
