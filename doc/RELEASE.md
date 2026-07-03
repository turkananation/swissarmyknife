# Release Process

SwissArmyKnife releases are tag-first and evidence-driven. The GitHub release
identity is `v<version>`, and the tag must point at the commit that passed the
release gate.

## Local Gate

```bash
dart pub get
dart run tool/agent/verify.dart release
```

The release gate covers formatting, static analysis, tests, web compilation,
dartdoc generation, pub dry-run, and Jaspr site build.

## Tag

```bash
git status --short
git rev-parse HEAD
git tag -a v0.1.0 -m "SwissArmyKnife v0.1.0"
git push origin main
git push origin v0.1.0
```

The `v*` tag triggers the GitHub release workflow. Do not retag a published
version. If a release candidate is wrong, fix forward and tag the next version.

## Publish

After the tag workflow passes and the package owner confirms pub.dev
credentials, publish with:

```bash
dart pub publish
```

Record the final pub.dev URL in the GitHub release notes.
