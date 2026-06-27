import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('BoolKnife', () {
    group('toInt', () {
      test('should return 1 when boolean is true', () {
        expect(true.toInt(), equals(1));
      });

      test('should return 0 when boolean is false', () {
        expect(false.toInt(), equals(0));
      });
    });

    group('toYesNo', () {
      test('should return Yes when boolean is true', () {
        expect(true.toYesNo(), equals('Yes'));
      });

      test('should return No when boolean is false', () {
        expect(false.toYesNo(), equals('No'));
      });
    });

    group('toOnOff', () {
      test('should return On when boolean is true', () {
        expect(true.toOnOff(), equals('On'));
      });

      test('should return Off when boolean is false', () {
        expect(false.toOnOff(), equals('Off'));
      });
    });

    group('toEnabledDisabled', () {
      test('should return Enabled when boolean is true', () {
        expect(true.toEnabledDisabled(), equals('Enabled'));
      });

      test('should return Disabled when boolean is false', () {
        expect(false.toEnabledDisabled(), equals('Disabled'));
      });
    });

    group('when', () {
      test('should return isTrue value when boolean is true', () {
        final result = true.when(isTrue: 'Yes', isFalse: 'No');
        expect(result, equals('Yes'));
      });

      test('should return isFalse value when boolean is false', () {
        final result = false.when(isTrue: 'Yes', isFalse: 'No');
        expect(result, equals('No'));
      });
    });

    group('ifTrue', () {
      test('should execute action when boolean is true', () {
        var executed = false;
        final result = true.ifTrue(() {
          executed = true;
        });
        expect(executed, isTrue);
        expect(result, isTrue);
      });

      test('should not execute action when boolean is false', () {
        var executed = false;
        final result = false.ifTrue(() {
          executed = true;
        });
        expect(executed, isFalse);
        expect(result, isFalse);
      });
    });

    group('ifFalse', () {
      test('should execute action when boolean is false', () {
        var executed = false;
        final result = false.ifFalse(() {
          executed = true;
        });
        expect(executed, isTrue);
        expect(result, isFalse);
      });

      test('should not execute action when boolean is true', () {
        var executed = false;
        final result = true.ifFalse(() {
          executed = true;
        });
        expect(executed, isFalse);
        expect(result, isTrue);
      });
    });
  });
}
