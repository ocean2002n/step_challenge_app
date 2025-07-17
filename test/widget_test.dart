// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_challenge_app/main.dart';
import 'package:step_challenge_app/services/locale_service.dart';
import 'package:step_challenge_app/services/deep_link_service.dart';
import 'package:step_challenge_app/services/auth_service.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(StepChallengeApp(
      localeService: LocaleService(),
      deepLinkService: DeepLinkService(),
      authService: AuthService(),
    ));

    // Wait for the app to render
    await tester.pumpAndSettle();

    // Verify that our app loads (check for any text widget to ensure app rendered)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
