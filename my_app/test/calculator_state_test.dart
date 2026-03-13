import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/services/calculator_state.dart';

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
      expect(state.isFractionDisplay, true);
      state.onKeyPressed('S⇔D');
      expect(state.isFractionDisplay, false);
      state.onKeyPressed('S⇔D');
      expect(state.isFractionDisplay, true);
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
}
