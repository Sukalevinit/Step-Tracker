import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';

class MockPedometer {
  static void setUpMockPlatformChannel() {
    const MethodChannel('pedometer')
      .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'startListening':
            return null;
          case 'stopListening':
            return null;
          default:
            return null;
        }
    });
  }

  static Stream<StepCount> stepCountStream() {
    return Stream.fromIterable([
      StepCount(steps: 0, timeStamp: DateTime.now()),
    ]);
  }
}
