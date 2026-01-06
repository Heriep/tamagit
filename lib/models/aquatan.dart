import 'package:flutter/material.dart';
import '../models/pet_stats.dart';

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
  walkingFront(row: 0),
  walkingLeft(row: 1),
  walkingRight(row: 2),
  walkingBack(row: 3);

  const AquatanPose({required this.row});

  final int row;
}

class AquatanState {
  final PetStats stats;
  final int age;
  final AquatanMood mood;
  final AquatanGrowthStage growthStage;
  final AquatanPose currentPose;
  final Map<String, Color> colors;
  final DateTime lastFed;
  final DateTime lastPlayed;
  final DateTime lastRested;
  final int totalCommits;
  final int commitStreak;
  final DateTime createdAt;

  AquatanState({
    required this.stats,
    required this.age,
    required this.mood,
    required this.growthStage,
    required this.currentPose,
    required this.colors,
    required this.lastFed,
    required this.lastPlayed,
    required this.lastRested,
    required this.totalCommits,
    required this.commitStreak,
    required this.createdAt,
  });

  factory AquatanState.initial(Map<String, Color> colors) {
    final now = DateTime.now();
    return AquatanState(
      stats: PetStats.initial(),
      age: 0,
      mood: AquatanMood.happy,
      growthStage: AquatanGrowthStage.egg,
      currentPose: AquatanPose.walkingFront,
      colors: colors,
      lastFed: now,
      lastPlayed: now,
      lastRested: now,
      totalCommits: 0,
      commitStreak: 0,
      createdAt: now,
    );
  }

  int get health => stats.health;
  int get happiness => stats.happiness;
  int get energy => stats.energy;

  AquatanState copyWith({
    PetStats? stats,
    int? age,
    AquatanMood? mood,
    AquatanGrowthStage? growthStage,
    AquatanPose? currentPose,
    Map<String, Color>? colors,
    DateTime? lastFed,
    DateTime? lastPlayed,
    DateTime? lastRested,
    int? totalCommits,
    int? commitStreak,
    DateTime? createdAt,
  }) {
    return AquatanState(
      stats: stats ?? this.stats,
      age: age ?? this.age,
      mood: mood ?? this.mood,
      growthStage: growthStage ?? this.growthStage,
      currentPose: currentPose ?? this.currentPose,
      colors: colors ?? this.colors,
      lastFed: lastFed ?? this.lastFed,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      lastRested: lastRested ?? this.lastRested,
      totalCommits: totalCommits ?? this.totalCommits,
      commitStreak: commitStreak ?? this.commitStreak,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.toJson(),
      'age': age,
      'mood': mood.name,
      'growthStage': growthStage.name,
      'currentPose': currentPose.name,
      'colors': colors.map((k, v) => MapEntry(k, v.value)),
      'lastFed': lastFed.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
      'lastRested': lastRested.toIso8601String(),
      'totalCommits': totalCommits,
      'commitStreak': commitStreak,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AquatanState.fromJson(Map<String, dynamic> json) {
    return AquatanState(
      stats: PetStats.fromJson(json['stats'] ?? {}),
      age: json['age'] as int? ?? 0,
      mood: AquatanMood.values.firstWhere(
        (e) => e.name == json['mood'],
        orElse: () => AquatanMood.happy,
      ),
      growthStage: AquatanGrowthStage.values.firstWhere(
        (e) => e.name == json['growthStage'],
        orElse: () => AquatanGrowthStage.egg,
      ),
      currentPose: AquatanPose.values.firstWhere(
        (e) => e.name == json['currentPose'],
        orElse: () => AquatanPose.walkingFront,
      ),
      colors: (json['colors'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, Color(v as int)),
      ) ?? {},
      lastFed: DateTime.parse(json['lastFed'] as String? ?? DateTime.now().toIso8601String()),
      lastPlayed: DateTime.parse(json['lastPlayed'] as String? ?? DateTime.now().toIso8601String()),
      lastRested: DateTime.parse(json['lastRested'] as String? ?? DateTime.now().toIso8601String()),
      totalCommits: json['totalCommits'] as int? ?? 0,
      commitStreak: json['commitStreak'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}