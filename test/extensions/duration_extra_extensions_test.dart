/// Tests for duration extra extensions.
library;

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('DurationExtraKnife', () {
    group('fromNow', () {
      test('should return a future date close to estimated time', () {
        final duration = const Duration(hours: 1);
        final futureTime = duration.fromNow;
        final difference = futureTime.difference(DateTime.now());
        // Difference should be very close to 1 hour (within 5 seconds)
        expect((difference.inSeconds - 3600).abs(), lessThan(5));
      });
    });

    group('ago', () {
      test('should return a past date close to estimated time', () {
        final duration = const Duration(hours: 1);
        final pastTime = duration.ago;
        final difference = DateTime.now().difference(pastTime);
        // Difference should be very close to 1 hour (within 5 seconds)
        expect((difference.inSeconds - 3600).abs(), lessThan(5));
      });
    });

    group('inWholeWeeks', () {
      test('should return correct number of whole weeks', () {
        expect(const Duration(days: 0).inWholeWeeks, equals(0));
        expect(const Duration(days: 6).inWholeWeeks, equals(0));
        expect(const Duration(days: 7).inWholeWeeks, equals(1));
        expect(const Duration(days: 13).inWholeWeeks, equals(1));
        expect(const Duration(days: 14).inWholeWeeks, equals(2));
      });

      test('should handle negative durations correctly', () {
        expect(const Duration(days: -7).inWholeWeeks, equals(-1));
      });
    });

    group('inWholeMonths', () {
      test('should return correct number of approximate months', () {
        expect(const Duration(days: 0).inWholeMonths, equals(0));
        expect(const Duration(days: 29).inWholeMonths, equals(0));
        expect(const Duration(days: 30).inWholeMonths, equals(1));
        expect(const Duration(days: 59).inWholeMonths, equals(1));
        expect(const Duration(days: 60).inWholeMonths, equals(2));
      });

      test('should handle negative durations correctly', () {
        expect(const Duration(days: -30).inWholeMonths, equals(-1));
      });
    });
  });
}
