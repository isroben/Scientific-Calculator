import 'dart:math' as math;

enum AngleUnit { degree, radian, gradian }
enum ImpliedMultiplication { type1, type2 }
enum PercentageType { type1, type2 }

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
  static const _modulo = 126; // '~'
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
  static const _A = 65; // 'A'
  static const _Z = 90; // 'Z'
  static const _root = 8730; // '√'

  String _expr = '';
  int _pos = -1;
  int _ch = -1;
  Map<String, double> _variables = {};
  AngleUnit angleUnit = AngleUnit.degree;
  ImpliedMultiplication impliedMultiplication = ImpliedMultiplication.type1;
  PercentageType percentageType = PercentageType.type2;

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
        double startPos = _pos.toDouble();
        double term = _parseTerm();
        if (percentageType == PercentageType.type1 && _isLastWasPercentage()) {
          x += (x * term);
        } else {
          x += term;
        }
      } else if (_eat(_minus)) {
        double term = _parseTerm();
        if (percentageType == PercentageType.type1 && _isLastWasPercentage()) {
          x -= (x * term);
        } else {
          x -= term;
        }
      } else {
        return x;
      }
    }
  }

  bool _isLastWasPercentage() {
    // Check if the character before current position (after parsing term) was '%'
    // This is a bit of a hack but avoids changing the whole grammar to pass flags.
    int p = _pos - 1;
    while (p >= 0 && _expr.codeUnitAt(p) == _space) p--;
    return p >= 0 && _expr.codeUnitAt(p) == _percent;
  }

  double _parseTerm() {
    double x = _parseFactor();
    for (;;) {
      if (_eat(_star)) {
        x *= _parseFactor();
      } else if (_eat(_slash)) {
        final divisor = _parseFactor();
        x = (divisor != 0) ? x / divisor : double.nan;
      } else if (_eat(_modulo)) {
        // Modulo
        x = x % _parseFactor();
      } else if (_eat(_p)) {
        x = _nPr(x, _parseFactor());
      } else if (_eat(_c)) {
        x = _nCr(x, _parseFactor());
      } else if (impliedMultiplication == ImpliedMultiplication.type1 && _isNextAtom()) {
        // Implied multiplication Type 1: Same precedence as * /
        x *= _parseFactor();
      } else {
        return x;
      }
    }
  }

  bool _isNextAtom() {
    while (_ch == _space) _nextChar();
    return (_ch >= _zero && _ch <= _nine) || 
           (_ch >= _a && _ch <= _z) || 
           (_ch >= _A && _ch <= _Z) || 
           (_ch == _lparen) || 
           (_ch > 127);
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
    } else if ((_ch >= _a && _ch <= _z) || (_ch >= _A && _ch <= _Z) || _ch == 95 || _ch > 127) {
      // Identifier (function name or constant)
      while ((_ch >= _a && _ch <= _z) || (_ch >= _A && _ch <= _Z) || _ch == 95 || _ch > 127) {
        _nextChar();
      }
      final name = _expr.substring(startPos, _pos).toLowerCase();

      // ── Constants & Variables (no parentheses needed) ──
      if (name == 'π' || name == 'pi') {
        x = math.pi;
      } else if (name == 'e' && !_eat(_lparen)) {
        x = math.e;
      } else if (name == 'log_') {
        _eat(_lparen);
        double base = _parseExpression();
        _eat(_rparen);
        double arg = _parseFactor(); // Argument is the next factor
        x = math.log(arg) / math.log(base);
      } else if (_variables.containsKey(name)) {
        x = _variables[name]!;
      } else if (name == 'x') {
        x = _variables['x'] ?? 0.0;
      } else {
        // ── Functions ──
        if (name == 'diff') {
          _eat(_lparen);
          int start = _pos;
          int parens = 0;
          while (_ch != -1 && !(_ch == 44 && parens == 0)) {
            if (_ch == _lparen) parens++;
            if (_ch == _rparen) parens--;
            _nextChar();
          }
          String subExpr = _expr.substring(start, _pos);
          _eat(44); // ','
          double val = _parseExpression();
          _eat(_rparen);

          const h = 0.000001;
          double y2 = (CalculatorService()..angleUnit = angleUnit..impliedMultiplication = impliedMultiplication..percentageType = percentageType).evaluate(subExpr, vars: {..._variables, 'x': val + h});
          double y1 = (CalculatorService()..angleUnit = angleUnit..impliedMultiplication = impliedMultiplication..percentageType = percentageType).evaluate(subExpr, vars: {..._variables, 'x': val - h});
          x = (y2 - y1) / (2 * h);
        } else if (name == 'integral') {
          _eat(_lparen);
          int start = _pos;
          int parens = 0;
          while (_ch != -1 && !(_ch == 44 && parens == 0)) {
            if (_ch == _lparen) parens++;
            if (_ch == _rparen) parens--;
            _nextChar();
          }
          String subExpr = _expr.substring(start, _pos);
          _eat(44); // ','
          double lower = _parseExpression();
          _eat(44); // ','
          double upper = _parseExpression();
          _eat(_rparen);
          x = _integral(subExpr, lower, upper);
        } else if (name == 'prod' || name == 'sum') {
          _eat(_lparen);
          int start = _pos;
          int parens = 0;
          while (_ch != -1 && !(_ch == 44 && parens == 0)) {
            if (_ch == _lparen) parens++;
            if (_ch == _rparen) parens--;
            _nextChar();
          }
          String subExpr = _expr.substring(start, _pos);
          _eat(44);
          int startVal = _parseExpression().toInt();
          _eat(44);
          int endVal = _parseExpression().toInt();
          _eat(_rparen);

          x = (name == 'sum') ? 0 : 1;
          for (int i = startVal; i <= endVal; i++) {
            double temp = (CalculatorService()..angleUnit = angleUnit..impliedMultiplication = impliedMultiplication..percentageType = percentageType).evaluate(subExpr, vars: {..._variables, 'x': i.toDouble()});
            if (name == 'sum') x += temp; else x *= temp;
          }
        } else if (name == 'gcd' || name == 'lcm' || name == 'ranint') {
          _eat(_lparen);
          double a = _parseExpression();
          _eat(44);
          double b = _parseExpression();
          _eat(_rparen);
          if (name == 'gcd') x = _gcd(a.toInt(), b.toInt()).toDouble();
          else if (name == 'lcm') x = _lcm(a.toInt(), b.toInt()).toDouble();
          else x = (a.toInt() + math.Random().nextInt(b.toInt() - a.toInt() + 1)).toDouble();
        } else if (name == 'avg') {
          _eat(_lparen);
          List<double> args = [];
          args.add(_parseExpression());
          while (_eat(44)) { // ','
            args.add(_parseExpression());
          }
          _eat(_rparen);
          x = args.isEmpty ? 0 : args.reduce((a, b) => a + b) / args.length;
        } else if (name != 'e') {
          // normal function: expect '(' arg ')'
          if (_eat(_lparen)) {
            x = _parseExpression();
            _eat(_rparen);
            x = _applyFunction(name, x);
          } else {
            // allow implicit argument (no parens)
            x = _parseFactor();
            x = _applyFunction(name, x);
          }
        } else {
          // 'e' followed by '('
          if (_eat(_lparen)) {
            x = _parseExpression();
            _eat(_rparen);
            x = _applyFunction(name, x);
          } else {
            x = math.e;
          }
        }
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

    // Implied multiplication Type 2: Higher precedence
    if (impliedMultiplication == ImpliedMultiplication.type2 && _isNextAtom()) {
      x *= _parseFactor();
    }

    // Percentage postfix (Note: different from modulo which is infix in _parseTerm)
    if (_eat(_percent)) {
      x /= 100.0;
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
        return math.sin(_maybeToRadians(x));
      case 'cos':
        return math.cos(_maybeToRadians(x));
      case 'tan':
        return math.tan(_maybeToRadians(x));
      case 'cot':
        return 1 / math.tan(_maybeToRadians(x));

      // Inverse trigonometric (output in degrees if degree mode)
      case 'asin':
        return _maybeFromRadians(math.asin(x));
      case 'acos':
        return _maybeFromRadians(math.acos(x));
      case 'atan':
        return _maybeFromRadians(math.atan(x));
      case 'acot':
        return _maybeFromRadians(math.atan(1 / x));

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

  double _maybeToRadians(double val) {
    switch (angleUnit) {
      case AngleUnit.degree: return val * math.pi / 180.0;
      case AngleUnit.gradian: return val * math.pi / 200.0;
      case AngleUnit.radian: return val;
    }
  }

  double _maybeFromRadians(double rad) {
    switch (angleUnit) {
      case AngleUnit.degree: return rad * 180.0 / math.pi;
      case AngleUnit.gradian: return rad * 200.0 / math.pi;
      case AngleUnit.radian: return rad;
    }
  }

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

  int _gcd(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  int _lcm(int a, int b) => (a * b) ~/ _gcd(a, b);

  double _integral(String expr, double a, double b) {
    const n = 1000; // Number of steps (should be even)
    double h = (b - a) / n;
    
    double sum = (CalculatorService()..angleUnit = angleUnit..impliedMultiplication = impliedMultiplication..percentageType = percentageType).evaluate(expr, vars: {..._variables, 'x': a}) +
                 (CalculatorService()..angleUnit = angleUnit..impliedMultiplication = impliedMultiplication..percentageType = percentageType).evaluate(expr, vars: {..._variables, 'x': b});

    for (int i = 1; i < n; i++) {
      double x = a + i * h;
      double val = (CalculatorService()..angleUnit = angleUnit..impliedMultiplication = impliedMultiplication..percentageType = percentageType).evaluate(expr, vars: {..._variables, 'x': x});
      if (i % 2 == 0) {
        sum += 2 * val;
      } else {
        sum += 4 * val;
      }
    }

    return (h / 3) * sum;
  }

  // ── Public API ───────────────────────────────────────────────────────

  double calculate(String uiExpression) {
    return evaluate(uiExpression);
  }

  /// Internal evaluation engine.
  double evaluate(String expression, {Map<String, double> vars = const {}}) {
    if (expression.isEmpty) return 0.0;

    final mathString = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('mod', '~')
        .replaceAll('π', 'pi')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('ⁿ', '^')
        .replaceAll('∛', 'cbrt')
        .replaceAll('⁻¹', '^-1')
        .replaceAll('Σ', 'sum')
        .replaceAll('Π', 'prod')
        .replaceAll('∫d', 'integral')
        .replaceAll('∫', 'integral')
        .replaceAll('d/dx', 'diff')
        .replaceAllMapped(RegExp(r'd\((.*?)\)/dx'), (match) => 'diff(${match.group(1)})')
        .replaceAll(' ', '');

    _expr = mathString;
    _pos = -1;
    _variables = Map.from(vars);
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
