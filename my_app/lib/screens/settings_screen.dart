import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/calculator_state.dart';
import '../services/calculator_service.dart';

class SettingsScreen extends StatefulWidget {
  final CalculatorState state;

  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF2C2C2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF5AB9EA)),
              onSelected: (value) {
                if (value == 'reset') {
                  widget.state.resetSettings();
                  setState(() {});
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'reset',
                  child: Text('Reset all settings'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Calculation', 'Display', 'Keyboard', 'Format', 'Graph', 'Math OCR', 'Other'];
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = _selectedTabIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? const Color(0xFF5AB9EA) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF5AB9EA) : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const Divider(height: 1, color: Colors.white10),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildCalculationTab();
      case 1:
        return _buildDisplayTab();
      case 2:
        return _buildKeyboardTab();
      case 3:
        return _buildFormatTab();
      case 4:
        return _buildGraphTab();
      case 5:
        return _buildMathOCRTab();
      case 6:
        return _buildOtherTab();
      default:
        return _buildPlaceholderTab();
    }
  }

  Widget _buildDisplayTab() {
    return ListView(
      children: [
        _buildSectionHeader('Display'),
        _buildSwitchSetting(
          'Clear screen',
          'Clear the screen before exiting.',
          widget.state.clearScreenOnExit,
          (val) => setState(() => widget.state.setClearScreenOnExit(val)),
        ),
        _buildSwitchSetting(
          'Blink cursor',
          '',
          widget.state.blinkCursorMode,
          (val) => setState(() => widget.state.setBlinkCursorMode(val)),
        ),
        _buildSwitchSetting(
          'Keep the screen on',
          '',
          widget.state.keepScreenOn,
          (val) => setState(() => widget.state.setKeepScreenOn(val)),
        ),
        _buildSliderSetting(
          'Display font size',
          widget.state.displayFontSize,
          12.0,
          40.0,
          (val) => setState(() => widget.state.setDisplayFontSize(val)),
          preview: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '1 234.781 23+33',
              style: GoogleFonts.getFont(
                widget.state.displayFontFamily,
                fontSize: widget.state.displayFontSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
        _buildBaseSetting(
          'Choose how the `Ans` variable will be displayed.',
          '',
          _buildAnsModePreview(),
        ),
        _buildValueNavigationTile(
          'Display Font',
          widget.state.displayFontFamily,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FontSelectionScreen(
                title: 'Display Font',
                selectedFont: widget.state.displayFontFamily,
                fonts: widget.state.availableDisplayFonts,
                onSelected: (font) => setState(() => widget.state.setDisplayFontFamily(font)),
              ),
            ),
          ),
        ),
        _buildValueNavigationTile(
          'App Font',
          widget.state.appFontFamily,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FontSelectionScreen(
                title: 'App Font',
                selectedFont: widget.state.appFontFamily,
                fonts: widget.state.availableAppFonts,
                onSelected: (font) => setState(() => widget.state.setAppFontFamily(font)),
              ),
            ),
          ),
        ),
        _buildSwitchSetting(
          'Show calculation information below the result',
          'Additional calculation information will be shown below the result, such as implicit multiplication and percentage calculations.',
          widget.state.showCalculationInfo,
          (val) => setState(() => widget.state.setShowCalculationInfo(val)),
        ),
        _buildSectionHeader('Calculator display shortcuts'),
        _buildSwitchSetting(
          'Math OCR',
          '',
          widget.state.mathOCR,
          (val) => setState(() => widget.state.setMathOCR(val)),
        ),
        _buildSwitchSetting(
          'Expression details',
          '',
          widget.state.expressionDetails,
          (val) => setState(() => widget.state.setExpressionDetails(val)),
        ),
        _buildSwitchSetting(
          'Graph',
          '',
          widget.state.showGraph,
          (val) => setState(() => widget.state.setShowGraph(val)),
        ),
        _buildSectionHeader('Calculator interface'),
        _buildSwitchSetting(
          'Show status bar',
          '',
          widget.state.showStatusBar,
          (val) => setState(() => widget.state.setShowStatusBar(val)),
        ),
        _buildNavigationSetting('Font', widget.state.displayFontFamily),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCalculationTab() {
    return ListView(
      children: [
        _buildSectionHeader('Calculation'),
        _buildAngleUnitSetting(),
        _buildDefaultOutputSetting(),
        _buildImpliedMultiplicationSetting(),
        _buildPercentageSetting(),
        _buildSectionHeader('Calculation'),
        _buildSwitchSetting(
          'CAS mode',
          'The calculator can perform algebraic operations like factoring and solving, and provide exact simplified answers with variables.',
          widget.state.casMode,
          (val) => setState(() => widget.state.setCasMode(val)),
        ),
        _buildSwitchSetting(
          'Automatically calculate',
          'Display results as you finish typing',
          widget.state.autoCalculate,
          (val) => setState(() => widget.state.setAutoCalculate(val)),
        ),
        _buildSwitchSetting(
          'Automatically calculate in DMS format',
          'When operations involve sexagesimal and decimal values, the result is displayed in sexagesimal format.',
          widget.state.autoCalculateDMS,
          (val) => setState(() => widget.state.setAutoCalculateDMS(val)),
        ),
        _buildSectionHeader('CMPLX'),
        _buildNavigationSetting('Default output format in CMPLX mode', 'Complex number (a+bi)'),
        _buildSectionHeader('STAT/DISTR'),
        _buildSwitchSetting(
          'Frequency column',
          'Show the frequency column (n) in the statistical editor.',
          widget.state.frequencyColumn,
          (val) => setState(() => widget.state.setFrequencyColumn(val)),
        ),
        _buildSectionHeader('TABLE'),
        _buildSwitchSetting(
          'Use the g(x) function',
          '',
          widget.state.useGXFunction,
          (val) => setState(() => widget.state.setUseGXFunction(val)),
        ),
        _buildSectionHeader('Other'),
        _buildSwitchSetting(
          'Ignore the plus and minus operators at the end of an input expression',
          'The input expression "3+4+" is considered valid',
          widget.state.ignoreExtraOperators,
          (val) => setState(() => widget.state.setIgnoreExtraOperators(val)),
        ),
        _buildSwitchSetting(
          'Automatically calculate the integral ∫dx',
          '',
          widget.state.autoCalculateIntegral,
          (val) => setState(() => widget.state.setAutoCalculateIntegral(val)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPlaceholderTab() {
    return const Center(child: Text('Coming Soon', style: TextStyle(color: Colors.white54)));
  }

  Widget _buildKeyboardTab() {
    return ListView(
      children: [
        _buildSectionHeader('Vibration and sound'),
        _buildSwitchSetting(
          'Vibrate on keypress',
          'Vibrate when a key is pressed',
          widget.state.vibrateOnKeypress,
          (val) => setState(() => widget.state.setVibrateOnKeypress(val)),
        ),
        _buildSwitchSetting(
          'Sound effect',
          'Play a sound effect when a key is pressed',
          widget.state.playSoundEffect,
          (val) => setState(() => widget.state.setPlaySoundEffect(val)),
        ),
        _buildSectionHeader('Keyboard'),
        _buildBaseSetting(
          'Keyboard layout',
          '',
          _buildSegmentedControl<String>(
            {
              'Calc 570/991 ES': 'Calc 570/991 ES',
              'Calc 580/991 EX (OPTN)': 'Calc 580/991 EX (OPTN)',
            },
            widget.state.keyboardLayout,
            (val) => widget.state.setKeyboardLayout(val),
          ),
        ),
        _buildNavigationSetting('Keymap', 'Customize calculator keyboard shortcuts'),
        _buildSliderSetting(
          'Keyboard font size scaling',
          widget.state.keyboardFontSizeScaling,
          0.75,
          2.0,
          (val) => setState(() => widget.state.setKeyboardFontSizeScaling(val)),
        ),
        _buildBaseSetting(
          'Button label style',
          '',
          _buildLabelStylePreview(),
        ),
        _buildBaseSetting(
          'Division sign',
          '',
          _buildSegmentedControl<String>(
            {'÷': '÷', '/': '/'},
            widget.state.divisionSign,
            (val) => widget.state.setDivisionSign(val),
          ),
        ),
        _buildBaseSetting(
          'Multiplication sign',
          '',
          _buildSegmentedControl<String>(
            {'×': '×', '*': '*'},
            widget.state.multiplicationSign,
            (val) => widget.state.setMultiplicationSign(val),
          ),
        ),
        _buildSwitchSetting(
          'Insert multiplication sign before a fraction',
          'To distinguish from a mixed fraction',
          widget.state.insertMultBeforeFraction,
          (val) => setState(() => widget.state.setInsertMultBeforeFraction(val)),
        ),
        _buildSwitchSetting(
          'Automatically add closing bracket',
          'When an opening parenthesis is entered, a closing parenthesis is added automatically; when a function key is pressed, both opening and closing parentheses are inserted.',
          widget.state.autoCloseBrackets,
          (val) => setState(() => widget.state.setAutoCloseBrackets(val)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildLabelStylePreview() {
    return Column(
      children: [
        _buildSegmentedControl<int>(
          {0: '0', 1: '1'},
          widget.state.buttonLabelStyle,
          (val) => widget.state.setButtonLabelStyle(val),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('x√y', style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 4),
                if (widget.state.buttonLabelStyle == 0)
                  Container(width: 40, height: 2, color: const Color(0xFF5AB9EA)),
              ],
            ),
            Column(
              children: [
                const Text('√■', style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 4),
                if (widget.state.buttonLabelStyle == 1)
                  Container(width: 40, height: 2, color: const Color(0xFF5AB9EA)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnsModePreview() {
    return Column(
      children: [
        _buildSegmentedControl<int>(
          {0: '0', 1: '1', 2: '2'},
          widget.state.ansDisplayMode,
          (val) => widget.state.setAnsDisplayMode(val),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAnsOptionPreview('Ans+3', 0),
            _buildAnsOptionPreview('12.123 4\nAns +3', 1),
            _buildAnsOptionPreview('12.123 4 +3', 2),
          ],
        ),
      ],
    );
  }

  Widget _buildAnsOptionPreview(String text, int index) {
    final isSelected = widget.state.ansDisplayMode == index;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: isSelected ? Border.all(color: const Color(0xFF5AB9EA), width: 1) : null,
        borderRadius: BorderRadius.circular(4),
        color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? const Color(0xFF5AB9EA) : Colors.white70,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSliderSetting(String title, double value, double min, double max, ValueChanged<double> onChanged, {Widget? preview}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
          if (preview != null) preview,
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF5AB9EA),
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF5AB9EA).withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF2C2C2E),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAngleUnitSetting() {
    return _buildBaseSetting(
      'Angle unit',
      '',
      _buildSegmentedControl<AngleUnit>(
        {
          AngleUnit.degree: 'Degree',
          AngleUnit.radian: 'Radian',
          AngleUnit.gradian: 'Gradian',
        },
        widget.state.angleUnit,
        (val) => widget.state.setAngleUnit(val),
      ),
    );
  }

  Widget _buildDefaultOutputSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBaseSetting(
          'Default output',
          '',
          _buildSegmentedControl<bool>(
            {
              true: 'Fraction',
              false: 'Decimal',
            },
            widget.state.isDefaultFractional,
            (val) => widget.state.toggleOutputMode(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Note: The default output can be changed by tapping the [FRAC/DEC] button at the top of the display.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white10),
      ],
    );
  }

  Widget _buildImpliedMultiplicationSetting() {
    return _buildBaseSetting(
      'Implied multiplication',
      'Determines the priority of implied multiplication in calculations and whether it has higher precedence than explicit multiplication and division.',
      _buildSegmentedControl<ImpliedMultiplication>(
        {
          ImpliedMultiplication.type1: '1/2π = 1/2*π',
          ImpliedMultiplication.type2: '1/2π = 1/(2*π)',
        },
        widget.state.impliedMultiplication,
        (val) => widget.state.setImpliedMultiplication(val),
      ),
    );
  }

  Widget _buildPercentageSetting() {
    return _buildBaseSetting(
      'Percentage calculation type',
      'Choose how percentages are calculated with addition and subtraction operators. This setting does not affect other operators like multiplication and division. Percentages are always calculated by dividing the term by 100 for these operators.',
      _buildSegmentedControl<PercentageType>(
        {
          PercentageType.type1: '100+20%=120',
          PercentageType.type2: '100+20%=100.2',
        },
        widget.state.percentageType,
        (val) => widget.state.setPercentageType(val),
      ),
    );
  }

  Widget _buildBaseSetting(String title, String description, Widget control) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.white)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(description, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          ],
          const SizedBox(height: 12),
          control,
        ],
      ),
    );
  }

  Widget _buildValueNavigationTile(String title, String value, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Color(0xFF5AB9EA), fontSize: 14)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchSetting(String title, String description, bool value, ValueChanged<bool> onChanged) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(description, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                    ],
                  ],
                ),
              ),
              CupertinoSwitch(
                value: value,
                activeColor: const Color(0xFF5AB9EA),
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white10),
      ],
    );
  }

  Widget _buildNavigationSetting(String title, String subtitle) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          trailing: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
          onTap: () {},
        ),
        const Divider(height: 1, color: Colors.white10),
      ],
    );
  }

  Widget _buildSegmentedControl<T>(Map<T, String> options, T selectedValue, ValueChanged<T> onSelected) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: options.entries.map((entry) {
          final isSelected = entry.key == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => onSelected(entry.key)),
              child: Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF5AB9EA) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormatTab() {
    return ListView(
      children: [
        _buildSectionHeader('Format'),
        _buildNavigationSetting('Decimal number format', 'Fixed, ENG, ENG SI, and SCI modes; Decimal precision'),
        _buildSwitchSetting(
          'Display polynomial in decreasing exponent order',
          'Display x³+2x²-x+6 instead of 6-x+2x²+x³',
          widget.state.displayPolyDecreasing,
          (val) => setState(() => widget.state.setDisplayPolyDecreasing(val)),
        ),
        _buildBaseSetting(
          'Decimal separator',
          '',
          _buildSegmentedControl<String>(
            {'.': 'Point 123.123', ',': 'Comma 123,123'},
            widget.state.decimalSeparator,
            (val) => widget.state.setDecimalSeparator(val),
          ),
        ),
        _buildNavigationSetting('Thousand separator', 'Space 123 123 123'),
        _buildNavigationSetting('Thousandth separator', 'Space 123 123 123'),
        _buildSwitchSetting(
          'Use Indian-style digit grouping',
          'Example: 1 13 23 23 45 56 890.234',
          widget.state.useIndianStyleGrouping,
          (val) => setState(() => widget.state.setUseIndianStyleGrouping(val)),
        ),
        _buildBaseSetting(
          'Scientific notation',
          '',
          _buildScientificNotationControl(),
        ),
        _buildSectionHeader('Digit grouping'),
        _buildBaseSetting(
          'Binary',
          '',
          _buildDigitGroupingControl(widget.state.binaryGrouping, (val) => widget.state.setBinaryGrouping(val)),
        ),
        _buildBaseSetting(
          'Octal',
          '',
          _buildDigitGroupingControl(widget.state.octalGrouping, (val) => widget.state.setOctalGrouping(val)),
        ),
        _buildBaseSetting(
          'Hexadecimal',
          '',
          _buildDigitGroupingControl(widget.state.hexGrouping, (val) => widget.state.setHexGrouping(val)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildGraphTab() {
    return ListView(
      children: [
        _buildSectionHeader('Graph'),
        _buildBaseSetting(
          'Graph theme',
          '',
          _buildSegmentedControl<int>(
            {0: 'Light theme', 1: 'Dark theme', 2: 'Automatic'},
            widget.state.graphTheme,
            (val) => widget.state.setGraphTheme(val),
          ),
        ),
        _buildBaseSetting(
          'Coordinate',
          '',
          _buildSegmentedControl<int>(
            {0: 'Cartesian coordinate', 1: 'Polar coordinate'},
            widget.state.coordinateSystem,
            (val) => widget.state.setCoordinateSystem(val),
          ),
        ),
        _buildSwitchSetting(
          'Show grid',
          '',
          widget.state.showGrid,
          (val) => setState(() => widget.state.setShowGrid(val)),
        ),
        _buildSwitchSetting(
          'Show axis labels',
          '',
          widget.state.showAxisLabels,
          (val) => setState(() => widget.state.setShowAxisLabels(val)),
        ),
        _buildSwitchSetting(
          'Independent zoom',
          'Allows zooming independently in both directions. This option will be ignored if the current coordinate system is polar.',
          widget.state.independentZoom,
          (val) => setState(() => widget.state.setIndependentZoom(val)),
        ),
        _buildBaseSetting(
          'Graph point style',
          'Draw continuous or discrete points',
          _buildSegmentedControl<int>(
            {0: 'Connected', 1: 'Dot'},
            widget.state.graphPointStyle,
            (val) => widget.state.setGraphPointStyle(val),
          ),
        ),
        _buildNavigationSetting('Clear all graph workspaces', ''),
        _buildSectionHeader('Polar graph'),
        _buildNavigationSetting('Polar start', ''),
        _buildNavigationSetting('Polar stop', ''),
        _buildNavigationSetting('Polar step', ''),
        _buildSectionHeader('Parametric graph'),
        _buildNavigationSetting('Parametric start', ''),
        _buildNavigationSetting('Parametric stop', ''),
        _buildNavigationSetting('Parametric step', ''),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildScientificNotationControl() {
    final Map<int, Widget> children = {
      0: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            children: [
              const TextSpan(text: '1.12341×10'),
              WidgetSpan(
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: const Text('³', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
        ),
      ),
      1: const Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text('1.12341E3', style: TextStyle(color: Colors.white, fontSize: 13)),
      ),
    };

    return _buildSegmentedControlWidget<int>(
      children,
      widget.state.scientificNotationMode,
      (val) => widget.state.setScientificNotationMode(val),
    );
  }

  Widget _buildDigitGroupingControl(int currentValue, ValueChanged<int> onChanged) {
    return _buildSegmentedControl<int>(
      {4: '4 digits', 8: '8 digits', 16: '16 digits', 32: '32 digits'},
      currentValue,
      onChanged,
    );
  }

  Widget _buildSegmentedControlWidget<T extends Object>(Map<T, Widget> children, T currentValue, ValueChanged<T> onChanged) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CupertinoSlidingSegmentedControl<T>(
        groupValue: currentValue,
        children: children.map((key, value) {
          return MapEntry(
            key,
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: value,
            ),
          );
        }),
        onValueChanged: (T? value) {
          if (value != null) {
            setState(() => onChanged(value));
          }
        },
        backgroundColor: const Color(0xFF1C1C1E),
        thumbColor: const Color(0xFF5AB9EA),
      ),
    );
  }

  Widget _buildMathOCRTab() {
    return ListView(
      children: [
        _buildSectionHeader('Recognition Logic'),
        _buildSwitchSetting(
          'Auto-detect separators',
          'Automatically detect how to interpret commas and dots in recognized LaTeX. If the input is ambiguous, the app will use the selected default options below.',
          widget.state.autoDetectSeparators,
          (val) => setState(() => widget.state.setAutoDetectSeparators(val)),
        ),
        _buildNavigationSetting(
          'Choose how to interpret commas (,) in recognized expressions',
          'Thousands separator (1,000 + 2,000 = 3000)',
        ),
        _buildNavigationSetting(
          'Choose how to interpret dots (.) in recognized expressions',
          'Decimal separator (2.5 + 1.3 = 3.8)',
        ),
        _buildSectionHeader('Behavior'),
        _buildNavigationSetting(
          'When recognition is successful with a single expression',
          'Do nothing',
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildOtherTab() {
    return ListView(
      children: [
        _buildSectionHeader('Unit Converter'),
        _buildBaseSetting(
          'Category order',
          '',
          _buildSegmentedControl<int>(
            {0: 'Default', 1: 'Alphabetical'},
            widget.state.unitCategoryOrder,
            (val) => widget.state.setUnitCategoryOrder(val),
          ),
        ),
        _buildBaseSetting(
          'Unit order',
          '',
          _buildSegmentedControl<int>(
            {0: 'Default', 1: 'Alphabetical'},
            widget.state.unitOrder,
            (val) => widget.state.setUnitOrder(val),
          ),
        ),
        _buildSectionHeader('Programming'),
        _buildBaseSetting(
          'Max history size',
          '',
          _buildSegmentedControl<int>(
            {50: '50', 100: '100', 500: '500', 1000: '1000'},
            widget.state.maxHistorySize,
            (val) => widget.state.setMaxHistorySize(val),
          ),
        ),
        _buildSectionHeader('Other'),
        _buildBaseSetting(
          'App icon',
          '',
          _buildAppIconPicker(),
        ),
        _buildNavigationSetting('App version', '3.5.6.1377'),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAppIconPicker() {
    return Column(
      children: [
        _buildSegmentedControl<int>(
          {0: '0', 1: '1', 2: '2'},
          widget.state.appIcon,
          (val) => widget.state.setAppIcon(val),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) {
            final isSelected = widget.state.appIcon == index;
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: isSelected ? Border.all(color: const Color(0xFF5AB9EA), width: 2) : null,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('assets/icons/app_icon_$index.png'), // Placeholder
                  fit: BoxFit.cover,
                  onError: (e, s) {},
                ),
              ),
              child: isSelected 
                ? const Icon(Icons.check_circle, color: Color(0xFF5AB9EA), size: 20)
                : null,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFontSelector() {
    return Container(); // No longer used
  }
}

class FontSelectionScreen extends StatelessWidget {
  final String title;
  final String selectedFont;
  final List<String> fonts;
  final ValueChanged<String> onSelected;

  const FontSelectionScreen({
    super.key,
    required this.title,
    required this.selectedFont,
    required this.fonts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        itemCount: fonts.length,
        separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
        itemBuilder: (context, index) {
          final font = fonts[index];
          final isSelected = font == selectedFont;
          return ListTile(
            title: Text(
              font,
              style: GoogleFonts.getFont(font, color: Colors.white),
            ),
            trailing: isSelected 
              ? const Icon(Icons.check, color: Color(0xFF5AB9EA)) 
              : null,
            onTap: () {
              onSelected(font);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
