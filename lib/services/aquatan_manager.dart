import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/aquatan.dart';

class AquatanManager {
  AquatanState _state;
  Timer? _updateTimer;
  Timer? _animationTimer;
  final Function(AquatanState) onStateChanged;
  final Random _random = Random();

  AquatanManager({
    required AquatanState initialState,
    required this.onStateChanged,
  }) : _state = initialState {
    _startUpdateCycle();
    _startAnimationCycle();
  }

  AquatanState get state => _state;

  void dispose() {
    _updateTimer?.cancel();
    _animationTimer?.cancel();
  }

  void _startUpdateCycle() {
    _updateTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _updateState();
    });
  }

  void _startAnimationCycle() {
    _animationTimer = Timer.periodic(
      Duration(milliseconds: _getAnimationInterval()),
      (_) => _updatePose(),
    );
  }

  int _getAnimationInterval() {
    const baseInterval = 250;
    final energyModifier = (_state.energy / 100).clamp(0.1, 1.0); // Prevent division by zero
    final stageModifier = _state.growthStage.animationSpeed.clamp(0.1, 10.0);
    
    return (baseInterval / (energyModifier * stageModifier)).round().clamp(100, 1000);
  }

  void _updateState() {
    final now = DateTime.now();
    final hoursSinceLastFed = now.difference(_state.lastFed).inHours;
    final hoursSinceLastPlayed = now.difference(_state.lastPlayed).inHours;

    int health = _state.health;
    int happiness = _state.happiness;
    int energy = _state.energy;

    if (hoursSinceLastFed > 6) {
      health -= (hoursSinceLastFed - 6) * 2;
      energy -= (hoursSinceLastFed - 6) * 3;
    }

    if (hoursSinceLastPlayed > 12) {
      happiness -= (hoursSinceLastPlayed - 12) * 2;
    }

    if (_state.mood == AquatanMood.sleeping) {
      energy = (energy + 10).clamp(0, 100);
    }

    health = health.clamp(0, 100);
    happiness = happiness.clamp(0, 100);
    energy = energy.clamp(0, 100);

    final mood = _calculateMood(health, happiness, energy);
    final growthStage = _calculateGrowthStage();

    _state = _state.copyWith(
      health: health,
      happiness: happiness,
      energy: energy,
      mood: mood,
      growthStage: growthStage,
    );

    onStateChanged(_state);
  }

  AquatanMood _calculateMood(int health, int happiness, int energy) {
    if (health < 30) return AquatanMood.sick;
    if (energy < 20) return AquatanMood.tired;
    if (happiness < 30) return AquatanMood.sad;
    if (energy < 40) return AquatanMood.sleeping;
    if (happiness > 80 && health > 80) return AquatanMood.excited;
    return AquatanMood.happy;
  }

  AquatanGrowthStage _calculateGrowthStage() {
    final totalCommits = _state.totalCommits;
    final age = _state.age;

    if (totalCommits < 10 || age < 1) return AquatanGrowthStage.egg;
    if (totalCommits < 50 || age < 7) return AquatanGrowthStage.baby;
    if (totalCommits < 150 || age < 30) return AquatanGrowthStage.child;
    if (totalCommits < 500 || age < 90) return AquatanGrowthStage.teen;
    if (totalCommits < 1500 || age < 180) return AquatanGrowthStage.adult;
    return AquatanGrowthStage.elder;
  }

  void _updatePose() {
    AquatanPose newPose;

    switch (_state.mood) {
      case AquatanMood.sleeping:
      case AquatanMood.tired:
        newPose = AquatanPose.idle;
        break;
      case AquatanMood.excited:
        newPose = _random.nextBool() ? AquatanPose.jumping : AquatanPose.celebrating;
        break;
      case AquatanMood.sick:
        newPose = AquatanPose.idle;
        break;
      case AquatanMood.sad:
        newPose = _random.nextDouble() < 0.3 ? AquatanPose.walking : AquatanPose.idle;
        break;
      case AquatanMood.happy:
        final rand = _random.nextDouble();
        if (rand < 0.5) {
          newPose = AquatanPose.idle;
        } else if (rand < 0.8) {
          newPose = AquatanPose.walking;
        } else {
          newPose = AquatanPose.jumping;
        }
        break;
    }

    if (_state.currentPose != newPose) {
      _state = _state.copyWith(currentPose: newPose);
      onStateChanged(_state);
    }

    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(
      Duration(milliseconds: _getAnimationInterval()),
      (_) => _updatePose(),
    );
  }

  void feed() {
    final health = (_state.health + 20).clamp(0, 100);
    final energy = (_state.energy + 15).clamp(0, 100);
    
    _state = _state.copyWith(
      health: health,
      energy: energy,
      lastFed: DateTime.now(),
    );
    
    onStateChanged(_state);
  }

  void play() {
    final happiness = (_state.happiness + 25).clamp(0, 100);
    final energy = (_state.energy - 10).clamp(0, 100);
    
    _state = _state.copyWith(
      happiness: happiness,
      energy: energy,
      lastPlayed: DateTime.now(),
      currentPose: AquatanPose.celebrating,
    );
    
    onStateChanged(_state);
  }

  void rest() {
    _state = _state.copyWith(
      mood: AquatanMood.sleeping,
      currentPose: AquatanPose.idle,
    );
    
    onStateChanged(_state);
  }

  void onCommit(int commitCount) {
    final totalCommits = _state.totalCommits + commitCount;
    final happiness = (_state.happiness + (commitCount * 5)).clamp(0, 100);
    final health = (_state.health + (commitCount * 2)).clamp(0, 100);
    
    _state = _state.copyWith(
      totalCommits: totalCommits,
      happiness: happiness,
      health: health,
      currentPose: AquatanPose.celebrating,
    );
    
    _updateState();
    onStateChanged(_state);
  }

  void updateCommitStreak(int streak) {
    final bonus = (streak / 7).floor() * 5;
    final happiness = (_state.happiness + bonus).clamp(0, 100);
    
    _state = _state.copyWith(
      commitStreak: streak,
      happiness: happiness,
    );
    
    onStateChanged(_state);
  }

  void incrementAge() {
    _state = _state.copyWith(age: _state.age + 1);
    _updateState();
    onStateChanged(_state);
  }

  double get displaySize => _state.growthStage.size;

  Color get healthColor {
    if (_state.health > 70) return Colors.green;
    if (_state.health > 40) return Colors.orange;
    return Colors.red;
  }

  Color get energyColor {
    if (_state.energy > 70) return Colors.blue;
    if (_state.energy > 40) return Colors.yellow;
    return Colors.red;
  }

  Color get happinessColor {
    if (_state.happiness > 70) return Colors.pink;
    if (_state.happiness > 40) return Colors.purple;
    return Colors.grey;
  }

  IconData get moodIcon {
    switch (_state.mood) {
      case AquatanMood.happy:
        return Icons.sentiment_very_satisfied;
      case AquatanMood.excited:
        return Icons.celebration;
      case AquatanMood.sad:
        return Icons.sentiment_dissatisfied;
      case AquatanMood.tired:
        return Icons.battery_2_bar;
      case AquatanMood.sick:
        return Icons.sick;
      case AquatanMood.sleeping:
        return Icons.bedtime;
    }
  }

  String get statusMessage {
    switch (_state.mood) {
      case AquatanMood.happy:
        return "I'm doing great! Thanks for coding!";
      case AquatanMood.excited:
        return "Wow! So many commits! You're amazing!";
      case AquatanMood.sad:
        return "I miss you... Let's code together!";
      case AquatanMood.tired:
        return "I'm so tired... Maybe I need rest?";
      case AquatanMood.sick:
        return "I don't feel well... Take care of me!";
      case AquatanMood.sleeping:
        return "Zzz... Let me rest a bit...";
    }
  }
}