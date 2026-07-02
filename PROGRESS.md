# 🔪 SwissArmyKnife — Progress Tracker

> **Last Updated**: 2026-06-29
> **Current Version**: 0.1.0-dev

---

## Legend
- ✅ Complete (implemented + tested)
- 🔨 In Progress
- ⬜ Not Started
- 🧪 Implemented, needs tests

---

## Tier 1: 🟢 Easy — Pure Dart Extensions

| # | Module | Status | File | Tests |
|---|--------|--------|------|-------|
| 1 | String Extensions | ✅ | `lib/src/extensions/string_extensions.dart` | `test/extensions/string_extensions_test.dart` |
| 2 | Num Extensions | ✅ | `lib/src/extensions/num_extensions.dart` | `test/extensions/num_extensions_test.dart` |
| 3 | DateTime Extensions | ✅ | `lib/src/extensions/datetime_extensions.dart` | `test/extensions/datetime_extensions_test.dart` |
| 4 | Collection Extensions | ✅ | `lib/src/extensions/collection_extensions.dart` | `test/extensions/collection_extensions_test.dart` |
| 5 | Map Extensions | ✅ | `lib/src/extensions/map_extensions.dart` | `test/extensions/map_extensions_test.dart` |
| 6 | Bool Extensions | ✅ | `lib/src/extensions/bool_extensions.dart` | `test/extensions/bool_extensions_test.dart` |
| 7 | Type Converters / Scope | ✅ | `lib/src/extensions/scope_functions.dart` | `test/extensions/scope_functions_test.dart` |
| 7.1 | Set Extensions | ✅ | `lib/src/extensions/set_extensions.dart` | `test/extensions/set_extensions_test.dart` |
| 7.2 | RegExp Extensions | ✅ | `lib/src/extensions/regexp_extensions.dart` | `test/extensions/regexp_extensions_test.dart` |
| 7.3 | Uint8List Extensions | ✅ | `lib/src/extensions/uint8list_extensions.dart` | `test/extensions/uint8list_extensions_test.dart` |
| 7.4 | Future Extensions | ✅ | `lib/src/extensions/future_extensions.dart` | `test/extensions/future_extensions_test.dart` |
| 7.5 | Stream Extensions | ✅ | `lib/src/extensions/stream_extensions.dart` | `test/extensions/stream_extensions_test.dart` |
| 7.6 | Double Extensions | ✅ | `lib/src/extensions/double_extensions.dart` | `test/extensions/double_extensions_test.dart` |
| 7.7 | Int Math Extensions | ✅ | `lib/src/extensions/int_math_extensions.dart` | `test/extensions/int_math_extensions_test.dart` |
| 7.8 | String Iterable Extensions | ✅ | `lib/src/extensions/string_iterable_extensions.dart` | `test/extensions/string_iterable_extensions_test.dart` |
| 7.9 | Comparable Iterable Extensions | ✅ | `lib/src/extensions/comparable_iterable_extensions.dart` | `test/extensions/comparable_iterable_extensions_test.dart` |
| 7.10 | MapEntry Extensions | ✅ | `lib/src/extensions/map_entry_extensions.dart` | `test/extensions/map_entry_extensions_test.dart` |
| 7.11 | Duration Extra Extensions | ✅ | `lib/src/extensions/duration_extra_extensions.dart` | `test/extensions/duration_extra_extensions_test.dart` |
| 7.12 | Nullable Extensions | ✅ | `lib/src/extensions/nullable_extensions.dart` | `test/extensions/nullable_extensions_test.dart` |


## Tier 2: 🟡 Medium — Functional & Async Patterns

| # | Module | Status | File | Tests |
|---|--------|--------|------|-------|
| 8 | Result Type | ✅ | `lib/src/functional/result.dart` | `test/functional/result_test.dart` |
| 9 | Option Type | ✅ | `lib/src/functional/option.dart` | `test/functional/option_test.dart` |
| 10 | Either Type | ✅ | `lib/src/functional/either.dart` | `test/functional/either_test.dart` |
| 11 | Debouncer & Throttler | ✅ | `lib/src/async/debouncer.dart`, `lib/src/async/throttler.dart` | `test/async/debouncer_test.dart` |
| 12 | Retry Utility | ✅ | `lib/src/async/retry.dart` | `test/async/retry_test.dart` |
| 13 | Rate Limiter | ✅ | `lib/src/async/rate_limiter.dart` | `test/async/rate_limiter_test.dart` |
| 14 | Tuple Types | ✅ | `lib/src/functional/tuple.dart` | `test/functional/tuple_test.dart` |
| 15 | Validators | ✅ | `lib/src/patterns/validator.dart` | `test/patterns/validator_test.dart` |
| 16 | Event Bus | ✅ | `lib/src/patterns/event_bus.dart` | `test/patterns/event_bus_test.dart` |
| 17 | Disposable Pattern | ✅ | `lib/src/patterns/disposable.dart` | `test/patterns/disposable_test.dart` |

## Tier 3: 🟠 Advanced — IO, Networking, Platform

| # | Module | Status | File | Tests |
|---|--------|--------|------|-------|
| 18 | HTTP Client Wrapper | ✅ | `lib/src/networking/http_client.dart` | `test/networking/http_client_test.dart` |
| 19 | SafeJson | ✅ | `lib/src/data/safe_json.dart` | `test/data/safe_json_test.dart` |
| 20 | Logger | ✅ | `lib/src/logging/logger.dart` | `test/logging/logger_test.dart` |
| 21 | Cache Manager | ✅ | `lib/src/data/cache_manager.dart` | `test/data/cache_manager_test.dart` |
| 22 | Benchmark Utilities | ✅ | `lib/src/time/benchmark.dart` | `test/time/benchmark_test.dart` |
| 23 | Environment Config | ✅ | `lib/src/data/env_config.dart` | `test/data/env_config_test.dart` |
| 24 | Crypto Helpers | ⬜ | `lib/src/crypto/crypto_helpers.dart` | `test/crypto/crypto_helpers_test.dart` |
| 25 | Date Range & Recurrence | ✅ | `lib/src/time/date_range.dart` | `test/time/date_range_test.dart` |

## Tier 4: 🔴 Hard — Architecture & Patterns (v0.5.0)

| # | Module | Status | File | Tests |
|---|--------|--------|------|-------|
| 26 | Pipeline/Pipe Operator | ✅ | `lib/src/functional/pipeline.dart` | `test/functional/pipeline_test.dart` |
| 27 | Memoization | ✅ | `lib/src/advanced/memoize.dart` | `test/advanced/memoize_test.dart` |
| 28 | State Machine | ✅ | `lib/src/patterns/state_machine.dart` | `test/patterns/state_machine_test.dart` |
| 29 | Command Pattern | ✅ | `lib/src/patterns/command.dart` | `test/patterns/command_test.dart` |
| 30 | Lazy<T> | ✅ | `lib/src/patterns/lazy.dart` | `test/patterns/lazy_test.dart` |
| 31 | Circuit Breaker | ✅ | `lib/src/advanced/circuit_breaker.dart` | `test/advanced/circuit_breaker_test.dart` |
| 32 | Task Queue | ✅ | `lib/src/advanced/task_queue.dart` | `test/advanced/task_queue_test.dart` |
| 33 | Tree & Graph Utils | ✅ | `lib/src/advanced/tree_utils.dart` | `test/advanced/tree_utils_test.dart` |
| 34 | Codec Pipeline | ✅ | `lib/src/advanced/codec_pipeline.dart` | `test/advanced/codec_pipeline_test.dart` |
| 35 | Expression Evaluator | ✅ | `lib/src/advanced/expression_evaluator.dart` | `test/advanced/expression_evaluator_test.dart` |

## Tier 5: 🟣 Boss Level — Differentiators (v1.0.0)

| # | Module | Status | File | Tests |
|---|--------|--------|------|-------|
| 36 | API Client Builder | ✅ | `lib/src/networking/api_client_builder.dart` | `test/networking/api_client_builder_test.dart` |
| 37 | Reactive Store | ✅ | `lib/src/advanced/reactive_store.dart` | `test/advanced/reactive_store_test.dart` |
| 38 | Schema Validator | ✅ | `lib/src/data/schema_validator.dart` | `test/data/schema_validator_test.dart` |
| 39 | Cron Scheduler | ✅ | `lib/src/time/cron_scheduler.dart` | `test/time/cron_scheduler_test.dart` |
| 40 | Middleware Pipeline | ✅ | `lib/src/advanced/middleware_pipeline.dart` | `test/advanced/middleware_pipeline_test.dart` |

---

## Summary

| Tier | Total | ✅ Done | 🔨 WIP | ⬜ Todo |
|------|-------|---------|--------|---------|
| 🟢 Tier 1 | 19 | 19 | 0 | 0 |
| 🟡 Tier 2 | 10 | 10 | 0 | 0 |
| 🟠 Tier 3 | 8 | 7 | 0 | 1 |
| 🔴 Tier 4 | 10 | 10 | 0 | 0 |
| 🟣 Tier 5 | 5 | 5 | 0 | 0 |
| **Total** | **52** | **51** | **0** | **1** |
