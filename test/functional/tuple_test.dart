import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('Pair', () {
    group('construction', () {
      test('should expose first and second values', () {
        const pair = Pair('id', 42);

        expect(pair.first, equals('id'));
        expect(pair.second, equals(42));
      });

      test('should create pair from record', () {
        final pair = Pair<String, int>.fromRecord(('id', 42));

        expect(pair, equals(const Pair('id', 42)));
      });
    });

    group('mapFirst & mapSecond', () {
      test('should transform first value', () {
        final pair = const Pair(1, 'a').mapFirst((value) => value + 1);

        expect(pair, equals(const Pair(2, 'a')));
      });

      test('should transform second value', () {
        final pair = const Pair(
          1,
          'a',
        ).mapSecond((value) => value.toUpperCase());

        expect(pair, equals(const Pair(1, 'A')));
      });
    });

    group('conversions', () {
      test('should convert to record', () {
        final (key, value) = const Pair('id', 42).toRecord();

        expect(key, equals('id'));
        expect(value, equals(42));
      });

      test('should convert to list and map', () {
        const pair = Pair('id', 42);

        expect(pair.toList(), equals(['id', 42]));
        expect(pair.toMap(), equals({'first': 'id', 'second': 42}));
      });
    });

    group('equality & toString', () {
      test('should compare matching pairs', () {
        expect(const Pair('id', 42), equals(const Pair('id', 42)));
      });

      test('should describe pair values', () {
        expect(const Pair('id', 42).toString(), equals('Pair(id, 42)'));
      });
    });
  });

  group('Triple', () {
    group('construction', () {
      test('should expose first, second, and third values', () {
        const triple = Triple('id', 42, true);

        expect(triple.first, equals('id'));
        expect(triple.second, equals(42));
        expect(triple.third, isTrue);
      });

      test('should create triple from record', () {
        final triple = Triple<String, int, bool>.fromRecord(('id', 42, true));

        expect(triple, equals(const Triple('id', 42, true)));
      });
    });

    group('mapFirst, mapSecond & mapThird', () {
      test('should transform first value', () {
        final triple = const Triple(
          1,
          'a',
          true,
        ).mapFirst((value) => value + 1);

        expect(triple, equals(const Triple(2, 'a', true)));
      });

      test('should transform second value', () {
        final triple = const Triple(
          1,
          'a',
          true,
        ).mapSecond((value) => value.toUpperCase());

        expect(triple, equals(const Triple(1, 'A', true)));
      });

      test('should transform third value', () {
        final triple = const Triple(1, 'a', '3').mapThird(int.parse);

        expect(triple, equals(const Triple(1, 'a', 3)));
      });
    });

    group('conversions', () {
      test('should convert to record', () {
        final (id, count, active) = const Triple('id', 42, true).toRecord();

        expect(id, equals('id'));
        expect(count, equals(42));
        expect(active, isTrue);
      });

      test('should convert to list and map', () {
        const triple = Triple('id', 42, true);

        expect(triple.toList(), equals(['id', 42, true]));
        expect(
          triple.toMap(),
          equals({'first': 'id', 'second': 42, 'third': true}),
        );
      });
    });

    group('equality & toString', () {
      test('should compare matching triples', () {
        expect(
          const Triple('id', 42, true),
          equals(const Triple('id', 42, true)),
        );
      });

      test('should describe triple values', () {
        expect(
          const Triple('id', 42, true).toString(),
          equals('Triple(id, 42, true)'),
        );
      });
    });
  });
}
