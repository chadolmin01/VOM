// Basic Flutter widget test for V.O.M app

import 'package:flutter_test/flutter_test.dart';
import 'package:vom_user/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VomApp(isFirstRun: true));

    // Verify that the app loads (onboarding screen should appear)
    expect(find.text('반가워요 👋'), findsOneWidget);
  });
}
