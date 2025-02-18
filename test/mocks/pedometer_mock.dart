import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';

class MockPedometer {
  static final StreamController<StepCount> _stepController = StreamController<StepCount>.broadcast();
  static Timer? _updateTimer;
  static bool _isInitialized = false;
  static bool _isStepCountAvailable = true;
  static bool _shouldSimulateError = false;

  // Test helper methods
  static void simulateStepCountUnavailable() {
    _isStepCountAvailable = false;
  }

  static void simulateStepCountAvailable() {
    _isStepCountAvailable = true;
  }

  static void simulateError() {
    _shouldSimulateError = true;
  }

  static void resetError() {
    _shouldSimulateError = false;
  }

  static void simulateSteps(int steps) {
    if (!_stepController.isClosed) {
      _stepController.add(
        StepCount(
          steps: steps,
          timeStamp: DateTime.now(),
        ),
      );
    }
  }

  static void setUpMockPlatformChannel() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Mock method channel
    const MethodChannel('pedometer')
      .setMockMethodCallHandler((MethodCall methodCall) async {
        if (_shouldSimulateError) {
          throw PlatformException(
            code: 'PEDOMETER_ERROR',
            message: 'Simulated pedometer error',
          );
        }

        switch (methodCall.method) {
          case 'startListening':
            if (!_isStepCountAvailable) {
              throw PlatformException(
                code: 'STEP_COUNT_UNAVAILABLE',
                message: 'Step count is not available on this device',
              );
            }
            _startMockStepUpdates();
            return true;
          case 'stopListening':
            await _cleanup();
            return true;
          case 'isStepCountAvailable':
            return _isStepCountAvailable;
          default:
            throw PlatformException(
              code: 'UNSUPPORTED_METHOD',
              message: 'Method ${methodCall.method} is not supported',
            );
        }
    });

    // Mock event channel for step updates
    const EventChannel('pedometer/stepCount')
      .setMockMethodCallHandler((MethodCall methodCall) async {
        if (_shouldSimulateError) {
          throw PlatformException(
            code: 'PEDOMETER_ERROR',
            message: 'Simulated pedometer error',
          );
        }
        return null;
    });
  }

  static Future<void> _cleanup() async {
    _updateTimer?.cancel();
    _updateTimer = null;
    if (!_stepController.isClosed) {
      await _stepController.close();
    }
  }

  static void _startMockStepUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_shouldSimulateError) {
        timer.cancel();
        _stepController.addError(
          PlatformException(
            code: 'PEDOMETER_ERROR',
            message: 'Simulated pedometer error during updates',
          ),
        );
        return;
      }

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

  // Cleanup method for tests
  static void reset() {
    _cleanup();
    _isInitialized = false;
    _isStepCountAvailable = true;
    _shouldSimulateError = false;
  }
}
