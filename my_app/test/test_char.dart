import 'package:my_app/data/keypad_layout.dart';

void main() {
  final k = scientificKeys.firstWhere((k) => k.label.startsWith('x'));
  print("Found keys starting with x:");
  for (var key in scientificKeys.where((k) => k.label.startsWith('x'))) {
    print("'${key.label}' => ${key.label.codeUnits}");
  }
}
