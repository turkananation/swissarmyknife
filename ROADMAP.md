# 🔪 SwissArmyKnife — Feature Roadmap

> **Version Target**: 0.1.0 (Tiers 1-3) → 0.5.0 (Tier 4) → 1.0.0 (Tier 5)
> **Created**: 2026-06-26

---

## Tier 1: 🟢 Easy — Pure Dart Extensions
*Zero dependencies. Just beautiful extension methods that feel native.*

### 1. String Extensions (`StringKnife`)
- `capitalize()` — Capitalize first letter
- `capitalizeEach()` — Capitalize first letter of each word
- `toTitleCase()` — Smart title case (respects articles, prepositions)
- `toCamelCase()` — Convert to camelCase
- `toSnakeCase()` — Convert to snake_case
- `toKebabCase()` — Convert to kebab-case
- `toPascalCase()` — Convert to PascalCase
- `slugify()` — URL-safe slug
- `truncate(maxLength, {ellipsis})` — Truncate with ellipsis
- `removeHtml()` — Strip HTML tags
- `reverse()` — Reverse string
- `mask({visibleCount, maskChar})` — Mask sensitive data (credit cards, etc.)
- `initials({count})` — Extract initials from name
- `isBlank` / `isNotBlank` — Null-safe blank checks
- `isEmail` — Email validation
- `isUrl` — URL validation
- `isNumeric` — Numeric string check
- `isAlpha` — Alphabetic check
- `isAlphanumeric` — Alphanumeric check
- `wordCount` — Count words
- `charFrequency()` — Character frequency map
- `wrap(prefix, suffix)` — Wrap string
- `unwrap(prefix, suffix)` — Unwrap string
- `toIntOrNull()` / `toDoubleOrNull()` — Safe parsing
- `repeat(n, {separator})` — Repeat with separator
- `replaceMultiple(Map<String, String>)` — Multiple replacements in one pass
- `containsAny(List<String>)` — Check if contains any of patterns
- `equalsIgnoreCase(other)` — Case-insensitive comparison

### 2. Num Extensions (`NumKnife`)
- `toCurrency({symbol, decimals, locale})` — Format as currency
- `toFileSizeString()` — Bytes to "1.5 MB"
- `toOrdinal()` — 1 → "1st", 2 → "2nd"
- `toRoman()` — 4 → "IV"
- `toPercentString({decimals})` — 0.85 → "85%"
- `isBetween(min, max)` — Range check (inclusive)
- `isPositive` / `isNegative` / `isZero` — Sign checks
- `roundTo(decimals)` — Round to N decimal places
- `duration` shortcuts:
  - `.milliseconds` → `Duration(milliseconds: n)`
  - `.seconds` → `Duration(seconds: n)`
  - `.minutes` → `Duration(minutes: n)`
  - `.hours` → `Duration(hours: n)`
  - `.days` → `Duration(days: n)`
- `coerceIn(min, max)` — Coerce to range
- `coerceAtLeast(min)` / `coerceAtMost(max)` — One-sided coerce
- `toCompactString()` — 1200 → "1.2K", 1500000 → "1.5M"

### 3. DateTime Extensions (`DateTimeKnife`)
- `isToday` / `isTomorrow` / `isYesterday` — Date checks
- `isWeekend` / `isWeekday` — Day type checks
- `isSameDay(other)` / `isSameMonth(other)` / `isSameYear(other)`
- `startOfDay` / `endOfDay` — Midnight boundaries
- `startOfWeek({startDay})` / `endOfWeek({startDay})` — Week boundaries
- `startOfMonth` / `endOfMonth` — Month boundaries
- `startOfYear` / `endOfYear` — Year boundaries
- `daysInMonth` — Days in current month
- `timeAgo()` — "2 hours ago", "yesterday", "3 months ago"
- `timeUntil()` — "in 5 minutes", "tomorrow"
- `format(pattern)` — Simple pattern-based formatting (yyyy, MM, dd, HH, mm, ss)
- `addBusinessDays(days)` — Add weekdays only
- `isLeapYear` — Leap year check
- `age` — Calculate age as Duration
- `quarter` — Get quarter (1-4)
- `weekOfYear` — ISO week number
- `copyWith({year, month, day, ...})` — Immutable copy with changes
- `toDateOnly()` — Strip time component
- `isBetween(start, end)` — Range check

### 4. Collection Extensions (`IterableKnife`, `ListKnife`)
- `groupBy(key)` — Group into Map
- `sortedBy(key)` / `sortedByDescending(key)` — Non-mutating sort
- `distinctBy(key)` — Unique by selector
- `chunk(size)` — Split into chunks
- `firstWhereOrNull(test)` / `lastWhereOrNull(test)` — Null-safe find
- `flatten()` — Flatten nested iterables
- `zipWith(other, combine)` — Zip two lists
- `zip(other)` — Zip into pairs
- `rotate(positions)` — Rotate elements
- `interleave(other)` — Alternate elements
- `partition(test)` — Split into (matching, notMatching)
- `frequencyMap()` — Count occurrences
- `minBy(key)` / `maxBy(key)` — Min/max by selector
- `sumBy(key)` / `averageBy(key)` — Aggregation by selector
- `forEachIndexed(action)` — forEach with index
- `mapIndexed(transform)` — map with index
- `whereIndexed(test)` — where with index
- `sample({count, random})` — Random sample
- `shuffled({random})` — Non-mutating shuffle
- `compact()` — Remove nulls (typed)
- `takeWhileInclusive(test)` — takeWhile but includes last match
- `separatedBy(separator)` — Insert separator between elements

### 5. Map Extensions (`MapKnife`)
- `deepMerge(other)` — Deep recursive merge
- `pick(keys)` — Keep only specified keys
- `omit(keys)` — Remove specified keys
- `flattenKeys({separator})` — Flatten nested maps: `{'a': {'b': 1}}` → `{'a.b': 1}`
- `unflattenKeys({separator})` — Reverse of flatten
- `invert()` — Swap keys and values
- `getNestedValue(path)` — Dot-notation access: `map.getNestedValue('user.name')`
- `setNestedValue(path, value)` — Dot-notation set
- `toQueryString()` — Convert to URL query string
- `fromQueryString(string)` — Parse URL query string
- `filterKeys(test)` / `filterValues(test)` — Filter by key or value
- `mapKeys(transform)` / `mapValues(transform)` — Transform keys or values
- `whereNotNull()` — Remove null values

### 6. Bool Extensions (`BoolKnife`)
- `toInt()` — true → 1, false → 0
- `toYesNo()` — true → "Yes", false → "No"
- `toOnOff()` — true → "On", false → "Off"
- `toEnabledDisabled()` — true → "Enabled", false → "Disabled"
- `when({required T isTrue, required T isFalse})` — Ternary helper
- `ifTrue(action)` / `ifFalse(action)` — Conditional execution

### 7. Type Converters (`ScopeKnife`)
Kotlin-inspired scope functions on all Objects:
- `let(transform)` — Transform and return: `value.let((v) => v * 2)`
- `also(action)` — Side effect, return original: `value.also(print)`
- `takeIf(predicate)` — Return value if predicate true, else null
- `takeUnless(predicate)` — Return value if predicate false, else null
- `tryCast<T>()` — Safe cast, returns T? instead of throwing
- `isType<T>()` — Type check shortcut

---

## Tier 2: 🟡 Medium — Functional & Async Patterns
*Powerful abstractions that eliminate boilerplate.*

### 8. Result Type
`Result<T, E>` — Explicit success/failure without try-catch:
- `Result.success(value)` / `Result.failure(error)`
- `map()`, `flatMap()`, `mapError()`
- `fold(onSuccess, onFailure)` — Pattern match
- `getOrElse(defaultValue)`, `getOrThrow()`
- `isSuccess` / `isFailure`
- `toOption()` — Convert to Option
- `Result.runCatching(() => ...)` — Wrap throwing code
- `Result.combine([results])` — Combine multiple results

### 9. Option Type
`Option<T>` — Null-safety on steroids:
- `Option.some(value)` / `Option.none()`
- `Option.fromNullable(value?)` — Wrap nullable
- `map()`, `flatMap()`, `filter()`
- `getOrElse(default)`, `getOrThrow()`
- `isSome` / `isNone`
- `toResult(error)` — Convert to Result
- `fold(onSome, onNone)` — Pattern match
- `zip(other)` — Combine two options

### 10. Either Type
`Either<L, R>` — Dual-typed returns:
- `Either.left(value)` / `Either.right(value)`
- `fold(onLeft, onRight)`
- `mapLeft()`, `mapRight()`, `flatMap()`
- `swap()` — Swap left and right
- `isLeft` / `isRight`
- `getLeftOrElse()` / `getRightOrElse()`
- `toResult()` — Convert to Result

### 11. Debouncer & Throttler
- `Debouncer(duration)` — Call after delay, reset on new call
  - `.run(action)` — Debounce an action
  - `.cancel()` — Cancel pending
  - `.isActive` — Check if pending
  - `.dispose()` — Cleanup
- `Throttler(duration)` — Call at most once per duration
  - `.run(action)` — Throttle an action
  - `.cancel()` / `.dispose()`
- Stream extensions: `.debounce(duration)`, `.throttle(duration)`

### 12. Retry Utility
- `retry(action, {maxAttempts, delay, backoff, jitter, retryIf, onRetry})`
- Backoff strategies: `constant`, `linear`, `exponential`
- Custom retry conditions via `retryIf` predicate
- Progress callback via `onRetry`
- Returns `Result<T, E>`

### 13. Rate Limiter
- `RateLimiter.tokenBucket(maxTokens, refillRate)`
- `RateLimiter.slidingWindow(maxRequests, windowDuration)`
- `.acquire()` — Returns bool or waits
- `.tryAcquire()` — Non-blocking
- `.remaining` — Tokens/requests remaining

### 14. Tuple Types
- `Pair<A, B>` — Two values with `.first`, `.second`
- `Triple<A, B, C>` — Three values with `.first`, `.second`, `.third`
- `mapFirst()`, `mapSecond()`, `mapThird()`
- Destructuring via records pattern matching
- `toList()`, `toMap()`

### 15. Validators
Chainable, composable validation:
- `Validator<String>.email()`, `.url()`, `.minLength()`, `.maxLength()`
- `.matches(regex)`, `.contains(substring)`
- `.required()`, `.numeric()`, `.alpha()`
- `Validator<num>.min()`, `.max()`, `.positive()`
- `.validate(input)` → `Result<T, List<String>>`
- `.and(other)`, `.or(other)` — Combine validators
- Custom validators via `Validator.custom(test, message)`

### 16. Event Bus
- `EventBus()` — Create bus instance
- `.fire<T>(event)` — Fire typed event
- `.on<T>()` — Stream of typed events
- `.onWhere<T>(test)` — Filtered stream
- `.once<T>()` — Listen once, auto-cancel
- `.dispose()` — Cleanup all
- `GlobalEventBus.instance` — Singleton for app-wide events

### 17. Disposable Pattern
- `Disposable` mixin — adds `.dispose()` contract
- `DisposeBag` — collect disposables
  - `.add(StreamSubscription)` / `.addTimer(Timer)` / `.addController(StreamController)`
  - `.disposeAll()` — Clean up everything
  - `.autoDispose(resource)` — Generic disposal

---

## Tier 3: 🟠 Advanced — IO, Networking, Platform
*Production-ready utilities for real applications.*

### 18. HTTP Client Wrapper
Fluent API wrapping `package:http`:
```dart
final response = await knife.http
    .get('https://api.example.com/users')
    .withHeaders({'Authorization': 'Bearer token'})
    .withTimeout(5.seconds)
    .withRetry(3, backoff: exponential)
    .execute();
// Returns Result<Response, HttpError>
```

### 19. SafeJson
Null-safe deep JSON access:
```dart
final name = json.at('user.profile.name').asStringOr('Unknown');
final age = json.at('user.age').asIntOr(0);
final tags = json.at('user.tags').asListOr<String>([]);
```

### 20. Logger
Beautiful console logger:
- `Log.d('Debug message')`, `.i()`, `.w()`, `.e()`, `.wtf()`
- Colored output with emoji: 🐛 📘 ⚠️ ❌ 💀
- Stack trace on errors
- Tag filtering: `Log.d('message', tag: 'HTTP')`
- Log levels: `LogLevel.debug`, `info`, `warning`, `error`, `fatal`
- Configurable: `Log.config(minLevel: LogLevel.info, showTimestamp: true)`

### 21. Cache Manager
In-memory LRU cache:
- `Cache<K, V>(maxSize: 100)`
- `.get(key, orElse: () => compute(), ttl: 5.minutes)`
- `.put(key, value, {ttl})`
- `.invalidate(key)` / `.invalidateAll()`
- `.containsKey(key)` / `.size` / `.keys`
- `.stats` — Hit/miss ratio

### 22. Benchmark Utilities
- `benchmark(action, {iterations})` — Returns `BenchmarkResult` with timing
- `benchmarkAsync(action)` — For async code
- `compareBenchmarks({'name': action})` — Side-by-side comparison table
- `BenchmarkResult` — `.elapsed`, `.perIteration`, `.opsPerSecond`

### 23. Environment Config
- `Env.load('.env')` — Load from file
- `Env.get('API_KEY')` — Get required (throws if missing)
- `Env.getOrNull('OPTIONAL')` — Get optional
- `Env.getOr('KEY', 'default')` — Get with default
- `Env.getInt()`, `.getBool()`, `.getDouble()` — Typed access
- `Env.require(['API_KEY', 'DB_URL'])` — Validate all required present

### 24. Crypto Helpers
- `'hello'.md5` — MD5 hash
- `'hello'.sha256` — SHA-256 hash
- `'hello'.sha512` — SHA-512 hash
- `'hello'.hmacSha256(key)` — HMAC
- `generateUuid()` / `generateUuidV4()` — UUID generation
- `randomString(length, {charset})` — Random string
- `secureRandomBytes(length)` — Crypto-secure random bytes
- `'hello'.toBase64()` / `'aGVsbG8='.fromBase64()` — Base64

### 25. Date Range & Recurrence
- `DateRange(start, end)`
- `.contains(date)`, `.overlaps(other)`, `.intersection(other)`
- `.duration`, `.days`, `.toList()`
- `.iterate({step})` — Generate dates in range
- `Recurrence.daily()`, `.weekly()`, `.monthly()`, `.yearly()`
- `.occurrences(from, count)` — Generate occurrences
- `.nextAfter(date)` — Next occurrence after date

---

## Tier 4: 🔴 Hard — Architecture & Patterns (v0.5.0)

### 26. Pipeline/Pipe Operator
### 27. Memoization
### 28. Finite State Machine
### 29. Command Pattern (undo/redo)
### 30. Lazy<T>
### 31. Circuit Breaker
### 32. Task Queue
### 33. Tree & Graph Utils
### 34. Codec Pipeline
### 35. Expression Evaluator

---

## Tier 5: 🟣 Boss Level — Differentiators (v1.0.0)

### 36. API Client Builder
### 37. Reactive Store
### 38. Schema Validator
### 39. Cron Scheduler
### 40. Middleware Pipeline
