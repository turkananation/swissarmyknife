---
title: API Guide
description: A practical map of the SwissArmyKnife public API surface.
---

## Extensions

| Module family | Common use |
| --- | --- |
| Strings | Case conversion, slugging, masking, truncation, extraction, similarity |
| Numbers | Compact strings, ranges, ordinals, Roman numerals, file sizes, durations |
| Dates | Day/month/year boundaries, comparisons, formatting, business days |
| Collections | Group, sort, chunk, partition, zip, sample, flatten, aggregate |
| Maps | Deep merge, nested paths, query strings, key/value transforms |
| Async values | Future timeouts, delayed work, error suppression, stream debounce/throttle |
| URI, regex, bytes | Query mutation, named captures, hex/base64/UTF-8 helpers |

## Functional Types

`Result<T, E>` makes fallible work explicit. `Option<T>` makes absence explicit.
`Either<L, R>` models two typed branches. `Pair` and `Triple` keep small grouped
values typed. Pipelines make transformations reusable.

## Application Primitives

Use `Validator`, `EventBus`, `DisposeBag`, `Lazy`, `StateMachine`, and
`CommandHistory` for common application patterns without committing to a larger
framework.

## Infrastructure

`Http` and `ApiClientBuilder` wrap `package:http` with headers, JSON, retry,
timeout, status validation, and typed failures. `SafeJson`, `SchemaValidator`,
`Cache`, `Env`, `Log`, `DateRange`, `Recurrence`, and `CronScheduler` cover
data, config, observability, and time.

## Advanced Composition

Memoization, circuit breakers, task queues, tree and graph helpers, codec
pipelines, expression evaluation, reactive state, and middleware pipelines give
you small durable pieces for larger systems.
