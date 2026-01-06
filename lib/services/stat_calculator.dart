import 'package:flutter/material.dart';
import '../models/pet_stats.dart';
import '../models/aquatan.dart';

class StatCalculator {
  static AquatanMood calculateMood(PetStats stats) {
    if (stats.health < 30) return AquatanMood.sick;
    if (stats.energy < 20) return AquatanMood.tired;
    if (stats.happiness < 30) return AquatanMood.sad;
    if (stats.energy < 40) return AquatanMood.sleeping;
    if (stats.happiness > 80 && stats.health > 80) return AquatanMood.excited;
    return AquatanMood.happy;
  }

  static AquatanGrowthStage calculateGrowthStage(int totalCommits, int ageDays) {
    if (totalCommits < 10 || ageDays < 1) return AquatanGrowthStage.egg;
    if (totalCommits < 50 || ageDays < 7) return AquatanGrowthStage.baby;
    if (totalCommits < 150 || ageDays < 30) return AquatanGrowthStage.child;
    if (totalCommits < 500 || ageDays < 90) return AquatanGrowthStage.teen;
    if (totalCommits < 1500 || ageDays < 180) return AquatanGrowthStage.adult;
    return AquatanGrowthStage.elder;
  }

  static Color getStatColor(int value) {
    if (value > 70) return Colors.green;
    if (value > 40) return Colors.orange;
    return Colors.red;
  }

  static IconData getMoodIcon(AquatanMood mood) {
    switch (mood) {
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

  static String getStatusMessage(AquatanMood mood) {
    switch (mood) {
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