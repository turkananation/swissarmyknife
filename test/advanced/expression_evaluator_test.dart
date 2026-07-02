import 'dart:math' as math;

import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('ExpressionEvaluator', () {
    test('should evaluate arithmetic with precedence and grouping', () {
      final evaluator = ExpressionEvaluator();

      expect(evaluator.evaluate('1 + 2 * 3'), equals(7));
      expect(evaluator.evaluate('(1 + 2) * 3'), equals(9));
      expect(evaluator.evaluate('10 % 4 + 6 / 3'), equals(4));
      expect(evaluator.evaluate('2 ^ 3 ^ 2'), equals(512));
      expect(evaluator.evaluate('-2 ^ 2'), equals(-4));
      expect(evaluator.evaluate('(-2) ^ 2'), equals(4));
    });

    test('should parse decimals and exponent notation', () {
      final evaluator = ExpressionEvaluator();

      expect(evaluator.evaluate('.5 + 1.5'), equals(2));
      expect(evaluator.evaluate('1e3 + 2.5e2'), equals(1250));
    });

    test('should resolve variables and default constants', () {
      final evaluator = ExpressionEvaluator();

      expect(
        evaluator.evaluate(
          'subtotal * (1 + tax)',
          variables: {'subtotal': 80, 'tax': 0.25},
        ),
        equals(100),
      );
      expect(evaluator.evaluate('round(pi)'), equals(3));
    });

    test('should compile expressions for repeated evaluation', () {
      final evaluator = ExpressionEvaluator();
      final expression = evaluator.compile('price * quantity - discount');

      expect(
        expression.evaluate(
          variables: {'price': 10, 'quantity': 3, 'discount': 4},
        ),
        equals(26),
      );
      expect(
        expression.evaluate(
          variables: {'price': 8, 'quantity': 2, 'discount': 1},
        ),
        equals(15),
      );
      expect(
        expression.toString(),
        equals('Expression(price * quantity - discount)'),
      );
    });

    test('should evaluate built-in functions', () {
      final evaluator = ExpressionEvaluator();

      expect(evaluator.evaluate('max(1, 5, 3)'), equals(5));
      expect(evaluator.evaluate('min(1, 5, 3)'), equals(1));
      expect(evaluator.evaluate('pow(2, 5)'), equals(32));
      expect(evaluator.evaluate('sqrt(81) + abs(-4)'), equals(13));
      expect(evaluator.evaluate('clamp(12, 0, 10)'), equals(10));
      expect(evaluator.evaluate('sin(pi / 2)'), closeTo(1, 0.0000001));
    });

    test('should support custom constants and functions', () {
      final evaluator = ExpressionEvaluator(
        constants: {'answer': 42},
        functions: {
          'double': (arguments) => arguments.single * 2,
          'hypot': (arguments) => math.sqrt(
            arguments[0] * arguments[0] + arguments[1] * arguments[1],
          ),
        },
      );

      expect(evaluator.evaluate('double(answer)'), equals(84));
      expect(evaluator.evaluate('hypot(3, 4)'), equals(5));

      final expression = evaluator.compile('scale(value)');
      expect(
        expression.evaluate(
          variables: {'value': 7},
          functions: {'scale': (arguments) => arguments.single * 10},
        ),
        equals(70),
      );
    });

    test('should return Result failures for syntax errors', () {
      final evaluator = ExpressionEvaluator();
      final result = evaluator.tryCompile('1 + * 2');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ExpressionSyntaxException>());
      expect(result.errorOrNull!.offset, equals(4));
    });

    test(
      'should return Result failures for unknown identifiers and functions',
      () {
        final evaluator = ExpressionEvaluator();

        final variableResult = evaluator.tryEvaluate('missing + 1');
        final functionResult = evaluator.tryEvaluate('missing(1)');

        expect(variableResult.isFailure, isTrue);
        expect(
          variableResult.errorOrNull,
          isA<ExpressionEvaluationException>(),
        );
        expect(
          variableResult.errorOrNull!.message,
          contains('Unknown identifier'),
        );
        expect(functionResult.isFailure, isTrue);
        expect(
          functionResult.errorOrNull!.message,
          contains('Unknown function'),
        );
      },
    );

    test('should report function arity and user function failures', () {
      final evaluator = ExpressionEvaluator(
        functions: {'explode': (_) => throw StateError('boom')},
      );

      final arity = evaluator.tryEvaluate('pow(2)');
      final userFailure = evaluator.tryEvaluate('explode(1)');

      expect(arity.isFailure, isTrue);
      expect(arity.errorOrNull!.message, contains('expects 2 argument'));
      expect(userFailure.isFailure, isTrue);
      expect(
        userFailure.errorOrNull!.message,
        contains('Function "explode" failed'),
      );
      expect(userFailure.errorOrNull!.cause, isA<StateError>());
    });

    test('should allow variables to override constants', () {
      final evaluator = ExpressionEvaluator();

      expect(evaluator.evaluate('pi + 1', variables: {'pi': 10}), equals(11));
    });
  });
}
