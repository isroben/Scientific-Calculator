import 'package:flutter/material.dart';
import '../constants/calc_colors.dart';
import '../widgets/calc_button.dart';
import '../data/keypad_layout.dart';
import '../models/calc_key.dart';
import '../services/calculator_service.dart';
import 'dart:async';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class Calculation {
  final String expression;
  final String result;
  Calculation(this.expression, this.result);
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final List<Calculation> _history = [];
  String _currentExpression = "";
  String _currentResult = "";
  bool _hasPerformedFirstCalculation = false;
  late Timer _cursorTimer;
  bool _showCursor = true;
  final ScrollController _scrollController = ScrollController();

  final CalculatorService _service = CalculatorService();

  @override
  void initState() {
    super.initState();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    });
  }

  @override
  void dispose() {
    _cursorTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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

  bool _isOperator(String label) {
    return ['+', '-', '×', '÷', '^', 'mod'].contains(label);
  }

  void _onPressed(String label) {
    setState(() {
      if (label == 'CLR' || label == 'AC') {
        _currentExpression = "";
        _currentResult = "";
        _history.clear();
        _hasPerformedFirstCalculation = false;
      } else if (label == '⌫') {
        if (_currentExpression.isNotEmpty) {
          _currentExpression = _currentExpression.substring(
            0,
            _currentExpression.length - 1,
          );
        }
      } else if (label == '=') {
        if (_currentExpression.isNotEmpty) {
          try {
            double calcResult = _service.calculate(_currentExpression);
            if (calcResult.isNaN) {
              _currentResult = "Error";
            } else {
              String tempResult = calcResult.toString();
              if (tempResult.endsWith('.0')) {
                tempResult = tempResult.substring(0, tempResult.length - 2);
              }
              _currentResult = tempResult;
              // Push to history
              _history.add(Calculation(_currentExpression, _currentResult));
              _currentExpression = "";
              _currentResult = "";

              if (_hasPerformedFirstCalculation) {
                _scrollToBottom();
              } else {
                _hasPerformedFirstCalculation = true;
              }
            }
          } catch (e) {
            _currentResult = "Error";
          }
        }
      } else {
        // Reuse result logic
        if (_history.isNotEmpty &&
            _currentExpression.isEmpty &&
            _isOperator(label)) {
          _currentExpression = _history.last.result + label;
        } else {
          _currentExpression += label;
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CalcColors.display,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 22,
                          color: CalcColors.textDark,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Row(
                          children: [
                            _iconBox(Icons.crop_free),
                            const SizedBox(width: 4),
                            _iconBox(Icons.more_horiz),
                          ],
                        ),
                      ),
                      // Scrollable content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          6,
                          0,
                          5,
                          0,
                        ), // leave space for bottom icons
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _history.length + 1,
                          padding: EdgeInsets.only(bottom: 60),
                          itemBuilder: (context, index) {
                            if (index < _history.length) {
                              final calc = _history[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    calc.expression,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      color: CalcColors.textDark,
                                      fontFamily: 'monospace',
                                      height: 1.25,
                                    ),
                                  ),
                                  Text(
                                    _formatResult(calc.result),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      color: CalcColors.textDark,
                                      fontFamily: 'monospace',
                                      height: 1,
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.black26,
                                    height: 5,
                                  ),
                                ],
                              );
                            } else {
                              // Current active input
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _currentExpression.isEmpty &&
                                                _history.isEmpty
                                            ? '0'
                                            : _currentExpression,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          color: CalcColors.textDark,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      if (_currentResult.isEmpty && _showCursor)
                                        Container(
                                          width: 2.5,
                                          height: 24,
                                          color: CalcColors.cursor,
                                        ),
                                    ],
                                  ),
                                  if (_currentResult.isNotEmpty)
                                    Text(
                                      _formatResult(_currentResult),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        color: CalcColors.textDark,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                ],
                              );
                            }
                          },
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

  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: CalcColors.textDark, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: CalcColors.textDark),
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
