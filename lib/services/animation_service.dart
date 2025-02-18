import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true;

  // Animation controllers
  late AnimationController _stepAnimationController;
  late AnimationController _waterAnimationController;

  void initialize(TickerProvider vsync) {
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );

    _waterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
  }

  void dispose() {
    _stepAnimationController.dispose();
    _waterAnimationController.dispose();
    _audioPlayer.dispose();
  }

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  Future<void> playStepAnimation() async {
    if (_stepAnimationController.isAnimating) return;
    
    _stepAnimationController.forward(from: 0);
    if (_isSoundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/step.mp3'));
    }
  }

  Future<void> playWaterAnimation() async {
    if (_waterAnimationController.isAnimating) return;
    
    _waterAnimationController.forward(from: 0);
    if (_isSoundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/water.mp3'));
    }
  }

  Future<void> playAchievementSound() async {
    if (_isSoundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/achievement.mp3'));
    }
  }

  AnimationController get stepAnimationController => _stepAnimationController;
  AnimationController get waterAnimationController => _waterAnimationController;
}
