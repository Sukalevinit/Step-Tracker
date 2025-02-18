import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';

class MockPedometer {
  static void setUpMockPlatformChannel() {
    const MethodChannel('pedometer')
      .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'startListening':
            return true;
          case 'stopListening':
            return true;
          case 'isStepCountAvailable':
            return true;
          default:
            return null;
        }
    });

    // Mock EventChannel for step updates
    const EventChannel('step_count')
      .setMockMethodCallHandler((MethodCall methodCall) async {
        return null;
    });
  }

  static Stream<StepCount> stepCountStream() {
    return Stream.periodic(
      const Duration(seconds: 1),
      (count) => StepCount(
        steps: count,
        timeStamp: DateTime.now(),
      ),
    ).take(1); // Only emit one value for testing
  }
}
