import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef EvaluateExpressionNative = Double Function(Pointer<Utf8> expression);
typedef EvaluateExpression = double Function(Pointer<Utf8> expression);

typedef MathFuncNative = Double Function(Double value);
typedef MathFunc = double Function(double value);

class CalculatorService {
  late DynamicLibrary _lib;
  late EvaluateExpression _evaluateExpression;
  late MathFunc _sin;
  late MathFunc _cos;
  late MathFunc _tan;
  late MathFunc _sqrt;

  CalculatorService() {
    _lib = Platform.isAndroid
        ? DynamicLibrary.open('libcalculator_native.so')
        : DynamicLibrary.process();

    _evaluateExpression = _lib
        .lookup<NativeFunction<EvaluateExpressionNative>>('evaluate_expression')
        .asFunction();

    _sin = _lib.lookup<NativeFunction<MathFuncNative>>('calculate_sin').asFunction();
    _cos = _lib.lookup<NativeFunction<MathFuncNative>>('calculate_cos').asFunction();
    _tan = _lib.lookup<NativeFunction<MathFuncNative>>('calculate_tan').asFunction();
    _sqrt = _lib.lookup<NativeFunction<MathFuncNative>>('calculate_sqrt').asFunction();
  }

  double evaluate(String expression) {
    final ptr = expression.toNativeUtf8();
    try {
      return _evaluateExpression(ptr);
    } finally {
      malloc.free(ptr);
    }
  }

  double sin(double val) => _sin(val);
  double cos(double val) => _cos(val);
  double tan(double val) => _tan(val);
  double sqrt(double val) => _sqrt(val);
}
