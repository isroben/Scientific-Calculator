import 'package:flutter/material.dart';

class CalcKey {
  final String label;
  final String? top;
  final String? right;
  final Color color;
  final Color textColor;
  final IconData? icon;

  const CalcKey({
    required this.label,
    this.top,
    this.right,
    this.color = const Color(0xFF31363D),
    this.textColor = Colors.white,
    this.icon,
  });
}
