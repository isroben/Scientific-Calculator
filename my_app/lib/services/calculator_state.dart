import 'package:flutter/foundation.dart';
import 'package:fraction/fraction.dart';
import '../models/calc_key.dart';
import '../models/calculation.dart';
import '../data/keypad_layout.dart';
import 'calculator_service.dart';

/// All calculator logic extracted from the screen.
///
/// The UI listens via [ChangeNotifier] and calls [onKeyPressed] for
/// every button tap. This class owns:
///   - expression / result strings with cursor position
///   - history list
///   - shift / alpha modes
///   - memory (STO / RCL / M+ / M-)
///   - fraction ↔ decimal toggle
class CalculatorState extends ChangeNotifier {
  // ── Public state (read-only outside this class) ──────────────────────
  final List<Calculation> history = [];

  String get currentExpression => _currentExpression;
  String get currentResult => _currentResult;
  bool get isShowingResult => _isShowingResult;
  bool get showCursor => _showCursor;
  bool get shift => _shift;
  bool get alpha => _alpha;
  bool get isFractionDisplay => _isFractionDisplay;
  String? get currentFraction => _currentFraction;

  /// Current cursor position within the expression (0 = before first char).
  int get cursorPosition => _cursorPosition;

  /// Text before the cursor (for display rendering).
  String get textBeforeCursor =>
      _currentExpression.substring(0, _cursorPosition);

  /// Text after the cursor (for display rendering).
  String get textAfterCursor =>
      _currentExpression.substring(_cursorPosition);

  // ── Private state ────────────────────────────────────────────────────
  String _currentExpression = '';
  String _currentResult = '';
  bool _isShowingResult = false;
  bool _showCursor = true;
  bool _shift = false;
  bool _alpha = false;
  double _memory = 0.0;
  double _lastAnswer = 0.0;
  bool _isFractionDisplay = true;
  String? _currentFraction;
  int _cursorPosition = 0;

  final CalculatorService _service = CalculatorService();
  final Map<String, CalcKey> _keyMap = {};

  /// Callback the UI can hook into to trigger a scroll-to-bottom.
  VoidCallback? onHistoryAdded;

  // ── Label → function mapping (single source of truth) ────────────────
  static const _labelToFunc = <String, String>{
    // Inverse trig
    'Sin⁻¹': 'asin',
    'Cos⁻¹': 'acos',
    'Tan⁻¹': 'atan',
    'Cot⁻¹': 'acot',
    // Trig
    'Sin': 'sin',
    'Cos': 'cos',
    'Tan': 'tan',
    'Cot': 'cot',
    '√x': '√',
    '∛x': '∛',
    // Logs
    'Log': 'log',
    'Ln': 'ln',
    '10ⁿ': '10^',
    'eⁿ': 'e^',
    // Misc
    'FACT': 'fact',
    '|x|': 'abs',
    'Ceil': 'ceil',
    'Floor': 'floor',
    'nPr': 'nPr',
    'nCr': 'nCr',
  };

  static const _operators = {'+', '-', '×', '÷', '^', 'mod'};

  // ── Initialisation ───────────────────────────────────────────────────

  CalculatorState() {
    _buildKeyMap();
  }

  void _buildKeyMap() {
    for (final key in scientificKeys) {
      _keyMap[key.label] = key;
    }
    for (final key in numericKeys) {
      _keyMap[key.label] = key;
    }
  }

  // ── Cursor blink ─────────────────────────────────────────────────────

  void toggleCursor() {
    _showCursor = !_showCursor;
    notifyListeners();
  }

  // ── Cursor-aware text manipulation ───────────────────────────────────

  /// Insert [text] at the current cursor position and advance cursor.
  void _insertAtCursor(String text) {
    _currentExpression = _currentExpression.substring(0, _cursorPosition) +
        text +
        _currentExpression.substring(_cursorPosition);
    _cursorPosition += text.length;
  }

  /// Delete one character before the cursor (backspace behaviour).
  void _deleteBeforeCursor() {
    if (_cursorPosition > 0) {
      _currentExpression =
          _currentExpression.substring(0, _cursorPosition - 1) +
              _currentExpression.substring(_cursorPosition);
      _cursorPosition--;
    }
  }

  /// Reset expression and cursor.
  void _clearExpression() {
    _currentExpression = '';
    _cursorPosition = 0;
  }

  // ── Key press entry point ────────────────────────────────────────────

  void onKeyPressed(String label) {
    // Special toggles — don't affect expression
    if (label == 'SHIFT') {
      _shift = !_shift;
      _alpha = false;
      notifyListeners();
      return;
    }
    if (label == 'ALPHA') {
      _alpha = !_alpha;
      _shift = false;
      notifyListeners();
      return;
    }

    // Arrow keys — handle directly without key lookup
    if (const {'◄', '►', '▲', '▼'}.contains(label)) {
      _handleArrow(label);
      notifyListeners();
      return;
    }

    final key = _keyMap[label];
    if (key == null) return; // unknown key

    final actualLabel = _getEffectiveLabel(key);

    // Momentary shift/alpha — reset after use
    _shift = false;
    _alpha = false;

    // Arrow labels from shifted/alpha keys
    if (const {'◄', '►', '▲', '▼'}.contains(actualLabel)) {
      _handleArrow(actualLabel);
      notifyListeners();
      return;
    }

    // If we are currently showing a result and the user types something
    // new (not = / ⌫ / memory ops / clear), save current into history FIRST.
    if (_isShowingResult &&
        actualLabel != '=' &&
        actualLabel != '⌫' &&
        actualLabel != 'CLR' &&
        actualLabel != 'CLR All' &&
        actualLabel != 'AC' &&
        actualLabel != 'S⇔D' &&
        !_isMemoryOp(actualLabel)) {
      history.add(Calculation(_currentExpression, _currentResult));
      _clearExpression();
      _currentResult = '';
      _isShowingResult = false;
      _isFractionDisplay = true;
      _currentFraction = null;
      onHistoryAdded?.call();
    }

    _processLabel(actualLabel);
    notifyListeners();
  }

  // ── Arrow key handling ───────────────────────────────────────────────

  void _handleArrow(String arrow) {
    switch (arrow) {
      case '◄':
        if (_cursorPosition > 0) _cursorPosition--;
      case '►':
        if (_cursorPosition < _currentExpression.length) _cursorPosition++;
      case '▲':
      case '▼':
        // Reserved for future use (e.g. history navigation)
        break;
    }
  }

  // ── Label processing ─────────────────────────────────────────────────

  void _processLabel(String label) {
    // Clear — CLR, CLR All, and AC all fully reset the window
    if (label == 'CLR' || label == 'CLR All' || label == 'AC') {
      history.clear();
      _clearExpression();
      _currentResult = '';
      _isShowingResult = false;
      _isFractionDisplay = true;
      _currentFraction = null;
      return;
    }

    // Backspace — delete character before cursor
    if (label == '⌫') {
      if (_isShowingResult) {
        _isShowingResult = false;
        _currentResult = '';
        _isFractionDisplay = true;
        _currentFraction = null;
      } else {
        _deleteBeforeCursor();
      }
      return;
    }

    // Equals
    if (label == '=') {
      _evaluate();
      return;
    }

    // Memory
    if (_isMemoryOp(label)) {
      _handleMemory(label);
      return;
    }

    // Ans
    if (label == 'Ans') {
      _insertAtCursor('$_lastAnswer');
      return;
    }

    // Exponents
    if (label == 'x²') {
      _insertAtCursor('²');
      return;
    }
    if (label == 'x³') {
      _insertAtCursor('³');
      return;
    }
    if (label == 'xⁿ') {
      _insertAtCursor('^');
      return;
    }

    // Constants
    if (label == 'π' || label == 'pi') {
      _insertAtCursor('π');
      return;
    }
    if (label == 'e') {
      _insertAtCursor('e');
      return;
    }

    // Operators
    if (_operators.contains(label)) {
      _insertAtCursor(label);
      return;
    }

    // Decimal point
    if (label == '.') {
      _insertAtCursor('.');
      return;
    }

    // Digit
    if (RegExp(r'^[0-9]$').hasMatch(label)) {
      _insertAtCursor(label);
      return;
    }

    // Fraction ↔ Decimal toggle
    if (label == 'S⇔D') {
      if (_currentResult.isNotEmpty && _currentResult != 'Error') {
        _isFractionDisplay = !_isFractionDisplay;
      }
      return;
    }

    // Parentheses
    if (label == '(' || label == ')') {
      _insertAtCursor(label);
      return;
    }

    // Specific handler for nth root (positions cursor backward to type n)
    if (label == 'ⁿ√x') {
      _insertAtCursor('√(');
      _cursorPosition -= 2;
      return;
    }

    // Scientific functions — use single lookup map
    final func = _labelToFunc[label];
    if (func != null) {
      _insertAtCursor('$func(');
      return;
    }

    // Fallback: insert as-is (single variables, etc.)
    _insertAtCursor(label);
  }

  // ── Evaluation ───────────────────────────────────────────────────────

  void _evaluate() {
    if (_currentExpression.isEmpty || _isShowingResult) return;
    try {
      final result = _service.calculate(_currentExpression);
      if (result.isNaN) {
        _currentResult = 'Error';
      } else {
        // Round to 9 decimal places
        final rounded = double.parse(result.toStringAsFixed(9));
        var text = rounded.toString();
        // Strip trailing zeros after decimal point (e.g. "5.000000" → "5")
        if (text.contains('.')) {
          text = text.replaceAll(RegExp(r'0+$'), '');
          text = text.replaceAll(RegExp(r'\.$'), '');
        }
        _currentResult = text;
        _lastAnswer = rounded;
        _isShowingResult = true;
        _currentFraction = _toFraction(text);
        _isFractionDisplay = true;
      }
    } catch (_) {
      _currentResult = 'Error';
    }
  }

  // ── Memory ───────────────────────────────────────────────────────────

  bool _isMemoryOp(String label) =>
      const {'STO', 'RCL', 'M+', 'M-'}.contains(label);

  void _handleMemory(String op) {
    double value = 0.0;
    if (_currentResult.isNotEmpty) {
      value = double.tryParse(_currentResult) ?? 0.0;
    } else if (_lastAnswer != 0.0) {
      value = _lastAnswer;
    }
    switch (op) {
      case 'STO':
        _memory = value;
      case 'RCL':
        _insertAtCursor('$_memory');
      case 'M+':
        _memory += value;
      case 'M-':
        _memory -= value;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  String _getEffectiveLabel(CalcKey key) {
    if (_shift && key.top != null && key.top!.isNotEmpty) return key.top!;
    if (_alpha && key.right != null && key.right!.isNotEmpty) return key.right!;
    return key.label;
  }

  /// Convert a decimal result to its fraction representation.
  String _toFraction(String decimal) {
    if (decimal == 'Error') return decimal;
    try {
      final value = double.parse(decimal);
      return Fraction.fromDouble(value).toString();
    } catch (_) {
      return decimal;
    }
  }
}

/// Format a decimal string with spaces every 3 digits after the point.
String formatDecimal(String raw) {
  if (raw.isEmpty || raw == 'Error' || !raw.contains('.')) return raw;
  final parts = raw.split('.');
  final buffer = StringBuffer();
  for (int i = 0; i < parts[1].length; i++) {
    if (i > 0 && i % 3 == 0) buffer.write(' ');
    buffer.write(parts[1][i]);
  }
  return '${parts[0]}.${buffer.toString()}';
}
