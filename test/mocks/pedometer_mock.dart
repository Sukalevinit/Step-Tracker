import 'package:pedometer/pedometer.dart';

class MockPedometer {
  static Stream<StepCount> stepCountStream() {
    return Stream.fromIterable([
      StepCount(steps: 0, timeStamp: DateTime.now()),
    ]);
  }
}
