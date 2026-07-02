import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Validator', () {
    test('should validate email addresses', () {
      final validator = Validator<String>.email();

      expect(validator.validate('me@example.com').isSuccess, isTrue);
      expect(validator.validate('not-email').errorOrNull, isNotEmpty);
    });

    test('should validate URLs and string lengths', () {
      final validator = Validator<String>.url().minLength(12).maxLength(30);

      expect(validator.validate('https://dart.dev').isSuccess, isTrue);
      expect(validator.validate('dart.dev').errorOrNull, hasLength(2));
    });

    test('should validate string patterns and contents', () {
      final validator = Validator<String>.matches(
        RegExp(r'^[A-Z]+$'),
      ).contains('A').alpha();

      expect(validator.validate('ABC').isSuccess, isTrue);
      expect(validator.validate('123').errorOrNull, hasLength(3));
    });

    test('should validate numeric strings', () {
      final validator = Validator<String>.numeric();

      expect(validator.validate('-12.5').isSuccess, isTrue);
      expect(validator.validate('12x').isFailure, isTrue);
    });

    test('should validate numeric ranges', () {
      final validator = Validator<num>.min(10).max(20).positive();

      expect(validator.validate(15).isSuccess, isTrue);
      expect(
        validator.validate(5).errorOrNull,
        equals(['Must be at least 10.']),
      );
      expect(
        validator.validate(-1).errorOrNull,
        equals(['Must be at least 10.', 'Must be positive.']),
      );
    });

    test('should validate required values', () {
      final stringValidator = Validator<String?>.required();
      final listValidator = Validator<List<int>>.required();

      expect(stringValidator.validate('value').isSuccess, isTrue);
      expect(stringValidator.validate('   ').isFailure, isTrue);
      expect(listValidator.validate([1]).isSuccess, isTrue);
      expect(listValidator.validate([]).isFailure, isTrue);
    });

    test('should support custom validators', () {
      final validator = Validator<int>.custom(
        (value) => value.isEven,
        'Must be even.',
      );

      expect(validator.validate(2).isSuccess, isTrue);
      expect(validator.validate(3).errorOrNull, equals(['Must be even.']));
    });

    test('should compose validators with and/or', () {
      final requiredEmail = Validator<String>.required().and(
        Validator<String>.email(),
      );
      final emailOrNumeric = Validator<String>.email().or(
        Validator<String>.numeric(),
      );

      expect(requiredEmail.validate('me@example.com').isSuccess, isTrue);
      expect(requiredEmail.validate('').errorOrNull, hasLength(2));
      expect(emailOrNumeric.validate('me@example.com').isSuccess, isTrue);
      expect(emailOrNumeric.validate('123').isSuccess, isTrue);
      expect(emailOrNumeric.validate('nope').errorOrNull, hasLength(2));
    });

    test('should validate arguments for length rules', () {
      expect(() => Validator<String>.minLength(-1), throwsArgumentError);
      expect(() => Validator<String>.maxLength(-1), throwsArgumentError);
    });
  });
}
