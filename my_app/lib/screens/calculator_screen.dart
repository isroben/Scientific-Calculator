import 'package:flutter/material.dart';
import '../constants/calc_colors.dart';
import '../widgets/calc_button.dart';
import '../data/keypad_layout.dart';
import '../models/calc_key.dart';
import '../services/calculator_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = "";
  String result = "";

  final CalculatorService _service = CalculatorService();

  /// Formats a decimal result by grouping digits after the decimal point
  /// in blocks of three, separated by spaces.
  String _formatResult(String raw) {
    if (raw.isEmpty || raw == 'Error') return raw;
    if (!raw.contains('.')) return raw;

    final parts = raw.split('.');
    final intPart = parts[0];
    final fracPart = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < fracPart.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(fracPart[i]);
    }
    return '$intPart.${buffer.toString()}';
  }

  void _onPressed(String label) {
    setState(() {
      if (label == 'CLR' || label == 'AC') {
        expression = "";
        result = "";
      } else if (label == '⌫') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (label == '=') {
        try {
          double calcResult = _service.calculate(expression);
          if (calcResult.isNaN) {
            result = "Error";
          } else {
            String tempResult = calcResult.toString();
            if (tempResult.endsWith('.0')) {
              tempResult = tempResult.substring(0, tempResult.length - 2);
            }
            result = tempResult;
          }
        } catch (e) {
          result = "Error";
        }
      } else {
        if (result.isNotEmpty) {
          expression = label;
          result = "";
        } else {
          expression += label;
        }
      }
    });
  }

  Widget _buildKeyRow(List<CalcKey> keys, {required bool isDense}) {
    return Expanded(
      flex: isDense ? 8 : 9,
      child: Row(
        children: keys.map((key) {
          return CalcButton(
            label: key.label,
            top: key.top,
            right: key.right,
            color: key.color,
            textColor: key.textColor,
            onTap: () => _onPressed(key.label),
            fontSize: isDense ? 20 : 28,
            fontWeight: isDense ? FontWeight.normal : FontWeight.bold,
            verticalPadding: isDense ? 0.2 : 1.0,
            horizontalPadding: 3.5,
            subFontSize: 16,
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CalcColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP AD BANNER
            Container(
              height: 50,
              width: double.infinity,
              color: Colors.black,
              alignment: Alignment.center,
              child: const Text(
                "AD BANNER SPACE",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),

            // 2. DISPLAY AREA
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CalcColors.display,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Camera icon (top‑right)
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 22,
                          color: CalcColors.textDark,
                        ),
                      ),
                      // Crop icon (bottom‑left)
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: CalcColors.textDark,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.crop_free,
                            size: 16,
                            color: CalcColors.textDark,
                          ),
                        ),
                      ),
                      // Main text area (expression + result)
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Expression line (left aligned)
                              Row(
                                children: [
                                  Text(
                                    expression.isEmpty ? '0' : expression,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: CalcColors.textDark,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.normal,
                                      height: 1.0, // Tighten line height
                                    ),
                                  ),
                                  if (result.isEmpty)
                                    Container(
                                      width: 2.5,
                                      height: 28,
                                      color: CalcColors.cursor,
                                    ),
                                ],
                              ),
                              // Result line (right aligned) - Tight gap
                              if (result.isNotEmpty)
                                Text(
                                  _formatResult(result),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: CalcColors.textDark,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.normal,
                                    height: 1.0, // Tighten line height
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. TOOLBAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: SizedBox(
                height: 36,
                child: Row(
                  children: [
                    const Icon(Icons.menu, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    _buildGoProButton(),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Σ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'RAD',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'MATH',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'DECI',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            // 4. KEYPAD
            Expanded(
              flex: 13,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    _buildKeyRow(scientificKeys.sublist(0, 6), isDense: true),
                    _buildKeyRow(scientificKeys.sublist(6, 12), isDense: true),
                    _buildKeyRow(scientificKeys.sublist(12, 18), isDense: true),
                    _buildKeyRow(scientificKeys.sublist(18, 24), isDense: true),
                    _buildKeyRow(scientificKeys.sublist(24, 30), isDense: true),
                    const SizedBox(height: 4),
                    _buildKeyRow(numericKeys.sublist(0, 5), isDense: false),
                    _buildKeyRow(numericKeys.sublist(5, 10), isDense: false),
                    _buildKeyRow(numericKeys.sublist(10, 15), isDense: false),
                    _buildKeyRow(numericKeys.sublist(15, 20), isDense: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoProButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: CalcColors.goPro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'GO PRO',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
