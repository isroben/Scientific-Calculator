import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/services/calculator_state.dart';

void main() {
  test('x n button', () {
    final state = CalculatorState();
    state.onKeyPressed('2');
    state.onKeyPressed('xⁿ');
    state.onKeyPressed('3');
    print("Expression after xn and 3: ${state.currentExpression}");
    state.onKeyPressed('=');
    print("Result after =: ${state.currentResult}");
  });
}
