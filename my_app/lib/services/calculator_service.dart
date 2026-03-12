import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef EvaluateExpressionNative = Double Function(Pointer<Utf8> expression);
typedef EvaluateExpression = double Function(Pointer<Utf8> expression);

class CalculatorService {
  late DynamicLibrary _lib;
  late EvaluateExpression _evaluateExpression;

  CalculatorService() {
    // Note: Ensure your CMake project name is 'calc_engine' to match libcalc_engine.so
    _lib = Platform.isAndroid
        ? DynamicLibrary.open('libcalc_engine.so')
        : DynamicLibrary.process();

    _evaluateExpression = _lib
        .lookupFunction<EvaluateExpressionNative, EvaluateExpression>('evaluate_expression');
  }

  double calculate(String uiExpression) {
    if (uiExpression.isEmpty) return 0.0;

    // STEP 1: Translate UI symbols to C++ Math Strings
    String mathString = uiExpression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('sin', 'sin(') // Add opening bracket for the engine
        .replaceAll('cos', 'cos(')
        .replaceAll('tan', 'tan(')
        .replaceAll('log', 'log(')
        .replaceAll('ln', 'ln(')
        .replaceAll('√', 'sqrt(')
        .replaceAll('π', '3.14159265359')
        .replaceAll('e', '2.71828182846');

    // Handle powers: x² -> ^2
    mathString = mathString.replaceAll('²', '^2').replaceAll('³', '^3');

    // STEP 2: Balanced Parentheses (Auto-close brackets if user forgot)
    int openBrackets = '('.allMatches(mathString).length;
    int closeBrackets = ')'.allMatches(mathString).length;
    while (openBrackets > closeBrackets) {
      mathString += ')';
      closeBrackets++;
    }

    // STEP 3: Pass to C++
    final ptr = mathString.toNativeUtf8();
    try {
      return _evaluateExpression(ptr);
    } catch (e) {
      return double.nan;
    } finally {
      malloc.free(ptr);
    }
  }
}