import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesMock {
  static Map<String, dynamic> _preferences = {};

  static void reset() {
    _preferences = {
      'step_goal': 7000,
      'water_goal': 500,
      'water_intake': 0,
      'reminder_interval': 30,
      'has_animations': true,
      'has_sound_effects': true,
    };
  }

  static void setUp() {
    reset();
    SharedPreferences.setMockInitialValues(_preferences);

    const MethodChannel('plugins.flutter.io/shared_preferences')
      .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getAll':
            return Map<String, dynamic>.from(_preferences);
          case 'setBool':
            _preferences[methodCall.arguments['key']] = methodCall.arguments['value'];
            return true;
          case 'setInt':
            _preferences[methodCall.arguments['key']] = methodCall.arguments['value'];
            return true;
          case 'setDouble':
            _preferences[methodCall.arguments['key']] = methodCall.arguments['value'];
            return true;
          case 'setString':
            _preferences[methodCall.arguments['key']] = methodCall.arguments['value'];
            return true;
          case 'remove':
            _preferences.remove(methodCall.arguments['key']);
            return true;
          case 'clear':
            _preferences.clear();
            return true;
          default:
            return null;
        }
    });
  }

  static dynamic getValue(String key) {
    return _preferences[key];
  }

  static void setValue(String key, dynamic value) {
    _preferences[key] = value;
  }
}
