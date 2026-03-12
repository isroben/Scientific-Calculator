import 'package:flutter/material.dart';
import '../models/calc_key.dart';
import '../constants/calc_colors.dart';

final List<CalcKey> scientificKeys = [

  // Row 1
  CalcKey(label: "SHIFT", color: CalcColors.shift, textColor: Colors.black),
  CalcKey(label: "ALPHA", color: CalcColors.alpha, textColor: Colors.black),
  CalcKey(label: "◄"),
  CalcKey(label: "►"),
  CalcKey(label: "MODE"),
  CalcKey(label: "≫"),

  // Row 2
  CalcKey(label: "CALC", top: "SOLVE", right: "="),
  CalcKey(label: "∫dx", top: "d/dx", right: ":"),
  CalcKey(label: "▲"),
  CalcKey(label: "▼"),
  CalcKey(label: "x⁻¹", top: "■!"),
  CalcKey(label: "Logₐb", top: "Σ", right: "Π"),

  // Row 3
  CalcKey(label: "□/□", top: "÷R"),
  CalcKey(label: "√x", top: "∛x", right: "mod"),
  CalcKey(label: "x²", top: "x³", right: "x̅"),
  CalcKey(label: "xⁿ", top: "ⁿ√x", right: ""),
  CalcKey(label: "Log", top: "10ⁿ", right: ""),
  CalcKey(label: "Ln", top: "eⁿ", right: "t"),

  // Row 4
  CalcKey(label: "(-)", top: "∠", right: "a"),
  CalcKey(label: "° '\"", top: "FACT", right: "b"),
  CalcKey(label: "hyp", top: "|x|", right: "c"),
  CalcKey(label: "Sin", top: "Sin⁻¹", right: "d"),
  CalcKey(label: "Cos", top: "Cos⁻¹", right: "e"),
  CalcKey(label: "Tan", top: "Tan⁻¹", right: "f"),

  // Row 5
  CalcKey(label: "RCL", top: "STO", right: "CLRv"),
  CalcKey(label: "ENG", top: "𝒊", right: "Cot"),
  CalcKey(label: "(",top: "%",right: "Cot⁻¹"),
  CalcKey(label: ")",top: ",", right: "x"),
  CalcKey(label: "S⇔D", top:"", right: "y"),
  CalcKey(label: "M+", top: "M-", right: "m"),
];

final List<CalcKey> numericKeys = [

  // Row 6
  CalcKey(label: "7", color: CalcColors.btnNumber, top: "CONST"),
  CalcKey(label: "8", color: CalcColors.btnNumber, top: "CONV"),
  CalcKey(label: "9", color: CalcColors.btnNumber, top: "SI"),
  CalcKey(label: "⌫", color: CalcColors.btnAction),
  CalcKey(label: "CLR", color: CalcColors.btnAction, top: "CLR All"),

  // Row 7
  CalcKey(label: "4", color: CalcColors.btnNumber, top: "MATRIX", right: "::"),
  CalcKey(label: "5", color: CalcColors.btnNumber, top: "VECTOR"),
  CalcKey(label: "6", color: CalcColors.btnNumber, top: "FUNC", right: "HELP"),
  CalcKey(
    label: "×",
    color: CalcColors.btnOperator,
    textColor: Colors.black,
    top: "nPr",
    right: "GCD",
  ),
  CalcKey(
    label: "÷",
    color: CalcColors.btnOperator,
    textColor: Colors.black,
    top: "nCr",
    right: "LCM",
  ),

  // Row 8
  CalcKey(label: "1", color: CalcColors.btnNumber, top: "STAT"),
  CalcKey(label: "2", color: CalcColors.btnNumber, top: "CMPLX"),
  CalcKey(label: "3", color: CalcColors.btnNumber, top: "DISTR"),
  CalcKey(
    label: "+",
    color: CalcColors.btnOperator,
    textColor: Colors.black,
    top: "Pol",
    right: "Ceil",
  ),
  CalcKey(
    label: "-",
    color: CalcColors.btnOperator,
    textColor: Colors.black,
    top: "Rec",
    right: "Floor",
  ),

  // Row 9
  CalcKey(label: "0", color: CalcColors.btnNumber, top: "Copy", right: "Paste"),
  CalcKey(
    label: ".",
    color: CalcColors.btnNumber,
    top: "Ran#",
    right: "RanInt",
  ),
  CalcKey(label: "Exp", color: CalcColors.btnNumber, top: "π", right: "e"),
  CalcKey(
    label: "Ans",
    color: CalcColors.btnOperator,
    textColor: Colors.black,
    top: "~",
    right: "PreAns",
  ),
  CalcKey(
    label: "=",
    color: CalcColors.btnOperator,
    textColor: Colors.black,
    top: "History",
  ),
];