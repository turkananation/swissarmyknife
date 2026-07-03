# API Guide

This guide maps the public surface exported by
`package:swissarmyknife/swissarmyknife.dart`.

## Extensions

| Module | Use for |
| --- | --- |
| `StringKnife` and advanced string helpers | Case conversion, slugging, truncation, masking, extraction, similarity |
| `NumKnife`, `IntMathKnife`, `DoubleKnife` | Compact numbers, ranges, duration shortcuts, precision, math helpers |
| `DateTimeKnife` and duration helpers | Date boundaries, comparisons, formatting, human-readable durations |
| Collection helpers | Grouping, chunking, sorting, zipping, partitioning, safe lookups |
| Map helpers | Deep merge, nested paths, query strings, key/value transforms |
| Future and stream helpers | Timeouts, delayed work, error suppression, debounce, throttle |
| URI, RegExp, Set, Uint8List helpers | Query mutation, named captures, set operations, hex/base64/UTF-8 utilities |

## Functional Types

`Result<T, E>` is for explicit success/failure. `Option<T>` is for nullable
flows. `Either<L, R>` is for dual-typed results where both branches matter.
`Pair` and `Triple` hold small typed tuples. `Pipe`, `Pipeline`, and async
variants make transformation chains reusable.

## Async and Patterns

`Debouncer`, `Throttler`, `retry`, and `RateLimiter` cover common coordination
needs. `Validator`, `EventBus`, `DisposeBag`, `Lazy`, `StateMachine`, and
`CommandHistory` cover application patterns without pulling in a framework.

## Data, Time, Networking, and Logging

`SafeJson` and `SchemaValidator` make untrusted maps safer to consume.
`Cache` provides in-memory LRU behavior. `Env` loads VM dotenv files or
application-provided maps. `Http` and `ApiClientBuilder` wrap `package:http`
with typed results, retry policy, status validation, JSON helpers, headers, and
timeouts. Time utilities include `DateRange`, `Recurrence`, `CronExpression`,
`CronScheduler`, and benchmarking helpers.

## Advanced Utilities

Use memoization for repeatable expensive work, `CircuitBreaker` for fail-fast
protection, `TaskQueue` for bounded concurrency, tree and graph helpers for
traversal, `CodecPipeline` for conversion chains, `ExpressionEvaluator` for
numeric expressions, `ReactiveStore` for small synchronous state containers,
and `MiddlewarePipeline` for composable request or task processing.
