import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class StepProvider with ChangeNotifier {
  int _steps = 0;
  double _km = 0.0;
  double _calories = 0.0;
  DateTime? _startTime;
  late Stream<StepCount> _stepCountStream;
  bool _isTracking = false;
  double _strideLength = 0.762; // Average stride length in meters
  double _caloriesPerStep = 0.04; // Average calories burned per step
  
  // Settings
  int _stepGoal = 7000;
  int _waterGoal = 500;
  int _waterIntake = 0;
  int _reminderInterval = 30;
  bool _hasAnimations = true;
  bool _hasSoundEffects = true;

  int get steps => _steps;
  double get km => _km;
  double get calories => _calories;
  bool get isTracking => _isTracking;
  String get volumeUnit => 'ml';
  
  // Settings getters
  int get stepGoal => _stepGoal;
  int get waterGoal => _waterGoal;
  int get waterIntake => _waterIntake;
  int get reminderInterval => _reminderInterval;
  bool get hasAnimations => _hasAnimations;
  bool get hasSoundEffects => _hasSoundEffects;

  String get elapsedTime {
    if (_startTime == null) return '0.00';
    final difference = DateTime.now().difference(_startTime!);
    return (difference.inMinutes / 60).toStringAsFixed(2);
  }

  double get kilometers => _steps * 0.0007;
  int get caloriesBurned => (_steps * 0.04).round();

  StepProvider() {
    _initPedometer();
    _loadSavedData();
  }

  Future<void> setStepGoal(int goal) async {
    _stepGoal = goal;
    await _saveData();
    notifyListeners();
  }

  Future<void> setWaterGoal(int goal) async {
    _waterGoal = goal;
    await _saveData();
    notifyListeners();
  }

  Future<void> setWaterIntake(int intake) async {
    _waterIntake = intake;
    await _saveData();
    notifyListeners();
  }

  Future<void> setReminderInterval(int minutes) async {
    _reminderInterval = minutes;
    await _saveData();
    notifyListeners();
  }

  Future<void> setAnimations(bool enabled) async {
    _hasAnimations = enabled;
    await _saveData();
    notifyListeners();
  }

  Future<void> setSoundEffects(bool enabled) async {
    _hasSoundEffects = enabled;
    await _saveData();
    notifyListeners();
  }

  Future<void> incrementWater() async {
    if (_waterIntake < _waterGoal) {
      _waterIntake += 250;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> decrementWater() async {
    if (_waterIntake > 0) {
      _waterIntake -= 250;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> _initPedometer() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
    }
  }

  void _onStepCount(StepCount event) {
    if (!_isTracking) {
      _startTime = DateTime.now();
      _isTracking = true;
    }
    _steps = event.steps;
    _calculateStats();
    _saveData();
    notifyListeners();
  }

  void _onStepCountError(error) {
    print('Step count error: $error');
  }

  void _calculateStats() {
    _km = (_steps * _strideLength) / 1000;
    _calories = _steps * _caloriesPerStep;
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps', _steps);
    await prefs.setDouble('km', _km);
    await prefs.setDouble('calories', _calories);
    await prefs.setInt('stepGoal', _stepGoal);
    await prefs.setInt('waterGoal', _waterGoal);
    await prefs.setInt('waterIntake', _waterIntake);
    await prefs.setInt('reminderInterval', _reminderInterval);
    await prefs.setBool('hasAnimations', _hasAnimations);
    await prefs.setBool('hasSoundEffects', _hasSoundEffects);
    if (_startTime != null) {
      await prefs.setString('startTime', _startTime!.toIso8601String());
    }
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _steps = prefs.getInt('steps') ?? 0;
    _km = prefs.getDouble('km') ?? 0.0;
    _calories = prefs.getDouble('calories') ?? 0.0;
    _stepGoal = prefs.getInt('stepGoal') ?? 7000;
    _waterGoal = prefs.getInt('waterGoal') ?? 500;
    _waterIntake = prefs.getInt('waterIntake') ?? 0;
    _reminderInterval = prefs.getInt('reminderInterval') ?? 30;
    _hasAnimations = prefs.getBool('hasAnimations') ?? true;
    _hasSoundEffects = prefs.getBool('hasSoundEffects') ?? true;
    final savedStartTime = prefs.getString('startTime');
    if (savedStartTime != null) {
      _startTime = DateTime.parse(savedStartTime);
      _isTracking = true;
    }
    notifyListeners();
  }

  Future<void> resetStats() async {
    _steps = 0;
    _km = 0.0;
    _calories = 0.0;
    _startTime = null;
    _isTracking = false;
    await _saveData();
    notifyListeners();
  }

  String exportToCsv() {
    return 'Date,Steps,Distance (km),Calories\n'
           '${DateTime.now().toIso8601String()},$_steps,${_km.toStringAsFixed(2)},$_calories';
  }
}
