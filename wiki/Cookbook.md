# Cookbook

## Parse Without Throwing

```dart
final parsed = Result.runCatching(() => int.parse('42'));
final value = parsed.getOrElse(0);
```

## Validate Input

```dart
final result = Validator<String>.email().validate('team@example.com');
```

## Read Nested JSON

```dart
final name = payload.at('user.profile.name').asStringOr('Unknown');
```

## Bound Work

```dart
final queue = TaskQueue(concurrency: 4);
final value = await queue.add(() => loadRecord()).future;
```
