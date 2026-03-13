import 'dart:math' as math;

/// Recursive-descent expression parser and evaluator.
///
/// Grammar (from lowest to highest precedence):
///   expression = term (('+' | '-') term)*
///   term       = factor (('*' | '/' | '%' | 'P' | 'C') factor)*
///   factor     = ['+' | '-'] atom ('^' factor)? ('!')?
///   atom       = number | constant | function '(' expression ')' | '(' expression ')'
class CalculatorService {
  // ── ASCII code points (readable names instead of magic numbers) ──────
  static const _plus = 43; // '+'
  static const _minus = 45; // '-'
  static const _star = 42; // '*'
  static const _slash = 47; // '/'
  static const _percent = 37; // '%'
  static const _caret = 94; // '^'
  static const _bang = 33; // '!'
  static const _lparen = 40; // '('
  static const _rparen = 41; // ')'
  static const _dot = 46; // '.'
  static const _zero = 48; // '0'
  static const _nine = 57; // '9'
  static const _a = 97; // 'a'
  static const _z = 122; // 'z'
  static const _space = 32;
  static const _p = 80; // nPr
  static const _c = 67; // nCr
  static const _root = 8730; // '√'

  String _expr = '';
  int _pos = -1;
  int _ch = -1;

  // ── Tokeniser helpers ────────────────────────────────────────────────

  void _nextChar() {
    _ch = (++_pos < _expr.length) ? _expr.codeUnitAt(_pos) : -1;
  }

  bool _eat(int charToEat) {
    while (_ch == _space) {
      _nextChar();
    }
    if (_ch == charToEat) {
      _nextChar();
      return true;
    }
    return false;
  }

  // ── Parser ───────────────────────────────────────────────────────────

  double _parseExpression() {
    double x = _parseTerm();
    for (;;) {
      if (_eat(_plus)) {
        x += _parseTerm();
      } else if (_eat(_minus)) {
        x -= _parseTerm();
      } else {
        return x;
      }
    }
  }

  double _parseTerm() {
    double x = _parseFactor();
    for (;;) {
      if (_eat(_star)) {
        x *= _parseFactor();
      } else if (_eat(_slash)) {
        final divisor = _parseFactor();
        x = (divisor != 0) ? x / divisor : double.nan;
      } else if (_eat(_percent)) {
        // Modulo
        x = x % _parseFactor();
      } else if (_eat(_p)) {
        // nPr
        x = _nPr(x, _parseFactor());
      } else if (_eat(_c)) {
        // nCr
        x = _nCr(x, _parseFactor());
      } else {
        return x;
      }
    }
  }

  double _parseFactor() {
    // Unary +/-
    if (_eat(_plus)) return _parseFactor();
    if (_eat(_minus)) return -_parseFactor();

    double x;
    final startPos = _pos;

    if (_eat(_lparen)) {
      // Parenthesised sub-expression
      x = _parseExpression();
      _eat(_rparen);
    } else if ((_ch >= _zero && _ch <= _nine) || _ch == _dot) {
      // Number literal
      while ((_ch >= _zero && _ch <= _nine) || _ch == _dot) {
        _nextChar();
      }
      x = double.parse(_expr.substring(startPos, _pos));
    } else if ((_ch >= _a && _ch <= _z) || _ch > 127) {
      // Identifier (function name or constant) — lowercase + non-ASCII
      while ((_ch >= _a && _ch <= _z) || _ch > 127) {
        _nextChar();
      }
      final name = _expr.substring(startPos, _pos);

      // ── Constants (no parentheses needed) ──
      if (name == 'π' || name == 'pi') {
        x = math.pi;
      } else if (name == 'e' && !_eat(_lparen)) {
        // lone 'e' without '(' is Euler's number
        x = math.e;
      } else {
        // ── Functions — parse argument ──
        if (name != 'e') {
          // normal function: expect '(' arg ')'
          if (!_eat(_lparen)) {
            // allow implicit argument (no parens)
            x = _parseFactor();
          } else {
            x = _parseExpression();
            _eat(_rparen);
          }
        } else {
          // 'e' followed by '(' — we already consumed '(' above
          x = _parseExpression();
          _eat(_rparen);
        }

        x = _applyFunction(name, x);
      }
    } else {
      return double.nan;
    }

    // Post-fix operators (right-to-left for ^, and infix for √)
    if (_eat(_caret)) x = math.pow(x, _parseFactor()).toDouble();
    if (_eat(_bang)) x = _factorial(x);
    if (_eat(_root)) {
      final radicand = _parseFactor();
      if (radicand < 0 && x % 2 != 0 && x % 1 == 0) {
        x = -math.pow(-radicand, 1 / x).toDouble();
      } else {
        x = math.pow(radicand, 1 / x).toDouble();
      }
    }

    return x;
  }

  // ── Function dispatch ────────────────────────────────────────────────

  double _applyFunction(String name, double x) {
    switch (name) {
      // Roots
      case 'sqrt':
      case '√':
        return math.sqrt(x);
      case 'cbrt':
        return math.pow(x, 1 / 3).toDouble();

      // Powers / convenience
      case 'sq':
        return x * x;
      case 'cube':
        return x * x * x;

      // Trigonometric (input in degrees)
      case 'sin':
        return math.sin(_toRadians(x));
      case 'cos':
        return math.cos(_toRadians(x));
      case 'tan':
        return math.tan(_toRadians(x));
      case 'cot':
        return 1 / math.tan(_toRadians(x));

      // Inverse trigonometric (output in degrees)
      case 'asin':
        return _toDegrees(math.asin(x));
      case 'acos':
        return _toDegrees(math.acos(x));
      case 'atan':
        return _toDegrees(math.atan(x));
      case 'acot':
        return _toDegrees(math.atan(1 / x));

      // Hyperbolic
      case 'sinh':
        return _sinh(x);
      case 'cosh':
        return _cosh(x);
      case 'tanh':
        return _tanh(x);

      // Logarithmic
      case 'log':
        return math.log(x) / math.ln10;
      case 'ln':
        return math.log(x);

      // Misc
      case 'abs':
        return x.abs();
      case 'fact':
        return _factorial(x);
      case 'ceil':
        return x.ceilToDouble();
      case 'floor':
        return x.floorToDouble();

      // e^x handled via caret
      case 'e':
        return math.pow(math.e, x).toDouble();

      default:
        return double.nan;
    }
  }

  // ── Maths helpers ────────────────────────────────────────────────────

  double _toRadians(double deg) => deg * math.pi / 180.0;
  double _toDegrees(double rad) => rad * 180.0 / math.pi;

  double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
  double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
  double _tanh(double x) => _sinh(x) / _cosh(x);

  double _factorial(double n) {
    if (n < 0 || n > 170) return double.nan;
    if (n == 0) return 1;
    double res = 1;
    for (int i = 2; i <= n.toInt(); i++) {
      res *= i;
    }
    return res;
  }

  double _nPr(double n, double r) {
    if (r > n || n < 0 || r < 0) return double.nan;
    return _factorial(n) / _factorial(n - r);
  }

  double _nCr(double n, double r) {
    if (r > n || n < 0 || r < 0) return double.nan;
    return _factorial(n) / (_factorial(r) * _factorial(n - r));
  }

  // ── Public API ───────────────────────────────────────────────────────

  /// Evaluate a UI expression string (with Unicode operators) and return
  /// the numeric result. Returns [double.nan] on any error.
  double calculate(String uiExpression) {
    if (uiExpression.isEmpty) return 0.0;

    final mathString = uiExpression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('mod', '%')
        .replaceAll('π', 'pi')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('ⁿ', '^')
        .replaceAll('∛', 'cbrt')
        .replaceAll(' ', '');

    _expr = mathString;
    _pos = -1;
    _nextChar();

    try {
      final result = _parseExpression();
      if (_pos < _expr.length) return double.nan;
      return result;
    } catch (_) {
      return double.nan;
    }
  }
}
