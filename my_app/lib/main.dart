import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/calculator_state.dart';
import 'services/global_state.dart';

void main() {
  runApp(const ScientificCalculatorApp());
}

class ScientificCalculatorApp extends StatelessWidget {
  const ScientificCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: globalCalculatorState,
      builder: (context, child) {
        return MaterialApp(
          title: 'Scientific Calculator',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            textTheme: GoogleFonts.getTextTheme(globalCalculatorState.appFontFamily),
          ),
          home: const CalculatorScreen(),
        );
      },
    );
  }
}
