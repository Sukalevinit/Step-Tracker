// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_app/main.dart';
import 'package:my_app/providers/step_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mocks/pedometer_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Step Tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => StepProvider(),
        child: const MyApp(),
      ),
    );

    // Wait for the widget to rebuild
    await tester.pumpAndSettle();

    // Verify that the app renders without crashing
    expect(find.byType(MyApp), findsOneWidget);
  });
}
