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
  final bool isLarge;

  const CalcButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.subLabelTop,
    this.subLabelRight,
    this.backgroundColor = const Color(0xFF3F444D),
    this.textColor = Colors.white,
    this.subTextColorTop = const Color(0xFFB5C99A),
    this.subTextColorRight = const Color(0xFFFFB6C1),
    this.fontSize = 18,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subLabelTop ?? '',
                  style: TextStyle(color: subTextColorTop, fontSize: 10),
                ),
                Text(
                  subLabelRight ?? '',
                  style: TextStyle(color: subTextColorRight, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: double.infinity,
              height: isLarge ? 50 : 40,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: textColor,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
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
