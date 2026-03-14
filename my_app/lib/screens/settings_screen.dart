import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
              child: _selectedTabIndex == 0 ? _buildCalculationTab() : _buildPlaceholderTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Calculation', 'Display', 'Keyboard', 'Format', 'Graph'];
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
}
