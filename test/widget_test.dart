// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';

import 'package:ai_tutor/main.dart';
import 'package:provider/provider.dart';
import 'package:ai_tutor/providers/tutor_provider.dart';

void main() {
  testWidgets('App starts with Onboarding Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TutorProvider()),
        ],
        child: const AITutorApp(),
      ),
    );

    // Verify that the title is present (from AppBar in Onboarding)
    expect(find.text('Welcome to AI English Tutor'), findsOneWidget);
  });
}
