# SwissArmyKnife Progress

Last updated: 2026-07-03
Current release boundary: v0.1.0

## v0.1.0 Status

The v0.1.0 package surface is implemented and covered by the release gate.

| Area | Status |
| --- | --- |
| Extensions | Complete |
| Functional types and pipelines | Complete |
| Async helpers | Complete |
| Pattern helpers | Complete |
| Data, networking, time, and logging | Complete |
| Advanced utilities | Complete |
| Public docs | Complete |
| Jaspr Pages site | Complete |
| CI, Pages, and tag release workflows | Complete |

## Verification

Use the local release gate before tagging:

```bash
dart run tool/agent/verify.dart release
```

The gate covers formatting, static analysis, tests, web compilation, dartdoc,
pub publish dry-run, and the Jaspr site build.

## Open Release Tasks

- Push the verified commit to `main`.
- Create and push the annotated `v0.1.0` tag.
- Confirm GitHub Actions release and Pages workflows pass remotely.
- Publish to pub.dev from an authenticated account.
