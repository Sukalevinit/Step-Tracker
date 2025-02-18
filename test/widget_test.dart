import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:my_app/main.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/providers/step_provider.dart';
import 'mocks/pedometer_mock.dart';
import 'helpers/test_helper.dart';

class MockPermissionHandlerPlatform extends PermissionHandlerPlatform {
  bool _shouldDenyPermission = false;

  void simulatePermissionDenied() {
    _shouldDenyPermission = true;
  }

  void simulatePermissionGranted() {
    _shouldDenyPermission = false;
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return _shouldDenyPermission ? PermissionStatus.denied : PermissionStatus.granted;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return Map.fromIterable(
      permissions,
      key: (p) => p,
      value: (_) => _shouldDenyPermission ? PermissionStatus.denied : PermissionStatus.granted,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockPermissionHandlerPlatform mockPermissionHandler;

  setUp(() {
    // Reset mock states before each test
    MockPedometer.reset();
    mockPermissionHandler = MockPermissionHandlerPlatform();
    mockPermissionHandler.simulatePermissionGranted();
    PermissionHandlerPlatform.instance = mockPermissionHandler;
  });

  setUpAll(() {
    TestHelper.setUpPreferences();

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
  });

  group('Step Tracker App Tests', () {
    testWidgets('App initializes and renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await TestHelper.pumpAndWait(tester);

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Step counting works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await TestHelper.pumpAndWait(tester);

      // Simulate steps and verify UI updates
      MockPedometer.simulateSteps(100);
      await TestHelper.pumpAndWait(tester);
      expect(find.text('100'), findsOneWidget);

      // Simulate more steps
      MockPedometer.simulateSteps(250);
      await TestHelper.pumpAndWait(tester);
      expect(find.text('250'), findsOneWidget);
    });

    testWidgets('Handles step counter unavailability gracefully', (WidgetTester tester) async {
      MockPedometer.simulateStepCountUnavailable();
      await tester.pumpWidget(const MyApp());
      await TestHelper.pumpAndWait(tester);

      // Verify app shows appropriate message
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.textContaining('unavailable'), findsOneWidget);
    });

    testWidgets('Handles permission denied scenario', (WidgetTester tester) async {
      mockPermissionHandler.simulatePermissionDenied();
      await tester.pumpWidget(const MyApp());
      await TestHelper.pumpAndWait(tester);

      // Verify app shows permission request UI
      expect(find.textContaining('permission'), findsOneWidget);
    });

    testWidgets('Handles pedometer errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await TestHelper.pumpAndWait(tester);

      // Simulate pedometer error
      MockPedometer.simulateError();
      await TestHelper.pumpAndWait(tester);
      
      // Verify error state is handled
      expect(find.textContaining('error'), findsOneWidget);

      // Reset error and verify recovery
      MockPedometer.resetError();
      await TestHelper.pumpAndWait(tester);
      expect(find.textContaining('error'), findsNothing);
    });

    testWidgets('Water tracking works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await TestHelper.pumpAndWait(tester);

      // Find and tap water add button
      final addWaterButton = find.byIcon(Icons.add);
      await TestHelper.tapAndWait(tester, addWaterButton);

      // Verify water intake increased
      expect(find.textContaining('100'), findsOneWidget);
    });
  });
}
