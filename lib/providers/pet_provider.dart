import 'package:flutter/material.dart';
import '../models/aquatan.dart';
import '../models/statistics.dart';
import '../services/aquatan_manager.dart';
import '../services/storage_service.dart';
import '../services/statistics_service.dart';
import '../utils/aquatan_generator.dart';

class PetProvider extends ChangeNotifier {
  AquatanManager? _aquatanManager;
  Statistics? _statistics;
  final StorageService _storageService;
  final StatisticsService _statisticsService;
  String? _username;
  bool _isInitialized = false;

  PetProvider(this._storageService, this._statisticsService);

  AquatanManager? get aquatanManager => _aquatanManager;
  AquatanState? get state => _aquatanManager?.state;
  Statistics? get statistics => _statistics;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(String username) async {
    _username = username;
    
    // Load or create statistics
    _statistics = await _statisticsService.loadStatistics();
    
    // Try to load saved state
    final savedState = await _storageService.loadAquatanState();
    
    AquatanState initialState;
    if (savedState != null) {
      initialState = savedState;
    } else {
      final colors = AquatanGenerator.generateColorsFromUsername(username);
      initialState = AquatanState.initial(colors);
    }

    _aquatanManager = AquatanManager(
      initialState: initialState,
      onStateChanged: (state) async {
        await _storageService.saveAquatanState(state);
        notifyListeners();
      },
    );

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> feed() async {
    _aquatanManager?.feed();
    _statistics?.recordFeed();
    await _saveStatistics();
    notifyListeners();
  }

  Future<void> play() async {
    _aquatanManager?.play();
    _statistics?.recordPlay();
    await _saveStatistics();
    notifyListeners();
  }

  Future<void> rest() async {
    _aquatanManager?.rest();
    _statistics?.recordRest();
    await _saveStatistics();
    notifyListeners();
  }

  Future<void> onCommit(int commitCount, {DateTime? commitDate}) async {
    _aquatanManager?.onCommit(commitCount);
    _statistics?.recordCommits(commitCount, commitDate ?? DateTime.now());
    
    if (_statistics != null) {
      _aquatanManager?.updateCommitStreak(_statistics!.currentStreak);
    }
    
    await _saveStatistics();
    notifyListeners();
  }

  Future<void> _saveStatistics() async {
    if (_statistics != null) {
      await _statisticsService.saveStatistics(_statistics!);
    }
  }

  @override
  void dispose() {
    _aquatanManager?.dispose();
    super.dispose();
  }
}