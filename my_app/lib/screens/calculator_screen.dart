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
            // 1. Display Area (Redesigned for Pixel-Perfect match)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.28,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.displayBackground,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 12,
                      left: 12,
                      child: Icon(Icons.camera_alt_outlined, size: 24, color: AppColors.textDark),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textDark, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.camera_enhance_outlined, size: 18, color: AppColors.textDark),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 25, right: 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _expression.isEmpty ? '0' : _expression,
                              style: const TextStyle(
                                fontSize: 36,
                                color: AppColors.textDark,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 3,
                              height: 34,
                              color: AppColors.displayCursor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.menu, color: Colors.white, size: 30),
                  const SizedBox(width: 12),
                  _buildGoProButton(),
                  const SizedBox(width: 12),
                  const Icon(Icons.settings_outlined, color: Colors.white, size: 26),
                  const SizedBox(width: 10),
                  const Text('Σ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  _buildToolbarTag('RAD'),
                  _buildToolbarTag('MATH'),
                  _buildToolbarTag('DECI'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 3. Button Grid (Matching the reference layout)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    _row([
                      _btn('SHIFT', bg: AppColors.shiftGreen, tx: Colors.black),
                      _btn('ALPHA', bg: AppColors.alphaBlue, tx: Colors.black),
                      _btn('', icon: const Icon(Icons.arrow_left, color: Colors.white, size: 28)),
                      _btn('', icon: const Icon(Icons.arrow_right, color: Colors.white, size: 28)),
                      _btn('MODE'),
                      _btn('≫'),
                    ]),
                    _row([
                      _btn('OPTN', st: 'SOLVE', sr: '='),
                      _btn('CALC', st: 'd/dx', sr: ':'),
                      _btn('▲'),
                      _btn('▼'),
                      _btn('∫dx', st: 'Σ', sr: 'Π'),
                      _btn('x', sr: ':'),
                    ]),
                    _row([
                      _btn('□/□', st: '÷R'),
                      _btn('√', st: '∛', sr: 'mod'),
                      _btn('x²', st: 'x³', sr: '■'),
                      _btn('xᐞ', st: '√', sr: 'Cot'),
                      _btn('Log', st: '10ᐞ', sr: 'Cot⁻¹'),
                      _btn('Ln', st: 'eᐞ', sr: 't'),
                    ]),
                    _row([
                      _btn('(-)', st: 'Logₐ', sr: 'a'),
                      _btn('°\'\"', st: 'FACT', sr: 'b'),
                      _btn('hyp', st: '■!', sr: 'c'),
                      _btn('Sin', st: 'Sin⁻¹', sr: 'd'),
                      _btn('Cos', st: 'Cos⁻¹', sr: 'e'),
                      _btn('Tan', st: 'Tan⁻¹', sr: 'f'),
                    ]),
                    _row([
                      _btn('STO', st: 'RCL', sr: 'CRL'),
                      _btn('ENG', st: '∠', sr: 'i'),
                      _btn('(', sr: 'x'),
                      _btn(')', sr: 'y'),
                      _btn('S⇔D', sr: 'z'),
                      _btn('M+', st: 'M-', sr: 'm'),
                    ]),
                    const SizedBox(height: 4),
                    _row([
                      _btn('7', bg: AppColors.buttonGrey, st: 'CONST'),
                      _btn('8', bg: AppColors.buttonGrey, st: 'CONV'),
                      _btn('9', bg: AppColors.buttonGrey, st: 'SI'),
                      _btn('⌫', bg: const Color(0xFF60646B), icon: const Icon(Icons.backspace_outlined, size: 20)),
                      _btn('CLR', bg: const Color(0xFF60646B), st: 'CLR All'),
                    ]),
                    _row([
                      _btn('4', bg: AppColors.buttonGrey, st: 'MATRIX', sr: '::'),
                      _btn('5', bg: AppColors.buttonGrey, st: 'VECTOR'),
                      _btn('6', bg: AppColors.buttonGrey, st: 'FUNC', sr: 'HELP'),
                      _btn('×', bg: AppColors.buttonWhite, tx: Colors.black, st: 'nPr', sr: 'GCD'),
                      _btn('÷', bg: AppColors.buttonWhite, tx: Colors.black, st: 'nCr', sr: 'LCM'),
                    ]),
                    _row([
                      _btn('1', bg: AppColors.buttonGrey, st: 'STAT'),
                      _btn('2', bg: AppColors.buttonGrey, st: 'CMPLX'),
                      _btn('3', bg: AppColors.buttonGrey, st: 'DISTR'),
                      _btn('+', bg: AppColors.buttonWhite, tx: Colors.black, st: 'Pol', sr: 'Ceil'),
                      _btn('-', bg: AppColors.buttonWhite, tx: Colors.black, st: 'Rec', sr: 'Floor'),
                    ]),
                    _row([
                      _btn('0', bg: AppColors.buttonGrey, st: 'Copy', sr: 'Paste'),
                      _btn('.', bg: AppColors.buttonGrey, st: 'Ran#', sr: 'RanInt'),
                      _btn('Exp', bg: AppColors.buttonGrey, st: 'π', sr: 'e'),
                      _btn('Ans', bg: AppColors.buttonWhite, tx: Colors.black, st: '%', sr: 'PreAns'),
                      _btn('=', bg: AppColors.buttonWhite, tx: Colors.black, st: 'History'),
                    ]),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.goProBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text('GO PRO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildToolbarTag(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400)),
    );
  }

  Widget _row(List<Widget> buttons) {
    return Expanded(
      child: Row(
        children: buttons,
      ),
    );
  }

  Widget _btn(String label, {Color? bg, Color? tx, String? st, String? sr, Widget? icon}) {
    return CalcButton(
      label: label,
      onPressed: () => _onButtonPressed(label),
      backgroundColor: bg ?? AppColors.buttonDark,
      textColor: tx ?? Colors.white,
      subLabelTop: st,
      subLabelRight: sr,
      icon: icon,
    );
  }
}
