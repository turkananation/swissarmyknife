# AGENTS.md - SwissArmyKnife

## Project Contract

SwissArmyKnife is a Dart package with one public entrypoint:

```dart
import 'package:swissarmyknife/swissarmyknife.dart';
```

Keep implementation files under `lib/src/` and export public APIs through
`lib/swissarmyknife.dart`.

## Documentation Lookup

When a task asks about a library, framework, SDK, API, CLI, or cloud service,
use the `ctx7` CLI first:

```bash
npx ctx7@latest library <name> "<user question>"
npx ctx7@latest docs /org/project "<user question>"
```

Use the resolved Context7 library ID. Do not send secrets in queries.

## Release Rule

Releases are tag-first. The release identity is `v<version>`, and the tag must
point at the exact commit that passed the release gate.

```bash
dart run tool/agent/verify.dart release
git tag -a v0.1.0 -m "SwissArmyKnife v0.1.0"
git push origin main
git push origin v0.1.0
```

Never move a published tag. Fix forward with the next version.

## Verification

Quick gate:

```bash
dart run tool/agent/verify.dart quick
```

Release gate:

```bash
dart run tool/agent/verify.dart release
```

The release gate runs formatting, analysis, tests, web compilation, dartdoc,
pub dry-run, and the Jaspr Pages site build.
