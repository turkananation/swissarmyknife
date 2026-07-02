/// Composable schema validation for JSON-like data.
///
/// Use [SchemaValidator] to build small runtime schemas for maps, lists,
/// primitive values, enums, nullable values, and custom rules.
library;

import '../functional/result.dart';

/// One schema validation issue.
final class SchemaValidationIssue {
  /// Creates a validation issue.
  const SchemaValidationIssue({
    required this.path,
    required this.message,
    this.value,
  });

  /// JSON-like path to the invalid value.
  final String path;

  /// Human-readable issue.
  final String message;

  /// Value that failed validation.
  final Object? value;

  @override
  String toString() => '$path: $message';
}

/// Validation result with all collected issues.
final class SchemaValidationResult {
  /// Creates a validation result.
  const SchemaValidationResult(this.issues);

  /// Collected issues.
  final List<SchemaValidationIssue> issues;

  /// Whether validation passed.
  bool get isValid => issues.isEmpty;

  /// Whether validation failed.
  bool get isInvalid => !isValid;
}

/// A typed runtime schema.
abstract base class Schema<T> {
  /// Creates a schema.
  const Schema();

  /// Validates [value] and collects all issues.
  SchemaValidationResult validate(Object? value, {String path = r'$'}) {
    final issues = <SchemaValidationIssue>[];
    collectIssues(value, path, issues);
    return SchemaValidationResult(
      List<SchemaValidationIssue>.unmodifiable(issues),
    );
  }

  /// Validates and casts [value] to [T].
  Result<T, List<SchemaValidationIssue>> parse(Object? value) {
    final result = validate(value);
    if (result.isInvalid) {
      return Result<T, List<SchemaValidationIssue>>.failure(result.issues);
    }
    return Result<T, List<SchemaValidationIssue>>.success(cast(value));
  }

  /// Returns a schema that accepts `null` or this schema.
  Schema<T?> nullable() => _NullableSchema<T>(this);

  /// Returns a schema that applies [test] after this schema passes.
  Schema<T> refine(bool Function(T value) test, String message) {
    return _RefinedSchema<T>(this, test, message);
  }

  /// Collects issues for [value].
  void collectIssues(
    Object? value,
    String path,
    List<SchemaValidationIssue> issues,
  );

  /// Casts a value that already passed validation.
  T cast(Object? value);
}

/// Object field schema with required/optional presence.
final class SchemaField<T> {
  /// Creates a required field.
  const SchemaField(this.schema) : isRequired = true;

  /// Creates an optional field.
  const SchemaField.optional(this.schema) : isRequired = false;

  /// Field schema.
  final Schema<T> schema;

  /// Whether the object must contain this field.
  final bool isRequired;
}

/// Static schema builders.
abstract final class SchemaValidator {
  /// String schema.
  static Schema<String> string({
    int? minLength,
    int? maxLength,
    Pattern? pattern,
  }) {
    return _StringSchema(
      minLength: minLength,
      maxLength: maxLength,
      pattern: pattern,
    );
  }

  /// Numeric schema.
  static Schema<num> number({num? min, num? max}) {
    return _NumberSchema(min: min, max: max);
  }

  /// Integer schema.
  static Schema<int> integer({int? min, int? max}) {
    return _IntegerSchema(min: min, max: max);
  }

  /// Boolean schema.
  static Schema<bool> boolean() => const _BoolSchema();

  /// List schema.
  static Schema<List<T>> list<T>(
    Schema<T> item, {
    int? minLength,
    int? maxLength,
  }) {
    return _ListSchema<T>(item, minLength: minLength, maxLength: maxLength);
  }

  /// Object schema with named [fields].
  static Schema<Map<String, Object?>> object(
    Map<String, SchemaField<Object?>> fields, {
    bool allowUnknown = false,
  }) {
    return _ObjectSchema(fields, allowUnknown: allowUnknown);
  }

  /// Enum schema that accepts one of [values].
  static Schema<T> enumeration<T>(Iterable<T> values) {
    return _EnumSchema<T>(Set<T>.unmodifiable(values));
  }

  /// Custom schema.
  static Schema<T> custom<T>({
    required bool Function(Object? value) isValid,
    required T Function(Object? value) cast,
    required String message,
  }) {
    return _CustomSchema<T>(
      isValid: isValid,
      castValue: cast,
      message: message,
    );
  }
}

final class _StringSchema extends Schema<String> {
  const _StringSchema({this.minLength, this.maxLength, this.pattern});

  final int? minLength;
  final int? maxLength;
  final Pattern? pattern;

  @override
  void collectIssues(
    Object? value,
    String path,
    List<SchemaValidationIssue> issues,
  ) {
    if (value is! String) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected string.',
          value: value,
        ),
      );
      return;
    }

    final min = minLength;
    if (min != null && value.length < min) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected at least $min character(s).',
          value: value,
        ),
      );
    }

    final max = maxLength;
    if (max != null && value.length > max) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected at most $max character(s).',
          value: value,
        ),
      );
    }

    final expectedPattern = pattern;
    if (expectedPattern != null &&
        !expectedPattern.allMatches(value).isNotEmpty) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected value to match pattern.',
          value: value,
        ),
      );
    }
  }

  @override
  String cast(Object? value) => value as String;
}

final class _NumberSchema extends Schema<num> {
  const _NumberSchema({this.min, this.max});

  final num? min;
  final num? max;

  @override
  void collectIssues(
    Object? value,
    String path,
    List<SchemaValidationIssue> issues,
  ) {
    if (value is! num) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected number.',
          value: value,
        ),
      );
      return;
    }
    _checkRange(value, path, issues, min: min, max: max);
  }

  @override
  num cast(Object? value) => value as num;
}

final class _IntegerSchema extends Schema<int> {
  const _IntegerSchema({this.min, this.max});

  final int? min;
  final int? max;

  @override
  void collectIssues(
    Object? value,
    String path,
    List<SchemaValidationIssue> issues,
  ) {
    if (value is! int) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected integer.',
          value: value,
        ),
      );
      return;
    }
    _checkRange(value, path, issues, min: min, max: max);
  }

  @override
  int cast(Object? value) => value as int;
}

final class _BoolSchema extends Schema<bool> {
  const _BoolSchema();

  @override
  void collectIssues(
    Object? value,
    String path,
    List<SchemaValidationIssue> issues,
  ) {
    if (value is! bool) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected boolean.',
          value: value,
        ),
      );
    }
  }

  @override
  bool cast(Object? value) => value as bool;
}

final class _ListSchema<T> extends Schema<List<T>> {
  const _ListSchema(this.item, {this.minLength, this.maxLength});

  final Schema<T> item;
  final int? minLength;
  final int? maxLength;

  @override
  void collectIssues(
    Object? value,
    String path,
    List<SchemaValidationIssue> issues,
  ) {
    if (value is! List) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected list.',
          value: value,
        ),
      );
      return;
    }

    final min = minLength;
    if (min != null && value.length < min) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected at least $min item(s).',
          value: value,
        ),
      );
    }

    final max = maxLength;
    if (max != null && value.length > max) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected at most $max item(s).',
          value: value,
        ),
      );
    }

    for (var i = 0; i < value.length; i++) {
      item.collectIssues(value[i], '$path[$i]', issues);
    }
  }

  @override
  List<T> cast(Object? value) {
    final raw = value as List;
    return List<T>.unmodifiable(raw.map(item.cast));
  }
}

final class _ObjectSchema extends Schema<Map<String, Object?>> {
  const _ObjectSchema(this.fields, {required this.allowUnknown});

  final Map<String, SchemaField<Object?>> fields;
  final bool allowUnknown;

  @override
  void collectIssues(
    Object? value,
    String path,
    List<SchemaValidationIssue> issues,
  ) {
    if (value is! Map) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected object.',
          value: value,
        ),
      );
      return;
    }

    for (final entry in value.entries) {
      if (entry.key is! String) {
        issues.add(
          SchemaValidationIssue(
            path: path,
            message: 'Expected object keys to be strings.',
            value: entry.key,
          ),
        );
      }
    }

    for (final field in fields.entries) {
      final key = field.key;
      final schemaField = field.value;
      final fieldPath = '$path.$key';
      if (!value.containsKey(key)) {
        if (schemaField.isRequired) {
          issues.add(
            SchemaValidationIssue(
              path: fieldPath,
              message: 'Missing required field.',
            ),
          );
        }
        continue;
      }
      schemaField.schema.collectIssues(value[key], fieldPath, issues);
    }

    if (!allowUnknown) {
      for (final key in value.keys.whereType<String>()) {
        if (!fields.containsKey(key)) {
          issues.add(
            SchemaValidationIssue(
              path: '$path.$key',
              message: 'Unknown field.',
              value: value[key],
            ),
          );
        }
      }
    }
  }

  @override
  Map<String, Object?> cast(Object? value) {
    final raw = value as Map;
    return Map<String, Object?>.unmodifiable(raw.cast<String, Object?>());
  }
}

final class _EnumSchema<T> extends Schema<T> {
  const _EnumSchema(this.values);

  final Set<T> values;

  @override
  void collectIssues(
    Object? value,
    String path,
    List<SchemaValidationIssue> issues,
  ) {
    if (!values.contains(value)) {
      issues.add(
        SchemaValidationIssue(
          path: path,
          message: 'Expected one of ${values.join(', ')}.',
          value: value,
        ),
      );
    }
  }

  @override
  T cast(Object? value) => value as T;
}

final class _NullableSchema<T> extends Schema<T?> {
  const _NullableSchema(this.inner);

  final Schema<T> inner;

  @override
  void collectIssues(
    Object? value,
    String path,
    List<SchemaValidationIssue> issues,
  ) {
    if (value == null) return;
    inner.collectIssues(value, path, issues);
  }

  @override
  T? cast(Object? value) => value == null ? null : inner.cast(value);
}

final class _RefinedSchema<T> extends Schema<T> {
  const _RefinedSchema(this.inner, this.test, this.message);

  final Schema<T> inner;
  final bool Function(T value) test;
  final String message;

  @override
  void collectIssues(
    Object? value,
    String path,
    List<SchemaValidationIssue> issues,
  ) {
    final before = issues.length;
    inner.collectIssues(value, path, issues);
    if (issues.length != before) return;

    final typed = inner.cast(value);
    if (!test(typed)) {
      issues.add(
        SchemaValidationIssue(path: path, message: message, value: value),
      );
    }
  }

  @override
  T cast(Object? value) => inner.cast(value);
}

final class _CustomSchema<T> extends Schema<T> {
  const _CustomSchema({
    required this.isValid,
    required this.castValue,
    required this.message,
  });

  final bool Function(Object? value) isValid;
  final T Function(Object? value) castValue;
  final String message;

  @override
  void collectIssues(
    Object? value,
    String path,
    List<SchemaValidationIssue> issues,
  ) {
    if (!isValid(value)) {
      issues.add(
        SchemaValidationIssue(path: path, message: message, value: value),
      );
    }
  }

  @override
  T cast(Object? value) => castValue(value);
}

void _checkRange(
  num value,
  String path,
  List<SchemaValidationIssue> issues, {
  num? min,
  num? max,
}) {
  if (min != null && value < min) {
    issues.add(
      SchemaValidationIssue(
        path: path,
        message: 'Expected at least $min.',
        value: value,
      ),
    );
  }
  if (max != null && value > max) {
    issues.add(
      SchemaValidationIssue(
        path: path,
        message: 'Expected at most $max.',
        value: value,
      ),
    );
  }
}
