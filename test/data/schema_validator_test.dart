import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaValidator', () {
    test('should validate primitive schemas', () {
      final name = SchemaValidator.string(minLength: 2, maxLength: 5);
      final email = SchemaValidator.string(pattern: RegExp(r'^[^@]+@[^@]+$'));
      final age = SchemaValidator.integer(min: 18, max: 99);
      final score = SchemaValidator.number(min: 0, max: 100);
      final flag = SchemaValidator.boolean();
      final role = SchemaValidator.enumeration({'admin', 'user'});

      expect(name.validate('Ada').isValid, isTrue);
      expect(email.validate('ada@example.com').isValid, isTrue);
      expect(age.validate(37).isValid, isTrue);
      expect(score.validate(99.5).isValid, isTrue);
      expect(flag.validate(true).isValid, isTrue);
      expect(role.validate('admin').isValid, isTrue);

      expect(name.validate('A').issues.single.message, contains('at least'));
      expect(email.validate('bad').issues.single.message, contains('pattern'));
      expect(age.validate(17).issues.single.message, contains('at least'));
      expect(score.validate(101).issues.single.message, contains('at most'));
      expect(flag.validate('true').issues.single.message, contains('boolean'));
      expect(role.validate('guest').issues.single.message, contains('one of'));
    });

    test('should validate objects with required and optional fields', () {
      final schema = SchemaValidator.object({
        'name': SchemaField(SchemaValidator.string(minLength: 1)),
        'age': SchemaField(SchemaValidator.integer(min: 0)),
        'nickname': SchemaField.optional(SchemaValidator.string()),
      });

      final valid = schema.validate({
        'name': 'Ada',
        'age': 37,
        'nickname': 'Countess',
      });
      final invalid = schema.validate({'name': '', 'extra': true});

      expect(valid.isValid, isTrue);
      expect(invalid.isInvalid, isTrue);
      expect(
        invalid.issues.map((issue) => issue.path),
        equals([r'$.name', r'$.age', r'$.extra']),
      );
      expect(
        invalid.issues.map((issue) => issue.message),
        contains('Missing required field.'),
      );
    });

    test('should validate nested lists and report indexed paths', () {
      final schema = SchemaValidator.object({
        'tags': SchemaField(
          SchemaValidator.list(
            SchemaValidator.string(minLength: 2),
            minLength: 1,
          ),
        ),
      });

      final result = schema.validate({
        'tags': ['ok', 'x', 3],
      });

      expect(result.isInvalid, isTrue);
      expect(
        result.issues.map((issue) => issue.path),
        equals([r'$.tags[1]', r'$.tags[2]']),
      );
    });

    test('should support nullable, refined, and custom schemas', () {
      final nullable = SchemaValidator.string().nullable();
      final even = SchemaValidator.integer().refine(
        (value) => value.isEven,
        'Expected an even number.',
      );
      final csv = SchemaValidator.custom<List<String>>(
        isValid: (value) => value is String,
        cast: (value) => (value as String).split(','),
        message: 'Expected CSV text.',
      );

      expect(nullable.parse(null).valueOrNull, isNull);
      expect(nullable.parse('ok').valueOrNull, equals('ok'));
      expect(even.validate(4).isValid, isTrue);
      expect(even.validate(3).issues.single.message, contains('even'));
      expect(csv.parse('a,b').valueOrNull, equals(['a', 'b']));
      expect(csv.validate(1).issues.single.message, contains('CSV'));
    });

    test(
      'should parse valid values and return all issues for invalid values',
      () {
        final schema = SchemaValidator.object({
          'name': SchemaField(SchemaValidator.string()),
          'active': SchemaField(SchemaValidator.boolean()),
        });

        final parsed = schema.parse({'name': 'Ada', 'active': true});
        final invalid = schema.parse({'name': 1, 'active': 'yes'});

        expect(parsed.isSuccess, isTrue);
        expect(parsed.valueOrNull, equals({'name': 'Ada', 'active': true}));
        expect(invalid.isFailure, isTrue);
        expect(invalid.errorOrNull, hasLength(2));
        expect(
          invalid.errorOrNull!.map((issue) => issue.path),
          equals([r'$.name', r'$.active']),
        );
      },
    );

    test('should allow unknown object fields when configured', () {
      final schema = SchemaValidator.object({
        'name': SchemaField(SchemaValidator.string()),
      }, allowUnknown: true);

      expect(schema.validate({'name': 'Ada', 'extra': true}).isValid, isTrue);
    });
  });
}
