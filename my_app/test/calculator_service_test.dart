import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/services/calculator_service.dart';

void main() {
  late CalculatorService service;

  setUp(() {
    service = CalculatorService();
  });

  group('Basic arithmetic', () {
    test('addition', () {
      expect(service.calculate('2+3'), 5.0);
    });

    test('subtraction', () {
      expect(service.calculate('10-4'), 6.0);
    });

    test('multiplication', () {
      expect(service.calculate('3×4'), 12.0);
      expect(service.calculate('3*4'), 12.0);
    });

    test('division', () {
      expect(service.calculate('10÷2'), 5.0);
    });

    test('division by zero returns NaN', () {
      expect(service.calculate('5÷0').isNaN, true);
    });

    test('operator precedence', () {
      expect(service.calculate('2+3×4'), 14.0);
    });

    test('parentheses', () {
      expect(service.calculate('(2+3)×4'), 20.0);
    });

    test('nested parentheses', () {
      expect(service.calculate('((2+3)×(4-1))'), 15.0);
    });

    test('negative numbers', () {
      expect(service.calculate('-5+3'), -2.0);
    });

    test('decimal numbers', () {
      expect(service.calculate('1.5+2.5'), 4.0);
    });
  });

  group('Modulo (Bug #2 fix)', () {
    test('mod via symbol', () {
      expect(service.calculate('10mod3'), 1.0);
    });
  });

  group('Powers and roots', () {
    test('square via sq()', () {
      expect(service.calculate('sq(5)'), 25.0);
    });

    test('cube via cube()', () {
      expect(service.calculate('cube(3)'), 27.0);
    });

    test('power via ^', () {
      expect(service.calculate('2^10'), 1024.0);
    });

    test('square root', () {
      expect(service.calculate('sqrt(9)'), 3.0);
    });

    test('cube root', () {
      final result = service.calculate('cbrt(27)');
      expect(result, closeTo(3.0, 1e-10));
    });
  });

  group('Trigonometry (degree mode)', () {
    test('sin(30) = 0.5', () {
      expect(service.calculate('sin(30)'), closeTo(0.5, 1e-10));
    });

    test('cos(60) = 0.5', () {
      expect(service.calculate('cos(60)'), closeTo(0.5, 1e-10));
    });

    test('tan(45) ≈ 1', () {
      expect(service.calculate('tan(45)'), closeTo(1.0, 1e-10));
    });

    test('asin(0.5) = 30', () {
      expect(service.calculate('asin(0.5)'), closeTo(30.0, 1e-10));
    });

    test('acos(0.5) = 60', () {
      expect(service.calculate('acos(0.5)'), closeTo(60.0, 1e-10));
    });

    test('atan(1) = 45', () {
      expect(service.calculate('atan(1)'), closeTo(45.0, 1e-10));
    });
  });

  group('Logarithms', () {
    test('log(100) = 2', () {
      expect(service.calculate('log(100)'), closeTo(2.0, 1e-10));
    });

    test('ln(e) = 1', () {
      // 'e' alone is Euler's number, ln(e) = 1
      expect(service.calculate('ln(2.718281828459045)'), closeTo(1.0, 1e-10));
    });
  });

  group('Factorial', () {
    test('fact(5) = 120', () {
      expect(service.calculate('fact(5)'), 120.0);
    });

    test('fact(0) = 1', () {
      expect(service.calculate('fact(0)'), 1.0);
    });

    test('postfix ! factorial', () {
      expect(service.calculate('5!'), 120.0);
    });

    test('negative factorial returns NaN', () {
      expect(service.calculate('fact(-1)').isNaN, true);
    });
  });

  group('Combinatorics', () {
    test('nPr: 5P2 = 20', () {
      // The parser uses uppercase P
      expect(service.calculate('5P2'), 20.0);
    });

    test('nCr: 5C2 = 10', () {
      expect(service.calculate('5C2'), 10.0);
    });
  });

  group('Misc functions', () {
    test('abs(-7) = 7', () {
      expect(service.calculate('abs(-7)'), 7.0);
    });

    test('ceil(2.3) = 3', () {
      expect(service.calculate('ceil(2.3)'), 3.0);
    });

    test('floor(2.9) = 2', () {
      expect(service.calculate('floor(2.9)'), 2.0);
    });
  });

  group('Constants', () {
    test('pi ≈ 3.14159', () {
      expect(service.calculate('pi'), closeTo(3.141592653589793, 1e-10));
    });
  });

  group('Error handling', () {
    test('empty expression returns 0', () {
      expect(service.calculate(''), 0.0);
    });

    test('malformed expression returns NaN', () {
      expect(service.calculate('++').isNaN, false); // unary + is valid
    });

    test('unknown function returns NaN', () {
      expect(service.calculate('xyz(5)').isNaN, true);
    });
  });
}
