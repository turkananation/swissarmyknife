import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('StringKnife', () {
    group('capitalize', () {
      test('should capitalize first letter', () {
        expect('hello'.capitalize(), equals('Hello'));
      });
      test('should handle empty string', () {
        expect(''.capitalize(), equals(''));
      });
    });

    group('capitalizeEach', () {
      test('should capitalize each word', () {
        expect('hello world'.capitalizeEach(), equals('Hello World'));
      });
      test('should handle empty string', () {
        expect(''.capitalizeEach(), equals(''));
      });
    });

    group('toTitleCase', () {
      test('should convert to Title Case respecting minor words', () {
        expect('the lord of the rings'.toTitleCase(),
            equals('The Lord of the Rings'));
      });
      test('should capitalize first and last word even if minor', () {
        expect('a game of thrones of'.toTitleCase(),
            equals('A Game of Thrones Of'));
      });
    });

    group('toCamelCase', () {
      test('should convert snake_case to camelCase', () {
        expect('hello_world_test'.toCamelCase(), equals('helloWorldTest'));
      });
      test('should convert PascalCase to camelCase', () {
        expect('HelloWorldTest'.toCamelCase(), equals('helloWorldTest'));
      });
    });

    group('toSnakeCase', () {
      test('should convert camelCase to snake_case', () {
        expect('helloWorldTest'.toSnakeCase(), equals('hello_world_test'));
      });
      test('should convert HTMLParser to html_parser', () {
        expect('HTMLParser'.toSnakeCase(), equals('html_parser'));
      });
    });

    group('toKebabCase', () {
      test('should convert camelCase to kebab-case', () {
        expect('helloWorldTest'.toKebabCase(), equals('hello-world-test'));
      });
      test('should handle spaces', () {
        expect('Hello World'.toKebabCase(), equals('hello-world'));
      });
    });

    group('toPascalCase', () {
      test('should convert snake_case to PascalCase', () {
        expect('hello_world_test'.toPascalCase(), equals('HelloWorldTest'));
      });
      test('should convert camelCase to PascalCase', () {
        expect('helloWorldTest'.toPascalCase(), equals('HelloWorldTest'));
      });
    });

    group('slugify', () {
      test('should slugify basic string', () {
        expect('Hello World!'.slugify(), equals('hello-world'));
      });
      test('should handle multiple symbols', () {
        expect(r'hello @world #cool$'.slugify(), equals('hello-world-cool'));
      });
    });

    group('truncate', () {
      test('should truncate long string with ellipsis', () {
        expect('hello world'.truncate(8), equals('hello...'));
      });
      test('should return string unchanged if within maxLength', () {
        expect('hello'.truncate(8), equals('hello'));
      });
      test('should slice if maxLength is small', () {
        expect('hello world'.truncate(2, ellipsis: '...'), equals('he'));
      });
    });

    group('removeHtml', () {
      test('should strip tags', () {
        expect('<p>Hello <b>World</b></p>'.removeHtml(), equals('Hello World'));
      });
      test('should leave text without tags unchanged', () {
        expect('Hello World'.removeHtml(), equals('Hello World'));
      });
    });

    group('reverse', () {
      test('should reverse characters', () {
        expect('hello'.reverse(), equals('olleh'));
      });
      test('should handle empty', () {
        expect(''.reverse(), equals(''));
      });
    });

    group('mask', () {
      test('should mask credit card with default params', () {
        expect('12345678'.mask(), equals('****5678'));
      });
      test('should respect visibleCount', () {
        expect('12345678'.mask(visibleCount: 2), equals('******78'));
      });
      test('should respect maskChar', () {
        expect('1234'.mask(visibleCount: 1, maskChar: '#'), equals('###4'));
      });
    });

    group('initials', () {
      test('should extract initials', () {
        expect('John Doe'.initials(), equals('JD'));
      });
      test('should limit count', () {
        expect('John Fitzgerald Kennedy'.initials(count: 3), equals('JFK'));
        expect('John Fitzgerald Kennedy'.initials(count: 2), equals('JF'));
      });
    });

    group('isEmail', () {
      test('should return true for valid emails', () {
        expect('test@example.com'.isEmail, isTrue);
      });
      test('should return false for invalid emails', () {
        expect('invalid-email'.isEmail, isFalse);
      });
    });

    group('isUrl', () {
      test('should return true for valid http/https URLs', () {
        expect('https://example.com/foo'.isUrl, isTrue);
        expect('http://google.com'.isUrl, isTrue);
      });
      test('should return false for invalid URLs', () {
        expect('ftp://example.com'.isUrl, isFalse);
        expect('example.com'.isUrl, isFalse);
      });
    });

    group('isNumeric', () {
      test('should return true for integers and decimals', () {
        expect('123'.isNumeric, isTrue);
        expect('-123.45'.isNumeric, isTrue);
      });
      test('should return false for alphanumeric', () {
        expect('123a'.isNumeric, isFalse);
      });
    });

    group('isAlpha', () {
      test('should return true for letters only', () {
        expect('HelloWorld'.isAlpha, isTrue);
      });
      test('should return false if includes digits or spaces', () {
        expect('Hello 123'.isAlpha, isFalse);
      });
    });

    group('isAlphanumeric', () {
      test('should return true for letters and digits', () {
        expect('Hello123'.isAlphanumeric, isTrue);
      });
      test('should return false if contains space/punctuation', () {
        expect('Hello_123'.isAlphanumeric, isFalse);
      });
    });

    group('wordCount', () {
      test('should count words correctly', () {
        expect('hello world dynamic'.wordCount, equals(3));
      });
      test('should count zero for empty', () {
        expect(''.wordCount, equals(0));
      });
    });

    group('charFrequency', () {
      test('should calculate frequencies', () {
        expect('hello'.charFrequency(), equals({'h': 1, 'e': 1, 'l': 2, 'o': 1}));
      });
    });

    group('wrap & unwrap', () {
      test('should wrap string', () {
        expect('content'.wrap('[', ']'), equals('[content]'));
      });
      test('should unwrap string', () {
        expect('[content]'.unwrap('[', ']'), equals('content'));
      });
      test('should return original string if it does not match wrap delimiters', () {
        expect('content'.unwrap('[', ']'), equals('content'));
      });
    });

    group('toIntOrNull & toDoubleOrNull', () {
      test('should parse correctly', () {
        expect('123'.toIntOrNull(), equals(123));
        expect('123.45'.toDoubleOrNull(), equals(123.45));
      });
      test('should return null on failure', () {
        expect('abc'.toIntOrNull(), isNull);
        expect('abc'.toDoubleOrNull(), isNull);
      });
    });

    group('repeatWith', () {
      test('should repeat string', () {
        expect('a'.repeatWith(3, separator: '-'), equals('a-a-a'));
      });
      test('should return empty for n <= 0', () {
        expect('a'.repeatWith(0), equals(''));
      });
    });

    group('replaceMultiple', () {
      test('should replace multiple matches in single pass', () {
        final result = 'hello world'.replaceMultiple({'hello': 'hi', 'world': 'there'});
        expect(result, equals('hi there'));
      });

      test('should ignore empty keys and prevent infinite loops', () {
        final result = 'hello world'.replaceMultiple({'': 'ignore', 'hello': 'hi'});
        expect(result, equals('hi world'));
      });
    });

    group('containsAny', () {
      test('should return true if any pattern is present', () {
        expect('hello world'.containsAny(['world', 'cool']), isTrue);
      });
      test('should return false if none are present', () {
        expect('hello world'.containsAny(['cool', 'nice']), isFalse);
      });
    });

    group('equalsIgnoreCase', () {
      test('should compare ignoring case', () {
        expect('Hello'.equalsIgnoreCase('hello'), isTrue);
      });
    });
  });

  group('NullableStringKnife', () {
    group('isBlank', () {
      test('should return true for null', () {
        String? val;
        expect(val.isBlank, isTrue);
      });
      test('should return true for empty or whitespace', () {
        expect(''.isBlank, isTrue);
        expect('   '.isBlank, isTrue);
      });
      test('should return false for valid content', () {
        expect('hello'.isBlank, isFalse);
      });
    });

    group('isNotBlank', () {
      test('should return false for null', () {
        String? val;
        expect(val.isNotBlank, isFalse);
      });
      test('should return true for valid content', () {
        expect('hello'.isNotBlank, isTrue);
      });
    });
  });
}
