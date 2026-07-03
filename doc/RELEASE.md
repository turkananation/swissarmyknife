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

## Wiki

The canonical wiki source lives in `wiki/`. GitHub only exposes
`swissarmyknife.wiki.git` after the first wiki page has been created once in
the GitHub UI. After that one-time bootstrap, the **Wiki Sync** workflow keeps
the live GitHub wiki aligned with the committed Markdown files.

To bootstrap:

1. Open <https://github.com/turkananation/swissarmyknife/wiki>.
2. Create the first `Home` page with the contents of `wiki/Home.md`.
3. Run the **Wiki Sync** workflow from GitHub Actions.
