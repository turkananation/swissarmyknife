/// Numeric expression evaluator with variables, constants, and functions.
///
/// The evaluator uses a small tokenizer and Pratt parser so expressions can be
/// compiled once and evaluated repeatedly without string substitution.
library;

import 'dart:math' as math;

import '../functional/result.dart';

/// Function available to evaluated expressions.
typedef ExpressionFunction = num Function(List<num> arguments);

/// Base exception for expression parsing and evaluation failures.
class ExpressionException implements Exception {
  /// Creates an expression exception.
  const ExpressionException(
    this.message, {
    this.offset,
    this.source,
    this.cause,
  });

  /// Human-readable failure message.
  final String message;

  /// Character offset in [source], when available.
  final int? offset;

  /// Original expression source, when available.
  final String? source;

  /// Original thrown object, when the error wraps user code.
  final Object? cause;

  @override
  String toString() {
    final location = offset == null ? '' : ' at offset $offset';
    final wrapped = cause == null ? '' : ' Cause: $cause';
    return 'ExpressionException$location: $message$wrapped';
  }
}

/// Syntax error found while parsing an expression.
final class ExpressionSyntaxException extends ExpressionException {
  /// Creates a syntax exception.
  const ExpressionSyntaxException(super.message, {super.offset, super.source});
}

/// Error found while evaluating an expression.
final class ExpressionEvaluationException extends ExpressionException {
  /// Creates an evaluation exception.
  const ExpressionEvaluationException(
    super.message, {
    super.offset,
    super.source,
    super.cause,
  });
}

/// Compiled numeric expression.
final class Expression {
  Expression._(
    this.source,
    this._root, {
    required Map<String, num> constants,
    required Map<String, ExpressionFunction> functions,
  }) : constants = Map<String, num>.unmodifiable(constants),
       functions = Map<String, ExpressionFunction>.unmodifiable(functions);

  /// Original expression source.
  final String source;

  final _ExpressionNode _root;

  /// Constants captured when the expression was compiled.
  final Map<String, num> constants;

  /// Functions captured when the expression was compiled.
  final Map<String, ExpressionFunction> functions;

  /// Evaluates the expression with optional [variables].
  ///
  /// Per-call [constants] and [functions] override values captured at compile
  /// time.
  num evaluate({
    Map<String, num> variables = const {},
    Map<String, num>? constants,
    Map<String, ExpressionFunction>? functions,
  }) {
    final environment = _ExpressionEnvironment(
      source: source,
      variables: variables,
      constants: {...this.constants, ...?constants},
      functions: {...this.functions, ...?functions},
    );
    return _root.evaluate(environment);
  }

  /// Evaluates the expression and captures failures as a [Result].
  Result<num, ExpressionException> tryEvaluate({
    Map<String, num> variables = const {},
    Map<String, num>? constants,
    Map<String, ExpressionFunction>? functions,
  }) {
    try {
      return Result<num, ExpressionException>.success(
        evaluate(
          variables: variables,
          constants: constants,
          functions: functions,
        ),
      );
    } on ExpressionException catch (error) {
      return Result<num, ExpressionException>.failure(error);
    }
  }

  @override
  String toString() => 'Expression($source)';
}

/// Compiles and evaluates numeric expressions.
final class ExpressionEvaluator {
  /// Creates an evaluator.
  ExpressionEvaluator({
    Map<String, num>? constants,
    Map<String, ExpressionFunction>? functions,
    bool includeDefaults = true,
  }) : constants = Map<String, num>.unmodifiable({
         if (includeDefaults) ..._defaultConstants,
         ...?constants,
       }),
       functions = Map<String, ExpressionFunction>.unmodifiable({
         if (includeDefaults) ..._defaultFunctions,
         ...?functions,
       });

  /// Constants available to compiled expressions.
  final Map<String, num> constants;

  /// Functions available to compiled expressions.
  final Map<String, ExpressionFunction> functions;

  /// Compiles [source] into an [Expression].
  Expression compile(String source) {
    final tokens = _Tokenizer(source).tokenize();
    final root = _Parser(source, tokens).parse();
    return Expression._(
      source,
      root,
      constants: constants,
      functions: functions,
    );
  }

  /// Compiles [source], returning syntax failures as a [Result].
  Result<Expression, ExpressionException> tryCompile(String source) {
    try {
      return Result<Expression, ExpressionException>.success(compile(source));
    } on ExpressionException catch (error) {
      return Result<Expression, ExpressionException>.failure(error);
    }
  }

  /// Compiles and evaluates [source].
  num evaluate(String source, {Map<String, num> variables = const {}}) {
    return compile(source).evaluate(variables: variables);
  }

  /// Compiles and evaluates [source], returning failures as a [Result].
  Result<num, ExpressionException> tryEvaluate(
    String source, {
    Map<String, num> variables = const {},
  }) {
    try {
      return Result<num, ExpressionException>.success(
        evaluate(source, variables: variables),
      );
    } on ExpressionException catch (error) {
      return Result<num, ExpressionException>.failure(error);
    }
  }
}

final Map<String, num> _defaultConstants = {'pi': math.pi, 'e': math.e};

final Map<String, ExpressionFunction> _defaultFunctions = {
  'abs': _fixed('abs', 1, (args) => args[0].abs()),
  'sqrt': _fixed('sqrt', 1, (args) => math.sqrt(args[0])),
  'sin': _fixed('sin', 1, (args) => math.sin(args[0])),
  'cos': _fixed('cos', 1, (args) => math.cos(args[0])),
  'tan': _fixed('tan', 1, (args) => math.tan(args[0])),
  'log': _fixed('log', 1, (args) => math.log(args[0])),
  'exp': _fixed('exp', 1, (args) => math.exp(args[0])),
  'floor': _fixed('floor', 1, (args) => args[0].floor()),
  'ceil': _fixed('ceil', 1, (args) => args[0].ceil()),
  'round': _fixed('round', 1, (args) => args[0].round()),
  'pow': _fixed('pow', 2, (args) => math.pow(args[0], args[1])),
  'clamp': _fixed('clamp', 3, (args) => args[0].clamp(args[1], args[2])),
  'min': _atLeast('min', 1, (args) => args.reduce(math.min)),
  'max': _atLeast('max', 1, (args) => args.reduce(math.max)),
};

ExpressionFunction _fixed(
  String name,
  int arity,
  num Function(List<num> arguments) compute,
) {
  return (arguments) {
    if (arguments.length != arity) {
      throw ExpressionEvaluationException(
        'Function "$name" expects $arity argument(s) but got '
        '${arguments.length}.',
      );
    }
    return compute(arguments);
  };
}

ExpressionFunction _atLeast(
  String name,
  int minimum,
  num Function(List<num> arguments) compute,
) {
  return (arguments) {
    if (arguments.length < minimum) {
      throw ExpressionEvaluationException(
        'Function "$name" expects at least $minimum argument(s) but got '
        '${arguments.length}.',
      );
    }
    return compute(arguments);
  };
}

final class _ExpressionEnvironment {
  const _ExpressionEnvironment({
    required this.source,
    required this.variables,
    required this.constants,
    required this.functions,
  });

  final String source;
  final Map<String, num> variables;
  final Map<String, num> constants;
  final Map<String, ExpressionFunction> functions;

  num resolveIdentifier(String name, int offset) {
    if (variables.containsKey(name)) return variables[name] as num;
    if (constants.containsKey(name)) return constants[name] as num;
    throw ExpressionEvaluationException(
      'Unknown identifier "$name".',
      offset: offset,
      source: source,
    );
  }

  ExpressionFunction resolveFunction(String name, int offset) {
    final function = functions[name];
    if (function != null) return function;
    throw ExpressionEvaluationException(
      'Unknown function "$name".',
      offset: offset,
      source: source,
    );
  }
}

abstract interface class _ExpressionNode {
  num evaluate(_ExpressionEnvironment environment);
}

final class _LiteralNode implements _ExpressionNode {
  const _LiteralNode(this.value);

  final num value;

  @override
  num evaluate(_ExpressionEnvironment environment) => value;
}

final class _IdentifierNode implements _ExpressionNode {
  const _IdentifierNode(this.name, this.offset);

  final String name;
  final int offset;

  @override
  num evaluate(_ExpressionEnvironment environment) {
    return environment.resolveIdentifier(name, offset);
  }
}

final class _UnaryNode implements _ExpressionNode {
  const _UnaryNode(this.operator, this.operand);

  final _UnaryOperator operator;
  final _ExpressionNode operand;

  @override
  num evaluate(_ExpressionEnvironment environment) {
    final value = operand.evaluate(environment);
    return switch (operator) {
      _UnaryOperator.positive => value,
      _UnaryOperator.negative => -value,
    };
  }
}

final class _BinaryNode implements _ExpressionNode {
  const _BinaryNode(this.operator, this.left, this.right);

  final _BinaryOperator operator;
  final _ExpressionNode left;
  final _ExpressionNode right;

  @override
  num evaluate(_ExpressionEnvironment environment) {
    final leftValue = left.evaluate(environment);
    final rightValue = right.evaluate(environment);
    return operator.apply(leftValue, rightValue);
  }
}

final class _FunctionCallNode implements _ExpressionNode {
  const _FunctionCallNode(this.name, this.arguments, this.offset);

  final String name;
  final List<_ExpressionNode> arguments;
  final int offset;

  @override
  num evaluate(_ExpressionEnvironment environment) {
    final function = environment.resolveFunction(name, offset);
    final values = [
      for (final argument in arguments) argument.evaluate(environment),
    ];

    try {
      return function(values);
    } on ExpressionException {
      rethrow;
    } catch (error) {
      throw ExpressionEvaluationException(
        'Function "$name" failed.',
        offset: offset,
        source: environment.source,
        cause: error,
      );
    }
  }
}

enum _UnaryOperator { positive, negative }

enum _BinaryOperator {
  add('+', 10, false),
  subtract('-', 10, false),
  multiply('*', 20, false),
  divide('/', 20, false),
  modulo('%', 20, false),
  power('^', 30, true);

  const _BinaryOperator(this.symbol, this.precedence, this.isRightAssociative);

  final String symbol;
  final int precedence;
  final bool isRightAssociative;

  num apply(num left, num right) {
    return switch (this) {
      _BinaryOperator.add => left + right,
      _BinaryOperator.subtract => left - right,
      _BinaryOperator.multiply => left * right,
      _BinaryOperator.divide => left / right,
      _BinaryOperator.modulo => left % right,
      _BinaryOperator.power => math.pow(left, right),
    };
  }

  static _BinaryOperator? fromToken(_TokenType type) {
    return switch (type) {
      _TokenType.plus => _BinaryOperator.add,
      _TokenType.minus => _BinaryOperator.subtract,
      _TokenType.star => _BinaryOperator.multiply,
      _TokenType.slash => _BinaryOperator.divide,
      _TokenType.percent => _BinaryOperator.modulo,
      _TokenType.caret => _BinaryOperator.power,
      _ => null,
    };
  }
}

final class _Parser {
  _Parser(this.source, this.tokens);

  static const int _unaryPrecedence = 25;

  final String source;
  final List<_Token> tokens;
  int _current = 0;

  _ExpressionNode parse() {
    final expression = _parseExpression(0);
    _consume(
      _TokenType.eof,
      'Unexpected token "${_peek().lexeme}" after expression.',
    );
    return expression;
  }

  _ExpressionNode _parseExpression(int minPrecedence) {
    var left = _parsePrefix();

    while (true) {
      final operator = _BinaryOperator.fromToken(_peek().type);
      if (operator == null || operator.precedence < minPrecedence) break;

      _advance();
      final nextMinPrecedence = operator.isRightAssociative
          ? operator.precedence
          : operator.precedence + 1;
      final right = _parseExpression(nextMinPrecedence);
      left = _BinaryNode(operator, left, right);
    }

    return left;
  }

  _ExpressionNode _parsePrefix() {
    final token = _advance();
    return switch (token.type) {
      _TokenType.number => _LiteralNode(token.number as num),
      _TokenType.identifier => _parseIdentifier(token),
      _TokenType.plus => _UnaryNode(
        _UnaryOperator.positive,
        _parseExpression(_unaryPrecedence),
      ),
      _TokenType.minus => _UnaryNode(
        _UnaryOperator.negative,
        _parseExpression(_unaryPrecedence),
      ),
      _TokenType.leftParen => _parseGrouped(token),
      _ => throw ExpressionSyntaxException(
        'Expected expression but found "${token.lexeme}".',
        offset: token.offset,
        source: source,
      ),
    };
  }

  _ExpressionNode _parseIdentifier(_Token token) {
    if (!_match(_TokenType.leftParen)) {
      return _IdentifierNode(token.lexeme, token.offset);
    }

    final arguments = <_ExpressionNode>[];
    if (!_check(_TokenType.rightParen)) {
      do {
        arguments.add(_parseExpression(0));
      } while (_match(_TokenType.comma));
    }
    _consume(_TokenType.rightParen, 'Expected ")" after function arguments.');
    return _FunctionCallNode(token.lexeme, arguments, token.offset);
  }

  _ExpressionNode _parseGrouped(_Token token) {
    final expression = _parseExpression(0);
    _consume(_TokenType.rightParen, 'Expected ")" after grouped expression.');
    return expression;
  }

  bool _match(_TokenType type) {
    if (!_check(type)) return false;
    _advance();
    return true;
  }

  _Token _consume(_TokenType type, String message) {
    if (_check(type)) return _advance();
    final token = _peek();
    throw ExpressionSyntaxException(
      message,
      offset: token.offset,
      source: source,
    );
  }

  bool _check(_TokenType type) {
    if (_isAtEnd) return type == _TokenType.eof;
    return _peek().type == type;
  }

  _Token _advance() {
    if (!_isAtEnd) _current++;
    return tokens[_current - 1];
  }

  bool get _isAtEnd => _peek().type == _TokenType.eof;

  _Token _peek() => tokens[_current];
}

final class _Tokenizer {
  const _Tokenizer(this.source);

  final String source;

  List<_Token> tokenize() {
    final tokens = <_Token>[];
    var index = 0;

    while (index < source.length) {
      final char = source.codeUnitAt(index);
      if (_isWhitespace(char)) {
        index++;
        continue;
      }

      switch (char) {
        case 43:
          tokens.add(_Token(_TokenType.plus, '+', index));
          index++;
        case 45:
          tokens.add(_Token(_TokenType.minus, '-', index));
          index++;
        case 42:
          tokens.add(_Token(_TokenType.star, '*', index));
          index++;
        case 47:
          tokens.add(_Token(_TokenType.slash, '/', index));
          index++;
        case 37:
          tokens.add(_Token(_TokenType.percent, '%', index));
          index++;
        case 94:
          tokens.add(_Token(_TokenType.caret, '^', index));
          index++;
        case 40:
          tokens.add(_Token(_TokenType.leftParen, '(', index));
          index++;
        case 41:
          tokens.add(_Token(_TokenType.rightParen, ')', index));
          index++;
        case 44:
          tokens.add(_Token(_TokenType.comma, ',', index));
          index++;
        default:
          if (_isDigit(char) ||
              (char == 46 &&
                  index + 1 < source.length &&
                  _isDigit(source.codeUnitAt(index + 1)))) {
            final token = _readNumber(index);
            tokens.add(token);
            index += token.lexeme.length;
          } else if (_isIdentifierStart(char)) {
            final token = _readIdentifier(index);
            tokens.add(token);
            index += token.lexeme.length;
          } else {
            throw ExpressionSyntaxException(
              'Unexpected character "${source[index]}".',
              offset: index,
              source: source,
            );
          }
      }
    }

    tokens.add(_Token(_TokenType.eof, '<eof>', source.length));
    return tokens;
  }

  _Token _readNumber(int start) {
    var index = start;
    var sawDot = false;

    while (index < source.length) {
      final char = source.codeUnitAt(index);
      if (_isDigit(char)) {
        index++;
      } else if (char == 46 && !sawDot) {
        sawDot = true;
        index++;
      } else {
        break;
      }
    }

    if (index < source.length) {
      final char = source.codeUnitAt(index);
      if (char == 69 || char == 101) {
        index = _readExponent(index);
      }
    }

    final lexeme = source.substring(start, index);
    return _Token(
      _TokenType.number,
      lexeme,
      start,
      number: _parseNumber(lexeme),
    );
  }

  int _readExponent(int exponentStart) {
    var index = exponentStart + 1;
    if (index < source.length) {
      final sign = source.codeUnitAt(index);
      if (sign == 43 || sign == 45) index++;
    }

    final digitsStart = index;
    while (index < source.length && _isDigit(source.codeUnitAt(index))) {
      index++;
    }

    if (digitsStart == index) {
      throw ExpressionSyntaxException(
        'Expected exponent digits.',
        offset: exponentStart,
        source: source,
      );
    }
    return index;
  }

  _Token _readIdentifier(int start) {
    var index = start + 1;
    while (index < source.length &&
        _isIdentifierPart(source.codeUnitAt(index))) {
      index++;
    }
    return _Token(_TokenType.identifier, source.substring(start, index), start);
  }
}

enum _TokenType {
  number,
  identifier,
  plus,
  minus,
  star,
  slash,
  percent,
  caret,
  leftParen,
  rightParen,
  comma,
  eof,
}

final class _Token {
  const _Token(this.type, this.lexeme, this.offset, {this.number});

  final _TokenType type;
  final String lexeme;
  final int offset;
  final num? number;
}

num _parseNumber(String lexeme) {
  if (lexeme.contains('.') || lexeme.contains('e') || lexeme.contains('E')) {
    return double.parse(lexeme);
  }
  return int.parse(lexeme);
}

bool _isWhitespace(int codeUnit) {
  return codeUnit == 32 || codeUnit == 9 || codeUnit == 10 || codeUnit == 13;
}

bool _isDigit(int codeUnit) => codeUnit >= 48 && codeUnit <= 57;

bool _isIdentifierStart(int codeUnit) {
  return codeUnit == 95 ||
      (codeUnit >= 65 && codeUnit <= 90) ||
      (codeUnit >= 97 && codeUnit <= 122);
}

bool _isIdentifierPart(int codeUnit) {
  return _isIdentifierStart(codeUnit) || _isDigit(codeUnit);
}
