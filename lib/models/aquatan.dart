import 'package:flutter/material.dart';

enum AquatanMood {
  happy,
  sad,
  tired,
  excited,
  sick,
  sleeping,
}

enum AquatanGrowthStage {
  egg(size: 0.5, animationSpeed: 1.0),
  baby(size: 0.7, animationSpeed: 1.2),
  child(size: 1.0, animationSpeed: 1.0),
  teen(size: 1.3, animationSpeed: 0.9),
  adult(size: 1.5, animationSpeed: 0.8),
  elder(size: 1.7, animationSpeed: 0.6);

  const AquatanGrowthStage({
    required this.size,
    required this.animationSpeed,
  });

  final double size;
  final double animationSpeed;
}

enum AquatanPose {
  idle(row: 0),
  walking(row: 1),
  jumping(row: 2),
  celebrating(row: 3);

  const AquatanPose({required this.row});

  final int row;
}

class AquatanState {
  final int health;
  final int happiness;
  final int energy;
  final int age;
  final AquatanMood mood;
  final AquatanGrowthStage growthStage;
  final AquatanPose currentPose;
  final Map<String, Color> colors;
  final DateTime lastFed;
  final DateTime lastPlayed;
  final int totalCommits;
  final int commitStreak;

  AquatanState({
    required this.health,
    required this.happiness,
    required this.energy,
    required this.age,
    required this.mood,
    required this.growthStage,
    required this.currentPose,
    required this.colors,
    required this.lastFed,
    required this.lastPlayed,
    required this.totalCommits,
    required this.commitStreak,
  });

  factory AquatanState.initial(Map<String, Color> colors) {
    return AquatanState(
      health: 100,
      happiness: 100,
      energy: 100,
      age: 0,
      mood: AquatanMood.happy,
      growthStage: AquatanGrowthStage.egg,
      currentPose: AquatanPose.idle,
      colors: colors,
      lastFed: DateTime.now(),
      lastPlayed: DateTime.now(),
      totalCommits: 0,
      commitStreak: 0,
    );
  }

  AquatanState copyWith({
    int? health,
    int? happiness,
    int? energy,
    int? age,
    AquatanMood? mood,
    AquatanGrowthStage? growthStage,
    AquatanPose? currentPose,
    Map<String, Color>? colors,
    DateTime? lastFed,
    DateTime? lastPlayed,
    int? totalCommits,
    int? commitStreak,
  }) {
    return AquatanState(
      health: health ?? this.health,
      happiness: happiness ?? this.happiness,
      energy: energy ?? this.energy,
      age: age ?? this.age,
      mood: mood ?? this.mood,
      growthStage: growthStage ?? this.growthStage,
      currentPose: currentPose ?? this.currentPose,
      colors: colors ?? this.colors,
      lastFed: lastFed ?? this.lastFed,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      totalCommits: totalCommits ?? this.totalCommits,
      commitStreak: commitStreak ?? this.commitStreak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'health': health,
      'happiness': happiness,
      'energy': energy,
      'age': age,
      'mood': mood.name,
      'growthStage': growthStage.name,
      'currentPose': currentPose.name,
      'colors': colors.map((k, v) => MapEntry(k, v.value)),
      'lastFed': lastFed.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
      'totalCommits': totalCommits,
      'commitStreak': commitStreak,
    };
  }

  factory AquatanState.fromJson(Map<String, dynamic> json) {
    return AquatanState(
      health: json['health'] as int,
      happiness: json['happiness'] as int,
      energy: json['energy'] as int,
      age: json['age'] as int,
      mood: AquatanMood.values.firstWhere((e) => e.name == json['mood']),
      growthStage: AquatanGrowthStage.values.firstWhere((e) => e.name == json['growthStage']),
      currentPose: AquatanPose.values.firstWhere((e) => e.name == json['currentPose']),
      colors: (json['colors'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, Color(v as int)),
      ),
      lastFed: DateTime.parse(json['lastFed'] as String),
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
      totalCommits: json['totalCommits'] as int,
      commitStreak: json['commitStreak'] as int,
    );
  }
}