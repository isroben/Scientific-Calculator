import 'dart:math' as math;

class CalculatorService {
  String _expr = "";
  int _pos = -1;
  int _ch = -1;

  void _nextChar() {
    _ch = (++_pos < _expr.length) ? _expr.codeUnitAt(_pos) : -1;
  }

  bool _eat(int charToEat) {
    while (_ch == 32) { // space
      _nextChar();
    }
    if (_ch == charToEat) {
      _nextChar();
      return true;
    }
    return false;
  }

  double _parseExpression() {
    double x = _parseTerm();
    for (;;) {
      if (_eat(43)) { // +
        x += _parseTerm();
      } else if (_eat(45)) { // -
        x -= _parseTerm();
      } else {
        return x;
      }
    }
  }

  double _parseTerm() {
    double x = _parseFactor();
    for (;;) {
      if (_eat(42)) { // *
        x *= _parseFactor();
      } else if (_eat(47)) { // /
        double divisor = _parseFactor();
        x = (divisor != 0) ? x / divisor : double.nan;
      } else if (_eat(80)) { // P (nPr)
        x = _nPr(x, _parseFactor());
      } else if (_eat(67)) { // C (nCr)
        x = _nCr(x, _parseFactor());
      } else {
        return x;
      }
    }
  }

  double _parseFactor() {
    if (_eat(43)) return _parseFactor(); // +
    if (_eat(45)) return -_parseFactor(); // -

    double x;
    int startPos = _pos;
    if (_eat(40)) { // (
      x = _parseExpression();
      _eat(41); // )
    } else if ((_ch >= 48 && _ch <= 57) || _ch == 46) { // 0-9 or .
      while ((_ch >= 48 && _ch <= 57) || _ch == 46) {
        _nextChar();
      }
      x = double.parse(_expr.substring(startPos, _pos));
    } else if (_ch >= 97 && _ch <= 122 || _ch > 127) { // a-z or non-ascii (like symbols)
      while (_ch >= 97 && _ch <= 122 || _ch > 127) {
        _nextChar();
      }
      String func = _expr.substring(startPos, _pos);
      if (func == "pi" || func == "π") {
        x = math.pi;
      } else if (func == "e") {
        x = math.e;
      } else {
        if (_eat(40)) {
          x = _parseExpression();
          _eat(41);
        } else {
          x = _parseFactor();
        }
        if (func == "sqrt" || func == "√") {
          x = math.sqrt(x);
        } else if (func == "sin") {
          x = math.sin(x * math.pi / 180.0);
        } else if (func == "cos") {
          x = math.cos(x * math.pi / 180.0);
        } else if (func == "tan") {
          x = math.tan(x * math.pi / 180.0);
        } else if (func == "log") {
          x = math.log(x) / math.ln10;
        } else if (func == "ln") {
          x = math.log(x);
        } else if (func == "abs") {
          x = x.abs();
        } else if (func == "fact") {
          x = _factorial(x);
        } else if (func == "ceil") {
          x = x.ceilToDouble();
        } else if (func == "floor") {
          x = x.floorToDouble();
        } else {
          return double.nan;
        }
      }
    } else {
      return double.nan;
    }

    if (_eat(94)) x = math.pow(x, _parseFactor()).toDouble(); // ^
    if (_eat(33)) x = _factorial(x); // !

    return x;
  }

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

  double calculate(String uiExpression) {
    if (uiExpression.isEmpty) return 0.0;

    String mathString = uiExpression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('mod', '%')
        .replaceAll('sin', 'sin')
        .replaceAll('cos', 'cos')
        .replaceAll('tan', 'tan')
        .replaceAll('log', 'log')
        .replaceAll('ln', 'ln')
        .replaceAll('√', 'sqrt')
        .replaceAll('π', 'pi')
        .replaceAll('e', 'e')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('ⁿ', '^')
        .replaceAll(' ', '');

    _expr = mathString;
    _pos = -1;
    _nextChar();
    try {
      double result = _parseExpression();
      if (_pos < _expr.length) return double.nan;
      return result;
    } catch (e) {
      return double.nan;
    }
  }
}
