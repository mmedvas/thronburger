// Basic Flutter widget test for Thronburger app

import 'package:flutter_test/flutter_test.dart';

import 'package:thronburger_app/main.dart';

void main() {
  testWidgets('App should start with login screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ThronburgerApp());

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that we see the Thronburger logo or login page
    expect(find.textContaining('THRONBURGER'), findsWidgets);
  });
}
