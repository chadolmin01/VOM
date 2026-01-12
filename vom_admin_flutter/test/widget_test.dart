// Basic Flutter widget test for V.O.M Admin app

import 'package:flutter_test/flutter_test.dart';
import 'package:vom_admin/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VomAdminApp());

    // Verify that the app loads (login screen should appear)
    expect(find.text('V.O.M'), findsOneWidget);
  });
}
