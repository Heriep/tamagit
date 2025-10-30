import 'package:flutter/material.dart';

// App Constants
class AppConstants {
  // App Info
  static const String appName = 'TamaGit';
  static const String version = '0.1.0';

  // Pet Constants
  static const int maxHunger = 100;
  static const int maxHappiness = 100;
  static const int maxEnergy = 100;
  static const int hungerDecayPerHour = 2;
  static const int happinessDecayPerHour = 1;
  static const int energyDecayPerHour = 3;

  // GitHub Constants
  static const int defaultCheckIntervalMinutes = 60;
  static const int commitsPerDay = 1;
  static const int foodValuePerCommit = 10;

  // UI Constants
  static const double petWidgetSize = 200.0;
  static const double statBarHeight = 20.0;
  static const double defaultPadding = 16.0;

  // Colors
  static const Color happyColor = Color(0xFF4CAF50);
  static const Color neutralColor = Color(0xFF2196F3);
  static const Color sadColor = Color(0xFFF44336);
  static const Color sleepingColor = Color(0xFF9C27B0);
  
  // Mood Colors
  static Color getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return happyColor;
      case 'sad':
        return sadColor;
      case 'sleeping':
        return sleepingColor;
      default:
        return neutralColor;
    }
  }

  // Pet Stage Emojis
  static const Map<String, String> stageEmojis = {
    'egg': '🥚',
    'baby': '🐣',
    'teen': '🐥',
    'adult': '🐔',
  };

  // Mood Emojis
  static const Map<String, String> moodEmojis = {
    'happy': '😊',
    'neutral': '😐',
    'sad': '😢',
    'sleeping': '😴',
  };
}