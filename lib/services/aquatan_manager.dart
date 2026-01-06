import 'dart:async';
import 'dart:math';
import '../models/aquatan.dart';
import 'stat_calculator.dart';
import '../utils/game_constants.dart';

class AquatanManager {
  AquatanState _state;
  Timer? _decayTimer;
  Timer? _poseTimer;
  Timer? _agingTimer;
  final Function(AquatanState) onStateChanged;
  final Random _random = Random();

  AquatanManager({
    required AquatanState initialState,
    required this.onStateChanged,
  }) : _state = initialState {
    _startTimers();
  }

  AquatanState get state => _state;

  void dispose() {
    _decayTimer?.cancel();
    _poseTimer?.cancel();
    _agingTimer?.cancel();
  }

  void _startTimers() {
    // Decay timer - runs every hour
    _decayTimer = Timer.periodic(const Duration(hours: 1), (_) => _applyDecay());
    
    // Pose animation timer - changes walking direction
    _schedulePoseUpdate();
    
    // Aging timer - runs daily
    _agingTimer = Timer.periodic(const Duration(days: 1), (_) => _incrementAge());
  }

  void _applyDecay() {
    final now = DateTime.now();
    final timeSinceLastUpdate = now.difference(_state.lastFed);
    
    final newStats = _state.stats.applyDecay(timeSinceLastUpdate);
    _updateState(_state.copyWith(stats: newStats));
  }

  void _incrementAge() {
    _updateState(_state.copyWith(age: _state.age + 1));
  }

  void _schedulePoseUpdate() {
    _poseTimer?.cancel();
    
    final interval = _calculatePoseInterval();
    _poseTimer = Timer(Duration(milliseconds: interval), () {
      _updatePose();
      _schedulePoseUpdate();
    });
  }

  int _calculatePoseInterval() {
    final energyFactor = (_state.energy / 100).clamp(0.1, 1.0);
    final stageFactor = _state.growthStage.animationSpeed.clamp(0.1, 10.0);
    
    // More frequent direction changes when energetic
    final interval = (GameConstants.baseAnimationInterval * 8 / (energyFactor * stageFactor)).round();
    return interval.clamp(1000, 5000); // Change direction every 1-5 seconds
  }

  void _updatePose() {
    final newPose = _selectPoseForMood(_state.mood);
    if (newPose != _state.currentPose) {
      _updateState(_state.copyWith(currentPose: newPose));
    }
  }

  AquatanPose _selectPoseForMood(AquatanMood mood) {
    switch (mood) {
      case AquatanMood.sleeping:
      case AquatanMood.sick:
        // Stay facing front when sleeping/sick
        return AquatanPose.walkingFront;
        
      case AquatanMood.tired:
        // Mostly stay still, occasionally turn
        return _random.nextDouble() < 0.8 
            ? AquatanPose.walkingFront 
            : AquatanPose.values[_random.nextInt(AquatanPose.values.length)];
        
      case AquatanMood.sad:
        // Slow pacing left and right
        return _random.nextBool() ? AquatanPose.walkingLeft : AquatanPose.walkingRight;
        
      case AquatanMood.excited:
        // Rapid random movement in all directions
        return AquatanPose.values[_random.nextInt(AquatanPose.values.length)];
        
      case AquatanMood.happy:
        // Normal wandering behavior
        final rand = _random.nextDouble();
        if (rand < 0.4) return AquatanPose.walkingFront;
        if (rand < 0.6) return AquatanPose.walkingBack;
        if (rand < 0.8) return AquatanPose.walkingLeft;
        return AquatanPose.walkingRight;
    }
  }

  void _updateState(AquatanState newState) {
    // Recalculate mood and growth stage based on new stats
    final mood = StatCalculator.calculateMood(newState.stats);
    final growthStage = StatCalculator.calculateGrowthStage(
      newState.totalCommits,
      newState.age,
    );
    
    _state = newState.copyWith(
      mood: mood,
      growthStage: growthStage,
    );
    
    onStateChanged(_state);
  }

  // Player actions
  void feed() {
    final newStats = _state.stats.feed();
    _updateState(_state.copyWith(
      stats: newStats,
      lastFed: DateTime.now(),
      currentPose: AquatanPose.walkingFront, // Face front when being fed
    ));
  }

  void play() {
    final newStats = _state.stats.play();
    _updateState(_state.copyWith(
      stats: newStats,
      lastPlayed: DateTime.now(),
      currentPose: AquatanPose.walkingBack, // Jump around happily
    ));
  }

  void rest() {
    final newStats = _state.stats.rest();
    _updateState(_state.copyWith(
      stats: newStats,
      lastRested: DateTime.now(),
      mood: AquatanMood.sleeping,
      currentPose: AquatanPose.walkingFront, // Face front while sleeping
    ));
  }

  void onCommit(int commitCount) {
    final newStats = _state.stats.receiveCommitReward(commitCount);
    _updateState(_state.copyWith(
      stats: newStats,
      totalCommits: _state.totalCommits + commitCount,
      currentPose: AquatanPose.walkingFront, // Face front when receiving commits
    ));
  }

  void updateCommitStreak(int streak) {
    final bonusHappiness = (streak / 7).floor() * 5;
    final newStats = _state.stats.copyWith(
      happiness: _state.happiness + bonusHappiness,
    );
    
    _updateState(_state.copyWith(
      stats: newStats,
      commitStreak: streak,
    ));
  }

  // Make _updateState accessible for debug purposes
  void debugUpdateState(AquatanState newState) {
    _updateState(newState);
  }

  // Debug method to force state override (bypasses recalculation)
  void debugSetState(AquatanState newState) {
    _state = newState;
    onStateChanged(_state);
  }
}