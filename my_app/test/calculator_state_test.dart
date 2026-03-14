import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/services/calculator_state.dart';
import 'package:my_app/services/calculator_service.dart';

void main() {
  late CalculatorState state;

  setUp(() {
    state = CalculatorState();
  });

  tearDown(() {
    state.dispose();
  });

  group('Basic input', () {
    test('digits append to expression', () {
      state.onKeyPressed('1');
      state.onKeyPressed('2');
      state.onKeyPressed('3');
      expect(state.currentExpression, '123');
    });

    test('operators append to expression', () {
      state.onKeyPressed('1');
      state.onKeyPressed('+');
      state.onKeyPressed('2');
      expect(state.currentExpression, '1+2');
    });

    test('dot appends to expression', () {
      state.onKeyPressed('1');
      state.onKeyPressed('.');
      state.onKeyPressed('5');
      expect(state.currentExpression, '1.5');
    });
  });

  group('Equals and results', () {
    test('equals evaluates expression', () {
      state.onKeyPressed('2');
      state.onKeyPressed('+');
      state.onKeyPressed('3');
      state.onKeyPressed('=');
      expect(state.currentResult, '5');
      expect(state.isShowingResult, true);
    });

    test('equals on empty expression does nothing', () {
      state.onKeyPressed('=');
      expect(state.currentResult, '');
      expect(state.isShowingResult, false);
    });
  });

  group('History (Bug #1 fix)', () {
    test('pressing digit after result saves expression to history', () {
      state.onKeyPressed('2');
      state.onKeyPressed('+');
      state.onKeyPressed('3');
      state.onKeyPressed('=');
      // Now press a new digit — previous result should go to history
      state.onKeyPressed('5');
      expect(state.history.length, 1);
      expect(state.history[0].expression, '2+3');
      expect(state.history[0].result, '5');
      // New expression should be started
      expect(state.currentExpression, '5');
    });

    test('multiple calculations build history', () {
      // First calculation
      state.onKeyPressed('1');
      state.onKeyPressed('+');
      state.onKeyPressed('1');
      state.onKeyPressed('=');

      // Start second
      state.onKeyPressed('2');
      state.onKeyPressed('+');
      state.onKeyPressed('2');
      state.onKeyPressed('=');

      // Start third
      state.onKeyPressed('3');

      expect(state.history.length, 2);
      expect(state.history[0].expression, '1+1');
      expect(state.history[0].result, '2');
      expect(state.history[1].expression, '2+2');
      expect(state.history[1].result, '4');
    });
  });

  group('Clear operations', () {
    test('CLR clears current expression and result', () {
      state.onKeyPressed('1');
      state.onKeyPressed('+');
      state.onKeyPressed('2');
      state.onKeyPressed('=');
      state.onKeyPressed('CLR');
      expect(state.currentExpression, '');
      expect(state.currentResult, '');
      expect(state.isShowingResult, false);
    });

    test('backspace removes last character', () {
      state.onKeyPressed('1');
      state.onKeyPressed('2');
      state.onKeyPressed('3');
      state.onKeyPressed('⌫');
      expect(state.currentExpression, '12');
    });

    test('backspace after result clears result', () {
      state.onKeyPressed('5');
      state.onKeyPressed('=');
      state.onKeyPressed('⌫');
      expect(state.isShowingResult, false);
      expect(state.currentResult, '');
    });
  });

  group('Shift and Alpha modes', () {
    test('SHIFT toggles on and off', () {
      state.onKeyPressed('SHIFT');
      expect(state.shift, true);
      state.onKeyPressed('SHIFT');
      expect(state.shift, false);
    });

    test('ALPHA toggles on and off', () {
      state.onKeyPressed('ALPHA');
      expect(state.alpha, true);
      state.onKeyPressed('ALPHA');
      expect(state.alpha, false);
    });

    test('SHIFT turns off ALPHA', () {
      state.onKeyPressed('ALPHA');
      state.onKeyPressed('SHIFT');
      expect(state.shift, true);
      expect(state.alpha, false);
    });

    test('shift resets after key press', () {
      state.onKeyPressed('SHIFT');
      expect(state.shift, true);
      state.onKeyPressed('7'); // pressing any key should reset shift
      expect(state.shift, false);
    });
  });

  group('Memory operations', () {
    test('M+ stores and RCL recalls', () {
      state.onKeyPressed('5');
      state.onKeyPressed('=');
      state.onKeyPressed('M+');
      // Clear and recall
      state.onKeyPressed('CLR');
      state.onKeyPressed('RCL');
      expect(state.currentExpression, '5.0');
    });
  });

  group('Fraction toggle', () {
    test('S⇔D toggles fraction display', () {
      state.onKeyPressed('1');
      state.onKeyPressed('÷');
      state.onKeyPressed('3');
      state.onKeyPressed('=');
      state.onKeyPressed('1');
      state.onKeyPressed('÷');
      state.onKeyPressed('3');
      state.onKeyPressed('=');
      // Default is DECI (false), so isFractionDisplay should be false
      expect(state.isFractionDisplay, false);
      state.onKeyPressed('S⇔D');
      expect(state.isFractionDisplay, true);
      state.onKeyPressed('S⇔D');
      expect(state.isFractionDisplay, false);
    });
  });

  group('Scientific functions via labels', () {
    test('Sin key inserts sin( into expression', () {
      state.onKeyPressed('Sin');
      expect(state.currentExpression, 'sin(');
    });

    test('SHIFT + Sin key inserts asin(', () {
      state.onKeyPressed('SHIFT');
      state.onKeyPressed('Sin');
      expect(state.currentExpression, 'asin(');
    });
  });

  group('formatDecimal utility', () {
    test('formats decimals with spaces', () {
      expect(formatDecimal('3.141592'), '3.141 592');
    });

    test('returns integers unchanged', () {
      expect(formatDecimal('42'), '42');
    });

    test('returns Error unchanged', () {
      expect(formatDecimal('Error'), 'Error');
    });
  });

  group('New Functions and Modes', () {
    test('MODE toggles angleUnit', () {
      expect(state.angleUnit, AngleUnit.degree);
      state.onKeyPressed('MODE');
      expect(state.angleUnit, AngleUnit.radian);
      state.onKeyPressed('MODE');
      expect(state.angleUnit, AngleUnit.gradian);
      state.onKeyPressed('MODE');
      expect(state.angleUnit, AngleUnit.degree);
    });

    test('SHIFT + ∫dx (d/dx) inserts diff(', () {
      state.onKeyPressed('SHIFT');
      state.onKeyPressed('∫dx');
      expect(state.currentExpression, 'diff(');
    });

    test('SHIFT + x² (x³) inserts ³', () {
      state.onKeyPressed('SHIFT');
      state.onKeyPressed('x²');
      expect(state.currentExpression, '³');
    });

    test('SHIFT + xⁿ (ⁿ√x) inserts √( and moves cursor', () {
      state.onKeyPressed('SHIFT');
      state.onKeyPressed('xⁿ');
      expect(state.currentExpression, '√(');
      // "√(" length is 2. Cursor starts at 0, inserts "√(" -> cursor at 2.
      // then moves back by 2 -> cursor at 0.
      expect(state.cursorPosition, 0);
    });
  });

  group('ALPHA Functionality and Variables', () {
    test('ALPHA + ) inserts variable x', () {
      state.onKeyPressed('ALPHA');
      state.onKeyPressed(')');
      expect(state.currentExpression, 'x');
    });

    // Note: STO is current mapped to just _memory for simplicity in state,
    // but variables A-F, M, X, Y, T work as identifiers in expressions.
    test('Using variable x in expression', () {
      state.onKeyPressed('ALPHA');
      state.onKeyPressed(')'); // inserts 'x'
      state.onKeyPressed('+');
      state.onKeyPressed('5');
      state.onKeyPressed('=');
      // x defaults to 0
      expect(state.currentResult, '5');
    });

    test('PreAns holds previous result', () {
      state.onKeyPressed('2');
      state.onKeyPressed('+');
      state.onKeyPressed('2');
      state.onKeyPressed('='); // Result 4, lastAns 0 -> result
      state.onKeyPressed('3');
      state.onKeyPressed('+');
      state.onKeyPressed('3');
      state.onKeyPressed('='); // Result 6, lastAns 4
      state.onKeyPressed('CLR');
      state.onKeyPressed('ALPHA');
      state.onKeyPressed('Ans'); // PreAns label on Ans key
      expect(state.currentExpression, '4.0');
    });

    test('CLRv clears variables', () {
      state.onKeyPressed('ALPHA');
      state.onKeyPressed('RCL'); // CLRv label on RCL key
      // This calls _vars.updateAll to 0.0.
      expect(state.currentExpression, '');
    });

    test('ALPHA + × inserts GCD', () {
      state.onKeyPressed('ALPHA');
      state.onKeyPressed('×');
      expect(state.currentExpression, 'gcd(');
    });
  });

  group('Default Output Mode (DECI/FRAC)', () {
    test('toggleOutputMode changes isDefaultFractional', () {
      expect(state.isDefaultFractional, false);
      state.toggleOutputMode();
      expect(state.isDefaultFractional, true);
      state.toggleOutputMode();
      expect(state.isDefaultFractional, false);
    });

    test('default mode affects result display', () {
      // Set mode to FRAC (Fractional default)
      state.toggleOutputMode();
      expect(state.isDefaultFractional, true);

      // Perform a calculation (1 ÷ 3)
      state.onKeyPressed('1');
      state.onKeyPressed('÷');
      state.onKeyPressed('3');
      state.onKeyPressed('=');

      // isFractionDisplay should be true (matching isDefaultFractional)
      expect(state.isFractionDisplay, true);

      // Reset and set mode to DECI (Decimal default)
      state.onKeyPressed('CLR');
      state.toggleOutputMode();
      expect(state.isDefaultFractional, false);

      // Perform a calculation (1 ÷ 3)
      state.onKeyPressed('1');
      state.onKeyPressed('÷');
      state.onKeyPressed('3');
      state.onKeyPressed('=');

      // isFractionDisplay should be false
      expect(state.isFractionDisplay, false);
    });
  });
}
