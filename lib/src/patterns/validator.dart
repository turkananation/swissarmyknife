/// Composable validators that return explicit results.
///
/// Use [Validator] to build reusable validation chains without throwing or
/// manually accumulating error strings.
library;

import '../functional/result.dart';

/// A composable validator for values of type [T].
///
/// Example:
/// ```dart
/// final validator = Validator<String>.email().minLength(5);
/// final result = validator.validate('me@example.com');
/// ```
final class Validator<T> {
  /// Creates an empty validator that accepts every value.
  factory Validator() => Validator._((_) => const <String>[]);

  /// Creates a validator from a custom [test] and [message].
  factory Validator.custom(bool Function(T input) test, String message) {
    return Validator<T>().custom(test, message);
  }

  /// Creates a validator requiring a non-empty value.
  factory Validator.required({String message = 'Value is required.'}) {
    return Validator<T>().required(message: message);
  }

  /// Creates a string email validator.
  factory Validator.email({String message = 'Must be a valid email address.'}) {
    return Validator<T>().email(message: message);
  }

  /// Creates a string URL validator.
  factory Validator.url({String message = 'Must be a valid URL.'}) {
    return Validator<T>().url(message: message);
  }

  /// Creates a minimum string length validator.
  factory Validator.minLength(int minLength, {String? message}) {
    return Validator<T>().minLength(minLength, message: message);
  }

  /// Creates a maximum string length validator.
  factory Validator.maxLength(int maxLength, {String? message}) {
    return Validator<T>().maxLength(maxLength, message: message);
  }

  /// Creates a regular expression validator.
  factory Validator.matches(
    RegExp pattern, {
    String message = 'Value has an invalid format.',
  }) {
    return Validator<T>().matches(pattern, message: message);
  }

  /// Creates a substring validator.
  factory Validator.contains(String substring, {String? message}) {
    return Validator<T>().contains(substring, message: message);
  }

  /// Creates a numeric string validator.
  factory Validator.numeric({String message = 'Must be numeric.'}) {
    return Validator<T>().numeric(message: message);
  }

  /// Creates an alphabetic string validator.
  factory Validator.alpha({String message = 'Must contain only letters.'}) {
    return Validator<T>().alpha(message: message);
  }

  /// Creates a minimum numeric value validator.
  factory Validator.min(num min, {String? message}) {
    return Validator<T>().min(min, message: message);
  }

  /// Creates a maximum numeric value validator.
  factory Validator.max(num max, {String? message}) {
    return Validator<T>().max(max, message: message);
  }

  /// Creates a positive numeric value validator.
  factory Validator.positive({String message = 'Must be positive.'}) {
    return Validator<T>().positive(message: message);
  }

  const Validator._(this._validate);

  final List<String> Function(T input) _validate;

  /// Validates [input], returning success with the input or failure messages.
  ///
  /// Example:
  /// ```dart
  /// final result = Validator<String>.email().validate('me@example.com');
  /// ```
  Result<T, List<String>> validate(T input) {
    final errors = _validate(input);
    if (errors.isEmpty) {
      return Result<T, List<String>>.success(input);
    }
    return Result<T, List<String>>.failure(errors);
  }

  /// Adds a custom [test] with [message].
  ///
  /// Example:
  /// ```dart
  /// final validator = Validator<int>().custom((value) => value.isEven, 'even');
  /// ```
  Validator<T> custom(bool Function(T input) test, String message) {
    return _add((input) => test(input), message);
  }

  /// Adds a required-value rule.
  ///
  /// Strings must be non-blank; iterables and maps must be non-empty.
  Validator<T> required({String message = 'Value is required.'}) {
    return _add(_isPresent, message);
  }

  /// Adds an email rule for string values.
  Validator<T> email({String message = 'Must be a valid email address.'}) {
    return _add((input) {
      if (input is! String) return false;
      return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(input);
    }, message);
  }

  /// Adds a URL rule for string values.
  Validator<T> url({String message = 'Must be a valid URL.'}) {
    return _add((input) {
      if (input is! String) return false;
      final uri = Uri.tryParse(input);
      return uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    }, message);
  }

  /// Adds a minimum string length rule.
  Validator<T> minLength(int minLength, {String? message}) {
    if (minLength < 0) {
      throw ArgumentError.value(
        minLength,
        'minLength',
        'Must be non-negative.',
      );
    }
    return _add((input) {
      if (input is! String) return false;
      return input.length >= minLength;
    }, message ?? 'Must be at least $minLength characters long.');
  }

  /// Adds a maximum string length rule.
  Validator<T> maxLength(int maxLength, {String? message}) {
    if (maxLength < 0) {
      throw ArgumentError.value(
        maxLength,
        'maxLength',
        'Must be non-negative.',
      );
    }
    return _add((input) {
      if (input is! String) return false;
      return input.length <= maxLength;
    }, message ?? 'Must be at most $maxLength characters long.');
  }

  /// Adds a regular expression rule for string values.
  Validator<T> matches(
    RegExp pattern, {
    String message = 'Value has an invalid format.',
  }) {
    return _add((input) {
      if (input is! String) return false;
      return pattern.hasMatch(input);
    }, message);
  }

  /// Adds a substring rule for string values.
  Validator<T> contains(String substring, {String? message}) {
    return _add((input) {
      if (input is! String) return false;
      return input.contains(substring);
    }, message ?? 'Must contain "$substring".');
  }

  /// Adds a numeric-string rule.
  Validator<T> numeric({String message = 'Must be numeric.'}) {
    return _add((input) {
      if (input is! String) return false;
      return num.tryParse(input) != null;
    }, message);
  }

  /// Adds an alphabetic-string rule.
  Validator<T> alpha({String message = 'Must contain only letters.'}) {
    return _add((input) {
      if (input is! String) return false;
      return RegExp(r'^[A-Za-z]+$').hasMatch(input);
    }, message);
  }

  /// Adds a minimum numeric value rule.
  Validator<T> min(num min, {String? message}) {
    return _add((input) {
      if (input is! num) return false;
      return input >= min;
    }, message ?? 'Must be at least $min.');
  }

  /// Adds a maximum numeric value rule.
  Validator<T> max(num max, {String? message}) {
    return _add((input) {
      if (input is! num) return false;
      return input <= max;
    }, message ?? 'Must be at most $max.');
  }

  /// Adds a positive numeric value rule.
  Validator<T> positive({String message = 'Must be positive.'}) {
    return _add((input) {
      if (input is! num) return false;
      return input > 0;
    }, message);
  }

  /// Combines this validator with [other], requiring both to pass.
  ///
  /// Example:
  /// ```dart
  /// final validator = Validator<String>.required()
  ///     .and(Validator<String>.email());
  /// ```
  Validator<T> and(Validator<T> other) {
    return Validator<T>._((input) {
      return [..._validate(input), ...other._validate(input)];
    });
  }

  /// Combines this validator with [other], requiring either to pass.
  ///
  /// If both fail, errors from both validators are returned.
  Validator<T> or(Validator<T> other) {
    return Validator<T>._((input) {
      final firstErrors = _validate(input);
      if (firstErrors.isEmpty) return const <String>[];

      final secondErrors = other._validate(input);
      if (secondErrors.isEmpty) return const <String>[];

      return [...firstErrors, ...secondErrors];
    });
  }

  Validator<T> _add(bool Function(T input) test, String message) {
    return Validator<T>._((input) {
      final errors = List<String>.from(_validate(input));
      if (!test(input)) {
        errors.add(message);
      }
      return errors;
    });
  }
}

bool _isPresent(Object? value) {
  if (value == null) return false;
  if (value is String) return value.trim().isNotEmpty;
  if (value is Iterable) return value.isNotEmpty;
  if (value is Map) return value.isNotEmpty;
  return true;
}
