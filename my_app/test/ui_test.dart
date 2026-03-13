import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/screens/calculator_screen.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('x n button visual feedback', (tester) async {
    await tester.pumpWidget(const ScientificCalculatorApp());
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('xⁿ'));
    await tester.pump();
    
    // Check if there is some superscript visual indicator like '□' or at least '^'
  });
}
