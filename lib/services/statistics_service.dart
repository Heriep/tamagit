import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/statistics.dart';

class StatisticsService {
  static const String _statisticsKey = 'statistics_data';

  Future<void> saveStatistics(Statistics statistics) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(statistics.toJson());
    await prefs.setString(_statisticsKey, jsonString);
  }

  Future<Statistics> loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_statisticsKey);
    
    if (jsonString == null) {
      return Statistics.initial();
    }
    
    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return Statistics.fromJson(jsonMap);
    } catch (e) {
      // If there's an error parsing, return initial statistics
      return Statistics.initial();
    }
  }

  Future<void> clearStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statisticsKey);
  }
}