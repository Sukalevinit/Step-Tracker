import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';

class MockPedometer {
  static final StreamController<StepCount> _stepController = StreamController<StepCount>.broadcast();
  static bool _isInitialized = false;

  static void setUpMockPlatformChannel() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Mock method channel
    const MethodChannel('pedometer')
      .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'startListening':
            _startMockStepUpdates();
            return true;
          case 'stopListening':
            await _stepController.close();
            return true;
          case 'isStepCountAvailable':
            return true;
          default:
            return null;
        }
    });

    // Mock event channel for step updates
    const EventChannel('pedometer/stepCount')
      .setMockMethodCallHandler((MethodCall methodCall) async {
        return null;
    });
  }

  static void _startMockStepUpdates() {
    // Simulate step updates every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_stepController.isClosed) {
        _stepController.add(
          StepCount(
            steps: timer.tick * 10, // Simulate 10 steps per second
            timeStamp: DateTime.now(),
          ),
        );
      } else {
        timer.cancel();
      }
    });
  }

  static Stream<StepCount> get stepCountStream => _stepController.stream;
}
