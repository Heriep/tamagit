import 'package:flutter/material.dart';
import '../models/aquatan.dart';
import '../services/aquatan_manager.dart';
import '../services/storage_service.dart';
import '../utils/aquatan_generator.dart';

class PetProvider extends ChangeNotifier {
  AquatanManager? _aquatanManager;
  final StorageService _storageService;
  String? _username;

  PetProvider(this._storageService);

  AquatanManager? get aquatanManager => _aquatanManager;
  AquatanState? get state => _aquatanManager?.state;

  Future<void> initialize(String username) async {
    _username = username;
    
    // Try to load saved state
    final savedState = await _storageService.loadAquatanState();
    
    AquatanState initialState;
    if (savedState != null) {
      initialState = savedState;
    } else {
      // Generate colors from username
      final colors = AquatanGenerator.generateColorsFromUsername(username);
      initialState = AquatanState.initial(colors);
    }

    _aquatanManager = AquatanManager(
      initialState: initialState,
      onStateChanged: (state) {
        _storageService.saveAquatanState(state);
        notifyListeners();
      },
    );

    notifyListeners();
  }

  void feed() {
    _aquatanManager?.feed();
    notifyListeners();
  }

  void play() {
    _aquatanManager?.play();
    notifyListeners();
  }

  void rest() {
    _aquatanManager?.rest();
    notifyListeners();
  }

  void onCommit(int commitCount) {
    _aquatanManager?.onCommit(commitCount);
    notifyListeners();
  }

  void updateCommitStreak(int streak) {
    _aquatanManager?.updateCommitStreak(streak);
    notifyListeners();
  }

  void incrementAge() {
    _aquatanManager?.incrementAge();
    notifyListeners();
  }

  @override
  void dispose() {
    _aquatanManager?.dispose();
    super.dispose();
  }
}