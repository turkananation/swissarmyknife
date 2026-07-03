---
title: Cookbook
description: Common SwissArmyKnife patterns for day-to-day Dart application code.
---

## Parse Safely

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

## Read JSON

```dart
final payload = {
  'user': {'profile': {'name': 'Ada'}},
};

final name = payload.at('user.profile.name').asStringOr('Unknown');
```

## Retry Work

```dart
final result = await retry(
  () async => fetchSomething(),
  maxAttempts: 3,
  delay: const Duration(milliseconds: 200),
  backoff: BackoffStrategy.exponential,
);
```

## Bound Concurrency

```dart
final queue = TaskQueue(concurrency: 4);
final futures = ids.map((id) => queue.add(() => loadRecord(id)).future);
final records = await Future.wait(futures);
```

## Compose Middleware

```dart
final pipeline = MiddlewarePipeline<int>()
    .use(MiddlewarePipeline.tap((value) => print('in: $value')))
    .use(MiddlewarePipeline.transform((value) => value + 1));

final output = await pipeline.run(41);
```
