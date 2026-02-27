import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('PokerCalc smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PokerCalcApp());
    expect(find.text('PokerCalc'), findsOneWidget);
  });
}
