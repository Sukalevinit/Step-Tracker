import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestHelper {
  static Future<void> setUpPreferences({
    int stepGoal = 7000,
    int waterGoal = 500,
    int waterIntake = 0,
    int reminderInterval = 30,
    bool hasAnimations = true,
    bool hasSoundEffects = true,
  }) async {
    SharedPreferences.setMockInitialValues({
      'step_goal': stepGoal,
      'water_goal': waterGoal,
      'water_intake': waterIntake,
      'reminder_interval': reminderInterval,
      'has_animations': hasAnimations,
      'has_sound_effects': hasSoundEffects,
    });
  }

  static Future<void> pumpAndWait(WidgetTester tester, [Duration? duration]) async {
    await tester.pump(duration ?? const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
  }

  static Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await pumpAndWait(tester);
  }
}
