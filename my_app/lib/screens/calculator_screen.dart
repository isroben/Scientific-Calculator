import 'package:flutter/material.dart';
import '../constants/calc_colors.dart';
import '../widgets/calc_button.dart';
import '../data/keypad_layout.dart';
import '../models/calc_key.dart';
import '../services/calculator_state.dart';
import '../services/calculator_service.dart';
import 'settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../services/scanner/scanner_service.dart';
import '../services/ai_api_service.dart';
import '../services/global_state.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorState _state = globalCalculatorState;
  late Timer _cursorTimer;
  final ScrollController _scrollController = ScrollController();
  final ScannerService _scannerService = ScannerService();
  final AiApiService _aiApiService = AiApiService();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _state.onHistoryAdded = _scrollToBottom;
    // Listen to all state changes (including cursor blink) to rebuild UI
    _state.addListener(_onStateChanged);
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (mounted && _state.blinkCursorMode) {
        _state.toggleCursor();
      } else if (mounted && !_state.blinkCursorMode) {
        // If blink is disabled, ensure cursor is showing when not in result mode
        if (!_state.showCursor) _state.toggleCursor();
      }
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
    // Don't dispose global state
    _scannerService.dispose();
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
          final effectiveLabel = key.label == '÷' ? _state.divisionSign : 
                               (key.label == '×' ? _state.multiplicationSign : key.label);
          return CalcButton(
            label: effectiveLabel,
            top: key.top,
            right: key.right,
            color: key.color,
            textColor: key.textColor,
            onTap: () => _onPressed(key.label),
            fontSize: (isDense ? 20 : 28) * _state.keyboardFontSizeScaling,
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
              // Removed top right camera icon as requested to move it
              Positioned(
                bottom: 12,
                left: 12,
                child: _iconBox(
                  Icons.camera_alt, 
                  size: 24,
                  onTap: _isScanning ? null : _handleCameraScan,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 5, 0),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _state.history.length + 1,
                  padding: const EdgeInsets.only(bottom: 40),
                  itemBuilder: (context, index) {
                    if (_isScanning) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: Color(0xFF5AB9EA)),
                        ),
                      );
                    }
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
            style: GoogleFonts.getFont(_state.displayFontFamily,
              fontSize: _state.displayFontSize,
              color: CalcColors.textDark,
              height: 1.0,
            ),
            children: _buildExpressionSpans(calc.expression, '', false, false),
          ),
        ),
        Text(
          formatDecimal(calc.result),
          textAlign: TextAlign.right,
          style: GoogleFonts.getFont(
            _state.displayFontFamily,
            fontSize: _state.displayFontSize,
            color: CalcColors.textDark,
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
            style: GoogleFonts.getFont(_state.displayFontFamily,
              fontSize: _state.displayFontSize,
              color: CalcColors.textDark,
              height: 1.0,
            ),
            children: _buildExpressionSpans(beforeCursor, afterCursor, _state.showCursor && !_state.isShowingResult && !_state.isAiProcessing, false),
          ),
        ),
        if (_state.isAiProcessing)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: CalcColors.textDark),
                ),
                SizedBox(width: 8),
                Text('AI Solving...', style: TextStyle(color: CalcColors.textDark, fontSize: 14)),
              ],
            ),
          )
        else if (_state.currentResult.isNotEmpty)
          Text(
            resultText,
            textAlign: TextAlign.right,
            style: GoogleFonts.getFont(_state.displayFontFamily,
              fontSize: _state.displayFontSize,
              color: CalcColors.textDark,
              height: 1.0,
            ),
          ),
      ],
    );
  }

  List<InlineSpan> _buildExpressionSpans(String before, String after, bool showCursor, bool isResultText) {
    final spans = <InlineSpan>[];
    final text = '$before\u200B$after';

    bool inExponent = false;
    bool inSubscript = false;
    int parenDepth = 0;
    int subscriptParenDepth = 0;
    StringBuffer currentNormal = StringBuffer();
    StringBuffer currentSuperscript = StringBuffer();
    StringBuffer currentSubscript = StringBuffer();

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
                style: GoogleFonts.getFont(
                  _state.displayFontFamily,
                  fontSize: _state.displayFontSize * 0.6,
                  color: CalcColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ),
        ));
        currentSuperscript.clear();
      }
    }

    void flushSubscript() {
      if (currentSubscript.isNotEmpty) {
        String disp = currentSubscript.toString();
        // Remove zero-width characters for empty content check
        String cleanDisp = disp.replaceAll('\u200B', '');

        if (cleanDisp == '()') {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.bottom,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                '(□)',
                style: GoogleFonts.getFont(
                  _state.displayFontFamily,
                  fontSize: _state.displayFontSize * 0.45,
                  color: Colors.black26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ));
        } else {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.bottom,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  disp,
                  style: GoogleFonts.getFont(
                    _state.displayFontFamily,
                    fontSize: _state.displayFontSize * 0.55,
                    color: CalcColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ),
          ));
        }
        currentSubscript.clear();
      }
    }

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '\u200B') {
        flushNormal();
        flushSuperscript();
        flushSubscript();
        if (!isResultText) {
          spans.add(WidgetSpan(
            alignment: inExponent ? PlaceholderAlignment.top : (inSubscript ? PlaceholderAlignment.bottom : PlaceholderAlignment.middle),
            child: Opacity(
              opacity: showCursor ? 1.0 : 0.0,
              child: Container(
                width: 2.5, 
                height: (inExponent || inSubscript) ? 16 : 28, 
                color: CalcColors.cursor,
                margin: inExponent ? const EdgeInsets.only(top: 2.0) : (inSubscript ? const EdgeInsets.only(bottom: 2.0) : EdgeInsets.zero),
              ),
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
                style: GoogleFonts.getFont(
                  _state.displayFontFamily,
                  fontSize: _state.displayFontSize * 0.6,
                  color: CalcColors.textDark,
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

        bool isEmptyExponent = true;
        for (int j = i + 1; j < text.length; j++) {
          if (text[j] == '\u200B') continue;
          if (RegExp(r'[0-9.a-zA-Zπe(]').hasMatch(text[j]) || text[j] == '-') {
            isEmptyExponent = false;
          }
          break;
        }

        if (isEmptyExponent) {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                '□',
                  style: GoogleFonts.getFont(
                    _state.displayFontFamily,
                    fontSize: _state.displayFontSize * 0.6,
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
              ),
            ),
          ));
        }
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
      } else if (inSubscript) {
        if (char == '(') {
          subscriptParenDepth++;
          currentSubscript.write(char);
        } else if (char == ')') {
          subscriptParenDepth--;
          if (subscriptParenDepth <= 0) {
            currentSubscript.write(char);
            flushSubscript();
            inSubscript = false;
            subscriptParenDepth = 0;
          } else {
            currentSubscript.write(char);
          }
        } else {
          currentSubscript.write(char);
        }
      } else {
        // Lookahead for log_(base)
        if (char == 'l' && text.substring(i).startsWith('log_(')) {
          int firstOpen = i + 4;
          int depth = 0;
          int firstClose = -1;
          for (int j = firstOpen; j < text.length; j++) {
            if (text[j] == '\u200B') continue;
            if (text[j] == '(') depth++;
            if (text[j] == ')') {
              depth--;
              if (depth == 0) {
                firstClose = j;
                break;
              }
            }
          }

          if (firstClose != -1) {
            flushNormal();
            spans.add(const TextSpan(text: 'log'));
            i = firstOpen; // Now at '('
            
            inSubscript = true;
            subscriptParenDepth = 1;
            currentSubscript.write('(');
            continue;
          }
        }
        currentNormal.write(char);
      }
    }

    flushNormal();
    flushSuperscript();
    flushSubscript();

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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(state: _state),
                  ),
                ).then((_) => setState(() {}));
              },
              child: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 22,
              ),
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
            Text(
              _state.angleUnit == AngleUnit.degree ? 'DEG' : 
              _state.angleUnit == AngleUnit.radian ? 'RAD' : 'GRA',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(width: 16),
            const Text(
              'MATH',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _state.toggleOutputMode();
                });
              },
              child: Text(
                _state.isDefaultFractional ? 'FRAC' : 'DECI',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
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

  Widget _iconBox(IconData icon, {double size = 16, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: size, color: CalcColors.textDark),
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

  Future<void> _handleCameraScan() async {
    setState(() => _isScanning = true);
    
    try {
      final String? jsonPayload = await _scannerService.scanMathProblem();
      
      if (jsonPayload != null) {
        // Feed the structured JSON to our AI model endpoint
        await _aiApiService.feedToAiModel(jsonPayload);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Problem scanned and fed to AI!'),
              backgroundColor: Color(0xFF5AB9EA),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanning failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }
}
