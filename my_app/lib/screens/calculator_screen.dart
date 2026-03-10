import 'package:flutter/material.dart';
import '../widgets/calc_button.dart';
import '../constants/colors.dart';
import '../services/calculator_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';
  late CalculatorService _calcService;

  @override
  void initState() {
    super.initState();
    try {
      _calcService = CalculatorService();
    } catch (e) {
      debugPrint('FFI Initialization failed: $e');
    }
  }

  void _onButtonPressed(String label) {
    setState(() {
      if (label == 'CLR') {
        _expression = '';
        _result = '';
      } else if (label == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (label == '=') {
        try {
          final evalResult = _calcService.evaluate(_expression);
          _result = evalResult.toString();
        } catch (e) {
          _result = 'Error';
        }
      } else if (label == 'Ans') {
        _expression += _result;
      } else {
        // Simple mapping for display vs logic
        String toAdd = label;
        if (label == '×') toAdd = '*';
        if (label == '÷') toAdd = '/';
        if (label == 'Exp') toAdd = 'e';
        _expression += toAdd;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.displayBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Icon(Icons.camera_alt_outlined, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      _expression,
                      style: const TextStyle(fontSize: 24, color: Colors.black, fontFamily: 'monospace'),
                    ),
                    Text(
                      _result.isNotEmpty ? '= $_result' : '',
                      style: const TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Toolbar (Skipping options, settings, go pro as requested)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.menu, color: Colors.transparent), // Placeholder for menu
                  const Spacer(),
                  const Text('Σ', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 8),
                  const Text('RAD', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 8),
                  const Text('MATH', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 8),
                  const Text('DECI', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),

            // Buttons Area
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRow(['SHIFT', 'ALPHA', '◀', '▶', 'MODE', '≫']),
                      _buildRow(['OPTN', 'CALC', '▲', '▼', '∫dx', 'x']),
                      _buildRow(['□/□', '√', 'x²', 'xᐞ', 'Log', 'Ln']),
                      _buildRow(['(-)', '°\'\"', 'hyp', 'Sin', 'Cos', 'Tan']),
                      _buildRow(['STO', 'ENG', '(', ')', 'S⇔D', 'M+']),
                      const SizedBox(height: 8),
                      _buildRow(['7', '8', '9', '⌫', 'CLR'], isNumeric: true),
                      _buildRow(['4', '5', '6', '×', '÷'], isNumeric: true),
                      _buildRow(['1', '2', '3', '+', '-'], isNumeric: true),
                      _buildRow(['0', '.', 'Exp', 'Ans', '='], isNumeric: true),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> labels, {bool isNumeric = false}) {
    return Row(
      children: labels.map((label) {
        Color bgColor = AppColors.functionButton;
        Color textColor = Colors.white;
        
        if (label == 'SHIFT') {
          bgColor = AppColors.shiftButton;
          textColor = Colors.black;
        } else if (label == 'ALPHA') {
          bgColor = AppColors.alphaButton;
          textColor = Colors.black;
        } else if (RegExp(r'^[0-9.]$').hasMatch(label) || label == 'Exp') {
          bgColor = AppColors.numberButton;
        } else if (['+', '-', '×', '÷', '=', 'Ans'].contains(label)) {
          bgColor = Colors.white;
          textColor = Colors.black;
        } else if (['⌫', 'CLR'].contains(label)) {
          bgColor = const Color(0xFF60646B);
        }

        return CalcButton(
          label: label,
          backgroundColor: bgColor,
          textColor: textColor,
          onPressed: () => _onButtonPressed(label),
        );
      }).toList(),
    );
  }
}
