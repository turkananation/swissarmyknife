import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('StringAdvancedKnife', () {
    group('removeDiacritics', () {
      test('should strip accents from character sets', () {
        expect('Café'.removeDiacritics(), equals('Cafe'));
        expect('München'.removeDiacritics(), equals('Munchen'));
        expect('À la carte'.removeDiacritics(), equals('A la carte'));
        expect('crème brûlée'.removeDiacritics(), equals('creme brulee'));
      });
      test('should leave unaccented text alone', () {
        expect('hello 123'.removeDiacritics(), equals('hello 123'));
      });
    });

    group('levenshteinDistance', () {
      test('should compute correct distance', () {
        expect('kitten'.levenshteinDistance('sitting'), equals(3));
        expect('apple'.levenshteinDistance('apply'), equals(1));
        expect('hello'.levenshteinDistance('hello'), equals(0));
      });
      test('should handle empty strings', () {
        expect(''.levenshteinDistance('test'), equals(4));
        expect('test'.levenshteinDistance(''), equals(4));
      });
    });

    group('similarity', () {
      test('should return 1.0 for equal strings', () {
        expect('hello'.similarity('hello'), equals(1.0));
      });
      test('should return correct ratio', () {
        expect('apple'.similarity('apply'), equals(0.8)); // 4/5 match
        expect(''.similarity('test'), equals(0.0));
      });
    });

    group('removeWhitespace', () {
      test('should collapse and trim spaces', () {
        expect('  hello   world  '.removeWhitespace(), equals('hello world'));
        expect(' \n hello \t world '.removeWhitespace(), equals('hello world'));
      });
    });

    group('extractors', () {
      test('extractEmails', () {
        final text = 'Contact us at info@example.com or support@company.org.';
        expect(text.extractEmails(), equals(['info@example.com', 'support@company.org']));
      });

      test('extractUrls', () {
        final text = 'Links: http://google.com and https://github.com/foo/bar?q=1 .';
        expect(text.extractUrls(), equals(['http://google.com', 'https://github.com/foo/bar?q=1']));
      });

      test('extractPhoneNumbers', () {
        final text = 'Call +1 (555) 019-2834 or 091-234-5678 today.';
        final extracted = text.extractPhoneNumbers();
        expect(extracted, contains('+1 (555) 019-2834'));
        expect(extracted, contains('091-234-5678'));
      });

      test('extractHashtags', () {
        final text = 'Coding in #dart and #flutter is #fun_times!';
        expect(text.extractHashtags(), equals(['#dart', '#flutter', '#fun_times']));
      });

      test('extractMentions', () {
        final text = 'Reply to @john_doe and @mary.';
        expect(text.extractMentions(), equals(['@john_doe', '@mary']));
      });
    });
  });
}
