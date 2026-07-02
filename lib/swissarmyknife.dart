/// SwissArmyKnife — The ultimate Dart utility toolkit.
///
/// Import this single file to access all extensions, functional types,
/// and utilities:
///
/// ```dart
/// import 'package:swissarmyknife/swissarmyknife.dart';
/// ```
library;

// Tier 1 — Pure Dart Extensions
export 'src/extensions/bool_extensions.dart';
export 'src/extensions/collection_advanced_extensions.dart';
export 'src/extensions/collection_extensions.dart';
export 'src/extensions/datetime_advanced_extensions.dart';
export 'src/extensions/datetime_extensions.dart';
export 'src/extensions/map_extensions.dart';
export 'src/extensions/num_extensions.dart';
export 'src/extensions/numeric_iterable_extensions.dart';
export 'src/extensions/random_extensions.dart';
export 'src/extensions/scope_functions.dart';
export 'src/extensions/string_advanced_extensions.dart';
export 'src/extensions/string_extensions.dart';
export 'src/extensions/uri_extensions.dart';
export 'src/extensions/set_extensions.dart';
export 'src/extensions/regexp_extensions.dart';
export 'src/extensions/uint8list_extensions.dart';
export 'src/extensions/future_extensions.dart';
export 'src/extensions/stream_extensions.dart';
export 'src/extensions/double_extensions.dart';
export 'src/extensions/int_math_extensions.dart';
export 'src/extensions/string_iterable_extensions.dart';
export 'src/extensions/comparable_iterable_extensions.dart';
export 'src/extensions/map_entry_extensions.dart';
export 'src/extensions/duration_extra_extensions.dart';
export 'src/extensions/nullable_extensions.dart';

// Tier 2 — Functional & async patterns
export 'src/advanced/codec_pipeline.dart';
export 'src/advanced/circuit_breaker.dart';
export 'src/advanced/expression_evaluator.dart';
export 'src/advanced/memoize.dart';
export 'src/advanced/middleware_pipeline.dart';
export 'src/advanced/reactive_store.dart';
export 'src/advanced/task_queue.dart';
export 'src/advanced/tree_utils.dart';
export 'src/async/debouncer.dart';
export 'src/async/rate_limiter.dart';
export 'src/async/retry.dart';
export 'src/async/throttler.dart';
export 'src/functional/either.dart';
export 'src/functional/option.dart';
export 'src/functional/pipeline.dart';
export 'src/functional/result.dart';
export 'src/functional/tuple.dart';
export 'src/patterns/command.dart';
export 'src/patterns/disposable.dart';
export 'src/patterns/event_bus.dart';
export 'src/patterns/lazy.dart';
export 'src/patterns/state_machine.dart';
export 'src/patterns/validator.dart';

// Tier 3 — IO, data, and time utilities
export 'src/data/cache_manager.dart';
export 'src/data/env_config.dart';
export 'src/data/safe_json.dart';
export 'src/data/schema_validator.dart';
export 'src/logging/logger.dart';
export 'src/networking/api_client_builder.dart';
export 'src/networking/http_client.dart';
export 'src/time/benchmark.dart';
export 'src/time/cron_scheduler.dart';
export 'src/time/date_range.dart';
