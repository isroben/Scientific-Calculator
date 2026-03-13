import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(const ScientificCalculatorApp());
}

class ScientificCalculatorApp extends StatelessWidget {
  const ScientificCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Scientific Calculator',
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}
