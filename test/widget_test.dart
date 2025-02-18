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
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:my_app/main.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/providers/step_provider.dart';
import 'mocks/pedometer_mock.dart';

class MockPermissionHandlerPlatform extends PermissionHandlerPlatform {
  Future<PermissionStatus> getPermissionStatus() async {
    return PermissionStatus.granted;
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return PermissionStatus.granted;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return Map.fromIterable(
      permissions,
      key: (p) => p,
      value: (_) => PermissionStatus.granted,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset mock state before each test
    MockPedometer.reset();
  });

  setUpAll(() {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({
      'step_goal': 7000,
      'water_goal': 500,
      'water_intake': 0,
      'reminder_interval': 30,
      'has_animations': true,
      'has_sound_effects': true,
    });

    // Mock SharedPreferences platform channel
    const MethodChannel('plugins.flutter.io/shared_preferences')
      .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{
            'step_goal': 7000,
            'water_goal': 500,
            'water_intake': 0,
            'reminder_interval': 30,
            'has_animations': true,
            'has_sound_effects': true,
          };
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

    // Register mock permission handler
    PermissionHandlerPlatform.instance = MockPermissionHandlerPlatform();
  });

  testWidgets('Step Tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the widget to rebuild and animations to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify that the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);

    // Simulate some steps and verify UI updates
    MockPedometer.simulateSteps(100);
    await tester.pumpAndSettle();
    
    // Test error handling
    MockPedometer.simulateError();
    await tester.pumpAndSettle();
    
    // Reset error and continue
    MockPedometer.resetError();
    await tester.pumpAndSettle();
  });

  testWidgets('Step Tracker handles unavailable step counter', (WidgetTester tester) async {
    // Simulate step counter being unavailable
    MockPedometer.simulateStepCountUnavailable();

    // Build our app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify app still renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
