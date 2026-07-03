# Release Checklist

Releases are tag-first.

```bash
dart pub get
dart run tool/agent/verify.dart release
git tag -a v0.1.0 -m "SwissArmyKnife v0.1.0"
git push origin main
git push origin v0.1.0
```

The release gate covers formatting, analysis, tests, web compilation, dartdoc,
pub publish dry-run, and Jaspr site build.

Do not move a published tag. Fix forward with the next version.
