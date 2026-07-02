import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('DateRange', () {
    test('should include dates between start and end', () {
      final range = DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 3));

      expect(range.days, equals(3));
      expect(range.duration, equals(const Duration(days: 2)));
      expect(range.contains(DateTime(2026, 1, 2)), isTrue);
      expect(range.contains(DateTime(2026, 1, 4)), isFalse);
      expect(
        range.toList(),
        equals([
          DateTime(2026, 1, 1),
          DateTime(2026, 1, 2),
          DateTime(2026, 1, 3),
        ]),
      );
    });

    test('should detect overlap and intersection', () {
      final first = DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 10));
      final second = DateRange(DateTime(2026, 1, 5), DateTime(2026, 1, 20));
      final third = DateRange(DateTime(2026, 2, 1), DateTime(2026, 2, 2));

      expect(first.overlaps(second), isTrue);
      expect(
        first.intersection(second),
        equals(DateRange(DateTime(2026, 1, 5), DateTime(2026, 1, 10))),
      );
      expect(first.overlaps(third), isFalse);
      expect(first.intersection(third), isNull);
    });

    test('should iterate with custom steps and validate inputs', () {
      final range = DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 5));

      expect(
        range.iterate(step: const Duration(days: 2)).toList(),
        equals([
          DateTime(2026, 1, 1),
          DateTime(2026, 1, 3),
          DateTime(2026, 1, 5),
        ]),
      );
      expect(
        () => range.iterate(step: Duration.zero).toList(),
        throwsArgumentError,
      );
      expect(
        () => DateRange(DateTime(2026, 1, 2), DateTime(2026, 1, 1)),
        throwsArgumentError,
      );
    });
  });

  group('Recurrence', () {
    test('should generate daily and weekly occurrences', () {
      expect(
        Recurrence.daily().occurrences(DateTime(2026, 1, 1), 3),
        equals([
          DateTime(2026, 1, 1),
          DateTime(2026, 1, 2),
          DateTime(2026, 1, 3),
        ]),
      );
      expect(
        Recurrence.weekly(interval: 2).nextAfter(DateTime(2026, 1, 1)),
        equals(DateTime(2026, 1, 15)),
      );
    });

    test('should clamp monthly and yearly dates', () {
      expect(
        Recurrence.monthly().nextAfter(DateTime(2026, 1, 31)),
        equals(DateTime(2026, 2, 28)),
      );
      expect(
        Recurrence.yearly().nextAfter(DateTime(2024, 2, 29)),
        equals(DateTime(2025, 2, 28)),
      );
    });

    test('should validate recurrence inputs', () {
      expect(() => Recurrence.daily(interval: 0), throwsArgumentError);
      expect(
        () => Recurrence.daily().occurrences(DateTime(2026), -1),
        throwsArgumentError,
      );
    });
  });
}
