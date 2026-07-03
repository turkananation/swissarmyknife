import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('DateTimeKnife', () {
    group('Date checks', () {
      test('isToday, isTomorrow, isYesterday', () {
        final today = DateTime.now();
        final tomorrow = today.add(const Duration(days: 1));
        final yesterday = today.subtract(const Duration(days: 1));

        expect(today.isToday, isTrue);
        expect(tomorrow.isTomorrow, isTrue);
        expect(yesterday.isYesterday, isTrue);

        expect(today.isTomorrow, isFalse);
        expect(today.isYesterday, isFalse);
      });

      test('isWeekend & isWeekday', () {
        final saturday = DateTime(2026, 6, 27); // Saturday
        final monday = DateTime(2026, 6, 29); // Monday

        expect(saturday.isWeekend, isTrue);
        expect(saturday.isWeekday, isFalse);
        expect(monday.isWeekday, isTrue);
        expect(monday.isWeekend, isFalse);
      });
    });

    group('Comparisons', () {
      test('isSameDay, isSameMonth, isSameYear', () {
        final date1 = DateTime(2026, 6, 26, 10, 0);
        final date2 = DateTime(2026, 6, 26, 18, 0);
        final date3 = DateTime(2026, 6, 27);
        final date4 = DateTime(2026, 7, 26);
        final date5 = DateTime(2027, 6, 26);

        expect(date1.isSameDay(date2), isTrue);
        expect(date1.isSameDay(date3), isFalse);

        expect(date1.isSameMonth(date3), isTrue);
        expect(date1.isSameMonth(date4), isFalse);

        expect(date1.isSameYear(date4), isTrue);
        expect(date1.isSameYear(date5), isFalse);
      });
    });

    group('Boundaries', () {
      test('startOfDay & endOfDay', () {
        final date = DateTime(2026, 6, 26, 15, 30, 45);
        expect(date.startOfDay, equals(DateTime(2026, 6, 26, 0, 0, 0)));
        expect(
          date.endOfDay,
          equals(DateTime(2026, 6, 26, 23, 59, 59, 999, 999)),
        );
      });

      test('startOfWeek & endOfWeek', () {
        final date = DateTime(2026, 6, 26); // Friday
        final monday = date.startOfWeek();
        final sunday = date.endOfWeek();

        expect(monday.weekday, equals(DateTime.monday));
        expect(sunday.weekday, equals(DateTime.sunday));
        expect(monday.day, equals(22)); // June 22, 2026
        expect(sunday.day, equals(28)); // June 28, 2026
      });

      test('startOfMonth & endOfMonth', () {
        final date = DateTime(2026, 6, 26);
        expect(date.startOfMonth, equals(DateTime(2026, 6, 1)));
        expect(date.endOfMonth.day, equals(30)); // June has 30 days
      });
    });

    group('Leap year & days in month', () {
      test('isLeapYear', () {
        expect(DateTime(2020, 1, 1).isLeapYear, isTrue);
        expect(DateTime(2021, 1, 1).isLeapYear, isFalse);
        expect(DateTime(2000, 1, 1).isLeapYear, isTrue);
        expect(DateTime(1900, 1, 1).isLeapYear, isFalse);
      });

      test('daysInMonth', () {
        expect(DateTime(2020, 2, 1).daysInMonth, equals(29)); // Leap year Feb
        expect(DateTime(2021, 2, 1).daysInMonth, equals(28));
        expect(DateTime(2026, 6, 1).daysInMonth, equals(30));
      });
    });

    group('Quarter & weekOfYear', () {
      test('quarter', () {
        expect(DateTime(2026, 1, 15).quarter, equals(1));
        expect(DateTime(2026, 5, 20).quarter, equals(2));
        expect(DateTime(2026, 8, 10).quarter, equals(3));
        expect(DateTime(2026, 11, 5).quarter, equals(4));
      });

      test('weekOfYear', () {
        expect(DateTime(2026, 1, 1).weekOfYear, equals(1));
        expect(DateTime(2026, 6, 26).weekOfYear, equals(26));
      });
    });

    group('Relative formatting', () {
      test('timeAgo', () {
        final now = DateTime.now();
        final justNow = now.subtract(const Duration(seconds: 10));
        final minsAgo = now.subtract(const Duration(minutes: 5));
        final yesterday = now.subtract(const Duration(days: 1));

        expect(justNow.timeAgo(), equals('just now'));
        expect(minsAgo.timeAgo(), equals('5 minutes ago'));
        expect(yesterday.timeAgo(), equals('yesterday'));
      });

      test('timeUntil', () {
        final now = DateTime.now();
        final inMins = now.add(const Duration(minutes: 5, seconds: 10));
        final tomorrow = now.add(const Duration(days: 1, hours: 1));

        expect(inMins.timeUntil(), equals('in 5 minutes'));
        expect(tomorrow.timeUntil(), equals('tomorrow'));
      });
    });

    group('format', () {
      test('should format with custom pattern', () {
        final date = DateTime(2026, 6, 26, 15, 30, 45);
        expect(
          date.format('yyyy-MM-dd HH:mm:ss'),
          equals('2026-06-26 15:30:45'),
        );
        expect(date.format('MMM d, yy'), equals('Jun 26, 26'));
      });
    });

    group('addBusinessDays', () {
      test('should add days skipping weekends', () {
        final friday = DateTime(2026, 6, 26); // Friday
        final nextMonday = friday.addBusinessDays(1);
        expect(nextMonday.weekday, equals(DateTime.monday));
        expect(nextMonday.day, equals(29)); // June 29, 2026
      });

      test('should subtract days skipping weekends', () {
        final monday = DateTime(2026, 6, 29); // Monday
        final prevFriday = monday.addBusinessDays(-1);
        expect(prevFriday.weekday, equals(DateTime.friday));
        expect(prevFriday.day, equals(26)); // June 26, 2026
      });
    });

    group('age, copyWith, toDateOnly, isBetween', () {
      test('age', () {
        final birthDate = DateTime.now().subtract(const Duration(days: 365));
        expect(birthDate.age.inDays, greaterThanOrEqualTo(364));
      });

      test('copyWith', () {
        final date = DateTime(2026, 6, 26);
        final copied = date.copyWith(year: 2027, month: 8);
        expect(copied, equals(DateTime(2027, 8, 26)));
      });

      test('toDateOnly', () {
        final date = DateTime(2026, 6, 26, 15, 30, 45);
        expect(date.toDateOnly(), equals(DateTime(2026, 6, 26)));
      });

      test('isBetween', () {
        final start = DateTime(2026, 6, 1);
        final end = DateTime(2026, 6, 30);
        expect(DateTime(2026, 6, 15).isBetween(start, end), isTrue);
        expect(DateTime(2026, 5, 15).isBetween(start, end), isFalse);
      });
    });

    group('UTC preservation', () {
      test('should preserve isUtc across boundary getters and utilities', () {
        final utcDate = DateTime.utc(2026, 6, 26, 15, 30, 45, 123, 456);

        expect(utcDate.startOfDay.isUtc, isTrue);
        expect(utcDate.endOfDay.isUtc, isTrue);
        expect(utcDate.startOfWeek().isUtc, isTrue);
        expect(utcDate.endOfWeek().isUtc, isTrue);
        expect(utcDate.startOfMonth.isUtc, isTrue);
        expect(utcDate.endOfMonth.isUtc, isTrue);
        expect(utcDate.startOfYear.isUtc, isTrue);
        expect(utcDate.endOfYear.isUtc, isTrue);
        expect(utcDate.toDateOnly().isUtc, isTrue);
        expect(utcDate.copyWith(year: 2027).isUtc, isTrue);
        expect(utcDate.copyWith(year: 2027).year, equals(2027));
      });
    });
  });
}
