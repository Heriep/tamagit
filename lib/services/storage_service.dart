import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/user_settings.dart';
import '../models/aquatan.dart';

class StorageService {
  static const String _petKey = 'pet_data';
  static const String _settingsKey = 'user_settings';
  static const String _lastUpdateKey = 'last_update';

  // Save pet state
  Future<void> savePet(Pet pet) async {
    final prefs = await SharedPreferences.getInstance();
    final petJson = json.encode(pet.toJson());
    await prefs.setString(_petKey, petJson);
  }

  // Load pet state
  Future<Pet?> loadPet() async {
    final prefs = await SharedPreferences.getInstance();
    final petJson = prefs.getString(_petKey);
    
    if (petJson == null) {
      return null;
    }

    try {
      final petData = json.decode(petJson);
      return Pet.fromJson(petData);
    } catch (e) {
      // If there's an error parsing, return null (fresh start)
      return null;
    }
  }

  // Save user settings
  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }

  // Load user settings
  Future<UserSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson == null) {
      return UserSettings();
    }

    try {
      final settingsData = json.decode(settingsJson);
      return UserSettings.fromJson(settingsData);
    } catch (e) {
      return UserSettings();
    }
  }

  // Save last update time
  Future<void> saveLastUpdate(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUpdateKey, dateTime.toIso8601String());
  }

  // Get last update time
  Future<DateTime?> getLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString(_lastUpdateKey);
    
    if (lastUpdate == null) {
      return null;
    }

    try {
      return DateTime.parse(lastUpdate);
    } catch (e) {
      return null;
    }
  }

  // Save Aquatan state
  Future<void> saveAquatanState(AquatanState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aquatan_state', jsonEncode(state.toJson()));
  }

  // Load Aquatan state
  Future<AquatanState?> loadAquatanState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString('aquatan_state');
    
    if (stateJson != null) {
      return AquatanState.fromJson(jsonDecode(stateJson));
    }
    return null;
  }

  // Clear all data (for reset)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_petKey);
    await prefs.remove(_lastUpdateKey);
    // Keep settings
  }
}