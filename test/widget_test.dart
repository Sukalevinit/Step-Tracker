import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:my_app/main.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/providers/step_provider.dart';
import 'mocks/pedometer_mock.dart';
import 'mocks/shared_preferences_mock.dart';
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
    // Reset all mock states before each test
    MockPedometer.reset();
    SharedPreferencesMock.reset();
    mockPermissionHandler = MockPermissionHandlerPlatform();
    mockPermissionHandler.simulatePermissionGranted();
    PermissionHandlerPlatform.instance = mockPermissionHandler;
  });

  setUpAll(() {
    SharedPreferencesMock.setUp();

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
    group('Initialization Tests', () {
      testWidgets('App initializes with correct default values', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('7000'), findsOneWidget); // Default step goal
        expect(find.text('500'), findsOneWidget); // Default water goal
      });

      testWidgets('App loads saved preferences', (WidgetTester tester) async {
        SharedPreferencesMock.setValue('step_goal', 10000);
        SharedPreferencesMock.setValue('water_goal', 1000);

        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        expect(find.text('10000'), findsOneWidget);
        expect(find.text('1000'), findsOneWidget);
      });
    });

    group('Step Tracking Tests', () {
      testWidgets('Step counting works correctly', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        MockPedometer.simulateSteps(100);
        await TestHelper.pumpAndWait(tester);
        expect(find.text('100'), findsOneWidget);

        MockPedometer.simulateSteps(250);
        await TestHelper.pumpAndWait(tester);
        expect(find.text('250'), findsOneWidget);
      });

      testWidgets('Step goal achievement is recognized', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        MockPedometer.simulateSteps(7000); // Default goal
        await TestHelper.pumpAndWait(tester);

        expect(find.byIcon(Icons.celebration), findsOneWidget);
      });
    });

    group('Water Tracking Tests', () {
      testWidgets('Water intake tracking works correctly', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        final addWaterButton = find.byIcon(Icons.add);
        await TestHelper.tapAndWait(tester, addWaterButton);
        expect(find.text('100'), findsOneWidget);

        await TestHelper.tapAndWait(tester, addWaterButton);
        expect(find.text('200'), findsOneWidget);
      });

      testWidgets('Water goal achievement is recognized', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        // Add water until goal is reached
        final addWaterButton = find.byIcon(Icons.add);
        for (var i = 0; i < 5; i++) {
          await TestHelper.tapAndWait(tester, addWaterButton);
        }

        expect(find.byIcon(Icons.water_drop), findsOneWidget);
      });
    });

    group('Settings Tests', () {
      testWidgets('Can update step goal', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        // Navigate to settings
        await TestHelper.tapAndWait(tester, find.byIcon(Icons.settings));
        
        // Find and tap step goal setting
        final stepGoalField = find.byKey(const Key('step_goal_field'));
        await TestHelper.tapAndWait(tester, stepGoalField);
        
        // Enter new value
        await tester.enterText(stepGoalField, '10000');
        await TestHelper.tapAndWait(tester, find.text('Save'));

        expect(SharedPreferencesMock.getValue('step_goal'), 10000);
      });

      testWidgets('Can toggle animations', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        // Navigate to settings
        await TestHelper.tapAndWait(tester, find.byIcon(Icons.settings));
        
        // Toggle animations
        final animationSwitch = find.byKey(const Key('animation_switch'));
        await TestHelper.tapAndWait(tester, animationSwitch);

        expect(SharedPreferencesMock.getValue('has_animations'), false);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('Handles step counter unavailability gracefully', (WidgetTester tester) async {
        MockPedometer.simulateStepCountUnavailable();
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        expect(find.textContaining('unavailable'), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('Handles permission denied scenario', (WidgetTester tester) async {
        mockPermissionHandler.simulatePermissionDenied();
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        expect(find.textContaining('permission'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget); // Request permission button
      });

      testWidgets('Handles pedometer errors gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        MockPedometer.simulateError();
        await TestHelper.pumpAndWait(tester);
        expect(find.textContaining('error'), findsOneWidget);

        MockPedometer.resetError();
        await TestHelper.pumpAndWait(tester);
        expect(find.textContaining('error'), findsNothing);
      });

      testWidgets('Recovers from temporary errors', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        // Simulate error
        MockPedometer.simulateError();
        await TestHelper.pumpAndWait(tester);
        expect(find.textContaining('error'), findsOneWidget);

        // Reset error and simulate steps
        MockPedometer.resetError();
        await TestHelper.pumpAndWait(tester);
        MockPedometer.simulateSteps(100);
        await TestHelper.pumpAndWait(tester);

        expect(find.text('100'), findsOneWidget);
        expect(find.textContaining('error'), findsNothing);
      });
    });

    group('State Management Tests', () {
      testWidgets('Provider updates are reflected in UI', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        final context = tester.element(find.byType(HomeScreen));
        final provider = context.read<StepProvider>();

        // Update step count through provider
        provider.updateStepCount(150);
        await TestHelper.pumpAndWait(tester);
        expect(find.text('150'), findsOneWidget);

        // Update water intake through provider
        provider.addWater();
        await TestHelper.pumpAndWait(tester);
        expect(find.text('100'), findsOneWidget);
      });

      testWidgets('State persists across widget rebuilds', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        // Set initial state
        MockPedometer.simulateSteps(200);
        await TestHelper.pumpAndWait(tester);
        expect(find.text('200'), findsOneWidget);

        // Rebuild widget
        await tester.pumpWidget(const MyApp());
        await TestHelper.pumpAndWait(tester);

        // Verify state persists
        expect(find.text('200'), findsOneWidget);
      });
    });
  });
}
