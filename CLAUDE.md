# CLAUDE.md — SwissArmyKnife Developer Guide

## Project Overview
SwissArmyKnife is a comprehensive Dart utility package providing 40+ modules
covering extensions, functional types, networking, caching, state machines,
and architectural patterns — all behind a single import.

## Architecture
```
lib/
  swissarmyknife.dart          # Barrel file — single entry point
  src/
    extensions/                # Tier 1 — Pure Dart extensions
      string_extensions.dart
      num_extensions.dart
      datetime_extensions.dart
      collection_extensions.dart
      map_extensions.dart
      bool_extensions.dart
      type_converters.dart
    functional/                # Tier 2 — Functional & async patterns
      result.dart
      option.dart
      either.dart
      tuple.dart
      pipeline.dart
    async/                     # Tier 2-3 — Async utilities
      debouncer.dart
      throttler.dart
      retry.dart
      rate_limiter.dart
    patterns/                  # Tier 2-4 — Design patterns
      event_bus.dart
      disposable.dart
      validator.dart
      command.dart
      state_machine.dart
      lazy.dart
    networking/                # Tier 3 — HTTP & networking
      http_client.dart
      api_client_builder.dart
    data/                      # Tier 3 — Data utilities
      safe_json.dart
      cache_manager.dart
      env_config.dart
      schema_validator.dart
    crypto/                    # Tier 3 — Crypto helpers
      crypto_helpers.dart
    logging/                   # Tier 3 — Logger
      logger.dart
    time/                      # Tier 3 — Time utilities
      benchmark.dart
      date_range.dart
      cron_scheduler.dart
    advanced/                  # Tier 4-5 — Advanced
      memoize.dart
      circuit_breaker.dart
      task_queue.dart
      tree_utils.dart
      codec_pipeline.dart
      expression_evaluator.dart
      reactive_store.dart
      middleware_pipeline.dart
```

## Coding Standards
- Every public API **must** have a dartdoc comment with an example
- Every file **must** export only through the barrel file
- Use `extension` types for all Dart type extensions
- Prefer `const` constructors wherever possible
- Every module **must** have corresponding tests in `test/`
- Follow effective Dart style: https://dart.dev/effective-dart
- APIs should be **fluent** and **chainable** wherever possible
- Return `Result<T, E>` instead of throwing exceptions in library code
- Use named parameters for optional configuration
- Provide sensible defaults for everything

## Testing
```bash
dart test                    # Run all tests
dart test test/extensions/   # Run extension tests only
dart analyze                 # Static analysis
```

## Dependencies Policy
- **Minimize dependencies** — prefer pure Dart implementations
- Only allowed external deps: `crypto`, `http`, `uuid`
- Everything else is hand-rolled

## API Design Principles
1. **One import**: `import 'package:swissarmyknife/swissarmyknife.dart';`
2. **Zero config**: Everything works out of the box
3. **Progressive disclosure**: Simple API surface, advanced options via named params
4. **Type safe**: Leverage Dart's type system to prevent runtime errors
5. **Composable**: Every utility should compose with others
