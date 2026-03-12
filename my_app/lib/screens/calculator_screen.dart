import 'package:flutter/material.dart';
import '../constants/calc_colors.dart';
import '../widgets/calc_button.dart';
import '../data/keypad_layout.dart';
import '../models/calc_key.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = "";

  void _onPressed(String label) {
    setState(() {
      if (label == 'CLR') {
        expression = "";
      } else if (label == '⌫') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
      } else {
        expression += label;
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
              child: Text(
                "AD BANNER SPACE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
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
                      Align(
                        alignment: Alignment.topRight,
                        child: Icon(Icons.camera_alt_outlined, size: 22, color: CalcColors.textDark),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(color: CalcColors.textDark, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.crop_free, size: 16, color: CalcColors.textDark),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10, right: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                expression.isEmpty ? '0' : expression,
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: CalcColors.textDark,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(width: 2.5, height: 32, color: CalcColors.cursor),
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
                    const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                    const SizedBox(width: 16),
                    const Text('Σ', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
                    // const Spacer(),
                    const SizedBox(width: 16),
                    const Text('RAD', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(width: 16),
                    const Text('MATH', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(width: 16),
                    const Text('DECI', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            ),

            // 4. KEYPAD
            Expanded(
              flex: 13,
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 0.0),
                child: Column(
                  children: [
                    // Scientific rows
                    _buildKeyRow(scientificKeys.sublist(0, 6), isDense: true),
                    _buildKeyRow(scientificKeys.sublist(6, 12), isDense: true),
                    _buildKeyRow(scientificKeys.sublist(12, 18), isDense: true),
                    _buildKeyRow(scientificKeys.sublist(18, 24), isDense: true),
                    _buildKeyRow(scientificKeys.sublist(24, 30), isDense: true),

                    const SizedBox(height: 4),

                    // Numeric rows
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
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
