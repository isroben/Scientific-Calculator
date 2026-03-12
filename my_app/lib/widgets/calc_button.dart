import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  final String label;
  final String? top;
  final String? right;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final double fontSize;
  final double subFontSize;
  final FontWeight fontWeight;
  final double verticalPadding;
  final double horizontalPadding;

  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.top,
    this.right,
    this.color = const Color(0xFF3F444D),
    this.textColor = Colors.white,
    this.fontSize = 16,
    this.subFontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.verticalPadding = 1.0,
    this.horizontalPadding = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Column(
          children: [
            // Sub-labels row with minimal horizontal padding to move them "bit inside"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: SizedBox(
                height: subFontSize + 3,
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildSubLabel(top, const Color(0xFFB5C99A)),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _buildSubLabel(right, const Color(0xFFD98E94)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Very small gap between sub-labels and button
            const SizedBox(height: 0.1),
            // Main Button
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: textColor,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubLabel(String? text, Color labelColor) {
    if (text == null) return const SizedBox.shrink();
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: labelColor,
          fontSize: subFontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
