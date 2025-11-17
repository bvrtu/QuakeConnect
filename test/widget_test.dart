import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quakeconnect/main.dart';

void main() {
  testWidgets('QuakeConnect renders bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const QuakeConnectApp());

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Safety'), findsOneWidget);
  });
}
