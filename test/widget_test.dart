import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_diet_assistant/main.dart';
import 'package:smart_diet_assistant/providers/app_state.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AppState())],
        child: const SmartDietApp(),
      ),
    );

    // Verify that the Role Selection screen appears by looking for text
    expect(find.text('Welcome to\nSmart Diet Assistant'), findsOneWidget);

    // Verify icon exists
    expect(find.byIcon(Icons.arrow_forward_ios), findsWidgets);
  });
}