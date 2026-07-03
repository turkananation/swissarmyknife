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

## Wiki

The wiki source lives in `wiki/`.

If `swissarmyknife.wiki.git` does not exist yet, create the first `Home` page
once through the GitHub wiki UI using `wiki/Home.md`, then run the **Wiki Sync**
workflow. Future wiki updates sync from the committed Markdown files.
