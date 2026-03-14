import 'package:flutter/foundation.dart';
import 'package:fraction/fraction.dart';
import '../models/calc_key.dart';
import '../models/calculation.dart';
import '../data/keypad_layout.dart';
import 'calculator_service.dart';
import 'ai_api_service.dart';

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
  AngleUnit get angleUnit => _service.angleUnit;
  ImpliedMultiplication get impliedMultiplication => _impliedMultiplication;
  PercentageType get percentageType => _percentageType;
  bool get casMode => _casMode;
  bool get autoCalculate => _autoCalculate;
  bool get autoCalculateDMS => _autoCalculateDMS;
  bool get frequencyColumn => _frequencyColumn;
  bool get useGXFunction => _useGXFunction;
  bool get ignoreExtraOperators => _ignoreExtraOperators;
  bool get autoCalculateIntegral => _autoCalculateIntegral;
  bool get isDefaultFractional => _isDefaultFractional;
  bool get isFractionDisplay => _isFractionDisplay;
  String? get currentFraction => _currentFraction;
  bool get isAiProcessing => _isAiProcessing;

  // Display Settings
  bool get clearScreenOnExit => _clearScreenOnExit;
  bool get blinkCursorMode => _blinkCursorMode;
  bool get keepScreenOn => _keepScreenOn;
  double get displayFontSize => _displayFontSize;
  int get ansDisplayMode => _ansDisplayMode;
  bool get showCalculationInfo => _showCalculationInfo;
  bool get mathOCR => _mathOCR;
  bool get expressionDetails => _expressionDetails;
  bool get showGraph => _showGraph;
  bool get showStatusBar => _showStatusBar;
  String get displayFontFamily => _displayFontFamily;
  String get appFontFamily => _appFontFamily;
  List<String> get availableDisplayFonts => ['Roboto', 'Courier Prime', 'Orbitron', 'Inter', 'JetBrains Mono'];
  List<String> get availableAppFonts => ['Roboto', 'Inter', 'Open Sans', 'Lato', 'Montserrat', 'Ubuntu'];
  String get themeName => _themeName;
  String get language => _language;

  // Keyboard Settings
  bool get vibrateOnKeypress => _vibrateOnKeypress;
  bool get playSoundEffect => _playSoundEffect;
  String get keyboardLayout => _keyboardLayout;
  double get keyboardFontSizeScaling => _keyboardFontSizeScaling;
  int get buttonLabelStyle => _buttonLabelStyle;
  String get divisionSign => _divisionSign;
  String get multiplicationSign => _multiplicationSign;
  bool get insertMultBeforeFraction => _insertMultBeforeFraction;
  bool get autoCloseBrackets => _autoCloseBrackets;

  // Format Settings
  bool get displayPolyDecreasing => _displayPolyDecreasing;
  String get decimalSeparator => _decimalSeparator;
  String get thousandSeparator => _thousandSeparator;
  String get thousandthSeparator => _thousandthSeparator;
  bool get useIndianStyleGrouping => _useIndianStyleGrouping;
  int get scientificNotationMode => _scientificNotationMode; // 0: x10^n, 1: En
  int get binaryGrouping => _binaryGrouping;
  int get octalGrouping => _octalGrouping;
  int get hexGrouping => _hexGrouping;

  // Graph Settings
  int get graphTheme => _graphTheme; // 0: Light, 1: Dark, 2: Auto
  int get coordinateSystem => _coordinateSystem; // 0: Cartesian, 1: Polar
  bool get showGrid => _showGrid;
  bool get showAxisLabels => _showAxisLabels;
  bool get independentZoom => _independentZoom;
  int get graphPointStyle => _graphPointStyle; // 0: Connected, 1: Dot
  double get polarStart => _polarStart;
  double get polarStop => _polarStop;
  double get polarStep => _polarStep;
  double get parametricStart => _parametricStart;
  double get parametricStop => _parametricStop;
  double get parametricStep => _parametricStep;

  // Math OCR Settings
  bool get autoDetectSeparators => _autoDetectSeparators;
  int get interpretCommas => _interpretCommas; // 0: Thousands separator
  int get interpretDots => _interpretDots; // 0: Decimal separator
  int get onSuccessSingleExpression => _onSuccessSingleExpression; // 0: Do nothing

  // Other Settings
  int get unitCategoryOrder => _unitCategoryOrder; // 0: Default, 1: Alphabetical
  int get unitOrder => _unitOrder; // 0: Default, 1: Alphabetical
  int get maxHistorySize => _maxHistorySize; // 50, 100, 500, 1000
  int get appIcon => _appIcon; // 0, 1, 2

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
  double _preAns = 0.0;
  final Map<String, double> _vars = {
    'a': 0, 'b': 0, 'c': 0, 'd': 0, 'e': 0, 'f': 0, 'm': 0, 'x': 0, 'y': 0, 't': 0
  };
  
  // Settings
  ImpliedMultiplication _impliedMultiplication = ImpliedMultiplication.type1;
  PercentageType _percentageType = PercentageType.type2;
  bool _casMode = true;
  bool _autoCalculate = true;
  bool _autoCalculateDMS = true;
  bool _frequencyColumn = true;
  bool _useGXFunction = true;
  bool _ignoreExtraOperators = true;
  bool _autoCalculateIntegral = false;
  bool _isDefaultFractional = false;

  // Display Settings Private
  bool _clearScreenOnExit = false;
  bool _blinkCursorMode = true;
  bool _keepScreenOn = true;
  double _displayFontSize = 24.0;
  int _ansDisplayMode = 2; // 0, 1, 2
  bool _showCalculationInfo = true;
  bool _mathOCR = true;
  bool _expressionDetails = true;
  bool _showGraph = true;
  bool _showStatusBar = false;
  String _displayFontFamily = 'Roboto';
  String _appFontFamily = 'Roboto';
  String _themeName = 'Ti-36';
  String _language = 'System';

  // Keyboard Settings Private
  bool _vibrateOnKeypress = true;
  bool _playSoundEffect = true;
  String _keyboardLayout = 'Calc 570/991 ES';
  double _keyboardFontSizeScaling = 1.0;
  int _buttonLabelStyle = 1;
  String _divisionSign = '÷';
  String _multiplicationSign = '×';
  bool _insertMultBeforeFraction = true;
  bool _autoCloseBrackets = false;

  // Format Settings Private
  bool _displayPolyDecreasing = true;
  String _decimalSeparator = '.';
  String _thousandSeparator = 'Space';
  String _thousandthSeparator = 'Space';
  bool _useIndianStyleGrouping = false;
  int _scientificNotationMode = 0;
  int _binaryGrouping = 4;
  int _octalGrouping = 4;
  int _hexGrouping = 4;

  // Graph Settings Private
  int _graphTheme = 0;
  int _coordinateSystem = 0;
  bool _showGrid = true;
  bool _showAxisLabels = true;
  bool _independentZoom = true;
  int _graphPointStyle = 0;
  double _polarStart = 0.0;
  double _polarStop = 6.28;
  double _polarStep = 0.1;
  double _parametricStart = 0.0;
  double _parametricStop = 6.28;
  double _parametricStep = 0.1;

  // Math OCR Settings Private
  bool _autoDetectSeparators = true;
  int _interpretCommas = 0;
  int _interpretDots = 0;
  int _onSuccessSingleExpression = 0;

  // Other Settings Private
  int _unitCategoryOrder = 0;
  int _unitOrder = 0;
  int _maxHistorySize = 100;
  int _appIcon = 0;

  bool _isFractionDisplay = true;
  String? _currentFraction;
  int _cursorPosition = 0;
  bool _isAiProcessing = false;

  final CalculatorService _service = CalculatorService();
  final AiApiService _aiService = AiApiService();
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
    'Σ': 'sum',
    'Π': 'prod',
    '∠': 'angle',
    'Pol': 'pol',
    'Rec': 'rec',
    'GCD': 'gcd',
    'LCM': 'lcm',
    'RanInt': 'ranInt',
    'avg': 'avg',
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

  void toggleOutputMode() {
    _isDefaultFractional = !_isDefaultFractional;
    notifyListeners();
  }

  void setAngleUnit(AngleUnit unit) {
    _service.angleUnit = unit;
    notifyListeners();
  }

  void setImpliedMultiplication(ImpliedMultiplication mode) {
    _impliedMultiplication = mode;
    _service.impliedMultiplication = mode;
    notifyListeners();
  }

  void setPercentageType(PercentageType type) {
    _percentageType = type;
    _service.percentageType = type;
    notifyListeners();
  }

  void setCasMode(bool value) {
    _casMode = value;
    notifyListeners();
  }

  void setAutoCalculate(bool value) {
    _autoCalculate = value;
    notifyListeners();
  }

  void setAutoCalculateDMS(bool value) {
    _autoCalculateDMS = value;
    notifyListeners();
  }

  void setFrequencyColumn(bool value) {
    _frequencyColumn = value;
    notifyListeners();
  }

  void setUseGXFunction(bool value) {
    _useGXFunction = value;
    notifyListeners();
  }

  void setIgnoreExtraOperators(bool value) {
    _ignoreExtraOperators = value;
    notifyListeners();
  }

  void setAutoCalculateIntegral(bool value) {
    _autoCalculateIntegral = value;
    notifyListeners();
  }

  // Display Setters
  void setClearScreenOnExit(bool value) {
    _clearScreenOnExit = value;
    notifyListeners();
  }

  void setBlinkCursorMode(bool value) {
    _blinkCursorMode = value;
    notifyListeners();
  }

  void setKeepScreenOn(bool value) {
    _keepScreenOn = value;
    notifyListeners();
  }

  void setDisplayFontSize(double value) {
    _displayFontSize = value;
    notifyListeners();
  }

  void setAnsDisplayMode(int value) {
    _ansDisplayMode = value;
    notifyListeners();
  }

  void setShowCalculationInfo(bool value) {
    _showCalculationInfo = value;
    notifyListeners();
  }

  void setMathOCR(bool value) {
    _mathOCR = value;
    notifyListeners();
  }

  void setExpressionDetails(bool value) {
    _expressionDetails = value;
    notifyListeners();
  }

  void setShowGraph(bool value) {
    _showGraph = value;
    notifyListeners();
  }

  void setShowStatusBar(bool value) {
    _showStatusBar = value;
    notifyListeners();
  }

  void setDisplayFontFamily(String value) {
    _displayFontFamily = value;
    notifyListeners();
  }

  void setAppFontFamily(String value) {
    _appFontFamily = value;
    notifyListeners();
  }

  void setThemeName(String value) {
    _themeName = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  // Keyboard Setters
  void setVibrateOnKeypress(bool value) {
    _vibrateOnKeypress = value;
    notifyListeners();
  }

  void setPlaySoundEffect(bool value) {
    _playSoundEffect = value;
    notifyListeners();
  }

  void setKeyboardLayout(String value) {
    _keyboardLayout = value;
    notifyListeners();
  }

  void setKeyboardFontSizeScaling(double value) {
    _keyboardFontSizeScaling = value;
    notifyListeners();
  }

  void setButtonLabelStyle(int value) {
    _buttonLabelStyle = value;
    notifyListeners();
  }

  void setDivisionSign(String value) {
    _divisionSign = value;
    notifyListeners();
  }

  void setMultiplicationSign(String value) {
    _multiplicationSign = value;
    notifyListeners();
  }

  void setInsertMultBeforeFraction(bool value) {
    _insertMultBeforeFraction = value;
    notifyListeners();
  }

  void setAutoCloseBrackets(bool value) {
    _autoCloseBrackets = value;
    notifyListeners();
  }

  // Format Setters
  void setDisplayPolyDecreasing(bool value) {
    _displayPolyDecreasing = value;
    notifyListeners();
  }

  void setDecimalSeparator(String value) {
    _decimalSeparator = value;
    notifyListeners();
  }

  void setThousandSeparator(String value) {
    _thousandSeparator = value;
    notifyListeners();
  }

  void setThousandthSeparator(String value) {
    _thousandthSeparator = value;
    notifyListeners();
  }

  void setUseIndianStyleGrouping(bool value) {
    _useIndianStyleGrouping = value;
    notifyListeners();
  }

  void setScientificNotationMode(int value) {
    _scientificNotationMode = value;
    notifyListeners();
  }

  void setBinaryGrouping(int value) {
    _binaryGrouping = value;
    notifyListeners();
  }

  void setOctalGrouping(int value) {
    _octalGrouping = value;
    notifyListeners();
  }

  void setHexGrouping(int value) {
    _hexGrouping = value;
    notifyListeners();
  }

  // Graph Setters
  void setGraphTheme(int value) {
    _graphTheme = value;
    notifyListeners();
  }

  void setCoordinateSystem(int value) {
    _coordinateSystem = value;
    notifyListeners();
  }

  void setShowGrid(bool value) {
    _showGrid = value;
    notifyListeners();
  }

  void setShowAxisLabels(bool value) {
    _showAxisLabels = value;
    notifyListeners();
  }

  void setIndependentZoom(bool value) {
    _independentZoom = value;
    notifyListeners();
  }

  void setGraphPointStyle(int value) {
    _graphPointStyle = value;
    notifyListeners();
  }

  void setPolarStart(double value) {
    _polarStart = value;
    notifyListeners();
  }

  void setPolarStop(double value) {
    _polarStop = value;
    notifyListeners();
  }

  void setPolarStep(double value) {
    _polarStep = value;
    notifyListeners();
  }

  void setParametricStart(double value) {
    _parametricStart = value;
    notifyListeners();
  }

  void setParametricStop(double value) {
    _parametricStop = value;
    notifyListeners();
  }

  void setParametricStep(double value) {
    _parametricStep = value;
    notifyListeners();
  }

  // Math OCR Setters
  void setAutoDetectSeparators(bool value) {
    _autoDetectSeparators = value;
    notifyListeners();
  }

  void setInterpretCommas(int value) {
    _interpretCommas = value;
    notifyListeners();
  }

  void setInterpretDots(int value) {
    _interpretDots = value;
    notifyListeners();
  }

  void setOnSuccessSingleExpression(int value) {
    _onSuccessSingleExpression = value;
    notifyListeners();
  }

  // Other Setters
  void setUnitCategoryOrder(int value) {
    _unitCategoryOrder = value;
    notifyListeners();
  }

  void setUnitOrder(int value) {
    _unitOrder = value;
    notifyListeners();
  }

  void setMaxHistorySize(int value) {
    _maxHistorySize = value;
    notifyListeners();
  }

  void setAppIcon(int value) {
    _appIcon = value;
    notifyListeners();
  }

  void resetSettings() {
    _service.angleUnit = AngleUnit.degree;
    _impliedMultiplication = ImpliedMultiplication.type1;
    _percentageType = PercentageType.type2;
    _casMode = true;
    _autoCalculate = true;
    _autoCalculateDMS = true;
    _frequencyColumn = true;
    _useGXFunction = true;
    _ignoreExtraOperators = true;
    _autoCalculateIntegral = false;
    _isDefaultFractional = false;
    
    // Reset Display
    _clearScreenOnExit = false;
    _blinkCursorMode = true;
    _keepScreenOn = true;
    _displayFontSize = 24.0;
    _ansDisplayMode = 2;
    _showCalculationInfo = true;
    _mathOCR = true;
    _expressionDetails = true;
    _showGraph = true;
    _showStatusBar = false;
    _displayFontFamily = 'Roboto';
    _appFontFamily = 'Roboto';
    _themeName = 'Ti-36';
    _language = 'System';

    // Reset Keyboard
    _vibrateOnKeypress = true;
    _playSoundEffect = true;
    _keyboardLayout = 'Calc 570/991 ES';
    _keyboardFontSizeScaling = 1.0;
    _buttonLabelStyle = 1;
    _divisionSign = '÷';
    _multiplicationSign = '×';
    _insertMultBeforeFraction = true;
    _autoCloseBrackets = false;

    // Reset Format
    _displayPolyDecreasing = true;
    _decimalSeparator = '.';
    _thousandSeparator = 'Space';
    _thousandthSeparator = 'Space';
    _useIndianStyleGrouping = false;
    _scientificNotationMode = 0;
    _binaryGrouping = 4;
    _octalGrouping = 4;
    _hexGrouping = 4;

    // Reset Graph
    _graphTheme = 0;
    _coordinateSystem = 0;
    _showGrid = true;
    _showAxisLabels = true;
    _independentZoom = true;
    _graphPointStyle = 0;
    _polarStart = 0.0;
    _polarStop = 6.28;
    _polarStep = 0.1;
    _parametricStart = 0.0;
    _parametricStop = 6.28;
    _parametricStep = 0.1;

    // Reset Math OCR
    _autoDetectSeparators = true;
    _interpretCommas = 0;
    _interpretDots = 0;
    _onSuccessSingleExpression = 0;

    // Reset Other
    _unitCategoryOrder = 0;
    _unitOrder = 0;
    _maxHistorySize = 100;
    _appIcon = 0;

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
        actualLabel != 'CLRv' &&
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
        break;
      case '►':
        // Navigation for log_(): if at 'log_(a|)', move to 'log_(a)|'
        if (_cursorPosition < _currentExpression.length) {
          int open = _currentExpression.lastIndexOf('log_(', _cursorPosition);
          if (open != -1) {
            int close = _currentExpression.indexOf(')', open + 5);
            if (close != -1 && _cursorPosition == close) {
               _cursorPosition++;
               return;
            }
          }
        }
        if (_cursorPosition < _currentExpression.length) _cursorPosition++;
        break;
      case '▲':
        _moveUp();
        break;
      case '▼':
        _moveDown();
        break;
    }
  }

  void _moveUp() {
    // If we're at 'x^|(', move inside: 'x^|'
    // Actually, in the refined template it's '^()'
    // Check if cursor is next to a '^' or '√'
    
    // Navigation for log_(): if inside log_(a|), pressing Up moves to log_(a)|
    int logIdx = _currentExpression.lastIndexOf('log_(', _cursorPosition);
    if (logIdx != -1) {
      int close = _currentExpression.indexOf(')', logIdx + 5);
      if (close != -1 && _cursorPosition <= close) {
         _cursorPosition = close + 1;
         return;
      }
    }

    // Existing Up logic...

    // 2. Check if we're inside a root and want to go to the index position
    // If expression is '√(', cursor is at index 1 -> '√|('
    // But if we want '2√(', cursor should be at 0 -> '|2√('
    // Let's check if we are at the start of a root '√'
    if (_cursorPosition < _currentExpression.length && _currentExpression[_cursorPosition] == '√') {
      // Already at the index position (start of root)
      return;
    }
    
    // Find previous '√'
    int rootIdx = _currentExpression.lastIndexOf('√', _cursorPosition);
    if (rootIdx != -1 && rootIdx < _cursorPosition) {
      // Check if we are inside the following parentheses
      if (rootIdx + 1 < _currentExpression.length && _currentExpression[rootIdx + 1] == '(') {
        _cursorPosition = rootIdx; // Move to before √
      }
    }
  }

  void _moveDown() {
    // If we are inside an exponent '^(...|)', jump out to '^(...)|'
    // Find the nearest closing bracket after cursor
    int bracketIdx = _currentExpression.indexOf(')', _cursorPosition);
    if (bracketIdx != -1) {
      // Check if this bracket belongs to an exponent or root
      // Search backwards from bracketIdx to find if it corresponds to a '^(' or '√('
      int openIdx = _currentExpression.lastIndexOf('(', bracketIdx);
      if (openIdx != -0 && openIdx != -1) {
        if (_currentExpression[openIdx - 1] == '^' || _currentExpression[openIdx - 1] == '√') {
          _cursorPosition = bracketIdx + 1;
        }
      }
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

    // Mode toggle (Cycles through DEG, RAD, GRA)
    if (label == 'MODE') {
      final nextUnit = AngleUnit.values[(_service.angleUnit.index + 1) % AngleUnit.values.length];
      _service.angleUnit = nextUnit;
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

    // PreAns
    if (label == 'PreAns') {
      _insertAtCursor('$_preAns');
      return;
    }

    // Exponents
    if (label == 'Logₐb') {
      _insertAtCursor('log_()');
      _cursorPosition--; // Inside log_(|)
      return;
    }
    if (label == 'x²') {
      _insertAtCursor('²');
      return;
    }
    if (label == 'x³') {
      _insertAtCursor('³');
      return;
    }
    if (label == 'x⁻¹') {
      _insertAtCursor('⁻¹');
      return;
    }
    if (label == '■!') {
      _insertAtCursor('!');
      return;
    }
    if (label == 'xⁿ') {
      _insertAtCursor('^()');
      _cursorPosition--; // Inside ^(|)
      return;
    }

    // d/dx
    if (label == 'd/dx') {
      _insertAtCursor('d()/dx');
      _cursorPosition -= 4; // Inside d(|)/dx
      return;
    }

    // ∫dx
    if (label == '∫dx') {
      _insertAtCursor('∫d()');
      _cursorPosition -= 1; // Inside ∫d(|)
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

    // CLRv (Clear Variables)
    if (label == 'CLRv') {
      _vars.updateAll((key, value) => 0.0);
      return;
    }

    // Parentheses
    if (label == '(') {
      _insertAtCursor('(');
      if (_autoCloseBrackets) {
        _insertAtCursor(')');
        _cursorPosition--;
      }
      return;
    }
    if (label == ')') {
      _insertAtCursor(')');
      return;
    }

    // Specific handler for nth root (positions cursor at index position)
    if (label == 'ⁿ√x') {
      _insertAtCursor('√()');
      _cursorPosition -= 3; // Before √ -> |√()
      return;
    }

    if (label == 'x̅') {
      _insertAtCursor('avg(');
      return;
    }
    if (label == '%' || label == ',' || label == ':') {
      _insertAtCursor(label);
      return;
    }

    // Scientific functions — use single lookup map
    final func = _labelToFunc[label];
    if (func != null) {
      _insertAtCursor('$func(');
      if (_autoCloseBrackets) {
        _insertAtCursor(')');
        _cursorPosition--;
      }
      return;
    }

    // Fallback: insert as-is (single variables, etc.)
    _insertAtCursor(label);
  }

  // ── Evaluation ───────────────────────────────────────────────────────

  Future<void> _evaluate() async {
    if (_currentExpression.isEmpty || _isShowingResult || _isAiProcessing) return;

    // Detect if this is a calculus problem that should go to AI
    if (_currentExpression.contains('∫') || (_currentExpression.contains('d(') && _currentExpression.contains('/dx'))) {
      _isAiProcessing = true;
      _currentResult = '...';
      notifyListeners();

      try {
        final aiResult = await _aiService.solveCalculus(_currentExpression);
        _currentResult = aiResult;
        _isShowingResult = true;
      } catch (e) {
        _currentResult = 'Error';
      } finally {
        _isAiProcessing = false;
        notifyListeners();
      }
      return;
    }

    try {
      _service.angleUnit = angleUnit;
      _service.impliedMultiplication = _impliedMultiplication;
      _service.percentageType = _percentageType;
      
      final result = _service.evaluate(_currentExpression, vars: _vars);
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
        _preAns = _lastAnswer;
        _currentResult = text;
        _lastAnswer = rounded;
        _isShowingResult = true;
        _currentFraction = _toFraction(text);
        _isFractionDisplay = _isDefaultFractional;
      }
    } catch (_) {
      _currentResult = 'Error';
    }
    notifyListeners();
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
        // For simplicity, store to M or current variable context if we had one.
        // On a Casio, STO is followed by a variable key.
        // Here we'll just store to memory.
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
