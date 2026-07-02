## 0.1.0

- Added sealed `Result`, `Option`, and `Either` functional types.
- Added immutable `Pair` and `Triple` tuple types.
- Added reusable `Pipe`, `AsyncPipe`, `Pipeline`, and `AsyncPipeline` helpers.
- Added sync and async memoization helpers with TTL, LRU, custom keys, and
  in-flight async sharing.
- Added `Debouncer`, `Throttler`, stream debounce/throttle, and `retry`.
- Added `RateLimiter` token-bucket and sliding-window implementations.
- Added typed `EventBus`, `GlobalEventBus`, `Disposable`, and `DisposeBag`.
- Added typed `StateMachine` with guarded transitions, listeners, history, and
  `Result` errors.
- Added `Command` and `CommandHistory` helpers with guarded execution,
  undo/redo stacks, and typed failures.
- Added sync and async `Lazy` helpers with cached values, reset, mapping, and
  in-flight async sharing.
- Added `CircuitBreaker` with closed/open/half-open states, cooldowns,
  thresholds, and typed failures.
- Added bounded priority `TaskQueue` with pause/resume, pending cancellation,
  close semantics, and typed task futures.
- Added immutable `TreeNode` traversal helpers and mutable `Graph` utilities
  with BFS, DFS, shortest paths, and cycle detection.
- Added composable `CodecPipeline` helpers with named stages, converter/codec
  adapters, common UTF-8/base64/JSON pipelines, and `Result` error handling.
- Added compiled numeric `ExpressionEvaluator` with variables, constants,
  functions, syntax/evaluation failures, and `Result` fallbacks.
- Added `ReactiveStore` with versioned changes, synchronous subscriptions,
  streams, custom equality, derived selectors, and disposal semantics.
- Added chainable `Validator<T>` with `Result<T, List<String>>` outcomes.
- Added fluent `Http` request helpers with headers, JSON bodies, timeouts,
  retry policy, status validation, and typed `HttpError` failures.
- Added `ApiClientBuilder` with base URI resolution, static/dynamic headers,
  retry/timeout/status policies, typed JSON endpoints, and API error types.
- Added `SafeJson`, in-memory LRU `Cache`, `Env`, benchmark helpers, and
  date range/recurrence utilities.
- Added composable `SchemaValidator` schemas for primitives, objects, lists,
  enums, nullable/refined/custom rules, path-aware issues, and typed parsing.
- Added five-field `CronExpression` and `CronScheduler` with lists, ranges,
  steps, names, next occurrences, manual `runDue`, and timer-backed start/stop.
- Added async-aware `MiddlewarePipeline` with immutable composition,
  short-circuiting, terminal overrides, tap/transform/guard helpers, and
  `Result` failure capture.
- Added configurable `Log` helpers with levels, tags, timestamps, colors, and
  stack traces.
- Deferred crypto helpers; no crypto/UUID dependency is required for this slice.
- Exported the new Tier 2 and non-crypto Tier 3 APIs through the main barrel file.
