---
title: v0.1.0 Release
description: The release checklist and tag-first workflow for SwissArmyKnife.
---

SwissArmyKnife releases are tagged from the start. The release identity is
`v<version>`, and the tag must point at the commit that passed the release gate.

## Verify

```bash
dart pub get
dart run tool/agent/verify.dart release
```

## Tag

```bash
git status --short
git tag -a v0.1.0 -m "SwissArmyKnife v0.1.0"
git push origin main
git push origin v0.1.0
```

## Publish

After the tag workflow passes and pub.dev credentials are confirmed:

```bash
dart pub publish
```

## Boundaries

The pub archive excludes agent files, GitHub workflows, the Jaspr site source,
the local wiki source, generated docs, and release tooling. Public package docs
remain in `README.md`, `CHANGELOG.md`, `LICENSE`, `example/`, `lib/`, `test/`,
and `doc/`.
