import 'package:flutter/material.dart';
import '../constants/calc_colors.dart';
import '../widgets/calc_button.dart';
import '../data/keypad_layout.dart';
import '../models/calc_key.dart';
import '../services/calculator_state.dart';
import 'dart:async';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorState _state = CalculatorState();
  late Timer _cursorTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _state.onHistoryAdded = _scrollToBottom;
    // Listen to all state changes (including cursor blink) to rebuild UI
    _state.addListener(_onStateChanged);
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (mounted) _state.toggleCursor();
    });
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cursorTimer.cancel();
    _scrollController.dispose();
    _state.removeListener(_onStateChanged);
    _state.dispose();
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

  void _onPressed(String label) {
    setState(() {
      _state.onKeyPressed(label);
    });
  }

  // ── Build helpers ────────────────────────────────────────────────────

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

  // ── Display area ─────────────────────────────────────────────────────

  Widget _buildDisplay() {
    return Expanded(
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
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 5, 0),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _state.history.length + 1,
                  padding: const EdgeInsets.only(bottom: 40),
                  itemBuilder: (context, index) {
                    if (index < _state.history.length) {
                      return _buildHistoryItem(index);
                    }
                    return _buildCurrentInput();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(int index) {
    final calc = _state.history[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 28,
              color: CalcColors.textDark,
              fontFamily: 'monospace',
              height: 1.0,
            ),
            children: _buildExpressionSpans(calc.expression, '', false, false),
          ),
        ),
        Text(
          formatDecimal(calc.result),
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 28,
            color: CalcColors.textDark,
            fontFamily: 'monospace',
            height: 1.0,
          ),
        ),
        const Divider(color: Colors.black26, height: 8, thickness: 1),
      ],
    );
  }

  Widget _buildCurrentInput() {
    final isEmpty = _state.currentExpression.isEmpty && _state.history.isEmpty;
    final beforeCursor = isEmpty ? '0' : _state.textBeforeCursor;
    final afterCursor = _state.textAfterCursor;

    final resultText = _state.isFractionDisplay &&
            _state.currentFraction != null
        ? _state.currentFraction!
        : formatDecimal(_state.currentResult);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 28,
              color: CalcColors.textDark,
              fontFamily: 'monospace',
              height: 1.0,
            ),
            children: _buildExpressionSpans(beforeCursor, afterCursor, _state.showCursor && !_state.isShowingResult, false),
          ),
        ),
        if (_state.currentResult.isNotEmpty)
          Text(
            resultText,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 28,
              color: CalcColors.textDark,
              fontFamily: 'monospace',
              height: 1.0,
            ),
          ),
      ],
    );
  }

  List<InlineSpan> _buildExpressionSpans(String before, String after, bool showCursor, bool isResultText) {
    final spans = <InlineSpan>[];
    final text = before + '\u200B' + after;

    bool inExponent = false;
    int parenDepth = 0;
    StringBuffer currentNormal = StringBuffer();
    StringBuffer currentSuperscript = StringBuffer();

    void flushNormal() {
      if (currentNormal.isNotEmpty) {
        spans.add(TextSpan(text: currentNormal.toString()));
        currentNormal.clear();
      }
    }

    void flushSuperscript() {
      if (currentSuperscript.isNotEmpty) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              currentSuperscript.toString(),
              style: const TextStyle(
                fontSize: 16,
                color: CalcColors.textDark,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
        currentSuperscript.clear();
      }
    }

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '\u200B') {
        flushNormal();
        flushSuperscript();
        if (!isResultText) {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Opacity(
              opacity: showCursor ? 1.0 : 0.0,
              child: Container(width: 2.5, height: 28, color: CalcColors.cursor),
            ),
          ));
        }
        continue;
      }

      if (char == '²' || char == '³') {
        flushNormal();
        flushSuperscript();
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              char == '²' ? '2' : '3',
              style: const TextStyle(
                fontSize: 16,
                color: CalcColors.textDark,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
        inExponent = false;
        parenDepth = 0;
        continue;
      }

      if (char == '^') {
        flushNormal();
        flushSuperscript();
        inExponent = true;
        parenDepth = 0;
        continue;
      }

      if (inExponent) {
        if (char == '(') {
          parenDepth++;
          currentSuperscript.write(char);
        } else if (char == ')') {
          parenDepth--;
          currentSuperscript.write(char);
          if (parenDepth <= 0) {
            flushSuperscript();
            inExponent = false;
            parenDepth = 0;
          }
        } else if (parenDepth > 0) {
          currentSuperscript.write(char);
        } else if (RegExp(r'[0-9.a-zA-Zπe]').hasMatch(char) || (char == '-' && currentSuperscript.isEmpty)) {
          currentSuperscript.write(char);
        } else {
          flushSuperscript();
          inExponent = false;
          currentNormal.write(char);
        }
      } else {
        currentNormal.write(char);
      }
    }

    flushNormal();
    flushSuperscript();

    return spans;
  }

  // ── Toolbar ──────────────────────────────────────────────────────────

  Widget _buildToolbar() {
    return Padding(
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
    );
  }

  // ── Keypad ───────────────────────────────────────────────────────────

  Widget _buildKeypad() {
    return Expanded(
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
    );
  }

  // ── Small widgets ────────────────────────────────────────────────────

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

  // ── Main build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CalcColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Ad banner
            Container(
              height: 50,
              width: double.infinity,
              color: Colors.black,
              alignment: Alignment.center,
              child: const Text(
                'AD BANNER SPACE',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            _buildDisplay(),
            _buildToolbar(),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }
}
