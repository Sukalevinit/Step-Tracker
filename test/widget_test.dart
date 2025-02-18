// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/main.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/providers/step_provider.dart';
import 'mocks/pedometer_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});

    // Mock platform channels
    const MethodChannel('plugins.flutter.io/shared_preferences')
      .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{};
        }
        return null;
    });

    // Mock orientation
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'SystemChrome.setPreferredOrientations') {
          return null;
        }
        return null;
    });

    // Set up pedometer mock
    MockPedometer.setUpMockPlatformChannel();
  });

  testWidgets('Step Tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the widget to rebuild and animations to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify that the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
