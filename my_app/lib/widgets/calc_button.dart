import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  final String label;
  final String? subLabelTop;
  final String? subLabelRight;
  final Color backgroundColor;
  final Color textColor;
  final Color? subTextColorTop;
  final Color? subTextColorRight;
  final VoidCallback onPressed;
  final double fontSize;
  final double subFontSize;
  final Widget? icon;
  final bool isWide;

  const CalcButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.subLabelTop,
    this.subLabelRight,
    this.backgroundColor = const Color(0xFF31363D),
    this.textColor = Colors.white,
    this.subTextColorTop = const Color(0xFFA5B495),
    this.subTextColorRight = const Color(0xFFD18A90),
    this.fontSize = 15,
    this.subFontSize = 8,
    this.icon,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: isWide ? 1 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subLabelTop ?? '',
                    style: TextStyle(
                      color: subTextColorTop,
                      fontSize: subFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subLabelRight ?? '',
                    style: TextStyle(
                      color: subTextColorRight,
                      fontSize: subFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: textColor,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: Colors.black,
                ),
                child: icon ?? Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
