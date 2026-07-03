# SwissArmyKnife Roadmap

## v0.1.0 - Release Candidate

Goal: publish a professional first public release with a broad but tested Dart
utility surface, strong docs, a Jaspr Pages site, and a tag-first release
workflow.

Included:

- One public barrel import.
- Extensions for strings, numbers, dates, collections, maps, futures, streams,
  URIs, regex, bytes, nullable values, and related helpers.
- `Result`, `Option`, `Either`, tuples, and pipelines.
- Retry, debounce, throttle, rate limiters, validators, event bus, disposal,
  lazy values, state machines, and commands.
- HTTP/API helpers, safe JSON, schema validation, cache, env config, logging,
  date ranges, recurrence, cron, and benchmarking.
- Memoization, circuit breaker, task queue, tree/graph helpers, codec pipeline,
  expression evaluator, reactive store, and middleware pipeline.
- CI, Pages, release workflow, `.pubignore`, and local release verifier.

## v0.2.x - Refinement

- Add more example-led docs based on real user questions.
- Expand edge-case tests around web compilation and platform-specific behavior.
- Add benchmark snapshots for hot extension paths where performance matters.
- Improve API reference cross-links and public dartdoc examples.

## v0.3.x - Adoption

- Publish deeper migration guides for teams replacing local helper libraries.
- Add issue templates and curated "good first issue" backlog.
- Add more cookbook recipes for Flutter, server, CLI, and test code.

## v1.0.0 - Stability

- Freeze the core naming conventions.
- Review public APIs for deprecation needs.
- Confirm no broad breaking changes remain in planned work.
