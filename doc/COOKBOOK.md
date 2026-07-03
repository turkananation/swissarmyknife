# Cookbook

## Parse Without Throwing

```dart
final port = Result.runCatching(() => int.parse('8080'))
    .map((value) => value.clamp(1, 65535))
    .getOrElse(3000);
```

## Validate Input

```dart
final validator = Validator<String>.email().minLength(5);
final result = validator.validate('team@example.com');

if (result.isFailure) {
  print(result.errorOrNull);
}
```

## Read Nested JSON

```dart
final payload = {
  'user': {'profile': {'name': 'Ada'}},
};

final name = payload.at('user.profile.name').asStringOr('Unknown');
```

## Retry a Flaky Operation

```dart
final result = await retry(
  () async => fetchSomething(),
  maxAttempts: 3,
  delay: const Duration(milliseconds: 200),
  backoff: BackoffStrategy.exponential,
);
```

## Bound Concurrent Work

```dart
final queue = TaskQueue(concurrency: 4);

final jobs = [
  for (final id in [1, 2, 3])
    queue.add(() async => loadRecord(id)).future,
];

final records = await Future.wait(jobs);
```

## Protect a Dependency

```dart
final breaker = CircuitBreaker(failureThreshold: 3);
final result = await breaker.execute(() => callRemoteService());

result.fold(
  (value) => print(value),
  (failure) => print('remote unavailable: $failure'),
);
```

## Build a Small Middleware Chain

```dart
final pipeline = MiddlewarePipeline<int>()
    .use(MiddlewarePipeline.tap((value) => print('in: $value')))
    .use(MiddlewarePipeline.transform((value) => value + 1));

final output = await pipeline.run(41);
```
