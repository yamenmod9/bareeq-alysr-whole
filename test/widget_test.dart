import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bareeq_alysr/main.dart';

void main() {
  testWidgets('App boots with loading state', (WidgetTester tester) async {
    await tester.pumpWidget(const BareeqApp());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
