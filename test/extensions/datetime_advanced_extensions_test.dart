import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('DateTimeAdvancedKnife', () {
    group('truncateTo', () {
      test('should truncate to specific intervals correctly', () {
        final date = DateTime(2026, 6, 26, 15, 30, 45, 123);

        expect(date.truncateTo(DateTimeInterval.year), equals(DateTime(2026)));
        expect(date.truncateTo(DateTimeInterval.month), equals(DateTime(2026, 6)));
        expect(date.truncateTo(DateTimeInterval.day), equals(DateTime(2026, 6, 26)));
        expect(date.truncateTo(DateTimeInterval.hour), equals(DateTime(2026, 6, 26, 15)));
        expect(date.truncateTo(DateTimeInterval.minute), equals(DateTime(2026, 6, 26, 15, 30)));
        expect(date.truncateTo(DateTimeInterval.second), equals(DateTime(2026, 6, 26, 15, 30, 45)));
      });

      test('should preserve isUtc when truncating', () {
        final date = DateTime.utc(2026, 6, 26, 15, 30, 45, 123);
        expect(date.truncateTo(DateTimeInterval.day).isUtc, isTrue);
        expect(date.truncateTo(DateTimeInterval.day), equals(DateTime.utc(2026, 6, 26)));
      });
    });

    group('nextWeekday & previousWeekday', () {
      test('nextWeekday should return correct day', () {
        final date = DateTime(2026, 6, 26); // Friday
        final nextMon = date.nextWeekday(DateTime.monday);
        expect(nextMon.weekday, equals(DateTime.monday));
        expect(nextMon.day, equals(29)); // Monday, June 29, 2026
      });

      test('previousWeekday should return correct day', () {
        final date = DateTime(2026, 6, 26); // Friday
        final lastMon = date.previousWeekday(DateTime.monday);
        expect(lastMon.weekday, equals(DateTime.monday));
        expect(lastMon.day, equals(22)); // Monday, June 22, 2026
      });
    });
  });

  group('DurationKnife', () {
    group('toFormattedString', () {
      test('should format duration concisely', () {
        final dur = Duration(days: 2, hours: 4, minutes: 12, seconds: 30);
        expect(dur.toFormattedString(), equals('2d 4h 12m 30s'));
      });
      test('should omit zero values', () {
        final dur = Duration(days: 2, minutes: 12);
        expect(dur.toFormattedString(), equals('2d 12m'));
      });
      test('should handle sub-second values', () {
        expect(const Duration(milliseconds: 500).toFormattedString(), equals('500ms'));
        expect(const Duration(microseconds: 5).toFormattedString(), equals('5us'));
        expect(Duration.zero.toFormattedString(), equals('0s'));
      });
    });

    group('toHumanReadable', () {
      test('should format duration as human readable', () {
        final dur = Duration(days: 2, hours: 4, minutes: 12, seconds: 30);
        expect(dur.toHumanReadable(), equals('2 days, 4 hours, 12 minutes, 30 seconds'));
      });
      test('should pluralize correctly', () {
        final dur = Duration(days: 1, hours: 1, minutes: 1, seconds: 1);
        expect(dur.toHumanReadable(), equals('1 day, 1 hour, 1 minute, 1 second'));
      });
    });
  });
}
