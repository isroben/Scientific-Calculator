import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('Calculator UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScientificCalculatorApp());

    // Verify that the display area exists.
    expect(find.text('RAD'), findsOneWidget);
    expect(find.text('MATH'), findsOneWidget);
    
    // Verify some buttons exist
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '='), findsOneWidget);
  });
}
